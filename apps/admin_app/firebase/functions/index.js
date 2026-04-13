const admin = require('firebase-admin');
const { onCall, onRequest, HttpsError } = require('firebase-functions/v2/https');

admin.initializeApp();

const db = admin.firestore();
const auth = admin.auth();

async function ensureRoleConstraints({ role, schoolId, excludeUserId = null }) {
  if (role === 'admin') {
    const snapshot = await db.collection('users').where('role', '==', 'admin').limit(5).get();
    const conflicting = snapshot.docs.find((doc) => doc.id !== excludeUserId);
    if (conflicting) {
      throw new HttpsError('already-exists', 'Only one admin account is allowed.');
    }
  }

  if (role === 'pedagogiqueManager') {
    const normalizedSchoolId = String(schoolId || '').trim();
    if (!normalizedSchoolId) {
      throw new HttpsError('invalid-argument', 'schoolId is required for pedagogiqueManager.');
    }

    const snapshot = await db
      .collection('users')
      .where('role', '==', 'pedagogiqueManager')
      .where('schoolId', '==', normalizedSchoolId)
      .limit(5)
      .get();
    const conflicting = snapshot.docs.find((doc) => doc.id !== excludeUserId);
    if (conflicting) {
      throw new HttpsError(
        'already-exists',
        `School "${normalizedSchoolId}" already has a pedagogique manager.`,
      );
    }
  }
}

async function requirePrivilegedUser(request) {
  if (!request.auth?.uid) {
    throw new HttpsError('unauthenticated', 'You must be signed in.');
  }

  const userDoc = await db.collection('users').doc(request.auth.uid).get();
  const role = userDoc.data()?.role;
  const status = userDoc.data()?.status;

  if (status == 'inactive') {
    throw new HttpsError('permission-denied', 'Your account is inactive.');
  }

  if (role !== 'admin' && role !== 'pedagogiqueManager') {
    throw new HttpsError('permission-denied', 'Only admin roles can perform this action.');
  }

  return userDoc.data() || {};
}

function defaultEmotionForRole(role) {
  return role === 'student' ? 'curious' : 'steady';
}

function defaultEvolutionForRole(role) {
  if (role === 'student') {
    return 'spark';
  }
  if (role === 'teacher') {
    return 'mentor';
  }
  return 'manager';
}

async function createUserProfile({ uid, displayName, email, role, schoolId, schoolName, teacherId }) {
  const batch = db.batch();
  const schoolRef = schoolId ? db.collection('schools').doc(String(schoolId).trim()) : null;
  if (schoolRef) {
    batch.set(
      schoolRef,
      {
        name: schoolName || String(schoolId).trim(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  }

  batch.set(
    db.collection('users').doc(uid),
    {
      displayName,
      email,
      role,
      status: 'active',
      schoolId: schoolId ? String(schoolId).trim() : '',
      teacherId: teacherId ? String(teacherId).trim() : null,
      avatarCharacterId: 'lumi',
      totalXP: 0,
      dailyStreak: role === 'student' ? 1 : 0,
      currentEmotion: defaultEmotionForRole(role),
      evolutionStage: defaultEvolutionForRole(role),
      provisioningState: 'active',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );

  if (role === 'student') {
    batch.set(
      db.collection('progress').doc(uid),
      {
        userId: uid,
        completedLessonIds: [],
        currentLessonId: 'chapter_1_lesson_1',
        unlockedChapterIds: ['chapter_1'],
        badgesCount: 0,
        masteryScore: 0.42,
        completedLessonsCount: 0,
        lessonStates: {},
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  }

  await batch.commit();
}

exports.bootstrapFirstAdmin = onRequest(async (request, response) => {
  response.set('Access-Control-Allow-Origin', '*');
  response.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  response.set('Access-Control-Allow-Headers', 'Content-Type');

  if (request.method === 'OPTIONS') {
    response.status(204).send('');
    return;
  }

  if (request.method !== 'POST') {
    response.status(405).json({ error: 'method-not-allowed' });
    return;
  }

  const existingAdmins = await db.collection('users').where('role', '==', 'admin').limit(1).get();
  if (!existingAdmins.empty) {
    response.status(409).json({ error: 'admin-already-exists' });
    return;
  }

  const { displayName, email, password } = request.body || {};
  if (!displayName || !email || !password) {
    response.status(400).json({ error: 'displayName, email, and password are required.' });
    return;
  }

  try {
    const userRecord = await auth.createUser({
      displayName,
      email,
      password,
    });

    await createUserProfile({
      uid: userRecord.uid,
      displayName,
      email,
      role: 'admin',
      schoolId: '',
      schoolName: null,
      teacherId: null,
    });

    response.status(200).json({
      uid: userRecord.uid,
      email,
      role: 'admin',
    });
  } catch (error) {
    response.status(500).json({
      error: error?.message || 'bootstrap-failed',
    });
  }
});

exports.provisionUserAccount = onCall(async (request) => {
  await requirePrivilegedUser(request);

  const {
    displayName,
    email,
    password,
    role,
    schoolId,
    schoolName,
    teacherId,
  } = request.data || {};

  if (!displayName || !email || !password || !role) {
    throw new HttpsError('invalid-argument', 'displayName, email, password, and role are required.');
  }

  await ensureRoleConstraints({ role, schoolId });

  const userRecord = await auth.createUser({
    displayName,
    email,
    password,
  });

  await auth.setCustomUserClaims(userRecord.uid, { role });

  await createUserProfile({
    uid: userRecord.uid,
    displayName,
    email,
    role,
    schoolId,
    schoolName,
    teacherId,
  });

  return {
    uid: userRecord.uid,
    email: userRecord.email,
    role,
  };
});

exports.createSchool = onCall(async (request) => {
  await requirePrivilegedUser(request);

  const { schoolId, name } = request.data || {};
  if (!schoolId || !name) {
    throw new HttpsError('invalid-argument', 'schoolId and name are required.');
  }

  await db.collection('schools').doc(String(schoolId).trim()).set(
    {
      name,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );

  return { schoolId };
});

exports.updateUserProfile = onCall(async (request) => {
  await requirePrivilegedUser(request);

  const { userId, displayName, role, schoolId } = request.data || {};
  if (!userId) {
    throw new HttpsError('invalid-argument', 'userId is required.');
  }

  const updates = {
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  const existingUser = await db.collection('users').doc(userId).get();
  const existingData = existingUser.data() || {};

  await ensureRoleConstraints({
    role: role || existingData.role,
    schoolId: schoolId !== undefined ? schoolId : existingData.schoolId,
    excludeUserId: userId,
  });

  if (displayName) {
    updates.displayName = displayName;
  }
  if (role) {
    updates.role = role;
    await auth.setCustomUserClaims(userId, { role });
  }
  if (schoolId !== undefined) {
    updates.schoolId = schoolId;
  }

  await db.collection('users').doc(userId).set(updates, { merge: true });
  return { userId };
});

exports.setUserStatus = onCall(async (request) => {
  await requirePrivilegedUser(request);

  const { userId, status } = request.data || {};
  if (!userId || !status) {
    throw new HttpsError('invalid-argument', 'userId and status are required.');
  }

  await db.collection('users').doc(userId).set(
    {
      status,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );

  await auth.updateUser(userId, { disabled: status === 'inactive' });

  return { userId, status };
});

exports.assignTeacherToStudent = onCall(async (request) => {
  await requirePrivilegedUser(request);

  const { studentId, teacherId } = request.data || {};
  if (!studentId) {
    throw new HttpsError('invalid-argument', 'studentId is required.');
  }

  await db.collection('users').doc(studentId).set(
    {
      teacherId: teacherId ? String(teacherId).trim() : null,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );

  return { studentId, teacherId: teacherId || null };
});
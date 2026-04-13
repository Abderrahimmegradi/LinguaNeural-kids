import { initializeApp } from 'firebase/app';
import { collection, deleteDoc, doc, getDocs, getFirestore, writeBatch } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: 'AIzaSyAvpGY7AygxEu5RsBbez249kIwoCRu-DvI',
  appId: '1:395160022558:web:11189fd4c783a6b951880f',
  messagingSenderId: '395160022558',
  projectId: 'linguaneuralkids',
  authDomain: 'linguaneuralkids.firebaseapp.com',
  storageBucket: 'linguaneuralkids.firebasestorage.app',
  measurementId: 'G-ENB18EBDKS',
};

const demoUserIds = [
  'admin_root',
  'pedagogique_manager_1',
  'teacher_amal',
  'teacher_samir',
  'student_demo',
  'student_aya',
];

const demoSchoolIds = ['school_sunrise', 'school_oasis'];
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

async function deleteByIds(collectionName, ids) {
  if (ids.length === 0) {
    return 0;
  }

  const batch = writeBatch(db);
  for (const id of ids) {
    batch.delete(doc(db, collectionName, id));
  }
  await batch.commit();
  return ids.length;
}

async function deleteEmotionDocs() {
  let deleted = 0;
  for (const collectionName of ['emotions', 'emotion_events']) {
    const snapshot = await getDocs(collection(db, collectionName));
    for (const item of snapshot.docs) {
      await deleteDoc(item.ref);
      deleted += 1;
    }
  }
  return deleted;
}

async function cleanup() {
  const deletedUsers = await deleteByIds('users', demoUserIds);
  const deletedProgress = await deleteByIds('progress', demoUserIds.filter((id) => id.startsWith('student_') || id === 'student_demo'));
  const deletedSchools = await deleteByIds('schools', demoSchoolIds);
  const deletedEmotions = await deleteEmotionDocs();

  console.log(JSON.stringify({
    deletedUsers,
    deletedProgress,
    deletedSchools,
    deletedEmotions,
  }, null, 2));
}

cleanup().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
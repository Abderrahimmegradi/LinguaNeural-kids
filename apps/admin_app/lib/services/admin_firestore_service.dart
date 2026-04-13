import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

import '../firebase_options.dart';
import '../models/admin_dashboard_models.dart';

class AdminFirestoreService {
  AdminFirestoreService({FirebaseFirestore? firestore})
  : _firestore = firestore ?? _resolveFirestore();

  final FirebaseFirestore? _firestore;

  static FirebaseFirestore? _resolveFirestore() {
    try {
      return Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null;
    } catch (_) {
      return null;
    }
  }

  Future<AdminDashboardBundle> loadDashboard() async {
    if (_firestore == null) {
      return _fallbackDashboard();
    }

    final usersSnapshot = await _firestore.collection('users').get();
    final progressSnapshot = await _firestore.collection('progress').get();
    final schoolsSnapshot = await _firestore.collection('schools').get();

    final progressByUserId = {
      for (final doc in progressSnapshot.docs) doc.id: doc.data(),
    };
    final schoolsById = {
      for (final doc in schoolsSnapshot.docs) doc.id: doc.data(),
    };

    final users = usersSnapshot.docs
        .map((doc) => _mapUser(doc.id, doc.data(), progressByUserId[doc.id]))
        .toList(growable: false)
      ..sort((a, b) {
        final roleCompare = a.role.compareTo(b.role);
        if (roleCompare != 0) {
          return roleCompare;
        }
        return a.displayName.compareTo(b.displayName);
      });

    final roleCounts = _buildRoleCounts(users);
    final schoolSummaries = _buildSchoolSummaries(users, schoolsById);
    final teacherSummaries = _buildTeacherSummaries(users);

    return AdminDashboardBundle(
      users: users,
      roleCounts: roleCounts,
      schoolSummaries: schoolSummaries,
      teacherSummaries: teacherSummaries,
    );
  }

  Future<void> createUser({
    required String email,
    required String password,
    required String role,
    String? schoolId,
    String? teacherId,
  }) async {
    if (_firestore == null) {
      throw Exception('Firestore is not available.');
    }

    final normalizedRole = role.trim();
    final normalizedEmail = email.trim();
    final normalizedSchoolId = (schoolId ?? '').trim();
    final normalizedTeacherId = (teacherId ?? '').trim();

    await _ensureRoleConstraints(role: normalizedRole);

    final response = await http.post(
      Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${DefaultFirebaseOptions.web.apiKey}',
      ),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': normalizedEmail,
        'password': password,
        'returnSecureToken': false,
      }),
    );

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      final code = payload['error']?['message'] as String? ?? 'UNKNOWN';
      throw Exception(_friendlyAuthError(code));
    }

    final userId = payload['localId'] as String?;
    if (userId == null || userId.isEmpty) {
      throw Exception('Firebase did not return a user id.');
    }

    final displayName = _displayNameFromEmail(normalizedEmail);
    await _firestore.collection('users').doc(userId).set({
      'displayName': displayName,
      'email': normalizedEmail,
      'role': normalizedRole,
      'status': 'active',
      'schoolId': normalizedSchoolId,
      'teacherId': normalizedTeacherId.isEmpty ? null : normalizedTeacherId,
      'avatarCharacterId': 'lumi',
      'totalXP': 0,
      'dailyStreak': normalizedRole == 'student' ? 1 : 0,
      'currentEmotion': normalizedRole == 'student' ? 'curious' : 'steady',
      'evolutionStage': _defaultEvolutionForRole(normalizedRole),
      'provisioningState': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (normalizedRole == 'student') {
      await _firestore.collection('progress').doc(userId).set({
        'userId': userId,
        'completedLessonIds': <String>[],
        'currentLessonId': 'chapter_1_lesson_1',
        'unlockedChapterIds': <String>['chapter_1'],
        'badgesCount': 0,
        'masteryScore': 0.42,
        'completedLessonsCount': 0,
        'lessonStates': <String, dynamic>{},
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> createSchool({
    required String schoolId,
    required String name,
  }) async {
    if (_firestore == null) {
      throw Exception('Firestore is not available.');
    }

    await _firestore.collection('schools').doc(schoolId.trim()).set({
      'name': name.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateUserProfile({
    required String userId,
    required String displayName,
    required String role,
    required String schoolId,
  }) async {
    if (_firestore == null) {
      throw Exception('Firestore is not available.');
    }

    await _ensureRoleConstraints(role: role.trim(), excludeUserId: userId);

    await _firestore.collection('users').doc(userId).set({
      'displayName': displayName.trim(),
      'role': role.trim(),
      'schoolId': schoolId.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setUserStatus({
    required String userId,
    required String status,
  }) async {
    if (_firestore == null) {
      throw Exception('Firestore is not available.');
    }

    await _firestore.collection('users').doc(userId).set({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> assignTeacherToStudent({
    required String studentId,
    String? teacherId,
  }) async {
    if (_firestore == null) {
      throw Exception('Firestore is not available.');
    }

    await _firestore.collection('users').doc(studentId).set({
      'teacherId': (teacherId ?? '').trim().isEmpty ? null : teacherId!.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<AdminStudentInsight> loadStudentInsight(AdminUserRecord user) async {
    if (_firestore == null) {
      return AdminStudentInsight(
        user: user,
        currentLessonId: 'chapter_1_lesson_1',
        completedLessonsCount: 0,
        badgesCount: 0,
        unlockedChapterIds: const ['chapter_1'],
        lessonStates: const [],
        emotionEvents: const [],
      );
    }

    final progressSnapshot = await _firestore.collection('progress').doc(user.id).get();
    final emotionEventsSnapshot = await _firestore
        .collection('emotion_events')
        .where('userId', isEqualTo: user.id)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();

    final progressData = progressSnapshot.data() ?? <String, dynamic>{};
    final lessonStatesMap = Map<String, dynamic>.from(
      progressData['lessonStates'] as Map<String, dynamic>? ?? const <String, dynamic>{},
    );

    final lessonStates = lessonStatesMap.entries
        .map(
          (entry) => AdminLessonStateSummary(
            lessonId: entry.key,
            completed: entry.value['completed'] as bool? ?? false,
            score: (entry.value['score'] as num?)?.toDouble() ?? 0,
            mistakeCount: entry.value['mistakeCount'] as int? ?? 0,
            xpEarned: entry.value['xpEarned'] as int? ?? 0,
          ),
        )
        .toList(growable: false)
      ..sort((a, b) => b.score.compareTo(a.score));

    final emotionEvents = emotionEventsSnapshot.docs
        .map(
          (doc) => AdminEmotionEvent(
            lessonId: doc.data()['lessonId'] as String? ?? 'unknown_lesson',
            emotion: doc.data()['emotion'] as String? ?? 'unknown',
            masteryScore: (doc.data()['masteryScore'] as num?)?.toDouble() ?? 0,
            score: (doc.data()['score'] as num?)?.toDouble() ?? 0,
            mistakeCount: doc.data()['mistakeCount'] as int? ?? 0,
            createdAt: (doc.data()['createdAt'] as Timestamp?)?.toDate(),
          ),
        )
        .toList(growable: false);

    return AdminStudentInsight(
      user: user,
      currentLessonId: progressData['currentLessonId'] as String? ?? 'chapter_1_lesson_1',
      completedLessonsCount: progressData['completedLessonsCount'] as int? ?? lessonStates.length,
      badgesCount: progressData['badgesCount'] as int? ?? 0,
      unlockedChapterIds: List<String>.from(
        (progressData['unlockedChapterIds'] as List<dynamic>? ?? const ['chapter_1']),
      ),
      lessonStates: lessonStates,
      emotionEvents: emotionEvents,
    );
  }

  AdminUserRecord _mapUser(
    String id,
    Map<String, dynamic> userData,
    Map<String, dynamic>? progressData,
  ) {
    final mastery = progressData == null
        ? 0.0
        : ((progressData['masteryScore'] as num?)?.toDouble() ?? 0.0);

    return AdminUserRecord(
      id: id,
      displayName: userData['displayName'] as String? ?? 'Unnamed user',
      email: userData['email'] as String? ?? 'no-email@pending.local',
      role: userData['role'] as String? ?? 'student',
      status: userData['status'] as String? ?? 'active',
      schoolId: userData['schoolId'] as String? ?? 'unassigned',
      teacherId: userData['teacherId'] as String?,
      totalXp: userData['totalXP'] as int? ?? 0,
      dailyStreak: userData['dailyStreak'] as int? ?? 0,
      currentEmotion: userData['currentEmotion'] as String? ?? 'unknown',
      evolutionStage: userData['evolutionStage'] as String? ?? 'spark',
      masteryScore: mastery,
    );
  }

  List<AdminRoleCount> _buildRoleCounts(List<AdminUserRecord> users) {
    const roles = ['admin', 'pedagogiqueManager', 'teacher', 'student'];
    return roles
        .map(
          (role) => AdminRoleCount(
            role: role,
            count: users.where((user) => user.role == role).length,
          ),
        )
        .toList(growable: false);
  }

  List<SchoolSummary> _buildSchoolSummaries(
    List<AdminUserRecord> users,
    Map<String, Map<String, dynamic>> schoolsById,
  ) {
    final schoolIds = {
      ...schoolsById.keys,
      ...users.map((user) => user.schoolId).where((value) => value.isNotEmpty),
    };

    return schoolIds.map((schoolId) {
      final schoolUsers = users.where((user) => user.schoolId == schoolId).toList(growable: false);
      final teachers = schoolUsers.where((user) => user.role == 'teacher').length;
      final students = schoolUsers.where((user) => user.role == 'student').toList(growable: false);
      final averageXp = students.isEmpty
          ? 0.0
          : students.map((user) => user.totalXp).reduce((a, b) => a + b) / students.length;
      final averageMastery = students.isEmpty
          ? 0.0
          : students.map((user) => user.masteryScore).reduce((a, b) => a + b) / students.length;

      return SchoolSummary(
        schoolId: schoolId,
        schoolName: schoolsById[schoolId]?['name'] as String? ?? _schoolLabel(schoolId),
        teacherCount: teachers,
        studentCount: students.length,
        averageXp: averageXp,
        averageMastery: averageMastery,
      );
    }).toList(growable: false)
      ..sort((a, b) => a.schoolName.compareTo(b.schoolName));
  }

  List<TeacherSummary> _buildTeacherSummaries(List<AdminUserRecord> users) {
    final teachers = users.where((user) => user.isTeacher).toList(growable: false);
    final students = users.where((user) => user.isStudent).toList(growable: false);

    return teachers.map((teacher) {
      final assignedStudents = students
          .where((student) => student.teacherId == teacher.id ||
              (student.teacherId == null && student.schoolId == teacher.schoolId))
          .toList(growable: false);
      final averageMastery = assignedStudents.isEmpty
          ? 0.0
          : assignedStudents.map((student) => student.masteryScore).reduce((a, b) => a + b) /
              assignedStudents.length;
      final supportNeeded = assignedStudents
          .where((student) => student.currentEmotion == 'needs_support' || student.masteryScore < 0.65)
          .length;

      return TeacherSummary(
        teacherId: teacher.id,
        teacherName: teacher.displayName,
        schoolId: teacher.schoolId,
        assignedStudents: assignedStudents.length,
        averageMastery: averageMastery,
        supportNeededCount: supportNeeded,
      );
    }).toList(growable: false)
      ..sort((a, b) => a.teacherName.compareTo(b.teacherName));
  }

  AdminDashboardBundle _fallbackDashboard() {
    const users = <AdminUserRecord>[];

    return AdminDashboardBundle(
      users: users,
      roleCounts: _buildRoleCounts(users),
      schoolSummaries: const [],
      teacherSummaries: const [],
    );
  }

  String _schoolLabel(String schoolId) {
    if (schoolId.isEmpty || schoolId == 'unassigned') {
      return 'Unassigned';
    }
    return schoolId
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  Future<void> _ensureRoleConstraints({
    required String role,
    String? excludeUserId,
  }) async {
    if (_firestore == null) {
      return;
    }

    if (role == 'admin') {
      final snapshot = await _firestore.collection('users').where('role', isEqualTo: 'admin').limit(5).get();
      final conflict = snapshot.docs.any((doc) => doc.id != excludeUserId);
      if (conflict) {
        throw Exception('There is already one admin in the system.');
      }
    }

    if (role == 'pedagogiqueManager') {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'pedagogiqueManager')
          .limit(5)
          .get();
      final conflict = snapshot.docs.any((doc) => doc.id != excludeUserId);
      if (conflict) {
        throw Exception('There is already one pedagogique manager in the system.');
      }
    }
  }

  String _defaultEvolutionForRole(String role) {
    if (role == 'student') {
      return 'spark';
    }
    if (role == 'teacher') {
      return 'mentor';
    }
    return 'manager';
  }

  String _displayNameFromEmail(String email) {
    final localPart = email.split('@').first.trim();
    if (localPart.isEmpty) {
      return 'New User';
    }

    return localPart
        .split(RegExp(r'[._\-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  String _friendlyAuthError(String code) {
    switch (code) {
      case 'EMAIL_EXISTS':
        return 'This email is already in use.';
      case 'WEAK_PASSWORD : Password should be at least 6 characters':
      case 'WEAK_PASSWORD':
        return 'Password must be at least 6 characters.';
      case 'INVALID_EMAIL':
        return 'The email address is invalid.';
      default:
        return 'Unable to create the account right now.';
    }
  }
}
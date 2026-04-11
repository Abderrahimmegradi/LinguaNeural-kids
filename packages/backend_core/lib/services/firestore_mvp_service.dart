import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/initial_curriculum_seed.dart';
import '../models/app_user_profile.dart';
import '../models/emotion_record.dart';
import '../models/english_lesson_model.dart' as english;
import '../models/learning_chapter.dart';
import '../models/learning_exercise.dart';
import '../models/learning_lesson.dart';
import '../models/learning_unit.dart';
import '../models/student_progress.dart';

class FirestoreMvpService {
  FirestoreMvpService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get usersCollection =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get chaptersCollection =>
      _firestore.collection('chapters');
  CollectionReference<Map<String, dynamic>> get unitsCollection =>
      _firestore.collection('units');
  CollectionReference<Map<String, dynamic>> get lessonsCollection =>
      _firestore.collection('lessons');
  CollectionReference<Map<String, dynamic>> get exercisesCollection =>
      _firestore.collection('exercises');
  CollectionReference<Map<String, dynamic>> get progressCollection =>
      _firestore.collection('progress');
  CollectionReference<Map<String, dynamic>> get emotionsCollection =>
      _firestore.collection('emotions');
  CollectionReference<Map<String, dynamic>> get legacySchoolsCollection =>
      _firestore.collection('schools');

  Future<void> saveUserProfile(AppUserProfile profile) async {
    await usersCollection.doc(profile.id).set(profile.toMap());
  }

  Future<AppUserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await usersCollection.doc(userId).get();
      if (!doc.exists) {
        return null;
      }
      return AppUserProfile.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }

  Future<List<AppUserProfile>> getUsersByRole(
    UserRole role, {
    String? schoolId,
    String? teacherId,
    bool includeLegacyTeacherlessForSchool = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query;
      if (role == UserRole.student && teacherId != null && teacherId.isNotEmpty) {
        query = usersCollection
            .where('role', isEqualTo: role.name)
            .where('teacherId', isEqualTo: teacherId);
      } else if (schoolId != null && schoolId.isNotEmpty) {
        query = usersCollection.where('schoolId', isEqualTo: schoolId);
      } else {
        query = usersCollection.where('role', isEqualTo: role.name);
      }

      final primarySnapshot = await query.get();
      final docsById = <String, DocumentSnapshot<Map<String, dynamic>>>{};
      for (final doc in primarySnapshot.docs) {
        docsById[doc.id] = doc;
      }

      if (includeLegacyTeacherlessForSchool &&
          role == UserRole.student &&
          teacherId != null &&
          teacherId.isNotEmpty &&
          schoolId != null &&
          schoolId.isNotEmpty) {
        try {
          final schoolSnapshot =
              await usersCollection.where('schoolId', isEqualTo: schoolId).get();
          for (final doc in schoolSnapshot.docs) {
            docsById.putIfAbsent(doc.id, () => doc);
          }
        } catch (_) {
        }
      }

      final users = docsById.values
          .map(AppUserProfile.fromFirestore)
          .where((user) => user.role == role)
          .where(
            (user) =>
                teacherId == null ||
                teacherId.isEmpty ||
                user.teacherId == teacherId ||
                (includeLegacyTeacherlessForSchool &&
                    role == UserRole.student &&
                    schoolId != null &&
                    schoolId.isNotEmpty &&
                    user.schoolId == schoolId &&
                    (user.teacherId == null || user.teacherId!.isEmpty)),
          )
          .where(
            (user) => schoolId == null || schoolId.isEmpty || user.schoolId == schoolId,
          )
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      return users;
    } catch (e) {
      return const <AppUserProfile>[];
    }
  }

  Future<void> deleteUserData(
    AppUserProfile user, {
    bool cascadeAssignedStudents = true,
  }) async {
    if (cascadeAssignedStudents && user.role == UserRole.teacher) {
      final assignedStudents = user.schoolId != null && user.schoolId!.isNotEmpty
          ? (await getUsersByRole(
              UserRole.student,
              schoolId: user.schoolId,
            ))
              .where((student) => student.teacherId == user.id)
              .toList()
          : await getUsersByRole(
              UserRole.student,
              teacherId: user.id,
            );
      for (final student in assignedStudents) {
        await deleteUserData(student, cascadeAssignedStudents: false);
      }
    }

    await _deleteQueryBatch(progressCollection.where('userId', isEqualTo: user.id));
    await _deleteQueryBatch(progressCollection.where('studentId', isEqualTo: user.id));
    await _deleteQueryBatch(emotionsCollection.where('studentId', isEqualTo: user.id));
    await usersCollection.doc(user.id).delete();
  }

  Future<void> saveChapter(LearningChapter chapter) async {
    await chaptersCollection.doc(chapter.id).set(chapter.toMap());
  }

  Future<List<LearningChapter>> getAllChapters() async {
    try {
      final snapshot = await chaptersCollection.get();
      final chapters = snapshot.docs.map(LearningChapter.fromFirestore).toList();
      chapters.sort((a, b) => a.order.compareTo(b.order));
      return chapters;
    } catch (e) {
      return const <LearningChapter>[];
    }
  }

  Future<void> saveUnit(LearningUnit unit) async {
    await unitsCollection.doc(unit.id).set(unit.toMap());
  }

  Future<List<LearningUnit>> getAllUnits() async {
    try {
      final snapshot = await unitsCollection.get();
      final units = snapshot.docs.map(LearningUnit.fromFirestore).toList();
      units.sort((a, b) => a.order.compareTo(b.order));
      return units;
    } catch (e) {
      return const <LearningUnit>[];
    }
  }

  Future<List<LearningUnit>> getUnitsForChapter(String chapterId) async {
    try {
      final snapshot = await unitsCollection.where('chapterId', isEqualTo: chapterId).get();
      final units = snapshot.docs.map(LearningUnit.fromFirestore).toList();
      units.sort((a, b) => a.order.compareTo(b.order));
      return units;
    } catch (e) {
      return const <LearningUnit>[];
    }
  }

  Future<void> createLesson(
    LearningLesson lesson, {
    List<LearningExercise> exercises = const <LearningExercise>[],
  }) async {
    final batch = _firestore.batch();
    batch.set(lessonsCollection.doc(lesson.id), lesson.toMap());
    for (final exercise in exercises) {
      batch.set(exercisesCollection.doc(exercise.id), exercise.toMap());
    }
    await batch.commit();
  }

  Future<void> saveLesson(LearningLesson lesson) async {
    await lessonsCollection.doc(lesson.id).set(lesson.toMap());
  }

  Future<List<LearningLesson>> getAllLessons() async {
    try {
      final snapshot = await lessonsCollection.get();
      final lessons = snapshot.docs.map(LearningLesson.fromFirestore).toList();
      lessons.sort((a, b) {
        final chapterCompare = a.chapterId.compareTo(b.chapterId);
        if (chapterCompare != 0) {
          return chapterCompare;
        }
        final unitCompare = a.unitId.compareTo(b.unitId);
        if (unitCompare != 0) {
          return unitCompare;
        }
        final orderCompare = a.order.compareTo(b.order);
        if (orderCompare != 0) {
          return orderCompare;
        }
        return a.title.compareTo(b.title);
      });
      return lessons;
    } catch (e) {
      return const <LearningLesson>[];
    }
  }

  Future<LearningLesson?> getLesson(String lessonId) async {
    try {
      final doc = await lessonsCollection.doc(lessonId).get();
      if (!doc.exists) {
        return null;
      }
      return LearningLesson.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }

  Future<List<LearningExercise>> getExercisesForLesson(String lessonId) async {
    try {
      final snapshot = await exercisesCollection.where('lessonId', isEqualTo: lessonId).get();
      final exercises = snapshot.docs.map(LearningExercise.fromFirestore).toList();
      exercises.sort((a, b) => a.order.compareTo(b.order));
      return exercises;
    } catch (e) {
      return const <LearningExercise>[];
    }
  }

  Future<void> saveExercise(LearningExercise exercise) async {
    await exercisesCollection.doc(exercise.id).set(exercise.toMap());
  }

  Future<void> deleteLesson(String lessonId) async {
    await _deleteQueryBatch(exercisesCollection.where('lessonId', isEqualTo: lessonId));
    await _deleteQueryBatch(progressCollection.where('lessonId', isEqualTo: lessonId));
    await lessonsCollection.doc(lessonId).delete();
  }

  Future<void> saveStudentProgress(StudentProgress progress) async {
    final docId = progress.id.isNotEmpty ? progress.id : '${progress.userId}_${progress.lessonId}';
    await progressCollection.doc(docId).set(progress.toMap());
  }

  Future<List<StudentProgress>> getProgressForStudent(String studentId) async {
    try {
      final snapshot = await progressCollection.where('userId', isEqualTo: studentId).get();
      final legacySnapshot = await progressCollection.where('studentId', isEqualTo: studentId).get();
      final docsById = <String, DocumentSnapshot<Map<String, dynamic>>>{};
      for (final doc in snapshot.docs) {
        docsById[doc.id] = doc;
      }
      for (final doc in legacySnapshot.docs) {
        docsById.putIfAbsent(doc.id, () => doc);
      }
      final progress = docsById.values.map(StudentProgress.fromFirestore).toList();
      progress.sort((a, b) => b.date.compareTo(a.date));
      return progress;
    } catch (e) {
      return const <StudentProgress>[];
    }
  }

  Future<StudentProgress?> getProgressForLesson(String userId, String lessonId) async {
    try {
      final doc = await progressCollection.doc('${userId}_$lessonId').get();
      if (doc.exists) {
        return StudentProgress.fromFirestore(doc);
      }

      final progress = await getProgressForStudent(userId);
      for (final item in progress) {
        if (item.lessonId == lessonId) {
          return item;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> saveEmotionRecord(EmotionRecord record) async {
    final docId = record.id.isNotEmpty
        ? record.id
        : '${record.studentId}_${DateTime.now().millisecondsSinceEpoch}';
    await emotionsCollection.doc(docId).set(record.toMap());
  }

  Future<List<EmotionRecord>> getEmotionsForStudent(String studentId) async {
    try {
      final snapshot = await emotionsCollection.where('studentId', isEqualTo: studentId).get();
      final records = snapshot.docs.map(EmotionRecord.fromFirestore).toList();
      records.sort((a, b) {
        final left = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final right = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return right.compareTo(left);
      });
      return records;
    } catch (e) {
      return const <EmotionRecord>[];
    }
  }

  Future<void> clearLessons() async {
    await _deleteQueryBatch(exercisesCollection);
    await _deleteQueryBatch(progressCollection);
    await _deleteQueryBatch(lessonsCollection);
    await _deleteQueryBatch(unitsCollection);
    await _deleteQueryBatch(chaptersCollection);
  }

  Future<void> clearExercises() async {
    await _deleteQueryBatch(exercisesCollection);
  }

  Future<void> clearProgress() async {
    await _deleteQueryBatch(progressCollection);
    await _deleteQueryBatch(emotionsCollection);
  }

  Future<void> resetDatabase() async {
    await clearProgress();
    await clearLessons();
  }

  Future<void> resetHierarchyData({
    required String preserveAdminUserId,
  }) async {
    final snapshot = await usersCollection.get();
    final users = snapshot.docs.map(AppUserProfile.fromFirestore).toList();

    final teachers = users.where((user) => user.role == UserRole.teacher).toList();
    final remainingStudents = users.where((user) => user.role == UserRole.student).toList();
    final schools = users.where((user) => user.role == UserRole.school).toList();

    for (final teacher in teachers) {
      await deleteUserData(teacher);
    }

    for (final student in remainingStudents) {
      final isPreservedAdmin = student.id == preserveAdminUserId;
      if (!isPreservedAdmin) {
        final freshDoc = await usersCollection.doc(student.id).get();
        if (freshDoc.exists) {
          await deleteUserData(AppUserProfile.fromFirestore(freshDoc));
        }
      }
    }

    for (final school in schools) {
      if (school.id != preserveAdminUserId) {
        final freshDoc = await usersCollection.doc(school.id).get();
        if (freshDoc.exists) {
          await usersCollection.doc(school.id).delete();
        }
      }
    }

    await clearProgress();
    await _deleteQueryBatch(legacySchoolsCollection);
  }

  Future<void> uploadSeedCurriculum(CurriculumSeedBundle seed) async {
    await clearLessons();

    final batch = _firestore.batch();
    for (final chapter in seed.chapters) {
      batch.set(chaptersCollection.doc(chapter.id), chapter.toMap());
    }
    for (final unit in seed.units) {
      batch.set(unitsCollection.doc(unit.id), unit.toMap());
    }
    for (final lesson in seed.lessons) {
      batch.set(lessonsCollection.doc(lesson.id), lesson.toMap());
    }
    for (final exercise in seed.exercises) {
      batch.set(exercisesCollection.doc(exercise.id), exercise.toMap());
    }
    await batch.commit();
  }

  Future<void> uploadEnglishCurriculum(
    List<english.EnglishLesson> sourceLessons,
  ) async {
    final batch = _firestore.batch();
    final previousLessonByLevel = <String, String>{};
    final chapterOrder = <String, int>{
      'A1': 1,
      'A2': 2,
      'B1': 3,
      'B2': 4,
      'C1': 5,
      'C2': 6,
    };
    final unitOrders = <String, int>{};

    for (final sourceLesson in sourceLessons) {
      final chapterId = 'chapter_${_slugify(sourceLesson.level)}';
      final unitKey = '${sourceLesson.level}_${sourceLesson.category}';
      final unitId = 'unit_${_slugify(unitKey)}';
      unitOrders.putIfAbsent(unitKey, () => unitOrders.length + 1);

      final chapter = LearningChapter(
        id: chapterId,
        title: 'Chapter ${sourceLesson.level}',
        order: chapterOrder[sourceLesson.level] ?? 99,
        description:
            'Progressive ${sourceLesson.level} pathway for Algerian primary learners.',
      );
      final unit = LearningUnit(
        id: unitId,
        chapterId: chapterId,
        title: sourceLesson.category,
        order: unitOrders[unitKey] ?? 1,
        description: sourceLesson.description,
      );

      batch.set(chaptersCollection.doc(chapter.id), chapter.toMap());
      batch.set(unitsCollection.doc(unit.id), unit.toMap());

      final exerciseCount = sourceLesson.units.fold<int>(
        0,
        (totalExercises, unitItem) => totalExercises + unitItem.exercises.length,
      );
      final previousLessonId = previousLessonByLevel[sourceLesson.level];
      final reviewLessonIds =
          previousLessonId == null ? const <String>[] : <String>[previousLessonId];
      final lesson = LearningLesson(
        id: sourceLesson.id,
        chapterId: chapterId,
        unitId: unitId,
        title: sourceLesson.title,
        level: sourceLesson.level,
        duration: exerciseCount,
        order: sourceLesson.order,
        difficulty: sourceLesson.level.startsWith('C') ? 'advanced' : 'normal',
        xpReward: exerciseCount * 10,
        isAdvanced: sourceLesson.level.startsWith('C'),
        reviewLessonIds: reviewLessonIds,
      );

      batch.set(lessonsCollection.doc(lesson.id), lesson.toMap());
      previousLessonByLevel[sourceLesson.level] = lesson.id;

      for (final unitItem in sourceLesson.units) {
        for (var index = 0; index < unitItem.exercises.length; index++) {
          final exercise = unitItem.exercises[index];
          final exerciseId = '${sourceLesson.id}_${unitItem.id}_${exercise.id}';
          final mappedExercise = LearningExercise(
            id: exerciseId,
            lessonId: sourceLesson.id,
            type: exercise.type,
            order: index + 1,
            difficulty: sourceLesson.level.startsWith('C') ? 'advanced' : 'normal',
            question: exercise.question,
            questionArabic: exercise.questionArabic,
            options: exercise.options
                .map(
                  (option) => <String, dynamic>{
                    'id': option.id,
                    'text': option.text,
                    'textArabic': option.textArabic,
                    'isCorrect': option.isCorrect,
                    'audio': option.audio,
                  },
                )
                .toList(),
            correctAnswer: exercise.correctAnswer ?? '',
            explanation: exercise.explanation,
            explanationArabic: exercise.explanationArabic,
            xpReward: exercise.xpReward,
          );
          batch.set(exercisesCollection.doc(mappedExercise.id), mappedExercise.toMap());
        }
      }
    }

    await batch.commit();
  }

  Future<void> _deleteQueryBatch(dynamic queryOrCollection) async {
    while (true) {
      final QuerySnapshot<Map<String, dynamic>> snapshot;
      if (queryOrCollection is Query<Map<String, dynamic>>) {
        snapshot = await queryOrCollection.limit(200).get();
      } else {
        snapshot = await (queryOrCollection as CollectionReference<Map<String, dynamic>>)
            .limit(200)
            .get();
      }

      if (snapshot.docs.isEmpty) {
        return;
      }

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  String _slugify(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'_+'), '_').replaceAll(RegExp(r'^_|_$'), '');
  }
}

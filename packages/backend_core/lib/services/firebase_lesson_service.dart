import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/english_lesson_model.dart';

class FirebaseEnglishLessonService {
  static final FirebaseEnglishLessonService _instance =
      FirebaseEnglishLessonService._internal();

  factory FirebaseEnglishLessonService() {
    return _instance;
  }

  FirebaseEnglishLessonService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get lessonsCollection =>
      _firestore.collection('english_lessons');

  CollectionReference get userProgressCollection =>
      _firestore.collection('user_progress');

  Future<List<EnglishLesson>> getLessonsByLevel(String level) async {
    try {
      final snapshot = await lessonsCollection
          .where('level', isEqualTo: level)
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => EnglishLesson.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<EnglishLesson?> getLessonById(String lessonId) async {
    try {
      final doc = await lessonsCollection.doc(lessonId).get();
      if (doc.exists) {
        return EnglishLesson.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<EnglishLesson>> getAllLessons() async {
    try {
      final snapshot = await lessonsCollection.orderBy('level').orderBy('order').get();
      return snapshot.docs
          .map((doc) => EnglishLesson.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveUserProgress(
    String userId,
    String lessonId,
    UserProgress progress,
  ) async {
    try {
      await userProgressCollection.doc('${userId}_$lessonId').set(progress.toMap());
    } catch (e) {
    }
  }

  Future<UserProgress?> getUserProgress(
    String userId,
    String lessonId,
  ) async {
    try {
      final doc = await userProgressCollection.doc('${userId}_$lessonId').get();
      if (doc.exists) {
        return UserProgress.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<UserProgress>> getUserProgressByLevel(
    String userId,
    String level,
  ) async {
    try {
      final lessons = await getLessonsByLevel(level);
      final progressList = <UserProgress>[];

      for (final lesson in lessons) {
        final progress = await getUserProgress(userId, lesson.id);
        if (progress != null) {
          progressList.add(progress);
        }
      }

      return progressList;
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, UserProgress>> getAllUserProgress(String userId) async {
    try {
      final snapshot = await userProgressCollection
          .where('userId', isEqualTo: userId)
          .get();

      final progressMap = <String, UserProgress>{};
      for (final doc in snapshot.docs) {
        final progress = UserProgress.fromMap(doc.data() as Map<String, dynamic>);
        progressMap[progress.lessonId] = progress;
      }

      return progressMap;
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final allProgress = await getAllUserProgress(userId);
      var totalXP = 0;
      var lessonsCompleted = 0;
      final levelProgress = <String, int>{};

      for (final progress in allProgress.values) {
        totalXP += progress.xpEarned;
        if (progress.isCompleted) {
          lessonsCompleted++;
        }
      }

      return {
        'totalXP': totalXP,
        'lessonsCompleted': lessonsCompleted,
        'levelProgress': levelProgress,
      };
    } catch (e) {
      return {};
    }
  }

  Future<void> addLesson(EnglishLesson lesson) async {
    try {
      await lessonsCollection.doc(lesson.id).set(lesson.toMap());
    } catch (e) {
    }
  }

  Future<void> bulkAddLessons(List<EnglishLesson> lessons) async {
    try {
      final batch = _firestore.batch();

      for (final lesson in lessons) {
        batch.set(lessonsCollection.doc(lesson.id), lesson.toMap());
      }

      await batch.commit();
    } catch (e) {
    }
  }

  Future<void> deleteLesson(String lessonId) async {
    try {
      await lessonsCollection.doc(lessonId).delete();
    } catch (e) {
    }
  }

  Future<void> updateLesson(String lessonId, Map<String, dynamic> data) async {
    try {
      await lessonsCollection.doc(lessonId).update(data);
    } catch (e) {
    }
  }
}

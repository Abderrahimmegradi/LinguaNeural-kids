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

  // Collection references
  CollectionReference get lessonsCollection =>
      _firestore.collection('english_lessons');

  CollectionReference get userProgressCollection =>
      _firestore.collection('user_progress');

  // ==================== LESSON METHODS ====================

  /// Get all lessons by level
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
      print('Error fetching lessons: $e');
      return [];
    }
  }

  /// Get single lesson by ID
  Future<EnglishLesson?> getLessonById(String lessonId) async {
    try {
      final doc = await lessonsCollection.doc(lessonId).get();
      if (doc.exists) {
        return EnglishLesson.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching lesson: $e');
      return null;
    }
  }

  /// Get all lessons (for admin/management)
  Future<List<EnglishLesson>> getAllLessons() async {
    try {
      final snapshot = await lessonsCollection.orderBy('level').orderBy('order').get();
      return snapshot.docs
          .map((doc) => EnglishLesson.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching all lessons: $e');
      return [];
    }
  }

  // ==================== USER PROGRESS METHODS ====================

  /// Save/update user progress for a lesson
  Future<void> saveUserProgress(
    String userId,
    String lessonId,
    UserProgress progress,
  ) async {
    try {
      await userProgressCollection
          .doc('${userId}_$lessonId')
          .set(progress.toMap());
    } catch (e) {
      print('Error saving progress: $e');
    }
  }

  /// Get user progress for a specific lesson
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
      print('Error fetching user progress: $e');
      return null;
    }
  }

  /// Get all user progress for a level
  Future<List<UserProgress>> getUserProgressByLevel(
    String userId,
    String level,
  ) async {
    try {
      final lessons = await getLessonsByLevel(level);
      List<UserProgress> progressList = [];

      for (var lesson in lessons) {
        final progress = await getUserProgress(userId, lesson.id);
        if (progress != null) {
          progressList.add(progress);
        }
      }

      return progressList;
    } catch (e) {
      print('Error fetching user progress by level: $e');
      return [];
    }
  }

  /// Get all user progress
  Future<Map<String, UserProgress>> getAllUserProgress(String userId) async {
    try {
      final snapshot = await userProgressCollection
          .where('userId', isEqualTo: userId)
          .get();

      Map<String, UserProgress> progressMap = {};
      for (var doc in snapshot.docs) {
        final progress = UserProgress.fromMap(doc.data() as Map<String, dynamic>);
        progressMap[progress.lessonId] = progress;
      }

      return progressMap;
    } catch (e) {
      print('Error fetching all user progress: $e');
      return {};
    }
  }

  // ==================== STATISTICS METHODS ====================

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final allProgress = await getAllUserProgress(userId);

      int totalXP = 0;
      int lessonsCompleted = 0;
      Map<String, int> levelProgress = {};

      for (var progress in allProgress.values) {
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
      print('Error fetching user stats: $e');
      return {};
    }
  }

  // ==================== ADMIN METHODS (FOR ADDING LESSONS TO FIREBASE) ====================

  /// Add a new lesson (admin only)
  Future<void> addLesson(EnglishLesson lesson) async {
    try {
      await lessonsCollection.doc(lesson.id).set(lesson.toMap());
    } catch (e) {
      print('Error adding lesson: $e');
    }
  }

  /// Bulk add lessons (admin only)
  Future<void> bulkAddLessons(List<EnglishLesson> lessons) async {
    try {
      WriteBatch batch = _firestore.batch();

      for (var lesson in lessons) {
        batch.set(
          lessonsCollection.doc(lesson.id),
          lesson.toMap(),
        );
      }

      await batch.commit();
      print('Successfully added ${lessons.length} lessons');
    } catch (e) {
      print('Error bulk adding lessons: $e');
    }
  }

  /// Delete a lesson (admin only)
  Future<void> deleteLesson(String lessonId) async {
    try {
      await lessonsCollection.doc(lessonId).delete();
    } catch (e) {
      print('Error deleting lesson: $e');
    }
  }

  /// Update a lesson (admin only)
  Future<void> updateLesson(String lessonId, Map<String, dynamic> data) async {
    try {
      await lessonsCollection.doc(lessonId).update(data);
    } catch (e) {
      print('Error updating lesson: $e');
    }
  }
}

import 'package:flutter/material.dart';
import '../models/english_lesson_model.dart';
import '../services/firebase_lesson_service.dart';

class EnglishLessonProvider extends ChangeNotifier {
  final FirebaseEnglishLessonService _firebaseService =
      FirebaseEnglishLessonService();

  // Current state
  String currentLevel = 'A1';
  EnglishLesson? currentLesson;
  LessonUnit? currentUnit;
  Exercise? currentExercise;
  int currentExerciseIndex = 0;
  int currentUnitIndex = 0;

  // Lessons cache
  Map<String, List<EnglishLesson>> lessonsCache = {};

  // Expose current lessons list for UI convenience
  List<EnglishLesson> get lessons => lessonsCache[currentLevel] ?? [];
  // User progress tracking
  Map<String, UserProgress> userProgressMap = {};
  int totalXP = 0;
  int dailyStreak = 0;
  int lessonsCompleted = 0;

  // Loading state
  bool isLoading = false;

  // Get lessons by current level (with caching)
  Future<List<EnglishLesson>> getLessonsByCurrentLevel() async {
    if (lessonsCache.containsKey(currentLevel)) {
      return lessonsCache[currentLevel]!;
    }

    isLoading = true;
    notifyListeners();

    final lessons = await _firebaseService.getLessonsByLevel(currentLevel);
    lessonsCache[currentLevel] = lessons;

    isLoading = false;
    notifyListeners();

    return lessons;
  }

  // Get lessons by specific level
  Future<List<EnglishLesson>> getLessonsByLevel(String level) async {
    if (lessonsCache.containsKey(level)) {
      return lessonsCache[level]!;
    }

    isLoading = true;
    notifyListeners();

    final lessons = await _firebaseService.getLessonsByLevel(level);
    lessonsCache[level] = lessons;

    isLoading = false;
    notifyListeners();

    return lessons;
  }

  // Set current level
  void setCurrentLevel(String level) {
    currentLevel = level;
    currentLesson = null;
    currentUnit = null;
    currentExercise = null;
    currentExerciseIndex = 0;
    currentUnitIndex = 0;
    notifyListeners();
  }

  // Start a lesson
  void startLesson(EnglishLesson lesson) {
    currentLesson = lesson;
    currentUnitIndex = 0;
    currentUnit = lesson.units.isNotEmpty ? lesson.units[0] : null;
    currentExerciseIndex = 0;
    currentExercise = currentUnit?.exercises.isNotEmpty == true
        ? currentUnit!.exercises[0]
        : null;
    notifyListeners();
  }

  // Move to next exercise
  void nextExercise() {
    if (currentUnit == null) return;

    currentExerciseIndex++;
    if (currentExerciseIndex < currentUnit!.exercises.length) {
      currentExercise = currentUnit!.exercises[currentExerciseIndex];
    } else {
      // Move to next unit
      moveToNextUnit();
    }
    notifyListeners();
  }

  // Move to next unit
  void moveToNextUnit() {
    if (currentLesson == null) return;

    currentUnitIndex++;
    if (currentUnitIndex < currentLesson!.units.length) {
      currentUnit = currentLesson!.units[currentUnitIndex];
      currentExerciseIndex = 0;
      currentExercise = currentUnit!.exercises.isNotEmpty
          ? currentUnit!.exercises[0]
          : null;
    } else {
      // Lesson completed
      completeLesson();
    }
    notifyListeners();
  }

  // Mark lesson as completed
  Future<void> completeLesson() async {
    if (currentLesson == null) return;

    String lessonId = currentLesson!.id;
    int xpEarned = _calculateXP();

    // Create progress object
    final progress = UserProgress(
      userId: 'user1', // TODO: Get from auth
      lessonId: lessonId,
      isCompleted: true,
      xpEarned: xpEarned,
      attemptCount: 1,
      lastAttempted: DateTime.now(),
    );

    // Save to Firebase
    await _firebaseService.saveUserProgress('user1', lessonId, progress);

    // Update local state
    userProgressMap[lessonId] = progress;
    totalXP += xpEarned;
    lessonsCompleted++;

    notifyListeners();
  }

  // Calculate XP earned
  int _calculateXP() {
    int xp = 0;
    if (currentLesson != null) {
      for (var unit in currentLesson!.units) {
        for (var exercise in unit.exercises) {
          xp += exercise.xpReward;
        }
      }
    }
    return xp;
  }

  // Check if lesson is completed
  bool isLessonCompleted(String lessonId) {
    return userProgressMap[lessonId]?.isCompleted ?? false;
  }

  // Get progress percentage
  int getProgressPercentage() {
    if (currentLesson == null) return 0;

    int totalExercises = 0;
    for (var unit in currentLesson!.units) {
      totalExercises += unit.exercises.length;
    }

    int completedExercises =
        (currentUnitIndex) * currentLesson!.units[0].exercises.length +
            currentExerciseIndex;

    if (totalExercises == 0) return 0;
    return ((completedExercises / totalExercises) * 100).toInt();
  }

  // Load user progress from Firebase
  Future<void> loadUserProgress(String userId) async {
    isLoading = true;
    notifyListeners();

    userProgressMap = await _firebaseService.getAllUserProgress(userId);

    // Calculate statistics
    totalXP = 0;
    lessonsCompleted = 0;

    for (var progress in userProgressMap.values) {
      totalXP += progress.xpEarned;
      if (progress.isCompleted) {
        lessonsCompleted++;
      }
    }

    isLoading = false;
    notifyListeners();
  }

  // Bulk upload lessons to Firestore (admin helper)
  Future<void> bulkUploadLessons(List<EnglishLesson> lessons) async {
    isLoading = true;
    notifyListeners();

    await _firebaseService.bulkAddLessons(lessons);

    // Clear cache so next read fetches fresh data
    lessonsCache.clear();

    isLoading = false;
    notifyListeners();
  }

  // Get all levels
  List<String> getAllLevels() {
    return ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    return {
      'totalXP': totalXP,
      'dailyStreak': dailyStreak,
      'lessonsCompleted': lessonsCompleted,
      'currentLevel': currentLevel,
      'isLoading': isLoading,
    };
  }
}

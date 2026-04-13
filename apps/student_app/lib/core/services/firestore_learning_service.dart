import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/character.dart';
import '../models/learning_chapter.dart';
import '../models/learning_exercise.dart';
import '../models/learning_lesson.dart';
import '../mock/mock_lesson_data.dart';
import '../providers/user_provider.dart';

class FirestoreHomeBundle {
  const FirestoreHomeBundle({
    required this.chapters,
    required this.lessons,
    required this.lessonStates,
    required this.unlockedChapterIds,
    required this.completedLessonIds,
    required this.currentLessonId,
    required this.badgesCount,
    required this.activeCharacter,
    required this.profile,
    required this.totalXp,
    required this.dailyStreak,
    required this.currentEmotion,
    required this.evolutionStage,
    required this.masteryScore,
    required this.momentumScore,
  });

  final List<LearningChapter> chapters;
  final List<LearningLesson> lessons;
  final Map<String, LessonStateSnapshot> lessonStates;
  final Set<String> unlockedChapterIds;
  final Set<String> completedLessonIds;
  final String currentLessonId;
  final int badgesCount;
  final Character activeCharacter;
  final AppUserProfile profile;
  final int totalXp;
  final int dailyStreak;
  final String currentEmotion;
  final String evolutionStage;
  final double masteryScore;
  final double momentumScore;
}

class FirestoreLessonBundle {
  const FirestoreLessonBundle({
    required this.lesson,
    required this.chapter,
    required this.exercises,
    this.lessonState,
  });

  final LearningLesson lesson;
  final LearningChapter chapter;
  final List<LearningExercise> exercises;
  final LessonStateSnapshot? lessonState;
}

class LessonCompletionResult {
  const LessonCompletionResult({
    required this.totalXp,
    required this.dailyStreak,
    required this.currentEmotion,
    required this.evolutionStage,
    required this.masteryScore,
  });

  final int totalXp;
  final int dailyStreak;
  final String currentEmotion;
  final String evolutionStage;
  final double masteryScore;
}

class LessonStateSnapshot {
  const LessonStateSnapshot({
    required this.lessonId,
    required this.completed,
    required this.score,
    required this.xpEarned,
    required this.mistakeCount,
    required this.completedExerciseIds,
    required this.totalExerciseCount,
    this.currentExerciseIndex = 0,
    this.completedAt,
  });

  final String lessonId;
  final bool completed;
  final double score;
  final int xpEarned;
  final int mistakeCount;
  final List<String> completedExerciseIds;
  final int totalExerciseCount;
  final int currentExerciseIndex;
  final DateTime? completedAt;

  double get progress {
    if (completed) {
      return 1;
    }
    if (totalExerciseCount <= 0) {
      return 0;
    }
    return (completedExerciseIds.length / totalExerciseCount).clamp(0, 1);
  }
}

class FirestoreLearningService {
  FirestoreLearningService({FirebaseFirestore? firestore})
      : _firestore = firestore ??
            (Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null);

  final FirebaseFirestore? _firestore;

  Future<FirestoreHomeBundle> loadHomeBundle(String userId) async {
    if (_firestore == null) {
      return _loadFallbackHomeBundle(userId);
    }

    try {
      final chaptersSnapshot = await _firestore.collection('chapters').get();
      final lessonsSnapshot = await _firestore.collection('lessons').get();
      final userSnapshot = await _firestore.collection('users').doc(userId).get();
      final progressSnapshot = await _firestore.collection('progress').doc(userId).get();

      final chapters = chaptersSnapshot.docs
          .map((doc) => LearningChapter.fromMap(_withId(doc)))
          .toList(growable: false)
        ..sort((a, b) => a.order.compareTo(b.order));

      final chapterOrders = {
        for (final chapter in chapters) chapter.id: chapter.order,
      };

      final lessons = lessonsSnapshot.docs
          .map((doc) => LearningLesson.fromMap(_withId(doc)))
          .toList(growable: false)
        ..sort((a, b) {
          final chapterCompare =
              (chapterOrders[a.chapterId] ?? 0).compareTo(chapterOrders[b.chapterId] ?? 0);
          if (chapterCompare != 0) {
            return chapterCompare;
          }
          return a.order.compareTo(b.order);
        });

      final userData = userSnapshot.data() ?? <String, dynamic>{};
      final progressData = progressSnapshot.data() ?? <String, dynamic>{};
      final lessonStates = _parseLessonStates(progressData['lessonStates']);
      final masteryScore = _readDouble(progressData['masteryScore']) ??
          _computeMasteryScore(lessonStates.values.toList(growable: false));
      final completedLessons = Set<String>.from(
        (progressData['completedLessonIds'] as List<dynamic>? ?? const <String>[])
            .cast<String>(),
      );
      final totalXp = userData['totalXP'] as int? ?? 0;
      final dailyStreak = userData['dailyStreak'] as int? ?? 1;
      final evolutionStage = userData['evolutionStage'] as String? ??
          _computeEvolutionStage(
            totalXp: totalXp,
            dailyStreak: dailyStreak,
            masteryScore: masteryScore,
            completedLessonsCount: completedLessons.length,
          );
      final momentumScore = _computeMomentumScore(
        totalXp: totalXp,
        dailyStreak: dailyStreak,
        masteryScore: masteryScore,
      );

      final avatarCharacterId = userData['avatarCharacterId'] as String? ?? 'lumi';
      final activeCharacter = Character.byId(avatarCharacterId);

      return FirestoreHomeBundle(
        chapters: chapters,
        lessons: lessons,
        lessonStates: lessonStates,
        unlockedChapterIds: Set<String>.from(
          (progressData['unlockedChapterIds'] as List<dynamic>? ?? ['chapter_1'])
              .cast<String>(),
        ),
        completedLessonIds: completedLessons,
        currentLessonId: progressData['currentLessonId'] as String? ?? lessons.first.id,
        badgesCount: progressData['badgesCount'] as int? ?? _computeBadgesCount(completedLessons.length),
        activeCharacter: activeCharacter,
        profile: AppUserProfile(
          id: userSnapshot.id,
          displayName: _resolveDisplayName(
            userId: userSnapshot.id,
            displayName: userData['displayName'] as String?,
            email: userData['email'] as String?,
          ),
          avatarCharacterId: avatarCharacterId,
          role: userData['role'] as String? ?? 'student',
          email: userData['email'] as String?,
          schoolId: userData['schoolId'] as String?,
          teacherId: userData['teacherId'] as String?,
        ),
        totalXp: totalXp,
        dailyStreak: dailyStreak,
        currentEmotion: userData['currentEmotion'] as String? ?? 'curious',
        evolutionStage: evolutionStage,
        masteryScore: masteryScore,
        momentumScore: momentumScore,
      );
    } on FirebaseException {
      return _loadFallbackHomeBundle(userId);
    }
  }

  Future<FirestoreLessonBundle> loadLessonBundle({
    required String userId,
    String? lessonId,
  }) async {
    if (_firestore == null) {
      return _loadFallbackLessonBundle(lessonId);
    }

    try {
      final progressSnapshot = await _firestore.collection('progress').doc(userId).get();
        final lessonStates = _parseLessonStates(progressSnapshot.data()?['lessonStates']);
      final currentLessonId = lessonId ??
          progressSnapshot.data()?['currentLessonId'] as String? ??
          'chapter_1_lesson_1';

      final lessonSnapshot = await _firestore.collection('lessons').doc(currentLessonId).get();
      final lesson = LearningLesson.fromMap(_withId(lessonSnapshot));
      final chapterSnapshot = await _firestore.collection('chapters').doc(lesson.chapterId).get();
      final chapter = LearningChapter.fromMap(_withId(chapterSnapshot));
      final exercisesSnapshot = await _firestore
          .collection('exercises')
          .where('lessonId', isEqualTo: lesson.id)
          .get();

      final exercises = exercisesSnapshot.docs
          .map((doc) => LearningExercise.fromMap(_withId(doc)))
          .toList(growable: false)
        ..sort((a, b) => _exerciseOrder(a.type).compareTo(_exerciseOrder(b.type)));

      return FirestoreLessonBundle(
        lesson: lesson,
        chapter: chapter,
        exercises: exercises,
        lessonState: lessonStates[currentLessonId],
      );
    } on FirebaseException {
      return _loadFallbackLessonBundle(lessonId);
    }
  }

  Future<void> updateLessonProgress({
    required String userId,
    required LearningLesson lesson,
    required int currentExerciseIndex,
    required List<String> completedExerciseIds,
    required int totalExerciseCount,
    required int mistakeCount,
    required int xpEarned,
  }) async {
    if (_firestore == null) {
      return;
    }

    final progressRef = _firestore.collection('progress').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final progressSnapshot = await transaction.get(progressRef);
      final progressData = progressSnapshot.data() ?? <String, dynamic>{};
      final lessonStates = Map<String, dynamic>.from(
        progressData['lessonStates'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      );
      final existingLessonState = lessonStates[lesson.id];
      if (existingLessonState is Map && existingLessonState['completed'] == true) {
        return;
      }

      final normalizedTotal = totalExerciseCount <= 0 ? 1 : totalExerciseCount;
      final progressScore = (completedExerciseIds.length / normalizedTotal).clamp(0, 1).toDouble();

      lessonStates[lesson.id] = {
        'lessonId': lesson.id,
        'completed': false,
        'score': progressScore,
        'xpEarned': xpEarned,
        'mistakeCount': mistakeCount,
        'completedExerciseIds': completedExerciseIds,
        'totalExerciseCount': totalExerciseCount,
        'currentExerciseIndex': currentExerciseIndex,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      transaction.set(
        progressRef,
        {
          'userId': userId,
          'currentLessonId': lesson.id,
          'lessonStates': lessonStates,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }

  Future<LessonCompletionResult?> completeLesson({
    required String userId,
    required LearningLesson lesson,
    required int earnedXp,
    required double finalScore,
    required int mistakeCount,
    required List<String> completedExerciseIds,
    required int totalExerciseCount,
  }) async {
    if (_firestore == null) {
      return null;
    }

    final progressRef = _firestore.collection('progress').doc(userId);
    final userRef = _firestore.collection('users').doc(userId);
    final emotionRef = _firestore.collection('emotions').doc(userId);
    final emotionEventRef = _firestore.collection('emotion_events').doc();

    LessonCompletionResult? result;

    await _firestore.runTransaction((transaction) async {
      final progressSnapshot = await transaction.get(progressRef);
      final userSnapshot = await transaction.get(userRef);

      final progressData = progressSnapshot.data() ?? <String, dynamic>{};
      final userData = userSnapshot.data() ?? <String, dynamic>{};
      final previousLastCompletedAt = _readDate(progressData['lastLessonCompletedAt']);
      final currentStreak = userData['dailyStreak'] as int? ?? 1;

      final completed = Set<String>.from(
        (progressData['completedLessonIds'] as List<dynamic>? ?? const <String>[])
            .cast<String>(),
      )
        ..add(lesson.id);

      final allLessonsSnapshot = await _firestore.collection('lessons').get();
      final allLessons = allLessonsSnapshot.docs
          .map((doc) => LearningLesson.fromMap(_withId(doc)))
          .toList(growable: false)
        ..sort((a, b) {
          final chapterCompare = a.chapterId.compareTo(b.chapterId);
          if (chapterCompare != 0) {
            return chapterCompare;
          }
          return a.order.compareTo(b.order);
        });

      final currentIndex = allLessons.indexWhere((entry) => entry.id == lesson.id);
      final nextLessonId = currentIndex >= 0 && currentIndex < allLessons.length - 1
          ? allLessons[currentIndex + 1].id
          : lesson.id;

      final chapterOrder = int.tryParse(lesson.chapterId.split('_').last) ?? 1;
      final unlocked = Set<String>.from(
        (progressData['unlockedChapterIds'] as List<dynamic>? ?? ['chapter_1'])
            .cast<String>(),
      );
      if (chapterOrder < 10) {
        unlocked.add('chapter_${chapterOrder + 1}');
      }

      final updatedStreak = _nextStreak(
        lastCompletedAt: previousLastCompletedAt,
        currentStreak: currentStreak,
      );
      final updatedTotalXp = (userData['totalXP'] as int? ?? 0) + earnedXp;
      final lessonStates = Map<String, dynamic>.from(
        progressData['lessonStates'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      );
      lessonStates[lesson.id] = {
        'lessonId': lesson.id,
        'completed': true,
        'score': finalScore,
        'xpEarned': earnedXp,
        'mistakeCount': mistakeCount,
        'completedExerciseIds': completedExerciseIds,
        'totalExerciseCount': totalExerciseCount,
        'currentExerciseIndex': totalExerciseCount > 0 ? totalExerciseCount - 1 : 0,
        'completedAt': FieldValue.serverTimestamp(),
      };

      final parsedStates = _parseLessonStates(lessonStates);
      final masteryScore = _computeMasteryScore(parsedStates.values.toList(growable: false));
      final badgesCount = _computeBadgesCount(completed.length);
      final evolutionStage = _computeEvolutionStage(
        totalXp: updatedTotalXp,
        dailyStreak: updatedStreak,
        masteryScore: masteryScore,
        completedLessonsCount: completed.length,
      );
      final emotion = _computeEmotion(
        finalScore: finalScore,
        dailyStreak: updatedStreak,
        mistakeCount: mistakeCount,
        masteryScore: masteryScore,
      );

      transaction.set(
        progressRef,
        {
          'userId': userId,
          'completedLessonIds': completed.toList()..sort(),
          'currentLessonId': nextLessonId,
          'unlockedChapterIds': unlocked.toList()..sort(),
          'badgesCount': badgesCount,
          'masteryScore': masteryScore,
          'completedLessonsCount': completed.length,
          'lastLessonCompletedAt': FieldValue.serverTimestamp(),
          'lessonStates': lessonStates,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      transaction.set(
        userRef,
        {
          'totalXP': updatedTotalXp,
          'dailyStreak': updatedStreak,
          'currentEmotion': emotion,
          'evolutionStage': evolutionStage,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      transaction.set(
        emotionRef,
        {
          'userId': userId,
          'currentEmotion': emotion,
          'evolutionStage': evolutionStage,
          'masteryScore': masteryScore,
          'source': 'lesson_completion',
          'lessonId': lesson.id,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      transaction.set(
        emotionEventRef,
        {
          'userId': userId,
          'lessonId': lesson.id,
          'emotion': emotion,
          'masteryScore': masteryScore,
          'score': finalScore,
          'mistakeCount': mistakeCount,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );

      result = LessonCompletionResult(
        totalXp: updatedTotalXp,
        dailyStreak: updatedStreak,
        currentEmotion: emotion,
        evolutionStage: evolutionStage,
        masteryScore: masteryScore,
      );
    });

    return result;
  }

  Future<void> updateAvatarCharacter({
    required String userId,
    required String avatarCharacterId,
  }) async {
    if (_firestore == null) {
      return;
    }

    await _firestore.collection('users').doc(userId).set(
      {
        'avatarCharacterId': avatarCharacterId,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  FirestoreHomeBundle _loadFallbackHomeBundle(String userId) {
    const avatarCharacterId = 'lumi';
    final activeCharacter = Character.byId(avatarCharacterId);

    return FirestoreHomeBundle(
      chapters: MockLessonData.chapters,
      lessons: MockLessonData.lessons,
      lessonStates: const {
        'chapter_1_lesson_1': LessonStateSnapshot(
          lessonId: 'chapter_1_lesson_1',
          completed: true,
          score: 0.92,
          xpEarned: 50,
          mistakeCount: 0,
          completedExerciseIds: ['chapter_1_lesson_1_01_multipleChoice'],
          totalExerciseCount: 5,
        ),
      },
      unlockedChapterIds: const {'chapter_1'},
      completedLessonIds: const {'chapter_1_lesson_1'},
      currentLessonId: 'chapter_1_lesson_2',
      badgesCount: 4,
      activeCharacter: activeCharacter,
      profile: AppUserProfile(
        id: userId,
        displayName: _resolveDisplayName(userId: userId),
        avatarCharacterId: avatarCharacterId,
        role: 'student',
      ),
      totalXp: 110,
      dailyStreak: 5,
      currentEmotion: 'curious',
      evolutionStage: 'explorer',
      masteryScore: 0.92,
      momentumScore: 0.68,
    );
  }

  FirestoreLessonBundle _loadFallbackLessonBundle(String? lessonId) {
    final lesson = MockLessonData.lessonById(lessonId);
    return FirestoreLessonBundle(
      lesson: lesson,
      chapter: MockLessonData.chapterById(lesson.chapterId),
      exercises: MockLessonData.exercisesForLesson(lesson.id),
      lessonState: null,
    );
  }

  Map<String, dynamic> _withId(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return {
      'id': doc.id,
      ...data,
    };
  }

  Map<String, LessonStateSnapshot> _parseLessonStates(dynamic rawLessonStates) {
    if (rawLessonStates is! Map) {
      return const <String, LessonStateSnapshot>{};
    }

    final states = <String, LessonStateSnapshot>{};
    for (final entry in rawLessonStates.entries) {
      if (entry.value is! Map) {
        continue;
      }

      final map = Map<String, dynamic>.from(entry.value as Map);
      states[entry.key.toString()] = LessonStateSnapshot(
        lessonId: map['lessonId'] as String? ?? entry.key.toString(),
        completed: map['completed'] as bool? ?? false,
        score: _readDouble(map['score']) ?? 0,
        xpEarned: map['xpEarned'] as int? ?? 0,
        mistakeCount: map['mistakeCount'] as int? ?? 0,
        completedExerciseIds: List<String>.from(
          (map['completedExerciseIds'] as List<dynamic>? ?? const <String>[]).cast<String>(),
        ),
        totalExerciseCount: map['totalExerciseCount'] as int? ?? 0,
        currentExerciseIndex: map['currentExerciseIndex'] as int? ?? 0,
        completedAt: _readDate(map['completedAt']),
      );
    }
    return states;
  }

  double _computeMasteryScore(List<LessonStateSnapshot> lessonStates) {
    if (lessonStates.isEmpty) {
      return 0.42;
    }
    final total = lessonStates.fold<double>(0, (runningTotal, state) => runningTotal + state.score);
    return (total / lessonStates.length).clamp(0, 1);
  }

  double _computeMomentumScore({
    required int totalXp,
    required int dailyStreak,
    required double masteryScore,
  }) {
    final xpFactor = (totalXp / 800).clamp(0, 1);
    final streakFactor = (dailyStreak / 14).clamp(0, 1);
    return ((xpFactor * 0.25) + (streakFactor * 0.35) + (masteryScore * 0.4))
        .clamp(0, 1);
  }

  int _computeBadgesCount(int completedLessonsCount) {
    if (completedLessonsCount <= 0) {
      return 0;
    }
    return 1 + (completedLessonsCount ~/ 2);
  }

  String _computeEvolutionStage({
    required int totalXp,
    required int dailyStreak,
    required double masteryScore,
    required int completedLessonsCount,
  }) {
    if (totalXp >= 700 && dailyStreak >= 10 && masteryScore >= 0.88) {
      return 'star';
    }
    if (totalXp >= 420 && dailyStreak >= 6 && masteryScore >= 0.78) {
      return 'flyer';
    }
    if (totalXp >= 180 && completedLessonsCount >= 3 && masteryScore >= 0.65) {
      return 'explorer';
    }
    return 'spark';
  }

  String _computeEmotion({
    required double finalScore,
    required int dailyStreak,
    required int mistakeCount,
    required double masteryScore,
  }) {
    if (finalScore >= 0.95 && dailyStreak >= 7) {
      return 'unstoppable';
    }
    if (finalScore >= 0.85 && masteryScore >= 0.75) {
      return 'confident';
    }
    if (mistakeCount >= 3) {
      return 'needs_support';
    }
    if (dailyStreak >= 3) {
      return 'focused';
    }
    return 'curious';
  }

  int _nextStreak({
    required DateTime? lastCompletedAt,
    required int currentStreak,
  }) {
    final now = DateTime.now();
    if (lastCompletedAt == null) {
      return currentStreak <= 0 ? 1 : currentStreak;
    }

    final lastDate = DateTime(lastCompletedAt.year, lastCompletedAt.month, lastCompletedAt.day);
    final today = DateTime(now.year, now.month, now.day);
    final difference = today.difference(lastDate).inDays;

    if (difference <= 0) {
      return currentStreak <= 0 ? 1 : currentStreak;
    }
    if (difference == 1) {
      return currentStreak + 1;
    }
    return 1;
  }

  DateTime? _readDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  double? _readDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }

  int _exerciseOrder(String type) {
    const order = {
      'multipleChoice': 0,
      'listening': 1,
      'matching': 2,
      'speaking': 3,
      'writing': 4,
    };
    return order[type] ?? 99;
  }

  String _resolveDisplayName({
    required String userId,
    String? displayName,
    String? email,
  }) {
    final trimmedName = displayName?.trim();
    if (trimmedName != null && trimmedName.isNotEmpty) {
      return trimmedName;
    }

    final trimmedEmail = email?.trim();
    if (trimmedEmail != null && trimmedEmail.contains('@')) {
      final emailName = trimmedEmail.split('@').first.replaceAll(RegExp(r'[._-]+'), ' ').trim();
      if (emailName.isNotEmpty) {
        return emailName
            .split(' ')
            .where((part) => part.isNotEmpty)
            .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
            .join(' ');
      }
    }

    if (userId != 'student_demo' && userId.trim().isNotEmpty) {
      return 'User';
    }

    return 'User';
  }
}
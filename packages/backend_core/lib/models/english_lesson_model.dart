import 'package:cloud_firestore/cloud_firestore.dart';

class EnglishLesson {
  final String id;
  final String title;
  final String titleArabic;
  final String description;
  final String descriptionArabic;
  final String level;
  final List<LessonUnit> units;
  final int order;
  final String category;
  final String categoryArabic;

  EnglishLesson({
    required this.id,
    required this.title,
    required this.titleArabic,
    required this.description,
    required this.descriptionArabic,
    required this.level,
    required this.units,
    required this.order,
    required this.category,
    required this.categoryArabic,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'titleArabic': titleArabic,
      'description': description,
      'descriptionArabic': descriptionArabic,
      'level': level,
      'units': units.map((u) => u.toMap()).toList(),
      'order': order,
      'category': category,
      'categoryArabic': categoryArabic,
    };
  }

  factory EnglishLesson.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return EnglishLesson(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      titleArabic: data['titleArabic'] ?? '',
      description: data['description'] ?? '',
      descriptionArabic: data['descriptionArabic'] ?? '',
      level: data['level'] ?? 'A1',
      units: (data['units'] as List?)
              ?.map((u) => LessonUnit.fromMap(u as Map<String, dynamic>))
              .toList() ??
          [],
      order: data['order'] ?? 0,
      category: data['category'] ?? '',
      categoryArabic: data['categoryArabic'] ?? '',
    );
  }

  factory EnglishLesson.fromMap(Map<String, dynamic> map) {
    return EnglishLesson(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      titleArabic: map['titleArabic'] ?? '',
      description: map['description'] ?? '',
      descriptionArabic: map['descriptionArabic'] ?? '',
      level: map['level'] ?? 'A1',
      units: (map['units'] as List?)
              ?.map((u) => LessonUnit.fromMap(u as Map<String, dynamic>))
              .toList() ??
          [],
      order: map['order'] ?? 0,
      category: map['category'] ?? '',
      categoryArabic: map['categoryArabic'] ?? '',
    );
  }
}

class LessonUnit {
  final String id;
  final String type;
  final List<Exercise> exercises;

  LessonUnit({
    required this.id,
    required this.type,
    required this.exercises,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }

  factory LessonUnit.fromMap(Map<String, dynamic> map) {
    return LessonUnit(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      exercises: (map['exercises'] as List?)
              ?.map((e) => Exercise.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Exercise {
  final String id;
  final String question;
  final String questionArabic;
  final String type;
  final List<ExerciseOption> options;
  final String? correctAnswer;
  final String explanation;
  final String explanationArabic;
  final int xpReward;

  Exercise({
    required this.id,
    required this.question,
    required this.questionArabic,
    required this.type,
    required this.options,
    this.correctAnswer,
    required this.explanation,
    required this.explanationArabic,
    required this.xpReward,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'questionArabic': questionArabic,
      'type': type,
      'options': options.map((o) => o.toMap()).toList(),
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'explanationArabic': explanationArabic,
      'xpReward': xpReward,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      questionArabic: map['questionArabic'] ?? '',
      type: map['type'] ?? '',
      options: (map['options'] as List?)
              ?.map((o) => ExerciseOption.fromMap(o as Map<String, dynamic>))
              .toList() ??
          [],
      correctAnswer: map['correctAnswer'],
      explanation: map['explanation'] ?? '',
      explanationArabic: map['explanationArabic'] ?? '',
      xpReward: map['xpReward'] ?? 10,
    );
  }
}

class ExerciseOption {
  final String id;
  final String text;
  final String textArabic;
  final bool isCorrect;
  final String? audio;

  ExerciseOption({
    required this.id,
    required this.text,
    required this.textArabic,
    required this.isCorrect,
    this.audio,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'textArabic': textArabic,
      'isCorrect': isCorrect,
      'audio': audio,
    };
  }

  factory ExerciseOption.fromMap(Map<String, dynamic> map) {
    return ExerciseOption(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      textArabic: map['textArabic'] ?? '',
      isCorrect: map['isCorrect'] ?? false,
      audio: map['audio'],
    );
  }
}

class UserProgress {
  final String userId;
  final String lessonId;
  bool isCompleted;
  int xpEarned;
  int attemptCount;
  DateTime lastAttempted;
  Map<String, bool> exerciseCompletion;

  UserProgress({
    required this.userId,
    required this.lessonId,
    this.isCompleted = false,
    this.xpEarned = 0,
    this.attemptCount = 0,
    required this.lastAttempted,
    this.exerciseCompletion = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'lessonId': lessonId,
      'isCompleted': isCompleted,
      'xpEarned': xpEarned,
      'attemptCount': attemptCount,
      'lastAttempted': lastAttempted,
      'exerciseCompletion': exerciseCompletion,
    };
  }

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      userId: map['userId'] ?? '',
      lessonId: map['lessonId'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      xpEarned: map['xpEarned'] ?? 0,
      attemptCount: map['attemptCount'] ?? 0,
      lastAttempted:
          (map['lastAttempted'] as Timestamp?)?.toDate() ?? DateTime.now(),
      exerciseCompletion: Map<String, bool>.from(
        map['exerciseCompletion'] ?? {},
      ),
    );
  }
}

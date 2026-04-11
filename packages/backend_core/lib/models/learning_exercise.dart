import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class LearningExercise {
  final String id;
  final String lessonId;
  final String type;
  final int order;
  final String difficulty;
  final bool isAdvanced;
  final String question;
  final String questionArabic;
  final List<Map<String, dynamic>> options;
  final String correctAnswer;
  final String explanation;
  final String explanationArabic;
  final int xpReward;
  final String audioUrl;
  final String audioPrompt;
  final String expectedSpeech;
  final String imageHint;
  final DateTime? createdAt;

  const LearningExercise({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.question,
    this.difficulty = 'normal',
    this.isAdvanced = false,
    this.questionArabic = '',
    this.options = const [],
    this.correctAnswer = '',
    this.explanation = '',
    this.explanationArabic = '',
    this.xpReward = 10,
    this.audioUrl = '',
    this.audioPrompt = '',
    this.expectedSpeech = '',
    this.imageHint = '',
    this.order = 0,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lessonId': lessonId,
      'type': type,
      'order': order,
      'difficulty': difficulty,
      'isAdvanced': isAdvanced,
      'question': question,
      'questionArabic': questionArabic,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'explanationArabic': explanationArabic,
      'xpReward': xpReward,
      'audioUrl': audioUrl,
      'audioPrompt': audioPrompt,
      'expectedSpeech': expectedSpeech,
      'imageHint': imageHint,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory LearningExercise.fromMap(Map<String, dynamic> map) {
    final legacyContent = map['content'] as String?;
    if (legacyContent != null &&
        (map['question'] == null ||
            (map['question'] as String?)?.isEmpty == true)) {
      try {
        final decoded = jsonDecode(legacyContent);
        if (decoded is Map) {
          map = {
            ...map,
            'question': decoded['question'],
            'questionArabic': decoded['questionArabic'],
            'options': decoded['options'],
            'correctAnswer': decoded['correctAnswer'],
            'explanation': decoded['explanation'],
            'explanationArabic': decoded['explanationArabic'],
            'xpReward': decoded['xpReward'],
            'order': decoded['order'] ?? decoded['index'],
            'audioUrl': decoded['audioUrl'],
            'audioPrompt': decoded['audioPrompt'],
            'expectedSpeech': decoded['expectedSpeech'],
            'imageHint': decoded['imageHint'],
          };
        }
      } catch (_) {
        map = {
          ...map,
          'question': legacyContent,
        };
      }
    }

    return LearningExercise(
      id: map['id'] as String? ?? '',
      lessonId: map['lessonId'] as String? ?? '',
      type: map['type'] as String? ?? 'reading',
      order: (map['order'] as num?)?.toInt() ?? 0,
      difficulty: map['difficulty'] as String? ?? 'normal',
      isAdvanced: map['isAdvanced'] as bool? ?? false,
      question: map['question'] as String? ?? '',
      questionArabic: map['questionArabic'] as String? ?? '',
      options: (map['options'] as List?)
              ?.map((item) => Map<String, dynamic>.from(item as Map))
              .toList() ??
          const <Map<String, dynamic>>[],
      correctAnswer: map['correctAnswer'] as String? ?? '',
      explanation: map['explanation'] as String? ?? '',
      explanationArabic: map['explanationArabic'] as String? ?? '',
      xpReward: (map['xpReward'] as num?)?.toInt() ?? 10,
      audioUrl: map['audioUrl'] as String? ?? '',
      audioPrompt: map['audioPrompt'] as String? ?? '',
      expectedSpeech: map['expectedSpeech'] as String? ?? '',
      imageHint: map['imageHint'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  factory LearningExercise.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return LearningExercise.fromMap({
      ...data,
      'id': data['id'] ?? doc.id,
    });
  }

  Map<String, dynamic> get decodedContent {
    return {
      'question': question,
      'questionArabic': questionArabic,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'explanationArabic': explanationArabic,
      'xpReward': xpReward,
      'audioUrl': audioUrl,
      'audioPrompt': audioPrompt,
      'expectedSpeech': expectedSpeech,
      'imageHint': imageHint,
      'type': type,
      'order': order,
      'difficulty': difficulty,
      'isAdvanced': isAdvanced,
    };
  }
}

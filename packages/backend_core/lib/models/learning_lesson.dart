import 'package:cloud_firestore/cloud_firestore.dart';

class LearningLesson {
  final String id;
  final String chapterId;
  final String unitId;
  final String title;
  final String level;
  final int duration;
  final int order;
  final String difficulty;
  final int xpReward;
  final bool isAdvanced;
  final List<String> reviewLessonIds;
  final DateTime? createdAt;

  const LearningLesson({
    required this.id,
    this.chapterId = '',
    this.unitId = '',
    required this.title,
    required this.level,
    required this.duration,
    this.order = 0,
    this.difficulty = 'normal',
    this.xpReward = 10,
    this.isAdvanced = false,
    this.reviewLessonIds = const <String>[],
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chapterId': chapterId,
      'unitId': unitId,
      'title': title,
      'level': level,
      'duration': duration,
      'order': order,
      'difficulty': difficulty,
      'xpReward': xpReward,
      'isAdvanced': isAdvanced,
      'reviewLessonIds': reviewLessonIds,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory LearningLesson.fromMap(Map<String, dynamic> map) {
    return LearningLesson(
      id: map['id'] as String? ?? '',
      chapterId: map['chapterId'] as String? ?? '',
      unitId: map['unitId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      level: map['level'] as String? ?? map['difficulty'] as String? ?? 'A1',
      duration: (map['duration'] as num?)?.toInt() ?? 0,
      order: (map['order'] as num?)?.toInt() ?? 0,
      difficulty: map['difficulty'] as String? ?? 'normal',
      xpReward: (map['xpReward'] as num?)?.toInt() ?? 10,
      isAdvanced: map['isAdvanced'] as bool? ?? false,
      reviewLessonIds: (map['reviewLessonIds'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          const <String>[],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  factory LearningLesson.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return LearningLesson.fromMap({
      ...data,
      'id': data['id'] ?? doc.id,
    });
  }
}

class LearningLesson {
  const LearningLesson({
    required this.id,
    required this.title,
    required this.chapterId,
    required this.unitId,
    required this.order,
    required this.duration,
    required this.xpReward,
    required this.level,
  });

  final String id;
  final String title;
  final String chapterId;
  final String unitId;
  final int order;
  final int duration;
  final int xpReward;
  final int level;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'chapterId': chapterId,
      'unitId': unitId,
      'order': order,
      'duration': duration,
      'xpReward': xpReward,
      'level': level,
    };
  }

  factory LearningLesson.fromMap(Map<String, dynamic> map) {
    return LearningLesson(
      id: map['id'] as String,
      title: map['title'] as String,
      chapterId: map['chapterId'] as String,
      unitId: map['unitId'] as String,
      order: map['order'] as int,
      duration: map['duration'] as int,
      xpReward: map['xpReward'] as int,
      level: map['level'] as int,
    );
  }
}
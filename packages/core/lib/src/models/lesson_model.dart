class LessonModel {
  const LessonModel({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.unitCount,
  });

  final String id;
  final String title;
  final String description;
  final String level;
  final int unitCount;

  factory LessonModel.fromMap(Map<String, dynamic> map) {
    return LessonModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      level: map['level'] as String? ?? 'A1',
      unitCount: (map['unitCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'level': level,
      'unitCount': unitCount,
    };
  }
}
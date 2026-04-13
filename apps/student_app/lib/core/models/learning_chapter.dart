class LearningChapter {
  const LearningChapter({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.colorHex,
  });

  final String id;
  final String title;
  final String description;
  final int order;
  final String colorHex;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'order': order,
      'colorHex': colorHex,
    };
  }

  factory LearningChapter.fromMap(Map<String, dynamic> map) {
    return LearningChapter(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      order: map['order'] as int,
      colorHex: map['colorHex'] as String,
    );
  }
}
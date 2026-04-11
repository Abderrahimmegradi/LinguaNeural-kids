import 'package:cloud_firestore/cloud_firestore.dart';

class LearningChapter {
  const LearningChapter({
    required this.id,
    required this.title,
    required this.order,
    this.description = '',
    this.colorHex = '0E7C86',
    this.createdAt,
  });

  final String id;
  final String title;
  final int order;
  final String description;
  final String colorHex;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'order': order,
      'description': description,
      'colorHex': colorHex,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory LearningChapter.fromMap(Map<String, dynamic> map) {
    return LearningChapter(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      order: (map['order'] as num?)?.toInt() ?? 0,
      description: map['description'] as String? ?? '',
      colorHex: map['colorHex'] as String? ?? '0E7C86',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  factory LearningChapter.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return LearningChapter.fromMap({
      ...data,
      'id': data['id'] ?? doc.id,
    });
  }
}

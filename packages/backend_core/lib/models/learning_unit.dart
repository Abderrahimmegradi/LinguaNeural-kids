import 'package:cloud_firestore/cloud_firestore.dart';

class LearningUnit {
  const LearningUnit({
    required this.id,
    required this.chapterId,
    required this.title,
    required this.order,
    this.description = '',
    this.createdAt,
  });

  final String id;
  final String chapterId;
  final String title;
  final int order;
  final String description;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chapterId': chapterId,
      'title': title,
      'order': order,
      'description': description,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory LearningUnit.fromMap(Map<String, dynamic> map) {
    return LearningUnit(
      id: map['id'] as String? ?? '',
      chapterId: map['chapterId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      order: (map['order'] as num?)?.toInt() ?? 0,
      description: map['description'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  factory LearningUnit.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return LearningUnit.fromMap({
      ...data,
      'id': data['id'] ?? doc.id,
    });
  }
}

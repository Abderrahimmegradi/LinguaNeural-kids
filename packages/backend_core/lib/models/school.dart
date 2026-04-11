import 'package:cloud_firestore/cloud_firestore.dart';

class School {
  final String id;
  final String name;
  final DateTime? createdAt;

  const School({
    required this.id,
    required this.name,
    this.createdAt,
  });

  School copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return School(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory School.fromMap(Map<String, dynamic> map) {
    return School(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  factory School.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return School.fromMap({
      ...data,
      'id': data['id'] ?? doc.id,
    });
  }
}

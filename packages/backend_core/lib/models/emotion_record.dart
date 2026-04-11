import 'package:cloud_firestore/cloud_firestore.dart';

class EmotionRecord {
  final String id;
  final String studentId;
  final String type;
  final double confidence;
  final DateTime? createdAt;

  const EmotionRecord({
    required this.id,
    required this.studentId,
    required this.type,
    required this.confidence,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'type': type,
      'confidence': confidence,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory EmotionRecord.fromMap(
    Map<String, dynamic> map, {
    String? id,
  }) {
    return EmotionRecord(
      id: id ?? map['id'] as String? ?? '',
      studentId: map['studentId'] as String? ?? '',
      type: map['type'] as String? ?? '',
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  factory EmotionRecord.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return EmotionRecord.fromMap(data, id: doc.id);
  }
}

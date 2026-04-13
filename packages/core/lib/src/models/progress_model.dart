class ProgressModel {
  const ProgressModel({
    required this.userId,
    required this.lessonId,
    required this.completedUnits,
    required this.totalUnits,
    this.completedAt,
  });

  final String userId;
  final String lessonId;
  final int completedUnits;
  final int totalUnits;
  final DateTime? completedAt;

  double get completionRate {
    if (totalUnits == 0) {
      return 0;
    }
    return completedUnits / totalUnits;
  }

  factory ProgressModel.fromMap(Map<String, dynamic> map) {
    return ProgressModel(
      userId: map['userId'] as String,
      lessonId: map['lessonId'] as String,
      completedUnits: (map['completedUnits'] as num?)?.toInt() ?? 0,
      totalUnits: (map['totalUnits'] as num?)?.toInt() ?? 0,
      completedAt: map['completedAt'] == null
          ? null
          : DateTime.tryParse(map['completedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'lessonId': lessonId,
      'completedUnits': completedUnits,
      'totalUnits': totalUnits,
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}
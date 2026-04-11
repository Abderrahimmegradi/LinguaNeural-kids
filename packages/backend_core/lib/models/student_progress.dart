import 'package:cloud_firestore/cloud_firestore.dart';

class StudentProgress {
  final String id;
  final String userId;
  final String lessonId;
  final bool completed;
  final double score;
  final int xpEarned;
  final List<String> completedExerciseIds;
  final DateTime date;

  const StudentProgress({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.completed,
    required this.score,
    required this.xpEarned,
    this.completedExerciseIds = const [],
    required this.date,
  });

  String get studentId => userId;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'lessonId': lessonId,
      'completed': completed,
      'score': score,
      'xpEarned': xpEarned,
      'completedExerciseIds': completedExerciseIds,
      'date': Timestamp.fromDate(date),
    };
  }

  factory StudentProgress.fromMap(
    Map<String, dynamic> map, {
    String? id,
  }) {
    return StudentProgress(
      id: id ?? map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? map['studentId'] as String? ?? '',
      lessonId: map['lessonId'] as String? ?? _extractLessonId(map['exerciseId'] as String?),
      completed: map['completed'] as bool? ?? false,
      score: (map['score'] as num?)?.toDouble() ?? 0,
      xpEarned: (map['xpEarned'] as num?)?.toInt() ?? 0,
      completedExerciseIds: (map['completedExerciseIds'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          _legacyCompletedExerciseIds(map['exerciseId'] as String?),
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory StudentProgress.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return StudentProgress.fromMap(data, id: doc.id);
  }

  static String _extractLessonId(String? exerciseId) {
    if (exerciseId == null || exerciseId.isEmpty) {
      return '';
    }

    final parts = exerciseId.split('_');
    if (parts.length >= 2) {
      return '${parts[0]}_${parts[1]}';
    }
    return exerciseId;
  }

  static List<String> _legacyCompletedExerciseIds(String? exerciseId) {
    if (exerciseId == null || exerciseId.isEmpty) {
      return const <String>[];
    }
    return <String>[exerciseId];
  }
}

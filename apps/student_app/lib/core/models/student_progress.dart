class StudentProgress {
  const StudentProgress({
    required this.lessonId,
    required this.completed,
    required this.score,
    required this.xpEarned,
    required this.completedExerciseIds,
    required this.date,
  });

  final String lessonId;
  final bool completed;
  final double score;
  final int xpEarned;
  final List<String> completedExerciseIds;
  final DateTime date;

  Map<String, dynamic> toMap() {
    return {
      'lessonId': lessonId,
      'completed': completed,
      'score': score,
      'xpEarned': xpEarned,
      'completedExerciseIds': completedExerciseIds,
      'date': date.toIso8601String(),
    };
  }

  factory StudentProgress.fromMap(Map<String, dynamic> map) {
    return StudentProgress(
      lessonId: map['lessonId'] as String,
      completed: map['completed'] as bool,
      score: (map['score'] as num).toDouble(),
      xpEarned: map['xpEarned'] as int,
      completedExerciseIds: List<String>.from(
        map['completedExerciseIds'] as List<dynamic>,
      ),
      date: DateTime.parse(map['date'] as String),
    );
  }
}
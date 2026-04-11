import '../models/student_progress.dart';
import 'firestore_mvp_service.dart';

class ProgressService {
  ProgressService({
    FirestoreMvpService? firestoreService,
  }) : _firestoreService = firestoreService ?? FirestoreMvpService();

  final FirestoreMvpService _firestoreService;

  Future<void> saveProgress({
    required String userId,
    required String lessonId,
    required bool completed,
    required double score,
    required int xpEarned,
    List<String> completedExerciseIds = const <String>[],
  }) {
    return _firestoreService.saveStudentProgress(
      StudentProgress(
        id: '${userId}_$lessonId',
        userId: userId,
        lessonId: lessonId,
        completed: completed,
        score: score,
        xpEarned: xpEarned,
        completedExerciseIds: completedExerciseIds,
        date: DateTime.now(),
      ),
    );
  }

  Future<List<StudentProgress>> getProgressForStudent(String studentId) {
    return _firestoreService.getProgressForStudent(studentId);
  }

  Future<StudentProgress?> getProgressForLesson(
    String userId,
    String lessonId,
  ) {
    return _firestoreService.getProgressForLesson(userId, lessonId);
  }
}

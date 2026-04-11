import '../models/learning_exercise.dart';
import 'firestore_mvp_service.dart';

class ExerciseService {
  ExerciseService({
    FirestoreMvpService? firestoreService,
  }) : _firestoreService = firestoreService ?? FirestoreMvpService();

  final FirestoreMvpService _firestoreService;

  Future<List<LearningExercise>> getExercisesByLesson(String lessonId) {
    return _firestoreService.getExercisesForLesson(lessonId);
  }
}

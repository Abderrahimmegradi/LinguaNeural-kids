import '../models/learning_chapter.dart';
import '../models/learning_lesson.dart';
import '../models/learning_unit.dart';
import 'firestore_mvp_service.dart';

class LessonService {
  LessonService({
    FirestoreMvpService? firestoreService,
  }) : _firestoreService = firestoreService ?? FirestoreMvpService();

  final FirestoreMvpService _firestoreService;

  Future<List<LearningLesson>> getLessons() {
    return _firestoreService.getAllLessons();
  }

  Future<List<LearningChapter>> getChapters() {
    return _firestoreService.getAllChapters();
  }

  Future<List<LearningUnit>> getUnits() {
    return _firestoreService.getAllUnits();
  }
}

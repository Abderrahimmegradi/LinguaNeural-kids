import '../models/student_progress.dart';

class ProgressService {
  final Map<String, StudentProgress> _progressByLesson = {};

  StudentProgress? getProgress(String lessonId) {
    return _progressByLesson[lessonId];
  }

  List<StudentProgress> getAllProgress() {
    return _progressByLesson.values.toList(growable: false);
  }

  void saveProgress(StudentProgress progress) {
    _progressByLesson[progress.lessonId] = progress;
  }
}
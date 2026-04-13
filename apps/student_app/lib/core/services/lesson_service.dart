import '../models/learning_lesson.dart';

class LessonService {
  const LessonService();

  List<LearningLesson> getLessons() {
    return const [
      LearningLesson(
        id: 'lesson_1',
        title: 'Greetings',
        chapterId: 'chapter_1',
        unitId: 'unit_1',
        order: 1,
        duration: 8,
        xpReward: 20,
        level: 1,
      ),
      LearningLesson(
        id: 'lesson_2',
        title: 'Family Words',
        chapterId: 'chapter_1',
        unitId: 'unit_1',
        order: 2,
        duration: 10,
        xpReward: 25,
        level: 1,
      ),
    ];
  }
}
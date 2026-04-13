import '../models/learning_exercise.dart';

class ExerciseService {
  const ExerciseService();

  List<LearningExercise> getExercisesForLesson(String lessonId) {
    return [
      LearningExercise(
        id: 'exercise_${lessonId}_1',
        lessonId: lessonId,
        type: 'multipleChoice',
        question: 'How do you say Hello?',
        questionArabic: 'كيف تقول مرحبا؟',
        expectedSpeech: 'Hello',
        correctAnswer: 'Hello',
        explanation: 'Hello is a common English greeting.',
        xpReward: 10,
        options: const [
          {'label': 'Hello', 'value': 'Hello'},
          {'label': 'Bye', 'value': 'Bye'},
          {'label': 'Thanks', 'value': 'Thanks'},
        ],
        audioUrl: null,
        imageHint: 'wave',
      ),
    ];
  }
}
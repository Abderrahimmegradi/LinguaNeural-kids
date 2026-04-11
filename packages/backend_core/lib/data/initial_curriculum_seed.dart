import '../models/learning_chapter.dart';
import '../models/learning_exercise.dart';
import '../models/learning_lesson.dart';
import '../models/learning_unit.dart';

class CurriculumSeedBundle {
  const CurriculumSeedBundle({
    required this.chapters,
    required this.units,
    required this.lessons,
    required this.exercises,
  });

  final List<LearningChapter> chapters;
  final List<LearningUnit> units;
  final List<LearningLesson> lessons;
  final List<LearningExercise> exercises;
}

final CurriculumSeedBundle initialCurriculumSeed =
    _buildInitialCurriculumSeed();

CurriculumSeedBundle _buildInitialCurriculumSeed() {
  final chapters = <LearningChapter>[];
  final units = <LearningUnit>[];
  final lessons = <LearningLesson>[];
  final exercises = <LearningExercise>[];

  for (final chapterData in _curriculumBlueprint) {
    final chapter = LearningChapter(
      id: chapterData.id,
      title: chapterData.title,
      order: chapterData.order,
      description: chapterData.description,
    );
    chapters.add(chapter);

    String? previousLessonId;
    for (final unitData in chapterData.units) {
      final unit = LearningUnit(
        id: unitData.id,
        chapterId: chapter.id,
        title: unitData.title,
        order: unitData.order,
        description: unitData.description,
      );
      units.add(unit);

      for (final lessonData in unitData.lessons) {
        final lessonId = lessonData.id;
        final lessonExercises = _buildLessonExercises(
          lessonId: lessonId,
          words: lessonData.words,
          speakingSentence: lessonData.speakingSentence,
        );
        final lesson = LearningLesson(
          id: lessonId,
          chapterId: chapter.id,
          unitId: unit.id,
          title: lessonData.title,
          level: 'A1',
          duration: lessonExercises.length,
          order: lessonData.order,
          difficulty: 'easy',
          xpReward: lessonExercises.fold<int>(
            0,
            (sum, exercise) => sum + exercise.xpReward,
          ),
          isAdvanced: false,
          reviewLessonIds: previousLessonId == null
              ? const <String>[]
              : <String>[previousLessonId],
        );

        lessons.add(lesson);
        exercises.addAll(lessonExercises);
        previousLessonId = lessonId;
      }
    }
  }

  return CurriculumSeedBundle(
    chapters: chapters,
    units: units,
    lessons: lessons,
    exercises: exercises,
  );
}

List<LearningExercise> _buildLessonExercises({
  required String lessonId,
  required List<_SeedWord> words,
  required String speakingSentence,
}) {
  final listeningWord = words.first;
  final quizWord = words.length > 1 ? words[1] : words.first;
  final matchingWord = words.length > 2 ? words[2] : words.first;
  final options = _buildOptions(words);

  return <LearningExercise>[
    LearningExercise(
      id: '${lessonId}_listen',
      lessonId: lessonId,
      type: 'listening',
      order: 1,
      difficulty: 'easy',
      question: 'Listen carefully and tap the word you hear.',
      options: _markCorrectOption(options, listeningWord.label),
      correctAnswer: listeningWord.label,
      explanation:
          'Great listening. The sound matched "${listeningWord.label}".',
      xpReward: 10,
      audioPrompt: listeningWord.label,
      imageHint: listeningWord.imageKey,
    ),
    LearningExercise(
      id: '${lessonId}_choice',
      lessonId: lessonId,
      type: 'multipleChoice',
      order: 2,
      difficulty: 'easy',
      question: 'Which word matches: ${quizWord.clue}?',
      options: _markCorrectOption(options, quizWord.label),
      correctAnswer: quizWord.label,
      explanation: '"${quizWord.label}" is the best match for ${quizWord.clue}.',
      xpReward: 10,
      imageHint: quizWord.imageKey,
    ),
    LearningExercise(
      id: '${lessonId}_match',
      lessonId: lessonId,
      type: 'matching',
      order: 3,
      difficulty: 'easy',
      question: 'Match "${matchingWord.label}" with the right picture.',
      options: _markCorrectOption(options, matchingWord.label),
      correctAnswer: matchingWord.label,
      explanation:
          'Nice match. "${matchingWord.label}" uses that picture clue.',
      xpReward: 10,
      imageHint: matchingWord.imageKey,
    ),
    LearningExercise(
      id: '${lessonId}_speak',
      lessonId: lessonId,
      type: 'speaking',
      order: 4,
      difficulty: 'easy',
      question: 'Tap to speak and say: $speakingSentence',
      correctAnswer: speakingSentence,
      explanation: 'Speaking practice helps your English sound stronger.',
      xpReward: 10,
      expectedSpeech: speakingSentence,
      audioPrompt: speakingSentence,
    ),
  ];
}

List<Map<String, dynamic>> _buildOptions(List<_SeedWord> words) {
  final options = words
      .map(
        (word) => <String, dynamic>{
          'text': word.label,
          'textArabic': word.clue,
          'imageKey': word.imageKey,
        },
      )
      .toList();

  final labels = words.map((word) => word.label).toSet();
  final distractor = _distractorPool.firstWhere(
    (candidate) => !labels.contains(candidate.label),
  );
  options.add(
    <String, dynamic>{
      'text': distractor.label,
      'textArabic': distractor.clue,
      'imageKey': distractor.imageKey,
    },
  );
  return options;
}

List<Map<String, dynamic>> _markCorrectOption(
  List<Map<String, dynamic>> options,
  String correctLabel,
) {
  return options
      .map(
        (option) => <String, dynamic>{
          ...option,
          'isCorrect': option['text'] == correctLabel,
        },
      )
      .toList();
}

class _SeedChapter {
  const _SeedChapter({
    required this.id,
    required this.order,
    required this.title,
    required this.description,
    required this.units,
  });

  final String id;
  final int order;
  final String title;
  final String description;
  final List<_SeedUnit> units;
}

class _SeedUnit {
  const _SeedUnit({
    required this.id,
    required this.order,
    required this.title,
    required this.description,
    required this.lessons,
  });

  final String id;
  final int order;
  final String title;
  final String description;
  final List<_SeedLesson> lessons;
}

class _SeedLesson {
  const _SeedLesson({
    required this.id,
    required this.order,
    required this.title,
    required this.speakingSentence,
    required this.words,
  });

  final String id;
  final int order;
  final String title;
  final String speakingSentence;
  final List<_SeedWord> words;
}

class _SeedWord {
  const _SeedWord({
    required this.label,
    required this.clue,
    required this.imageKey,
  });

  final String label;
  final String clue;
  final String imageKey;
}

const List<_SeedWord> _distractorPool = <_SeedWord>[
  _SeedWord(label: 'book', clue: 'كتاب', imageKey: 'book'),
  _SeedWord(label: 'apple', clue: 'تفاحة', imageKey: 'apple'),
  _SeedWord(label: 'school', clue: 'مدرسة', imageKey: 'school'),
  _SeedWord(label: 'sun', clue: 'شمس', imageKey: 'sun'),
];

const List<_SeedChapter> _curriculumBlueprint = <_SeedChapter>[
  _SeedChapter(
    id: 'chapter_starters',
    order: 1,
    title: 'First Words',
    description: 'Build confidence with familiar greetings and classroom words.',
    units: <_SeedUnit>[
      _SeedUnit(
        id: 'unit_greetings',
        order: 1,
        title: 'Greetings',
        description: 'Introduce greetings and simple polite phrases.',
        lessons: <_SeedLesson>[
          _SeedLesson(
            id: 'lesson_hello',
            order: 1,
            title: 'Hello and Goodbye',
            speakingSentence: 'Hello, goodbye',
            words: <_SeedWord>[
              _SeedWord(label: 'hello', clue: 'مرحبا', imageKey: 'hello'),
              _SeedWord(label: 'goodbye', clue: 'مع السلامة', imageKey: 'goodbye'),
              _SeedWord(label: 'thank you', clue: 'شكرا', imageKey: 'thank_you'),
            ],
          ),
        ],
      ),
    ],
  ),
];

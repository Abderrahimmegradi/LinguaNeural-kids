import '../models/learning_chapter.dart';
import '../models/learning_exercise.dart';
import '../models/learning_lesson.dart';

class MockLessonData {
  const MockLessonData._();

  static const List<LearningChapter> chapters = [
    LearningChapter(
      id: 'chapter_1',
      title: 'Hello World',
      description: 'Basic greetings',
      order: 1,
      colorHex: '#0E7C86',
    ),
    LearningChapter(
      id: 'chapter_2',
      title: 'My Family',
      description: 'Family members',
      order: 2,
      colorHex: '#1A936F',
    ),
    LearningChapter(
      id: 'chapter_3',
      title: 'Colors & Shapes',
      description: 'Colors and shapes',
      order: 3,
      colorHex: '#F4B942',
    ),
    LearningChapter(
      id: 'chapter_4',
      title: 'Numbers & Counting',
      description: 'Numbers 1-20',
      order: 4,
      colorHex: '#E76F51',
    ),
    LearningChapter(
      id: 'chapter_5',
      title: 'Food & Drinks',
      description: 'Common foods',
      order: 5,
      colorHex: '#8B5CF6',
    ),
    LearningChapter(
      id: 'chapter_6',
      title: 'My Body',
      description: 'Body parts',
      order: 6,
      colorHex: '#0E7C86',
    ),
    LearningChapter(
      id: 'chapter_7',
      title: 'Daily Routine',
      description: 'Morning/evening actions',
      order: 7,
      colorHex: '#1A936F',
    ),
    LearningChapter(
      id: 'chapter_8',
      title: 'Weather & Seasons',
      description: 'Weather vocabulary',
      order: 8,
      colorHex: '#F4B942',
    ),
    LearningChapter(
      id: 'chapter_9',
      title: 'Animals',
      description: 'Pet and zoo animals',
      order: 9,
      colorHex: '#E76F51',
    ),
    LearningChapter(
      id: 'chapter_10',
      title: 'Places & Directions',
      description: 'School, park, home',
      order: 10,
      colorHex: '#8B5CF6',
    ),
  ];

  static final List<LearningLesson> lessons = _buildLessons();
  static final List<LearningExercise> exercises = _buildExercises();

  static List<LearningLesson> lessonsForChapter(String chapterId) {
    return lessons
        .where((lesson) => lesson.chapterId == chapterId)
        .toList(growable: false)
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  static List<LearningExercise> exercisesForLesson(String lessonId) {
    return exercises
        .where((exercise) => exercise.lessonId == lessonId)
        .toList(growable: false);
  }

  static LearningLesson lessonById(String? lessonId) {
    return lessons.firstWhere(
      (lesson) => lesson.id == lessonId,
      orElse: () => lessons.first,
    );
  }

  static LearningChapter chapterById(String chapterId) {
    return chapters.firstWhere((chapter) => chapter.id == chapterId);
  }

  static List<LearningLesson> _buildLessons() {
    const lessonTemplates = [
      ('Introduction + Vocabulary', 5, 50),
      ('Practice + Listening', 7, 60),
      ('Speaking + Writing', 8, 70),
      ('Review Game', 6, 55),
      ('Quiz', 5, 80),
    ];

    final builtLessons = <LearningLesson>[];
    for (final chapter in chapters) {
      for (var index = 0; index < lessonTemplates.length; index++) {
        final template = lessonTemplates[index];
        builtLessons.add(
          LearningLesson(
            id: '${chapter.id}_lesson_${index + 1}',
            title: template.$1,
            chapterId: chapter.id,
            unitId: 'unit_${chapter.order}',
            order: index + 1,
            duration: template.$2,
            xpReward: template.$3,
            level: chapter.order,
          ),
        );
      }
    }
    return builtLessons;
  }

  static List<LearningExercise> _buildExercises() {
    final builtExercises = <LearningExercise>[];
    for (final lesson in lessons) {
      final chapter = chapterById(lesson.chapterId);
      final topic = chapter.title;
      builtExercises.addAll([
        LearningExercise(
          id: '${lesson.id}_mc',
          lessonId: lesson.id,
          type: 'multipleChoice',
          question: 'Choose the English word linked to $topic.',
          questionArabic: 'اختر الكلمة الإنجليزية المرتبطة بموضوع $topic.',
          expectedSpeech: _keywordForTopic(topic),
          correctAnswer: _keywordForTopic(topic),
          explanation: 'This introduces the main vocabulary for the chapter.',
          xpReward: 10,
          options: [
            {'label': _keywordForTopic(topic), 'value': _keywordForTopic(topic), 'emoji': _emojiForTopic(topic)},
            {'label': 'Maybe', 'value': 'maybe', 'emoji': '❓'},
            {'label': 'Later', 'value': 'later', 'emoji': '⏳'},
            {'label': 'Nothing', 'value': 'nothing', 'emoji': '⭕'},
          ],
          audioUrl: null,
          imageHint: _emojiForTopic(topic),
        ),
        LearningExercise(
          id: '${lesson.id}_listen',
          lessonId: lesson.id,
          type: 'listening',
          question: 'Listen and tap the phrase you hear for $topic.',
          questionArabic: 'استمع ثم اختر العبارة التي تسمعها في موضوع $topic.',
          expectedSpeech: 'Listen: ${_listeningPhraseForTopic(topic)}',
          correctAnswer: _listeningPhraseForTopic(topic),
          explanation: 'Listening builds recognition before speaking.',
          xpReward: 12,
          options: [
            {'label': _listeningPhraseForTopic(topic), 'value': _listeningPhraseForTopic(topic), 'emoji': '🔊'},
            {'label': 'See you soon', 'value': 'See you soon', 'emoji': '👋'},
            {'label': 'I am sleepy', 'value': 'I am sleepy', 'emoji': '😴'},
            {'label': 'Blue sky', 'value': 'Blue sky', 'emoji': '🌤️'},
          ],
          audioUrl: 'mock://$topic/audio',
          imageHint: 'speaker',
        ),
        LearningExercise(
          id: '${lesson.id}_true_false',
          lessonId: lesson.id,
          type: 'trueFalse',
          question: 'Is this statement true for $topic?',
          questionArabic: 'هل هذه الجملة صحيحة في موضوع $topic؟',
          expectedSpeech: _trueFalsePromptForTopic(topic).$1,
          correctAnswer: _trueFalsePromptForTopic(topic).$2,
          explanation: 'True or false checks fast understanding before the next challenge.',
          xpReward: 11,
          options: const [
            {'label': 'True', 'value': 'true', 'emoji': '✅'},
            {'label': 'False', 'value': 'false', 'emoji': '❌'},
          ],
          audioUrl: null,
          imageHint: 'toggle',
        ),
        LearningExercise(
          id: '${lesson.id}_match',
          lessonId: lesson.id,
          type: 'matching',
          question: 'Match the word to the correct picture card.',
          questionArabic: 'طابق الكلمة مع البطاقة الصحيحة.',
          expectedSpeech: _keywordForTopic(topic),
          correctAnswer: _keywordForTopic(topic),
          explanation: 'Matching helps connect images with vocabulary quickly.',
          xpReward: 14,
          options: [
            {'label': _keywordForTopic(topic), 'value': _keywordForTopic(topic), 'emoji': _emojiForTopic(topic)},
            {'label': 'cat', 'value': 'cat', 'emoji': '🐱'},
            {'label': 'apple', 'value': 'apple', 'emoji': '🍎'},
            {'label': 'sun', 'value': 'sun', 'emoji': '☀️'},
          ],
          audioUrl: null,
          imageHint: 'grid',
        ),
        LearningExercise(
          id: '${lesson.id}_reorder',
          lessonId: lesson.id,
          type: 'reorder',
          question: 'Build the sentence in the right order.',
          questionArabic: 'رتب الكلمات لتكوين الجملة الصحيحة.',
          expectedSpeech: _reorderPromptForTopic(topic),
          correctAnswer: _reorderPromptForTopic(topic),
          explanation: 'Reordering grows sentence sense and calm attention to detail.',
          xpReward: 15,
          options: _reorderBankForTopic(topic),
          audioUrl: null,
          imageHint: 'puzzle',
        ),
        LearningExercise(
          id: '${lesson.id}_speak',
          lessonId: lesson.id,
          type: 'speaking',
          question: 'Say the key phrase for $topic out loud.',
          questionArabic: 'قل العبارة الأساسية الخاصة بموضوع $topic بصوت عالٍ.',
          expectedSpeech: _speakingPromptForTopic(topic),
          correctAnswer: _speakingPromptForTopic(topic),
          explanation: 'Speaking practice builds confidence with the chapter phrase.',
          xpReward: 16,
          options: const [],
          audioUrl: null,
          imageHint: 'microphone',
        ),
        LearningExercise(
          id: '${lesson.id}_write',
          lessonId: lesson.id,
          type: 'writing',
          question: 'Write the phrase that fits this chapter best.',
          questionArabic: 'اكتب العبارة الأنسب لهذا الفصل.',
          expectedSpeech: _writingPromptForTopic(topic),
          correctAnswer: _writingPromptForTopic(topic),
          explanation: 'Writing reinforces spelling and sentence order.',
          xpReward: 18,
          options: _wordBankForTopic(topic),
          audioUrl: null,
          imageHint: 'pencil',
        ),
      ]);
    }
    return builtExercises;
  }

  static String _keywordForTopic(String topic) {
    switch (topic) {
      case 'Hello World':
        return 'hello';
      case 'My Family':
        return 'mother';
      case 'Colors & Shapes':
        return 'circle';
      case 'Numbers & Counting':
        return 'ten';
      case 'Food & Drinks':
        return 'juice';
      case 'My Body':
        return 'hand';
      case 'Daily Routine':
        return 'wake up';
      case 'Weather & Seasons':
        return 'rainy';
      case 'Animals':
        return 'lion';
      case 'Places & Directions':
        return 'school';
      default:
        return 'word';
    }
  }

  static String _listeningPhraseForTopic(String topic) {
    switch (topic) {
      case 'Hello World':
        return 'Hello, my friend';
      case 'My Family':
        return 'This is my family';
      case 'Colors & Shapes':
        return 'The circle is blue';
      case 'Numbers & Counting':
        return 'I can count to ten';
      case 'Food & Drinks':
        return 'I like apple juice';
      case 'My Body':
        return 'Raise your hand';
      case 'Daily Routine':
        return 'I wake up early';
      case 'Weather & Seasons':
        return 'Today is rainy';
      case 'Animals':
        return 'The lion is strong';
      case 'Places & Directions':
        return 'Go to school';
      default:
        return 'Listen carefully';
    }
  }

  static (String, String) _trueFalsePromptForTopic(String topic) {
    switch (topic) {
      case 'Hello World':
        return ('Hello is a greeting.', 'true');
      case 'My Family':
        return ('A family has no people.', 'false');
      case 'Colors & Shapes':
        return ('A circle is a shape.', 'true');
      case 'Numbers & Counting':
        return ('Ten comes after three hundred.', 'false');
      case 'Food & Drinks':
        return ('Juice is something you can drink.', 'true');
      case 'My Body':
        return ('Hands are body parts.', 'true');
      case 'Daily Routine':
        return ('Brushing teeth is never part of a routine.', 'false');
      case 'Weather & Seasons':
        return ('Rainy describes weather.', 'true');
      case 'Animals':
        return ('A lion is a type of weather.', 'false');
      case 'Places & Directions':
        return ('School can be a place.', 'true');
      default:
        return ('Learning English is fun.', 'true');
    }
  }

  static String _speakingPromptForTopic(String topic) {
    switch (topic) {
      case 'Hello World':
        return 'Hello, I am ready';
      case 'My Family':
        return 'This is my family';
      case 'Colors & Shapes':
        return 'The circle is red';
      case 'Numbers & Counting':
        return 'I can count to twenty';
      case 'Food & Drinks':
        return 'I like bread and milk';
      case 'My Body':
        return 'These are my eyes';
      case 'Daily Routine':
        return 'I brush my teeth';
      case 'Weather & Seasons':
        return 'It is sunny today';
      case 'Animals':
        return 'The tiger is fast';
      case 'Places & Directions':
        return 'The park is near home';
      default:
        return 'I am learning English';
    }
  }

  static String _writingPromptForTopic(String topic) {
    switch (topic) {
      case 'Hello World':
        return 'hello friend';
      case 'My Family':
        return 'my family loves me';
      case 'Colors & Shapes':
        return 'a square is green';
      case 'Numbers & Counting':
        return 'i count to ten';
      case 'Food & Drinks':
        return 'i drink orange juice';
      case 'My Body':
        return 'my hands are clean';
      case 'Daily Routine':
        return 'i wake up early';
      case 'Weather & Seasons':
        return 'winter is cold';
      case 'Animals':
        return 'the rabbit can jump';
      case 'Places & Directions':
        return 'go to the park';
      default:
        return 'write the answer';
    }
  }

  static String _reorderPromptForTopic(String topic) {
    switch (topic) {
      case 'Hello World':
        return 'hello my friend';
      case 'My Family':
        return 'this is my family';
      case 'Colors & Shapes':
        return 'the square is green';
      case 'Numbers & Counting':
        return 'i can count to ten';
      case 'Food & Drinks':
        return 'i like orange juice';
      case 'My Body':
        return 'raise your hand now';
      case 'Daily Routine':
        return 'i brush my teeth';
      case 'Weather & Seasons':
        return 'today is very sunny';
      case 'Animals':
        return 'the rabbit can jump';
      case 'Places & Directions':
        return 'go to the school';
      default:
        return 'put the words together';
    }
  }

  static List<Map<String, dynamic>> _wordBankForTopic(String topic) {
    return _writingPromptForTopic(topic)
        .split(' ')
        .map((word) => {'label': word, 'value': word})
        .toList(growable: false);
  }

  static List<Map<String, dynamic>> _reorderBankForTopic(String topic) {
    final words = _reorderPromptForTopic(topic).split(' ');
    final rotated = [...words.skip(1), words.first];
    return rotated
        .map((word) => {'label': word, 'value': word})
        .toList(growable: false);
  }

  static String _emojiForTopic(String topic) {
    switch (topic) {
      case 'Hello World':
        return '👋';
      case 'My Family':
        return '👨‍👩‍👧';
      case 'Colors & Shapes':
        return '🟦';
      case 'Numbers & Counting':
        return '🔢';
      case 'Food & Drinks':
        return '🍎';
      case 'My Body':
        return '🖐️';
      case 'Daily Routine':
        return '⏰';
      case 'Weather & Seasons':
        return '🌦️';
      case 'Animals':
        return '🦁';
      case 'Places & Directions':
        return '🧭';
      default:
        return '✨';
    }
  }
}
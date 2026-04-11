import 'dart:ui';

import 'package:backend_core/models/character.dart' as app_char;

enum CharacterMoment {
  homeWelcome,
  continueJourney,
  lessonPrompt,
  correctAnswer,
  wrongAnswer,
  lessonComplete,
  perfectLesson,
  streakCelebration,
  lockedLesson,
}

class CharacterReaction {
  const CharacterReaction({
    required this.character,
    required this.message,
    required this.accentColor,
    required this.title,
  });

  final app_char.Character character;
  final String message;
  final Color accentColor;
  final String title;
}

class CharacterCoachService {
  CharacterCoachService._internal();

  static final CharacterCoachService _instance =
      CharacterCoachService._internal();

  factory CharacterCoachService() => _instance;

  final Map<String, int> _rotationByBucket = <String, int>{};

  CharacterReaction homeReaction({
    required bool hasProgress,
    required int streak,
    required int xp,
    required double overallProgress,
    String? nextLessonTitle,
  }) {
    final nextStep = (nextLessonTitle != null && nextLessonTitle.trim().isNotEmpty)
        ? nextLessonTitle.trim()
        : 'your next lesson';

    if (!hasProgress) {
      return _reaction(
        character: app_char.Characters.lumi,
        title: 'Lumi is here',
        accentColor: app_char.Characters.lumi.primaryColor,
        bucket: 'home_lumi_start',
        messages: <String>[
          'Hi friend! Let\'s start your very first learning adventure together.',
          'Welcome! I\'ll stay with you while you discover your first words and sounds.',
          'Your adventure starts here. Tap continue and I\'ll guide you step by step.',
        ],
      );
    }

    if (streak >= 5) {
      return _reaction(
        character: app_char.Characters.zippy,
        title: 'Zippy is cheering',
        accentColor: app_char.Characters.zippy.primaryColor,
        bucket: 'home_zippy_streak',
        messages: <String>[
          'Your streak is on fire! Let\'s keep the energy going with $nextStep.',
          'Look at that streak! One more lesson and your flame gets even bigger.',
          'You came back again. That is champion energy. Let\'s jump into $nextStep.',
        ],
      );
    }

    if (overallProgress >= 0.60 || xp >= 250) {
      return _reaction(
        character: app_char.Characters.orin,
        title: 'Orin is watching',
        accentColor: app_char.Characters.orin.primaryColor,
        bucket: 'home_orin_growth',
        messages: <String>[
          'You are growing into a confident learner. Let\'s keep building your journey.',
          'Every lesson adds a little more wisdom. Today is another strong step forward.',
          'Your progress is becoming something special. $nextStep is a lovely next step.',
        ],
      );
    }

    return _reaction(
      character: app_char.Characters.lumi,
      title: 'Your guide',
      accentColor: app_char.Characters.lumi.primaryColor,
      bucket: 'home_lumi_continue',
      messages: <String>[
        'You are doing great. Let\'s continue with $nextStep.',
        'One lesson at a time. I\'ll help you keep moving forward.',
        'Ready for another adventure? $nextStep is waiting.',
      ],
    );
  }

  CharacterReaction lessonPrompt({
    required String exerciseType,
    required int questionIndex,
    required int totalQuestions,
  }) {
    final companions = app_char.Characters.all;
    final preferredCharacter = switch (exerciseType) {
      'speaking' => app_char.Characters.nexo,
      'writing' => app_char.Characters.orin,
      'matching' => companions[questionIndex % companions.length],
      'listening' => companions[(questionIndex + 1) % companions.length],
      _ => companions[(questionIndex + 2) % companions.length],
    };

    final promptBucket = 'prompt_${exerciseType}_${preferredCharacter.id}';
    final stageLabel = questionIndex == totalQuestions - 1
        ? 'Final question feeling'
        : '${preferredCharacter.name} is with you';

    return _reaction(
      character: preferredCharacter,
      title: stageLabel,
      accentColor: preferredCharacter.primaryColor,
      bucket: promptBucket,
      messages: _promptMessagesFor(preferredCharacter, exerciseType),
    );
  }

  CharacterReaction answerReaction({
    required bool isCorrect,
    required String exerciseType,
    required bool isFirstChance,
    required bool lessonCompleted,
    required bool perfectLesson,
  }) {
    if (isCorrect && perfectLesson) {
      return _reaction(
        character: app_char.Characters.zippy,
        title: 'Big celebration',
        accentColor: app_char.Characters.zippy.primaryColor,
        bucket: 'answer_perfect',
        messages: <String>[
          'Perfect lesson! That was superstar energy from start to finish.',
          'You crushed every challenge. What a beautiful win!',
          'That was smooth, sharp, and brilliant. Perfect!',
        ],
      );
    }

    if (isCorrect && lessonCompleted) {
      return _reaction(
        character: app_char.Characters.orin,
        title: 'Orin celebrates',
        accentColor: app_char.Characters.orin.primaryColor,
        bucket: 'answer_complete',
        messages: <String>[
          'Lesson complete. Every small win is turning into real progress.',
          'You finished the lesson with confidence. That growth will stay with you.',
          'Another lesson is now part of your journey. Well done.',
        ],
      );
    }

    if (isCorrect) {
      return _reaction(
        character: app_char.Characters.zippy,
        title: 'Zippy cheers',
        accentColor: app_char.Characters.zippy.primaryColor,
        bucket: 'answer_correct',
        messages: <String>[
          'Nice work!',
          'You\'re getting better!',
          'That was easy for you!',
          'Boom! Great answer!',
          'Yes! Keep the momentum going!',
        ],
      );
    }

    if (exerciseType == 'speaking' || exerciseType == 'writing') {
      return _reaction(
        character: app_char.Characters.nexo,
        title: 'Nexo helps',
        accentColor: app_char.Characters.nexo.primaryColor,
        bucket: 'answer_correction_$exerciseType',
        messages: isFirstChance
            ? <String>[
                'Oops, try again! Let\'s fix it together.',
                'You\'re close. Check the sounds and try once more.',
                'Almost there. Let\'s correct it step by step.',
              ]
            : <String>[
                'Let\'s slow it down and rebuild the answer carefully.',
                'This one needs a tiny correction. We can do it together.',
                'Stay calm. One more careful try will help.',
              ],
      );
    }

    return _reaction(
      character: isFirstChance
          ? app_char.Characters.lumi
          : app_char.Characters.nexo,
      title: isFirstChance ? 'Lumi encourages' : 'Nexo helps',
      accentColor: isFirstChance
          ? app_char.Characters.lumi.primaryColor
          : app_char.Characters.nexo.primaryColor,
      bucket: isFirstChance ? 'answer_retry_soft' : 'answer_retry_logic',
      messages: isFirstChance
          ? <String>[
              'Oops, try again!',
              'You\'re close!',
              'Let\'s fix it together!',
              'That one was tricky, but you can do it.',
            ]
          : <String>[
              'Take a breath and look at the clues again.',
              'Let\'s break it down and solve it together.',
              'You are still learning. One more try.',
            ],
    );
  }

  CharacterReaction streakReaction({required int streak}) {
    return _reaction(
      character: streak >= 7
          ? app_char.Characters.orin
          : app_char.Characters.zippy,
      title: 'Streak power',
      accentColor: streak >= 7
          ? app_char.Characters.orin.primaryColor
          : app_char.Characters.zippy.primaryColor,
      bucket: 'streak_reward',
      messages: <String>[
        'That streak is glowing. Keep showing up for yourself.',
        'Your streak is becoming a superpower.',
        'Every day you return, your learning gets stronger.',
      ],
    );
  }

  CharacterReaction _reaction({
    required app_char.Character character,
    required String title,
    required Color accentColor,
    required String bucket,
    required List<String> messages,
  }) {
    return CharacterReaction(
      character: character,
      title: title,
      accentColor: accentColor,
      message: _rotate(bucket, messages),
    );
  }

  String _rotate(String bucket, List<String> messages) {
    if (messages.isEmpty) {
      return '';
    }

    final nextIndex = ((_rotationByBucket[bucket] ?? -1) + 1) % messages.length;
    _rotationByBucket[bucket] = nextIndex;
    return messages[nextIndex];
  }

  List<String> _promptMessagesFor(
    app_char.Character character,
    String exerciseType,
  ) {
    switch (character.id) {
      case 'lumi':
        switch (exerciseType) {
          case 'listening':
            return <String>[
              'I feel curious about this sound. Let\'s listen softly and choose together.',
              'I feel calm. Use your ears like a tiny detective and we will find it.',
              'I feel ready to help. Hear the clue and pick the one that fits.',
            ];
          case 'matching':
            return <String>[
              'I feel playful. Let\'s match these clues like puzzle pieces.',
              'I feel excited to spot the picture that belongs here.',
              'I feel gentle and focused. Look for the friend that matches the word.',
            ];
        }
        return <String>[
          'I feel happy to learn with you. Let\'s take this one step by step.',
          'I feel brave for you. Tap the answer that feels right.',
          'I feel ready to guide you. We can solve this together.',
        ];
      case 'zippy':
        return <String>[
          'I feel fired up. Let\'s make this question a quick win.',
          'I feel bouncy and bold. Trust your first smart idea.',
          'I feel excited. Pick fast, but pick with care.',
        ];
      case 'nexo':
        switch (exerciseType) {
          case 'speaking':
            return <String>[
              'I feel focused. Say it clearly and I will coach the rhythm.',
              'I feel steady. Use a brave voice and speak one chunk at a time.',
              'I feel ready to help. Listen first, then say it with confidence.',
            ];
          case 'writing':
            return <String>[
              'I feel precise today. Build the sentence one word at a time.',
              'I feel calm and logical. Watch the order and the spelling.',
              'I feel ready to coach. Use the word bank to shape the answer.',
            ];
        }
        return <String>[
          'I feel focused. Let\'s use the clues and solve it cleanly.',
          'I feel sharp. There is a pattern here, and we can spot it.',
          'I feel ready to coach. Choose the answer that fits best.',
        ];
      case 'orin':
      default:
        return <String>[
          'I feel proud of your progress. Take your time and think clearly.',
          'I feel calm. One careful answer is all we need.',
          'I feel hopeful for you. This is another strong step on your path.',
        ];
    }
  }
}

import 'dart:ui';

/// Character model for the language learning companions.
///
/// These companions are intentionally lightweight so the UI can stay playful
/// while the reaction logic remains modular and easy to extend later.
class Character {
  final String id;
  final String name;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final String emoji;
  final String role;
  final String personality;
  final List<String> traits;

  const Character({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.emoji,
    required this.role,
    required this.personality,
    required this.traits,
  });

  static final Map<String, int> _messageRotation = <String, int>{};

  String getMotivationalMessage({
    required String? lastAction,
    String? taskType,
    bool isFirstChance = true,
  }) {
    final action = lastAction ?? 'lesson_start';
    final messages = _messagesFor(
      action: action,
      taskType: taskType,
      isFirstChance: isFirstChance,
    );

    if (messages.isEmpty) {
      return '$name believes in you!';
    }

    final bucket =
        '$id:$action:${taskType ?? 'general'}:${isFirstChance ? 'first' : 'retry'}';
    final nextIndex = ((_messageRotation[bucket] ?? -1) + 1) % messages.length;
    _messageRotation[bucket] = nextIndex;
    return messages[nextIndex];
  }

  List<String> _messagesFor({
    required String action,
    String? taskType,
    required bool isFirstChance,
  }) {
    switch (id) {
      case 'lumi':
        return _lumiMessages(action, taskType, isFirstChance);
      case 'zippy':
        return _zippyMessages(action, taskType, isFirstChance);
      case 'nexo':
        return _nexoMessages(action, taskType, isFirstChance);
      case 'orin':
        return _orinMessages(action, taskType, isFirstChance);
      default:
        return _lumiMessages(action, taskType, isFirstChance);
    }
  }

  List<String> _lumiMessages(
    String action,
    String? taskType,
    bool isFirstChance,
  ) {
    switch (action) {
      case 'correct_answer':
        return const <String>[
          'Nice work, friend!',
          'You did it! I knew you could.',
          'That was gentle and smart.',
          'You are learning so well already.',
        ];
      case 'wrong_answer':
        return isFirstChance
            ? const <String>[
                'Oops, try again. I will help you.',
                'You are close. Let us look carefully.',
                'That one was tricky. We can fix it together.',
              ]
            : const <String>[
                'Take a calm breath. We will solve it step by step.',
                'No rush. Let us try one more careful answer.',
                'Learning takes practice, and you are still doing great.',
              ];
      case 'lesson_complete':
        return const <String>[
          'You finished the lesson. So proud of you.',
          'Adventure complete. Ready for another tiny win?',
          'You kept going and it paid off.',
        ];
      default:
        if (taskType == 'listening') {
          return const <String>[
            'Listen carefully and trust your ears.',
            'Use your detective ears for this one.',
            'The sound will help you find the answer.',
          ];
        }
        if (taskType == 'matching') {
          return const <String>[
            'Find the clue that belongs with the word.',
            'This is like a tiny puzzle. You can do it.',
            'Look slowly and match the best picture.',
          ];
        }
        return const <String>[
          'Hi friend. Let us learn together.',
          'Let us start together with one small step.',
          'Ready to learn? I am right here with you.',
        ];
    }
  }

  List<String> _zippyMessages(
    String action,
    String? taskType,
    bool isFirstChance,
  ) {
    switch (action) {
      case 'correct_answer':
        return const <String>[
          'Boom. Great answer!',
          'Yes! You are getting stronger!',
          'That was easy for you!',
          'High speed success. Nice job!',
        ];
      case 'wrong_answer':
        return isFirstChance
            ? const <String>[
                'Oops. Bounce back and try again!',
                'You are close. Let us go again!',
                'Tiny stumble. Big comeback next!',
              ]
            : const <String>[
                'Stay in the game. You can still win this one.',
                'Take another shot. I believe in your next answer.',
                'Keep the energy up. We are not done yet.',
              ];
      case 'lesson_complete':
        return const <String>[
          'Lesson complete. That was awesome!',
          'You smashed it. Keep the streak glowing!',
          'Another win for your adventure team!',
        ];
      default:
        if (taskType == 'multipleChoice') {
          return const <String>[
            'Pick your card and go for it!',
            'Trust your instinct and tap the winner.',
            'Quick eyes, quick thinking, big win.',
          ];
        }
        return const <String>[
          'Let us go. Adventure mode is on!',
          'You and me, friend. Time for another win.',
          'Energy up. Your next challenge is waiting.',
        ];
    }
  }

  List<String> _nexoMessages(
    String action,
    String? taskType,
    bool isFirstChance,
  ) {
    switch (action) {
      case 'correct_answer':
        return const <String>[
          'Correct. Your thinking was sharp.',
          'Excellent logic. Well done.',
          'That answer lines up perfectly.',
          'Strong work. You solved it clearly.',
        ];
      case 'wrong_answer':
        return isFirstChance
            ? const <String>[
                'Almost. Let us correct it together.',
                'You are close. Check the clue and try again.',
                'Small error detected. We can fix it.',
              ]
            : const <String>[
                'Slow down and rebuild the answer carefully.',
                'One more precise try should do it.',
                'Let us use the clues and solve it step by step.',
              ];
      case 'lesson_complete':
        return const <String>[
          'Lesson completed successfully.',
          'Progress saved. Your skills are growing.',
          'Strong finish. That was a solid session.',
        ];
      default:
        if (taskType == 'speaking') {
          return const <String>[
            'Use a clear voice. I am listening carefully.',
            'Say it slowly and confidently.',
            'Good speaking comes one sound at a time.',
          ];
        }
        if (taskType == 'writing') {
          return const <String>[
            'Type the answer carefully.',
            'Check each word, then send it.',
            'Accuracy first. Speed second.',
          ];
        }
        return const <String>[
          'Let us notice the patterns together.',
          'Let us think clearly and solve this together.',
          'Ready to focus? Let us solve this with clear thinking.',
        ];
    }
  }

  List<String> _orinMessages(
    String action,
    String? taskType,
    bool isFirstChance,
  ) {
    switch (action) {
      case 'correct_answer':
        return const <String>[
          'Beautiful work. Your progress is growing.',
          'Wise choice. You are becoming more confident.',
          'That answer shows real learning.',
          'Another thoughtful step forward.',
        ];
      case 'wrong_answer':
        return isFirstChance
            ? const <String>[
                'Even wise learners pause and try again.',
                'You are still on the right path. Try once more.',
                'Mistakes are part of growing. Keep going.',
              ]
            : const <String>[
                'Patience now. Growth often comes after a second try.',
                'Take another careful look. The answer will appear.',
                'Every retry is part of your journey.',
              ];
      case 'lesson_complete':
        return const <String>[
          'Another lesson added to your journey.',
          'You are building something strong, one lesson at a time.',
          'Keep this rhythm. It turns effort into growth.',
        ];
      default:
        return const <String>[
          'I will watch over your long adventure.',
          'Every lesson you finish makes you stronger.',
          'Small steps today become big progress tomorrow.',
        ];
    }
  }
}

class Characters {
  static const Character lumi = Character(
    id: 'lumi',
    name: 'Lumi',
    description: 'A curious baby guide who makes first steps feel safe and fun.',
    primaryColor: Color(0xFFF5B94C),
    secondaryColor: Color(0xFFFFF5DE),
    emoji: 'ðŸ‘¶',
    role: 'Guide',
    personality: 'Friendly, curious, and patient',
    traits: <String>['gentle', 'curious', 'safe', 'supportive'],
  );

  static const Character zippy = Character(
    id: 'zippy',
    name: 'Zippy',
    description: 'A playful cat who brings energy, celebration, and momentum.',
    primaryColor: Color(0xFFF26A5B),
    secondaryColor: Color(0xFFFFEEE8),
    emoji: 'ðŸ±',
    role: 'Motivator',
    personality: 'Energetic, joyful, and bold',
    traits: <String>['fast', 'playful', 'cheerful', 'brave'],
  );

  static const Character nexo = Character(
    id: 'nexo',
    name: 'Nexo',
    description: 'A clever robot who helps with logic, speaking, and corrections.',
    primaryColor: Color(0xFF4F7CF7),
    secondaryColor: Color(0xFFEAF0FF),
    emoji: 'ðŸ¤–',
    role: 'Coach',
    personality: 'Clear, calm, and precise',
    traits: <String>['logical', 'focused', 'helpful', 'clear'],
  );

  static const Character orin = Character(
    id: 'orin',
    name: 'Orin',
    description: 'A wise owl who celebrates steady growth and long-term progress.',
    primaryColor: Color(0xFF4E8D64),
    secondaryColor: Color(0xFFEAF6ED),
    emoji: 'ðŸ¦‰',
    role: 'Mentor',
    personality: 'Wise, calm, and encouraging',
    traits: <String>['steady', 'wise', 'patient', 'reflective'],
  );

  static const List<Character> all = <Character>[lumi, zippy, nexo, orin];

  static Character? getById(String? id) {
    if (id == null || id.isEmpty) {
      return null;
    }
    try {
      return all.firstWhere((character) => character.id == id);
    } catch (_) {
      return null;
    }
  }

  static Character getRandomCharacter() {
    return all[DateTime.now().millisecond % all.length];
  }
}

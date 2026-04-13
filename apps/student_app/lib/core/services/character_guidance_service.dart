import '../models/character.dart';
import '../models/learning_exercise.dart';
import 'audio_service.dart';

class GuidanceReaction {
  const GuidanceReaction({
    required this.message,
    this.spokenLine,
    this.cue,
    this.shouldSpeak = false,
  });

  final String message;
  final String? spokenLine;
  final FeedbackCue? cue;
  final bool shouldSpeak;
}

class CharacterGuidanceService {
  const CharacterGuidanceService();

  int _characterSeed(Character character) {
    return switch (character.id) {
      'baby' => 1,
      'nexo' => 2,
      'owl' => 3,
      _ => 0,
    };
  }

  String _pick(List<String> variants, int seed) {
    return variants[seed % variants.length];
  }

  int _exerciseSeed(LearningExercise exercise, Character character) {
    return exercise.id.hashCode.abs() + _characterSeed(character);
  }

  GuidanceReaction lessonWelcome({
    required Character character,
    required LearningExercise exercise,
    required String emotion,
    required bool resumed,
    required int solvedSteps,
  }) {
    if (resumed) {
      final message = switch (character.id) {
        'baby' => _pick([
            'Welcome back. $solvedSteps done. One more step.',
            'You are back. $solvedSteps complete. Keep going.',
          ], solvedSteps),
        'nexo' => _pick([
            'Welcome back. $solvedSteps solved. Next step ready.',
            'Progress restored. $solvedSteps solved. Continue.',
          ], solvedSteps),
        'owl' => _pick([
            'Welcome back. Your work is safe. Continue calmly.',
            'You are back. Breathe once. Continue where you stopped.',
          ], solvedSteps),
        _ => _pick([
            'Welcome back. Progress saved. Next step ready.',
            'Your lesson is ready again. Continue now.',
          ], solvedSteps),
      };
      return GuidanceReaction(
        message: message,
        spokenLine: message,
        shouldSpeak: emotion == 'needs_support',
      );
    }

    final intro = switch (character.id) {
      'baby' => _pick([
          'I am here. One brave answer at a time.',
          'Let us play. One smart step now.',
        ], _exerciseSeed(exercise, character)),
      'nexo' => _pick([
          'I am ready. Clear steps only.',
          'Systems ready. Let us solve this fast.',
        ], _exerciseSeed(exercise, character)),
      'owl' => _pick([
          'I am here. Slow down and notice.',
          'Take a calm breath. Then begin.',
        ], _exerciseSeed(exercise, character)),
      _ => _pick([
          'I am ready. Let us begin.',
          'Ready for a bright start? Let us go.',
        ], _exerciseSeed(exercise, character)),
    };
    return GuidanceReaction(message: intro);
  }

  GuidanceReaction draftReady({
    required Character character,
    required String exerciseType,
  }) {
    final message = switch (exerciseType) {
      'speaking' => 'I am listening. Tap Check.',
      'reorder' => 'Good. Check when it sounds right.',
      'writing' => 'Good. Read once, then Check.',
      _ => 'Good choice. Tap Check.',
    };
    return GuidanceReaction(
      message: message,
      cue: FeedbackCue.optionSelected,
      shouldSpeak: false,
    );
  }

  GuidanceReaction playbackStarted({
    required Character character,
    required bool usedFallback,
  }) {
    final message = usedFallback
        ? switch (character.id) {
            'baby' => 'Task voice is on. Listen, then tap.',
            'nexo' => 'Prompt voice active. Listen, then solve.',
            'owl' => 'Task voice is ready. Listen carefully.',
            _ => 'Task voice is on. Listen, then answer.',
          }
        : switch (character.id) {
            'baby' => 'Prompt playing. Catch the sound.',
            'nexo' => 'Prompt playing. Lock onto the clue.',
            'owl' => 'Listen closely. Catch the first sound.',
            _ => 'Prompt playing. Listen carefully.',
          };

    return GuidanceReaction(
      message: message,
      spokenLine: null,
      cue: FeedbackCue.optionSelected,
      shouldSpeak: false,
    );
  }

  GuidanceReaction recordingStarted({
    required Character character,
    required String emotion,
  }) {
    final message = switch (character.id) {
      'baby' => 'I am listening. Speak slowly.',
      'nexo' => 'Recording started. One clear try.',
      'owl' => 'Speak when ready. Stay calm.',
      _ => 'Recording started. Speak clearly.',
    };

    return GuidanceReaction(
      message: message,
      spokenLine: emotion == 'needs_support' ? message : null,
      cue: FeedbackCue.optionSelected,
      shouldSpeak: emotion == 'needs_support',
    );
  }

  GuidanceReaction recordingCaptured({
    required Character character,
    required bool hasWords,
    required String emotion,
  }) {
    if (!hasWords) {
      return emptyAnswer(
        character: character,
        exerciseType: 'speaking',
        emotion: emotion,
      );
    }

    final message = switch (character.id) {
      'baby' => _pick(['I heard you. Now check.', 'Nice voice. Tap Check.'], _characterSeed(character)),
      'nexo' => _pick(['Voice captured. Check now.', 'Input stored. Check now.'], _characterSeed(character)),
      'owl' => _pick(['Voice captured. Breathe, then check.', 'I heard that. Pause, then check.'], _characterSeed(character)),
      _ => _pick(['Voice captured. Check now.', 'Good. Tap Check now.'], _characterSeed(character)),
    };

    return GuidanceReaction(
      message: message,
      cue: FeedbackCue.optionSelected,
      shouldSpeak: false,
    );
  }

  GuidanceReaction microphoneError({
    required Character character,
    required String message,
  }) {
    final line = switch (character.id) {
      'baby' => 'Mic trouble. Try again gently.',
      'nexo' => 'Mic problem. Retry now.',
      'owl' => 'Mic trouble. Try once more calmly.',
      _ => 'Mic problem. Try again.',
    };

    return GuidanceReaction(
      message: '$line Details: $message',
      spokenLine: line,
      cue: FeedbackCue.gentlePrompt,
      shouldSpeak: true,
    );
  }

  GuidanceReaction nextStep({
    required Character character,
    required LearningExercise exercise,
    required String emotion,
  }) {
    final line = switch (exercise.type) {
      'listening' => _pick(['New listening step. Hear the clue first.', 'Fresh audio round. Listen before tapping.'], _characterSeed(character)),
      'speaking' => _pick(['New speaking step. One clear phrase.', 'Voice round. Say it once, clearly.'], _characterSeed(character)),
      'reorder' => _pick(['New sentence step. Build the order.', 'Build the line from the first word.'], _characterSeed(character)),
      'writing' => _pick(['New writing step. Build and read.', 'Write it clean, then check it.'], _characterSeed(character)),
      'trueFalse' => _pick(['New check. True or false.', 'Quick round. Pick true or false.'], _characterSeed(character)),
      'matching' => _pick(['New match. Pair the strongest clue.', 'New pair round. Match the best clue first.'], _characterSeed(character)),
      _ => _pick(['New step ready.', 'Next challenge ready.'], _characterSeed(character)),
    };

    return GuidanceReaction(
      message: line,
      spokenLine: emotion == 'needs_support' ? line : null,
      cue: FeedbackCue.optionSelected,
      shouldSpeak: emotion == 'needs_support',
    );
  }

  GuidanceReaction emptyAnswer({
    required Character character,
    required String exerciseType,
    required String emotion,
  }) {
    final message = switch (exerciseType) {
      'speaking' => 'Record your voice first.',
      'writing' => 'Write something first.',
      'reorder' => 'Build the sentence first.',
      _ => 'Choose an answer first.',
    };

    return GuidanceReaction(
      message: message,
      spokenLine: message,
      cue: FeedbackCue.gentlePrompt,
      shouldSpeak: emotion == 'needs_support',
    );
  }

  GuidanceReaction answerOutcome({
    required Character character,
    required LearningExercise exercise,
    required bool isCorrect,
    required String emotion,
    required int mistakeCount,
    required int correctStreak,
    required double progressValue,
  }) {
    if (isCorrect) {
      final message = switch (character.id) {
        'baby' => _pick(['Yes. Nice job.', 'Great one. Keep going.', 'That was smart.'], correctStreak + _characterSeed(character)),
        'nexo' => _pick(['Correct. Strong choice.', 'Correct. Efficient move.', 'Locked in. Correct.'], correctStreak + _characterSeed(character)),
        'owl' => _pick(['Well done. Calm and correct.', 'Good work. You heard it well.', 'That was steady and right.'], correctStreak + _characterSeed(character)),
        _ => _pick(['Correct. Keep going.', 'Nice. Next one.', 'Strong answer.'], correctStreak + _characterSeed(character)),
      };
      final shouldSpeak = (emotion == 'needs_support' && correctStreak >= 1) ||
          correctStreak >= 3 ||
          progressValue >= 0.96;
      return GuidanceReaction(
        message: message,
        spokenLine: shouldSpeak ? message : null,
        cue: FeedbackCue.correctAnswer,
        shouldSpeak: shouldSpeak,
      );
    }

    final supportTail = mistakeCount >= 3
        ? 'Slow down. Try again.'
        : switch (exercise.type) {
            'listening' => 'Play it again. Catch the first sound.',
            'speaking' => 'Try one clear phrase.',
            'writing' => 'Read it once more.',
            'reorder' => 'Start with the first word.',
            _ => 'Look once more.',
          };

    final message = switch (character.id) {
      'baby' => _pick(['Not yet. $supportTail', 'Close one. $supportTail'], mistakeCount + _characterSeed(character)),
      'nexo' => _pick(['Almost. $supportTail', 'Close. Reprocess it. $supportTail'], mistakeCount + _characterSeed(character)),
      'owl' => _pick(['Try again calmly. $supportTail', 'Slow down once. $supportTail'], mistakeCount + _characterSeed(character)),
      _ => _pick(['Not quite. $supportTail', 'Almost there. $supportTail'], mistakeCount + _characterSeed(character)),
    };

    return GuidanceReaction(
      message: message,
      spokenLine: mistakeCount >= 2 || emotion == 'needs_support' ? message : null,
      cue: FeedbackCue.incorrectAnswer,
      shouldSpeak: mistakeCount >= 2 || emotion == 'needs_support',
    );
  }

  GuidanceReaction lessonComplete({
    required Character character,
    required double score,
    required int earnedXp,
    required bool perfectBonus,
    required int mistakeCount,
  }) {
    final percent = score.toStringAsFixed(0);
    final bonusLine = perfectBonus ? ' Bonus won.' : '';
    final recoveryLine = mistakeCount > 0 ? ' Good recovery.' : '';

    final message = switch (character.id) {
      'baby' => _pick([
          'Lesson done. $earnedXp XP. $percent percent.$bonusLine$recoveryLine',
          'You cleared it. $earnedXp XP won. Score $percent percent.$bonusLine',
        ], earnedXp + _characterSeed(character)),
      'nexo' => _pick([
          'Lesson done. $percent percent. $earnedXp XP.$bonusLine',
          'Stage clear. Score $percent percent. $earnedXp XP secured.$bonusLine',
        ], earnedXp + _characterSeed(character)),
      'owl' => _pick([
          'Lesson done. $percent percent. $earnedXp XP.$recoveryLine',
          'You finished well. Score $percent percent. $earnedXp XP.$recoveryLine',
        ], earnedXp + _characterSeed(character)),
      _ => _pick([
          'Lesson done. $earnedXp XP. $percent percent.$bonusLine',
          'Challenge cleared. $earnedXp XP earned. Score $percent percent.$bonusLine',
        ], earnedXp + _characterSeed(character)),
    };

    return GuidanceReaction(
      message: message,
      spokenLine: message,
      cue: perfectBonus ? FeedbackCue.celebration : FeedbackCue.reward,
      shouldSpeak: true,
    );
  }
}
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/models/character.dart';
import '../../core/models/learning_chapter.dart';
import '../../core/models/learning_exercise.dart';
import '../../core/models/learning_lesson.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/audio_service.dart' show AudioPlaybackResult, AudioService, FeedbackCue;
import '../../core/services/character_guidance_service.dart';
import '../../core/services/firestore_learning_service.dart';
import '../widgets/animated_character_avatar.dart';

class StudentLessonScreen extends StatefulWidget {
  const StudentLessonScreen({
    super.key,
    this.lessonId,
    this.onReturnHome,
  });

  final String? lessonId;
  final VoidCallback? onReturnHome;

  @override
  State<StudentLessonScreen> createState() => _StudentLessonScreenState();
}

class _StudentLessonScreenState extends State<StudentLessonScreen> {
  final AudioService _audioService = AudioService.instance;
  final FirestoreLearningService _learningService = FirestoreLearningService();
  final CharacterGuidanceService _guidanceService = const CharacterGuidanceService();

  late LearningLesson _lesson;
  late LearningChapter _chapter;
  late Character _coach;
  late TextEditingController _writingController;

  List<LearningExercise> _exercises = [];
  int _currentIndex = 0;
  List<String> _completedExerciseIds = [];
  String? _selectedOption;
  String _spokenWords = '';
  List<String> _reorderSelection = [];
  int _mistakeCount = 0;
  int _correctStreak = 0;
  int _sessionXp = 0;
  double _finalScore = 0;
  bool _lessonCompleted = false;
  bool _showCelebration = false;
  bool? _lastAnswerCorrect;
  String _statusMessage = '';
  bool _isLoading = true;
  bool _isPlayingAudio = false;
  bool _isRecording = false;
  bool _isSavingProgress = false;
  String? _loadError;
  String? _lastSpokenGuidance;

  @override
  void initState() {
    super.initState();
    _writingController = TextEditingController();
    _loadLesson();
  }

  @override
  void dispose() {
    _audioService.stop();
    _audioService.stopListening();
    _writingController.dispose();
    super.dispose();
  }

  Future<void> _loadLesson() async {
    final userId = context.read<UserProvider>().currentUserId ?? 'student_demo';

    try {
      final bundle = await _learningService.loadLessonBundle(
        userId: userId,
        lessonId: widget.lessonId,
      );
      final savedState = bundle.lessonState;

      if (!mounted) {
        return;
      }

      setState(() {
        _lesson = bundle.lesson;
        _chapter = bundle.chapter;
        _coach = Character.characters[
            (_lesson.order + _chapter.order - 2) % Character.characters.length];
        _exercises = bundle.exercises;
        _completedExerciseIds = List<String>.from(savedState?.completedExerciseIds ?? const <String>[]);
        _mistakeCount = savedState?.mistakeCount ?? 0;
        _sessionXp = savedState?.xpEarned ?? 0;
        _currentIndex = _initialExerciseIndex(savedState, bundle.exercises.length);
        _statusMessage = bundle.exercises.isEmpty
          ? ''
          : _initialStatusMessage(savedState, bundle.exercises[_currentIndex]);
        _isLoading = false;
        _loadError = null;
      });

      if (_exercises.isNotEmpty) {
        final reaction = _guidanceService.lessonWelcome(
          character: _coach,
          exercise: _exercises[_currentIndex],
          emotion: _currentSessionEmotion(),
          resumed: savedState != null && (savedState.completedExerciseIds.isNotEmpty || savedState.mistakeCount > 0),
          solvedSteps: savedState?.completedExerciseIds.length ?? 0,
        );
        if (reaction.shouldSpeak) {
          await _performGuidance(reaction);
        }
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _loadError = error.toString();
      });
    }
  }

  LearningExercise get _currentExercise => _exercises[_currentIndex];

  double get _progressValue {
    if (_exercises.isEmpty) {
      return 0;
    }
    final completedCount = _completedExerciseIds.length;
    final inFlightBonus = _lastAnswerCorrect == true && !_completedExerciseIds.contains(_currentExercise.id) ? 1 : 0;
    return ((completedCount + inFlightBonus) / _exercises.length).clamp(0, 1);
  }

  int get _heartsLeft {
    final remaining = 5 - _mistakeCount;
    return remaining < 0 ? 0 : remaining;
  }

  String get _coachSpeechText {
    if (_statusMessage.isNotEmpty) {
      return _statusMessage;
    }
    return _coachIntroForExercise(_currentExercise);
  }

  bool get _hasAnswerReady {
    final exercise = _currentExercise;
    return switch (exercise.type) {
      'speaking' => _normalizeText(_spokenWords).isNotEmpty,
      'reorder' => _reorderSelection.isNotEmpty,
      'writing' => _normalizeText(_writingController.text).isNotEmpty,
      _ => _normalizeText(_selectedOption ?? '').isNotEmpty,
    };
  }

  String get _checkActionLabel {
    if (_isRecording) {
      return 'Stop recording first';
    }
    return 'Check';
  }

  void _setSelectedOption(String value) {
    final reaction = _guidanceService.draftReady(
      character: _coach,
      exerciseType: _currentExercise.type,
    );

    setState(() {
      _selectedOption = value;
      _lastAnswerCorrect = null;
      _statusMessage = reaction.message;
    });

    _triggerFeedbackCue(reaction.cue);
  }

  Future<void> _playExerciseAudio() async {
    setState(() {
      _isPlayingAudio = true;
      _statusMessage = 'Playing the prompt...';
    });

    try {
      final AudioPlaybackResult result = await _audioService.play(
        source: _currentExercise.audioUrl,
        fallbackText: _currentExercise.expectedSpeech.isNotEmpty
            ? _currentExercise.expectedSpeech
            : _currentExercise.question,
      );
      if (!mounted) {
        return;
      }
      final reaction = _guidanceService.playbackStarted(
        character: _coach,
        usedFallback: result.usedFallback,
      );
      setState(() {
        if (!result.producedAudio) {
          _statusMessage = 'Audio is unavailable for this prompt right now.';
        } else {
          _statusMessage = reaction.message;
        }
      });
      if (result.producedAudio) {
        if (reaction.shouldSpeak) {
          await _performGuidance(reaction);
        } else {
          await _triggerFeedbackCue(reaction.cue);
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlayingAudio = false;
        });
      }
    }
  }

  Future<void> _toggleMicrophone() async {
    if (_isRecording) {
      final finalWords = await _audioService.stopListening();
      final reaction = finalWords.isEmpty
          ? _guidanceService.emptyAnswer(
              character: _coach,
              exerciseType: 'speaking',
              emotion: _currentSessionEmotion(),
            )
          : _guidanceService.draftReady(
              character: _coach,
              exerciseType: 'speaking',
            );
      setState(() {
        _isRecording = false;
        _spokenWords = finalWords;
        _lastAnswerCorrect = null;
        _statusMessage = finalWords.isEmpty
            ? 'No speech captured. ${reaction.message}'
            : 'Voice captured. ${reaction.message}';
      });
      if (finalWords.isEmpty) {
        await _performGuidance(reaction);
      } else {
        await _triggerFeedbackCue(reaction.cue);
      }
      return;
    }

    final started = await _audioService.startListening(
      onWords: (words) {
        if (!mounted) {
          return;
        }
        setState(() {
          _spokenWords = words;
        });
      },
      onStatus: _handleSpeechStatus,
      onError: _handleSpeechError,
    );

    if (!mounted) {
      return;
    }

    if (!started) {
      setState(() {
        _statusMessage = 'Microphone is not available on this device right now.';
      });
      return;
    }

    final reaction = _guidanceService.recordingStarted(
      character: _coach,
      emotion: _currentSessionEmotion(),
    );

    setState(() {
      _isRecording = true;
      _statusMessage = reaction.message;
    });

    if (reaction.shouldSpeak) {
      await _performGuidance(reaction);
    } else {
      await _triggerFeedbackCue(reaction.cue);
    }
  }

  void _handleSpeechStatus(String status) {
    if (!mounted) {
      return;
    }

    if (status == 'done' || status == 'notListening') {
      final hasWords = _spokenWords.trim().isNotEmpty;
      final reaction = _guidanceService.recordingCaptured(
        character: _coach,
        hasWords: hasWords,
        emotion: _currentSessionEmotion(),
      );
      setState(() {
        _isRecording = false;
        _statusMessage = reaction.message;
      });

      _triggerFeedbackCue(reaction.cue);
    }
  }

  void _handleSpeechError(String message) {
    if (!mounted) {
      return;
    }

    final reaction = _guidanceService.microphoneError(
      character: _coach,
      message: message,
    );

    setState(() {
      _isRecording = false;
      _statusMessage = reaction.message;
    });

    _performGuidance(reaction);
  }

  Future<void> _showSkipSwapDialog() async {
    final action = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Skip or swap'),
          content: Text(
            'You can skip this prompt or fill it with the expected phrase for testing.',
            style: _bodyStyle(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('skip'),
              child: const Text('Skip'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop('swap'),
              child: const Text('Swap phrase'),
            ),
          ],
        );
      },
    );

    if (action == 'skip') {
      final reaction = _guidanceService.emptyAnswer(
        character: _coach,
        exerciseType: 'speaking',
        emotion: _currentSessionEmotion(),
      );
      setState(() {
        _spokenWords = '';
        _lastAnswerCorrect = null;
        _statusMessage = 'Prompt skipped. ${reaction.message}';
      });
      await _performGuidance(reaction);
    } else if (action == 'swap') {
      final reaction = _guidanceService.draftReady(
        character: _coach,
        exerciseType: 'speaking',
      );
      setState(() {
        _spokenWords = _currentExercise.expectedSpeech;
        _lastAnswerCorrect = null;
        _statusMessage = 'Expected phrase inserted for testing. ${reaction.message}';
      });
      await _triggerFeedbackCue(reaction.cue);
    }
  }

  void _appendWord(String word) {
    final currentText = _writingController.text.trim();
    final nextText = currentText.isEmpty ? word : '$currentText $word';
    final reaction = _guidanceService.draftReady(
      character: _coach,
      exerciseType: _currentExercise.type,
    );

    setState(() {
      _writingController.text = nextText;
      _writingController.selection = TextSelection.collapsed(
        offset: _writingController.text.length,
      );
      _lastAnswerCorrect = null;
      _statusMessage = reaction.message;
    });
  }

  void _appendReorderWord(String word) {
    if (_reorderSelection.contains(word)) {
      return;
    }

    final reaction = _guidanceService.draftReady(
      character: _coach,
      exerciseType: _currentExercise.type,
    );

    setState(() {
      _reorderSelection = [..._reorderSelection, word];
      _lastAnswerCorrect = null;
      _statusMessage = reaction.message;
    });

    _triggerFeedbackCue(reaction.cue);
  }

  void _removeReorderWord(int index) {
    if (index < 0 || index >= _reorderSelection.length) {
      return;
    }

    setState(() {
      _reorderSelection = [
        ..._reorderSelection.take(index),
        ..._reorderSelection.skip(index + 1),
      ];
      _lastAnswerCorrect = null;
      _statusMessage = 'Adjust the order until the sentence sounds right.';
    });
  }

  Future<void> _speakCoachCue() async {
    await _audioService.speakCharacterLine(
      character: _coach,
      text: _coachSpeechText,
      emotion: _currentSessionEmotion(),
    );
  }

  Future<void> _checkAnswer() async {
    if (_lessonCompleted || _exercises.isEmpty) {
      return;
    }

    if (_isRecording) {
      final reaction = GuidanceReaction(
        message: 'Stop recording before checking your answer.',
        spokenLine: 'Stop recording first, then I can check your answer.',
        cue: FeedbackCue.gentlePrompt,
        shouldSpeak: true,
      );
      setState(() {
        _statusMessage = reaction.message;
      });
      await _performGuidance(reaction);
      return;
    }

    if (!_hasAnswerReady) {
      final reaction = _guidanceService.emptyAnswer(
        character: _coach,
        exerciseType: _currentExercise.type,
        emotion: _currentSessionEmotion(),
      );
      setState(() {
        _lastAnswerCorrect = null;
        _statusMessage = reaction.message;
      });
      await _performGuidance(reaction);
      return;
    }

    final exercise = _currentExercise;
    final sessionEmotion = _currentSessionEmotion();
    bool isCorrect;
    switch (exercise.type) {
      case 'speaking':
        isCorrect = _fuzzyTokenMatch(_spokenWords, exercise.correctAnswer) >= 0.7;
      case 'reorder':
        isCorrect = _normalizeText(_reorderSelection.join(' ')) ==
            _normalizeText(exercise.correctAnswer);
      case 'writing':
        isCorrect = _normalizeText(_writingController.text) ==
            _normalizeText(exercise.correctAnswer);
      default:
        isCorrect = _normalizeText(_selectedOption ?? '') ==
            _normalizeText(exercise.correctAnswer);
    }

    final nextCorrectStreak = isCorrect ? _correctStreak + 1 : 0;
    final reaction = _guidanceService.answerOutcome(
      character: _coach,
      exercise: exercise,
      isCorrect: isCorrect,
      emotion: sessionEmotion,
      mistakeCount: isCorrect ? _mistakeCount : _mistakeCount + 1,
      correctStreak: nextCorrectStreak,
      progressValue: _progressValue,
    );

    setState(() {
      _lastAnswerCorrect = isCorrect;
      if (isCorrect) {
        if (!_completedExerciseIds.contains(exercise.id)) {
          _completedExerciseIds = [..._completedExerciseIds, exercise.id];
          _sessionXp += exercise.xpReward;
        }
        _correctStreak = nextCorrectStreak;
        _statusMessage = reaction.message;
      } else {
        _mistakeCount += 1;
        _correctStreak = 0;
        _statusMessage = reaction.message;
      }
    });

    await _persistLessonProgress();
    await _performGuidance(reaction, emotion: sessionEmotion);
  }

  Future<void> _goToNext() async {
    if (_lastAnswerCorrect == null) {
      setState(() {
        _statusMessage = 'Check your answer before moving on.';
      });
      return;
    }

    if (_currentIndex == _exercises.length - 1) {
      await _completeLesson();
      return;
    }

    final nextIndex = _currentIndex + 1;

    setState(() {
      _currentIndex = nextIndex;
      _selectedOption = null;
      _spokenWords = '';
      _reorderSelection = [];
      _writingController.clear();
      _lastAnswerCorrect = null;
      _statusMessage = _guidanceService.nextStep(
        character: _coach,
        exercise: _exercises[nextIndex],
        emotion: _currentSessionEmotion(),
      ).message;
    });

    await _persistLessonProgress();
    final reaction = _guidanceService.nextStep(
      character: _coach,
      exercise: _exercises[nextIndex],
      emotion: _currentSessionEmotion(),
    );
    if (reaction.shouldSpeak) {
      await _performGuidance(reaction);
    } else {
      await _triggerFeedbackCue(reaction.cue);
    }
  }

  Future<void> _completeLesson() async {
    final correctCount = _completedExerciseIds.length;
    var earnedXp = _sessionXp;
    if (_mistakeCount == 0) {
      earnedXp += 20;
    }

    final userId = context.read<UserProvider>().currentUserId ?? 'student_demo';
    final result = await _learningService.completeLesson(
      userId: userId,
      lesson: _lesson,
      earnedXp: earnedXp,
      finalScore: _exercises.isEmpty ? 0 : correctCount / _exercises.length,
      mistakeCount: _mistakeCount,
      completedExerciseIds: _completedExerciseIds,
      totalExerciseCount: _exercises.length,
    );
    if (mounted && result != null) {
      context.read<UserProvider>().syncProgressMeta(
        nextTotalXp: result.totalXp,
        nextDailyStreak: result.dailyStreak,
        nextEmotion: result.currentEmotion,
        nextEvolutionStage: result.evolutionStage,
        nextMasteryScore: result.masteryScore,
      );
    }

    final reaction = _guidanceService.lessonComplete(
      character: _coach,
      score: (correctCount / _exercises.length) * 100,
      earnedXp: earnedXp,
      perfectBonus: _mistakeCount == 0,
      mistakeCount: _mistakeCount,
    );

    setState(() {
      _sessionXp = earnedXp;
      _finalScore = (correctCount / _exercises.length) * 100;
      _lessonCompleted = true;
      _showCelebration = true;
      _statusMessage = reaction.message;
    });

    await _performGuidance(reaction);
  }

  String _currentSessionEmotion() {
    return _sessionEmotion(context.read<UserProvider>().currentEmotion);
  }

  int _initialExerciseIndex(LessonStateSnapshot? state, int exerciseCount) {
    if (state == null || exerciseCount <= 0) {
      return 0;
    }

    final maxIndex = exerciseCount - 1;
    return state.currentExerciseIndex.clamp(0, maxIndex);
  }

  String _initialStatusMessage(LessonStateSnapshot? state, LearningExercise exercise) {
    return _guidanceService.lessonWelcome(
      character: _coach,
      exercise: exercise,
      emotion: _currentSessionEmotion(),
      resumed: state != null && (state.completedExerciseIds.isNotEmpty || state.mistakeCount > 0),
      solvedSteps: state?.completedExerciseIds.length ?? 0,
    ).message;
  }

  Future<void> _persistLessonProgress() async {
    if (_lessonCompleted || _isSavingProgress) {
      return;
    }

    final userId = context.read<UserProvider>().currentUserId ?? 'student_demo';
    _isSavingProgress = true;
    try {
      await _learningService.updateLessonProgress(
        userId: userId,
        lesson: _lesson,
        currentExerciseIndex: _currentIndex,
        completedExerciseIds: _completedExerciseIds,
        totalExerciseCount: _exercises.length,
        mistakeCount: _mistakeCount,
        xpEarned: _sessionXp,
      );
    } finally {
      _isSavingProgress = false;
    }
  }

  Future<void> _performGuidance(GuidanceReaction reaction, {String? emotion}) async {
    await _triggerFeedbackCue(reaction.cue);
    final spokenLine = reaction.spokenLine?.trim();
    final shouldSpeak = reaction.shouldSpeak &&
        spokenLine != null &&
        spokenLine.isNotEmpty &&
        (spokenLine != _lastSpokenGuidance ||
            reaction.cue == FeedbackCue.celebration ||
            reaction.cue == FeedbackCue.reward);
    if (shouldSpeak) {
      await _audioService.speakCharacterLine(
        character: _coach,
        text: spokenLine,
        emotion: emotion ?? _currentSessionEmotion(),
      );
      _lastSpokenGuidance = spokenLine;
    }
  }

  Future<void> _triggerFeedbackCue(FeedbackCue? cue) async {
    if (cue == null) {
      return;
    }
    await _audioService.playFeedbackCue(cue);
  }

  void _returnHome() {
    if (widget.onReturnHome != null) {
      widget.onReturnHome!.call();
      return;
    }
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Failed to load lesson', style: _headingStyle(fontSize: 24)),
                  const SizedBox(height: AppSpacing.md),
                  Text(_loadError!, textAlign: TextAlign.center, style: _bodyStyle()),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _loadError = null;
                      });
                      _loadLesson();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final exercise = _currentExercise;
    final user = context.watch<UserProvider>();
    final sessionEmotion = _sessionEmotion(user.currentEmotion);
    final supportCue = _supportCueForExercise(exercise);
    final mediaQuery = MediaQuery.of(context);
    final isNarrowWidth = mediaQuery.size.width < 380;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _colorFromHex(_chapter.colorHex),
              AppColors.background,
              AppColors.background,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0, 0.28, 1],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLessonTopBar(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildLessonTitleHeader(isNarrowWidth: isNarrowWidth),
                    const SizedBox(height: AppSpacing.lg),
                    _buildStageSummary(
                      sessionEmotion: sessionEmotion,
                      masteryScore: user.masteryScore,
                      supportCue: supportCue,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildLessonStage(exercise: exercise),
                  ],
                ),
              ),
              if (_showCelebration)
                _CelebrationOverlay(
                  score: _finalScore,
                  xpEarned: _sessionXp,
                  perfectBonus: _mistakeCount == 0,
                  onReturnHome: _returnHome,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLessonTopBar() {
    return Row(
      children: [
        _TopCircleButton(
          icon: Icons.close_rounded,
          onPressed: _returnHome,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: LinearProgressIndicator(
              value: _progressValue,
              minHeight: 12,
              backgroundColor: AppColors.surface.withValues(alpha: 0.45),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Row(
            children: [
              const Icon(Icons.favorite_rounded, color: AppColors.error, size: 18),
              const SizedBox(width: AppSpacing.xs),
              Text('$_heartsLeft', style: _bodyStyle(weight: FontWeight.w800)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLessonTitleHeader({required bool isNarrowWidth}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _chapter.title.toUpperCase(),
          style: _bodyStyle(color: AppColors.surface.withValues(alpha: 0.9), weight: FontWeight.w900),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                _lesson.title,
                style: _headingStyle(fontSize: isNarrowWidth ? 26 : 31),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Session', style: _bodyStyle(color: AppColors.textSecondary, weight: FontWeight.w800)),
                  Text('$_sessionXp XP', style: _headingStyle(fontSize: 18)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStageSummary({
    required String sessionEmotion,
    required double masteryScore,
    required String supportCue,
  }) {
    final confidenceValue = _heartsLeft / 5;
    final confidenceLabel = confidenceValue >= 0.8
        ? 'Strong'
        : confidenceValue >= 0.5
            ? 'Building'
            : 'Needs support';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _StageStatChip(
                icon: Icons.mood_rounded,
                label: _formatEmotion(sessionEmotion),
                tone: _emotionColor(sessionEmotion),
              ),
              _StageStatChip(
                icon: Icons.favorite_rounded,
                label: confidenceLabel,
                tone: confidenceValue >= 0.5 ? AppColors.success : AppColors.warning,
              ),
              _StageStatChip(
                icon: Icons.auto_graph_rounded,
                label: '${(masteryScore * 100).round()}% mastery',
                tone: AppColors.primaryDark,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Coach hint', style: _bodyStyle(color: AppColors.textSecondary, weight: FontWeight.w800)),
          const SizedBox(height: AppSpacing.xs),
          Text(supportCue, style: _bodyStyle(weight: FontWeight.w800)),
          const SizedBox(height: AppSpacing.md),
          _ProgressRail(
            label: 'Lesson progress',
            value: _progressValue,
            caption: '${_currentIndex + 1}/${_exercises.length}',
            color: AppColors.secondaryDark,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ProgressRail(
            label: 'Focus energy',
            value: confidenceValue,
            caption: '$_heartsLeft hearts',
            color: confidenceValue >= 0.5 ? AppColors.success : AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildLessonStage({required LearningExercise exercise}) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(exercise.id),
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 20,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 4),
                  child: AnimatedCharacterAvatar(
                    character: _coach,
                    size: 52,
                    highlighted: true,
                    showLabel: false,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${_coach.name} guide', style: _headingStyle(fontSize: 18)),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _statusMessage.isEmpty ? _coachIntroForExercise(exercise) : _statusMessage,
                        style: _bodyStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  onPressed: _speakCoachCue,
                  style: IconButton.styleFrom(
                    backgroundColor: _coach.secondaryColor.withValues(alpha: 0.7),
                    foregroundColor: _coach.primaryColor,
                  ),
                  icon: const Icon(Icons.volume_up_rounded),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.outline.withValues(alpha: 0.75)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Exercise ${_currentIndex + 1} of ${_exercises.length}',
                    style: _bodyStyle(color: AppColors.textSecondary, weight: FontWeight.w800),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(exercise.question, style: _headingStyle(fontSize: 24)),
                  if (exercise.questionArabic.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      exercise.questionArabic,
                      style: _bodyStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildExerciseArea(exercise),
            const SizedBox(height: AppSpacing.lg),
            if (_lastAnswerCorrect != null || _statusMessage.isNotEmpty)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: KeyedSubtree(
                  key: ValueKey('${_lastAnswerCorrect ?? 'info'}-$_statusMessage'),
                  child: _FeedbackPanel(
                    isCorrect: _lastAnswerCorrect,
                    message: _statusMessage,
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stackVertically = constraints.maxWidth < 340;
        if (stackVertically) {
          return Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _checkAnswer,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                  ),
                  child: Text(_checkActionLabel, style: _bodyStyle(color: AppColors.surface, weight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _goToNext,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.text,
                    side: const BorderSide(color: AppColors.outline),
                    backgroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                  ),
                  child: Text(
                    _currentIndex == _exercises.length - 1 ? 'Finish' : 'Next',
                    style: _bodyStyle(weight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: _checkAnswer,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                ),
                child: Text(_checkActionLabel, style: _bodyStyle(color: AppColors.surface, weight: FontWeight.w800)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: OutlinedButton(
                onPressed: _goToNext,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.text,
                  side: const BorderSide(color: AppColors.outline),
                  backgroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                ),
                child: Text(
                  _currentIndex == _exercises.length - 1 ? 'Finish' : 'Next',
                  style: _bodyStyle(weight: FontWeight.w800),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExerciseArea(LearningExercise exercise) {
    switch (exercise.type) {
      case 'multipleChoice':
        return _MultipleChoiceExercise(
          exercise: exercise,
          selectedOption: _selectedOption,
          lastAnswerCorrect: _lastAnswerCorrect,
          onSelect: _setSelectedOption,
        );
      case 'listening':
        return _ListeningExercise(
          exercise: exercise,
          selectedOption: _selectedOption,
          lastAnswerCorrect: _lastAnswerCorrect,
          onPlay: _playExerciseAudio,
          isPlaying: _isPlayingAudio,
          onSelect: _setSelectedOption,
        );
      case 'matching':
        return _MatchingExercise(
          exercise: exercise,
          selectedOption: _selectedOption,
          lastAnswerCorrect: _lastAnswerCorrect,
          onSelect: _setSelectedOption,
        );
      case 'trueFalse':
        return _TrueFalseExercise(
          exercise: exercise,
          selectedOption: _selectedOption,
          lastAnswerCorrect: _lastAnswerCorrect,
          onSelect: _setSelectedOption,
        );
      case 'reorder':
        return _ReorderExercise(
          exercise: exercise,
          selectedWords: _reorderSelection,
          onAddWord: _appendReorderWord,
          onRemoveWord: _removeReorderWord,
        );
      case 'speaking':
        return _SpeakingExercise(
          exercise: exercise,
          spokenWords: _spokenWords,
          isRecording: _isRecording,
          statusMessage: _statusMessage,
          onRecord: _toggleMicrophone,
          onSkipSwap: _showSkipSwapDialog,
        );
      case 'writing':
        return _WritingExercise(
          exercise: exercise,
          controller: _writingController,
          onWordTap: _appendWord,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _sessionEmotion(String baselineEmotion) {
    if (_lessonCompleted && _mistakeCount == 0) {
      return 'confident';
    }
    if (_lastAnswerCorrect == false || _heartsLeft <= 2) {
      return 'needs_support';
    }
    if (_sessionXp >= 20) {
      return 'joyful';
    }
    return baselineEmotion;
  }

  String _supportCueForExercise(LearningExercise exercise) {
    switch (exercise.type) {
      case 'listening':
        return 'Replay slowly and catch the clue.';
      case 'trueFalse':
        return 'Decide fast. Trust the clue.';
      case 'reorder':
        return 'Build the sentence in order.';
      case 'speaking':
        return 'Say one clear phrase, then check.';
      case 'writing':
        return 'Build it step by step.';
      case 'matching':
        return 'Find the strongest pair first.';
      default:
        return 'Pause. Think. Answer.';
    }
  }

  String _coachIntroForExercise(LearningExercise exercise, {bool warmup = false}) {
    final intro = switch (exercise.type) {
      'listening' => 'Listen first. Catch the sound.',
      'trueFalse' => 'Quick check. Pick true or false.',
      'matching' => 'Match the meaning first.',
      'reorder' => 'Build the sentence in order.',
      'speaking' => 'Use your voice. Keep it clear.',
      'writing' => 'Write it slowly and clearly.',
      _ => 'You are ready. One step now.',
    };

    if (!warmup) {
      return intro;
    }

    return '${_coach.name} is here. $intro';
  }

  double _fuzzyTokenMatch(String input, String expected) {
    final inputTokens = _tokenize(input);
    final expectedTokens = _tokenize(expected);
    if (inputTokens.isEmpty || expectedTokens.isEmpty) {
      return 0;
    }
    final overlap = inputTokens.where(expectedTokens.contains).length;
    return overlap / expectedTokens.length;
  }

  List<String> _tokenize(String value) {
    return _normalizeText(value)
        .split(' ')
        .where((token) => token.isNotEmpty)
        .toList(growable: false);
  }

  String _normalizeText(String value) {
    final lower = value.toLowerCase();
    final cleaned = lower.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
    return cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

class _TopCircleButton extends StatelessWidget {
  const _TopCircleButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.text),
      ),
    );
  }
}

class _TrueFalseExercise extends StatelessWidget {
  const _TrueFalseExercise({
    required this.exercise,
    required this.selectedOption,
    required this.lastAnswerCorrect,
    required this.onSelect,
  });

  final LearningExercise exercise;
  final String? selectedOption;
  final bool? lastAnswerCorrect;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.outline),
          ),
          child: Text(exercise.expectedSpeech, style: _bodyStyle(weight: FontWeight.w800)),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: exercise.options.map((option) {
            final value = option['value'] as String;
            final isSelected = selectedOption == value;
            final isCorrect = _normalizeOption(exercise.correctAnswer) == _normalizeOption(value);
            final color = _answerTone(isSelected, isCorrect, lastAnswerCorrect);
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: value == 'true' ? AppSpacing.md : 0),
                child: InkWell(
                  onTap: () => onSelect(value),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: isSelected ? 0.16 : 0.05),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: color),
                    ),
                    child: Column(
                      children: [
                        Text((option['emoji'] as String?) ?? '✨', style: const TextStyle(fontSize: 30)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(option['label'] as String, style: _bodyStyle(weight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(growable: false),
        ),
      ],
    );
  }
}

class _ReorderExercise extends StatelessWidget {
  const _ReorderExercise({
    required this.exercise,
    required this.selectedWords,
    required this.onAddWord,
    required this.onRemoveWord,
  });

  final LearningExercise exercise;
  final List<String> selectedWords;
  final ValueChanged<String> onAddWord;
  final ValueChanged<int> onRemoveWord;

  @override
  Widget build(BuildContext context) {
    final selectedSet = selectedWords.toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.outline),
          ),
          child: selectedWords.isEmpty
              ? Text('Tap the words below to build the sentence.', style: _bodyStyle(color: AppColors.textSecondary))
              : Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (var index = 0; index < selectedWords.length; index++)
                      InputChip(
                        onDeleted: () => onRemoveWord(index),
                        deleteIcon: const Icon(Icons.close_rounded, size: 18),
                        label: Text(selectedWords[index], style: _bodyStyle(weight: FontWeight.w800)),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: exercise.options.map((option) {
            final word = option['value'] as String;
            final used = selectedSet.contains(word);
            return ActionChip(
              onPressed: used ? null : () => onAddWord(word),
              backgroundColor: used ? AppColors.outline.withValues(alpha: 0.35) : AppColors.surface,
              side: BorderSide(color: used ? AppColors.outline : AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              label: Text(word, style: _bodyStyle(weight: FontWeight.w700)),
            );
          }).toList(growable: false),
        ),
      ],
    );
  }
}

class _FeedbackPanel extends StatelessWidget {
  const _FeedbackPanel({required this.isCorrect, required this.message});

  final bool? isCorrect;
  final String message;

  @override
  Widget build(BuildContext context) {
    final good = isCorrect == true;
    final toneColor = good ? AppColors.success : AppColors.warning;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: toneColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: toneColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(good ? Icons.check_circle_rounded : Icons.info_rounded, color: toneColor),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(message, style: _bodyStyle(color: AppColors.text))),
        ],
      ),
    );
  }
}

class _MultipleChoiceExercise extends StatelessWidget {
  const _MultipleChoiceExercise({
    required this.exercise,
    required this.selectedOption,
    required this.lastAnswerCorrect,
    required this.onSelect,
  });

  final LearningExercise exercise;
  final String? selectedOption;
  final bool? lastAnswerCorrect;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final optionWidth = availableWidth < 360
            ? availableWidth
            : (availableWidth - AppSpacing.md) / 2;

        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: exercise.options.map((option) {
            final value = option['value'] as String;
            final isSelected = selectedOption == value;
            final isCorrect = _normalizeOption(exercise.correctAnswer) == _normalizeOption(value);
            final color = _answerTone(isSelected, isCorrect, lastAnswerCorrect);

            return SizedBox(
              width: optionWidth,
              child: InkWell(
                onTap: () => onSelect(value),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isSelected ? 0.16 : 0.05),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: color),
                  ),
                  child: Column(
                    children: [
                      Text((option['emoji'] as String?) ?? '✨', style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        option['label'] as String,
                        textAlign: TextAlign.center,
                        style: _bodyStyle(weight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(growable: false),
        );
      },
    );
  }
}

class _ListeningExercise extends StatelessWidget {
  const _ListeningExercise({
    required this.exercise,
    required this.selectedOption,
    required this.lastAnswerCorrect,
    required this.onPlay,
    required this.isPlaying,
    required this.onSelect,
  });

  final LearningExercise exercise;
  final String? selectedOption;
  final bool? lastAnswerCorrect;
  final Future<void> Function() onPlay;
  final bool isPlaying;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: isPlaying ? 0.28 : 0.12),
                blurRadius: isPlaying ? 24 : 12,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: FilledButton.icon(
            onPressed: onPlay,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
            ),
            icon: isPlaying
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.surface),
                  )
                : const Icon(Icons.play_arrow_rounded),
            label: Text(
              isPlaying ? 'Playing...' : 'Play audio',
              style: _bodyStyle(color: AppColors.surface, weight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
          ),
          child: Text(
            'Listen twice if you need to. When a lesson uses local mock content, the coach reads it aloud safely instead of crashing.',
            style: _bodyStyle(color: AppColors.primaryDark, weight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _MultipleChoiceExercise(
          exercise: exercise,
          selectedOption: selectedOption,
          lastAnswerCorrect: lastAnswerCorrect,
          onSelect: onSelect,
        ),
      ],
    );
  }
}

class _MatchingExercise extends StatelessWidget {
  const _MatchingExercise({
    required this.exercise,
    required this.selectedOption,
    required this.lastAnswerCorrect,
    required this.onSelect,
  });

  final LearningExercise exercise;
  final String? selectedOption;
  final bool? lastAnswerCorrect;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: compact ? 0.88 : 0.98,
          children: exercise.options.map((option) {
            final value = option['value'] as String;
            final label = option['label'] as String;
            final badge = (option['emoji'] as String?) ?? '🧩';
            final isSelected = selectedOption == value;
            final isCorrect = _normalizeOption(exercise.correctAnswer) == _normalizeOption(value);
            final color = _answerTone(isSelected, isCorrect, lastAnswerCorrect);

            return InkWell(
              onTap: () => onSelect(value),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isSelected ? 0.16 : 0.05),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: color),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(badge, style: const TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Expanded(
                      child: Center(
                        child: Text(
                          label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: _headingStyle(
                            fontSize: label.length > 7 ? 22 : 26,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: _bodyStyle(color: AppColors.primaryDark, weight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            );
          }).toList(growable: false),
        );
      },
    );
  }
}

class _SpeakingExercise extends StatelessWidget {
  const _SpeakingExercise({
    required this.exercise,
    required this.spokenWords,
    required this.isRecording,
    required this.statusMessage,
    required this.onRecord,
    required this.onSkipSwap,
  });

  final LearningExercise exercise;
  final String spokenWords;
  final bool isRecording;
  final String statusMessage;
  final Future<void> Function() onRecord;
  final Future<void> Function() onSkipSwap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Expected text', style: _headingStyle(fontSize: 18)),
              const SizedBox(height: AppSpacing.sm),
              Text(exercise.expectedSpeech, style: _bodyStyle(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.md),
              Text(
                spokenWords.isEmpty ? 'No recording captured yet.' : 'Captured: $spokenWords',
                style: _bodyStyle(weight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.md),
              _SpeakingPulseIndicator(isRecording: isRecording, hasWords: spokenWords.isNotEmpty),
              if (statusMessage.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isRecording
                        ? AppColors.error.withValues(alpha: 0.12)
                        : AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Text(
                    statusMessage,
                    style: _bodyStyle(
                      color: isRecording ? AppColors.error : AppColors.secondaryDark,
                      weight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: [
                    BoxShadow(
                      color: (isRecording ? AppColors.error : AppColors.secondaryDark).withValues(alpha: 0.24),
                      blurRadius: isRecording ? 24 : 14,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: FilledButton.icon(
                  onPressed: onRecord,
                  style: FilledButton.styleFrom(
                    backgroundColor: isRecording ? AppColors.error : AppColors.secondaryDark,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                  ),
                  icon: Icon(isRecording ? Icons.stop_circle_rounded : Icons.mic_rounded),
                  label: Text(
                    isRecording ? 'Stop recording' : 'Record voice',
                    style: _bodyStyle(color: AppColors.surface, weight: FontWeight.w800),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onSkipSwap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.text,
                  side: const BorderSide(color: AppColors.outline),
                  backgroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                ),
                icon: const Icon(Icons.compare_arrows_rounded),
                label: Text('Skip / Swap', style: _bodyStyle(weight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WritingExercise extends StatelessWidget {
  const _WritingExercise({
    required this.exercise,
    required this.controller,
    required this.onWordTap,
  });

  final LearningExercise exercise;
  final TextEditingController controller;
  final ValueChanged<String> onWordTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          minLines: 2,
          maxLines: 4,
          style: _bodyStyle(),
          decoration: InputDecoration(
            hintText: 'Type your answer here',
            hintStyle: _bodyStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Text('Word bank', style: _headingStyle(fontSize: 18)),
            const Spacer(),
            TextButton.icon(
              onPressed: controller.clear,
              icon: const Icon(Icons.clear_rounded),
              label: Text('Clear', style: _bodyStyle(weight: FontWeight.w800)),
            ),
          ],
        ),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: exercise.options.map((option) {
            final word = option['value'] as String;
            return ActionChip(
              onPressed: () => onWordTap(word),
              backgroundColor: AppColors.surface,
              side: const BorderSide(color: AppColors.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              label: Text(word, style: _bodyStyle(weight: FontWeight.w700)),
            );
          }).toList(growable: false),
        ),
      ],
    );
  }
}

class _CelebrationOverlay extends StatefulWidget {
  const _CelebrationOverlay({
    required this.score,
    required this.xpEarned,
    required this.perfectBonus,
    required this.onReturnHome,
  });

  final double score;
  final int xpEarned;
  final bool perfectBonus;
  final VoidCallback onReturnHome;

  @override
  State<_CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<_CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final motion = _controller.value * math.pi * 2;
        final floatY = (math.sin(motion) * 8).toDouble();
        final sparkleDrift = (math.cos(motion * 1.3) * 10).toDouble();
        final glowPulse = 0.75 + ((math.sin(motion * 1.2) + 1) * 0.12);
        final badgeScale = 1 + ((math.cos(motion * 1.5) + 1) * 0.03);
        final scoreTier = widget.score >= 95
            ? 'Legend Clear'
            : widget.score >= 80
                ? 'Golden Finish'
                : 'Quest Complete';
        final nextUnlock = widget.perfectBonus ? 'Perfect crown unlocked' : 'XP chest opened';

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xCC10203A),
                AppColors.primaryDark.withValues(alpha: 0.88),
                AppColors.secondaryDark.withValues(alpha: 0.82),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 88 + sparkleDrift,
                left: 18,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Positioned(
                top: 110,
                right: 20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.warning.withValues(alpha: 0.14),
                        AppColors.secondary.withValues(alpha: 0.06),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 80 + sparkleDrift,
                left: 24,
                child: _PulseConfettiBar(color: AppColors.warning.withValues(alpha: glowPulse * 0.45)),
              ),
              Positioned(
                bottom: 96 - sparkleDrift,
                right: 28,
                child: _PulseConfettiBar(color: AppColors.secondary.withValues(alpha: glowPulse * 0.45)),
              ),
              Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.84, end: 1),
                  duration: const Duration(milliseconds: 620),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, overlayChild) {
                    return Transform.translate(
                      offset: Offset(0, floatY),
                      child: Transform.scale(scale: scale, child: overlayChild),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.all(AppSpacing.xl),
                    padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, AppSpacing.xl),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.surface,
                          const Color(0xFFF4FBFF),
                          const Color(0xFFFFF7E8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.55), width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x26000000),
                          blurRadius: 28,
                          offset: Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.scale(
                          scale: badgeScale,
                          child: Container(
                            width: 104,
                            height: 104,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.warning,
                                  const Color(0xFFFFD970),
                                  AppColors.secondary,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.warning.withValues(alpha: glowPulse * 0.42),
                                  blurRadius: 28,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.88),
                              ),
                              child: const Icon(
                                Icons.workspace_premium_rounded,
                                size: 52,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text('Lesson Complete!', style: _headingStyle(fontSize: 28)),
                        const SizedBox(height: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                          ),
                          child: Text(
                            scoreTier,
                            style: _bodyStyle(color: AppColors.primaryDark, weight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: _RewardStatCard(
                                title: 'XP Won',
                                value: '${widget.xpEarned}',
                                icon: Icons.bolt_rounded,
                                color: AppColors.secondaryDark,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: _RewardStatCard(
                                title: 'Score',
                                value: '${widget.score.toStringAsFixed(0)}%',
                                icon: Icons.auto_graph_rounded,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _CelebrationMeter(
                          label: 'Score',
                          value: widget.score / 100,
                          caption: '${widget.score.toStringAsFixed(0)}%',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _CelebrationMeter(
                          label: 'XP Rush',
                          value: (widget.xpEarned / 100).clamp(0, 1).toDouble(),
                          caption: '${widget.xpEarned} XP',
                          color: AppColors.secondaryDark,
                        ),
                        if (widget.perfectBonus) ...[
                          const SizedBox(height: AppSpacing.md),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.secondary.withValues(alpha: 0.14),
                                  AppColors.warning.withValues(alpha: 0.12),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified_rounded, color: AppColors.secondaryDark, size: 18),
                                const SizedBox(width: AppSpacing.xs),
                                Text('Perfect bonus applied: +20 XP', style: _bodyStyle(color: AppColors.secondaryDark)),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.stars_rounded, color: AppColors.primaryDark),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(nextUnlock, style: _bodyStyle(weight: FontWeight.w800)),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.perfectBonus
                                          ? 'You finished with full energy and unlocked a stronger reward state.'
                                          : 'Your reward chest is filled. One more lesson makes the streak hotter.',
                                      style: _bodyStyle(color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        FilledButton(
                          onPressed: widget.onReturnHome,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                              vertical: AppSpacing.lg,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                            ),
                          ),
                          child: Text('Return Home', style: _bodyStyle(color: AppColors.surface, weight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RewardStatCard extends StatelessWidget {
  const _RewardStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: _bodyStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(value, style: _headingStyle(fontSize: 22, color: AppColors.text)),
        ],
      ),
    );
  }
}

class _PulseConfettiBar extends StatelessWidget {
  const _PulseConfettiBar({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.55,
      child: Container(
        width: 72,
        height: 14,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: LinearGradient(
            colors: [
              color,
              color.withValues(alpha: 0.18),
            ],
          ),
        ),
      ),
    );
  }
}

Color _answerTone(bool isSelected, bool isCorrect, bool? checkedState) {
  if (checkedState == null) {
    return isSelected ? AppColors.primary : AppColors.outline;
  }
  if (isCorrect) {
    return AppColors.success;
  }
  if (isSelected && !isCorrect) {
    return AppColors.error;
  }
  return AppColors.outline;
}

String _normalizeOption(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
}

Color _colorFromHex(String hex) {
  final normalized = hex.replaceFirst('#', '');
  return Color(int.parse('FF$normalized', radix: 16));
}

TextStyle _headingStyle({
  required double fontSize,
  Color color = AppColors.text,
  FontWeight fontWeight = FontWeight.w700,
}) {
  return GoogleFonts.fredoka(
    fontSize: fontSize,
    color: color,
    fontWeight: fontWeight,
  );
}

TextStyle _bodyStyle({
  Color color = AppColors.text,
  FontWeight weight = FontWeight.w600,
}) {
  return GoogleFonts.nunito(
    fontSize: 14,
    color: color,
    fontWeight: weight,
  );
}


class _StageStatChip extends StatelessWidget {
  const _StageStatChip({
    required this.icon,
    required this.label,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: tone),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: _bodyStyle(color: tone, weight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _ProgressRail extends StatelessWidget {
  const _ProgressRail({
    required this.label,
    required this.value,
    required this.caption,
    required this.color,
  });

  final String label;
  final double value;
  final String caption;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: _bodyStyle(weight: FontWeight.w800)),
            Text(caption, style: _bodyStyle(color: AppColors.textSecondary, weight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: LinearProgressIndicator(
            value: value.clamp(0, 1),
            minHeight: 10,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

String _formatEmotion(String value) {
  return value
      .replaceAll('_', ' ')
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

Color _emotionColor(String emotion) {
  switch (emotion.toLowerCase()) {
    case 'happy':
    case 'joyful':
      return AppColors.success;
    case 'frustrated':
    case 'worried':
      return AppColors.warning;
    case 'confident':
      return AppColors.secondaryDark;
    default:
      return AppColors.primaryDark;
  }
}

class _SpeakingPulseIndicator extends StatelessWidget {
  const _SpeakingPulseIndicator({
    required this.isRecording,
    required this.hasWords,
  });

  final bool isRecording;
  final bool hasWords;

  @override
  Widget build(BuildContext context) {
    final bars = isRecording
        ? const [0.35, 0.9, 0.55, 0.8, 0.45]
        : hasWords
            ? const [0.22, 0.45, 0.28, 0.4, 0.24]
            : const [0.12, 0.18, 0.12, 0.18, 0.12];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: isRecording
            ? AppColors.error.withValues(alpha: 0.08)
            : AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        children: [
          Icon(
            isRecording ? Icons.graphic_eq_rounded : Icons.multitrack_audio_rounded,
            color: isRecording ? AppColors.error : AppColors.primaryDark,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var index = 0; index < bars.length; index++)
                  _PulseBar(
                    heightFactor: bars[index],
                    color: isRecording ? AppColors.error : AppColors.secondaryDark,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseBar extends StatelessWidget {
  const _PulseBar({
    required this.heightFactor,
    required this.color,
  });

  final double heightFactor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.16, end: heightFactor),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: 10,
          height: 34 * value.clamp(0.12, 1.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
        );
      },
    );
  }
}

class _CelebrationMeter extends StatelessWidget {
  const _CelebrationMeter({
    required this.label,
    required this.value,
    required this.caption,
    this.color = AppColors.primary,
  });

  final String label;
  final double value;
  final String caption;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: _bodyStyle(weight: FontWeight.w800)),
            Text(caption, style: _bodyStyle(color: AppColors.textSecondary, weight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: value.clamp(0, 1)),
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeOutCubic,
          builder: (context, progress, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            );
          },
        ),
      ],
    );
  }
}
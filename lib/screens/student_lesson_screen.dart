import 'dart:math' as math;

import 'package:backend_core/backend_core.dart';
import 'package:backend_core/models/character.dart' as app_char;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../widgets/character_display.dart';

class StudentLessonScreen extends StatefulWidget {
  const StudentLessonScreen({
    super.key,
    this.lesson,
    this.lessonTitle,
  });

  final LearningLesson? lesson;
  final String? lessonTitle;

  @override
  State<StudentLessonScreen> createState() => _StudentLessonScreenState();
}

class _StudentLessonScreenState extends State<StudentLessonScreen>
    with TickerProviderStateMixin {
  final LessonService _lessonService = LessonService();
  final ExerciseService _exerciseService = ExerciseService();
  final ProgressService _progressService = ProgressService();
  final EmotionService _emotionService = EmotionService();
  final AudioService _audioService = AudioService();
  final SpeechService _speechService = SpeechService();
  final EnhancedAudioService _enhancedAudioService = EnhancedAudioService();
  final TTSService _ttsService = TTSService();
  final CharacterCoachService _characterCoach = CharacterCoachService();
  final TextEditingController _writingController = TextEditingController();

  app_char.Character? _lessonCharacter;
  String? _characterMessage;

  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isDetectingEmotion = false;
  bool _isPlayingAudio = false;
  bool _isRecordingSpeech = false;
  bool _lessonCompleted = false;
  bool _autoContinueScheduled = false;
  bool _showCelebration = false;
  bool _canJumpToNextChapter = false;
  String? _nextChapterId;
  String? _nextChapterTitle;
  String? _loadError;
  String? _statusMessage;
  String? _audioStatus;
  bool? _lastAnswerCorrect;
  String _selectedEmotion = 'focused';
  String _spokenWords = '';
  bool _isReviewRound = false;
  List<LearningExercise> _exercises = const <LearningExercise>[];
  final Set<String> _completedExerciseIds = <String>{};
  int _currentIndex = 0;
  int? _selectedOption;
  int _mistakeCount = 0;
  int _sessionXp = 0;
  int _perfectBonus = 0;
  double _finalScore = 0;

  late AnimationController _celebrationFadeController;
  late AnimationController _confettiController;

  LearningExercise get _currentExercise => _exercises[_currentIndex];

  @override
  void initState() {
    super.initState();
    _selectedEmotion = context.read<UserProvider>().currentEmotion;
    _lessonCharacter = app_char.Characters.lumi;
    _celebrationFadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _loadLessonData();
  }

  @override
  void dispose() {
    _speechService.stopListening();
    _audioService.dispose();
    _enhancedAudioService.stopAll();
    _writingController.dispose();
    _ttsService.stop();
    _celebrationFadeController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadLessonData() async {
    try {
      final userProvider = context.read<UserProvider>();
      await _speechService.initialize();
      await _enhancedAudioService.initialize();
      await _ttsService.initialize();

      if (widget.lesson == null) {
        if (mounted) {
          setState(() {
            _loadError = 'Lesson data not available';
            _isLoading = false;
          });
        }
        return;
      }
      
      final exercises =
          await _exerciseService.getExercisesByLesson(widget.lesson!.id);
      final lessonProgress = userProvider.currentUserId == null
          ? null
          : await _progressService.getProgressForLesson(
              userProvider.currentUserId!,
              widget.lesson!.id,
            );

      if (!mounted) {
        return;
      }

      setState(() {
        _exercises = exercises;
        _sessionXp = lessonProgress?.xpEarned ?? 0;
        _perfectBonus =
            lessonProgress != null && lessonProgress.score == 100 ? 20 : 0;
        _finalScore = lessonProgress?.score ?? 0;
        _mistakeCount =
            lessonProgress != null && lessonProgress.score < 100 ? 1 : 0;
        if (lessonProgress != null) {
          _completedExerciseIds.addAll(lessonProgress.completedExerciseIds);
          _lessonCompleted = lessonProgress.completed;
        }
        final firstPendingIndex = exercises.indexWhere(
          (item) => !_completedExerciseIds.contains(item.id),
        );
        _currentIndex = firstPendingIndex >= 0 ? firstPendingIndex : 0;
        _isLoading = false;
      });

      if (exercises.isNotEmpty) {
        _showPromptForCurrentExercise(speak: true);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadError = error.toString();
        _isLoading = false;
      });
    }
  }

  void _applyReaction(CharacterReaction reaction) {
    _lessonCharacter = reaction.character;
    _characterMessage = reaction.message;
  }

  Future<void> _voiceReaction(CharacterReaction reaction) async {
    await _ttsService.stop();
    await _ttsService.speakCharacterMessage(
      reaction.message,
      character: reaction.character,
    );
  }

  Future<void> _voiceAnswerReaction(
    CharacterReaction reaction, {
    required bool isCorrect,
  }) async {
    await _ttsService.stop();
    await _ttsService.speakAnswerFeedback(
      reaction.message,
      character: reaction.character,
      isCorrect: isCorrect,
    );
  }

  void _showPromptForCurrentExercise({bool speak = false}) {
    if (_exercises.isEmpty || !mounted) {
      return;
    }

    final reaction = _characterCoach.lessonPrompt(
      exerciseType: _currentExercise.type,
      questionIndex: _currentIndex,
      totalQuestions: _exercises.length,
    );

    setState(() {
      _applyReaction(reaction);
    });

    if (speak) {
      _voiceReaction(reaction);
    }
  }

  Future<void> _simulateEmotionDetection() async {
    if (_isDetectingEmotion) {
      return;
    }

    _audioService.playTap();

    setState(() {
      _isDetectingEmotion = true;
      _statusMessage = 'Checking your learning mood...';
    });

    final detectedEmotion = await _emotionService.analyzeEmotionFromVoice();
    if (!mounted) {
      return;
    }

    setState(() {
      _isDetectingEmotion = false;
      _selectedEmotion = detectedEmotion;
      _statusMessage = 'Mood detected: ${_titleCase(detectedEmotion)}';
    });
  }

  Future<void> _playExerciseAudio() async {
    final exercise = _currentExercise;
    if (_isPlayingAudio) {
      await _audioService.stop();
      if (!mounted) {
        return;
      }
      _audioService.playTap();
      setState(() {
        _isPlayingAudio = false;
        _audioStatus = 'Audio stopped.';
      });
      return;
    }

    _audioService.playTap();

    setState(() {
      _isPlayingAudio = true;
      _audioStatus = 'Playing audio prompt...';
    });

    try {
      if (exercise.audioUrl.isNotEmpty) {
        await _audioService.play(url: exercise.audioUrl);
      } else {
        await _ttsService.speakNarratorText(_exercisePromptText(exercise));
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _audioStatus = 'Listen carefully, then answer.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _audioStatus = 'Audio unavailable right now: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPlayingAudio = false;
        });
      }
    }
  }

  String _exercisePromptText(LearningExercise exercise) {
    if (exercise.audioPrompt.isNotEmpty) {
      return exercise.audioPrompt;
    }
    if (exercise.type == 'speaking' && exercise.expectedSpeech.isNotEmpty) {
      return exercise.expectedSpeech;
    }
    if (exercise.type == 'writing' && exercise.correctAnswer.isNotEmpty) {
      return exercise.correctAnswer;
    }
    return exercise.question;
  }

  Future<void> _speakQuestionPrompt() async {
    if (_exercises.isEmpty) {
      return;
    }
    setState(() {
      _audioStatus = 'Narrator is reading the prompt...';
    });
    await _ttsService.speakNarratorText(_exercisePromptText(_currentExercise));
    if (!mounted) {
      return;
    }
    setState(() {
      _audioStatus = 'Prompt played.';
    });
  }

  Future<void> _toggleSpeechRecording() async {
    // Prevent multiple simultaneous calls
    if (_isRecordingSpeech || _speechService.isListening || _speechService.isStarting) {
      return;
    }

    // Stopping current recording
    if (_isRecordingSpeech) {
      _speechService.stopListening();
      if (!mounted) {
        return;
      }
      _audioService.playTap();
      setState(() {
        _isRecordingSpeech = false;
        _statusMessage = _spokenWords.isEmpty
            ? 'Recording stopped. Tap again if you want another try.'
            : 'Great. Now check your answer.';
      });
      return;
    }

    // Starting new recording
    setState(() {
      _spokenWords = '';
      _isRecordingSpeech = true;
      _statusMessage = 'Recording... Use your brave voice.';
    });

    _audioService.playTap();

    try {
      // Complete cleanup first - ensure absolutely fresh state
      _speechService.stopListening();
      await Future.delayed(const Duration(milliseconds: 300)); // Give microphone time to settle

      // Final safety check - don't start if another request came in
      if (!mounted || !_isRecordingSpeech) {
        _speechService.stopListening();
        return;
      }

      final started = await _speechService.startListening(
        onResult: (words) {
          if (!mounted || !_isRecordingSpeech) {
            return;
          }
          setState(() {
            _spokenWords = words;
          });
        },
        onError: (error) {
          if (!mounted) {
            return;
          }
          setState(() {
            _isRecordingSpeech = false;
            _statusMessage = error;
          });
          _speechService.stopListening(); // Ensure cleanup on error
        },
      );

      if (!mounted) {
        _speechService.stopListening();
        return;
      }

      if (!started) {
        setState(() {
          _isRecordingSpeech = false;
          _statusMessage =
              _speechService.lastError ?? 'Microphone is not ready yet. Please check permissions.';
        });
        _speechService.stopListening(); // Cleanup on failed start
        return;
      }

      // Auto-stop after 6 seconds if still recording
      Future.delayed(const Duration(seconds: 6), () {
        if (!mounted || !_isRecordingSpeech) {
          return;
        }
        
        // Stop listening when time is up
        _speechService.stopListening();
        
        if (!mounted) {
          return;
        }
        
        setState(() {
          _isRecordingSpeech = false;
          _statusMessage = _spokenWords.isEmpty
              ? 'No voice captured. Tap to try again.'
              : 'Recording finished. Check your answer.';
        });
      });
    } catch (e) {
      // Handle any errors - always cleanup
      _speechService.stopListening();
      if (mounted) {
        setState(() {
          _isRecordingSpeech = false;
          _statusMessage = 'Recording error: ${e.toString()}. Please try again.';
        });
      }
    }
  }

  Future<void> _submitAnswer() async {
    if (_exercises.isEmpty || _isSubmitting) {
      return;
    }

    final exercise = _currentExercise;
    var updatedMistakes = _mistakeCount;
    bool isCorrect;
    CharacterReaction reaction = _characterCoach.lessonPrompt(
      exerciseType: exercise.type,
      questionIndex: _currentIndex,
      totalQuestions: _exercises.length,
    );

    if (exercise.type == 'speaking') {
      if (_spokenWords.trim().isEmpty) {
        reaction = _characterCoach.lessonPrompt(
          exerciseType: exercise.type,
          questionIndex: _currentIndex,
          totalQuestions: _exercises.length,
        );
        setState(() {
          _lastAnswerCorrect = false;
          _statusMessage = 'Tap the microphone and say the sentence first.';
          _applyReaction(reaction);
        });
        await _voiceAnswerReaction(reaction, isCorrect: false);
        return;
      }
      isCorrect = _validateSpeechAttempt(_spokenWords, exercise.expectedSpeech);
      if (!isCorrect) {
        updatedMistakes++;
        reaction = _characterCoach.answerReaction(
          isCorrect: false,
          exerciseType: exercise.type,
          isFirstChance: updatedMistakes == 1,
          lessonCompleted: false,
          perfectLesson: false,
        );
        _enhancedAudioService.playWrong();
        setState(() {
          _mistakeCount = updatedMistakes;
          _lastAnswerCorrect = false;
          _statusMessage =
              'We will revisit this speaking task in the mistake review at the end.';
          _applyReaction(reaction);
        });
        await _voiceAnswerReaction(reaction, isCorrect: false);
        return;
      }
    } else if (exercise.type == 'writing') {
      if (_writingController.text.trim().isEmpty) {
        reaction = _characterCoach.lessonPrompt(
          exerciseType: exercise.type,
          questionIndex: _currentIndex,
          totalQuestions: _exercises.length,
        );
        setState(() {
          _lastAnswerCorrect = false;
          _statusMessage = 'Type your answer first.';
          _applyReaction(reaction);
        });
        await _voiceAnswerReaction(reaction, isCorrect: false);
        return;
      }
      isCorrect = _validateWritingAttempt(_writingController.text, exercise);
      if (!isCorrect) {
        updatedMistakes++;
        reaction = _characterCoach.answerReaction(
          isCorrect: false,
          exerciseType: exercise.type,
          isFirstChance: updatedMistakes == 1,
          lessonCompleted: false,
          perfectLesson: false,
        );
        _enhancedAudioService.playWrong();
        setState(() {
          _mistakeCount = updatedMistakes;
          _lastAnswerCorrect = false;
          _statusMessage =
              'Saved for mistake review. You will fix this writing task before finishing.';
          _applyReaction(reaction);
        });
        await _voiceReaction(reaction);
        return;
      }
    } else {
      if (_selectedOption == null ||
          _selectedOption! >= exercise.options.length) {
        return;
      }
      final selected = exercise.options[_selectedOption!];
      isCorrect = selected['isCorrect'] == true;
      if (!isCorrect) {
        updatedMistakes++;
        reaction = _characterCoach.answerReaction(
          isCorrect: false,
          exerciseType: exercise.type,
          isFirstChance: updatedMistakes == 1,
          lessonCompleted: false,
          perfectLesson: false,
        );
        _enhancedAudioService.playWrong();
        setState(() {
          _mistakeCount = updatedMistakes;
          _lastAnswerCorrect = false;
          _statusMessage =
              'Not quite yet. We saved this one for the mistake review round.';
          _applyReaction(reaction);
        });
        await _voiceReaction(reaction);
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final updatedCompletedIds = <String>{
        ..._completedExerciseIds,
        exercise.id,
      }.toList();
      final lessonCompleted = updatedCompletedIds.length == _exercises.length;
      final score = _calculateScore(updatedMistakes);
      final perfectBonus = lessonCompleted && updatedMistakes == 0 ? 20 : 0;
      final gainedXp = exercise.xpReward + (lessonCompleted ? perfectBonus : 0);
      final updatedSessionXp = _sessionXp + gainedXp;
      final userProvider = context.read<UserProvider>();
      final userId = userProvider.currentUserId;
      reaction = _characterCoach.answerReaction(
        isCorrect: true,
        exerciseType: exercise.type,
        isFirstChance: updatedMistakes == _mistakeCount,
        lessonCompleted: lessonCompleted,
        perfectLesson: lessonCompleted && perfectBonus > 0,
      );

      // Play enhanced sound effects
      _enhancedAudioService.playCorrect();
      _enhancedAudioService.playXP();
      if (lessonCompleted) {
        _enhancedAudioService.playCelebrate();
        _enhancedAudioService.playUnlock();
      }

      if (userId != null && widget.lesson != null) {
        await _progressService.saveProgress(
          userId: userId,
          lessonId: widget.lesson!.id,
          completed: lessonCompleted,
          score: score,
          xpEarned: updatedSessionXp,
          completedExerciseIds: updatedCompletedIds,
        );
        await _emotionService.saveEmotion(userId, _selectedEmotion, 0.88);
      }

      userProvider.addXP(gainedXp);
      userProvider.updateEmotion(_selectedEmotion);
      if (lessonCompleted) {
        userProvider.incrementStreak();
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _completedExerciseIds
          ..clear()
          ..addAll(updatedCompletedIds);
        _lessonCompleted = lessonCompleted;
        _lastAnswerCorrect = true;
        _mistakeCount = updatedMistakes;
        _sessionXp = updatedSessionXp;
        _perfectBonus = lessonCompleted ? perfectBonus : _perfectBonus;
        _finalScore = score;
        _isReviewRound = false;
        _statusMessage = lessonCompleted && perfectBonus > 0
            ? 'Perfect! You earned +$gainedXp XP with a bonus.'
            : 'Correct! +${exercise.xpReward} XP earned.';
        _applyReaction(reaction);
        if (lessonCompleted) {
          _showCelebration = true;
        }
      });

      await _voiceAnswerReaction(reaction, isCorrect: true);

      if (lessonCompleted && mounted) {
        await _checkAndSetupNextChapterJump();
        _celebrationFadeController.forward();
        _confettiController.forward();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  double _calculateScore(int mistakes) {
    final safeExercises = _exercises.isEmpty ? 1 : _exercises.length;
    final score = ((safeExercises - mistakes) / safeExercises) * 100;
    return score.clamp(0, 100).toDouble();
  }

  bool _validateSpeechAttempt(String transcript, String expectedSpeech) {
    final normalizedTranscript = _normalizeSpeech(transcript);
    final normalizedExpected = _normalizeSpeech(expectedSpeech);
    if (normalizedTranscript.isEmpty || normalizedExpected.isEmpty) {
      return normalizedTranscript.isNotEmpty;
    }

    if (normalizedTranscript.contains(normalizedExpected)) {
      return true;
    }

    final expectedTokens = normalizedExpected.split(' ');
    var matchedTokens = 0;
    for (final token in expectedTokens) {
      if (token.isEmpty) {
        continue;
      }
      if (normalizedTranscript.contains(token)) {
        matchedTokens++;
      }
    }
    return matchedTokens >= math.max(1, expectedTokens.length ~/ 2);
  }

  bool _validateWritingAttempt(
    String attempt,
    LearningExercise exercise,
  ) {
    final normalizedAttempt = _normalizeSpeech(attempt);
    final targetSource = exercise.correctAnswer.isNotEmpty
        ? exercise.correctAnswer
        : exercise.expectedSpeech;
    final normalizedTarget = _normalizeSpeech(targetSource);

    if (normalizedAttempt.isEmpty || normalizedTarget.isEmpty) {
      return normalizedAttempt.isNotEmpty;
    }

    if (normalizedAttempt == normalizedTarget ||
        normalizedAttempt.contains(normalizedTarget) ||
        normalizedTarget.contains(normalizedAttempt)) {
      return true;
    }

    final targetTokens = normalizedTarget.split(' ');
    var matchedTokens = 0;
    for (final token in targetTokens) {
      if (token.isEmpty) {
        continue;
      }
      if (normalizedAttempt.contains(token)) {
        matchedTokens++;
      }
    }

    return matchedTokens >= math.max(1, (targetTokens.length * 0.7).ceil());
  }

  String _normalizeSpeech(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<void> _goToNextLesson() async {
    // Simply return to home screen after lesson completion
    // Home screen will refresh and unlock next lesson
    if (mounted) {
      Navigator.pop(context);
    }
  }

  /// Check if current lesson is the first lesson of its chapter, 
  /// and if so, find the next chapter
  Future<void> _checkAndSetupNextChapterJump() async {
    try {
      if (widget.lesson == null) return;
      
      // Get all chapters and lessons
      final chapters = await _lessonService.getChapters();
      final allLessons = await _lessonService.getLessons();
      
      LearningChapter? currentChapter;
      try {
        currentChapter = chapters.firstWhere(
          (c) => c.id == widget.lesson!.chapterId,
        );
      } catch (e) {
        return;
      }
      
      if (currentChapter == null) return;
      
      // Get all lessons in current chapter, sorted by order
      final currentChapterLessons = allLessons
          .where((l) => l.chapterId == currentChapter!.id)
          .toList();
      currentChapterLessons.sort((a, b) => a.order.compareTo(b.order));
      
      // Check if current lesson is the first lesson
      if (currentChapterLessons.isNotEmpty && 
          currentChapterLessons.first.id == widget.lesson!.id) {
        
        // Find the next chapter
        final currentChapterIndex = chapters.indexWhere(
          (c) => c.id == currentChapter!.id,
        );
        
        if (currentChapterIndex >= 0 && 
            currentChapterIndex + 1 < chapters.length) {
          final nextChapter = chapters[currentChapterIndex + 1];
          setState(() {
            _canJumpToNextChapter = true;
            _nextChapterId = nextChapter.id;
            _nextChapterTitle = nextChapter.title;
          });
          
          debugPrint('✨ Jump to next chapter available: ${nextChapter.title}');
        }
      }
    } catch (e) {
      debugPrint('Error checking next chapter: $e');
    }
  }

  /// Jump to the first lesson of the next chapter
  Future<void> _jumpToNextChapter() async {
    if (_nextChapterId == null) return;
    
    // Show mini-test first
    if (mounted) {
      final passed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _MiniTestDialog(
          nextChapterTitle: _nextChapterTitle ?? 'Next Chapter',
          onPassed: () {
            Navigator.pop(ctx, true);
          },
        ),
      );

      if (passed != true) return;
    }
    
    try {
      final allLessons = await _lessonService.getLessons();
      final nextChapterLessons = allLessons
          .where((l) => l.chapterId == _nextChapterId)
          .toList();
      nextChapterLessons.sort((a, b) => a.order.compareTo(b.order));
      
      if (nextChapterLessons.isNotEmpty) {
        final firstLesson = nextChapterLessons.first;
        
        if (mounted) {
          // Close celebration
          _celebrationFadeController.reverse();
          
          // Navigate to next chapter's first lesson
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (ctx) => StudentLessonScreen(
                    lesson: firstLesson,
                    lessonTitle: firstLesson.title,
                  ),
                ),
              );
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error jumping to next chapter: $e');
    }
  }

  void _nextStep() {
    if (_lastAnswerCorrect == false) {
      _moveToNextPendingExercise();
      return;
    }

    _moveToNextPendingExercise();
  }

  int? _findNextPendingExerciseIndex() {
    if (_exercises.isEmpty) {
      return null;
    }

    for (var index = _currentIndex + 1; index < _exercises.length; index++) {
      if (!_completedExerciseIds.contains(_exercises[index].id)) {
        return index;
      }
    }

    for (var index = 0; index <= _currentIndex; index++) {
      if (!_completedExerciseIds.contains(_exercises[index].id)) {
        return index;
      }
    }

    return null;
  }

  void _moveToNextPendingExercise() {
    final nextIndex = _findNextPendingExerciseIndex();
    if (nextIndex == null) {
      return;
    }

    final enteringReview = nextIndex <= _currentIndex;
    setState(() {
      _currentIndex = nextIndex;
      _selectedOption = null;
      _lastAnswerCorrect = null;
      _spokenWords = '';
      _writingController.clear();
      _audioStatus = null;
      _isReviewRound = enteringReview;
      _statusMessage = enteringReview
          ? 'Mistake review time. Let\'s fix the tricky ones together.'
          : null;
    });
    _showPromptForCurrentExercise(speak: true);
  }

  /// Show skip options for speaking exercises - can skip to next or swap to multichoice
  void _showSkipDialog() {
    if (_exercises.isEmpty) return;

    final exercise = _currentExercise;
    if (exercise.type != 'speaking') {
      _skipCurrentExercise();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Skip or Switch?',
          style: GoogleFonts.fredoka(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'You can skip to the next activity or switch this to a multiple choice question instead.',
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 1.5,
          ),
        ),
        actions: <Widget>[
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Keep Trying',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _skipCurrentExercise();
            },
            child: Text(
              'Skip This',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _swapSpeakingToMultipleChoice();
            },
            child: Text(
              'Switch to Multiple Choice',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  void _swapSpeakingToMultipleChoice() {
    if (_exercises.isEmpty) {
      return;
    }

    final currentExercise = _currentExercise;
    final mockMultiChoice = LearningExercise(
      id: '${currentExercise.id}_multichoice',
      lessonId: currentExercise.lessonId,
      type: 'multipleChoice',
      question: currentExercise.question,
      questionArabic: currentExercise.questionArabic,
      expectedSpeech: currentExercise.expectedSpeech,
      explanation: 'Great choice!',
      xpReward: currentExercise.xpReward - 5,
      options: <Map<String, dynamic>>[
        {
          'text': currentExercise.expectedSpeech,
          'textArabic': 'Correct answer',
          'imageKey': 'check',
          'isCorrect': true,
        },
        {
          'text': 'Try another option',
          'textArabic': 'Another option',
          'imageKey': 'close',
          'isCorrect': false,
        },
        {
          'text': 'Not sure',
          'textArabic': 'Need help',
          'imageKey': 'help',
          'isCorrect': false,
        },
      ],
    );
    final reaction = _characterCoach.lessonPrompt(
      exerciseType: 'multipleChoice',
      questionIndex: _currentIndex,
      totalQuestions: _exercises.length,
    );

    setState(() {
      _exercises[_currentIndex] = mockMultiChoice;
      _spokenWords = '';
      _writingController.clear();
      _selectedOption = null;
      _lastAnswerCorrect = null;
      _statusMessage = 'Switched to multiple choice. Choose the correct answer.';
      _applyReaction(reaction);
    });

    _audioService.playTap();
  }

  void _skipCurrentExercise() {
    if (_exercises.isEmpty) {
      return;
    }

    if (_currentIndex + 1 >= _exercises.length) {
      if (!_autoContinueScheduled) {
        _autoContinueScheduled = true;
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) {
            return;
          }
          _goToNextLesson();
        });
      }
      setState(() {
        _lessonCompleted = true;
      });
      return;
    }

    setState(() {
      _currentIndex++;
      _selectedOption = null;
      _statusMessage = null;
      _lastAnswerCorrect = null;
      _spokenWords = '';
      _writingController.clear();
      _audioStatus = null;
    });
    _showPromptForCurrentExercise(speak: true);
  }

  /// Convert speaking exercise to multiple choice by swapping in a multichoice version
  void _swapToMultipleChoice() {
    if (_exercises.isEmpty) return;
    
    final currentExercise = _currentExercise;
    
    // Create a mock multiple choice version of the speaking exercise
    // Using the expected speech as the correct answer
    final mockMultiChoice = LearningExercise(
      id: '${currentExercise.id}_multichoice',
      lessonId: currentExercise.lessonId,
      type: 'multipleChoice',
      question: currentExercise.question,
      questionArabic: currentExercise.questionArabic,
      expectedSpeech: currentExercise.expectedSpeech,
      explanation: 'Great choice!',
      xpReward: currentExercise.xpReward - 5, // Slight penalty for swapping
      options: <Map<String, dynamic>>[
        {
          'text': currentExercise.expectedSpeech,
          'textArabic': 'الإجابة الصحيحة',
          'imageKey': 'check',
          'isCorrect': true,
        },
        {
          'text': 'Try another option',
          'textArabic': 'خيار آخر',
          'imageKey': 'close',
          'isCorrect': false,
        },
        {
          'text': 'Not sure',
          'textArabic': 'لا أعرف',
          'imageKey': 'help',
          'isCorrect': false,
        },
      ],
    );

    setState(() {
      _exercises[_currentIndex] = mockMultiChoice;
      _spokenWords = '';
      _selectedOption = null;
      _lastAnswerCorrect = null;
      _statusMessage = '📝 Switched to multiple choice. Choose the correct answer!';
      _characterMessage = _lessonCharacter?.getMotivationalMessage(lastAction: 'lesson_start') ?? '';
    });

    // Play sound effect
    _audioService.playTap();
  }

  /// Skip the current exercise and move to the next one
  /// This allows testing the app without completing voice exercises
  void _skipExercise() {
    if (_exercises.isEmpty) {
      return;
    }

    // Check if this is the last exercise
    if (_currentIndex + 1 >= _exercises.length) {
      if (!_autoContinueScheduled) {
        _autoContinueScheduled = true;
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          _goToNextLesson();
        });
      }
      setState(() {
        _lessonCompleted = true;
      });
      return;
    }

    // Move to next exercise
    setState(() {
      _currentIndex++;
      _selectedOption = null;
      _statusMessage = null;
      _lastAnswerCorrect = null;
      _characterMessage = null;
      _spokenWords = '';
      _audioStatus = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFF0F4C5C),
              Color(0xFF1FA2A6),
              Color(0xFFF4F7F8),
            ],
            stops: <double>[0.0, 0.25, 0.25],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _loadError != null
                  ? _LessonError(error: _loadError!)
                  : _exercises.isEmpty
                      ? const _LessonError(
                          error: 'No exercises found for this lesson yet.',
                        )
                      : _lessonCompleted && _showCelebration
                          ? Stack(
                              children: <Widget>[
                                _buildExerciseView(),
                                _CelebrationOverlay(
                                  fadeAnimation: _celebrationFadeController,
                                  confettiAnimation: _confettiController,
                                  xpEarned: _sessionXp,
                                isPerfect: _perfectBonus > 0,
                                canJumpToNextChapter: _canJumpToNextChapter,
                                nextChapterTitle: _nextChapterTitle,
                                onJumpToNextChapter: _jumpToNextChapter,
                                onContinue: _goToNextLesson,
                              ),
                              ],
                            )
                          : _lessonCompleted
                              ? _LessonCompleteView(
                                  lessonTitle: widget.lesson?.title ?? widget.lessonTitle ?? 'Lesson',
                                  totalExercises: _exercises.length,
                                  totalXp: _sessionXp,
                                  score: _finalScore,
                                  perfectBonus: _perfectBonus,
                                  onContinue: _goToNextLesson,
                                )
                              : _buildExerciseView(),
        ),
      ),
    );
  }

  Widget _buildExerciseView() {
    final exercise = _currentExercise;
    final progressValue =
        (_completedExerciseIds.length / _exercises.length).clamp(0.0, 1.0);
    final responseColor = _lastAnswerCorrect == true
        ? const Color(0xFFF2FBF6)
        : _lastAnswerCorrect == false
            ? const Color(0xFFFFF6F2)
            : Colors.white;
    final activeCharacter = _lessonCharacter;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: <Widget>[
        Row(
          children: <Widget>[
            _LessonTopAction(
              onPressed: () => Navigator.pop(context),
              icon: Icons.close_rounded,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progressValue,
                  minHeight: 12,
                  backgroundColor: const Color(0xFFE2E8EE),
                  color: _lastAnswerCorrect == false
                      ? const Color(0xFFE76F51)
                      : const Color(0xFF58CC6A),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _LessonHeartBadge(correctness: _lastAnswerCorrect),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                widget.lesson?.title ?? widget.lessonTitle ?? 'Lesson',
                style: GoogleFonts.fredoka(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF16324F),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            AnimatedScale(
              scale: _lastAnswerCorrect == true ? 1.06 : 1,
              duration: const Duration(milliseconds: 180),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD95D),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$_sessionXp XP',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF8A4B00),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _CompactLessonCoach(
          character: activeCharacter,
          message: _characterMessage ?? _mascotMessage(exercise.type),
          isReviewRound: _isReviewRound,
        ),
        const SizedBox(height: 16),
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
          decoration: BoxDecoration(
            color: responseColor,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: _lastAnswerCorrect == true
                  ? const Color(0xFFCBEED6)
                  : _lastAnswerCorrect == false
                      ? const Color(0xFFF7D1C6)
                      : const Color(0xFFD9E5EC),
              width: 1.5,
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x16000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    _isReviewRound
                        ? 'Mistake review'
                        : 'Question ${_currentIndex + 1} of ${_exercises.length}',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF607D8B),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9F7F2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${widget.lesson?.level ?? 'A1'} - easy',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A936F),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                exercise.question,
                style: GoogleFonts.fredoka(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF16324F),
                ),
              ),
              if (exercise.questionArabic.isNotEmpty) ...<Widget>[
                const SizedBox(height: 6),
                Text(
                  exercise.questionArabic,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF607D8B),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: _speakQuestionPrompt,
                    icon: const Icon(Icons.record_voice_over_rounded),
                    label: Text(
                      'Hear narrator',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
                    ),
                  ),
                  if (_isReviewRound)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7E6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Fixing earlier mistakes',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFD4931B),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              _ExerciseTypePill(type: exercise.type),
              const SizedBox(height: 16),
              _buildExerciseInteraction(exercise),
              const SizedBox(height: 18),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _statusMessage == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: _FeedbackCard(
                          key: ValueKey<String>(_statusMessage!),
                          message: _statusMessage!,
                          explanation: _lastAnswerCorrect == true
                              ? exercise.explanation
                              : 'Pause, listen again, and try one more time.',
                          isCorrect: _lastAnswerCorrect ?? false,
                        ),
                      ),
              ),
              const SizedBox(height: 18),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: _lastAnswerCorrect != null
                    ? const EdgeInsets.all(16)
                    : EdgeInsets.zero,
                decoration: _lastAnswerCorrect != null
                    ? BoxDecoration(
                        color: _lastAnswerCorrect == true
                            ? const Color(0xFFE9F7F2)
                            : const Color(0xFFFFF0EC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _lastAnswerCorrect == true
                              ? const Color(0xFF1A936F)
                              : const Color(0xFFE76F51),
                          width: 2,
                        ),
                      )
                    : null,
                child: _lastAnswerCorrect != null
                    ? Row(
                        children: <Widget>[
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _lastAnswerCorrect == true
                                  ? const Color(0xFF1A936F)
                                  : const Color(0xFFE76F51),
                            ),
                            child: Icon(
                              _lastAnswerCorrect == true
                                  ? Icons.check_rounded
                                  : Icons.close_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  _lastAnswerCorrect == true
                                      ? 'Great job!'
                                      : 'Try again!',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: _lastAnswerCorrect == true
                                        ? const Color(0xFF1A936F)
                                        : const Color(0xFFE76F51),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _lastAnswerCorrect == true
                                      ? 'Excellent answer!'
                                      : 'Give it another go.',
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF607D8B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 22),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canCheckAnswer(exercise) && !_isSubmitting
                          ? () {
                              _audioService.playTap();
                              _submitAnswer();
                            }
                          : null,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2.2),
                            )
                          : Text(
                              _checkButtonLabel(exercise),
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _lastAnswerCorrect == null
                          ? null
                          : () {
                              _audioService.playTap();
                              _nextStep();
                            },
                      child: Text(
                        _lastAnswerCorrect == true
                            ? 'Next challenge'
                            : 'Keep going',
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseInteraction(LearningExercise exercise) {
    switch (exercise.type) {
      case 'listening':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _ActionBanner(
              title: 'Listening game',
              subtitle:
                  _audioStatus ?? 'Tap play, listen to the word, then choose.',
              icon: Icons.volume_up_rounded,
              actionLabel: _isPlayingAudio ? 'Playing...' : 'Play sound',
              onAction: _playExerciseAudio,
            ),
            const SizedBox(height: 18),
            ...List.generate(
              exercise.options.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AnswerCard(
                  label: exercise.options[index]['text'] as String? ?? '',
                  subtitle:
                      exercise.options[index]['textArabic'] as String? ?? '',
                  imageKey:
                      exercise.options[index]['imageKey'] as String? ?? '',
                  isSelected: _selectedOption == index,
                  isLocked: _isSubmitting,
                  isCorrect:
                      _lastAnswerCorrect == true && _selectedOption == index,
                  isWrongSelection:
                      _lastAnswerCorrect == false && _selectedOption == index,
                  onTap: () {
                    _audioService.playTap();
                    setState(() {
                      _selectedOption = index;
                    });
                  },
                ),
              ),
            ),
          ],
        );
      case 'matching':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Choose the picture card that matches the word.',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF607D8B),
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: exercise.options.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.08,
              ),
              itemBuilder: (context, index) {
                return _PictureChoiceCard(
                  label: exercise.options[index]['text'] as String? ?? '',
                  subtitle:
                      exercise.options[index]['textArabic'] as String? ?? '',
                  imageKey:
                      exercise.options[index]['imageKey'] as String? ?? '',
                  isSelected: _selectedOption == index,
                  isLocked: _isSubmitting,
                  isCorrect:
                      _lastAnswerCorrect == true && _selectedOption == index,
                  isWrongSelection:
                      _lastAnswerCorrect == false && _selectedOption == index,
                  onTap: () {
                    _audioService.playTap();
                    setState(() {
                      _selectedOption = index;
                    });
                  },
                );
              },
            ),
          ],
        );
      case 'speaking':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _ActionBanner(
              title: 'Speaking game',
              subtitle: _spokenWords.isEmpty
                  ? 'Listen to the model, then tap the microphone and speak.'
                  : 'We heard: "$_spokenWords"',
              icon: Icons.record_voice_over_rounded,
              actionLabel: _isPlayingAudio ? 'Playing...' : 'Hear the sentence',
              onAction: _playExerciseAudio,
            ),
            const SizedBox(height: 16),
            _SpeakingRecorderCard(
              isRecording: _isRecordingSpeech,
              transcript: _spokenWords,
              expectedSpeech: exercise.expectedSpeech,
              onTap: _toggleSpeechRecording,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _showSkipDialog,
              icon: const Icon(Icons.skip_next_rounded),
              label: const Text('Skip or swap'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ],
        );
      case 'writing':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _ActionBanner(
              title: 'Writing game',
              subtitle:
                  'Type the answer carefully, then check it with Nexo.',
              icon: Icons.edit_rounded,
              actionLabel: 'Clear',
              onAction: () {
                _audioService.playTap();
                setState(() {
                  _writingController.clear();
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _writingController,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type your answer here',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: const BorderSide(
                    color: Color(0xFFD7E5EC),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: const BorderSide(
                    color: Color(0xFFD7E5EC),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: const BorderSide(
                    color: Color(0xFF0E7C86),
                    width: 2,
                  ),
                ),
              ),
              onChanged: (_) {
                setState(() {
                  if (_lastAnswerCorrect != null) {
                    _lastAnswerCorrect = null;
                  }
                });
              },
            ),
            if (exercise.correctAnswer.isNotEmpty) ...<Widget>[
              const SizedBox(height: 10),
              Text(
                'Hint: think about the exact words you heard or learned.',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF607D8B),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _wordBankFor(exercise).map((word) {
                  return ActionChip(
                    label: Text(word),
                    onPressed: () {
                      final current = _writingController.text.trim();
                      final nextText = current.isEmpty ? word : '$current $word';
                      setState(() {
                        _writingController.text = nextText;
                        _writingController.selection = TextSelection.collapsed(
                          offset: _writingController.text.length,
                        );
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        );
      case 'multipleChoice':
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ...List.generate(
              exercise.options.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AnswerCard(
                  label: exercise.options[index]['text'] as String? ?? '',
                  subtitle:
                      exercise.options[index]['textArabic'] as String? ?? '',
                  imageKey:
                      exercise.options[index]['imageKey'] as String? ?? '',
                  isSelected: _selectedOption == index,
                  isLocked: _isSubmitting,
                  isCorrect:
                      _lastAnswerCorrect == true && _selectedOption == index,
                  isWrongSelection:
                      _lastAnswerCorrect == false && _selectedOption == index,
                  onTap: () {
                    _audioService.playTap();
                    setState(() {
                      _selectedOption = index;
                    });
                  },
                ),
              ),
            ),
          ],
        );
    }
  }

  bool _canCheckAnswer(LearningExercise exercise) {
    if (exercise.type == 'speaking') {
      return _spokenWords.trim().isNotEmpty;
    }
    if (exercise.type == 'writing') {
      return _writingController.text.trim().isNotEmpty;
    }
    return _selectedOption != null;
  }

  String _checkButtonLabel(LearningExercise exercise) {
    switch (exercise.type) {
      case 'speaking':
        return 'Check speaking';
      case 'writing':
        return 'Check writing';
      case 'listening':
        return 'Check listening';
      case 'matching':
        return 'Check match';
      default:
        return 'Check answer';
    }
  }

  List<String> _wordBankFor(LearningExercise exercise) {
    final source = exercise.correctAnswer.isNotEmpty
        ? exercise.correctAnswer
        : exercise.expectedSpeech;
    final words = source
        .split(RegExp(r'\s+'))
        .where((word) => word.trim().isNotEmpty)
        .toList();
    if (words.length < 2) {
      return words;
    }

    final rotation = exercise.id.length % words.length;
    return <String>[
      ...words.skip(rotation),
      ...words.take(rotation),
    ];
  }

  String _mascotMessage(String exerciseType) {
    if (_lastAnswerCorrect == true) {
      return 'Yay! Your mascot is cheering for you.';
    }
    if (_lastAnswerCorrect == false) {
      return 'Oops. Take a breath and try again.';
    }
    switch (exerciseType) {
      case 'listening':
        return 'Tap play and trust your ears.';
      case 'speaking':
        return 'Use a loud clear voice for this one.';
      case 'writing':
        return 'Type each word carefully and check the spelling.';
      case 'matching':
        return 'Look at the picture clues and choose wisely.';
      default:
        return 'Pick the best card to keep the streak alive.';
    }
  }

  String _titleCase(String value) {
    if (value.isEmpty) {
      return value;
    }
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}

class _LessonTopAction extends StatelessWidget {
  const _LessonTopAction({
    required this.onPressed,
    required this.icon,
  });

  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD9E5EC)),
          ),
          child: Icon(icon, color: const Color(0xFF8FA2B2)),
        ),
      ),
    );
  }
}

class _LessonHeartBadge extends StatelessWidget {
  const _LessonHeartBadge({
    required this.correctness,
  });

  final bool? correctness;

  @override
  Widget build(BuildContext context) {
    final color = correctness == false
        ? const Color(0xFFFF6B6B)
        : const Color(0xFFFF5B7F);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Icon(Icons.favorite_rounded, color: color, size: 24),
    );
  }
}

class _CompactLessonCoach extends StatelessWidget {
  const _CompactLessonCoach({
    required this.character,
    required this.message,
    required this.isReviewRound,
  });

  final app_char.Character? character;
  final String message;
  final bool isReviewRound;

  @override
  Widget build(BuildContext context) {
    final coach = character;
    final accent = coach?.primaryColor ?? const Color(0xFF58CC6A);
    final bubbleColor = isReviewRound
        ? const Color(0xFFFFF7E6)
        : accent.withOpacity(0.10);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD9E5EC)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (coach != null) ...<Widget>[
            CharacterDisplay(
              character: coach,
              size: 56,
              showName: false,
              animated: true,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    isReviewRound
                        ? '${coach?.name ?? 'Coach'} wants to fix this with you'
                        : '${coach?.name ?? 'Coach'} says',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: isReviewRound
                          ? const Color(0xFFD4931B)
                          : accent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF355070),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CelebrationOverlay extends StatefulWidget {
  const _CelebrationOverlay({
    required this.fadeAnimation,
    required this.confettiAnimation,
    required this.xpEarned,
    required this.isPerfect,
    required this.canJumpToNextChapter,
    this.nextChapterTitle,
    this.onJumpToNextChapter,
    required this.onContinue,
  });

  final AnimationController fadeAnimation;
  final AnimationController confettiAnimation;
  final int xpEarned;
  final bool isPerfect;
  final bool canJumpToNextChapter;
  final String? nextChapterTitle;
  final VoidCallback? onJumpToNextChapter;
  final VoidCallback onContinue;

  @override
  State<_CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<_CelebrationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Pulsing animation for the jump button
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
    
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.fadeAnimation,
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Stack(
          children: <Widget>[
            // Confetti effect
            CustomPaint(
              painter: _ConfettiPainter(
                animation: widget.confettiAnimation,
              ),
              child: Container(),
            ),
            // Center content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Character celebration emoji
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.5, end: 1.2).animate(
                      CurvedAnimation(
                        parent: widget.fadeAnimation,
                        curve: Curves.elasticOut,
                      ),
                    ),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.yellow[300],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.celebration_rounded,
                        size: 60,
                        color: Color(0xFF16324F),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Success text
                  Text(
                    widget.isPerfect ? 'Perfect!' : 'Amazing!',
                    style: GoogleFonts.fredoka(
                      fontSize: 56,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: <Shadow>[
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // XP earned
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4B942),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: const Color(0xFFF4B942).withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      '+${widget.xpEarned} XP',
                      style: GoogleFonts.fredoka(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF16324F),
                      ),
                    ),
                  ),
                  
                  // Jump to next chapter button (if available)
                  if (widget.canJumpToNextChapter &&
                      widget.nextChapterTitle != null) ...<Widget>[
                    const SizedBox(height: 40),
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                        CurvedAnimation(
                          parent: widget.fadeAnimation,
                          curve: Curves.elasticOut,
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          Text(
                            '🎉 Ready for the next chapter?',
                            style: GoogleFonts.fredoka(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Pulsing jump button
                          ScaleTransition(
                            scale: Tween<double>(begin: 0.95, end: 1.08).animate(
                              CurvedAnimation(
                                parent: _pulseController,
                                curve: Curves.easeInOut,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1FA2A6)
                                        .withValues(alpha: _pulseController.value * 0.5),
                                    blurRadius: 12 + (_pulseController.value * 8),
                                    spreadRadius: 2 + (_pulseController.value * 4),
                                  ),
                                ],
                              ),
                              child: FilledButton.icon(
                                onPressed: widget.onJumpToNextChapter,
                                icon: const Icon(Icons.arrow_forward_rounded),
                                label: Text(
                                  '${widget.nextChapterTitle}',
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF1FA2A6),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: widget.onContinue,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF16324F),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      widget.canJumpToNextChapter
                          ? 'Continue lesson path'
                          : 'Continue',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({required this.animation})
      : super(repaint: animation);

  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    const confettiCount = 30;

    for (int i = 0; i < confettiCount; i++) {
      final startX = random.nextDouble() * size.width;
      const startY = -20.0;
      final speedY = random.nextDouble() * 200 + 100;
      final speedX = (random.nextDouble() - 0.5) * 100;

      final currentY =
          startY + (speedY * animation.value * 2);
      final currentX = startX + (speedX * animation.value * 2);

      if (currentY < size.height) {
        final colors = <Color>[
          const Color(0xFF1A936F),
          const Color(0xFFF4B942),
          const Color(0xFFE76F51),
          const Color(0xFF0E7C86),
          const Color(0xFFE76FAD),
        ];

        final paint = Paint()
          ..color = colors[i % colors.length]
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(currentX, currentY), 5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}

class _LessonHud extends StatelessWidget {
  const _LessonHud({
    required this.sessionXp,
    required this.completedCount,
    required this.totalExercises,
    required this.reaction,
    required this.activeCharacter,
  });

  final int sessionXp;
  final int completedCount;
  final int totalExercises;
  final bool? reaction;
  final app_char.Character? activeCharacter;

  @override
  Widget build(BuildContext context) {
    final accent = reaction == true
        ? const Color(0xFF1A936F)
        : reaction == false
            ? const Color(0xFFE76F51)
            : const Color(0xFFFFFFFF);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        _HudBadge(
          icon: Icons.bolt_rounded,
          label: 'Session XP',
          value: '$sessionXp',
          accent: const Color(0xFFF4B942),
        ),
        _HudBadge(
          icon: Icons.flag_rounded,
          label: 'Challenges',
          value: '$completedCount / $totalExercises',
          accent: const Color(0xFF93D2D5),
        ),
        _HudBadge(
          icon: Icons.favorite_rounded,
          label: 'Coach',
          value: activeCharacter?.name ?? 'Friend',
          accent: accent,
          compact: true,
        ),
      ],
    );
  }
}

class _HudBadge extends StatelessWidget {
  const _HudBadge({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withValues(alpha: 0.82),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.fredoka(
                  fontSize: compact ? 15 : 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompanionSquadBar extends StatelessWidget {
  const _CompanionSquadBar({
    required this.activeCharacter,
  });

  final app_char.Character activeCharacter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: app_char.Characters.all
            .map(
              (character) => _MiniCompanionChip(
                character: character,
                isActive: character.id == activeCharacter.id,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _MiniCompanionChip extends StatelessWidget {
  const _MiniCompanionChip({
    required this.character,
    required this.isActive,
  });

  final app_char.Character character;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? character.secondaryColor : const Color(0xFFF5F8FA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive
              ? character.primaryColor.withValues(alpha: 0.35)
              : const Color(0xFFE0EBF0),
          width: isActive ? 1.6 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CharacterDisplay(
            character: character,
            size: 40,
            showName: false,
            animated: isActive,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                character.name,
                style: GoogleFonts.fredoka(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF16324F),
                ),
              ),
              Text(
                isActive ? 'Helping now' : character.role,
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isActive
                      ? character.primaryColor
                      : const Color(0xFF607D8B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MascotCoachCard extends StatelessWidget {
  const _MascotCoachCard({
    required this.character,
    required this.reaction,
    required this.lessonType,
    required this.message,
  });

  final app_char.Character? character;
  final bool? reaction;
  final String lessonType;
  final String message;

  @override
  Widget build(BuildContext context) {
    final activeCharacter = character ?? app_char.Characters.lumi;
    final accent = reaction == true
        ? const Color(0xFF1A936F)
        : reaction == false
            ? const Color(0xFFE76F51)
            : activeCharacter.primaryColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: <Widget>[
          AnimatedScale(
            scale: reaction == true ? 1.08 : 1,
            duration: const Duration(milliseconds: 180),
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  activeCharacter.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${activeCharacter.name} • ${activeCharacter.role}',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w900,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF51697D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseSceneCue extends StatelessWidget {
  const _ExerciseSceneCue({
    required this.exercise,
  });

  final LearningExercise exercise;

  @override
  Widget build(BuildContext context) {
    final prompt = switch (exercise.type) {
      'listening' =>
        'Use your ears first, then choose the meaning that matches best.',
      'speaking' =>
        'Listen, copy the rhythm, and say it like you are talking to a friend.',
      'writing' =>
        'Build the sentence carefully. Focus on word order and tiny details.',
      'matching' =>
        'Link the word to the right picture or idea like a tiny puzzle.',
      _ => 'Read closely and look for the clue that makes the sentence feel right.',
    };

    final visualHint = exercise.imageHint.trim().isEmpty
        ? null
        : 'Visual idea: ${exercise.imageHint.trim()}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCEAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_rounded,
                color: Color(0xFF0E7C86),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Kid-friendly clue',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0E7C86),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            prompt,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF51697D),
              height: 1.35,
            ),
          ),
          if (visualHint != null) ...[
            const SizedBox(height: 6),
            Text(
              visualHint,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF607D8B),
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExerciseTypePill extends StatelessWidget {
  const _ExerciseTypePill({
    required this.type,
  });

  final String type;

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      'listening' => Icons.headphones_rounded,
      'speaking' => Icons.mic_rounded,
      'writing' => Icons.edit_rounded,
      'matching' => Icons.extension_rounded,
      _ => Icons.quiz_rounded,
    };
    final label = switch (type) {
      'listening' => 'Listening',
      'speaking' => 'Speaking',
      'writing' => 'Writing',
      'matching' => 'Matching',
      _ => 'Multiple choice',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2FBFB),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: const Color(0xFF0E7C86), size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0E7C86),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBanner extends StatelessWidget {
  const _ActionBanner({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FB),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFDBF5F3),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: const Color(0xFF0E7C86)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: GoogleFonts.fredoka(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF16324F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF607D8B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: onAction,
            icon: Icon(icon),
            label: Text(
              actionLabel,
              style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeakingRecorderCard extends StatelessWidget {
  const _SpeakingRecorderCard({
    required this.isRecording,
    required this.transcript,
    required this.expectedSpeech,
    required this.onTap,
  });

  final bool isRecording;
  final String transcript;
  final String expectedSpeech;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isRecording ? const Color(0xFFFFF3E8) : const Color(0xFFF6F9FB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              isRecording ? const Color(0xFFF4B942) : const Color(0xFFE0EBF0),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: isRecording
                      ? const Color(0xFFE76F51)
                      : const Color(0xFF0E7C86),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      isRecording ? 'Recording...' : 'Tap to speak',
                      style: GoogleFonts.fredoka(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF16324F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transcript.isEmpty ? expectedSpeech : transcript,
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF607D8B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onTap,
              icon: Icon(
                  isRecording ? Icons.stop_circle_rounded : Icons.mic_rounded),
              label: Text(
                isRecording ? 'Stop recording' : 'Tap to speak',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    required this.label,
    required this.subtitle,
    required this.imageKey,
    required this.isSelected,
    required this.isLocked,
    required this.isCorrect,
    required this.isWrongSelection,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final String imageKey;
  final bool isSelected;
  final bool isLocked;
  final bool isCorrect;
  final bool isWrongSelection;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isCorrect
        ? const Color(0xFF1A936F)
        : isWrongSelection
            ? const Color(0xFFE76F51)
            : isSelected
                ? const Color(0xFF0E7C86)
                : const Color(0xFFE1EAF0);
    final backgroundColor = isCorrect
        ? const Color(0xFFE9F7F2)
        : isWrongSelection
            ? const Color(0xFFFFF0EC)
            : isSelected
                ? const Color(0xFFF0FAFA)
                : Colors.white;

    return TweenAnimationBuilder<double>(
      key: ValueKey<String>(
          'choice_$label$isWrongSelection$isCorrect$isSelected'),
      tween: Tween<double>(begin: isWrongSelection ? 1 : 0, end: 0),
      duration: const Duration(milliseconds: 360),
      builder: (context, value, child) {
        final dx = isWrongSelection ? math.sin(value * math.pi * 4) * 10 : 0.0;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: child,
        );
      },
      child: AnimatedScale(
        scale: isCorrect ? 1.02 : 1,
        duration: const Duration(milliseconds: 180),
        child: InkWell(
          onTap: isLocked ? null : onTap,
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _iconColor(imageKey).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(_iconFor(imageKey), color: _iconColor(imageKey)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        label,
                        style: GoogleFonts.nunito(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF16324F),
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF607D8B),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCorrect
                            ? const Color(0xFF1A936F)
                            : isWrongSelection
                                ? const Color(0xFFE76F51)
                                : isSelected
                                    ? borderColor
                                    : Colors.transparent,
                        border: Border.all(color: borderColor, width: 2),
                      ),
                      child: isCorrect || isWrongSelection
                          ? Icon(
                              isCorrect
                                  ? Icons.check_rounded
                                  : Icons.close_rounded,
                              size: 28,
                              color: Colors.white,
                            )
                          : (isSelected
                              ? const Icon(Icons.check_rounded,
                                  size: 16, color: Colors.white)
                              : null),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PictureChoiceCard extends StatelessWidget {
  const _PictureChoiceCard({
    required this.label,
    required this.subtitle,
    required this.imageKey,
    required this.isSelected,
    required this.isLocked,
    required this.isCorrect,
    required this.isWrongSelection,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final String imageKey;
  final bool isSelected;
  final bool isLocked;
  final bool isCorrect;
  final bool isWrongSelection;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = isCorrect
        ? const Color(0xFF1A936F)
        : isWrongSelection
            ? const Color(0xFFE76F51)
            : isSelected
                ? const Color(0xFF0E7C86)
                : _iconColor(imageKey);

    return TweenAnimationBuilder<double>(
      key: ValueKey<String>(
          'picture_$label$isWrongSelection$isCorrect$isSelected'),
      tween: Tween<double>(begin: isWrongSelection ? 1 : 0, end: 0),
      duration: const Duration(milliseconds: 360),
      builder: (context, value, child) {
        final dx = isWrongSelection ? math.sin(value * math.pi * 4) * 10 : 0.0;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: child,
        );
      },
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: isSelected ? accent.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: accent, width: 2),
          ),
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AnimatedScale(
                    scale: isCorrect ? 1.05 : 1,
                    duration: const Duration(milliseconds: 180),
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        _iconFor(imageKey),
                        size: 36,
                        color: accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.fredoka(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF16324F),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF607D8B),
                    ),
                  ),
                ],
              ),
              if (isCorrect || isWrongSelection)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCorrect
                          ? const Color(0xFF1A936F)
                          : const Color(0xFFE76F51),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: (isCorrect
                                  ? const Color(0xFF1A936F)
                                  : const Color(0xFFE76F51))
                              .withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      isCorrect
                          ? Icons.check_rounded
                          : Icons.close_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    super.key,
    required this.message,
    required this.explanation,
    required this.isCorrect,
  });

  final String message;
  final String explanation;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final accent =
        isCorrect ? const Color(0xFF1A936F) : const Color(0xFFE76F51);
    final background =
        isCorrect ? const Color(0xFFEAF7F0) : const Color(0xFFFFF2EE);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                isCorrect ? Icons.celebration_rounded : Icons.refresh_rounded,
                color: accent,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            explanation,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF51697D),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniTestDialog extends StatefulWidget {
  const _MiniTestDialog({
    required this.nextChapterTitle,
    required this.onPassed,
  });

  final String nextChapterTitle;
  final VoidCallback onPassed;

  @override
  State<_MiniTestDialog> createState() => _MiniTestDialogState();
}

class _MiniTestDialogState extends State<_MiniTestDialog> {
  late List<Map<String, dynamic>> _questions;
  int _currentQuestionIndex = 0;
  int? _selectedAnswer;
  bool _answered = false;
  int _correctAnswers = 0;

  @override
  void initState() {
    super.initState();
    _generateQuestions();
  }

  void _generateQuestions() {
    _questions = [
      {
        'question': 'You\'ve completed the chapter! Ready for the next challenge?',
        'options': ['Yes, let\'s go!', 'Maybe later'],
        'correctIndex': 0,
      },
      {
        'question': 'Which is the best way to learn a language?',
        'options': [
          'Practice every day',
          'Only study on weekends',
          'Practice once a month',
        ],
        'correctIndex': 0,
      },
    ];
  }

  void _onAnswerSelected(int index) {
    if (_answered) return;

    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (index == _questions[_currentQuestionIndex]['correctIndex']) {
        _correctAnswers++;
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      if (_currentQuestionIndex + 1 < _questions.length) {
        setState(() {
          _currentQuestionIndex++;
          _selectedAnswer = null;
          _answered = false;
        });
      } else {
        // All questions answered
        if (mounted) {
          Navigator.pop(context);
          widget.onPassed();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestionIndex];
    final isCorrectAnswer =
        _selectedAnswer == question['correctIndex'];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0E7C86).withValues(alpha: 0.05),
              const Color(0xFF1FA2A6).withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Text(
                'Quick Challenge',
                style: GoogleFonts.fredoka(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF16324F),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Before jumping to ${widget.nextChapterTitle}',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF607D8B),
                ),
              ),
              const SizedBox(height: 24),

              // Progress indicator
              Row(
                children: List.generate(
                  _questions.length,
                  (index) => Expanded(
                    child: Container(
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index <= _currentQuestionIndex
                            ? (index < _currentQuestionIndex ||
                                    (_answered && isCorrectAnswer)
                                ? const Color(0xFF1A936F)
                                : const Color(0xFFE76F51))
                            : const Color(0xFFE9F7F2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Question
              Text(
                question['question'],
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF16324F),
                ),
              ),
              const SizedBox(height: 24),

              // Options
              ...List.generate(
                (question['options'] as List<String>).length,
                (index) {
                  final option = (question['options'] as List<String>)[index];
                  final isSelected = _selectedAnswer == index;
                  final isCorrect = index == question['correctIndex'];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _onAnswerSelected(index),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _answered
                              ? isCorrect
                                  ? const Color(0xFFE8F7F2)
                                  : isSelected
                                      ? const Color(0xFFFFF0EC)
                                      : const Color(0xFFF5F7FA)
                              : isSelected
                                  ? const Color(0xFFF0FAFA)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _answered
                                ? isCorrect
                                    ? const Color(0xFF1A936F)
                                    : isSelected
                                        ? const Color(0xFFE76F51)
                                        : const Color(0xFFE1EAF0)
                                : isSelected
                                    ? const Color(0xFF0E7C86)
                                    : const Color(0xFFE1EAF0),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            if (_answered)
                              Icon(
                                isCorrect
                                    ? Icons.check_circle_rounded
                                    : isSelected
                                        ? Icons.cancel_rounded
                                        : Icons.radio_button_unchecked_rounded,
                                color: isCorrect
                                    ? const Color(0xFF1A936F)
                                    : isSelected
                                        ? const Color(0xFFE76F51)
                                        : const Color(0xFFB0BEC5),
                                size: 24,
                              )
                            else
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF0E7C86)
                                        : const Color(0xFFB0BEC5),
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check_rounded,
                                        size: 14,
                                        color: Color(0xFF0E7C86),
                                      )
                                    : null,
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                option,
                                style: GoogleFonts.nunito(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF16324F),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Info text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FAFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF0E7C86).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF0E7C86),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Answer correctly to unlock the next chapter!',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0E7C86),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonCompleteView extends StatelessWidget {
  const _LessonCompleteView({
    required this.lessonTitle,
    required this.totalExercises,
    required this.totalXp,
    required this.score,
    required this.perfectBonus,
    required this.onContinue,
  });

  final String lessonTitle;
  final int totalExercises;
  final int totalXp;
  final double score;
  final int perfectBonus;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final isPerfect = score == 100;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 560),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: isPerfect
                      ? const Color(0xFFFFF6DB)
                      : const Color(0xFFEAF7F0),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  isPerfect
                      ? Icons.emoji_events_rounded
                      : Icons.workspace_premium_rounded,
                  size: 48,
                  color: isPerfect
                      ? const Color(0xFFF4B942)
                      : const Color(0xFF1A936F),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                isPerfect ? 'Perfect!' : 'Lesson complete',
                style: GoogleFonts.fredoka(
                  fontSize: 34,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF16324F),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'You completed "$lessonTitle" with $totalExercises challenges and scored ${score.toStringAsFixed(0)}%.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF607D8B),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  _ResultBadge(
                    icon: Icons.bolt_rounded,
                    label: '$totalXp XP earned',
                    color: const Color(0xFF0E7C86),
                  ),
                  if (perfectBonus > 0)
                    _ResultBadge(
                      icon: Icons.star_rounded,
                      label: '+$perfectBonus perfect bonus',
                      color: const Color(0xFFF4B942),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1FA2A6),
                  ),
                  child: Text(
                    'Continue →',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Back to home',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  const _ResultBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonError extends StatelessWidget {
  const _LessonError({
    required this.error,
  });

  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.error_outline_rounded,
                size: 44,
                color: Color(0xFFE76F51),
              ),
              const SizedBox(height: 14),
              Text(
                error,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF51697D),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmotionOption {
  const _EmotionOption(this.key, this.label);

  final String key;
  final String label;
}

const List<_EmotionOption> _emotionOptions = <_EmotionOption>[
  _EmotionOption('happy', 'Happy'),
  _EmotionOption('focused', 'Focused'),
  _EmotionOption('curious', 'Curious'),
  _EmotionOption('tired', 'Tired'),
  _EmotionOption('frustrated', 'Frustrated'),
];

IconData _iconFor(String imageKey) {
  switch (imageKey) {
    case 'hello':
    case 'hi':
      return Icons.waving_hand_rounded;
    case 'goodbye':
      return Icons.emoji_people_rounded;
    case 'please':
    case 'thank_you':
    case 'sorry':
      return Icons.favorite_rounded;
    case 'name':
    case 'me':
      return Icons.badge_rounded;
    case 'friend':
    case 'friends_group':
      return Icons.groups_rounded;
    case 'happy':
      return Icons.sentiment_very_satisfied_rounded;
    case 'sad':
      return Icons.sentiment_dissatisfied_rounded;
    case 'excited':
      return Icons.celebration_rounded;
    case 'morning':
      return Icons.wb_sunny_rounded;
    case 'afternoon':
      return Icons.light_mode_rounded;
    case 'night':
      return Icons.nights_stay_rounded;
    case 'question':
      return Icons.help_rounded;
    case 'answer':
      return Icons.chat_bubble_rounded;
    case 'one':
      return Icons.filter_1_rounded;
    case 'two':
      return Icons.filter_2_rounded;
    case 'three':
      return Icons.filter_3_rounded;
    case 'four':
      return Icons.filter_4_rounded;
    case 'five':
      return Icons.filter_5_rounded;
    case 'six':
      return Icons.filter_6_rounded;
    case 'seven':
      return Icons.looks_3_rounded;
    case 'eight':
      return Icons.looks_4_rounded;
    case 'nine':
      return Icons.looks_5_rounded;
    case 'red':
    case 'blue':
    case 'yellow':
    case 'green':
    case 'orange':
    case 'purple':
    case 'black':
    case 'white':
    case 'pink':
      return Icons.circle_rounded;
    case 'book':
      return Icons.menu_book_rounded;
    case 'pen':
    case 'pencil':
      return Icons.edit_rounded;
    case 'desk':
    case 'table':
      return Icons.table_restaurant_rounded;
    case 'chair':
      return Icons.chair_rounded;
    case 'bag':
      return Icons.backpack_rounded;
    case 'ruler':
      return Icons.straighten_rounded;
    case 'eraser':
      return Icons.auto_fix_normal_rounded;
    case 'door':
      return Icons.door_front_door_rounded;
    case 'window':
      return Icons.window_rounded;
    case 'board':
      return Icons.dashboard_customize_rounded;
    case 'open':
      return Icons.unfold_more_rounded;
    case 'close':
      return Icons.close_fullscreen_rounded;
    case 'carry':
      return Icons.pan_tool_alt_rounded;
    case 'circle':
      return Icons.circle_outlined;
    case 'square':
      return Icons.square_outlined;
    case 'triangle':
      return Icons.change_history_rounded;
    case 'mother':
    case 'aunt':
    case 'grandmother':
      return Icons.person_rounded;
    case 'father':
    case 'uncle':
    case 'grandfather':
      return Icons.person_outline_rounded;
    case 'baby':
      return Icons.child_care_rounded;
    case 'brother':
    case 'student':
      return Icons.school_rounded;
    case 'sister':
      return Icons.person_rounded;
    case 'smile':
      return Icons.tag_faces_rounded;
    case 'play':
    case 'ball':
      return Icons.sports_soccer_rounded;
    case 'share':
    case 'help':
      return Icons.volunteer_activism_rounded;
    case 'kind':
      return Icons.favorite_border_rounded;
    case 'funny':
      return Icons.emoji_emotions_rounded;
    case 'strong':
      return Icons.fitness_center_rounded;
    case 'i_am':
    case 'i_like':
    case 'i_can':
    case 'this_is':
    case 'i_have':
    case 'we_are':
      return Icons.chat_rounded;
    case 'ready':
      return Icons.flag_rounded;
    case 'apple':
      return Icons.local_grocery_store_rounded;
    case 'read':
      return Icons.chrome_reader_mode_rounded;
    case 'draw':
      return Icons.draw_rounded;
    case 'class':
      return Icons.school_rounded;
    case 'star':
      return Icons.star_rounded;
    case 'sun':
      return Icons.wb_sunny_outlined;
    case 'tree':
      return Icons.park_rounded;
    default:
      return Icons.auto_awesome_rounded;
  }
}

Color _iconColor(String imageKey) {
  switch (imageKey) {
    case 'red':
      return const Color(0xFFE63946);
    case 'blue':
      return const Color(0xFF2B59C3);
    case 'yellow':
      return const Color(0xFFF4B942);
    case 'green':
      return const Color(0xFF2A9D8F);
    case 'orange':
      return const Color(0xFFF77F00);
    case 'purple':
      return const Color(0xFF8E5CF7);
    case 'black':
      return const Color(0xFF374151);
    case 'white':
      return const Color(0xFF9CA3AF);
    case 'pink':
      return const Color(0xFFE76FAD);
    case 'happy':
    case 'smile':
    case 'sun':
      return const Color(0xFFF4B942);
    case 'sad':
      return const Color(0xFF577590);
    case 'excited':
    case 'star':
      return const Color(0xFF1A936F);
    default:
      return const Color(0xFF0E7C86);
  }
}

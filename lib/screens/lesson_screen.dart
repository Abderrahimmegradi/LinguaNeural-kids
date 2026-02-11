import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/lesson.dart';
import '../models/exercise.dart';
import '../data/english_lessons.dart';
import 'speaking_exercise.dart';
import 'listening_exercise.dart';
import '../providers/user_provider.dart';
import '../providers/lesson_provider.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonScreen({super.key, required this.lesson});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _currentExerciseIndex = 0;
  int _score = 0;
  int _totalExercises = 0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _totalExercises = EnglishLessons.getExercisesForLesson(widget.lesson.id).length;
  }

  void _nextExercise() {
    if (_currentExerciseIndex < _totalExercises - 1) {
      setState(() {
        _currentExerciseIndex++;
      });
    } else {
      setState(() {
        _isCompleted = true;
      });
      _showCompletionDialog();
    }
  }

  void _addPoints(int points) {
    setState(() {
      _score += points;
    });
  }

  void _showCompletionDialog() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final lessonProvider = Provider.of<LessonProvider>(context, listen: false);
    
    // Add XP to user
    userProvider.addXP(_score);
    
    // Mark lesson as completed
    if (widget.lesson.id.isNotEmpty) {
      lessonProvider.completeLesson(widget.lesson.id);
      
      // Unlock next lesson
      lessonProvider.unlockNextLesson();
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Celebration Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF66BB6A).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration,
                size: 60,
                color: Color(0xFF66BB6A),
              ),
            ),
            
            const SizedBox(height: 20),
            
            Text(
              'Lesson Complete! 🎉',
              style: GoogleFonts.nunitoSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A237E),
              ),
            ),
            
            const SizedBox(height: 10),
            
            Text(
              'You earned $_score XP',
              style: GoogleFonts.nunitoSans(
                fontSize: 18,
                color: const Color(0xFF546E7A),
              ),
            ),
            
            const SizedBox(height: 10),
            
            Text(
              'Total XP: ${userProvider.totalXP}',
              style: GoogleFonts.nunitoSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A237E),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Stars based on performance
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Icon(
                  Icons.star,
                  size: 40,
                  color: _score > (index * 15) ? const Color(0xFFFF9800) : Colors.grey[300],
                );
              }),
            ),
            
            const SizedBox(height: 30),
            
            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Go back to lesson selection
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF66BB6A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  'Continue Learning',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getExerciseWidget() {
    final exercises = EnglishLessons.getExercisesForLesson(widget.lesson.id);
    if (_currentExerciseIndex >= exercises.length) {
      return const Center(child: Text('No more exercises'));
    }

    final exercise = exercises[_currentExerciseIndex];

    switch (exercise.type) {
      case 'speaking':
        return SpeakingExercise(
          exercise: exercise,
          onComplete: (isCorrect) {
            if (isCorrect) {
              _addPoints(exercise.points);
            }
            _nextExercise();
          },
        );
      case 'listening':
        return ListeningExercise(
          exercise: exercise,
          onComplete: (isCorrect) {
            if (isCorrect) {
              _addPoints(exercise.points);
            }
            _nextExercise();
          },
        );
      default:
        return MultipleChoiceExercise(
          exercise: exercise,
          onComplete: (isCorrect) {
            if (isCorrect) {
              _addPoints(exercise.points);
            }
            _nextExercise();
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF1A237E),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.lesson.title,
              style: GoogleFonts.nunitoSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A237E),
              ),
            ),
            Text(
              'Exercise ${_currentExerciseIndex + 1}/$_totalExercises',
              style: GoogleFonts.nunitoSans(
                fontSize: 12,
                color: const Color(0xFF546E7A),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 15),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Color(0xFFFF9800),
                  size: 16,
                ),
                const SizedBox(width: 5),
                Text(
                  '$_score XP',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A237E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: (_currentExerciseIndex + 1) / _totalExercises,
            backgroundColor: Colors.grey[200],
            color: const Color(0xFF66BB6A),
            minHeight: 3,
          ),
          
          // Exercise Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _getExerciseWidget(),
            ),
          ),
        ],
      ),
    );
  }
}

// Multiple Choice Exercise Widget
class MultipleChoiceExercise extends StatefulWidget {
  final Exercise exercise;
  final Function(bool) onComplete;

  const MultipleChoiceExercise({
    super.key,
    required this.exercise,
    required this.onComplete,
  });

  @override
  State<MultipleChoiceExercise> createState() => _MultipleChoiceExerciseState();
}

class _MultipleChoiceExerciseState extends State<MultipleChoiceExercise> {
  String? _selectedAnswer;
  bool _showFeedback = false;

  void _checkAnswer() {
    setState(() {
      _showFeedback = true;
    });
    
    Future.delayed(const Duration(seconds: 2), () {
      widget.onComplete(_selectedAnswer == widget.exercise.correctAnswer);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question
        Text(
          widget.exercise.question,
          style: GoogleFonts.nunitoSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A237E),
          ),
        ),
        
        const SizedBox(height: 30),
        
        // Options
        Column(
          children: widget.exercise.options!.map((option) {
            bool isCorrect = option == widget.exercise.correctAnswer;
            bool isSelected = option == _selectedAnswer;
            
            Color getColor() {
              if (!_showFeedback) {
                return isSelected ? const Color(0xFF1A237E) : Colors.grey[200]!;
              }
              if (isCorrect) return const Color(0xFF66BB6A);
              if (isSelected && !isCorrect) return const Color(0xFFEF5350);
              return Colors.grey[200]!;
            }
            
            Color getTextColor() {
              if (!_showFeedback) {
                return isSelected ? Colors.white : const Color(0xFF1A237E);
              }
              if (isCorrect) return Colors.white;
              if (isSelected && !isCorrect) return Colors.white;
              return const Color(0xFF1A237E);
            }
            
            return GestureDetector(
              onTap: _showFeedback ? null : () {
                setState(() {
                  _selectedAnswer = option;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: getColor(),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF1A237E) : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 18,
                          color: getTextColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (_showFeedback)
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? Colors.white : Colors.white,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        
        const Spacer(),
        
        // Hint
        if (widget.exercise.hint.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF29B6F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFF29B6F6),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.exercise.hint,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14,
                      color: const Color(0xFF1A237E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        const SizedBox(height: 20),
        
        // Check Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedAnswer == null || _showFeedback ? null : _checkAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              disabledBackgroundColor: Colors.grey[400],
            ),
            child: Text(
              _showFeedback ? 'Continue' : 'Check Answer',
              style: GoogleFonts.nunitoSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/english_lesson_provider.dart';
import '../models/english_lesson_model.dart';

class EnglishLessonScreen extends StatefulWidget {
  const EnglishLessonScreen({super.key});

  @override
  State<EnglishLessonScreen> createState() => _EnglishLessonScreenState();
}

class _EnglishLessonScreenState extends State<EnglishLessonScreen> {
  int? selectedAnswerIndex;
  bool answered = false;
  int totalXPEarned = 0;

  @override
  Widget build(BuildContext context) {
    final englishProvider = Provider.of<EnglishLessonProvider>(context);
    final lesson = englishProvider.currentLesson;
    final exercise = englishProvider.currentExercise;
    final progress = englishProvider.getProgressPercentage();

    if (lesson == null || exercise == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Error loading lesson',
            style: GoogleFonts.nunitoSans(fontSize: 16),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Lesson?'),
            content: const Text('Your progress will not be saved.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Exit'),
              ),
            ],
          ),
        ) ??
            false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            lesson.title,
            style: GoogleFonts.nunitoSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A237E),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  '${englishProvider.currentExerciseIndex + 1}/${englishProvider.currentUnit?.exercises.length ?? 0}',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A237E),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Progress bar
              Container(
                height: 8,
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (progress ?? 0) / 100.0,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF667EEA),
                    ),
                  ),
                ),
              ),
              // Main content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question in English
                    Text(
                      exercise.question,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Question in Arabic
                    Text(
                      exercise.questionArabic,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Exercise type indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getExerciseTypeColor(exercise.type)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getExerciseTypeLabel(exercise.type),
                        style: GoogleFonts.nunitoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              _getExerciseTypeColor(exercise.type),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Options
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: exercise.options.length,
                      itemBuilder: (context, index) {
                        final option = exercise.options[index];
                        final isSelected = selectedAnswerIndex == index;
                        final isCorrect = option.isCorrect;
                        final showResult = answered;

                        return GestureDetector(
                          onTap: answered
                              ? null
                              : () {
                                  setState(() {
                                    selectedAnswerIndex = index;
                                    answered = true;
                                    if (isCorrect) {
                                      totalXPEarned +=
                                          exercise.xpReward;
                                    }
                                  });
                                },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: showResult
                                    ? (isSelected && isCorrect
                                        ? Colors.green
                                        : isSelected && !isCorrect
                                            ? Colors.red
                                            : isCorrect &&
                                                    !isSelected
                                                ? Colors.green
                                                : Colors.grey[300]!)
                                    : (isSelected
                                        ? const Color(0xFF667EEA)
                                        : Colors.grey[300]!),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected && !showResult
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF667EEA)
                                            .withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black
                                            .withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        option.text,
                                        style: GoogleFonts
                                            .nunitoSans(
                                          fontSize: 16,
                                          fontWeight:
                                              FontWeight.w600,
                                          color: const Color(
                                              0xFF1A237E),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        option.textArabic,
                                        style: GoogleFonts
                                            .nunitoSans(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (showResult)
                                  Icon(
                                    isSelected && isCorrect
                                        ? Icons.check_circle
                                        : isSelected && !isCorrect
                                            ? Icons.cancel
                                            : isCorrect &&
                                                    !isSelected
                                                ? Icons.check_circle
                                                : Icons.circle_outlined,
                                    color: isSelected && isCorrect
                                        ? Colors.green
                                        : isSelected && !isCorrect
                                            ? Colors.red
                                            : isCorrect && !isSelected
                                                ? Colors.green
                                                : Colors.grey,
                                    size: 24,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Explanation (shown after answer)
              if (answered)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667EEA).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF667EEA).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              color: Color(0xFF667EEA),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Explanation',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF667EEA),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          exercise.explanation,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          exercise.explanationArabic,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              // Next button
              if (answered)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedAnswerIndex = null;
                          answered = false;
                        });
                        englishProvider.nextExercise();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667EEA),
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        englishProvider.currentExerciseIndex + 1 >=
                                (englishProvider
                                    .currentUnit?.exercises.length ?? 0)
                            ? 'Finish'
                            : 'Next',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Color _getExerciseTypeColor(String type) {
    const typeColors = {
      'multipleChoice': Colors.blue,
      'matching': Colors.green,
      'listeningChoice': Colors.orange,
      'speaking': Colors.red,
      'typing': Colors.purple,
    };
    return typeColors[type] ?? Colors.grey;
  }

  String _getExerciseTypeLabel(String type) {
    const typeLabels = {
      'multipleChoice': 'Multiple Choice',
      'matching': 'Matching',
      'listeningChoice': 'Listening',
      'speaking': 'Speaking',
      'typing': 'Typing',
    };
    return typeLabels[type] ?? 'Exercise';
  }
}

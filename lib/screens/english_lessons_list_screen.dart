import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/english_lesson_provider.dart';
import '../models/english_lesson_model.dart';
import 'english_lesson_screen.dart';

class EnglishLessonsListScreen extends StatefulWidget {
  const EnglishLessonsListScreen({super.key});

  @override
  State<EnglishLessonsListScreen> createState() =>
      _EnglishLessonsListScreenState();
}

class _EnglishLessonsListScreenState extends State<EnglishLessonsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<EnglishLessonProvider>(context, listen: false);
      provider.getLessonsByCurrentLevel();
      provider.loadUserProgress('user1');
    });
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<EnglishLessonProvider>(
      builder: (context, englishProvider, _) {
        final lessons = englishProvider.lessons;
        final stats = englishProvider.getStatistics();

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'Level ${englishProvider.currentLevel} Lessons',
              style: GoogleFonts.nunitoSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A237E),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: englishProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Quick stats
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getLevelColor(englishProvider.currentLevel),
                                _getLevelColor(englishProvider.currentLevel)
                                    .withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildQuickStat(
                                '${stats['lessonsCompleted'] ?? 0}',
                                'Completed',
                                Colors.white,
                              ),
                              _buildQuickStat(
                                '${stats['totalXP'] ?? 0}',
                                'XP Earned',
                                Colors.white,
                              ),
                              _buildQuickStat(
                                '${stats['dailyStreak'] ?? 0}',
                                'Day Streak',
                                Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Lessons list
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available Lessons',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1A237E),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: lessons.length,
                              itemBuilder: (context, index) {
                                final lesson = lessons[index];
                                final isCompleted =
                                    englishProvider.isLessonCompleted(lesson.id);

                                return _buildLessonCard(
                                  context,
                                  lesson,
                                  index,
                                  isCompleted,
                                  englishProvider,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildQuickStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.nunitoSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.nunitoSans(
            fontSize: 12,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildLessonCard(
    BuildContext context,
    EnglishLesson lesson,
    int index,
    bool isCompleted,
    EnglishLessonProvider englishProvider,
  ) {
    return GestureDetector(
      onTap: () {
        englishProvider.startLesson(lesson);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const EnglishLessonScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted
                ? _getLevelColor(lesson.level).withOpacity(0.3)
                : Colors.transparent,
            width: isCompleted ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lesson ${index + 1}',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lesson.title,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A237E),
                        ),
                      ),
                      Text(
                        lesson.titleArabic,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getLevelColor(lesson.level).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: _getLevelColor(lesson.level),
                      size: 24,
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              lesson.description,
              style: GoogleFonts.nunitoSans(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lesson.descriptionArabic,
              style: GoogleFonts.nunitoSans(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    const levelColors = {
      'A1': Colors.green,
      'A2': Color(0xFF7CB342),
      'B1': Colors.blue,
      'B2': Color(0xFF29B6F6),
      'C1': Colors.orange,
      'C2': Colors.red,
    };
    return levelColors[level] ?? Colors.grey;
  }
}

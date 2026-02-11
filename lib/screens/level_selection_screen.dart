import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/english_lesson_provider.dart';
import 'english_lessons_list_screen.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  // Level descriptions
  final Map<String, Map<String, String>> levelDescriptions = {
    'A1': {'en': 'Beginner - Basic words and phrases', 'ar': 'مبتدئ - كلمات وعبارات أساسية'},
    'A2': {'en': 'Elementary - Simple conversations', 'ar': 'ابتدائي - محادثات بسيطة'},
    'B1': {'en': 'Intermediate - Stories and descriptions', 'ar': 'متوسط - قصص ووصفات'},
    'B2': {'en': 'Upper Intermediate - Complex topics', 'ar': 'متوسط عالي - موضوعات معقدة'},
    'C1': {'en': 'Advanced - Literature and nuance', 'ar': 'متقدم - الأدب والدقة'},
    'C2': {'en': 'Mastery - Expert level', 'ar': 'إتقان - مستوى خبير'},
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EnglishLessonProvider>(context, listen: false)
          .loadUserProgress('user1');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EnglishLessonProvider>(
      builder: (context, englishProvider, _) {
        final stats = englishProvider.getStatistics();

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'Choose Your Level',
              style: GoogleFonts.nunitoSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A237E),
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Header with stats
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn('Current Level', stats['currentLevel'] ?? 'A1', '📚'),
                          _buildStatColumn('Lessons Done', '${stats['lessonsCompleted'] ?? 0}', '✅'),
                          _buildStatColumn('Total XP', '${stats['totalXP'] ?? 0}', '⭐'),
                        ],
                      ),
                    ],
                  ),
                ),
                // Level description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Select your English proficiency level (CEFR Framework)',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Level cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: englishProvider.getAllLevels().map((level) {
                      final levelDesc = levelDescriptions[level] ?? {};
                      final completed = stats['levelProgress']?[level] ?? 0;
                      final isCurrentLevel = level == stats['currentLevel'];

                      return _buildLevelCard(
                        context,
                        level: level,
                        title: _getLevelTitle(level),
                        description: levelDesc['en'] ?? '',
                        descriptionAr: levelDesc['ar'] ?? '',
                        lessonsCompleted: completed,
                        isCurrentLevel: isCurrentLevel,
                        englishProvider: englishProvider,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(String label, String value, String emoji) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.nunitoSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.nunitoSans(
            fontSize: 11,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildLevelCard(
    BuildContext context, {
    required String level,
    required String title,
    required String description,
    required String descriptionAr,
    required int lessonsCompleted,
    required bool isCurrentLevel,
    required EnglishLessonProvider englishProvider,
  }) {
    final levelColors = {
      'A1': Colors.green,
      'A2': Colors.lightGreen,
      'B1': Colors.blue,
      'B2': Colors.lightBlue,
      'C1': Colors.orange,
      'C2': Colors.red,
    };

    final color = levelColors[level] ?? Colors.grey;

    return GestureDetector(
      onTap: () {
        englishProvider.setCurrentLevel(level);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const EnglishLessonsListScreen(),
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
            color: isCurrentLevel ? color : Colors.transparent,
            width: 2,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          level,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A237E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (isCurrentLevel)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '✓',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Current',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: GoogleFonts.nunitoSans(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              descriptionAr,
              style: GoogleFonts.nunitoSans(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.3,
                      minHeight: 6,
                      backgroundColor: color.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$lessonsCompleted lessons',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getLevelTitle(String level) {
    final titles = {
      'A1': 'Beginner',
      'A2': 'Elementary',
      'B1': 'Intermediate',
      'B2': 'Upper Intermediate',
      'C1': 'Advanced',
      'C2': 'Mastery',
    };
    return titles[level] ?? '';
  }
}

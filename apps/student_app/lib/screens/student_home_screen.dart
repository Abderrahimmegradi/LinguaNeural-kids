import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_ui/shared_ui.dart';

import 'package:backend_core/models/character.dart' as app_char;
import '../theme/app_colors.dart';
import 'student_lesson_screen.dart';
import 'student_profile_screen.dart';

List<LearningLesson> _sortedLessons(List<LearningLesson> lessons) {
  final sorted = List<LearningLesson>.from(lessons);
  sorted.sort((a, b) => a.order.compareTo(b.order));
  return sorted;
}

List<LearningChapter> _sortedChapters(List<LearningChapter> chapters) {
  final sorted = List<LearningChapter>.from(chapters);
  sorted.sort((a, b) => a.order.compareTo(b.order));
  return sorted;
}

bool _isChapterUnlocked(
  String chapterId,
  List<LearningChapter> chapters,
  List<LearningLesson> allLessons,
  Map<String, StudentProgress> progressByLessonId,
) {
  if (chapterId.isEmpty || chapters.isEmpty) {
    return true;
  }

  final sortedChapters = _sortedChapters(chapters);
  final chapterIndex = sortedChapters.indexWhere((chapter) => chapter.id == chapterId);
  if (chapterIndex <= 0) {
    return true;
  }

  final previousChapter = sortedChapters[chapterIndex - 1];
  final previousChapterLessons = allLessons
      .where((lesson) => lesson.chapterId == previousChapter.id)
      .toList()
    ..sort((a, b) => a.order.compareTo(b.order));

  if (previousChapterLessons.isEmpty) {
    return true;
  }

  return previousChapterLessons.every(
    (lesson) => progressByLessonId[lesson.id]?.completed ?? false,
  );
}

app_char.Character _chapterGuideCharacter(
  LearningChapter chapter,
  List<LearningChapter> chapters,
) {
  final sorted = _sortedChapters(chapters);
  final index = sorted.indexWhere((item) => item.id == chapter.id);
  if (index < 0) {
    return app_char.Characters.lumi;
  }
  return app_char.Characters.all[index % app_char.Characters.all.length];
}

String _chapterGuideLine(
  LearningChapter chapter,
  List<LearningChapter> chapters,
  bool unlocked,
) {
  final guide = _chapterGuideCharacter(chapter, chapters);
  if (!unlocked) {
    return '${guide.name} is waiting here. Finish the chapter before this one to unlock the path.';
  }
  return switch (guide.id) {
    'lumi' => 'Lumi feels excited to welcome the learner into this colorful chapter.',
    'zippy' => 'Zippy is bringing fast energy and brave choices to this chapter.',
    'nexo' => 'Nexo is ready to coach careful thinking and clear answers here.',
    _ => 'Orin is here to guide steady progress through this chapter journey.',
  };
}

bool _isLessonUnlocked(
  LearningLesson lesson,
  List<LearningLesson> allLessons,
  Map<String, StudentProgress> progressByLessonId,
  List<LearningChapter> chapters,
) {
  if (!_isChapterUnlocked(
    lesson.chapterId,
    chapters,
    allLessons,
    progressByLessonId,
  )) {
    return false;
  }

  // Sort only lessons from the same chapter
  final chapterLessons = allLessons.where((l) => l.chapterId == lesson.chapterId).toList();
  final sorted = List<LearningLesson>.from(chapterLessons)
    ..sort((a, b) => a.order.compareTo(b.order));
  
  if (sorted.isEmpty) return false;

  final index = sorted.indexWhere((item) => item.id == lesson.id);
  if (index < 0) return false;
  
  // First lesson in chapter is always unlocked
  if (index == 0) {
    debugPrint('✅ Lesson "${lesson.title}" (1st in chapter) is UNLOCKED');
    return true;
  }

  // Unlock if previous lesson in same chapter is completed
  final previousLesson = sorted[index - 1];
  final previousCompleted = progressByLessonId[previousLesson.id]?.completed ?? false;
  
  debugPrint(
    'Lesson "${lesson.title}" (index $index): '
    'Previous lesson "${previousLesson.title}" completed=$previousCompleted'
  );
  
  if (previousCompleted) {
    debugPrint('✅ Lesson "${lesson.title}" is UNLOCKED');
  } else {
    debugPrint('🔒 Lesson "${lesson.title}" is LOCKED');
  }
  
  return previousCompleted;
}

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final LessonService _lessonService = LessonService();
  final ProgressService _progressService = ProgressService();
  final CharacterCoachService _characterCoach = CharacterCoachService();
  late Future<_StudentHomeData> _screenFuture;
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _screenFuture = _loadScreenData();
  }

  Future<_StudentHomeData> _loadScreenData() async {
    try {
      final userProvider = context.read<UserProvider>();
      final results = await Future.wait([
        _lessonService.getChapters(),
        _lessonService.getUnits(),
        _lessonService.getLessons(),
        userProvider.currentUserId == null
            ? Future.value(const <StudentProgress>[])
            : _progressService.getProgressForStudent(userProvider.currentUserId!),
      ]);
      final chapters = results[0] as List<LearningChapter>;
      final units = results[1] as List<LearningUnit>;
      final lessons = (results[2] as List<LearningLesson>)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      final progress = results[3] as List<StudentProgress>;

      final totalXP = progress.fold<int>(0, (sum, item) => sum + item.xpEarned);
      final streak = _calculateStreak(progress);
      userProvider.setGamificationStats(
        totalXP: totalXP,
        dailyStreak: streak,
      );

      return _StudentHomeData(
        chapters: chapters,
        units: units,
        lessons: lessons,
        progress: progress,
        totalXP: totalXP,
        streak: streak,
      );
    } catch (e) {
      // Return empty data on permission error
      return const _StudentHomeData(
        chapters: [],
        units: [],
        lessons: [],
        progress: [],
        totalXP: 0,
        streak: 0,
      );
    }
  }

  Future<void> _refreshLessons() async {
    final refreshed = _loadScreenData();
    setState(() {
      _screenFuture = refreshed;
    });
    await refreshed;
  }

  Future<void> _openLesson(LearningLesson lesson) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentLessonScreen(lesson: lesson),
      ),
    );
    if (!mounted) {
      return;
    }
    await _refreshLessons();
  }

  int _calculateStreak(List<StudentProgress> progress) {
    if (progress.isEmpty) {
      return 0;
    }

    final days = progress
        .map((item) => DateTime(item.date.year, item.date.month, item.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    var streak = 0;
    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);

    for (final day in days) {
      if (day == cursor) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else if (day == cursor.subtract(const Duration(days: 1)) &&
          streak == 0) {
        cursor = day;
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else if (day.isBefore(cursor)) {
        break;
      }
    }

    return streak;
  }

  LearningLesson? _nextLesson(_StudentHomeData data) {
    final sortedLessons = _sortedLessons(data.lessons);
    for (var index = 0; index < sortedLessons.length; index++) {
      final lesson = sortedLessons[index];
      final progress = data.progressByLessonId[lesson.id];
      final unlocked = _isLessonUnlocked(
        lesson,
        sortedLessons,
        data.progressByLessonId,
        data.chapters,
      );
      if (!unlocked) {
        continue;
      }
      if (progress == null || !progress.completed) {
        return lesson;
      }
    }
    return sortedLessons.isEmpty ? null : sortedLessons.first;
  }

  List<LearningLesson> _journeyLessons(_StudentHomeData data) {
    final chapterOrder = <String, int>{
      for (final chapter in data.chapters) chapter.id: chapter.order,
    };
    final unitOrder = <String, int>{
      for (final unit in data.units) unit.id: unit.order,
    };

    final sortedLessons = List<LearningLesson>.from(data.lessons);
    sortedLessons.sort((a, b) {
      final chapterCompare =
          (chapterOrder[a.chapterId] ?? 0).compareTo(chapterOrder[b.chapterId] ?? 0);
      if (chapterCompare != 0) {
        return chapterCompare;
      }

      final unitCompare =
          (unitOrder[a.unitId] ?? 0).compareTo(unitOrder[b.unitId] ?? 0);
      if (unitCompare != 0) {
        return unitCompare;
      }

      return a.order.compareTo(b.order);
    });
    return sortedLessons;
  }

  List<String> _buildAchievements(_StudentHomeData data) {
    final achievements = <String>[];
    if (data.progress.isNotEmpty) {
      achievements.add('First lesson');
    }
    if (data.progress.any((item) => item.score == 100)) {
      achievements.add('Perfect score');
    }
    if (data.streak >= 3) {
      achievements.add('3-day streak');
    }
    return achievements;
  }

  String _chapterNameFor(LearningLesson? lesson, List<LearningChapter> chapters) {
    if (lesson == null) return 'Intro';
    final chapter = chapters.firstWhere(
      (chapter) => chapter.id == lesson.chapterId,
      orElse: () => const LearningChapter(id: '', title: 'Unknown', order: 0),
    );
    return chapter.title.isNotEmpty ? chapter.title : 'Chapter';
  }

  String _unitNameFor(LearningLesson? lesson, List<LearningUnit> units) {
    if (lesson == null) return 'First unit';
    final unit = units.firstWhere(
      (unit) => unit.id == lesson.unitId,
      orElse: () => const LearningUnit(id: '', chapterId: '', title: 'Unknown', order: 0),
    );
    return unit.title.isNotEmpty ? unit.title : 'Unit';
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<_StudentHomeData>(
          future: _screenFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data ?? const _StudentHomeData();
            final completedLessons =
                data.progress.where((item) => item.completed).length;
            final overallProgress = data.lessons.isEmpty
                ? 0.0
                : completedLessons / data.lessons.length;
            final nextLesson = _nextLesson(data);
            final journeyLessons = _journeyLessons(data);
            final homeReaction = _characterCoach.homeReaction(
              hasProgress: data.progress.isNotEmpty,
              streak: data.streak,
              xp: data.totalXP,
              overallProgress: overallProgress,
              nextLessonTitle: nextLesson?.title,
            );
            final nextChapterName = _chapterNameFor(nextLesson, data.chapters);
            final nextUnitName = _unitNameFor(nextLesson, data.units);
            final achievements = _buildAchievements(data);
            VoidCallback? openNextLesson;
            if (nextLesson != null) {
              final lessonToOpen = nextLesson;
              openNextLesson = () => _openLesson(lessonToOpen);
            }

            // Sort chapters and create chapter-based view
            final sortedChapters = _sortedChapters(data.chapters);

            // Show different views based on selected nav index
            Widget content;
            switch (_selectedNavIndex) {
              case 0: // Lessons & Chapters
                content = RefreshIndicator(
                  onRefresh: _refreshLessons,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    children: [
                      // Professional header with stats
                      _ProfessionalHeader(
                        studentName: userProvider.profile?.name ?? 'Student',
                        xp: data.totalXP,
                        level: userProvider.level,
                        streak: data.streak,
                        overallProgress: overallProgress,
                        lessonsCompleted: completedLessons,
                        totalLessons: data.lessons.length,
                        nextLessonTitle: nextLesson?.title ?? 'Your first adventure',
                        nextChapter: nextChapterName,
                        nextUnit: nextUnitName,
                        companion: homeReaction,
                        onContinue: openNextLesson,
                      ),
                      const SizedBox(height: 28),
                      if (journeyLessons.isNotEmpty) ...[
                        _LessonPathPreview(
                          lessons: journeyLessons.take(7).toList(),
                          allLessons: journeyLessons,
                          allChapters: sortedChapters,
                          progressByLessonId: data.progressByLessonId,
                          onOpenLesson: _openLesson,
                        ),
                        const SizedBox(height: 24),
                        _AdventureRewardsPanel(
                          streak: data.streak,
                          achievements: achievements,
                          companion: homeReaction.character,
                          onDailyTap: () {
                            setState(() {
                              _selectedNavIndex = 1;
                            });
                          },
                          onAchievementsTap: () {
                            setState(() {
                              _selectedNavIndex = 2;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        _BonusMissionPanel(
                          nextLessonTitle:
                              nextLesson?.title ?? 'Start your first lesson',
                          currentChapter: nextChapterName,
                          completedLessons: completedLessons,
                          totalLessons: data.lessons.length,
                          streak: data.streak,
                          onContinue: openNextLesson,
                          onDailyTap: () {
                            setState(() {
                              _selectedNavIndex = 1;
                            });
                          },
                          onRewardsTap: () {
                            setState(() {
                              _selectedNavIndex = 2;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                      ],

                      // No chapters - show flat lesson list
                      if (sortedChapters.isEmpty) ...[
                        if (data.lessons.isEmpty)
                          _EmptyLessonState(onRefresh: _refreshLessons)
                        else
                          ..._buildLessonList(
                            _sortedLessons(data.lessons),
                            data,
                            null,
                          ),
                      ]
                      // Chapters - show chapter-based view
                      else ...[
                        for (final chapter in sortedChapters)
                          _ChapterSection(
                            chapter: chapter,
                            allChapters: sortedChapters,
                            allLessons: data.lessons,
                            lessons: data.lessons
                                .where((l) => l.chapterId == chapter.id)
                                .toList(),
                            progressByLessonId: data.progressByLessonId,
                            onOpenLesson: _openLesson,
                          ),
                      ],
                    ],
                  ),
                );
                break;

              case 1: // Daily Challenge
                content = _DailyChallengeView(
                  userData: data,
                  userProvider: userProvider,
                );
                break;

              case 2: // Achievements
                content = _AchievementsView(
                  userData: data,
                  userProvider: userProvider,
                );
                break;

              case 3: // Profile
                content = const StudentProfileScreen();
                break;

              default:
                content = const SizedBox();
            }

            return content;
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            selectedIcon: Icon(Icons.auto_stories_rounded),
            icon: Icon(Icons.auto_stories_outlined),
            label: 'Lessons',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.emoji_events_rounded),
            icon: Icon(Icons.emoji_events_outlined),
            label: 'Daily',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.star_rounded),
            icon: Icon(Icons.star_outline_rounded),
            label: 'Achievements',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person_rounded),
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLessonList(
    List<LearningLesson> sortedLessons,
    _StudentHomeData data,
    LearningChapter? chapter,
  ) {
    return [
      for (int i = 0; i < sortedLessons.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ProfessionalLessonCard(
            lesson: sortedLessons[i],
            lessonNumber: i + 1,
            totalLessons: sortedLessons.length,
            progress: data.progressByLessonId[sortedLessons[i].id],
            isUnlocked: _isLessonUnlocked(
              sortedLessons[i],
              sortedLessons,
              data.progressByLessonId,
              data.chapters,
            ),
            chapterColor: _hexToColor(chapter?.colorHex ?? '0E7C86'),
            onTap: _isLessonUnlocked(
                    sortedLessons[i],
                    sortedLessons,
                    data.progressByLessonId,
                    data.chapters,
                  )
                ? () => _openLesson(sortedLessons[i])
                : null,
          ),
        ),
    ];
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    return Color(int.parse(hex, radix: 16) + 0xFF000000);
  }
}

class _AdventureContinueCard extends StatelessWidget {
  const _AdventureContinueCard({
    required this.nextLessonTitle,
    required this.currentChapter,
    required this.currentUnit,
    required this.lessonsCompleted,
    required this.totalLessons,
    required this.accentColor,
    required this.companionName,
    required this.onContinue,
  });

  final String nextLessonTitle;
  final String currentChapter;
  final String currentUnit;
  final int lessonsCompleted;
  final int totalLessons;
  final Color accentColor;
  final String companionName;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final progress = totalLessons == 0 ? 0.0 : lessonsCompleted / totalLessons;
    final isEnabled = onContinue != null;

    return Material(
      child: InkWell(
        onTap: onContinue,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accentColor,
                AppColors.primary.withValues(alpha: 0.92),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.24),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nextLessonTitle,
                          style: GoogleFonts.fredoka(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.surface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$currentChapter • $currentUnit',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.surface.withValues(alpha: 0.92),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: AppColors.surface,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '$companionName picked this next step for you.',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.surface.withValues(alpha: 0.92),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$lessonsCompleted of $totalLessons lessons completed',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.surface.withValues(alpha: 0.84),
                      ),
                    ),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w900,
                      color: AppColors.surface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: AppColors.surface.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.surface.withValues(alpha: 0.92),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: AppColors.surface,
                    foregroundColor: accentColor,
                    disabledBackgroundColor: AppColors.surface.withValues(alpha: 0.6),
                    disabledForegroundColor: AppColors.surface.withValues(alpha: 0.7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: Icon(
                    isEnabled ? Icons.arrow_forward_rounded : Icons.flag_rounded,
                  ),
                  label: Text(
                    isEnabled ? 'Continue adventure' : 'Curriculum coming soon',
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
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

class _EmptyLessonState extends StatelessWidget {
  const _EmptyLessonState({
    required this.onRefresh,
  });

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.menu_book_rounded,
            size: 54,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'No lessons available yet',
            style: GoogleFonts.fredoka(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Ask the admin to upload the starter curriculum, then pull to refresh and your game path will appear here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(
              'Refresh lessons',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

/// Professional header with student stats
class _ProfessionalHeader extends StatelessWidget {
  const _ProfessionalHeader({
    required this.studentName,
    required this.xp,
    required this.level,
    required this.streak,
    required this.overallProgress,
    required this.lessonsCompleted,
    required this.totalLessons,
    required this.nextLessonTitle,
    required this.nextChapter,
    required this.nextUnit,
    required this.companion,
    required this.onContinue,
  });

  final String studentName;
  final int xp;
  final int level;
  final int streak;
  final double overallProgress;
  final int lessonsCompleted;
  final int totalLessons;
  final String nextLessonTitle;
  final String nextChapter;
  final String nextUnit;
  final CharacterReaction companion;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF9EC),
            Colors.white,
            Color(0xFFEAF7FB),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi $studentName!',
                      style: GoogleFonts.fredoka(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your friend team is ready to guide your next learning quest.',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => const StudentProfileScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.1),
                          AppColors.primary.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: companion.character.secondaryColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: companion.character.primaryColor.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CharacterDisplay(
                  character: companion.character,
                  size: 76,
                  showName: false,
                  animated: true,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        companion.title,
                        style: GoogleFonts.fredoka(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: companion.character.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        companion.message,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          height: 1.45,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.star_rounded,
                  label: 'Level',
                  value: '$level',
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Hot streak',
                  value: '$streak days',
                  color: AppColors.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.bolt_rounded,
                  label: 'XP',
                  value: '$xp',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _AdventureContinueCard(
            nextLessonTitle: nextLessonTitle,
            currentChapter: nextChapter,
            currentUnit: nextUnit,
            lessonsCompleted: lessonsCompleted,
            totalLessons: totalLessons,
            accentColor: companion.accentColor,
            companionName: companion.character.name,
            onContinue: onContinue,
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Adventure map',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  Text(
                    '${(overallProgress * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'You are moving forward one lesson at a time.',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: overallProgress,
                  minHeight: 8,
                  backgroundColor: AppColors.success.withValues(alpha: 0.12),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.fredoka(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonPathPreview extends StatelessWidget {
  const _LessonPathPreview({
    required this.lessons,
    required this.allLessons,
    required this.allChapters,
    required this.progressByLessonId,
    required this.onOpenLesson,
  });

  final List<LearningLesson> lessons;
  final List<LearningLesson> allLessons;
  final List<LearningChapter> allChapters;
  final Map<String, StudentProgress> progressByLessonId;
  final Future<void> Function(LearningLesson lesson) onOpenLesson;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adventure path',
            style: GoogleFonts.fredoka(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap the glowing lesson circles to continue your journey.',
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int index = 0; index < lessons.length; index++) ...[
                  Builder(
                    builder: (context) {
                      final lesson = lessons[index];
                      final isUnlocked = _isLessonUnlocked(
                        lesson,
                        allLessons,
                        progressByLessonId,
                        allChapters,
                      );

                      return _LessonPathNode(
                        lesson: lesson,
                        progress: progressByLessonId[lesson.id],
                        isCurrent: isUnlocked &&
                            (progressByLessonId[lesson.id] == null ||
                                !(progressByLessonId[lesson.id]?.completed ?? false)),
                        isUnlocked: isUnlocked,
                        onTap: isUnlocked
                            ? () {
                                onOpenLesson(lesson);
                              }
                            : null,
                      );
                    },
                  ),
                  if (index != lessons.length - 1)
                    Container(
                      width: 38,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 36),
                      decoration: BoxDecoration(
                        color: progressByLessonId[lessons[index].id]?.completed == true
                            ? AppColors.success.withValues(alpha: 0.45)
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdventureRewardsPanel extends StatelessWidget {
  const _AdventureRewardsPanel({
    required this.streak,
    required this.achievements,
    required this.companion,
    required this.onDailyTap,
    required this.onAchievementsTap,
  });

  final int streak;
  final List<String> achievements;
  final app_char.Character companion;
  final VoidCallback onDailyTap;
  final VoidCallback onAchievementsTap;

  @override
  Widget build(BuildContext context) {
    final rewardCount = achievements.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF8FCFD),
            Color(0xFFFFF8EE),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reward corner',
            style: GoogleFonts.fredoka(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${companion.name} is keeping your streak, badges, and adventure energy glowing.',
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _RewardQuickCard(
                title: 'Daily streak',
                value: '$streak day${streak == 1 ? '' : 's'}',
                icon: Icons.local_fire_department_rounded,
                accent: const Color(0xFFE76F51),
                helper: streak == 0
                    ? 'Start your first streak today.'
                    : 'Come back tomorrow to keep the flame alive.',
                actionLabel: 'Daily mission',
                onTap: onDailyTap,
              ),
              _RewardQuickCard(
                title: 'Badges won',
                value: '$rewardCount',
                icon: Icons.workspace_premium_rounded,
                accent: AppColors.secondaryDark,
                helper: rewardCount == 0
                    ? 'Your first badge is waiting for you.'
                    : 'Open your badge shelf and see your wins.',
                actionLabel: 'View badges',
                onTap: onAchievementsTap,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Friend team',
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: app_char.Characters.all
                .map(
                  (character) => _CompanionToken(
                    character: character,
                    isActive: character.id == companion.id,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _RewardQuickCard extends StatelessWidget {
  const _RewardQuickCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
    required this.helper,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accent;
  final String helper;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 240,
        maxWidth: 320,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Ink(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: accent.withValues(alpha: 0.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: accent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            value,
                            style: GoogleFonts.fredoka(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  helper,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      actionLabel,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: accent,
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

class _CompanionToken extends StatelessWidget {
  const _CompanionToken({
    required this.character,
    required this.isActive,
  });

  final app_char.Character character;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? character.secondaryColor : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive
              ? character.primaryColor.withValues(alpha: 0.32)
              : AppColors.border,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CharacterDisplay(
            character: character,
            size: 42,
            showName: false,
            animated: isActive,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                character.name,
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              Text(
                character.role,
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isActive
                      ? character.primaryColor
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LessonPathNode extends StatelessWidget {
  const _LessonPathNode({
    required this.lesson,
    required this.progress,
    required this.isCurrent,
    required this.isUnlocked,
    required this.onTap,
  });

  final LearningLesson lesson;
  final StudentProgress? progress;
  final bool isCurrent;
  final bool isUnlocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final completed = progress?.completed ?? false;
    final baseColor = !isUnlocked
        ? AppColors.textTertiary
        : completed
            ? AppColors.success
            : isCurrent
                ? AppColors.primary
                : AppColors.secondaryDark;
    final icon = completed
        ? Icons.check_rounded
        : !isUnlocked
            ? Icons.lock_rounded
            : isCurrent
                ? Icons.play_arrow_rounded
                : Icons.circle_outlined;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    baseColor,
                    baseColor.withValues(alpha: 0.78),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: baseColor.withValues(alpha: isCurrent ? 0.30 : 0.20),
                    blurRadius: isCurrent ? 18 : 10,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 34),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 90,
              child: Text(
                lesson.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chapter section with lessons
class _ChapterSection extends StatelessWidget {
  const _ChapterSection({
    required this.chapter,
    required this.allChapters,
    required this.allLessons,
    required this.lessons,
    required this.progressByLessonId,
    required this.onOpenLesson,
  });

  final LearningChapter chapter;
  final List<LearningChapter> allChapters;
  final List<LearningLesson> allLessons;
  final List<LearningLesson> lessons;
  final Map<String, StudentProgress> progressByLessonId;
  final Function(LearningLesson) onOpenLesson;

  @override
  Widget build(BuildContext context) {
    final chapterColor = _hexToColor(chapter.colorHex);
    final sortedLessons = List<LearningLesson>.from(lessons)
      ..sort((a, b) => a.order.compareTo(b.order));
    final chapterUnlocked = _isChapterUnlocked(
      chapter.id,
      allChapters,
      allLessons,
      progressByLessonId,
    );
    final chapterGuide = _chapterGuideCharacter(chapter, allChapters);

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  chapterColor,
                  chapterColor.withValues(alpha: 0.78),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: chapterColor.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CharacterDisplay(
                      character: chapterGuide,
                      size: 54,
                      showName: false,
                      animated: chapterUnlocked,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _chapterGuideLine(chapter, allChapters, chapterUnlocked),
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.92),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  chapterUnlocked ? chapter.title : '${chapter.title} • Locked',
                  style: GoogleFonts.fredoka(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                if (chapter.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    chapterUnlocked
                        ? chapter.description
                        : 'Finish the previous chapter to unlock this adventure path.',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      chapterUnlocked
                          ? Icons.lock_open_rounded
                          : Icons.lock_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      chapterUnlocked ? 'Chapter unlocked' : 'Chapter locked',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(
            sortedLessons.length,
            (index) {
              final lesson = sortedLessons[index];
              final progress = progressByLessonId[lesson.id];
              final isUnlocked = _isLessonUnlocked(
                lesson,
                allLessons,
                progressByLessonId,
                allChapters,
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ProfessionalLessonCard(
                  lesson: lesson,
                  lessonNumber: index + 1,
                  totalLessons: sortedLessons.length,
                  progress: progress,
                  isUnlocked: isUnlocked,
                  chapterColor: chapterColor,
                  onTap: isUnlocked ? () => onOpenLesson(lesson) : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    return Color(int.parse(hex, radix: 16) + 0xFF000000);
  }
}

/// Professional lesson card - full width
class _ProfessionalLessonCard extends StatefulWidget {
  const _ProfessionalLessonCard({
    required this.lesson,
    required this.lessonNumber,
    required this.totalLessons,
    required this.progress,
    required this.isUnlocked,
    required this.chapterColor,
    required this.onTap,
  });

  final LearningLesson lesson;
  final int lessonNumber;
  final int totalLessons;
  final StudentProgress? progress;
  final bool isUnlocked;
  final Color chapterColor;
  final VoidCallback? onTap;

  @override
  State<_ProfessionalLessonCard> createState() => _ProfessionalLessonCardState();
}

class _ProfessionalLessonCardState extends State<_ProfessionalLessonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovering) {
    if (isHovering) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.progress?.completed ?? false;
    final progressPercent = widget.progress?.score ?? 0.0;
    final isPerfect = isCompleted && progressPercent == 100;

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_hoverController.value * 0.02),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08 * _hoverController.value),
                    blurRadius: 8 + (8 * _hoverController.value),
                    offset: Offset(0, 2 + (4 * _hoverController.value)),
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: Material(
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: widget.isUnlocked
                    ? LinearGradient(
                        colors: isCompleted
                            ? const [Color(0xFFE8F7F2), Color(0xFFD4F1E9)]
                            : const [Colors.white, Color(0xFFFAFBFC)],
                      )
                    : const LinearGradient(
                        colors: [Color(0xFFF5F7FA), Color(0xFFEEF2F7)],
                      ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isUnlocked
                      ? (isCompleted ? const Color(0xFF1A936F).withValues(alpha: 0.3) : widget.chapterColor.withValues(alpha: 0.2))
                      : const Color(0xFFCAD3DC).withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  // Lesson number with animation
                  ScaleTransition(
                    scale: Tween<double>(begin: 1.0, end: 1.1).animate(
                      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
                    ),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: widget.isUnlocked ? widget.chapterColor : const Color(0xFFB0BEC5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${widget.lessonNumber}',
                          style: GoogleFonts.fredoka(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Lesson info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.lesson.title,
                          style: GoogleFonts.fredoka(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              size: 13,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.lesson.duration} min',
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.bolt_rounded,
                              size: 13,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+${widget.lesson.xpReward} XP',
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                        if (isCompleted && progressPercent > 0) ...[
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progressPercent / 100,
                              minHeight: 4,
                              backgroundColor: AppColors.outline,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isPerfect ? AppColors.warning : AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Status icon with animation
                  ScaleTransition(
                    scale: Tween<double>(begin: 1.0, end: 1.2).animate(
                      CurvedAnimation(parent: _hoverController, curve: Curves.elasticOut),
                    ),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isCompleted
                          ? AppColors.success.withValues(alpha: 0.15)
                            : widget.isUnlocked
                                ? widget.chapterColor.withValues(alpha: 0.15)
                                : const Color(0xFF9BA3A8).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isCompleted
                            ? (isPerfect ? Icons.emoji_events_rounded : Icons.check_circle_rounded)
                            : widget.isUnlocked
                                ? Icons.play_circle_filled_rounded
                                : Icons.lock_rounded,
                        color: isCompleted
                          ? AppColors.success
                            : widget.isUnlocked
                                ? widget.chapterColor
                                : const Color(0xFF9BA3A8),
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BonusMissionPanel extends StatelessWidget {
  const _BonusMissionPanel({
    required this.nextLessonTitle,
    required this.currentChapter,
    required this.completedLessons,
    required this.totalLessons,
    required this.streak,
    required this.onContinue,
    required this.onDailyTap,
    required this.onRewardsTap,
  });

  final String nextLessonTitle;
  final String currentChapter;
  final int completedLessons;
  final int totalLessons;
  final int streak;
  final VoidCallback? onContinue;
  final VoidCallback onDailyTap;
  final VoidCallback onRewardsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE3EDF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bonus missions',
            style: GoogleFonts.fredoka(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'A few quick things to give the app more rhythm, rewards, and replay value.',
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MissionCard(
                icon: Icons.play_circle_fill_rounded,
                title: 'Story path',
                subtitle: '$currentChapter • $nextLessonTitle',
                accent: AppColors.secondary,
                actionLabel: onContinue == null ? 'Completed' : 'Continue',
                onTap: onContinue,
              ),
              _MissionCard(
                icon: Icons.local_fire_department_rounded,
                title: 'Streak spark',
                subtitle: '$streak-day streak and $completedLessons/$totalLessons lessons done',
                accent: AppColors.error,
                actionLabel: 'Open daily',
                onTap: onDailyTap,
              ),
              _MissionCard(
                icon: Icons.emoji_events_rounded,
                title: 'Trophy room',
                subtitle: 'Check badges, progress, and unlocked milestones',
                accent: AppColors.warning,
                actionLabel: 'See rewards',
                onTap: onRewardsTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.actionLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final String actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.fredoka(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
              ),
              child: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionMiniChip extends StatelessWidget {
  const _MissionMiniChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyMissionCard extends StatelessWidget {
  const _DailyMissionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.status,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1EAF0), width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.fredoka(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  status,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    color: accent,
                    fontSize: 12,
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

class _StudentHomeData {
  const _StudentHomeData({
    this.chapters = const <LearningChapter>[],
    this.units = const <LearningUnit>[],
    this.lessons = const <LearningLesson>[],
    this.progress = const <StudentProgress>[],
    this.totalXP = 0,
    this.streak = 0,
  });

  final List<LearningChapter> chapters;
  final List<LearningUnit> units;
  final List<LearningLesson> lessons;
  final List<StudentProgress> progress;
  final int totalXP;
  final int streak;

  Map<String, StudentProgress> get progressByLessonId {
    return {
      for (final item in progress) item.lessonId: item,
    };
  }
}

class _DailyChallengeView extends StatelessWidget {
  const _DailyChallengeView({
    required this.userData,
    required this.userProvider,
  });

  final _StudentHomeData userData;
  final UserProvider userProvider;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final completedLessons = userData.progress.where((item) => item.completed).length;
    final lessonsToday = userData.progress.where((item) {
      final date = DateTime(item.date.year, item.date.month, item.date.day);
      return item.completed && date == today;
    }).length;
    const dailyGoal = 3;
    final missionProgress = (lessonsToday / dailyGoal).clamp(0.0, 1.0);
    final remainingGoal = dailyGoal - lessonsToday;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily mission',
            style: GoogleFonts.fredoka(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.warning,
                  AppColors.error,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Mission',
                  style: GoogleFonts.fredoka(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  remainingGoal <= 0
                      ? 'Amazing. You finished today\'s mission and unlocked bonus momentum.'
                      : 'Complete $remainingGoal more ${remainingGoal == 1 ? 'lesson' : 'lessons'} to finish today\'s mission.',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: missionProgress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  '$lessonsToday of $dailyGoal lessons completed today',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _MissionMiniChip(
                      icon: Icons.local_fire_department_rounded,
                      label: '${userData.streak}-day streak',
                    ),
                    _MissionMiniChip(
                      icon: Icons.bolt_rounded,
                      label: '${userProvider.totalXP} XP earned',
                    ),
                    _MissionMiniChip(
                      icon: Icons.auto_stories_rounded,
                      label: '$completedLessons lessons done',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Mission boosters',
            style: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          _DailyMissionCard(
            icon: Icons.hearing_rounded,
            title: 'Listening lap',
            subtitle: 'Replay one sentence and match it with the right meaning.',
            accent: AppColors.accent,
            status: lessonsToday > 0 ? 'Unlocked today' : 'Warm-up task',
          ),
          const SizedBox(height: 12),
          _DailyMissionCard(
            icon: Icons.route_rounded,
            title: 'Sentence builder',
            subtitle: 'Use speaking and writing tasks as mini sentence puzzles.',
            accent: AppColors.success,
            status: completedLessons >= 2 ? 'Ready to practice' : 'Unlock after 2 lessons',
          ),
          const SizedBox(height: 12),
          _DailyMissionCard(
            icon: Icons.emoji_events_rounded,
            title: 'Reward trail',
            subtitle: 'Finish today\'s mission to keep your streak glowing and trophy room growing.',
            accent: AppColors.warning,
            status: remainingGoal <= 0 ? 'Completed' : '$remainingGoal lesson(s) left',
          ),
        ],
      ),
    );
  }
}

class _AchievementsView extends StatelessWidget {
  const _AchievementsView({
    required this.userData,
    required this.userProvider,
  });

  final _StudentHomeData userData;
  final UserProvider userProvider;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 1100
        ? 4
        : width >= 760
            ? 3
            : 2;
    final completedLessons = userData.progress.where((item) => item.completed).length;
    final perfectScores = userData.progress.where((item) => item.score >= 100).length;

    final achievements = <Map<String, dynamic>>[
      {
        'icon': Icons.auto_stories_rounded,
        'title': 'Bookworm',
        'description': 'Complete 5 lessons',
        'unlocked': completedLessons >= 5,
      },
      {
        'icon': Icons.flash_on_rounded,
        'title': 'Streak Master',
        'description': '7-day streak',
        'unlocked': userData.streak >= 7,
      },
      {
        'icon': Icons.emoji_events_rounded,
        'title': 'Champion',
        'description': 'Perfect score 5 times',
        'unlocked': perfectScores >= 5,
      },
      {
        'icon': Icons.star_rounded,
        'title': 'Rising Star',
        'description': 'Reach level 5',
        'unlocked': userProvider.level >= 5,
      },
      {
        'icon': Icons.local_fire_department_rounded,
        'title': 'Unstoppable',
        'description': 'Complete 20 lessons',
        'unlocked': completedLessons >= 20,
      },
      {
        'icon': Icons.pets_rounded,
        'title': 'Pet Master',
        'description': 'Keep exploring with your companion team',
        'unlocked': userData.progress.isNotEmpty,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trophy room',
            style: GoogleFonts.fredoka(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: achievement['unlocked']
                        ? [
                            AppColors.warning.withValues(alpha: 0.15),
                            AppColors.warning.withValues(alpha: 0.05),
                          ]
                        : [
                            Colors.grey.withValues(alpha: 0.1),
                            Colors.grey.withValues(alpha: 0.05),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: achievement['unlocked']
                        ? AppColors.warning.withValues(alpha: 0.3)
                        : Colors.grey.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          achievement['icon'],
                          size: 40,
                          color: achievement['unlocked']
                              ? AppColors.warning
                              : Colors.grey,
                        ),
                        if (!achievement['unlocked'])
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black12,
                            ),
                            child: const Icon(
                              Icons.lock_outline_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      achievement['title'],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement['description'],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF9AAFB8),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

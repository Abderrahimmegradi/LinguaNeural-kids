import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_ui/shared_ui.dart';

import '../theme/app_colors.dart';

class StudentDetailsScreen extends StatefulWidget {
  const StudentDetailsScreen({
    super.key,
    required this.student,
    required this.progress,
    this.completedLessons = 0,
    this.averageProgress = 0.0,
    this.totalXp = 0,
    this.streak = 0,
    this.lastActivity,
    this.schoolName,
  });

  final AppUserProfile student;
  final List<StudentProgress> progress;
  final int completedLessons;
  final double averageProgress;
  final int totalXp;
  final int streak;
  final DateTime? lastActivity;
  final String? schoolName;

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  final LessonService _lessonService = LessonService();
  late final ScrollController _scrollController;
  late final Future<Map<String, LearningLesson>> _lessonMapFuture;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _lessonMapFuture = _loadLessonMap();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<Map<String, LearningLesson>> _loadLessonMap() async {
    try {
      final lessons = await _lessonService.getLessons();
      return {
        for (final lesson in lessons) lesson.id: lesson,
      };
    } catch (_) {
      return <String, LearningLesson>{};
    }
  }

  String get _displaySchoolName {
    final value = widget.schoolName?.trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }
    return 'Learning team';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Just now';
    }
    if (diff.inHours < 1) {
      return '${diff.inMinutes} min ago';
    }
    if (diff.inDays == 0) {
      return 'Today';
    }
    if (diff.inDays == 1) {
      return 'Yesterday';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    }
    if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()} weeks ago';
    }
    return '${(diff.inDays / 30).floor()} months ago';
  }

  String _lessonTitleFor(
    StudentProgress lessonProgress,
    Map<String, LearningLesson> lessonMap,
    int index,
  ) {
    final lesson = lessonMap[lessonProgress.lessonId];
    if (lesson != null && lesson.title.trim().isNotEmpty) {
      return lesson.title.trim();
    }
    return 'Lesson ${index + 1}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                0,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.10),
                      foregroundColor: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Student Snapshot',
                          style: GoogleFonts.fredoka(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'A friendly overview of progress, energy, and wins.',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: FutureBuilder<Map<String, LearningLesson>>(
                future: _lessonMapFuture,
                builder: (context, snapshot) {
                  final lessonMap = snapshot.data ?? const <String, LearningLesson>{};

                  return ListView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.xxl,
                    ),
                    children: [
                      _StudentHeroCard(
                        name: widget.student.name,
                        email: widget.student.email,
                        schoolName: _displaySchoolName,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _AdventureProgressCard(
                        progress: widget.averageProgress,
                        completedLessons: widget.completedLessons,
                        trackedLessons: widget.progress.length,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _MagicStatsGrid(
                        totalXp: widget.totalXp,
                        streak: widget.streak,
                        lastActivity: widget.lastActivity == null
                            ? 'Ready for a first lesson'
                            : _formatDate(widget.lastActivity!),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lesson adventures',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Each card shows how the student is doing in class.',
                                  style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (widget.progress.isEmpty)
                        const _EmptyAdventureState()
                      else
                        ...widget.progress.asMap().entries.map((entry) {
                          final lessonProgress = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                            child: _LessonAdventureCard(
                              title: _lessonTitleFor(
                                lessonProgress,
                                lessonMap,
                                entry.key,
                              ),
                              score: lessonProgress.score,
                              xpEarned: lessonProgress.xpEarned,
                              isCompleted: lessonProgress.completed,
                            ),
                          );
                        }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentHeroCard extends StatelessWidget {
  const _StudentHeroCard({
    required this.name,
    required this.email,
    required this.schoolName,
  });

  final String name;
  final String email;
  final String schoolName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
            AppColors.info,
          ],
        ),
        boxShadow: AppShadows.elevatedShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(name),
              style: GoogleFonts.fredoka(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.fredoka(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.apartment_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          schoolName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

class _AdventureProgressCard extends StatelessWidget {
  const _AdventureProgressCard({
    required this.progress,
    required this.completedLessons,
    required this.trackedLessons,
  });

  final double progress;
  final int completedLessons;
  final int trackedLessons;

  @override
  Widget build(BuildContext context) {
    final progressValue = (progress / 100).clamp(0.0, 1.0);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.secondaryDark,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Adventure progress',
                      style: GoogleFonts.fredoka(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '$completedLessons of $trackedLessons tracked lessons completed',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${progress.toStringAsFixed(0)}%',
                style: GoogleFonts.fredoka(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 12,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MagicStatsGrid extends StatelessWidget {
  const _MagicStatsGrid({
    required this.totalXp,
    required this.streak,
    required this.lastActivity,
  });

  final int totalXp;
  final int streak;
  final String lastActivity;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MagicStatCard(
                icon: Icons.bolt_rounded,
                label: 'Star power',
                value: '$totalXp XP',
                accent: AppColors.secondaryDark,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _MagicStatCard(
                icon: Icons.local_fire_department_rounded,
                label: 'Hot streak',
                value: '$streak day${streak == 1 ? '' : 's'}',
                accent: AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _MagicStatCard(
          icon: Icons.schedule_rounded,
          label: 'Last learning moment',
          value: lastActivity,
          accent: AppColors.primary,
          fullWidth: true,
        ),
      ],
    );
  }
}

class _MagicStatCard extends StatelessWidget {
  const _MagicStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    this.fullWidth = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  maxLines: fullWidth ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.fredoka(
                    fontSize: fullWidth ? 18 : 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return card;
  }
}

class _LessonAdventureCard extends StatelessWidget {
  const _LessonAdventureCard({
    required this.title,
    required this.score,
    required this.xpEarned,
    required this.isCompleted,
  });

  final String title;
  final double score;
  final int xpEarned;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final isPerfect = score >= 100;
    final accent = isPerfect ? AppColors.secondaryDark : AppColors.primary;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
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
                      title,
                      style: GoogleFonts.fredoka(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      isCompleted ? 'Completed' : 'Still exploring',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isCompleted ? AppColors.success : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Text(
                  '${score.toStringAsFixed(0)}%',
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: LinearProgressIndicator(
              value: (score / 100).clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _SmallBadge(
                icon: Icons.bolt_rounded,
                label: '$xpEarned XP',
                accent: AppColors.secondaryDark,
              ),
              const SizedBox(width: AppSpacing.sm),
              _SmallBadge(
                icon: isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.auto_awesome_rounded,
                label: isCompleted ? 'Finished' : 'Keep going',
                accent: isCompleted ? AppColors.success : AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAdventureState extends StatelessWidget {
  const _EmptyAdventureState();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.xxl),
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              size: 38,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No lesson adventures yet',
            style: GoogleFonts.fredoka(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Once this learner starts playing through lessons, their progress cards will show up here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

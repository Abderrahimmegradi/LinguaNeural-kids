import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/models/character.dart';
import '../../core/models/learning_chapter.dart';
import '../../core/models/learning_lesson.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/firestore_learning_service.dart';
import '../widgets/animated_character_avatar.dart';
import 'student_profile_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key, this.onOpenProfile, this.onOpenLesson});

  final VoidCallback? onOpenProfile;
  final void Function(String? lessonId)? onOpenLesson;

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final FirestoreLearningService _learningService = FirestoreLearningService();
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _chapterSectionKeys = {};
  final Map<String, GlobalKey> _lessonKeys = {};

  late Future<_StudentHomeData> _screenFuture;
  String? _currentChapterId;
  String? _currentLessonId;
  bool _isCurrentChapterVisible = false;

  @override
  void initState() {
    super.initState();
    _screenFuture = _loadScreenData();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshLessons() async {
    final nextFuture = _loadScreenData();
    setState(() {
      _screenFuture = nextFuture;
    });
    await nextFuture;
  }

  Future<_StudentHomeData> _loadScreenData() async {
    final userProvider = context.read<UserProvider>();
    final userId = userProvider.currentUserId ?? 'student_demo';
    final bundle = await _learningService.loadHomeBundle(userId);

    userProvider.syncFromRemote(
      nextProfile: bundle.profile,
      nextTotalXp: bundle.totalXp,
      nextDailyStreak: bundle.dailyStreak,
      nextEmotion: bundle.currentEmotion,
      nextEvolutionStage: bundle.evolutionStage,
      nextMasteryScore: bundle.masteryScore,
    );

    return _StudentHomeData(
      chapters: bundle.chapters,
      lessons: bundle.lessons,
      lessonStates: bundle.lessonStates,
      unlockedChapterIds: bundle.unlockedChapterIds,
      completedLessonIds: bundle.completedLessonIds,
      currentLessonId: bundle.currentLessonId,
      badgesCount: bundle.badgesCount,
      activeCharacter: bundle.activeCharacter,
      masteryScore: bundle.masteryScore,
      momentumScore: bundle.momentumScore,
    );
  }

  void _openProfile() {
    if (widget.onOpenProfile != null) {
      widget.onOpenProfile!.call();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const StudentProfileScreen()),
    );
  }

  void _openLesson(String? lessonId) {
    if (widget.onOpenLesson != null) {
      widget.onOpenLesson!(lessonId);
      return;
    }
  }

  GlobalKey _chapterKey(String chapterId) {
    return _chapterSectionKeys.putIfAbsent(chapterId, GlobalKey.new);
  }

  GlobalKey _lessonKey(String lessonId) {
    return _lessonKeys.putIfAbsent(lessonId, GlobalKey.new);
  }

  void _handleScroll() {
    _updateCurrentChapterVisibility();
  }

  bool _isKeyVisibleInViewport(GlobalKey key) {
    if (!_scrollController.hasClients) {
      return false;
    }

    final targetContext = key.currentContext;
    final viewportContext = _scrollController.position.context.notificationContext;
    if (targetContext == null || viewportContext == null) {
      return false;
    }

    final targetRenderObject = targetContext.findRenderObject();
    final viewportRenderObject = viewportContext.findRenderObject();
    if (targetRenderObject is! RenderBox || viewportRenderObject is! RenderBox) {
      return false;
    }

    final viewportTop = viewportRenderObject.localToGlobal(Offset.zero).dy + 20;
    final viewportBottom = viewportTop + viewportRenderObject.size.height - 28;
    final targetTop = targetRenderObject.localToGlobal(Offset.zero).dy;
    final targetBottom = targetTop + targetRenderObject.size.height;

    final visibleTop = math.max(targetTop, viewportTop);
    final visibleBottom = math.min(targetBottom, viewportBottom);
    final visibleHeight = visibleBottom - visibleTop;
    final minimumVisibleHeight = math.min(
      140.0,
      math.max(48.0, targetRenderObject.size.height * 0.4),
    );

    return visibleHeight >= minimumVisibleHeight;
  }

  bool _isCurrentTargetVisible() {
    final lessonId = _currentLessonId;
    if (lessonId != null) {
      final lessonKey = _lessonKeys[lessonId];
      if (lessonKey != null && _isKeyVisibleInViewport(lessonKey)) {
        return true;
      }
    }

    final chapterId = _currentChapterId;
    if (chapterId == null) {
      return false;
    }

    final chapterKey = _chapterSectionKeys[chapterId];
    return chapterKey != null && _isKeyVisibleInViewport(chapterKey);
  }

  void _updateCurrentChapterVisibility() {
    if (_currentChapterId == null) {
      return;
    }

    final visible = _isCurrentTargetVisible();

    if (visible != _isCurrentChapterVisible && mounted) {
      setState(() {
        _isCurrentChapterVisible = visible;
      });
    }
  }

  Future<void> _jumpToCurrentTask() async {
    if (!_scrollController.hasClients) {
      return;
    }

    final chapterId = _currentChapterId;
    if (chapterId == null) {
      return;
    }

    final isVisibleNow = _isCurrentTargetVisible();
    if (isVisibleNow != _isCurrentChapterVisible && mounted) {
      setState(() {
        _isCurrentChapterVisible = isVisibleNow;
      });
    }

    if (isVisibleNow) {
      await _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 460),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    final lessonId = _currentLessonId;
    final context =
        (lessonId != null ? _lessonKeys[lessonId]?.currentContext : null) ??
        _chapterSectionKeys[chapterId]?.currentContext;
    if (context == null) {
      return;
    }

    await Scrollable.ensureVisible(
      context,
      alignment: 0.08,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
    );
  }

  String _greetingName(UserProvider user) {
    final displayName = user.profile?.displayName.trim();
    if (displayName != null &&
        displayName.isNotEmpty &&
        displayName.toLowerCase() != 'user' &&
        displayName.toLowerCase() != 'learner' &&
        displayName.toLowerCase() != 'student') {
      return displayName.split(RegExp(r'\s+')).first;
    }

    final email = user.profile?.email?.trim();
    if (email != null && email.contains('@')) {
      final localPart = email.split('@').first.trim();
      if (localPart.isNotEmpty) {
        return localPart;
      }
    }

    final authDisplayName = FirebaseAuth.instance.currentUser?.displayName?.trim();
    if (authDisplayName != null && authDisplayName.isNotEmpty) {
      return authDisplayName.split(RegExp(r'\s+')).first;
    }

    final authEmail = FirebaseAuth.instance.currentUser?.email?.trim();
    if (authEmail != null && authEmail.contains('@')) {
      final localPart = authEmail.split('@').first.trim();
      if (localPart.isNotEmpty) {
        return localPart;
      }
    }

    return 'Student';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<_StudentHomeData>(
          future: _screenFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'We could not load your lessons.',
                        style: _headingStyle(fontSize: 22),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Pull to refresh or try again now.',
                        style: _bodyStyle(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FilledButton(
                        onPressed: _refreshLessons,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = snapshot.data;
            if (data == null || data.lessons.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refreshLessons,
                child: const _EmptyLessonState(),
              );
            }

            final totalLessons = data.lessons.length;
            final completedCount = data.completedLessonIds.length;
            final overallCompletion = completedCount / totalLessons;
            final nextLesson = data.nextUnlockedLesson;
            _currentChapterId = data.currentChapterId;
            _currentLessonId = data.currentLessonId;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _updateCurrentChapterVisibility();
              }
            });

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
                  child: _QuestSummaryBar(
                    level: user.level,
                    streak: user.dailyStreak,
                    totalXp: user.totalXP,
                    masteryScore: user.masteryScore,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: Stack(
                    children: [
                      RefreshIndicator(
                        onRefresh: _refreshLessons,
                        child: ListView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            0,
                            AppSpacing.lg,
                            92,
                          ),
                          children: [
                            _ProfessionalHeader(
                              studentName: _greetingName(user),
                              level: user.level,
                              streak: user.dailyStreak,
                              totalXp: user.totalXP,
                              currentEmotion: user.currentEmotion,
                              evolutionStage: user.evolutionStage,
                              masteryScore: user.masteryScore,
                              momentumScore: data.momentumScore,
                              activeCharacter: data.activeCharacter,
                              nextLesson: nextLesson,
                              overallCompletion: overallCompletion,
                              completedCount: completedCount,
                              totalCount: totalLessons,
                              onProfilePressed: _openProfile,
                              onOpenLesson: _openLesson,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            _FocusPanel(
                              currentEmotion: user.currentEmotion,
                              masteryScore: user.masteryScore,
                              momentumScore: data.momentumScore,
                              streak: user.dailyStreak,
                              badgesCount: data.badgesCount,
                              evolutionStage: user.evolutionStage,
                              activeCharacter: data.activeCharacter,
                              nextLesson: nextLesson,
                              onOpenLesson: _openLesson,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            _SectionTitle(
                              title: 'Learning Map',
                              subtitle: 'Open the next lesson directly from the chapter that matters now.',
                            ),
                            const SizedBox(height: AppSpacing.md),
                            for (final chapter in data.chapters)
                              KeyedSubtree(
                                key: _chapterKey(chapter.id),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                                  child: _ChapterSection(
                                    chapter: chapter,
                                    chapterColor: _colorFromHex(chapter.colorHex),
                                    character: data.characterForChapter(chapter.id),
                                    isLocked: !data.unlockedChapterIds.contains(chapter.id),
                                    lessons: data.lessonsForChapter(chapter.id),
                                    lessonKeyBuilder: _lessonKey,
                                    statusForLesson: data.statusForLesson,
                                    progressForLesson: data.progressForLesson,
                                    onOpenLesson: _openLesson,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: AppSpacing.lg,
                        bottom: AppSpacing.lg,
                        child: FloatingActionButton.small(
                          heroTag: 'home-scroll-task',
                          backgroundColor: AppColors.surface,
                          foregroundColor: AppColors.primaryDark,
                          elevation: 8,
                          onPressed: _jumpToCurrentTask,
                          child: Icon(
                            _isCurrentChapterVisible
                                ? Icons.keyboard_double_arrow_up_rounded
                                : Icons.keyboard_double_arrow_down_rounded,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StudentHomeData {
  const _StudentHomeData({
    required this.chapters,
    required this.lessons,
    required this.lessonStates,
    required this.unlockedChapterIds,
    required this.completedLessonIds,
    required this.currentLessonId,
    required this.badgesCount,
    required this.activeCharacter,
    required this.masteryScore,
    required this.momentumScore,
  });

  final List<LearningChapter> chapters;
  final List<LearningLesson> lessons;
  final Map<String, LessonStateSnapshot> lessonStates;
  final Set<String> unlockedChapterIds;
  final Set<String> completedLessonIds;
  final String currentLessonId;
  final int badgesCount;
  final Character activeCharacter;
  final double masteryScore;
  final double momentumScore;

  List<LearningLesson> lessonsForChapter(String chapterId) {
    return lessons
        .where((lesson) => lesson.chapterId == chapterId)
        .toList(growable: false)
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  LearningLesson get nextUnlockedLesson {
    return lessons.firstWhere(
      (lesson) =>
          unlockedChapterIds.contains(lesson.chapterId) &&
          !completedLessonIds.contains(lesson.id),
      orElse: () => lessons.first,
    );
  }

  String get currentChapterId {
    return lessons.firstWhere(
      (lesson) => lesson.id == currentLessonId,
      orElse: () => nextUnlockedLesson,
    ).chapterId;
  }

  Character characterForChapter(String chapterId) {
    final chapterOrder = chapters.firstWhere((chapter) => chapter.id == chapterId).order;
    return Character.characters[(chapterOrder - 1) % Character.characters.length];
  }

  _LessonVisualStatus statusForLesson(LearningLesson lesson) {
    if (!unlockedChapterIds.contains(lesson.chapterId)) {
      return _LessonVisualStatus.locked;
    }
    if (completedLessonIds.contains(lesson.id)) {
      return _LessonVisualStatus.completed;
    }
    if (lesson.id == currentLessonId) {
      return _LessonVisualStatus.current;
    }
    return _LessonVisualStatus.upcoming;
  }

  double progressForLesson(LearningLesson lesson) {
    final lessonState = lessonStates[lesson.id];
    if (lessonState != null) {
      return lessonState.progress;
    }
    if (lesson.id == currentLessonId) {
      return (0.2 + (momentumScore * 0.45)).clamp(0, 0.8);
    }
    return 0;
  }
}

enum _LessonVisualStatus { completed, current, locked, upcoming }

class _ProfessionalHeader extends StatelessWidget {
  const _ProfessionalHeader({
    required this.studentName,
    required this.level,
    required this.streak,
    required this.totalXp,
    required this.currentEmotion,
    required this.evolutionStage,
    required this.masteryScore,
    required this.momentumScore,
    required this.activeCharacter,
    required this.nextLesson,
    required this.overallCompletion,
    required this.completedCount,
    required this.totalCount,
    required this.onProfilePressed,
    required this.onOpenLesson,
  });

  final String studentName;
  final int level;
  final int streak;
  final int totalXp;
  final String currentEmotion;
  final String evolutionStage;
  final double masteryScore;
  final double momentumScore;
  final Character activeCharacter;
  final LearningLesson nextLesson;
  final double overallCompletion;
  final int completedCount;
  final int totalCount;
  final VoidCallback onProfilePressed;
  final void Function(String? lessonId) onOpenLesson;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Hi $studentName!',
                style: _headingStyle(fontSize: 30),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.outline),
              ),
              child: IconButton(
                onPressed: onProfilePressed,
                icon: const Icon(Icons.person_rounded),
                color: AppColors.text,
                tooltip: 'Open profile',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [activeCharacter.secondaryColor, AppColors.surface],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: activeCharacter.primaryColor.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedCharacterAvatar(character: activeCharacter, size: 58, highlighted: true),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${activeCharacter.name} is with you today', style: _headingStyle(fontSize: 20)),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _characterWelcomeLine(
                            character: activeCharacter,
                            nextLesson: nextLesson,
                            currentEmotion: currentEmotion,
                            masteryScore: masteryScore,
                          ),
                          style: _bodyStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _adaptiveJourneyLine(
                  currentEmotion: currentEmotion,
                  momentumScore: momentumScore,
                  masteryScore: masteryScore,
                ),
                style: _bodyStyle(color: AppColors.primaryDark, weight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.lg),
              InkWell(
                onTap: () => onOpenLesson(nextLesson.id),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                child: Ink(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Continue lesson', style: _bodyStyle(color: AppColors.surface, weight: FontWeight.w900)),
                            const SizedBox(height: AppSpacing.xs),
                            Text(nextLesson.title, style: _headingStyle(fontSize: 22, color: AppColors.surface)),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '${nextLesson.duration} min • ${nextLesson.xpReward} XP',
                              style: _bodyStyle(color: AppColors.surface),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_rounded, color: AppColors.surface),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Overall Progress', style: _headingStyle(fontSize: 18)),
                  Text('$completedCount/$totalCount lessons', style: _bodyStyle()),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                child: LinearProgressIndicator(
                  value: overallCompletion,
                  minHeight: 12,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Momentum ${(momentumScore * 100).round()}%',
                      style: _bodyStyle(weight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    _titleCase(evolutionStage),
                    style: _bodyStyle(color: AppColors.textSecondary, weight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _EmotionJourneyBand(
                currentEmotion: currentEmotion,
                masteryScore: masteryScore,
                momentumScore: momentumScore,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChapterSection extends StatelessWidget {
  const _ChapterSection({
    required this.chapter,
    required this.chapterColor,
    required this.character,
    required this.isLocked,
    required this.lessons,
    required this.lessonKeyBuilder,
    required this.statusForLesson,
    required this.progressForLesson,
    required this.onOpenLesson,
  });

  final LearningChapter chapter;
  final Color chapterColor;
  final Character character;
  final bool isLocked;
  final List<LearningLesson> lessons;
  final GlobalKey Function(String lessonId) lessonKeyBuilder;
  final _LessonVisualStatus Function(LearningLesson lesson) statusForLesson;
  final double Function(LearningLesson lesson) progressForLesson;
  final void Function(String? lessonId) onOpenLesson;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [chapterColor, chapterColor.withValues(alpha: 0.72)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.xl),
                topRight: Radius.circular(AppRadius.xl),
              ),
            ),
            child: Row(
              children: [
                AnimatedCharacterAvatar(character: character, size: 56, highlighted: true),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(chapter.title, style: _headingStyle(fontSize: 22, color: AppColors.surface)),
                      const SizedBox(height: AppSpacing.xs),
                      Text(chapter.description, style: _bodyStyle(color: AppColors.surface)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                        color: AppColors.surface,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        isLocked ? 'Locked' : 'Unlocked',
                        style: _bodyStyle(color: AppColors.surface, weight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                for (var index = 0; index < lessons.length; index++) ...[
                  KeyedSubtree(
                    key: lessonKeyBuilder(lessons[index].id),
                    child: _ProfessionalLessonCard(
                      lessonNumber: index + 1,
                      lesson: lessons[index],
                      status: statusForLesson(lessons[index]),
                      progress: progressForLesson(lessons[index]),
                      onTap: () => onOpenLesson(lessons[index].id),
                    ),
                  ),
                  if (index < lessons.length - 1) const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfessionalLessonCard extends StatefulWidget {
  const _ProfessionalLessonCard({
    required this.lessonNumber,
    required this.lesson,
    required this.status,
    required this.progress,
    required this.onTap,
  });

  final int lessonNumber;
  final LearningLesson lesson;
  final _LessonVisualStatus status;
  final double progress;
  final VoidCallback onTap;

  @override
  State<_ProfessionalLessonCard> createState() => _ProfessionalLessonCardState();
}

class _ProfessionalLessonCardState extends State<_ProfessionalLessonCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final statusMeta = _statusMeta(widget.status);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.02 : 1,
        duration: const Duration(milliseconds: 180),
        child: InkWell(
          onTap: widget.status == _LessonVisualStatus.locked ? null : widget.onTap,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Ink(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.outline),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: statusMeta.backgroundColor,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                      child: Text(
                        '${widget.lessonNumber}',
                        style: _headingStyle(fontSize: 18, color: statusMeta.foregroundColor),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.lesson.title, style: _headingStyle(fontSize: 18)),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '${widget.lesson.duration} min • ${widget.lesson.xpReward} XP',
                            style: _bodyStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(statusMeta.icon, color: statusMeta.foregroundColor),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          switch (widget.status) {
                            _LessonVisualStatus.completed => 'Review',
                            _LessonVisualStatus.current => 'Start',
                            _LessonVisualStatus.upcoming => 'Open',
                            _LessonVisualStatus.locked => 'Locked',
                          },
                          style: _bodyStyle(color: statusMeta.foregroundColor, weight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ],
                ),
                if (widget.progress > 0) ...[
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    child: LinearProgressIndicator(
                      value: widget.progress,
                      minHeight: 10,
                      backgroundColor: AppColors.outline,
                      valueColor: AlwaysStoppedAnimation<Color>(statusMeta.foregroundColor),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FocusPanel extends StatelessWidget {
  const _FocusPanel({
    required this.currentEmotion,
    required this.masteryScore,
    required this.momentumScore,
    required this.streak,
    required this.badgesCount,
    required this.evolutionStage,
    required this.activeCharacter,
    required this.nextLesson,
    required this.onOpenLesson,
  });

  final String currentEmotion;
  final double masteryScore;
  final double momentumScore;
  final int streak;
  final int badgesCount;
  final String evolutionStage;
  final Character activeCharacter;
  final LearningLesson nextLesson;
  final void Function(String? lessonId) onOpenLesson;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Today\'s focus', style: _headingStyle(fontSize: 20)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Keep the next step obvious and the learning rhythm calm.',
                      style: _bodyStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              AnimatedCharacterAvatar(character: activeCharacter, size: 50, highlighted: true),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: _MiniFocusCard(label: 'Streak', value: '$streak days', icon: Icons.local_fire_department_rounded)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _MiniFocusCard(label: 'Badges', value: '$badgesCount unlocked', icon: Icons.workspace_premium_rounded)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _MiniFocusCard(label: 'Stage', value: _titleCase(evolutionStage), icon: Icons.trending_up_rounded)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: () => onOpenLesson(nextLesson.id),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Ink(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Row(
                children: [
                  const Icon(Icons.play_circle_fill_rounded, color: AppColors.primary, size: 32),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Next stop', style: _bodyStyle(color: AppColors.textSecondary, weight: FontWeight.w800)),
                        const SizedBox(height: AppSpacing.xs),
                        Text(nextLesson.title, style: _headingStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniFocusCard extends StatelessWidget {
  const _MiniFocusCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: _headingStyle(fontSize: 16)),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: _bodyStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _EmptyLessonState extends StatelessWidget {
  const _EmptyLessonState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const SizedBox(height: 120),
        Icon(Icons.school_outlined, color: AppColors.textSecondary.withValues(alpha: 0.6), size: 72),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'No lessons yet',
          textAlign: TextAlign.center,
          style: _headingStyle(fontSize: 24),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Your adventure path will appear here once lessons are loaded.',
          textAlign: TextAlign.center,
          style: _bodyStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _headingStyle(fontSize: 22)),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle, style: _bodyStyle(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _QuestSummaryBar extends StatelessWidget {
  const _QuestSummaryBar({
    required this.level,
    required this.streak,
    required this.totalXp,
    required this.masteryScore,
  });

  final int level;
  final int streak;
  final int totalXp;
  final double masteryScore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.outline),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _QuestStatItem(
              icon: Icons.bolt_rounded,
              color: AppColors.primary,
              value: '$totalXp',
            ),
          ),
          Expanded(
            child: _QuestStatItem(
              icon: Icons.military_tech_rounded,
              color: AppColors.secondaryDark,
              value: '$level',
            ),
          ),
          Expanded(
            child: _QuestStatItem(
              icon: Icons.local_fire_department_rounded,
              color: AppColors.warning,
              value: '$streak',
            ),
          ),
          Expanded(
            child: _QuestStatItem(
              icon: Icons.auto_awesome_rounded,
              color: AppColors.primaryDark,
              value: '${(masteryScore * 100).round()}%',
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestStatItem extends StatelessWidget {
  const _QuestStatItem({
    required this.icon,
    required this.color,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _headingStyle(fontSize: 18, color: color),
          ),
        ),
      ],
    );
  }
}

class _StatusMeta {
  const _StatusMeta({
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.iconColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color iconColor;
}

_StatusMeta _statusMeta(_LessonVisualStatus status) {
  switch (status) {
    case _LessonVisualStatus.completed:
      return const _StatusMeta(
        icon: Icons.check_rounded,
        backgroundColor: AppColors.success,
        foregroundColor: AppColors.success,
        iconColor: AppColors.surface,
      );
    case _LessonVisualStatus.current:
      return const _StatusMeta(
        icon: Icons.play_arrow_rounded,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primary,
        iconColor: AppColors.surface,
      );
    case _LessonVisualStatus.locked:
      return const _StatusMeta(
        icon: Icons.lock_rounded,
        backgroundColor: AppColors.surfaceVariant,
        foregroundColor: AppColors.textSecondary,
        iconColor: AppColors.textSecondary,
      );
    case _LessonVisualStatus.upcoming:
      return const _StatusMeta(
        icon: Icons.radio_button_unchecked_rounded,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textSecondary,
        iconColor: AppColors.textSecondary,
      );
  }
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

String _titleCase(String value) {
  if (value.isEmpty) {
    return value;
  }
  return value
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

class _EmotionJourneyBand extends StatelessWidget {
  const _EmotionJourneyBand({
    required this.currentEmotion,
    required this.masteryScore,
    required this.momentumScore,
  });

  final String currentEmotion;
  final double masteryScore;
  final double momentumScore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              Text('Emotion journey', style: _headingStyle(fontSize: 16)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Today: ${_titleCase(currentEmotion)}. The lesson pace adapts to you.',
            style: _bodyStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: _miniMeter('Focus', momentumScore, AppColors.primaryDark)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _miniMeter('Confidence', masteryScore, AppColors.secondaryDark)),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _miniMeter(String label, double value, Color color) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: _bodyStyle(weight: FontWeight.w700)),
      const SizedBox(height: AppSpacing.xs),
      ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: LinearProgressIndicator(
          value: value.clamp(0, 1),
          minHeight: 8,
          backgroundColor: AppColors.outline,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    ],
  );
}

String _characterWelcomeLine({
  required Character character,
  required LearningLesson nextLesson,
  required String currentEmotion,
  required double masteryScore,
}) {
  switch (character.id) {
    case 'baby':
      return '"We go softly. ${nextLesson.title} is ready."';
    case 'nexo':
      return '"Next step: ${nextLesson.title.toLowerCase()}. Stay focused."';
    case 'owl':
      return '"Breathe. ${nextLesson.title} is a calm step."';
    default:
      return masteryScore >= 0.7
          ? '"Strong energy today. ${nextLesson.title.toLowerCase()} is next."'
          : '"${_titleCase(currentEmotion)} today. ${nextLesson.title.toLowerCase()} is next."';
  }
}

String _adaptiveJourneyLine({
  required String currentEmotion,
  required double momentumScore,
  required double masteryScore,
}) {
  if (currentEmotion == 'frustrated' || masteryScore < 0.45) {
    return 'Support mode: slower prompts and easier recovery.';
  }
  if (momentumScore > 0.75) {
    return 'Momentum mode: quicker wins and stronger rhythm.';
  }
  return 'Balance mode: calm coaching and steady progress.';
}
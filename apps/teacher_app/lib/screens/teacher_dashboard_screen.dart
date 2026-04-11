import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import 'student_details_screen.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  final _userService = UserService();
  final _progressService = ProgressService();
  final _emotionService = EmotionService();
  final _managedUserService = AdminManagementService();
  final _studentNameController = TextEditingController();
  final _studentEmailController = TextEditingController();
  final _studentPasswordController = TextEditingController();

  bool _isBusy = false;
  String? _statusMessage;
  late Future<List<AppUserProfile>> _studentsFuture;
  late Future<String> _schoolNameFuture;
  String? _cachedTeacherId;
  String? _cachedSchoolId;

  @override
  void initState() {
    super.initState();
    final profile = context.read<UserProvider>().profile;
    _cachedTeacherId = profile?.id;
    _cachedSchoolId = profile?.schoolId;
    _studentsFuture = _loadStudents();
    _schoolNameFuture = _loadSchoolName();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTeacherScope();
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    _studentEmailController.dispose();
    _studentPasswordController.dispose();
    super.dispose();
  }

  Future<List<AppUserProfile>> _loadStudents() {
    if (_cachedTeacherId == null || _cachedTeacherId!.isEmpty) {
      return Future.value(const <AppUserProfile>[]);
    }

    try {
      final teacherId = _cachedTeacherId!;
      return _userService.getStudents(
        schoolId: (_cachedSchoolId == null || _cachedSchoolId!.isEmpty)
            ? null
            : _cachedSchoolId,
        teacherId: teacherId,
        includeLegacyTeacherlessForSchool: true,
      );
    } catch (_) {
      return Future.value(const <AppUserProfile>[]);
    }
  }

  void _syncTeacherScope() {
    final profile = context.read<UserProvider>().profile;
    final nextTeacherId = profile?.id;
    final nextSchoolId = profile?.schoolId;
    final teacherChanged = nextTeacherId != _cachedTeacherId;
    final schoolChanged = nextSchoolId != _cachedSchoolId;

    if (!teacherChanged && !schoolChanged) {
      return;
    }

    _cachedTeacherId = nextTeacherId;
    _cachedSchoolId = nextSchoolId;
    _studentsFuture = _loadStudents();
    _schoolNameFuture = _loadSchoolName();
  }

  Future<String> _loadSchoolName() async {
    final schoolId = _cachedSchoolId;
    if (schoolId == null || schoolId.isEmpty) {
      return 'My school';
    }

    try {
      final schoolUserDoc =
          await FirebaseFirestore.instance.collection('users').doc(schoolId).get();
      if (schoolUserDoc.exists) {
        final profile = AppUserProfile.fromFirestore(schoolUserDoc);
        if (profile.role == UserRole.school && profile.name.isNotEmpty) {
          return profile.name;
        }
      }
    } catch (_) {
      return 'My school';
    }

    return 'My school';
  }

  Future<void> _refreshStudents() async {
    final refreshed = _loadStudents();
    setState(() {
      _studentsFuture = refreshed;
      _schoolNameFuture = _loadSchoolName();
    });
    await refreshed;
  }

  Future<_ClassSnapshot> _loadClassSnapshot(List<AppUserProfile> students) async {
    if (students.isEmpty) {
      return const _ClassSnapshot();
    }

    final progressEntries = await Future.wait(
      students.map(
        (student) => _progressService.getProgressForStudent(student.id),
      ),
    );

    var totalXp = 0;
    var averageAccumulator = 0.0;
    var trackedStudents = 0;
    var bestStreak = 0;

    for (final progress in progressEntries) {
      totalXp += progress.fold<int>(0, (total, item) => total + item.xpEarned);
      if (progress.isNotEmpty) {
        trackedStudents++;
        averageAccumulator += progress
                .map((item) => item.score)
                .reduce((left, right) => left + right) /
            progress.length;
      }
      final streak = _calculateStreak(progress);
      if (streak > bestStreak) {
        bestStreak = streak;
      }
    }

    return _ClassSnapshot(
      totalXp: totalXp,
      averageProgress:
          trackedStudents == 0 ? 0 : averageAccumulator / trackedStudents,
      bestStreak: bestStreak,
    );
  }

  String? _validateStudentInputs() {
    if (_studentNameController.text.trim().isEmpty) {
      return 'Student name is required.';
    }
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(_studentEmailController.text.trim())) {
      return 'Enter a valid student email.';
    }
    if (_studentPasswordController.text.trim().length < 8) {
      return 'Student password must be at least 8 characters.';
    }
    return null;
  }

  void _resetStudentInputs() {
    _studentNameController.clear();
    _studentEmailController.clear();
    _studentPasswordController.clear();
  }

  Future<bool> _createStudent() async {
    final validationError = _validateStudentInputs();
    if (validationError != null) {
      setState(() => _statusMessage = validationError);
      return false;
    }
    final profile = context.read<UserProvider>().profile;
    if (profile == null) {
      setState(() => _statusMessage = 'Teacher profile is missing.');
      return false;
    }
    if (profile.id.isEmpty) {
      setState(() => _statusMessage = 'Teacher account is missing.');
      return false;
    }
    if (profile.schoolId == null || profile.schoolId!.isEmpty) {
      setState(() => _statusMessage = 'Teacher school is missing.');
      return false;
    }
    setState(() {
      _isBusy = true;
      _statusMessage = null;
    });
    try {
      await _managedUserService.createManagedUser(
        name: _studentNameController.text.trim(),
        email: _studentEmailController.text.trim(),
        password: _studentPasswordController.text.trim(),
        role: UserRole.student,
        schoolId: profile.schoolId!,
        teacherId: profile.id,
      );
      _resetStudentInputs();

      await Future.delayed(const Duration(milliseconds: 500));
      await _refreshStudents();
      if (!mounted) {
        return false;
      }
      setState(() => _statusMessage = 'Student created successfully.');
      return true;
    } catch (e) {
      if (!mounted) {
        return false;
      }
      setState(() => _statusMessage = 'Student creation failed: $e');
      return false;
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _showAddStudentDialog() async {
    _resetStudentInputs();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        var isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> submit() async {
              setDialogState(() {
                isSubmitting = true;
              });
              final created = await _createStudent();
              if (!context.mounted || !dialogContext.mounted) {
                return;
              }
              setDialogState(() {
                isSubmitting = false;
              });
              if (created && Navigator.of(dialogContext).canPop()) {
                Navigator.of(dialogContext).pop();
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              titlePadding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
                0,
              ),
              contentPadding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                0,
              ),
              actionsPadding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              title: Text(
                'Add Student',
                style: AppTypography.headlineLarge,
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create a new student account linked to your classroom.',
                        style: AppTypography.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      TextField(
                        controller: _studentNameController,
                        textInputAction: TextInputAction.next,
                        decoration: _buildInputDecoration(
                          'Student name',
                          'Enter full name',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextField(
                        controller: _studentEmailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: _buildInputDecoration(
                          'Student email',
                          'student@example.com',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextField(
                        controller: _studentPasswordController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) async => submit(),
                        decoration: _buildInputDecoration(
                          'Temporary password',
                          'Minimum 8 characters',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSubmitting ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: isSubmitting ? null : submit,
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  InputDecoration _buildInputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: AppColors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Future<void> _editStudent(AppUserProfile student) async {
    final nameController = TextEditingController(text: student.name);
    final emailController = TextEditingController(text: student.email);
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit student'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Student name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Student email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current password for auth update',
                  hintText: 'Required only to change email or password',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New password',
                  hintText: 'Optional',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save changes'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      nameController.dispose();
      emailController.dispose();
      currentPasswordController.dispose();
      newPasswordController.dispose();
      return;
    }

    setState(() {
      _isBusy = true;
      _statusMessage = null;
    });
    try {
      await _managedUserService.updateManagedUser(
        originalProfile: student,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        schoolId: student.schoolId ?? _cachedSchoolId ?? 'school_pending',
        teacherId: student.teacherId ?? _cachedTeacherId,
        currentPassword: currentPasswordController.text.trim(),
        newPassword: newPasswordController.text.trim(),
      );
      await _refreshStudents();
      if (!mounted) return;
      setState(() => _statusMessage = 'Student updated successfully.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _statusMessage = 'Student update failed: $e');
    } finally {
      nameController.dispose();
      emailController.dispose();
      currentPasswordController.dispose();
      newPasswordController.dispose();
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _deleteStudent(AppUserProfile student) async {
    final passwordController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This removes the student profile and all related progress data.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current password for Firebase Auth deletion',
                hintText: 'Optional',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete student'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      passwordController.dispose();
      return;
    }
    setState(() => _isBusy = true);
    try {
      await _managedUserService.deleteManagedUser(
        user: student,
        currentPassword: passwordController.text.trim(),
      );
      await _refreshStudents();
      if (!mounted) return;
      setState(() {
        _statusMessage = passwordController.text.trim().isEmpty
            ? 'Student removed from Firestore and learning data. Firebase Auth deletion was skipped because no password was provided.'
            : 'Student deleted successfully.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _statusMessage = 'Student deletion failed: $e');
    } finally {
      passwordController.dispose();
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<_StudentInsight> _loadStudentInsight(String studentId) async {
    final results = await Future.wait([
      _progressService.getProgressForStudent(studentId),
      _emotionService.getEmotionsForStudent(studentId),
    ]);
    final progress = results[0] as List<StudentProgress>;
    final emotions = results[1] as List<EmotionRecord>;
    final completedLessons = progress.where((item) => item.completed).length;
    final averageProgress = progress.isEmpty
        ? 0.0
        : progress
                .map((item) => item.score)
                .reduce((left, right) => left + right) /
            progress.length;
    final totalXp = progress.fold<int>(0, (total, item) => total + item.xpEarned);
    final streakDays = _calculateStreak(progress);
    return _StudentInsight(
      progress: progress,
      latestEmotion: emotions.isEmpty ? null : emotions.first,
      completedLessons: completedLessons,
      averageProgress: averageProgress,
      totalXp: totalXp,
      streakDays: streakDays,
      lastActivity: progress.isEmpty ? null : progress.first.date,
    );
  }

  int _calculateStreak(List<StudentProgress> progress) {
    if (progress.isEmpty) {
      return 0;
    }

    final uniqueDays = progress
        .map((entry) => DateTime(entry.date.year, entry.date.month, entry.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (uniqueDays.isEmpty) {
      return 0;
    }

    var streak = 1;
    for (var index = 1; index < uniqueDays.length; index++) {
      final previous = uniqueDays[index - 1];
      final current = uniqueDays[index];
      if (previous.difference(current).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  Future<void> _showStudentDetails(
    AppUserProfile student,
    _StudentInsight insight,
  ) async {
    final schoolName = await _loadSchoolName();
    if (!mounted) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentDetailsScreen(
          student: student,
          progress: insight.progress,
          completedLessons: insight.completedLessons,
          averageProgress: insight.averageProgress,
          totalXp: insight.totalXp,
          streak: insight.streakDays,
          lastActivity: insight.lastActivity,
          schoolName: schoolName,
        ),
      ),
    );
  }

  bool _isSuccessMessage(String message) {
    return message.toLowerCase().contains('success');
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            FutureBuilder<List<AppUserProfile>>(
              future: _studentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final students = snapshot.data ?? const <AppUserProfile>[];
                return RefreshIndicator(
                  onRefresh: _refreshStudents,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.lg,
                          AppSpacing.lg,
                          AppSpacing.xxl,
                        ),
                        children: [
                          FutureBuilder<String>(
                            future: _schoolNameFuture,
                            builder: (context, schoolSnapshot) {
                              final schoolName = schoolSnapshot.data ?? 'My school';
                              return _TeacherHeader(
                                teacherName: userProvider.profile?.name ?? 'Teacher',
                                studentCount: students.length,
                                schoolName: schoolName,
                                onAddStudent: _showAddStudentDialog,
                                onLogout: userProvider.signOut,
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          FutureBuilder<_ClassSnapshot>(
                            future: _loadClassSnapshot(students),
                            builder: (context, classSnapshot) {
                              final summary =
                                  classSnapshot.data ?? const _ClassSnapshot();
                              return _ClassSnapshotStrip(
                                totalStudents: students.length,
                                totalXp: summary.totalXp,
                                averageProgress: summary.averageProgress,
                                bestStreak: summary.bestStreak,
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          if (_statusMessage != null) ...[
                            _StatusBanner(
                              message: _statusMessage!,
                              isSuccess: _isSuccessMessage(_statusMessage!),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                          ],
                          _SectionHeader(
                            title: 'Students',
                            subtitle:
                                'Track classroom progress, support learners, and manage student accounts.',
                            actionLabel: 'Add Student',
                            onActionPressed: _showAddStudentDialog,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          if (students.isEmpty)
                            _TeacherEmptyState(
                              onAddStudent: _showAddStudentDialog,
                            )
                          else
                            ...students.map(
                              (student) => Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                                child: _TeacherStudentCard(
                                  student: student,
                                  insightFuture: _loadStudentInsight(student.id),
                                  onEdit: () => _editStudent(student),
                                  onDelete: () => _deleteStudent(student),
                                  onViewDetails: (insight) =>
                                      _showStudentDetails(student, insight),
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
            if (_isBusy)
              Container(
                color: Colors.black.withValues(alpha: 0.08),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

class _TeacherHeader extends StatelessWidget {
  const _TeacherHeader({
    required this.teacherName,
    required this.schoolName,
    required this.studentCount,
    required this.onAddStudent,
    required this.onLogout,
  });

  final String teacherName;
  final String schoolName;
  final int studentCount;
  final VoidCallback onAddStudent;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        boxShadow: AppShadows.elevatedShadow,
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
                      'Teacher Dashboard',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      teacherName,
                      style: AppTypography.displaySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      schoolName,
                      style: AppTypography.bodyLarge.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  onLogout();
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                ),
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _HeaderMetricCard(
                  label: 'Total students',
                  value: '$studentCount',
                  icon: Icons.groups_rounded,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _HeaderMetricCard(
                  label: 'School',
                  value: schoolName,
                  icon: Icons.apartment_rounded,
                  isValueCompact: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddStudent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryDark,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: Text(
                'Add Student',
                style: AppTypography.buttonText.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderMetricCard extends StatelessWidget {
  const _HeaderMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    this.isValueCompact = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isValueCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.74),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: (isValueCompact
                          ? AppTypography.headlineSmall
                          : AppTypography.headlineLarge)
                      .copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
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

class _ClassSnapshotStrip extends StatelessWidget {
  const _ClassSnapshotStrip({
    required this.totalStudents,
    required this.totalXp,
    required this.averageProgress,
    required this.bestStreak,
  });

  final int totalStudents;
  final int totalXp;
  final double averageProgress;
  final int bestStreak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
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
                      'Class snapshot',
                      style: AppTypography.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'This space shows only the learners assigned to your classroom.',
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Text(
                  '$totalStudents learner${totalStudents == 1 ? '' : 's'}',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900
                  ? 4
                  : constraints.maxWidth >= 560
                      ? 2
                      : 1;
              final itemWidth = columns == 1
                  ? null
                  : (constraints.maxWidth -
                          (AppSpacing.md * (columns - 1))) /
                      columns;

              return Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  _SnapshotMetricCard(
                    width: itemWidth,
                    label: 'Learners',
                    value: '$totalStudents',
                    icon: Icons.groups_rounded,
                    color: AppColors.primary,
                  ),
                  _SnapshotMetricCard(
                    width: itemWidth,
                    label: 'Class XP',
                    value: '$totalXp',
                    icon: Icons.bolt_rounded,
                    color: AppColors.secondaryDark,
                  ),
                  _SnapshotMetricCard(
                    width: itemWidth,
                    label: 'Avg progress',
                    value: '${averageProgress.toStringAsFixed(0)}%',
                    icon: Icons.trending_up_rounded,
                    color: AppColors.success,
                  ),
                  _SnapshotMetricCard(
                    width: itemWidth,
                    label: 'Best streak',
                    value: '$bestStreak day${bestStreak == 1 ? '' : 's'}',
                    icon: Icons.local_fire_department_rounded,
                    color: AppColors.warning,
                    compactValue: true,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SnapshotMetricCard extends StatelessWidget {
  const _SnapshotMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.width,
    this.compactValue = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double? width;
  final bool compactValue;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  maxLines: compactValue ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: (compactValue
                          ? AppTypography.headlineSmall
                          : AppTypography.headlineMedium)
                      .copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (width == null) {
      return child;
    }

    return SizedBox(width: width, child: child);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onActionPressed,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTypography.headlineLarge,
              ),
            ),
            ElevatedButton.icon(
              onPressed: onActionPressed,
              icon: const Icon(Icons.add_rounded),
              label: Text(actionLabel),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: AppTypography.bodyMedium,
        ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.message,
    required this.isSuccess,
  });

  final String message;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final accent = isSuccess ? AppColors.success : AppColors.error;
    final background = isSuccess
        ? AppColors.success.withValues(alpha: 0.10)
        : AppColors.error.withValues(alpha: 0.10);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess
                ? Icons.check_circle_outline_rounded
                : Icons.error_outline_rounded,
            color: accent,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherStudentCard extends StatelessWidget {
  const _TeacherStudentCard({
    required this.student,
    required this.insightFuture,
    required this.onEdit,
    required this.onDelete,
    required this.onViewDetails,
  });

  final AppUserProfile student;
  final Future<_StudentInsight> insightFuture;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Future<void> Function(_StudentInsight insight) onViewDetails;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_StudentInsight>(
      future: insightFuture,
      builder: (context, snapshot) {
        final insight = snapshot.data ??
            const _StudentInsight(progress: <StudentProgress>[]);
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final progressValue =
            (insight.averageProgress / 100).clamp(0.0, 1.0).toDouble();

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : () => onViewDetails(insight),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
                boxShadow: AppShadows.cardShadow,
              ),
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _initials(student.name),
                          style: AppTypography.headlineSmall.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.headlineMedium,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              student.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') {
                            onDelete();
                          } else if (value == 'edit') {
                            onEdit();
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined,
                                    color: AppColors.primary),
                                SizedBox(width: AppSpacing.sm),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline_rounded,
                                    color: AppColors.error),
                                SizedBox(width: AppSpacing.sm),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (!isLoading) ...[
                    Row(children: [
                      Expanded(
                        child: _StudentMetricChip(
                          label: 'XP',
                          value: '${insight.totalXp}',
                          icon: Icons.bolt_rounded,
                          accent: AppColors.secondaryDark,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _StudentMetricChip(
                          label: 'Progress',
                          value: '${insight.averageProgress.toStringAsFixed(0)}%',
                          icon: Icons.trending_up_rounded,
                          accent: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _StudentMetricChip(
                          label: 'Streak',
                          value: '${insight.streakDays}d',
                          icon: Icons.local_fire_department_rounded,
                          accent: AppColors.success,
                        ),
                      ),
                    ]),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress overview',
                          style: AppTypography.labelLarge,
                        ),
                        Text(
                          '${insight.averageProgress.toStringAsFixed(0)}%',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 10,
                        backgroundColor: AppColors.surfaceVariant,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Edit'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => onViewDetails(insight),
                            icon:
                                const Icon(Icons.visibility_outlined, size: 18),
                            label: const Text('Details'),
                          ),
                        ),
                      ],
                    ),
                  ] else
                    const SizedBox(
                      height: 84,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static String _initials(String name) {
    final parts = name
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

class _StudentMetricChip extends StatelessWidget {
  const _StudentMetricChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accent),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherEmptyState extends StatelessWidget {
  const _TeacherEmptyState({
    required this.onAddStudent,
  });

  final VoidCallback onAddStudent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: const Icon(
              Icons.groups_rounded,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No students yet',
            style: AppTypography.headlineLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your classroom is ready. Add your first student to start tracking progress and activity.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddStudent,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Add first student'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentInsight {
  const _StudentInsight({
    required this.progress,
    this.latestEmotion,
    this.completedLessons = 0,
    this.averageProgress = 0,
    this.totalXp = 0,
    this.streakDays = 0,
    this.lastActivity,
  });

  final List<StudentProgress> progress;
  final EmotionRecord? latestEmotion;
  final int completedLessons;
  final double averageProgress;
  final int totalXp;
  final int streakDays;
  final DateTime? lastActivity;
}

class _ClassSnapshot {
  const _ClassSnapshot({
    this.totalXp = 0,
    this.averageProgress = 0,
    this.bestStreak = 0,
  });

  final int totalXp;
  final double averageProgress;
  final int bestStreak;
}
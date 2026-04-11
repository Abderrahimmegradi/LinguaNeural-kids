import 'package:backend_core/backend_core.dart';
import 'package:backend_core/models/school.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';

class SchoolDashboardScreen extends StatefulWidget {
  const SchoolDashboardScreen({super.key});

  @override
  State<SchoolDashboardScreen> createState() => _SchoolDashboardScreenState();
}

class _SchoolDashboardScreenState extends State<SchoolDashboardScreen> {
  final UserService _userService = UserService();
  final ProgressService _progressService = ProgressService();
  final AdminManagementService _adminManagementService =
      AdminManagementService();

  final TextEditingController _teacherNameController = TextEditingController();
  final TextEditingController _teacherEmailController = TextEditingController();
  final TextEditingController _teacherPasswordController =
      TextEditingController();

  late Future<_SchoolDashboardData> _dashboardFuture;
  bool _isBusy = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboardData();
  }

  @override
  void dispose() {
    _teacherNameController.dispose();
    _teacherEmailController.dispose();
    _teacherPasswordController.dispose();
    super.dispose();
  }

  Future<_SchoolDashboardData> _loadDashboardData() async {
    final profile = context.read<UserProvider>().profile;
    if (profile == null || profile.role != UserRole.school) {
      return const _SchoolDashboardData();
    }

    final school = School(
      id: profile.id,
      name: profile.name,
      createdAt: profile.createdAt,
    );

    try {
      final teachers = await _userService.getTeachers(schoolId: school.id);
      final students = await _userService.getStudents(schoolId: school.id);
      final progressEntries = await Future.wait(
        students.map(
          (student) => _progressService.getProgressForStudent(student.id),
        ),
      );

      final progressByStudentId = <String, List<StudentProgress>>{};
      for (var index = 0; index < students.length; index++) {
        progressByStudentId[students[index].id] = progressEntries[index];
      }

      return _SchoolDashboardData(
        school: school,
        teachers: teachers,
        students: students,
        progressByStudentId: progressByStudentId,
      );
    } catch (_) {
      return _SchoolDashboardData(school: school);
    }
  }

  Future<void> _refreshDashboard() async {
    final refreshed = _loadDashboardData();
    setState(() {
      _dashboardFuture = refreshed;
    });
    await refreshed;
  }

  void _resetTeacherInputs() {
    _teacherNameController.clear();
    _teacherEmailController.clear();
    _teacherPasswordController.clear();
  }

  String? _validateTeacherInputs() {
    if (_teacherNameController.text.trim().isEmpty) {
      return 'Teacher name is required.';
    }

    final email = _teacherEmailController.text.trim();
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(email)) {
      return 'Enter a valid teacher email.';
    }

    if (_teacherPasswordController.text.trim().length < 8) {
      return 'Teacher password must be at least 8 characters.';
    }

    return null;
  }

  Future<bool> _createTeacher() async {
    final validationError = _validateTeacherInputs();
    if (validationError != null) {
      setState(() {
        _statusMessage = validationError;
      });
      return false;
    }

    final schoolId = context.read<UserProvider>().profile?.id ?? '';
    if (schoolId.isEmpty) {
      setState(() {
        _statusMessage = 'School profile is missing.';
      });
      return false;
    }

    setState(() {
      _isBusy = true;
      _statusMessage = null;
    });

    try {
      await _adminManagementService.createManagedUser(
        name: _teacherNameController.text.trim(),
        email: _teacherEmailController.text.trim(),
        password: _teacherPasswordController.text.trim(),
        role: UserRole.teacher,
        schoolId: schoolId,
      );
      _resetTeacherInputs();
      await _refreshDashboard();
      if (!mounted) {
        return false;
      }
      setState(() {
        _statusMessage = 'Teacher created successfully.';
      });
      return true;
    } catch (e) {
      if (!mounted) {
        return false;
      }
      setState(() {
        _statusMessage = 'Could not create teacher: $e';
      });
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Future<void> _showAddTeacherDialog() async {
    _resetTeacherInputs();

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
              final created = await _createTeacher();
              if (!mounted) {
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
              title: Text(
                'Add Teacher',
                style: AppTypography.headlineLarge,
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _teacherNameController,
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration(
                          'Teacher name',
                          'Enter full name',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextField(
                        controller: _teacherEmailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration(
                          'Teacher email',
                          'teacher@school.com',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextField(
                        controller: _teacherPasswordController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) async => submit(),
                        decoration: _inputDecoration(
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
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
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

  InputDecoration _inputDecoration(String label, String hint) {
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

  Future<void> _confirmDeleteTeacher(AppUserProfile teacher) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete teacher'),
          content: Text(
            'Delete ${teacher.name}? This removes the teacher profile and linked students.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isBusy = true;
      _statusMessage = null;
    });

    try {
      await _adminManagementService.deleteManagedUser(user: teacher);
      await _refreshDashboard();
      if (!mounted) {
        return;
      }
      setState(() {
        _statusMessage = 'Teacher deleted successfully.';
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _statusMessage = 'Could not delete teacher: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  bool _isSuccessMessage(String? message) {
    if (message == null) {
      return false;
    }
    return message.toLowerCase().contains('success');
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final profile = userProvider.profile;

    if (profile == null || profile.role != UserRole.school) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your school profile is not ready yet. Please sign in again.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: userProvider.signOut,
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('School Dashboard'),
        backgroundColor: const Color(0xFF16324F),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _refreshDashboard,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            onPressed: userProvider.signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isBusy ? null : _showAddTeacherDialog,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add teacher'),
      ),
      body: Stack(
        children: [
          FutureBuilder<_SchoolDashboardData>(
            future: _dashboardFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data ??
                  _SchoolDashboardData(
                    school: School(
                      id: profile.id,
                      name: profile.name,
                      createdAt: profile.createdAt,
                    ),
                  );

              return RefreshIndicator(
                onRefresh: _refreshDashboard,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.xxxl + 28,
                      ),
                      children: [
                        _SchoolHero(
                          schoolName: data.school.name.isEmpty
                              ? 'My School'
                              : data.school.name,
                          teacherCount: data.teachers.length,
                          studentCount: data.students.length,
                          averageProgress: data.averageProgress,
                          onAddTeacher: _showAddTeacherDialog,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        if (_statusMessage != null) ...[
                          _SchoolStatusBanner(
                            message: _statusMessage!,
                            isSuccess: _isSuccessMessage(_statusMessage),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                        _SchoolSectionHeader(
                          title: 'Teaching team',
                          subtitle:
                              'Manage teachers, watch school progress, and keep your learning team growing.',
                          actionLabel: 'Add teacher',
                          onActionPressed: _showAddTeacherDialog,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        if (data.teachers.isEmpty)
                          const _EmptyTeachersState()
                        else
                          ...data.teachers.map(
                            (teacher) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.lg),
                              child: _SchoolTeacherCard(
                                teacher: teacher,
                                studentCount:
                                    data.studentCountForTeacher(teacher.id),
                                onDelete: () => _confirmDeleteTeacher(teacher),
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
              color: Colors.black.withOpacity(0.08),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _SchoolHero extends StatelessWidget {
  const _SchoolHero({
    required this.schoolName,
    required this.teacherCount,
    required this.studentCount,
    required this.averageProgress,
    required this.onAddTeacher,
  });

  final String schoolName;
  final int teacherCount;
  final int studentCount;
  final double averageProgress;
  final VoidCallback onAddTeacher;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16324F), AppColors.primary],
        ),
        boxShadow: AppShadows.elevatedShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'School Dashboard',
            style: AppTypography.labelLarge.copyWith(
              color: Colors.white.withOpacity(0.82),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            schoolName,
            style: AppTypography.displaySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your teaching team, learner growth, and school momentum in one place.',
            style: AppTypography.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.92),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _HeroMetricCard(
                label: 'Teachers',
                value: '$teacherCount',
                icon: Icons.school_rounded,
              ),
              _HeroMetricCard(
                label: 'Students',
                value: '$studentCount',
                icon: Icons.groups_rounded,
              ),
              _HeroMetricCard(
                label: 'Average progress',
                value: '${averageProgress.toStringAsFixed(0)}%',
                icon: Icons.trending_up_rounded,
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddTeacher,
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
                'Add teacher',
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

class _HeroMetricCard extends StatelessWidget {
  const _HeroMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    this.compact = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 180),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
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
                    color: Colors.white.withOpacity(0.74),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  maxLines: compact ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: (compact
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

class _SchoolSectionHeader extends StatelessWidget {
  const _SchoolSectionHeader({
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

class _SchoolStatusBanner extends StatelessWidget {
  const _SchoolStatusBanner({
    required this.message,
    required this.isSuccess,
  });

  final String message;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final accent = isSuccess ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.10),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: accent.withOpacity(0.22)),
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

class _SchoolTeacherCard extends StatelessWidget {
  const _SchoolTeacherCard({
    required this.teacher,
    required this.studentCount,
    required this.onDelete,
  });

  final AppUserProfile teacher;
  final int studentCount;
  final VoidCallback onDelete;

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(teacher.name),
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
                  teacher.name,
                  style: AppTypography.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  teacher.email,
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.groups_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '$studentCount students',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          IconButton(
            onPressed: onDelete,
            tooltip: 'Delete teacher',
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
            ),
          ),
        ],
      ),
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

class _EmptyTeachersState extends StatelessWidget {
  const _EmptyTeachersState();

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
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: const Icon(
              Icons.school_rounded,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No teachers yet',
            style: AppTypography.headlineLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Start by adding your first teacher so your school can begin creating classrooms.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _SchoolDashboardData {
  const _SchoolDashboardData({
    this.school = const School(id: '', name: ''),
    this.teachers = const <AppUserProfile>[],
    this.students = const <AppUserProfile>[],
    this.progressByStudentId = const <String, List<StudentProgress>>{},
  });

  final School school;
  final List<AppUserProfile> teachers;
  final List<AppUserProfile> students;
  final Map<String, List<StudentProgress>> progressByStudentId;

  double get averageProgress {
    final allEntries = progressByStudentId.values.expand((entries) => entries).toList();
    if (allEntries.isEmpty) {
      return 0;
    }
    final total = allEntries.fold<double>(0, (sum, entry) => sum + entry.score);
    return total / allEntries.length;
  }

  int studentCountForTeacher(String teacherId) {
    return students.where((student) => student.teacherId == teacherId).length;
  }
}

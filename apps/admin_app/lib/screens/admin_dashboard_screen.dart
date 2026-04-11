import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'school_details_screen.dart';
import '../theme/app_colors.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final UserService _userService = UserService();
  final ProgressService _progressService = ProgressService();
  final AdminManagementService _adminManagementService =
      AdminManagementService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _schoolEmailController = TextEditingController();
  final TextEditingController _schoolPasswordController =
      TextEditingController();

  late Future<_AdminDashboardData> _dashboardFuture;
  bool _isSavingSchool = false;
  bool _isResettingHierarchy = false;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboardData();
  }

  @override
  void dispose() {
    _schoolNameController.dispose();
    _schoolEmailController.dispose();
    _schoolPasswordController.dispose();
    super.dispose();
  }

  Future<_AdminDashboardData> _loadDashboardData() async {
    try {
      final results = await Future.wait([
        _fetchSchools(),
        _userService.getTeachers(),
        _userService.getStudents(),
      ]);

      final schools = results[0] as List<School>;
      final teachers = results[1] as List<AppUserProfile>;
      final students = results[2] as List<AppUserProfile>;
      final progressEntries = await Future.wait(
        students.map(
          (student) => _progressService.getProgressForStudent(student.id),
        ),
      );

      final progressByStudentId = <String, List<StudentProgress>>{};
      for (var index = 0; index < students.length; index++) {
        progressByStudentId[students[index].id] = progressEntries[index];
      }

      return _AdminDashboardData(
        schools: schools,
        teachers: teachers,
        students: students,
        progressByStudentId: progressByStudentId,
      );
    } catch (_) {
      return const _AdminDashboardData();
    }
  }

  Future<List<School>> _fetchSchools() async {
    final userSnapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: UserRole.school.name)
        .get();
    final schools = userSnapshot.docs
        .map(AppUserProfile.fromFirestore)
        .map(
          (profile) => School(
            id: profile.id,
            name: profile.name,
            createdAt: profile.createdAt,
          ),
        )
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return schools;
  }

  Future<void> _refreshDashboard() async {
    final refreshed = _loadDashboardData();
    setState(() {
      _dashboardFuture = refreshed;
    });
    await refreshed;
  }

  Future<void> _showAddSchoolDialog() async {
    _schoolNameController.clear();
    _schoolEmailController.clear();
    _schoolPasswordController.clear();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add school'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _schoolNameController,
                      autofocus: true,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'School name',
                        hintText: 'Enter school name',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _schoolEmailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'School email',
                        hintText: 'school@example.com',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _schoolPasswordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) async {
                        await _saveSchoolFromDialog(setDialogState);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Temporary password',
                        hintText: 'Minimum 8 characters',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isSavingSchool
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isSavingSchool
                      ? null
                      : () async {
                          await _saveSchoolFromDialog(setDialogState);
                        },
                  child: _isSavingSchool
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Add school'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveSchoolFromDialog(
    void Function(void Function()) setDialogState,
  ) async {
    final validationError = _validateSchoolInputs();
    if (validationError != null) {
      _showMessage(validationError);
      return;
    }

    setDialogState(() {
      _isSavingSchool = true;
    });

    try {
      await createSchool(
        _schoolNameController.text.trim(),
        _schoolEmailController.text.trim(),
        _schoolPasswordController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
      _showMessage('School created successfully');
      await _refreshDashboard();
    } catch (e, stackTrace) {
      debugPrint('Failed to create school: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) {
        return;
      }
      _showMessage('Failed to create school: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSavingSchool = false;
        });
      } else {
        _isSavingSchool = false;
      }
    }
  }

  String? _validateSchoolInputs() {
    if (_schoolNameController.text.trim().isEmpty) {
      return 'School name is required.';
    }

    final email = _schoolEmailController.text.trim();
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(email)) {
      return 'Enter a valid school email.';
    }

    if (_schoolPasswordController.text.trim().length < 8) {
      return 'School password must be at least 8 characters.';
    }

    return null;
  }

  Future<void> createSchool(
    String name,
    String email,
    String password,
  ) async {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();
    if (trimmedName.isEmpty) {
      throw Exception('School name is required.');
    }

    await _adminManagementService.createManagedUser(
      name: trimmedName,
      email: trimmedEmail,
      password: password,
      role: UserRole.school,
    );
  }

  Future<void> _openManageSchool(School school) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SchoolDetailsScreen(school: school),
      ),
    );

    if (!mounted) {
      return;
    }

    await _refreshDashboard();
  }

  Future<void> _confirmResetHierarchy() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset hierarchy data'),
          content: const Text(
            'This will delete all schools, teachers, students, and their progress data from Firestore while keeping the admin profile. Continue?',
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
                foregroundColor: AppColors.onError,
              ),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    if (!mounted) {
      return;
    }

    final adminId = context.read<UserProvider>().profile?.id;
    if (adminId == null || adminId.isEmpty) {
      _showMessage('Admin account is missing.');
      return;
    }

    setState(() {
      _isResettingHierarchy = true;
    });

    try {
      await _adminManagementService.resetHierarchyData(
        preserveAdminUserId: adminId,
      );
      if (!mounted) {
        return;
      }
      _showMessage('Hierarchy data reset successfully.');
      await _refreshDashboard();
    } catch (e, stackTrace) {
      debugPrint('Failed to reset hierarchy: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) {
        return;
      }
      _showMessage('Failed to reset hierarchy: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isResettingHierarchy = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            onPressed: _isResettingHierarchy ? null : _confirmResetHierarchy,
            icon: _isResettingHierarchy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Reset hierarchy',
          ),
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
        onPressed: _showAddSchoolDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add school'),
      ),
      body: FutureBuilder<_AdminDashboardData>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? const _AdminDashboardData();

          return RefreshIndicator(
            onRefresh: _refreshDashboard,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1260),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.xxxl + 28,
                  ),
                  children: [
                    _AdminHero(
                      schoolCount: data.schools.length,
                      teacherCount: data.teachers.length,
                      studentCount: data.students.length,
                      totalXp: data.totalXpInSystem,
                      onAddSchool: _showAddSchoolDialog,
                      onRefresh: _refreshDashboard,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _StatsGrid(data: data),
                    const SizedBox(height: AppSpacing.xl),
                    _AnalyticsSection(data: data),
                    const SizedBox(height: AppSpacing.xl),
                    _SectionHeader(
                      title: 'Schools list',
                      actionLabel: 'Add school',
                      onActionPressed: _showAddSchoolDialog,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (data.schools.isEmpty)
                      const _EmptySchoolsCard()
                    else
                      ...data.schools.map((school) {
                        final teacherCount = data.teacherCountForSchool(school.id);
                        final studentCount = data.studentCountForSchool(school.id);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                          child: _SchoolCard(
                            school: school,
                            teacherCount: teacherCount,
                            studentCount: studentCount,
                            onManage: () => _openManageSchool(school),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AdminHero extends StatelessWidget {
  const _AdminHero({
    required this.schoolCount,
    required this.teacherCount,
    required this.studentCount,
    required this.totalXp,
    required this.onAddSchool,
    required this.onRefresh,
  });

  final int schoolCount;
  final int teacherCount;
  final int studentCount;
  final int totalXp;
  final VoidCallback onAddSchool;
  final VoidCallback onRefresh;

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
                      'Admin command center',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.onPrimary.withValues(alpha: 0.82),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Guide the whole learning world from one calm dashboard.',
                      style: AppTypography.displaySmall.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'See school health, spotlight growth, and build new learning teams without exposing technical details.',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.onPrimary.withValues(alpha: 0.92),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              IconButton(
                onPressed: onRefresh,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.onPrimary.withValues(alpha: 0.12),
                ),
                icon: const Icon(Icons.refresh_rounded, color: AppColors.onPrimary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _HeroMiniBadge(
                label: 'Schools',
                value: '$schoolCount',
                icon: Icons.apartment_rounded,
              ),
              _HeroMiniBadge(
                label: 'Teachers',
                value: '$teacherCount',
                icon: Icons.school_rounded,
              ),
              _HeroMiniBadge(
                label: 'Students',
                value: '$studentCount',
                icon: Icons.groups_rounded,
              ),
              _HeroMiniBadge(
                label: 'XP',
                value: '$totalXp',
                icon: Icons.bolt_rounded,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddSchool,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.primaryDark,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              icon: const Icon(Icons.add_business_rounded),
              label: Text(
                'Create school',
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

class _HeroMiniBadge extends StatelessWidget {
  const _HeroMiniBadge({
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
      constraints: const BoxConstraints(minWidth: 170),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.onPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.onPrimary.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.onPrimary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(icon, color: AppColors.onPrimary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onPrimary.withValues(alpha: 0.74),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.onPrimary,
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

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.data,
  });

  final _AdminDashboardData data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1120
            ? 4
            : constraints.maxWidth >= 760
                ? 2
                : 1;
        final itemWidth = columns == 1
            ? null
            : (constraints.maxWidth - (AppSpacing.lg * (columns - 1))) / columns;

        return Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.lg,
          children: [
            _StatCard(
              title: 'Total schools',
              value: '${data.schools.length}',
              icon: Icons.apartment_rounded,
              color: AppColors.primary,
              width: itemWidth,
            ),
            _StatCard(
              title: 'Total teachers',
              value: '${data.teachers.length}',
              icon: Icons.school_rounded,
              color: AppColors.secondaryDark,
              width: itemWidth,
            ),
            _StatCard(
              title: 'Total students',
              value: '${data.students.length}',
              icon: Icons.groups_rounded,
              color: AppColors.success,
              width: itemWidth,
            ),
            _StatCard(
              title: 'Total XP',
              value: '${data.totalXpInSystem}',
              icon: Icons.bolt_rounded,
              color: AppColors.warning,
              width: itemWidth,
            ),
          ],
        );
      },
    );
  }
}

class _AnalyticsSection extends StatelessWidget {
  const _AnalyticsSection({
    required this.data,
  });

  final _AdminDashboardData data;

  @override
  Widget build(BuildContext context) {
    final mostActiveSchool = data.mostActiveSchool;
    final topStudents = data.topPerformingStudents;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Advanced analytics',
          style: AppTypography.headlineLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Quick performance signals across schools and students.',
          style: AppTypography.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.lg,
          children: [
            _AnalyticsCard(
              title: 'Average student progress',
              icon: Icons.trending_up_rounded,
              accentColor: AppColors.primary,
              child: _MetricWithBar(
                valueLabel:
                    '${data.averageStudentProgress.toStringAsFixed(1)}%',
                progress: data.averageStudentProgress / 100,
                helperText: 'Average score across tracked students',
              ),
            ),
            _AnalyticsCard(
              title: 'Most active school',
              icon: Icons.local_fire_department_rounded,
              accentColor: AppColors.secondaryDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mostActiveSchool?.name ?? 'No activity yet',
                    style: AppTypography.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    mostActiveSchool == null
                        ? 'No school progress data available'
                        : '${data.totalXpForSchool(mostActiveSchool.id)} XP earned',
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            ),
            _AnalyticsCard(
              title: 'Total XP in system',
              icon: Icons.bolt_rounded,
              accentColor: AppColors.success,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${data.totalXpInSystem}',
                    style: AppTypography.displaySmall.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Combined XP from all student progress entries',
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _AnalyticsCard(
          title: 'Top performing students',
          icon: Icons.emoji_events_rounded,
          accentColor: AppColors.secondary,
          child: topStudents.isEmpty
              ? Text(
                  'No student performance data yet.',
                  style: AppTypography.bodyMedium,
                )
              : Column(
                  children: topStudents.map((student) {
                    final scorePercent =
                        student.averageScore.clamp(0, 100) / 100;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: _TopStudentRow(
                        student: student,
                        progress: scorePercent,
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.width,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: AppTypography.displaySmall.copyWith(
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
      return card;
    }

    return SizedBox(
      width: width,
      child: card,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onActionPressed,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

class _SchoolCard extends StatelessWidget {
  const _SchoolCard({
    required this.school,
    required this.teacherCount,
    required this.studentCount,
    required this.onManage,
  });

  final School school;
  final int teacherCount;
  final int studentCount;
  final VoidCallback onManage;

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
          Text(
            school.name,
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _SchoolMetric(
                  label: 'Teachers',
                  value: '$teacherCount',
                  icon: Icons.school_outlined,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _SchoolMetric(
                  label: 'Students',
                  value: '$studentCount',
                  icon: Icons.groups_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onManage,
              child: const Text('Manage'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SchoolMetric extends StatelessWidget {
  const _SchoolMetric({
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTypography.headlineMedium,
              ),
              Text(
                label,
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Color accentColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 250),
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
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(icon, color: accentColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.headlineMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}

class _MetricWithBar extends StatelessWidget {
  const _MetricWithBar({
    required this.valueLabel,
    required this.progress,
    required this.helperText,
  });

  final String valueLabel;
  final double progress;
  final String helperText;

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          valueLabel,
          style: AppTypography.displaySmall.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: LinearProgressIndicator(
            value: clampedProgress,
            minHeight: 10,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          helperText,
          style: AppTypography.bodyMedium,
        ),
      ],
    );
  }
}

class _TopStudentRow extends StatelessWidget {
  const _TopStudentRow({
    required this.student,
    required this.progress,
  });

  final _StudentPerformance student;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.student.name,
                    style: AppTypography.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${student.schoolName} • ${student.totalXp} XP',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              '${student.averageScore.toStringAsFixed(0)}%',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
          ),
        ),
      ],
    );
  }
}

class _EmptySchoolsCard extends StatelessWidget {
  const _EmptySchoolsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: const Icon(
              Icons.apartment_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No schools yet',
            style: AppTypography.headlineLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Use the add school button to create your first school.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _AdminDashboardData {
  const _AdminDashboardData({
    this.schools = const <School>[],
    this.teachers = const <AppUserProfile>[],
    this.students = const <AppUserProfile>[],
    this.progressByStudentId = const <String, List<StudentProgress>>{},
  });

  final List<School> schools;
  final List<AppUserProfile> teachers;
  final List<AppUserProfile> students;
  final Map<String, List<StudentProgress>> progressByStudentId;

  int teacherCountForSchool(String schoolId) {
    return teachers.where((teacher) => teacher.schoolId == schoolId).length;
  }

  int studentCountForSchool(String schoolId) {
    return students.where((student) => student.schoolId == schoolId).length;
  }

  int get totalXpInSystem {
    return progressByStudentId.values
        .expand((entries) => entries)
        .fold<int>(0, (total, entry) => total + entry.xpEarned);
  }

  double get averageStudentProgress {
    if (students.isEmpty) {
      return 0;
    }

    final scores = students.map((student) {
      final entries = progressByStudentId[student.id] ?? const <StudentProgress>[];
      if (entries.isEmpty) {
        return 0.0;
      }
      final total = entries.fold<double>(0, (scoreTotal, entry) => scoreTotal + entry.score);
      return total / entries.length;
    }).toList();

    if (scores.isEmpty) {
      return 0;
    }

    return scores.fold<double>(0, (scoreTotal, score) => scoreTotal + score) / scores.length;
  }

  int totalXpForSchool(String schoolId) {
    final schoolStudents =
        students.where((student) => student.schoolId == schoolId).toList();
    return schoolStudents.fold<int>(0, (total, student) {
      final entries = progressByStudentId[student.id] ?? const <StudentProgress>[];
      final xp = entries.fold<int>(0, (xpTotal, entry) => xpTotal + entry.xpEarned);
      return total + xp;
    });
  }

  School? get mostActiveSchool {
    if (schools.isEmpty) {
      return null;
    }

    School? winner;
    var highestXp = -1;

    for (final school in schools) {
      final xp = totalXpForSchool(school.id);
      if (xp > highestXp) {
        highestXp = xp;
        winner = school;
      }
    }

    return highestXp <= 0 ? null : winner;
  }

  List<_StudentPerformance> get topPerformingStudents {
    final performances = students.map((student) {
      final entries = progressByStudentId[student.id] ?? const <StudentProgress>[];
      final totalXp = entries.fold<int>(0, (xpTotal, entry) => xpTotal + entry.xpEarned);
      final averageScore = entries.isEmpty
          ? 0.0
          : entries.fold<double>(0, (scoreTotal, entry) => scoreTotal + entry.score) /
              entries.length;
      final schoolName = schools
          .where((school) => school.id == student.schoolId)
          .map((school) => school.name)
          .cast<String?>()
          .firstWhere(
            (value) => value != null && value.isNotEmpty,
            orElse: () => 'School not assigned',
          );

      return _StudentPerformance(
        student: student,
        averageScore: averageScore,
        totalXp: totalXp,
        schoolName: schoolName ?? 'School not assigned',
      );
    }).where((performance) {
      return (progressByStudentId[performance.student.id] ?? const <StudentProgress>[])
          .isNotEmpty;
    }).toList();

    performances.sort((a, b) {
      final scoreCompare = b.averageScore.compareTo(a.averageScore);
      if (scoreCompare != 0) {
        return scoreCompare;
      }
      final xpCompare = b.totalXp.compareTo(a.totalXp);
      if (xpCompare != 0) {
        return xpCompare;
      }
      return a.student.name.compareTo(b.student.name);
    });

    return performances.take(5).toList();
  }
}

class _StudentPerformance {
  const _StudentPerformance({
    required this.student,
    required this.averageScore,
    required this.totalXp,
    required this.schoolName,
  });

  final AppUserProfile student;
  final double averageScore;
  final int totalXp;
  final String schoolName;
}

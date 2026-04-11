import 'package:backend_core/backend_core.dart';
import 'package:backend_core/models/school.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';

class SchoolDetailsScreen extends StatefulWidget {
  const SchoolDetailsScreen({
    super.key,
    required this.school,
  });

  final School school;

  @override
  State<SchoolDetailsScreen> createState() => _SchoolDetailsScreenState();
}

class _SchoolDetailsScreenState extends State<SchoolDetailsScreen> {
  final UserService _userService = UserService();
  final AdminManagementService _adminManagementService =
      AdminManagementService();

  final TextEditingController _teacherNameController = TextEditingController();
  final TextEditingController _teacherEmailController = TextEditingController();
  final TextEditingController _teacherPasswordController =
      TextEditingController();

  late Future<List<AppUserProfile>> _teachersFuture;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _teachersFuture = _loadTeachers();
  }

  @override
  void dispose() {
    _teacherNameController.dispose();
    _teacherEmailController.dispose();
    _teacherPasswordController.dispose();
    super.dispose();
  }

  Future<List<AppUserProfile>> _loadTeachers() {
    if (widget.school.id.isEmpty) {
      return Future.value(const <AppUserProfile>[]);
    }

    return _userService.getTeachers(schoolId: widget.school.id);
  }

  Future<void> _refreshTeachers() async {
    final refreshed = _loadTeachers();
    setState(() {
      _teachersFuture = refreshed;
    });
    await refreshed;
  }

  Future<void> _showAddTeacherDialog() async {
    _teacherNameController.clear();
    _teacherEmailController.clear();
    _teacherPasswordController.clear();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add teacher'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _teacherNameController,
                  decoration: const InputDecoration(
                    labelText: 'Teacher name',
                    hintText: 'Enter teacher name',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _teacherEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Teacher email',
                    hintText: 'teacher@school.com',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _teacherPasswordController,
                  obscureText: true,
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
              onPressed: _isBusy ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isBusy
                  ? null
                  : () async {
                      await _createTeacher();
                    },
              child: const Text('Add teacher'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createTeacher() async {
    final validationError = _validateTeacherInputs();
    if (validationError != null) {
      _showMessage(validationError, isError: true);
      return;
    }
    final schoolId = widget.school.id.trim();
    if (schoolId.isEmpty) {
      _showMessage('School is missing.', isError: true);
      return;
    }

    setState(() {
      _isBusy = true;
    });

    try {
      await _adminManagementService.createManagedUser(
        name: _teacherNameController.text.trim(),
        email: _teacherEmailController.text.trim(),
        password: _teacherPasswordController.text.trim(),
        role: UserRole.teacher,
        schoolId: schoolId,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
      _showMessage('Teacher added successfully.');
      await _refreshTeachers();
    } catch (e) {
      _showMessage('Could not add teacher: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
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

  Future<void> _confirmDeleteTeacher(AppUserProfile teacher) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete teacher'),
          content: Text(
            'Delete ${teacher.name}? This removes the teacher profile and linked school data. '
            'Authentication deletion is skipped in this lightweight flow.',
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
    });

    try {
      await _adminManagementService.deleteManagedUser(user: teacher);
      _showMessage('Teacher deleted successfully.');
      await _refreshTeachers();
    } catch (e) {
      _showMessage('Could not delete teacher: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? AppColors.error : AppColors.success,
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isSchoolAccount = userProvider.profile?.role == UserRole.school;

    return Scaffold(
      appBar: AppBar(
        title: const Text('School Details'),
        actions: [
          if (isSchoolAccount)
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
          FutureBuilder<List<AppUserProfile>>(
            future: _teachersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final teachers = snapshot.data ?? const <AppUserProfile>[];

              return RefreshIndicator(
                onRefresh: _refreshTeachers,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.xxxl + 28,
                  ),
                  children: [
                    _SchoolInfoCard(
                      school: widget.school,
                      teacherCount: teachers.length,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Teachers',
                            style: AppTypography.headlineLarge,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isBusy ? null : _showAddTeacherDialog,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add teacher'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (teachers.isEmpty)
                      const _EmptyTeachersCard()
                    else
                      ...teachers.map(
                        (teacher) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                          child: _TeacherCard(
                            teacher: teacher,
                            onDelete: () => _confirmDeleteTeacher(teacher),
                          ),
                        ),
                      ),
                  ],
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

class _SchoolInfoCard extends StatelessWidget {
  const _SchoolInfoCard({
    required this.school,
    required this.teacherCount,
  });

  final School school;
  final int teacherCount;

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
            style: AppTypography.displaySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Teachers: $teacherCount',
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _TeacherCard extends StatelessWidget {
  const _TeacherCard({
    required this.teacher,
    required this.onDelete,
  });

  final AppUserProfile teacher;
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: AppColors.primary,
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
}

class _EmptyTeachersCard extends StatelessWidget {
  const _EmptyTeachersCard();

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
              color: AppColors.secondary.withOpacity(0.16),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: const Icon(
              Icons.person_search_rounded,
              color: AppColors.secondaryDark,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No teachers yet',
            style: AppTypography.headlineLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Add the first teacher to start managing this school.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }
}

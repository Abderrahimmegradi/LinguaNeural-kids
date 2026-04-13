import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/admin_dashboard_models.dart';
import '../services/admin_firestore_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({
    super.key,
    required this.currentRole,
    required this.currentDisplayName,
    this.onSignOut,
    this.previewBundle,
  });

  final String currentRole;
  final String currentDisplayName;
  final Future<void> Function()? onSignOut;
  final AdminDashboardBundle? previewBundle;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminFirestoreService _service = AdminFirestoreService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newSchoolIdController = TextEditingController();
  final TextEditingController _newSchoolNameController = TextEditingController();

  late Future<AdminDashboardBundle> _dashboardFuture;
  String _selectedRole = 'student';
  bool _isCreatingUser = false;
  bool _isCreatingSchool = false;
  bool _isMutating = false;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = widget.previewBundle != null
        ? Future.value(widget.previewBundle)
        : _service.loadDashboard();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _newSchoolIdController.dispose();
    _newSchoolNameController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (widget.previewBundle != null) {
      setState(() {
        _dashboardFuture = Future.value(widget.previewBundle);
      });
      return;
    }

    final next = _service.loadDashboard();
    setState(() {
      _dashboardFuture = next;
    });
    await next;
  }

  Future<void> _createUser(AdminDashboardBundle data) async {
    final availableRoles = _availableCreateRoles(data);
    final selectedRole = availableRoles.contains(_selectedRole)
        ? _selectedRole
        : (availableRoles.isEmpty ? null : availableRoles.first);

    if (widget.currentRole != 'admin') {
      _showMessage('Only the admin can create accounts.');
      return;
    }

    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().length < 6 ||
        selectedRole == null) {
      _showMessage('Email, password, and an available role are required.');
      return;
    }

    setState(() {
      _isCreatingUser = true;
    });

    try {
      await _service.createUser(
        email: _emailController.text,
        password: _passwordController.text,
        role: selectedRole,
      );

      _emailController.clear();
      _passwordController.clear();
      await _refresh();
      _showMessage('Account provisioned and profile created successfully.');
    } catch (error) {
      _showMessage('Failed to create account: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingUser = false;
        });
      }
    }
  }

  Future<void> _createSchool() async {
    if (widget.currentRole != 'admin') {
      _showMessage('Only the admin can create schools.');
      return;
    }

    if (_newSchoolIdController.text.trim().isEmpty ||
        _newSchoolNameController.text.trim().isEmpty) {
      _showMessage('School id and school name are required.');
      return;
    }

    setState(() {
      _isCreatingSchool = true;
    });

    try {
      await _service.createSchool(
        schoolId: _newSchoolIdController.text,
        name: _newSchoolNameController.text,
      );
      _newSchoolIdController.clear();
      _newSchoolNameController.clear();
      await _refresh();
      _showMessage('School created successfully.');
    } catch (error) {
      _showMessage('Failed to create school: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingSchool = false;
        });
      }
    }
  }

  Future<void> _updateStatus(AdminUserRecord user) async {
    setState(() {
      _isMutating = true;
    });
    final nextStatus = user.status == 'active' ? 'inactive' : 'active';

    try {
      await _service.setUserStatus(userId: user.id, status: nextStatus);
      await _refresh();
      _showMessage('${user.displayName} is now $nextStatus.');
    } catch (error) {
      _showMessage('Failed to update status: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isMutating = false;
        });
      }
    }
  }

  Future<void> _showEditUserDialog(AdminUserRecord user) async {
    final displayNameController = TextEditingController(text: user.displayName);
    final schoolIdController = TextEditingController(text: user.schoolId);
    final allowedRoles = _availableEditRolesFor(user.role);
    var selectedRole = allowedRoles.contains(user.role) ? user.role : allowedRoles.first;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit ${user.displayName}', style: _headingStyle(22)),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _field(displayNameController, 'Display name'),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      isExpanded: true,
                      decoration: _inputDecoration('Role'),
                      items: allowedRoles
                          .map(
                            (role) => DropdownMenuItem(
                              value: role,
                              child: Text(_roleLabel(role)),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setDialogState(() {
                          selectedRole = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _field(schoolIdController, 'School id'),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (shouldSave != true) {
      displayNameController.dispose();
      schoolIdController.dispose();
      return;
    }

    setState(() {
      _isMutating = true;
    });

    try {
      await _service.updateUserProfile(
        userId: user.id,
        displayName: displayNameController.text,
        role: selectedRole,
        schoolId: schoolIdController.text,
      );
      await _refresh();
      _showMessage('User updated successfully.');
    } catch (error) {
      _showMessage('Failed to update user: $error');
    } finally {
      displayNameController.dispose();
      schoolIdController.dispose();
      if (mounted) {
        setState(() {
          _isMutating = false;
        });
      }
    }
  }

  Future<void> _showAssignTeacherDialog(
    AdminUserRecord student,
    List<AdminUserRecord> teachers,
  ) async {
    String? selectedTeacherId = student.teacherId;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Assign Teacher', style: _headingStyle(22)),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SizedBox(
                width: 420,
                child: DropdownButtonFormField<String?>(
                  initialValue: selectedTeacherId,
                  isExpanded: true,
                  decoration: _inputDecoration('Teacher'),
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('No teacher assigned')),
                    ...teachers
                        .where((teacher) =>
                            teacher.schoolId == student.schoolId || teacher.schoolId == 'unassigned')
                        .map(
                          (teacher) => DropdownMenuItem<String?>(
                            value: teacher.id,
                            child: Text('${teacher.displayName} · ${teacher.schoolId}'),
                          ),
                        ),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedTeacherId = value;
                    });
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Assign'),
            ),
          ],
        );
      },
    );

    if (shouldSave != true) {
      return;
    }

    setState(() {
      _isMutating = true;
    });

    try {
      await _service.assignTeacherToStudent(
        studentId: student.id,
        teacherId: selectedTeacherId,
      );
      await _refresh();
      _showMessage('Teacher assignment updated.');
    } catch (error) {
      _showMessage('Failed to assign teacher: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isMutating = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    if (widget.onSignOut == null) {
      return;
    }
    await widget.onSignOut!.call();
  }

  Future<void> _showStudentInsightDialog(AdminUserRecord user) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920, maxHeight: 760),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: FutureBuilder<AdminStudentInsight>(
                future: _service.loadStudentInsight(user),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Failed to load student insight: ${snapshot.error}', style: _bodyStyle()),
                    );
                  }

                  final insight = snapshot.data;
                  if (insight == null) {
                    return Center(child: Text('No student insight available.', style: _bodyStyle()));
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${user.displayName} progress', style: _headingStyle(28)),
                                const SizedBox(height: 4),
                                Text(user.email, style: _bodyStyle(color: const Color(0xFF64748B))),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _MetricChip(label: 'Current lesson', value: insight.currentLessonId),
                          _MetricChip(label: 'Completed', value: '${insight.completedLessonsCount}'),
                          _MetricChip(label: 'Badges', value: '${insight.badgesCount}'),
                          _MetricChip(label: 'Emotion', value: user.currentEmotion),
                          _MetricChip(label: 'Mastery', value: '${(user.masteryScore * 100).round()}%'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: _SectionCard(
                                title: 'Lesson states',
                                subtitle: 'Scores, XP, and mistakes from saved progress.',
                                child: insight.lessonStates.isEmpty
                                    ? const _EmptyState(message: 'No lesson history yet.')
                                    : Column(
                                        children: insight.lessonStates
                                            .map(
                                              (state) => Padding(
                                                padding: const EdgeInsets.only(bottom: 10),
                                                child: Container(
                                                  padding: const EdgeInsets.all(14),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFF8FBFD),
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(child: Text(state.lessonId, style: _bodyStyle())),
                                                      _MetricChip(label: 'Score', value: '${(state.score * 100).round()}%'),
                                                      const SizedBox(width: 8),
                                                      _MetricChip(label: 'XP', value: '${state.xpEarned}'),
                                                      const SizedBox(width: 8),
                                                      _MetricChip(label: 'Mistakes', value: '${state.mistakeCount}'),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(growable: false),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _SectionCard(
                                title: 'Emotion timeline',
                                subtitle: 'Recent adaptive signals written after lesson completion.',
                                child: insight.emotionEvents.isEmpty
                                    ? const _EmptyState(message: 'No emotion events recorded yet.')
                                    : Column(
                                        children: insight.emotionEvents
                                            .map(
                                              (event) => Padding(
                                                padding: const EdgeInsets.only(bottom: 10),
                                                child: Container(
                                                  padding: const EdgeInsets.all(14),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFF8FBFD),
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          _RoleBadge(label: event.emotion, color: const Color(0xFF0E7C86)),
                                                          const SizedBox(width: 8),
                                                          Text(event.lessonId, style: _bodyStyle()),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Wrap(
                                                        spacing: 8,
                                                        runSpacing: 8,
                                                        children: [
                                                          _MetricChip(label: 'Score', value: '${(event.score * 100).round()}%'),
                                                          _MetricChip(label: 'Mastery', value: '${(event.masteryScore * 100).round()}%'),
                                                          _MetricChip(label: 'Mistakes', value: '${event.mistakeCount}'),
                                                          _MetricChip(
                                                            label: 'Time',
                                                            value: event.createdAt == null
                                                                ? 'Pending'
                                                                : '${event.createdAt!.day}/${event.createdAt!.month} ${event.createdAt!.hour}:${event.createdAt!.minute.toString().padLeft(2, '0')}',
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(growable: false),
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
          ),
        );
      },
    );
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F8FB), Color(0xFFEAF4F4), Color(0xFFF8F3E7)],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<AdminDashboardBundle>(
            future: _dashboardFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Failed to load admin dashboard', style: _headingStyle(28)),
                        const SizedBox(height: 12),
                        Text('${snapshot.error}', textAlign: TextAlign.center, style: _bodyStyle()),
                        const SizedBox(height: 20),
                        FilledButton(onPressed: _refresh, child: const Text('Retry')),
                      ],
                    ),
                  ),
                );
              }

              final data = snapshot.data;
              if (data == null) {
                return const Center(child: Text('No admin data available.'));
              }

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _buildHeader(data),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _SummaryCard(label: 'Admins', value: '${data.adminCount}', icon: Icons.admin_panel_settings_rounded),
                        _SummaryCard(label: 'Managers', value: '${data.pedagogiqueManagerCount}', icon: Icons.school_rounded),
                        _SummaryCard(label: 'Teachers', value: '${data.teacherCount}', icon: Icons.groups_2_rounded),
                        _SummaryCard(label: 'Students', value: '${data.studentCount}', icon: Icons.child_care_rounded),
                        _SummaryCard(label: 'Support needed', value: '${data.supportNeededStudents}', icon: Icons.favorite_rounded),
                        _SummaryCard(label: 'Avg mastery', value: '${(data.averageStudentMastery * 100).round()}%', icon: Icons.trending_up_rounded),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _SectionCard(
                      title: 'Provision Accounts',
                      subtitle: 'Create Firebase email/password accounts and matching role records with the minimum setup needed for MVP testing.',
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          SizedBox(
                            width: 560,
                            child: _buildUserProvisioningForm(data),
                          ),
                          SizedBox(
                            width: 360,
                            child: _buildSchoolCreationForm(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionCard(
                      title: 'Learning Trends',
                      subtitle: 'Operational signals for mastery, streak, and learners who may need support.',
                      child: _TrendPanel(bundle: data),
                    ),
                    const SizedBox(height: 20),
                    _SectionCard(
                      title: 'Schools',
                      subtitle: 'School-level capacity and performance overview.',
                      child: Column(
                        children: data.schoolSummaries.isEmpty
                            ? [const _EmptyState(message: 'No schools have been created yet.')]
                            : data.schoolSummaries
                                .map(
                                  (school) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _SchoolTile(summary: school),
                                  ),
                                )
                                .toList(growable: false),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionCard(
                      title: 'Teachers',
                      subtitle: 'Teaching capacity, assigned students, and support load by teacher.',
                      child: Column(
                        children: data.teacherSummaries.isEmpty
                            ? [const _EmptyState(message: 'No teachers are available yet.')]
                            : data.teacherSummaries
                                .map(
                                  (teacher) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _TeacherTile(summary: teacher),
                                  ),
                                )
                                .toList(growable: false),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionCard(
                      title: 'User Directory',
                      subtitle: 'Edit roles, deactivate accounts, and assign teachers without leaving the console.',
                      child: Column(
                        children: data.users.isEmpty
                            ? [const _EmptyState(message: 'No user accounts have been provisioned yet.')]
                            : data.users
                                .map(
                                  (user) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _UserTile(
                                      user: user,
                                      isBusy: _isMutating,
                                      onViewProgress: user.isStudent
                                          ? () => _showStudentInsightDialog(user)
                                          : null,
                                      onEdit: () => _showEditUserDialog(user),
                                      onToggleStatus: () => _updateStatus(user),
                                      onAssignTeacher: user.isStudent
                                          ? () => _showAssignTeacherDialog(user, data.teachers)
                                          : null,
                                    ),
                                  ),
                                )
                                .toList(growable: false),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AdminDashboardBundle data) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0E7C86), Color(0xFF1F9AA5), Color(0xFFF4B942)],
        ),
      ),
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 620,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    widget.currentRole == 'admin' ? 'Platform Admin' : 'Pedagogique Manager',
                    style: _bodyStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Control center for real schools, roles, and student health', style: _headingStyle(34, color: Colors.white)),
                const SizedBox(height: 10),
                Text(
                  'Signed in as ${widget.currentDisplayName}. Provision accounts securely, monitor mastery trends, and intervene when learners start struggling.',
                  style: _bodyStyle(color: Colors.white.withValues(alpha: 0.92)),
                ),
              ],
            ),
          ),
          Container(
            width: 280,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Live pulse', style: _headingStyle(20, color: Colors.white)),
                const SizedBox(height: 12),
                _HeaderMetric(label: 'Schools', value: '${data.schoolSummaries.length}'),
                _HeaderMetric(label: 'Avg streak', value: data.averageStudentStreak.toStringAsFixed(1)),
                _HeaderMetric(label: 'Support needed', value: '${data.supportNeededStudents}'),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: widget.onSignOut == null ? null : _signOut,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0E7C86),
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProvisioningForm(AdminDashboardBundle data) {
    final canProvision = widget.currentRole == 'admin';
    final availableRoles = _availableCreateRoles(data);
    final selectedRole = availableRoles.contains(_selectedRole)
        ? _selectedRole
        : (availableRoles.isEmpty ? null : availableRoles.first);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FBFD),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD8E1E8)),
          ),
          child: Text(
            canProvision
                ? 'Simple creation flow: email, password, then role. Firebase generates the user id automatically.'
                : 'Provisioning is locked here. Only the admin account can create new users.',
            style: _bodyStyle(color: const Color(0xFF64748B)),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(width: 260, child: _field(_emailController, 'Email', enabled: canProvision)),
            SizedBox(
              width: 260,
              child: _field(_passwordController, 'Password', obscureText: true, enabled: canProvision),
            ),
            SizedBox(
              width: 260,
              child: DropdownButtonFormField<String>(
                initialValue: selectedRole,
                isExpanded: true,
                decoration: _inputDecoration('Role'),
                items: availableRoles
                    .map(
                      (role) => DropdownMenuItem(
                        value: role,
                        child: Text(_roleLabel(role)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null || !canProvision) {
                    return;
                  }
                  setState(() {
                    _selectedRole = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricChip(label: 'Admin slots', value: '${1 - data.adminCount < 0 ? 0 : 1 - data.adminCount} left'),
            _MetricChip(
              label: 'Pedagogique slots',
              value: '${1 - data.pedagogiqueManagerCount < 0 ? 0 : 1 - data.pedagogiqueManagerCount} left',
            ),
            _MetricChip(label: 'Teacher creation', value: 'Open'),
            _MetricChip(label: 'Student creation', value: 'Open'),
          ],
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _isCreatingUser || !canProvision || availableRoles.isEmpty
                ? null
                : () => _createUser(data),
            icon: _isCreatingUser
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.person_add_alt_1_rounded),
            label: Text(_isCreatingUser ? 'Provisioning...' : 'Create account'),
          ),
        ),
      ],
    );
  }

  Widget _buildSchoolCreationForm() {
    final canCreateSchool = widget.currentRole == 'admin';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field(_newSchoolIdController, 'New school id', enabled: canCreateSchool),
        const SizedBox(height: 16),
        _field(_newSchoolNameController, 'New school name', enabled: canCreateSchool),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isCreatingSchool || !canCreateSchool ? null : _createSchool,
            icon: _isCreatingSchool
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_business_rounded),
            label: Text(_isCreatingSchool ? 'Creating...' : 'Create school'),
          ),
        ),
        if (!canCreateSchool) ...[
          const SizedBox(height: 12),
          Text(
            'School creation is reserved for the admin account.',
            style: _bodyStyle(color: const Color(0xFF64748B)),
          ),
        ],
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool obscureText = false,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      decoration: _inputDecoration(label),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF8FBFD),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFD8E1E8)),
      ),
    );
  }

  List<String> _availableCreateRoles(AdminDashboardBundle data) {
    if (widget.currentRole != 'admin') {
      return const <String>[];
    }

    final roles = <String>[];
    if (data.adminCount == 0) {
      roles.add('admin');
    }
    if (data.pedagogiqueManagerCount == 0) {
      roles.add('pedagogiqueManager');
    }
    roles.addAll(const ['teacher', 'student']);
    return roles;
  }

  List<String> _availableEditRolesFor(String currentRole) {
    if (widget.currentRole != 'admin') {
      return <String>[currentRole];
    }

    return const ['admin', 'pedagogiqueManager', 'teacher', 'student'];
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'pedagogiqueManager':
        return 'Pedagogique Manager';
      case 'teacher':
        return 'Teacher';
      case 'student':
        return 'Student';
      default:
        return 'Admin';
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFD8E1E8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x110F172A),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _headingStyle(24)),
          const SizedBox(height: 6),
          Text(subtitle, style: _bodyStyle(color: const Color(0xFF64748B))),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
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
      width: 200,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD8E1E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(value, style: _headingStyle(28)),
          const SizedBox(height: 4),
          Text(label, style: _bodyStyle(color: const Color(0xFF64748B))),
        ],
      ),
    );
  }
}

class _TrendPanel extends StatelessWidget {
  const _TrendPanel({required this.bundle});

  final AdminDashboardBundle bundle;

  @override
  Widget build(BuildContext context) {
    final mastery = bundle.averageStudentMastery.clamp(0.0, 1.0);
    final streak = (bundle.averageStudentStreak / 10).clamp(0.0, 1.0);
    final supportRatio = bundle.studentCount == 0
        ? 0.0
        : (bundle.supportNeededStudents / bundle.studentCount).clamp(0.0, 1.0);

    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        SizedBox(
          width: 280,
          child: _TrendCard(
            title: 'Mastery trend',
            value: '${(bundle.averageStudentMastery * 100).round()}%',
            progress: mastery,
            color: const Color(0xFF0E7C86),
          ),
        ),
        SizedBox(
          width: 280,
          child: _TrendCard(
            title: 'Streak momentum',
            value: bundle.averageStudentStreak.toStringAsFixed(1),
            progress: streak,
            color: const Color(0xFFF4B942),
          ),
        ),
        SizedBox(
          width: 280,
          child: _TrendCard(
            title: 'Support pressure',
            value: '${(supportRatio * 100).round()}%',
            progress: supportRatio,
            color: const Color(0xFFD65151),
          ),
        ),
        SizedBox(
          width: 340,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: bundle.schoolSummaries.take(4).map((school) {
              final progress = school.averageMastery.clamp(0.0, 1.0);
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(school.schoolName, style: _headingStyle(16))),
                        Text('${(school.averageMastery * 100).round()}%', style: _bodyStyle()),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 10,
                        value: progress,
                        backgroundColor: const Color(0xFFE6EEF3),
                        color: const Color(0xFF0E7C86),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(growable: false),
          ),
        ),
      ],
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({
    required this.title,
    required this.value,
    required this.progress,
    required this.color,
  });

  final String title;
  final String value;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFD),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _bodyStyle(color: const Color(0xFF64748B))),
          const SizedBox(height: 10),
          Text(value, style: _headingStyle(28)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress,
              backgroundColor: const Color(0xFFE6EEF3),
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: _bodyStyle(color: Colors.white.withValues(alpha: 0.88))),
          Text(value, style: _headingStyle(18, color: Colors.white)),
        ],
      ),
    );
  }
}

class _SchoolTile extends StatelessWidget {
  const _SchoolTile({required this.summary});

  final SchoolSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFD),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 260,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(summary.schoolName, style: _headingStyle(20)),
                const SizedBox(height: 4),
                Text(summary.schoolId, style: _bodyStyle(color: const Color(0xFF64748B))),
              ],
            ),
          ),
          _MetricChip(label: 'Teachers', value: '${summary.teacherCount}'),
          _MetricChip(label: 'Students', value: '${summary.studentCount}'),
          _MetricChip(label: 'Avg XP', value: '${summary.averageXp.round()}'),
          _MetricChip(label: 'Mastery', value: '${(summary.averageMastery * 100).round()}%'),
        ],
      ),
    );
  }
}

class _TeacherTile extends StatelessWidget {
  const _TeacherTile({required this.summary});

  final TeacherSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFD),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 260,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(summary.teacherName, style: _headingStyle(20)),
                const SizedBox(height: 4),
                Text(summary.schoolId, style: _bodyStyle(color: const Color(0xFF64748B))),
              ],
            ),
          ),
          _MetricChip(label: 'Students', value: '${summary.assignedStudents}'),
          _MetricChip(label: 'Mastery', value: '${(summary.averageMastery * 100).round()}%'),
          _MetricChip(label: 'Need support', value: '${summary.supportNeededCount}'),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    required this.isBusy,
    this.onViewProgress,
    required this.onEdit,
    required this.onToggleStatus,
    this.onAssignTeacher,
  });

  final AdminUserRecord user;
  final bool isBusy;
  final VoidCallback? onViewProgress;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback? onAssignTeacher;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFD),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.displayName, style: _headingStyle(20)),
                    const SizedBox(height: 4),
                    Text(user.email, style: _bodyStyle(color: const Color(0xFF64748B))),
                  ],
                ),
              ),
              _RoleBadge(label: user.role, color: const Color(0xFF0E7C86)),
              _RoleBadge(
                label: user.status,
                color: user.status == 'active' ? const Color(0xFF1A8D5F) : const Color(0xFFD65151),
              ),
              _MetricChip(label: 'School', value: user.schoolId),
              if (user.isStudent) _MetricChip(label: 'Emotion', value: user.currentEmotion),
              if (user.isStudent) _MetricChip(label: 'Stage', value: user.evolutionStage),
              if (user.isStudent) _MetricChip(label: 'XP', value: '${user.totalXp}'),
              if (user.isStudent) _MetricChip(label: 'Mastery', value: '${(user.masteryScore * 100).round()}%'),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (onViewProgress != null)
                OutlinedButton.icon(
                  onPressed: isBusy ? null : onViewProgress,
                  icon: const Icon(Icons.insights_rounded),
                  label: const Text('View progress'),
                ),
              OutlinedButton.icon(
                onPressed: isBusy ? null : onEdit,
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Edit'),
              ),
              OutlinedButton.icon(
                onPressed: isBusy ? null : onToggleStatus,
                icon: Icon(user.status == 'active' ? Icons.pause_circle_rounded : Icons.play_circle_rounded),
                label: Text(user.status == 'active' ? 'Deactivate' : 'Reactivate'),
              ),
              if (onAssignTeacher != null)
                OutlinedButton.icon(
                  onPressed: isBusy ? null : onAssignTeacher,
                  icon: const Icon(Icons.link_rounded),
                  label: const Text('Assign teacher'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: _bodyStyle(color: color),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8E1E8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: _headingStyle(16)),
          const SizedBox(height: 2),
          Text(label, style: _bodyStyle(color: const Color(0xFF64748B))),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFD),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(message, style: _bodyStyle(color: const Color(0xFF64748B))),
    );
  }
}

TextStyle _headingStyle(double size, {Color color = const Color(0xFF162033)}) {
  return GoogleFonts.fredoka(
    fontSize: size,
    fontWeight: FontWeight.w700,
    color: color,
  );
}

TextStyle _bodyStyle({Color color = const Color(0xFF162033)}) {
  return GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: color,
  );
}
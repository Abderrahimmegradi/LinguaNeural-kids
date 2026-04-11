import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_ui/shared_ui.dart';

class TeacherLoginScreen extends StatefulWidget {
  const TeacherLoginScreen({super.key});

  @override
  State<TeacherLoginScreen> createState() => _TeacherLoginScreenState();
}

class _TeacherLoginScreenState extends State<TeacherLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final userProvider = context.read<UserProvider>();
    final error = await userProvider.signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (error != null) {
      setState(() {
        _isSubmitting = false;
        _errorText = error;
      });
      return;
    }

    if (userProvider.role != UserRole.teacher) {
      await userProvider.signOut();
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
        _errorText = 'This login is reserved for teacher accounts.';
      });
      return;
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return RoleLoginShell(
      eyebrow: 'Teaching Studio',
      title: 'Lead every class with signal, not noise.',
      description:
          'Your classroom view should feel focused: roster visibility, learner progress, and lesson follow-through in one decisive workspace.',
      heroIcon: Icons.cast_for_education_rounded,
      primaryColor: scheme.primary,
      secondaryColor: const Color(0xFFE76F51),
      surfaceTint: const Color(0xFFF7F7FB),
      metrics: const <RoleLoginMetric>[
        RoleLoginMetric(
          label: 'Class readiness',
          value: 'Live roster',
          icon: Icons.groups_rounded,
        ),
        RoleLoginMetric(
          label: 'Progress review',
          value: 'Daily',
          icon: Icons.analytics_outlined,
        ),
        RoleLoginMetric(
          label: 'Lesson pacing',
          value: 'On track',
          icon: Icons.task_alt_rounded,
        ),
      ],
      points: const <RoleLoginPoint>[
        RoleLoginPoint(
          title: 'See who needs attention first',
          detail: 'Move straight from sign-in to student signals and class priorities.',
          icon: Icons.visibility_rounded,
        ),
        RoleLoginPoint(
          title: 'Keep your teaching rhythm',
          detail: 'Progress, speaking practice, and follow-ups stay aligned with the day.',
          icon: Icons.waves_rounded,
        ),
        RoleLoginPoint(
          title: 'Act without extra clicks',
          detail: 'The interface is tuned for quick review between lessons and transitions.',
          icon: Icons.bolt_rounded,
        ),
      ],
      heroFootnote: 'Built for pacing, clarity, and classroom momentum.',
      formTitle: 'Teacher sign in',
      formDescription:
          'Use your teacher account to open rosters, lesson activity, and learner progress.',
      formHighlights: const <String>[
        'Teacher-only access',
        'Roster and progress',
        'Fast classroom review',
      ],
      supportNote:
          'If you do not have access yet, contact your school administrator to activate your teaching account.',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Teacher email',
                hintText: 'teacher@school.com',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email is required.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _isSubmitting ? null : _submit(),
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline_rounded),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required.';
                }
                return null;
              },
            ),
            if (_errorText != null) ...<Widget>[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scheme.errorContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _errorText!,
                  style: TextStyle(
                    color: scheme.onErrorContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.menu_book_rounded),
              label: Text(_isSubmitting ? 'Signing in...' : 'Open teaching desk'),
            ),
          ],
        ),
      ),
    );
  }
}
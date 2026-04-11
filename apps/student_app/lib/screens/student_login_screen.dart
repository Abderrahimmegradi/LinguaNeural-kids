import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_ui/shared_ui.dart';

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
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

    if (userProvider.role != UserRole.student) {
      await userProvider.signOut();
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
        _errorText = 'This login is reserved for student accounts.';
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
      eyebrow: 'Learning Quest',
      title: 'Welcome back, explorer.',
      description:
          'Your next lesson, listening challenge, and speaking streak are ready in a playful space built for confidence.',
      heroIcon: Icons.auto_awesome_rounded,
      primaryColor: scheme.primary,
      secondaryColor: const Color(0xFFF4B942),
      surfaceTint: const Color(0xFFF4FBFC),
      metrics: const <RoleLoginMetric>[
        RoleLoginMetric(
          label: 'Daily streak focus',
          value: '15 min',
          icon: Icons.timer_outlined,
        ),
        RoleLoginMetric(
          label: 'Practice modes',
          value: '4 paths',
          icon: Icons.extension_rounded,
        ),
        RoleLoginMetric(
          label: 'Voice confidence',
          value: 'Live',
          icon: Icons.mic_none_rounded,
        ),
      ],
      points: const <RoleLoginPoint>[
        RoleLoginPoint(
          title: 'Resume your lesson trail',
          detail: 'Pick up exactly where you stopped without hunting through menus.',
          icon: Icons.explore_rounded,
        ),
        RoleLoginPoint(
          title: 'Practice out loud',
          detail: 'Keep speaking activities close so pronunciation work feels natural.',
          icon: Icons.record_voice_over_rounded,
        ),
        RoleLoginPoint(
          title: 'Celebrate progress',
          detail: 'Rewards, streaks, and friendly feedback stay visible from the start.',
          icon: Icons.celebration_rounded,
        ),
      ],
      heroFootnote: 'Designed to feel encouraging first, never administrative.',
      formTitle: 'Student sign in',
      formDescription:
          'Use your student email and password to open today\'s learning journey.',
      formHighlights: const <String>[
        'Student-only access',
        'Lessons and streaks',
        'Classroom credentials',
      ],
      supportNote:
          'Need help getting back in? Ask your teacher or school coordinator for your classroom credentials.',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Student email',
                hintText: 'student@school.com',
                prefixIcon: Icon(Icons.alternate_email_rounded),
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
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline_rounded),
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _isSubmitting ? null : _submit(),
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
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.rocket_launch_rounded),
              label: Text(_isSubmitting ? 'Signing in...' : 'Start today\'s lesson'),
            ),
          ],
        ),
      ),
    );
  }
}
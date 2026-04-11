import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_ui/shared_ui.dart';

class SchoolLoginScreen extends StatefulWidget {
  const SchoolLoginScreen({super.key});

  @override
  State<SchoolLoginScreen> createState() => _SchoolLoginScreenState();
}

class _SchoolLoginScreenState extends State<SchoolLoginScreen> {
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

    if (userProvider.role != UserRole.school) {
      await userProvider.signOut();
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
        _errorText = 'This login is reserved for school accounts.';
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
      eyebrow: 'School Operations',
      title: 'See your campus with calm control.',
      description:
          'This school view is about oversight with clarity: teachers, student growth, and operational follow-through without clutter.',
      heroIcon: Icons.apartment_rounded,
      primaryColor: scheme.primary,
      secondaryColor: const Color(0xFF2A9D8F),
      surfaceTint: const Color(0xFFF7FBFA),
      metrics: const <RoleLoginMetric>[
        RoleLoginMetric(
          label: 'Teacher coordination',
          value: 'Centralized',
          icon: Icons.badge_rounded,
        ),
        RoleLoginMetric(
          label: 'Student growth view',
          value: 'Schoolwide',
          icon: Icons.trending_up_rounded,
        ),
        RoleLoginMetric(
          label: 'Operational rhythm',
          value: 'Daily',
          icon: Icons.event_note_rounded,
        ),
      ],
      points: const <RoleLoginPoint>[
        RoleLoginPoint(
          title: 'Track the whole learning system',
          detail: 'Move from sign-in to the status of teachers, students, and school performance.',
          icon: Icons.hub_rounded,
        ),
        RoleLoginPoint(
          title: 'Balance growth and operations',
          detail: 'Keep academic progress and management tasks visible in the same frame.',
          icon: Icons.balance_rounded,
        ),
        RoleLoginPoint(
          title: 'Stay organized under pressure',
          detail: 'The layout is designed to feel composed during busy school-day decisions.',
          icon: Icons.shield_moon_rounded,
        ),
      ],
      heroFootnote: 'Made for oversight, coordination, and a calmer administrative pace.',
      formTitle: 'School sign in',
      formDescription:
          'Use your school account to manage teachers, student progress, and campus-level activity.',
      formHighlights: const <String>[
        'School-only access',
        'Campus oversight',
        'Teacher coordination',
      ],
      supportNote:
          'Need access support? Contact the platform administrator linked to your school account.',
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
                labelText: 'School email',
                hintText: 'school@district.org',
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
                  : const Icon(Icons.apartment_rounded),
              label: Text(_isSubmitting ? 'Signing in...' : 'Open school overview'),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_ui/shared_ui.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
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

    if (userProvider.role != UserRole.admin) {
      await userProvider.signOut();
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
        _errorText = 'This login is reserved for admin accounts.';
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
      eyebrow: 'Platform Command',
      title: 'Coordinate the whole network from one clear front door.',
      description:
          'Admin access should feel authoritative and precise: school hierarchy, platform access, and system-wide actions without visual noise.',
      heroIcon: Icons.admin_panel_settings_rounded,
      primaryColor: scheme.primary,
      secondaryColor: const Color(0xFF4C6FFF),
      surfaceTint: const Color(0xFFF8F8FC),
      metrics: const <RoleLoginMetric>[
        RoleLoginMetric(
          label: 'School network',
          value: 'Managed',
          icon: Icons.account_tree_rounded,
        ),
        RoleLoginMetric(
          label: 'Access control',
          value: 'Role-based',
          icon: Icons.verified_user_rounded,
        ),
        RoleLoginMetric(
          label: 'Critical actions',
          value: 'Guarded',
          icon: Icons.gpp_good_rounded,
        ),
      ],
      points: const <RoleLoginPoint>[
        RoleLoginPoint(
          title: 'See the system as a whole',
          detail: 'Start with global visibility instead of drilling through fragmented screens.',
          icon: Icons.public_rounded,
        ),
        RoleLoginPoint(
          title: 'Manage hierarchy safely',
          detail: 'The experience signals control and consequence before high-impact actions.',
          icon: Icons.rule_folder_rounded,
        ),
        RoleLoginPoint(
          title: 'Move with confidence',
          detail: 'The interface favors steady decisions, not bright distractions or generic chrome.',
          icon: Icons.track_changes_rounded,
        ),
      ],
      heroFootnote: 'Structured to feel trusted, deliberate, and operationally serious.',
      formTitle: 'Admin sign in',
      formDescription:
          'Use your administrator account to manage platform structure, access, and cross-school operations.',
      formHighlights: const <String>[
        'Restricted access',
        'System-wide control',
        'High-impact actions',
      ],
      supportNote:
          'Admin access is restricted. If you believe this is incorrect, contact the platform owner before retrying.',
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
                labelText: 'Administrator email',
                hintText: 'admin@lingua-neural.com',
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
                  : const Icon(Icons.security_rounded),
              label: Text(_isSubmitting ? 'Signing in...' : 'Enter command center'),
            ),
          ],
        ),
      ),
    );
  }
}
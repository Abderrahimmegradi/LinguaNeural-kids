import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (error) {
      setState(() {
        _error = error.message ?? 'Unable to sign in.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardInset = mediaQuery.viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, viewportConstraints) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF3F7FA), Color(0xFFE5F1F3), Color(0xFFF8EEDB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -80,
                  left: -40,
                  child: _GlowBubble(color: const Color(0xFF0E7C86).withValues(alpha: 0.18), size: 260),
                ),
                Positioned(
                  bottom: -40,
                  right: -20,
                  child: _GlowBubble(color: const Color(0xFFF4B942).withValues(alpha: 0.22), size: 220),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardInset + 16),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight - 32),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1080),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isCompact = constraints.maxWidth < 920;
                              final hideHero = isCompact && keyboardInset > 0;
                              final hero = Container(
                                padding: EdgeInsets.all(isCompact ? 26 : 36),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF0E7C86), Color(0xFF1F9AA5), Color(0xFF0E7C86)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(34),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.16),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        'Lingua Neural Kids Admin',
                                        style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                    const SizedBox(height: 22),
                                    Text(
                                      'Run the whole learning platform from one calm control room.',
                                      style: GoogleFonts.fredoka(
                                        fontSize: isCompact ? 32 : 42,
                                        height: 1.05,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    Text(
                                      'Create accounts, watch mastery trends, and follow student wellbeing with a cleaner web workflow.',
                                      style: GoogleFonts.nunito(
                                        fontSize: isCompact ? 16 : 18,
                                        height: 1.4,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white.withValues(alpha: 0.92),
                                      ),
                                    ),
                                    const SizedBox(height: 28),
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: const [
                                        _LoginFeature(label: 'All statistics'),
                                        _LoginFeature(label: 'Role control'),
                                        _LoginFeature(label: 'Student insight'),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                              final card = Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(isCompact ? 24 : 30),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.94),
                                  borderRadius: BorderRadius.circular(34),
                                  border: Border.all(color: const Color(0xFFD8E1E8)),
                                  boxShadow: const [
                                    BoxShadow(color: Color(0x180F172A), blurRadius: 32, offset: Offset(0, 20)),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (hideHero) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE7F6F8),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          'Web control room',
                                          style: GoogleFonts.nunito(
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF0E7C86),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                    ],
                                    Text(
                                      'Admin Sign In',
                                      style: GoogleFonts.fredoka(
                                        fontSize: isCompact ? 30 : 34,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF162033),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Use the admin account or the single pedagogique manager account to enter the web console.',
                                      style: GoogleFonts.nunito(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FBFD),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'The dashboard keeps schools, users, progress, and wellbeing insight in one secure entry point.',
                                        style: GoogleFonts.nunito(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF486173),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    TextField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      decoration: _decoration('Email'),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      textInputAction: TextInputAction.done,
                                      onSubmitted: (_) {
                                        if (!_loading) {
                                          _signIn();
                                        }
                                      },
                                      decoration: _decoration('Password'),
                                    ),
                                    if (_error != null) ...[
                                      const SizedBox(height: 16),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF2F0),
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                        child: Text(
                                          _error!,
                                          style: GoogleFonts.nunito(
                                            color: const Color(0xFFB42318),
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      child: FilledButton(
                                        onPressed: _loading ? null : _signIn,
                                        style: FilledButton.styleFrom(
                                          backgroundColor: const Color(0xFF0E7C86),
                                          padding: const EdgeInsets.symmetric(vertical: 18),
                                        ),
                                        child: Text(_loading ? 'Signing in...' : 'Sign in'),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              return Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: isCompact ? 0 : 8,
                                  vertical: isCompact ? 8 : 24,
                                ),
                                child: isCompact
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          if (!hideHero) ...[
                                            hero,
                                            const SizedBox(height: 20),
                                          ],
                                          card,
                                        ],
                                      )
                                    : Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(child: hero),
                                          const SizedBox(width: 24),
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(maxWidth: 430),
                                            child: card,
                                          ),
                                        ],
                                      ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF8FBFD),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}

class _GlowBubble extends StatelessWidget {
  const _GlowBubble({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _LoginFeature extends StatelessWidget {
  const _LoginFeature({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (error) {
      setState(() {
        _error = error.message ?? 'Unable to log in.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
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
                colors: [Color(0xFFFFF4D8), Color(0xFFE4F6F8), Color(0xFFF6F0FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -60,
                  left: -30,
                  child: _StudentGlow(color: const Color(0xFFF4B942).withValues(alpha: 0.22), size: 220),
                ),
                Positioned(
                  bottom: -50,
                  right: -10,
                  child: _StudentGlow(color: const Color(0xFF0E7C86).withValues(alpha: 0.18), size: 240),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardInset + 16),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight - 32),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1100),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isCompact = constraints.maxWidth < 920;
                              final useMobileStack = isCompact;
                              final hero = Container(
                                padding: EdgeInsets.all(isCompact ? 24 : 34),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFF4B942), Color(0xFFE76F51), Color(0xFF8B5CF6)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(34),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Lumi, Baby, Nexo, Owl',
                                      style: GoogleFonts.nunito(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: isCompact ? 14 : 16,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    Text(
                                      'A playful language world that keeps every learner\'s progress personal.',
                                      style: GoogleFonts.fredoka(
                                        fontSize: isCompact ? 32 : 42,
                                        height: 1.05,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    Text(
                                      'Lessons, streaks, emotion tracking, audio prompts, and speaking practice all live in one colorful student journey.',
                                      style: GoogleFonts.nunito(
                                        fontSize: isCompact ? 16 : 18,
                                        height: 1.4,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white.withValues(alpha: 0.94),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: const [
                                        _StudentFeature(label: 'Voice practice'),
                                        _StudentFeature(label: 'Live rewards'),
                                        _StudentFeature(label: 'Adaptive lessons'),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                              final mobileHeroBanner = Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFF4B942), Color(0xFFE76F51)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.18),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Text('🦉', style: TextStyle(fontSize: 22)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Lumi, Baby, Nexo, and Owl are ready for today\'s lesson.',
                                        style: GoogleFonts.nunito(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              final card = Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(isCompact ? 24 : 30),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  borderRadius: BorderRadius.circular(34),
                                  border: Border.all(color: const Color(0xFFD8E1E8)),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x18000000),
                                      blurRadius: 28,
                                      offset: Offset(0, 18),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (useMobileStack) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8F8FA),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          'Emotion-aware student login',
                                          style: GoogleFonts.nunito(
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF0E7C86),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                    ],
                                    Text(
                                      'Student Log In',
                                      style: GoogleFonts.fredoka(
                                        fontSize: isCompact ? 30 : 34,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF162033),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Log in with the student account created by the admin so lessons, progress, and emotion history stay linked to the right learner.',
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
                                        'Your lessons, rewards, and wellbeing checkpoints stay connected to this login.',
                                        style: GoogleFonts.nunito(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF486173),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    TextField(
                                      key: const ValueKey('student-email-field'),
                                      controller: _emailController,
                                      focusNode: _emailFocusNode,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      autocorrect: false,
                                      enableSuggestions: false,
                                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                                      onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                                      decoration: _decoration('Email'),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      key: const ValueKey('student-password-field'),
                                      controller: _passwordController,
                                      focusNode: _passwordFocusNode,
                                      obscureText: true,
                                      textInputAction: TextInputAction.done,
                                      autocorrect: false,
                                      enableSuggestions: false,
                                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                                      onSubmitted: (_) {
                                        if (!_isLoading) {
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
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFFB42318),
                                          ),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      child: FilledButton(
                                        onPressed: _isLoading ? null : _signIn,
                                        style: FilledButton.styleFrom(
                                          backgroundColor: const Color(0xFF0E7C86),
                                          padding: const EdgeInsets.symmetric(vertical: 18),
                                        ),
                                        child: Text(_isLoading ? 'Logging in...' : 'Log In'),
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
                                child: useMobileStack
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          mobileHeroBanner,
                                          const SizedBox(height: 16),
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

class _StudentGlow extends StatelessWidget {
  const _StudentGlow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _StudentFeature extends StatelessWidget {
  const _StudentFeature({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'design_system/themes/app_theme.dart';
import 'student_app/screens/student_login_screen.dart';
import 'student_app/screens/student_role_redirect_screen.dart';
import 'student_app/screens/student_achievements_screen.dart';
import 'student_app/screens/student_daily_screen.dart';
import 'student_app/screens/student_home_screen.dart';
import 'student_app/screens/student_lesson_screen.dart';
import 'student_app/screens/student_profile_screen.dart';
import 'student_app/widgets/bottom_nav_bar.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.firebaseInitialization,
  });

  final Future<void> firebaseInitialization;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lingua Neural Kids',
      theme: AppTheme.lightTheme,
      home: _BootstrapGate(firebaseInitialization: firebaseInitialization),
    );
  }
}

class _BootstrapGate extends StatelessWidget {
  const _BootstrapGate({required this.firebaseInitialization});

  final Future<void> firebaseInitialization;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: firebaseInitialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _AppBootstrapScreen();
        }

        if (snapshot.hasError || Firebase.apps.isEmpty) {
          return const StudentAppShell();
        }

        return const _StudentAuthGate();
      },
    );
  }
}

class _StudentAuthGate extends StatefulWidget {
  const _StudentAuthGate();

  @override
  State<_StudentAuthGate> createState() => _StudentAuthGateState();
}

class _StudentAuthGateState extends State<_StudentAuthGate> {
  String? _roleFutureUserId;
  Future<DocumentSnapshot<Map<String, dynamic>>>? _roleFuture;

  Future<DocumentSnapshot<Map<String, dynamic>>> _roleForUser(String uid) {
    if (_roleFutureUserId == uid && _roleFuture != null) {
      return _roleFuture!;
    }

    _roleFutureUserId = uid;
    _roleFuture = FirebaseFirestore.instance.collection('users').doc(uid).get();
    return _roleFuture!;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final authUser = snapshot.data;
        if (authUser == null) {
          _roleFutureUserId = null;
          _roleFuture = null;
          return const StudentLoginScreen();
        }

        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: _roleForUser(authUser.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState != ConnectionState.done) {
              return const _AppBootstrapScreen(message: 'Preparing your student journey...');
            }

            final data = roleSnapshot.data?.data();
            final role = data?['role'] as String?;
            final status = data?['status'] as String? ?? 'active';

            if (data == null) {
              return StudentRoleRedirectScreen(
                title: 'Profile missing',
                message:
                    'This account exists in authentication, but the student profile has not been created yet. Ask the admin to finish account provisioning.',
                actionLabel: 'Log out',
                onAction: () => FirebaseAuth.instance.signOut(),
              );
            }

            if (status == 'inactive') {
              return StudentRoleRedirectScreen(
                title: 'Account inactive',
                message: 'This student account is inactive. Contact the administrator or teacher.',
                actionLabel: 'Log out',
                onAction: () => FirebaseAuth.instance.signOut(),
              );
            }

            if (role == 'student') {
              return const StudentAppShell();
            }

            final destination = switch (role) {
              'admin' || 'pedagogiqueManager' => 'admin app',
              'teacher' => 'teacher app',
              _ => 'assigned app',
            };

            return StudentRoleRedirectScreen(
              title: 'Use the correct app',
              message: 'This account has the role "$role" and should continue in the $destination.',
              actionLabel: 'Log out',
              onAction: () => FirebaseAuth.instance.signOut(),
            );
          },
        );
      },
    );
  }
}

class _PremiumLessonRoute extends PageRouteBuilder<void> {
  _PremiumLessonRoute({required WidgetBuilder builder})
      : super(
          transitionDuration: const Duration(milliseconds: 520),
          reverseTransitionDuration: const Duration(milliseconds: 380),
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.06),
                  end: Offset.zero,
                ).animate(curved),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.985, end: 1).animate(curved),
                  child: child,
                ),
              ),
            );
          },
        );
}

class _AppBootstrapScreen extends StatelessWidget {
  const _AppBootstrapScreen({
    this.message = 'Opening your learning space...',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF4D8), Color(0xFFE4F6F8), Color(0xFFF6F0FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x16000000),
                          blurRadius: 22,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const Text('🦉', style: TextStyle(fontSize: 38)),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Lingua Neural Kids',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF162033),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5B6472),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StudentAppShell extends StatefulWidget {
  const StudentAppShell({super.key});

  @override
  State<StudentAppShell> createState() => _StudentAppShellState();
}

class _StudentAppShellState extends State<StudentAppShell> {
  int _selectedIndex = 0;

  void _openLesson([String? lessonId]) {
    Navigator.of(context).push(
      _PremiumLessonRoute(
        builder: (_) => StudentLessonScreen(
          lessonId: lessonId,
          onReturnHome: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      StudentHomeScreen(
        onOpenProfile: () {
          setState(() {
            _selectedIndex = 3;
          });
        },
        onOpenLesson: _openLesson,
      ),
      StudentDailyScreen(onOpenLesson: _openLesson),
      const StudentAchievementsScreen(),
      const StudentProfileScreen(),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 360),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_selectedIndex),
          child: screens[_selectedIndex],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
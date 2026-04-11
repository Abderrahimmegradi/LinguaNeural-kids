import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'admin_dashboard_screen.dart';
import 'school_dashboard_screen.dart';
import 'teacher_dashboard_screen.dart';
import 'student_home_screen.dart';
import 'welcome_screen.dart';

class AuthGateScreen extends StatelessWidget {
  const AuthGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<fb_auth.User?>(
      stream: fb_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final firebaseUser = snapshot.data;
        if (firebaseUser == null) {
          return const WelcomeScreen();
        }

        return FutureBuilder<void>(
          future: context.read<UserProvider>().loadCurrentUserProfile(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (profileSnapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'We could not load your profile right now.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            context.read<UserProvider>().signOut();
                          },
                          child: const Text('Back To Welcome'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final userProvider = context.watch<UserProvider>();
            switch (userProvider.role) {
              case UserRole.admin:
                return const AdminDashboardScreen();
              case UserRole.school:
                return const SchoolDashboardScreen();
              case UserRole.teacher:
                return const TeacherDashboardScreen();
              case UserRole.student:
                return const StudentHomeScreen();
              case null:
                return Scaffold(
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Your profile is not ready yet. Please sign in again or contact the admin.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              context.read<UserProvider>().signOut();
                            },
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
            }
          },
        );
      },
    );
  }
}

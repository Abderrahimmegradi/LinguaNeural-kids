import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/role_redirect_screen.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0E7C86),
      primary: const Color(0xFF0E7C86),
      secondary: const Color(0xFFF4B942),
      surface: Colors.white,
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lingua Neural Kids Admin',
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF5F8FB),
        useMaterial3: true,
        textTheme: GoogleFonts.nunitoTextTheme(),
      ),
      home: Firebase.apps.isEmpty
          ? const AdminDashboardScreen(
              currentRole: 'admin',
              currentDisplayName: 'Offline Admin',
            )
          : const _AdminAuthGate(),
    );
  }
}

class _AdminAuthGate extends StatelessWidget {
  const _AdminAuthGate();

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
          return const AdminLoginScreen();
        }

        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance.collection('users').doc(authUser.uid).get(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final data = roleSnapshot.data?.data();
            final role = data?['role'] as String?;
            final status = data?['status'] as String? ?? 'active';
            final displayName = data?['displayName'] as String? ?? authUser.email ?? 'User';

            if (data == null) {
              return RoleRedirectScreen(
                title: 'Profile missing',
                message:
                    'Your auth account exists, but there is no user profile record yet. Create or sync the admin record first.',
                actionLabel: 'Sign out',
                onAction: () => FirebaseAuth.instance.signOut(),
              );
            }

            if (status == 'inactive') {
              return RoleRedirectScreen(
                title: 'Account inactive',
                message:
                    'This account is currently inactive. Contact the platform administrator.',
                actionLabel: 'Sign out',
                onAction: () => FirebaseAuth.instance.signOut(),
              );
            }

            if (role == 'admin' || role == 'pedagogiqueManager') {
              return AdminDashboardScreen(
                currentRole: role!,
                currentDisplayName: displayName,
                onSignOut: () => FirebaseAuth.instance.signOut(),
              );
            }

            final destination = switch (role) {
              'teacher' => 'teacher app',
              'student' => 'student app',
              _ => 'assigned app',
            };

            return RoleRedirectScreen(
              title: 'Use the correct app',
              message:
                  'This account has the role "$role" and should continue in the $destination after sign-in.',
              actionLabel: 'Sign out',
              onAction: () => FirebaseAuth.instance.signOut(),
            );
          },
        );
      },
    );
  }
}
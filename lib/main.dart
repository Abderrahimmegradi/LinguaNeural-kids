// DEPRECATED: Do not use. Use apps/* instead.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:backend_core/backend_core.dart';

import 'admin/upload_lessons.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/auth_gate_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/school_dashboard_screen.dart';
import 'screens/student_home_screen.dart';
import 'screens/teacher_dashboard_screen.dart';
import 'screens/welcome_screen_enhanced.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const LinguaNeuralApp());
}

class LinguaNeuralApp extends StatelessWidget {
  const LinguaNeuralApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'LinguaNeural Kids',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routes: {
          '/': (context) => const AuthGateScreen(),
          '/welcome': (context) => const WelcomeScreenEnhanced(),
          '/login': (context) => const LoginScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/admin-dashboard': (context) => const AdminDashboardScreen(),
          '/school-dashboard': (context) => const SchoolDashboardScreen(),
          '/teacher-dashboard': (context) => const TeacherDashboardScreen(),
          '/student-home': (context) => const StudentHomeScreen(),
          '/admin-upload-lessons': (context) => const UploadLessonsScreen(),
        },
        onUnknownRoute: (_) => MaterialPageRoute<void>(
          builder: (context) => const LoginScreen(),
        ),
      ),
    );
  }
}

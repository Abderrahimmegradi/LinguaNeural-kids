import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_home.dart';
import 'screens/progress_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/vocabulary_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/daily_challenge_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/rewards_shop_screen.dart';
import 'screens/parent_dashboard_screen.dart';
import 'screens/level_selection_screen.dart';
import 'screens/english_lessons_list_screen.dart';
import 'screens/english_lesson_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'providers/user_provider.dart';
import 'providers/lesson_provider.dart';
import 'providers/english_lesson_provider.dart';
import 'services/speech_service.dart';
import 'services/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Minimal Firebase options for web/emulator (dummy project ID for local development)
  const firebaseOptions = FirebaseOptions(
    apiKey: 'AIzaSyDemo_Key_For_Emulator_Testing_Only',
    appId: '1:000000000000:web:0000000000000000000000',
    projectId: 'demo',
    messagingSenderId: '000000000000',
    storageBucket: 'demo.appspot.com',
  );
  
  await Firebase.initializeApp(options: firebaseOptions);

  // Enable Firebase Emulator when built with:
  // flutter run --dart-define=USE_FIREBASE_EMULATOR=true
  const useEmulator = bool.fromEnvironment('USE_FIREBASE_EMULATOR', defaultValue: false);
  if (useEmulator || kDebugMode) {
    // Only enable emulator when explicitly requested or in debug mode
    try {
      FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      debugPrint('Using Firebase Emulator on localhost');
    } catch (e) {
      debugPrint('Failed to connect to emulator: $e');
    }
  }

  runApp(const LinguaNeuralApp());
}

class LinguaNeuralApp extends StatelessWidget {
  const LinguaNeuralApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => LessonProvider()),
        ChangeNotifierProvider(create: (_) => EnglishLessonProvider()),
        Provider(create: (_) => SpeechService()),
        Provider(create: (_) => AudioService()),
      ],
      child: MaterialApp(
        title: 'LinguaNeural Kids',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFFF5F7FA),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/home': (context) => const MainHomeScreen(),
          '/progress': (context) => const ProgressScreen(),
          '/achievements': (context) => const AchievementsScreen(),
          '/vocabulary': (context) => const VocabularyScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/daily-challenge': (context) => const DailyChallengeScreen(),
          '/leaderboard': (context) => const LeaderboardScreen(),
          '/rewards': (context) => const RewardsShopScreen(),
          '/parent-dashboard': (context) => const ParentDashboardScreen(),
          '/english-levels': (context) => const LevelSelectionScreen(),
          '/english-lessons': (context) => const EnglishLessonsListScreen(),
          '/english-lesson': (context) => const EnglishLessonScreen(),
        },
      ),
    );
  }
}
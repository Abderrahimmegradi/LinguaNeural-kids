import '../models/user.dart';
import '../models/lesson.dart';

class AppState {
  final User user;
  final List<Lesson> lessons;
  final Map<String, double> skillProgress;
  final String currentEmotion;
  final int dailyStreak;

  AppState({
    required this.user,
    required this.lessons,
    required this.skillProgress,
    required this.currentEmotion,
    required this.dailyStreak,
  });

  AppState copyWith({
    User? user,
    List<Lesson>? lessons,
    Map<String, double>? skillProgress,
    String? currentEmotion,
    int? dailyStreak,
  }) {
    return AppState(
      user: user ?? this.user,
      lessons: lessons ?? this.lessons,
      skillProgress: skillProgress ?? this.skillProgress,
      currentEmotion: currentEmotion ?? this.currentEmotion,
      dailyStreak: dailyStreak ?? this.dailyStreak,
    );
  }
}
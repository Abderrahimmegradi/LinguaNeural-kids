import 'package:flutter/foundation.dart';

class AppUserProfile {
  const AppUserProfile({
    required this.id,
    required this.displayName,
    required this.avatarCharacterId,
    required this.role,
    this.email,
    this.schoolId,
    this.teacherId,
  });

  final String id;
  final String displayName;
  final String avatarCharacterId;
  final String role;
  final String? email;
  final String? schoolId;
  final String? teacherId;

  AppUserProfile copyWith({
    String? id,
    String? displayName,
    String? avatarCharacterId,
    String? role,
    String? email,
    String? schoolId,
    String? teacherId,
  }) {
    return AppUserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      avatarCharacterId: avatarCharacterId ?? this.avatarCharacterId,
      role: role ?? this.role,
      email: email ?? this.email,
      schoolId: schoolId ?? this.schoolId,
      teacherId: teacherId ?? this.teacherId,
    );
  }
}

class UserProvider extends ChangeNotifier {
  String? currentUserId = 'student_demo';
  AppUserProfile? profile = const AppUserProfile(
    id: 'student_demo',
    displayName: 'User',
    avatarCharacterId: 'lumi',
    role: 'student',
  );
  int totalXP = 0;
  int dailyStreak = 1;
  String currentEmotion = 'curious';
  String evolutionStage = 'spark';
  double masteryScore = 0.42;

  int get level => 1 + (totalXP ~/ 100);

  void addXP(int value) {
    totalXP += value;
    notifyListeners();
  }

  void incrementStreak() {
    dailyStreak += 1;
    notifyListeners();
  }

  void updateEmotion(String emotion) {
    currentEmotion = emotion;
    notifyListeners();
  }

  void syncProgressMeta({
    required int nextTotalXp,
    required int nextDailyStreak,
    required String nextEmotion,
    required String nextEvolutionStage,
    required double nextMasteryScore,
  }) {
    totalXP = nextTotalXp;
    dailyStreak = nextDailyStreak;
    currentEmotion = nextEmotion;
    evolutionStage = nextEvolutionStage;
    masteryScore = nextMasteryScore;
    notifyListeners();
  }

  void syncFromRemote({
    required AppUserProfile nextProfile,
    required int nextTotalXp,
    required int nextDailyStreak,
    required String nextEmotion,
    required String nextEvolutionStage,
    required double nextMasteryScore,
  }) {
    currentUserId = nextProfile.id;
    profile = nextProfile;
    totalXP = nextTotalXp;
    dailyStreak = nextDailyStreak;
    currentEmotion = nextEmotion;
    evolutionStage = nextEvolutionStage;
    masteryScore = nextMasteryScore;
    notifyListeners();
  }

  void setAvatarCharacter(String avatarCharacterId) {
    final currentProfile = profile;
    if (currentProfile == null) {
      return;
    }

    profile = currentProfile.copyWith(avatarCharacterId: avatarCharacterId);
    notifyListeners();
  }
}
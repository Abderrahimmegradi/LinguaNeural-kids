import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';

import '../models/app_user_profile.dart';
import '../models/user.dart';
import '../services/progress_service.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  UserProvider({
    UserService? userService,
    ProgressService? progressService,
  }) : _userService = userService ?? UserService(),
       _progressService = progressService ?? ProgressService() {
    _auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        _user = null;
        _profile = null;
        notifyListeners();
        return;
      }
      await loadCurrentUserProfile();
    });
  }

  User? _user;
  AppUserProfile? _profile;
  String _currentEmotion = 'happy';
  int _dailyStreak = 0;
  int _totalXP = 0;
  int _level = 1;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final UserService _userService;
  final ProgressService _progressService;

  User? get user => _user;
  AppUserProfile? get profile => _profile;
  UserRole? get role => _profile?.role;
  String? get currentUserId => _auth.currentUser?.uid;
  String get currentEmotion => _currentEmotion;
  int get dailyStreak => _dailyStreak;
  int get totalXP => _totalXP;
  int get level => _level;
  bool get isLoggedIn => _auth.currentUser != null;
  bool get hasProfile => _profile != null;

  String get homeRoute {
    switch (_profile?.role) {
      case UserRole.admin:
        return '/admin-dashboard';
      case UserRole.school:
        return '/school-dashboard';
      case UserRole.teacher:
        return '/teacher-dashboard';
      case UserRole.student:
        return '/student-home';
      case null:
        return '/welcome';
    }
  }

  Future<void> loadCurrentUserProfile() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      _profile = null;
      _user = null;
      notifyListeners();
      return;
    }

    try {
      final profile = await _userService.getUserById(firebaseUser.uid);
      _profile = profile;
      if (profile == null) {
        _user = null;
        _totalXP = 0;
        _dailyStreak = 0;
        _level = 1;
      } else {
        await _loadGamificationStats(firebaseUser.uid);

        _user = User(
          id: profile.id,
          name: profile.name,
          email: profile.email,
          age: 8,
          currentEmotion: _currentEmotion,
          streakDays: _dailyStreak,
          totalXP: _totalXP,
          level: _level,
          skillProgress: getSkillProgress(),
          achievements: const [],
        );
      }
    } catch (_) {
      _profile = null;
      _user = null;
    }
    notifyListeners();
  }

  Future<void> _loadGamificationStats(String userId) async {
    try {
      final progressList = await _progressService.getProgressForStudent(userId);

      var totalXp = 0;
      for (final progress in progressList) {
        if (progress.completed) {
          totalXp += progress.xpEarned;
        }
      }

      _totalXP = totalXp;
      _level = (_totalXP ~/ 100) + 1;
    } catch (e) {
      debugPrint('Failed to load gamification stats: $e');
      _totalXP = 0;
      _level = 1;
    }
  }

  Future<String?> signUpWithEmail(
    String email,
    String password,
    String name,
    int age, {
    UserRole role = UserRole.student,
    String? schoolId,
  }) async {
    return 'Public signup is disabled. Ask the admin to create the account.';
  }

  Future<String?> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await loadCurrentUserProfile();
      if (_profile == null) {
        await _auth.signOut();
        notifyListeners();
        return 'This account is not active in the school platform. Contact your admin or teacher.';
      }
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _profile = null;
    _user = null;
    notifyListeners();
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void updateEmotion(String emotion) {
    _currentEmotion = emotion;
    notifyListeners();
  }

  void addXP(int xp) {
    _totalXP += xp;
    final newLevel = (_totalXP ~/ 100) + 1;
    if (newLevel > _level) {
      _level = newLevel;
    }
    notifyListeners();
  }

  void setGamificationStats({
    required int totalXP,
    required int dailyStreak,
  }) {
    _totalXP = totalXP;
    _dailyStreak = dailyStreak;
    _level = (_totalXP ~/ 100) + 1;
    notifyListeners();
  }

  void incrementStreak() {
    _dailyStreak++;
    notifyListeners();
  }

  void resetStreak() {
    _dailyStreak = 0;
    notifyListeners();
  }

  Map<String, double> getSkillProgress() {
    return {
      'listening': 0.75,
      'speaking': 0.60,
      'reading': 0.40,
      'writing': 0.25,
    };
  }
}
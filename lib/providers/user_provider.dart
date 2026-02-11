import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  String _currentEmotion = 'happy';
  int _dailyStreak = 7;
  int _totalXP = 150;
  int _level = 1;

  User? get user => _user;
  String get currentEmotion => _currentEmotion;
  int get dailyStreak => _dailyStreak;
  int get totalXP => _totalXP;
  int get level => _level;

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
    
    // Level up every 1000 XP
    final newLevel = (_totalXP ~/ 1000) + 1;
    if (newLevel > _level) {
      _level = newLevel;
    }
    
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
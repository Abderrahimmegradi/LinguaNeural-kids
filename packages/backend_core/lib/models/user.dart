class User {
  final String id;
  final String name;
  final String email;
  final int age;
  final String currentEmotion;
  final int streakDays;
  final int totalXP;
  final int level;
  final Map<String, double> skillProgress;
  final List<String> achievements;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.currentEmotion,
    required this.streakDays,
    required this.totalXP,
    required this.level,
    required this.skillProgress,
    required this.achievements,
  });

  int get nextLevelXP => level * 1000;
  double get levelProgress => (totalXP % 1000) / 1000;
}

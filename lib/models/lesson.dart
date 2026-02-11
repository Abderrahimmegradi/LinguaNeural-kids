class Lesson {
  final String id;
  final String title;
  final String description;
  final String category;
  final int level;
  final int duration; // in minutes
  final double progress; // 0.0 to 1.0
  final bool isLocked;
  final List<String> skills; // ['listening', 'speaking', 'reading', 'writing']
  final String icon;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.level,
    required this.duration,
    required this.progress,
    required this.isLocked,
    required this.skills,
    required this.icon,
  });

  String get difficulty {
    if (level <= 2) return 'Beginner';
    if (level <= 4) return 'Intermediate';
    return 'Advanced';
  }
}
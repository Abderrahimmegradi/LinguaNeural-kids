import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Achievement> achievements = [
      Achievement(
        id: 'welcome',
        name: 'Welcome!',
        description: 'Complete your first lesson',
        icon: '🎯',
        isUnlocked: true,
        unlockedDate: '2024-01-15',
      ),
      Achievement(
        id: 'fire_starter',
        name: 'Fire Starter',
        description: 'Maintain a 7-day streak',
        icon: '🔥',
        isUnlocked: true,
        unlockedDate: '2024-01-22',
      ),
      Achievement(
        id: 'word_master',
        name: 'Word Master',
        description: 'Learn 50 new words',
        icon: '📚',
        isUnlocked: true,
        unlockedDate: '2024-02-01',
      ),
      Achievement(
        id: 'speaking_star',
        name: 'Speaking Star',
        description: 'Complete 10 speaking exercises',
        icon: '🎤',
        isUnlocked: true,
        unlockedDate: '2024-02-05',
      ),
      Achievement(
        id: 'listening_legend',
        name: 'Listening Legend',
        description: 'Complete 10 listening exercises',
        icon: '👂',
        isUnlocked: false,
        unlockedDate: null,
      ),
      Achievement(
        id: 'speed_demon',
        name: 'Speed Demon',
        description: 'Complete a lesson in under 5 minutes',
        icon: '⚡',
        isUnlocked: false,
        unlockedDate: null,
      ),
      Achievement(
        id: 'level_up',
        name: 'Level Up!',
        description: 'Reach Level 5',
        icon: '⭐',
        isUnlocked: false,
        unlockedDate: null,
      ),
      Achievement(
        id: 'perfect_score',
        name: 'Perfect Score',
        description: 'Get 100% on a lesson',
        icon: '💯',
        isUnlocked: false,
        unlockedDate: null,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Achievements',
          style: GoogleFonts.nunitoSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A237E),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Stats
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFAB47BC),
                    Color(0xFF6A1B9A),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Achievements Earned',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${achievements.where((a) => a.isUnlocked).length}/${achievements.length}',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 50,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: achievements.where((a) => a.isUnlocked).length / achievements.length,
                      minHeight: 8,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // Achievements Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: achievements
                    .map((achievement) => AchievementCard(achievement: achievement))
                    .toList(),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final bool isUnlocked;
  final String? unlockedDate;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    this.unlockedDate,
  });
}

class AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const AchievementCard({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: achievement.isUnlocked ? 1.0 : 0.6,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: achievement.isUnlocked
                        ? const Color(0xFFFFD700).withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      achievement.icon,
                      style: const TextStyle(fontSize: 38),
                    ),
                  ),
                ),
                if (achievement.isUnlocked)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD700),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              achievement.name,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(
                fontSize: 11,
                color: const Color(0xFF546E7A),
              ),
            ),
            if (achievement.isUnlocked) ...[
              const SizedBox(height: 8),
              Text(
                'Unlocked ${achievement.unlockedDate}',
                style: GoogleFonts.nunitoSans(
                  fontSize: 10,
                  color: const Color(0xFF90A4AE),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
    );
  }
}

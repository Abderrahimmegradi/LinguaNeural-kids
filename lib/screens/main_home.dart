import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'lesson_selection.dart';
import 'profile_screen.dart';
import 'practice_screen.dart';
import 'progress_screen.dart';
import 'achievements_screen.dart';
import 'vocabulary_screen.dart';
import 'settings_screen.dart';
import 'daily_challenge_screen.dart';
import 'leaderboard_screen.dart';
import 'rewards_shop_screen.dart';
import '../providers/user_provider.dart';
import '../providers/lesson_provider.dart';
import '../providers/english_lesson_provider.dart';
import '../data/firebase_lessons_curriculum.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final lessonProvider = Provider.of<LessonProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'LinguaNeural Kids',
          style: GoogleFonts.nunitoSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A237E),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF1A237E),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Home Tab
          SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    // Welcome Card
                    Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF66BB6A),
                            Color(0xFF29B6F6),
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
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Color(0xFF1A237E),
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 15),
                          // Welcome Text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello, ${userProvider.user?.name ?? 'Friend'}! 👋',
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Ready for today\'s lesson?',
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Streak
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.local_fire_department,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '${userProvider.dailyStreak}',
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Start Learning English Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LessonSelectionScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A237E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            'Start Learning English',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Daily Goal
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(15),
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
                        child: Row(
                          children: [
                            const Icon(
                              Icons.flag_outlined,
                              color: Color(0xFFFF9800),
                              size: 30,
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Daily Goal',
                                    style: GoogleFonts.nunitoSans(
                                      fontSize: 14,
                                      color: const Color(0xFF546E7A),
                                    ),
                                  ),
                                  Text(
                                    'Complete 3 lessons today',
                                    style: GoogleFonts.nunitoSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1A237E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF9800).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                '${lessonProvider.completedLessons}/3',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFFF9800),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Skills Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Skills',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A237E),
                            ),
                          ),
                          const SizedBox(height: 15),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            children: const [
                              SkillCard(
                                title: 'Listening',
                                icon: Icons.headphones,
                                color: Color(0xFF66BB6A),
                                progress: 75,
                              ),
                              SkillCard(
                                title: 'Speaking',
                                icon: Icons.mic,
                                color: Color(0xFFFF9800),
                                progress: 60,
                              ),
                              SkillCard(
                                title: 'Reading',
                                icon: Icons.menu_book,
                                color: Color(0xFF29B6F6),
                                progress: 40,
                              ),
                              SkillCard(
                                title: 'Writing',
                                icon: Icons.edit,
                                color: Color(0xFFAB47BC),
                                progress: 25,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Quick Access Features
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Access',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A237E),
                            ),
                          ),
                          const SizedBox(height: 15),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            children: [
                              _buildQuickAccessButton(
                                context,
                                icon: '📊',
                                label: 'Progress',
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressScreen())),
                              ),
                              _buildQuickAccessButton(
                                context,
                                icon: '⭐',
                                label: 'Achievements',
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementsScreen())),
                              ),
                              _buildQuickAccessButton(
                                context,
                                icon: '📚',
                                label: 'Vocabulary',
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VocabularyScreen())),
                              ),
                              _buildQuickAccessButton(
                                context,
                                icon: '🎯',
                                label: 'Daily Challenge',
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyChallengeScreen())),
                              ),
                              _buildQuickAccessButton(
                                context,
                                icon: '🏆',
                                label: 'Leaderboard',
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
                              ),
                              _buildQuickAccessButton(
                                context,
                                icon: '🎁',
                                label: 'Rewards Shop',
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RewardsShopScreen())),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Continue Learning
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Continue Learning',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A237E),
                            ),
                          ),
                          const SizedBox(height: 15),
                          const LessonCard(
                            title: 'Greetings',
                            description: 'Learn basic greetings',
                            progress: 80,
                            color: Color(0xFF26A69A),
                          ),
                          const SizedBox(height: 10),
                          const LessonCard(
                            title: 'Numbers',
                            description: 'Count from 1 to 20',
                            progress: 50,
                            color: Color(0xFFEC407A),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
          // Practice Tab
          const PracticeScreen(),
          // Profile Tab
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1A237E),
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: GoogleFonts.nunitoSans(
          fontWeight: FontWeight.w600,
        ),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'Practice',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton(
    BuildContext context, {
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A237E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SkillCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int progress;

  const SkillCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: GoogleFonts.nunitoSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: color.withOpacity(0.2),
                  color: color,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 5),
                Text(
                  '$progress% Complete',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12,
                    color: const Color(0xFF546E7A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  final String title;
  final String description;
  final int progress;
  final Color color;

  const LessonCard({
    super.key,
    required this.title,
    required this.description,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        child: Row(
          children: [
            // Progress Circle
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    value: progress / 100,
                    backgroundColor: color.withOpacity(0.2),
                    color: color,
                    strokeWidth: 5,
                  ),
                ),
                Text(
                  '$progress%',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 15),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14,
                      color: const Color(0xFF546E7A),
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Your Progress',
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
            // Level Progress Card
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Level',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Level ${userProvider.level}',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Progress to Next Level',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (userProvider.totalXP % 1000) / 1000,
                      minHeight: 10,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${(userProvider.totalXP % 1000)} / 1000 XP',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Total Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistics',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _StatCard(
                        icon: Icons.local_fire_department,
                        title: 'Streak',
                        value: '${userProvider.dailyStreak}',
                        unit: 'days',
                        color: const Color(0xFFFF6B6B),
                      ),
                      const SizedBox(width: 15),
                      _StatCard(
                        icon: Icons.stars,
                        title: 'Total XP',
                        value: '${userProvider.totalXP}',
                        unit: 'points',
                        color: const Color(0xFFFFD93D),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _StatCard(
                        icon: Icons.school,
                        title: 'Level',
                        value: '${userProvider.level}',
                        unit: 'completed',
                        color: const Color(0xFF6BCB77),
                      ),
                      const SizedBox(width: 15),
                      const _StatCard(
                        icon: Icons.check_circle,
                        title: 'Lessons',
                        value: '12',
                        unit: 'completed',
                        color: Color(0xFF4D96FF),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Skills Chart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Skill Progress',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
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
                    child: const Column(
                      children: [
                        _SkillProgressBar(
                          skill: 'Listening',
                          progress: 75,
                          color: Color(0xFF66BB6A),
                        ),
                        SizedBox(height: 15),
                        _SkillProgressBar(
                          skill: 'Speaking',
                          progress: 60,
                          color: Color(0xFFFF9800),
                        ),
                        SizedBox(height: 15),
                        _SkillProgressBar(
                          skill: 'Reading',
                          progress: 40,
                          color: Color(0xFF29B6F6),
                        ),
                        SizedBox(height: 15),
                        _SkillProgressBar(
                          skill: 'Writing',
                          progress: 25,
                          color: Color(0xFFAB47BC),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.nunitoSans(
                fontSize: 14,
                color: const Color(0xFF546E7A),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  value,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A237E),
                  ),
                ),
              ],
            ),
            Text(
              unit,
              style: GoogleFonts.nunitoSans(
                fontSize: 12,
                color: const Color(0xFF90A4AE),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillProgressBar extends StatelessWidget {
  final String skill;
  final int progress;
  final Color color;

  const _SkillProgressBar({
    required this.skill,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              skill,
              style: GoogleFonts.nunitoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A237E),
              ),
            ),
            Text(
              '$progress%',
              style: GoogleFonts.nunitoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress / 100,
            minHeight: 8,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Profile',
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
            // Profile Header
            Container(
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF66BB6A),
                    Color(0xFF29B6F6),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // User Info
                  Text(
                    userProvider.user?.name ?? 'Friend',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 5),
                  
                  Text(
                    'Level ${userProvider.level} Learner',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      StatItem(
                        value: '${userProvider.dailyStreak}',
                        label: 'Day Streak',
                        icon: Icons.local_fire_department,
                        color: Colors.white,
                      ),
                      StatItem(
                        value: 'Level ${userProvider.level}',
                        label: 'Current Level',
                        icon: Icons.trending_up,
                        color: Colors.white,
                      ),
                      StatItem(
                        value: '${userProvider.totalXP}',
                        label: 'Total XP',
                        icon: Icons.star,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Learning Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Learning Statistics',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A237E),
                    ),
                  ),
                  
                  const SizedBox(height: 15),
                  
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                        SkillProgressRow(
                          skill: 'Listening',
                          progress: 0.75,
                          color: Color(0xFF66BB6A),
                        ),
                        SkillProgressRow(
                          skill: 'Speaking',
                          progress: 0.60,
                          color: Color(0xFFFF9800),
                        ),
                        SkillProgressRow(
                          skill: 'Reading',
                          progress: 0.40,
                          color: Color(0xFF29B6F6),
                        ),
                        SkillProgressRow(
                          skill: 'Writing',
                          progress: 0.25,
                          color: Color(0xFFAB47BC),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Settings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A237E),
                    ),
                  ),
                  
                  const SizedBox(height: 15),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SettingsItem(
                          icon: Icons.trending_up,
                          title: 'Progress & Statistics',
                          subtitle: 'View your learning progress',
                          onTap: () {
                            Navigator.pushNamed(context, '/progress');
                          },
                        ),
                        SettingsItem(
                          icon: Icons.star,
                          title: 'Achievements',
                          subtitle: 'View your earned badges',
                          onTap: () {
                            Navigator.pushNamed(context, '/achievements');
                          },
                        ),
                        SettingsItem(
                          icon: Icons.leaderboard,
                          title: 'Leaderboard',
                          subtitle: 'See global rankings',
                          onTap: () {
                            Navigator.pushNamed(context, '/leaderboard');
                          },
                        ),
                        SettingsItem(
                          icon: Icons.card_giftcard,
                          title: 'Rewards Shop',
                          subtitle: 'Spend your coins on rewards',
                          onTap: () {
                            Navigator.pushNamed(context, '/rewards');
                          },
                        ),
                        SettingsItem(
                          icon: Icons.emoji_emotions,
                          title: 'Daily Challenge',
                          subtitle: 'Complete today\'s challenge',
                          onTap: () {
                            Navigator.pushNamed(context, '/daily-challenge');
                          },
                        ),
                        SettingsItem(
                          icon: Icons.school,
                          title: 'Parent Dashboard',
                          subtitle: 'For parents to monitor progress',
                          onTap: () {
                            Navigator.pushNamed(context, '/parent-dashboard');
                          },
                        ),
                        SettingsItem(
                          icon: Icons.settings,
                          title: 'Settings',
                          subtitle: 'App preferences and options',
                          onTap: () {
                            Navigator.pushNamed(context, '/settings');
                          },
                        ),
                        SettingsItem(
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                          subtitle: 'FAQ and contact support',
                          onTap: () {},
                        ),
                        SettingsItem(
                          icon: Icons.logout,
                          title: 'Log Out',
                          subtitle: 'Sign out of your account',
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/',
                              (route) => false,
                            );
                          },
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const StatItem({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 30,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.nunitoSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.nunitoSans(
            fontSize: 12,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

class SkillProgressRow extends StatelessWidget {
  final String skill;
  final double progress;
  final Color color;

  const SkillProgressRow({
    super.key,
    required this.skill,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                skill,
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A237E),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.nunitoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.2),
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (color ?? const Color(0xFF1A237E)).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: color ?? const Color(0xFF1A237E),
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.nunitoSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: color ?? const Color(0xFF1A237E),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.nunitoSans(
          fontSize: 14,
          color: const Color(0xFF546E7A),
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
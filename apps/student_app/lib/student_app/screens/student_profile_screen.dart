import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/providers/user_provider.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final profile = user.profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0E7C86), Color(0xFF1A936F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.xxl),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 74,
                        height: 74,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _avatarEmoji(profile?.avatarCharacterId),
                          style: const TextStyle(fontSize: 34),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile?.displayName ?? 'Student',
                              style: GoogleFonts.fredoka(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              profile?.email ?? FirebaseAuth.instance.currentUser?.email ?? 'No email',
                              style: GoogleFonts.nunito(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      _pill('Role', profile?.role ?? 'student'),
                      _pill('Emotion', user.currentEmotion),
                      _pill('Evolution', user.evolutionStage),
                      _pill('Level', '${user.level}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(child: _metricCard('XP', '${user.totalXP}', Icons.bolt_rounded)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _metricCard('Streak', '${user.dailyStreak}', Icons.local_fire_department_rounded)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _metricCard('Mastery', '${(user.masteryScore * 100).round()}%', Icons.psychology_alt_rounded)),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _sectionCard(
              title: 'Account',
              children: [
                _infoRow('User Id', profile?.id ?? 'Not synced yet'),
                _infoRow('School', profile?.schoolId ?? 'Will be assigned by admin'),
                _infoRow('Teacher', profile?.teacherId ?? 'Will be assigned by admin'),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _sectionCard(
              title: 'Learning State',
              children: [
                _infoRow('Current emotion', user.currentEmotion),
                _infoRow('Evolution stage', user.evolutionStage),
                _infoRow('Mastery score', '${(user.masteryScore * 100).round()}%'),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: FirebaseAuth.instance.currentUser == null
                  ? null
                  : () => FirebaseAuth.instance.signOut(),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.fredoka(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: GoogleFonts.fredoka(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Text(
        '$label: $value',
        style: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  String _avatarEmoji(String? avatarCharacterId) {
    switch (avatarCharacterId) {
      case 'zippy':
      case 'baby':
        return '🧸';
      case 'nexo':
        return '⚙️';
      case 'owl':
      case 'orin':
        return '🦉';
      default:
        return '💡';
    }
  }
}
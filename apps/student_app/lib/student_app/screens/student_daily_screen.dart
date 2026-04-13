import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/models/character.dart';
import '../../core/providers/user_provider.dart';

class StudentDailyScreen extends StatelessWidget {
  const StudentDailyScreen({
    super.key,
    this.onOpenLesson,
  });

  final VoidCallback? onOpenLesson;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final activeCharacter = Character.byId(user.profile?.avatarCharacterId);

    final missions = [
      ('Voice warm-up', 'Say the target phrase with ${activeCharacter.name}.', Icons.mic_rounded),
      ('Listening focus', 'Replay one sound and match it correctly.', Icons.headphones_rounded),
      ('Streak shield', 'Complete one lesson to protect your streak.', Icons.local_fire_department_rounded),
    ];

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
                  colors: [Color(0xFFE76F51), Color(0xFFF4B942)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.xxl),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily Mission', style: _headingStyle(30, Colors.white)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Keep the rhythm today with one lesson, one voice check, and one reward unlock.',
                    style: _bodyStyle(Colors.white.withValues(alpha: 0.92)),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      _pill('Streak', '${user.dailyStreak} days'),
                      _pill('Emotion', user.currentEmotion),
                      _pill('Evolution', user.evolutionStage),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton.icon(
                    onPressed: onOpenLesson,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryDark,
                    ),
                    icon: const Icon(Icons.play_circle_fill_rounded),
                    label: const Text('Start today\'s lesson'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Today\'s checklist', style: _headingStyle(24, AppColors.text)),
            const SizedBox(height: AppSpacing.md),
            for (final mission in missions)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Icon(mission.$3, color: AppColors.primaryDark),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(mission.$1, style: _headingStyle(18, AppColors.text)),
                            const SizedBox(height: AppSpacing.xs),
                            Text(mission.$2, style: _bodyStyle(AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: activeCharacter.secondaryColor,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                border: Border.all(color: AppColors.outline),
              ),
              child: Row(
                children: [
                  Text(activeCharacter.emoji, style: const TextStyle(fontSize: 48)),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${activeCharacter.name} says', style: _headingStyle(20, AppColors.text)),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Short practice every day builds a strong voice, stronger confidence, and faster mastery.',
                          style: _bodyStyle(AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _pill(String label, String value) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.18),
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

TextStyle _headingStyle(double size, Color color) {
  return GoogleFonts.fredoka(
    fontSize: size,
    fontWeight: FontWeight.w700,
    color: color,
  );
}

TextStyle _bodyStyle(Color color) {
  return GoogleFonts.nunito(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: color,
  );
}
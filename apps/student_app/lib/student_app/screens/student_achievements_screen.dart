import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/models/character.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/firestore_learning_service.dart';

class StudentAchievementsScreen extends StatefulWidget {
  const StudentAchievementsScreen({super.key});

  @override
  State<StudentAchievementsScreen> createState() => _StudentAchievementsScreenState();
}

class _StudentAchievementsScreenState extends State<StudentAchievementsScreen> {
  final FirestoreLearningService _learningService = FirestoreLearningService();
  String? _savingCharacterId;

  Future<void> _selectCharacter(Character character) async {
    final user = context.read<UserProvider>();
    final userId = user.currentUserId;

    setState(() {
      _savingCharacterId = character.id;
    });

    user.setAvatarCharacter(character.id);

    try {
      if (userId != null) {
        await _learningService.updateAvatarCharacter(
          userId: userId,
          avatarCharacterId: character.id,
        );
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${character.name} is now your main guide.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _savingCharacterId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final activeCharacterId = user.profile?.avatarCharacterId ?? 'lumi';

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
                  Text('Achievements & Characters', style: _headingStyle(30, Colors.white)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Your rewards, mastery growth, and main character team live here.',
                    style: _bodyStyle(Colors.white.withValues(alpha: 0.92)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(child: _statCard('XP', '${user.totalXP}', Icons.bolt_rounded)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _statCard('Streak', '${user.dailyStreak}', Icons.local_fire_department_rounded)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _statCard('Mastery', '${(user.masteryScore * 100).round()}%', Icons.auto_awesome_rounded)),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Main characters', style: _headingStyle(24, AppColors.text)),
            const SizedBox(height: AppSpacing.md),
            for (final character in Character.characters)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _CharacterCard(
                  character: character,
                  active: activeCharacterId == character.id,
                  isSaving: _savingCharacterId == character.id,
                  onSelect: () => _selectCharacter(character),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({
    required this.character,
    required this.active,
    required this.isSaving,
    required this.onSelect,
  });

  final Character character;
  final bool active;
  final bool isSaving;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: character.secondaryColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: active ? character.primaryColor : AppColors.outline, width: active ? 2 : 1),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: character.primaryColor, width: 3),
            ),
            child: Text(character.emoji, style: const TextStyle(fontSize: 34)),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(character.name, style: _headingStyle(22, AppColors.text)),
                const SizedBox(height: AppSpacing.xs),
                Text(character.role, style: _bodyStyle(AppColors.textSecondary)),
              ],
            ),
          ),
          FilledButton(
            onPressed: isSaving ? null : onSelect,
            style: FilledButton.styleFrom(backgroundColor: character.primaryColor),
            child: isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(active ? 'Active' : 'Select'),
          ),
        ],
      ),
    );
  }
}

Widget _statCard(String title, String value, IconData icon) {
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
        Text(value, style: _headingStyle(22, AppColors.text)),
        const SizedBox(height: AppSpacing.xs),
        Text(title, style: _bodyStyle(AppColors.textSecondary)),
      ],
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
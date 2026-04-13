import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/models/character.dart';

class CharacterDisplay extends StatelessWidget {
  const CharacterDisplay({
    super.key,
    required this.character,
    this.size = 88,
    this.showName = true,
    this.animated = true,
  });

  final Character character;
  final double size;
  final bool showName;
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: character.secondaryColor,
            shape: BoxShape.circle,
            border: Border.all(color: character.primaryColor, width: 3),
          ),
          child: Text(
            character.emoji,
            style: TextStyle(fontSize: size * 0.44),
          ),
        ),
        if (showName) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            character.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w700,
                ),
          ),
          Text(
            character.role,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ],
    );

    if (!animated) {
      return content;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: content,
    );
  }
}
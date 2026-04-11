import 'package:flutter/material.dart';
import 'package:shared_ui/tokens/design_tokens.dart';

class StreakWidget extends StatelessWidget {
  const StreakWidget({
    super.key,
    required this.days,
    this.label = 'Streak',
  });

  final int days;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.lg,
        vertical: DesignSpacing.md,
      ),
      decoration: BoxDecoration(
        color: DesignColors.surface,
        borderRadius: BorderRadius.circular(DesignRadius.xl),
        border: Border.all(color: DesignColors.border),
        boxShadow: [
          BoxShadow(
            color: DesignColors.overlay(DesignColors.error, 0.14),
            blurRadius: DesignSpacing.md,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: DesignColors.errorContainer,
              borderRadius: BorderRadius.circular(DesignRadius.lg),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: DesignColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: DesignSpacing.md),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: DesignTypography.labelSmall.copyWith(
                  color: DesignColors.textSecondary,
                ),
              ),
              Text(
                '$days days',
                style: DesignTypography.headlineSmall.copyWith(
                  color: DesignColors.text,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

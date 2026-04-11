import 'package:flutter/material.dart';
import 'package:shared_ui/tokens/design_tokens.dart';

class XPBadge extends StatelessWidget {
  const XPBadge({
    super.key,
    required this.xp,
    this.label = 'XP',
  });

  final int xp;
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
            color: DesignColors.overlay(DesignColors.accent, 0.16),
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
              color: DesignColors.accentLight,
              borderRadius: BorderRadius.circular(DesignRadius.lg),
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: DesignColors.accentDark,
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
                '$xp',
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

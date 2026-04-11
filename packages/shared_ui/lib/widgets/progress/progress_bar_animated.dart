import 'package:flutter/material.dart';
import 'package:shared_ui/tokens/design_tokens.dart';

class ProgressBarAnimated extends StatelessWidget {
  const ProgressBarAnimated({
    super.key,
    required this.value,
    this.height = 14,
    this.fillColor = DesignColors.primary,
    this.backgroundColor = DesignColors.surfaceVariant,
    this.showPercentage = false,
  });

  final double value;
  final double height;
  final Color fillColor;
  final Color backgroundColor;
  final bool showPercentage;

  @override
  Widget build(BuildContext context) {
    final safeValue = value.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(DesignRadius.xl),
          child: Container(
            height: height,
            color: backgroundColor,
            child: Stack(
              children: [
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutCubic,
                  widthFactor: safeValue,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          fillColor,
                          DesignColors.overlay(fillColor, 0.82),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showPercentage) ...[
          const SizedBox(height: DesignSpacing.sm),
          Text(
            '${(safeValue * 100).round()}%',
            style: DesignTypography.labelSmall.copyWith(
              color: DesignColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_ui/tokens/design_tokens.dart';
import 'package:shared_ui/widgets/buttons/app_button.dart';

class RewardPopup extends StatelessWidget {
  const RewardPopup({
    super.key,
    required this.title,
    required this.message,
    this.primaryLabel = 'Continue',
    this.onPrimaryPressed,
    this.secondary,
    this.icon = Icons.workspace_premium_rounded,
    this.highlightColor = DesignColors.accent,
  });

  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback? onPrimaryPressed;
  final Widget? secondary;
  final IconData icon;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        margin: const EdgeInsets.all(DesignSpacing.xl),
        padding: const EdgeInsets.all(DesignSpacing.xl),
        decoration: BoxDecoration(
          color: DesignColors.surface,
          borderRadius: BorderRadius.circular(DesignRadius.xxl),
          boxShadow: [
            BoxShadow(
              color: DesignColors.overlay(highlightColor, 0.2),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: DesignColors.overlay(highlightColor, 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 38,
                color: highlightColor,
              ),
            ),
            const SizedBox(height: DesignSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: DesignTypography.headlineLarge,
            ),
            const SizedBox(height: DesignSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: DesignTypography.bodyMedium,
            ),
            const SizedBox(height: DesignSpacing.xl),
            AppButton(
              label: primaryLabel,
              onPressed: onPrimaryPressed,
              expanded: true,
              variant: AppButtonVariant.success,
            ),
            if (secondary != null) ...[
              const SizedBox(height: DesignSpacing.md),
              secondary!,
            ],
          ],
        ),
      ),
    );
  }
}

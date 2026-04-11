import 'package:flutter/material.dart';
import 'package:shared_ui/tokens/design_tokens.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(DesignSpacing.lg),
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? DesignColors.surface,
      borderRadius: BorderRadius.circular(DesignRadius.lg),
      shadowColor: DesignColors.overlay(DesignColors.text, 0.12),
      elevation: elevation ?? (onTap != null ? 4 : 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignRadius.lg),
        hoverColor: DesignColors.overlay(DesignColors.onPrimary, 0.04),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignRadius.lg),
            border: Border.all(
              color: borderColor ?? DesignColors.border,
            ),
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

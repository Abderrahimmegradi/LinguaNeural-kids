import 'package:flutter/material.dart';
import 'package:shared_ui/tokens/design_tokens.dart';

enum LessonNodeState { locked, available, active, completed }

class LessonNode extends StatelessWidget {
  const LessonNode({
    super.key,
    required this.state,
    required this.icon,
    this.progress = 0,
    this.size = 82,
    this.color = DesignColors.accent,
    this.onTap,
    this.label,
  });

  final LessonNodeState state;
  final IconData icon;
  final double progress;
  final double size;
  final Color color;
  final VoidCallback? onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0);
    final locked = state == LessonNodeState.locked;
    final active = state == LessonNodeState.active;
    final completed = state == LessonNodeState.completed;
    final ringColor = locked ? DesignColors.border : color;
    final fillColor = locked ? DesignColors.surfaceVariant : color;
    final iconColor = locked ? DesignColors.textTertiary : DesignColors.onPrimary;

    final node = SizedBox(
      width: size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: completed ? 1 : safeProgress),
            duration: const Duration(milliseconds: 450),
            builder: (context, animatedProgress, _) => Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: size,
                  height: size,
                  child: CircularProgressIndicator(
                    value: locked ? 0 : (completed ? 1 : animatedProgress),
                    strokeWidth: 8,
                    backgroundColor: DesignColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(ringColor),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: size - 16,
                  height: size - 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: fillColor,
                    boxShadow: [
                      BoxShadow(
                        color: DesignColors.overlay(
                          locked ? DesignColors.textTertiary : color,
                          active ? 0.28 : 0.18,
                        ),
                        blurRadius: active ? DesignSpacing.xl : DesignSpacing.lg,
                        offset: const Offset(0, DesignSpacing.sm),
                      ),
                    ],
                  ),
                  child: Icon(
                    completed ? Icons.check_rounded : (locked ? Icons.lock_rounded : icon),
                    color: iconColor,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: DesignSpacing.sm),
            Text(
              label!,
              textAlign: TextAlign.center,
              style: DesignTypography.labelSmall.copyWith(
                color: locked ? DesignColors.textTertiary : DesignColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return node;
    return GestureDetector(onTap: onTap, child: node);
  }
}

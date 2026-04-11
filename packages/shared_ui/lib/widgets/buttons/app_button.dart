import 'package:flutter/material.dart';
import 'package:shared_ui/tokens/design_tokens.dart';

enum AppButtonVariant { primary, secondary, success }

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.expanded = false,
    this.padding,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool expanded;
  final EdgeInsetsGeometry? padding;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;
    final palette = _paletteFor(widget.variant);

    final child = AnimatedBuilder(
      animation: _scale,
      builder: (context, _) => Transform.scale(
        scale: _scale.value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: widget.padding ??
              const EdgeInsets.symmetric(
                horizontal: DesignSpacing.xl,
                vertical: DesignSpacing.lg,
              ),
          decoration: BoxDecoration(
            color: enabled
                ? palette.background
                : DesignColors.disabled(palette.background),
            borderRadius: BorderRadius.circular(DesignRadius.xl),
            border: Border.all(
              color: enabled ? palette.border : DesignColors.disabled(palette.border),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: DesignColors.overlay(
                  enabled ? palette.background : DesignColors.border,
                  0.24,
                ),
                blurRadius: DesignSpacing.lg,
                offset: const Offset(0, DesignSpacing.sm),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading)
                SizedBox(
                  width: DesignSpacing.lg,
                  height: DesignSpacing.lg,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(palette.foreground),
                  ),
                )
              else if (widget.icon != null) ...[
                IconTheme(
                  data: IconThemeData(
                    color: palette.foreground,
                    size: 20,
                  ),
                  child: widget.icon!,
                ),
                const SizedBox(width: DesignSpacing.sm),
              ],
              Text(
                widget.label,
                style: DesignTypography.buttonText.copyWith(
                  color: palette.foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return GestureDetector(
      onTapDown: enabled ? (_) => _controller.forward(from: 0) : null,
      onTapCancel: enabled ? () => _controller.reverse() : null,
      onTapUp: enabled ? (_) => _controller.reverse() : null,
      child: InkWell(
        onTap: enabled ? widget.onPressed : null,
        borderRadius: BorderRadius.circular(DesignRadius.xl),
        child: widget.expanded ? SizedBox(width: double.infinity, child: child) : child,
      ),
    );
  }

  _ButtonPalette _paletteFor(AppButtonVariant variant) {
    switch (variant) {
      case AppButtonVariant.secondary:
        return const _ButtonPalette(
          background: DesignColors.surface,
          foreground: DesignColors.primary,
          border: DesignColors.border,
        );
      case AppButtonVariant.success:
        return const _ButtonPalette(
          background: DesignColors.success,
          foreground: DesignColors.onPrimary,
          border: DesignColors.success,
        );
      case AppButtonVariant.primary:
        return const _ButtonPalette(
          background: DesignColors.primary,
          foreground: DesignColors.onPrimary,
          border: DesignColors.primaryDark,
        );
    }
  }
}

class _ButtonPalette {
  const _ButtonPalette({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/character.dart';

class AnimatedCharacterAvatar extends StatefulWidget {
  const AnimatedCharacterAvatar({
    super.key,
    required this.character,
    required this.size,
    this.highlighted = false,
    this.showLabel = true,
  });

  final Character character;
  final double size;
  final bool highlighted;
  final bool showLabel;

  @override
  State<AnimatedCharacterAvatar> createState() => _AnimatedCharacterAvatarState();
}

class _AnimatedCharacterAvatarState extends State<AnimatedCharacterAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final motion = _controller.value * math.pi * 2;
        final wave = math.sin(motion);
        final sway = math.cos(motion * 1.4);
        final bob = math.cos(motion) * (widget.highlighted ? 5.5 : 3.2);
        final tilt = wave * (widget.highlighted ? 0.08 : 0.035);
        final pulse = 1 + ((sway + 1) / 2) * (widget.highlighted ? 0.08 : 0.04);
        final sparkleLift = math.sin(motion * 1.8) * 3;

        return Transform.translate(
          offset: Offset(0, bob),
          child: Transform.rotate(
            angle: tilt,
            child: Transform.scale(
              scale: pulse,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: widget.size * (widget.highlighted ? 1.3 : 1.18),
                    height: widget.size * (widget.highlighted ? 1.3 : 1.18),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          widget.character.primaryColor.withValues(alpha: widget.highlighted ? 0.20 : 0.12),
                          widget.character.primaryColor.withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, sparkleLift * 0.2),
                    child: child!,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: widget.size,
            height: widget.size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.character.secondaryColor,
                  widget.character.secondaryColor.withValues(alpha: 0.72),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.highlighted ? widget.character.primaryColor : AppColors.outline,
                width: widget.highlighted ? 3 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.character.primaryColor.withValues(alpha: widget.highlighted ? 0.28 : 0.14),
                  blurRadius: widget.highlighted ? 20 : 12,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Text(
              widget.character.emoji,
              style: TextStyle(fontSize: widget.size * 0.42),
            ),
          ),
          if (widget.showLabel) ...[
            const SizedBox(height: 8),
            Text(
              widget.character.name,
              style: TextStyle(
                color: widget.highlighted ? AppColors.text : AppColors.textSecondary,
                fontWeight: widget.highlighted ? FontWeight.w800 : FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

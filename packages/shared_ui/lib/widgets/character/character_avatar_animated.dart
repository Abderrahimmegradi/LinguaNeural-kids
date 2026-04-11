import 'package:backend_core/models/character.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/tokens/design_tokens.dart';

class CharacterAvatarAnimated extends StatefulWidget {
  const CharacterAvatarAnimated({
    super.key,
    required this.character,
    this.size = 120,
    this.animated = true,
    this.onTap,
  });

  final Character character;
  final double size;
  final bool animated;
  final VoidCallback? onTap;

  @override
  State<CharacterAvatarAnimated> createState() =>
      _CharacterAvatarAnimatedState();
}

class _CharacterAvatarAnimatedState extends State<CharacterAvatarAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.animated) {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 2800),
        vsync: this,
      )..repeat(reverse: true);

      _floatAnimation = Tween<double>(begin: 0, end: DesignSpacing.md).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );

      _scaleAnimation = Tween<double>(begin: 1, end: 1.05).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    if (widget.animated) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget bubble = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.character.primaryColor,
            DesignColors.overlay(widget.character.primaryColor, 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: DesignColors.overlay(widget.character.primaryColor, 0.32),
            blurRadius: DesignSpacing.xl,
            offset: const Offset(0, DesignSpacing.sm),
          ),
        ],
      ),
      child: Center(
        child: Text(
          widget.character.emoji,
          style: TextStyle(
            fontSize: widget.size * 0.5,
            fontFamily: 'Apple Color Emoji',
          ),
        ),
      ),
    );

    if (widget.animated) {
      bubble = AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, -_floatAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        ),
        child: bubble,
      );
    }

    if (widget.onTap != null) {
      bubble = GestureDetector(onTap: widget.onTap, child: bubble);
    }

    return bubble;
  }
}

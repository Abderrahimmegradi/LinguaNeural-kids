import 'package:backend_core/models/character.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Premium character display widget with animations
class CharacterDisplay extends StatefulWidget {
  final Character character;
  final double size;
  final bool showName;
  final bool animated;
  final VoidCallback? onTap;

  const CharacterDisplay({
    super.key,
    required this.character,
    this.size = 120,
    this.showName = true,
    this.animated = true,
    this.onTap,
  });

  @override
  State<CharacterDisplay> createState() => _CharacterDisplayState();
}

class _CharacterDisplayState extends State<CharacterDisplay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.animated) {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 3000),
        vsync: this,
      )..repeat(reverse: true);

      _floatAnimation = Tween<double>(begin: 0, end: 12).animate(
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
    final character = widget.character;
    final emoji = character.emoji;

    Widget display = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.animated)
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, -_floatAnimation.value),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            ),
            child: _buildCharacterBubble(emoji),
          )
        else
          _buildCharacterBubble(emoji),
        if (widget.showName) ...[
          const SizedBox(height: 12),
          Text(
            character.name,
            style: GoogleFonts.fredoka(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: character.primaryColor,
            ),
          ),
          Text(
            character.role,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );

    if (widget.onTap != null) {
      display = GestureDetector(
        onTap: widget.onTap,
        child: display,
      );
    }

    return display;
  }

  Widget _buildCharacterBubble(String emoji) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.character.primaryColor,
            widget.character.primaryColor.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: widget.character.primaryColor.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(
            fontSize: widget.size * 0.5,
            fontFamily: 'Apple Color Emoji',
          ),
        ),
      ),
    );
  }
}

/// Character dialog/card for speech bubbles and interactions
class CharacterSpeechBubble extends StatefulWidget {
  final Character character;
  final String message;
  final Duration displayDuration;
  final VoidCallback? onDismiss;

  const CharacterSpeechBubble({
    super.key,
    required this.character,
    required this.message,
    this.displayDuration = const Duration(seconds: 4),
    this.onDismiss,
  });

  @override
  State<CharacterSpeechBubble> createState() => _CharacterSpeechBubbleState();
}

class _CharacterSpeechBubbleState extends State<CharacterSpeechBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) {
            widget.onDismiss?.call();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.character.secondaryColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.character.primaryColor,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.character.primaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    widget.character.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.character.name,
                      style: GoogleFonts.fredoka(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: widget.character.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.message,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:backend_core/models/character.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_ui/tokens/design_tokens.dart';

class SpeechBubble extends StatefulWidget {
  const SpeechBubble({
    super.key,
    required this.character,
    required this.message,
    this.displayDuration = const Duration(seconds: 4),
    this.onDismiss,
  });

  final Character character;
  final String message;
  final Duration displayDuration;
  final VoidCallback? onDismiss;

  @override
  State<SpeechBubble> createState() => _SpeechBubbleState();
}

class _SpeechBubbleState extends State<SpeechBubble>
    with SingleTickerProviderStateMixin {
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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

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
          padding: const EdgeInsets.all(DesignSpacing.lg),
          decoration: BoxDecoration(
            color: widget.character.secondaryColor,
            borderRadius: BorderRadius.circular(DesignRadius.xxl),
            border: Border.all(
              color: widget.character.primaryColor,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: DesignColors.overlay(widget.character.primaryColor, 0.3),
                blurRadius: DesignSpacing.md,
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
                  const SizedBox(width: DesignSpacing.md),
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
              const SizedBox(height: DesignSpacing.md),
              Text(
                widget.message,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: DesignColors.text,
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

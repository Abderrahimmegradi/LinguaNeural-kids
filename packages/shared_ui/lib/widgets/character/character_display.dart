import 'package:backend_core/models/character.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_ui/tokens/design_tokens.dart';
import 'package:shared_ui/widgets/character/character_avatar_animated.dart';
import 'package:shared_ui/widgets/character/speech_bubble.dart';

class CharacterDisplay extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final character = this.character;

    Widget display = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CharacterAvatarAnimated(
          character: character,
          size: size,
          animated: animated,
        ),
        if (showName) ...[
          const SizedBox(height: DesignSpacing.md),
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
              color: DesignColors.textSecondary,
            ),
          ),
        ],
      ],
    );

    if (onTap != null) {
      display = GestureDetector(
        onTap: onTap,
        child: display,
      );
    }

    return display;
  }
}

class CharacterSpeechBubble extends SpeechBubble {
  const CharacterSpeechBubble({
    super.key,
    required super.character,
    required super.message,
    super.displayDuration,
    super.onDismiss,
  });
}

import 'package:flutter/material.dart';
import 'package:shared_ui/tokens/design_tokens.dart';

export 'package:shared_ui/tokens/design_tokens.dart';

class AppColors {
  static const Color primary = DesignColors.primary;
  static const Color primaryLight = DesignColors.primaryLight;
  static const Color primaryDark = DesignColors.primaryDark;
  static const Color accent = DesignColors.accent;
  static const Color secondary = DesignColors.accent;
  static const Color secondaryLight = DesignColors.accentLight;
  static const Color secondaryDark = DesignColors.accentDark;
  static const Color background = DesignColors.background;
  static const Color surface = DesignColors.surface;
  static const Color surfaceVariant = DesignColors.surfaceVariant;
  static const Color success = DesignColors.success;
  static const Color error = DesignColors.error;
  static const Color warning = DesignColors.warning;
  static const Color info = DesignColors.info;
  static const Color text = DesignColors.text;
  static const Color textSecondary = DesignColors.textSecondary;
  static const Color textTertiary = DesignColors.textTertiary;
  static const Color border = DesignColors.border;
  static const Color divider = DesignColors.divider;
  static const Color moodHappy = DesignColors.moodHappy;
  static const Color moodFocused = DesignColors.moodFocused;
  static const Color moodCurious = DesignColors.moodCurious;
  static const Color moodTired = DesignColors.moodTired;
  static const Color moodFrustrated = DesignColors.moodFrustrated;
  static const Color onPrimary = DesignColors.onPrimary;
  static const Color onSecondary = DesignColors.onSecondary;
  static const Color onSurface = DesignColors.text;
  static const Color outline = DesignColors.border;
  static const Color tertiaryContainer = DesignColors.tertiaryContainer;
  static const Color onTertiary = DesignColors.onTertiary;
  static const Color errorContainer = DesignColors.errorContainer;
  static const Color onError = DesignColors.onError;

  static Color overlay(Color color, double opacity) =>
      DesignColors.overlay(color, opacity);

  static Color disabled(Color color) => DesignColors.disabled(color);

  static Color hover(Color color) => DesignColors.hover(color);

  static Color focus(Color color) => DesignColors.focus(color);
}

class AppSpacing {
  static const double xs = DesignSpacing.xs;
  static const double sm = DesignSpacing.sm;
  static const double md = DesignSpacing.md;
  static const double lg = DesignSpacing.lg;
  static const double xl = DesignSpacing.xl;
  static const double xxl = DesignSpacing.xxl;
  static const double xxxl = DesignSpacing.xxxl;
  static const double paddingSmall = DesignSpacing.paddingSmall;
  static const double paddingMedium = DesignSpacing.paddingMedium;
  static const double paddingLarge = DesignSpacing.paddingLarge;
  static const double marginSmall = DesignSpacing.marginSmall;
  static const double marginMedium = DesignSpacing.marginMedium;
  static const double marginLarge = DesignSpacing.marginLarge;
  static const double gapSmall = DesignSpacing.gapSmall;
  static const double gapMedium = DesignSpacing.gapMedium;
  static const double gapLarge = DesignSpacing.gapLarge;
}

class AppRadius {
  static const double sm = DesignRadius.sm;
  static const double md = DesignRadius.md;
  static const double lg = DesignRadius.lg;
  static const double xl = DesignRadius.xl;
  static const double xxl = DesignRadius.xxl;
  static const double button = DesignRadius.button;
  static const double card = DesignRadius.card;
  static const double dialog = DesignRadius.dialog;
}

class AppTypography {
  static TextStyle get displayLarge => DesignTypography.displayLarge;
  static TextStyle get displayMedium => DesignTypography.displayMedium;
  static TextStyle get displaySmall => DesignTypography.displaySmall;
  static TextStyle get headlineLarge => DesignTypography.headlineLarge;
  static TextStyle get headlineMedium => DesignTypography.headlineMedium;
  static TextStyle get headlineSmall => DesignTypography.headlineSmall;
  static TextStyle get bodyLarge => DesignTypography.bodyLarge;
  static TextStyle get bodyMedium => DesignTypography.bodyMedium;
  static TextStyle get bodySmall => DesignTypography.bodySmall;
  static TextStyle get labelLarge => DesignTypography.labelLarge;
  static TextStyle get labelMedium => DesignTypography.labelMedium;
  static TextStyle get labelSmall => DesignTypography.labelSmall;
  static TextStyle get buttonText => DesignTypography.buttonText;
  static TextStyle get hint => DesignTypography.hint;
  static TextStyle get accent => DesignTypography.accent;
}

class AppShadows {
  static const boxShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const cardShadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const elevatedShadow = [
    BoxShadow(
      color: Color(0x21000000),
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];
}

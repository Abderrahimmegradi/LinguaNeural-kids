import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DesignColors {
  static const Color primary = Color(0xFF0E7C86);
  static const Color primaryLight = Color(0xFF4DB8C4);
  static const Color primaryDark = Color(0xFF065A62);

  static const Color accent = Color(0xFFF4B942);
  static const Color accentLight = Color(0xFFF8D27F);
  static const Color accentDark = Color(0xFFD4931B);

  static const Color background = Color(0xFFF6F9FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F4F8);

  static const Color success = Color(0xFF1A936F);
  static const Color error = Color(0xFFE76F51);
  static const Color warning = Color(0xFFF4B942);
  static const Color info = Color(0xFF0E7C86);

  static const Color text = Color(0xFF1A237E);
  static const Color textSecondary = Color(0xFF546E7A);
  static const Color textTertiary = Color(0xFF90A4AE);
  static const Color border = Color(0xFFE0EBF0);
  static const Color divider = Color(0xFFECEFF1);

  static const Color moodHappy = Color(0xFFF4B942);
  static const Color moodFocused = Color(0xFF0E7C86);
  static const Color moodCurious = Color(0xFFAB47BC);
  static const Color moodTired = Color(0xFF546E7A);
  static const Color moodFrustrated = Color(0xFFE76F51);

  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Color(0xFF1A1A1A);
  static const Color tertiaryContainer = Color(0xFFB3E5DE);
  static const Color onTertiary = Colors.white;
  static const Color errorContainer = Color(0xFFFFEBEE);
  static const Color onError = Colors.white;

  static Color overlay(Color color, double opacity) =>
      color.withValues(alpha: opacity);
  static Color disabled(Color color) => color.withValues(alpha: 0.38);
  static Color hover(Color color) => color.withValues(alpha: 0.08);
  static Color focus(Color color) => color.withValues(alpha: 0.12);
}

class DesignSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  static const double paddingSmall = sm;
  static const double paddingMedium = lg;
  static const double paddingLarge = xl;

  static const double marginSmall = sm;
  static const double marginMedium = lg;
  static const double marginLarge = xl;

  static const double gapSmall = sm;
  static const double gapMedium = lg;
  static const double gapLarge = xl;
}

class DesignRadius {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 24;

  static const double button = lg;
  static const double card = lg;
  static const double dialog = xl;
}

class DesignTypography {
  static TextStyle displayLarge = GoogleFonts.nunitoSans(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 1.2,
    color: DesignColors.text,
  );

  static TextStyle displayMedium = GoogleFonts.nunitoSans(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: DesignColors.text,
  );

  static TextStyle displaySmall = GoogleFonts.nunitoSans(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: DesignColors.text,
  );

  static TextStyle headlineLarge = GoogleFonts.nunitoSans(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: DesignColors.text,
  );

  static TextStyle headlineMedium = GoogleFonts.nunitoSans(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: DesignColors.text,
  );

  static TextStyle headlineSmall = GoogleFonts.nunitoSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: DesignColors.text,
  );

  static TextStyle bodyLarge = GoogleFonts.nunitoSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: DesignColors.text,
  );

  static TextStyle bodyMedium = GoogleFonts.nunitoSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: DesignColors.textSecondary,
  );

  static TextStyle bodySmall = GoogleFonts.nunitoSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: DesignColors.textSecondary,
  );

  static TextStyle labelLarge = GoogleFonts.nunitoSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.5,
    color: DesignColors.text,
  );

  static TextStyle labelMedium = GoogleFonts.nunitoSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.4,
    color: DesignColors.text,
  );

  static TextStyle labelSmall = GoogleFonts.nunitoSans(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.3,
    color: DesignColors.textSecondary,
  );

  static TextStyle buttonText = GoogleFonts.nunitoSans(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: 0.5,
  );

  static TextStyle hint = GoogleFonts.nunitoSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: DesignColors.textTertiary,
  );

  static TextStyle accent = GoogleFonts.nunitoSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: DesignColors.primary,
  );
}

class DesignTextThemes {
  static TextTheme get textTheme => TextTheme(
        displayLarge: DesignTypography.displayLarge,
        displayMedium: DesignTypography.displayMedium,
        displaySmall: DesignTypography.displaySmall,
        headlineLarge: DesignTypography.headlineLarge.copyWith(
          letterSpacing: -0.5,
        ),
        headlineMedium: DesignTypography.headlineMedium,
        headlineSmall: DesignTypography.headlineSmall,
        bodyLarge: DesignTypography.bodyLarge,
        bodyMedium: DesignTypography.bodyMedium,
        bodySmall: DesignTypography.bodySmall,
        labelLarge: DesignTypography.labelLarge,
        labelMedium: DesignTypography.labelMedium,
        labelSmall: DesignTypography.labelSmall,
      );
}

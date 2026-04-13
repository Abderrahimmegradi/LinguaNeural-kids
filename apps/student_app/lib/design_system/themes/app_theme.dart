import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme {
    final bodyTextTheme = GoogleFonts.nunitoTextTheme();
    final headlineTextTheme = GoogleFonts.fredokaTextTheme(bodyTextTheme);

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.text,
        onError: Colors.white,
      ),
      textTheme: bodyTextTheme.copyWith(
        displayLarge: headlineTextTheme.displayLarge,
        displayMedium: headlineTextTheme.displayMedium,
        displaySmall: headlineTextTheme.displaySmall,
        headlineLarge: headlineTextTheme.headlineLarge,
        headlineMedium: headlineTextTheme.headlineMedium,
        headlineSmall: headlineTextTheme.headlineSmall,
        titleLarge: headlineTextTheme.titleLarge,
        titleMedium: headlineTextTheme.titleMedium,
        titleSmall: headlineTextTheme.titleSmall,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
        titleTextStyle: headlineTextTheme.titleLarge?.copyWith(
          color: AppColors.text,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
        ),
      ),
      fontFamily: GoogleFonts.nunito().fontFamily,
    );
  }
}
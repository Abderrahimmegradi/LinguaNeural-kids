import 'package:flutter/material.dart';
import 'package:shared_ui/tokens/design_tokens.dart';

export 'package:shared_ui/tokens/design_tokens.dart';

/// Professional brand theme for Lingua Neural Kids
/// Creates a cohesive, modern, child-friendly learning experience
/// 
/// Brand Identity:
/// - Primary: Teal (#0E7C86) - Calming, trustworthy, educational
/// - Accent: Gold/Yellow (#F4B942) - Energetic, positive, achievement
/// - Surface: White (#FFFFFF) - Clean, clarity
/// - Background: Light Blue-Gray (#F6F9FB) - Subtle, non-distracting
class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme - Brand Identity
      colorScheme: const ColorScheme.light(
        primary: DesignColors.primary,
        onPrimary: DesignColors.onPrimary,
        primaryContainer: DesignColors.primaryLight,
        onPrimaryContainer: DesignColors.primary,
        secondary: DesignColors.accent,
        onSecondary: DesignColors.onSecondary,
        secondaryContainer: DesignColors.accentLight,
        onSecondaryContainer: DesignColors.accentDark,
        tertiary: DesignColors.info,
        tertiaryContainer: DesignColors.tertiaryContainer,
        onTertiary: DesignColors.onTertiary,
        error: DesignColors.error,
        onError: DesignColors.onError,
        errorContainer: DesignColors.errorContainer,
        onErrorContainer: DesignColors.error,
        surface: DesignColors.surface,
        onSurface: DesignColors.text,
        surfaceContainerHighest: DesignColors.surfaceVariant,
        onSurfaceVariant: DesignColors.textSecondary,
        outline: DesignColors.border,
      ),

      // Scaffold & Background
      scaffoldBackgroundColor: DesignColors.background,
      
      // AppBar - Premium Brand Appearance
      appBarTheme: AppBarTheme(
        backgroundColor: DesignColors.surface,
        foregroundColor: DesignColors.text,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 2,
        surfaceTintColor: DesignColors.primary.withOpacity(0.05),
        iconTheme: const IconThemeData(
          color: DesignColors.text,
          size: 24,
        ),
        actionsIconTheme: const IconThemeData(
          color: DesignColors.text,
          size: 24,
        ),
        titleTextStyle: DesignTypography.headlineLarge.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        toolbarHeight: 64,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(DesignRadius.lg),
            bottomRight: Radius.circular(DesignRadius.lg),
          ),
        ),
      ),

      // Text Theme
      textTheme: DesignTextThemes.textTheme,

      // Elevated Button - Premium Primary Action
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSpacing.xl,
            vertical: 14,
          ),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignRadius.button),
          ),
          textStyle: DesignTypography.labelLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          elevation: 2,
          shadowColor: DesignColors.primary.withOpacity(0.3),
          tapTargetSize: MaterialTapTargetSize.padded,
        ).copyWith(
          overlayColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.hovered)) {
              return DesignColors.primary.withOpacity(0.08);
            }
            if (states.contains(MaterialState.pressed)) {
              return DesignColors.primary.withOpacity(0.12);
            }
            return null;
          }),
          elevation: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) return 4;
            if (states.contains(MaterialState.hovered)) return 4;
            return 2;
          }),
        ),
      ),

      // Outlined Button - Secondary Action
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DesignColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSpacing.xl,
            vertical: 14,
          ),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignRadius.button),
          ),
          side: const BorderSide(
            color: DesignColors.primary,
            width: 2,
          ),
          textStyle: DesignTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w700,
          ),
          tapTargetSize: MaterialTapTargetSize.padded,
        ).copyWith(
          overlayColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return DesignColors.primary.withOpacity(0.12);
            }
            return null;
          }),
        ),
      ),

      // Text Button - Tertiary Action
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DesignColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSpacing.lg,
            vertical: DesignSpacing.md,
          ),
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignRadius.button),
          ),
          textStyle: DesignTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ).copyWith(
          overlayColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return DesignColors.primary.withOpacity(0.08);
            }
            return null;
          }),
        ),
      ),

      // Input Decoration - Clean & Professional
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DesignColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignSpacing.lg,
          vertical: DesignSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.lg),
          borderSide: const BorderSide(
            color: DesignColors.border,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.lg),
          borderSide: const BorderSide(
            color: DesignColors.border,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.lg),
          borderSide: const BorderSide(
            color: DesignColors.primary,
            width: 2.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.lg),
          borderSide: const BorderSide(
            color: DesignColors.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.lg),
          borderSide: const BorderSide(
            color: DesignColors.error,
            width: 2.5,
          ),
        ),
        labelStyle: DesignTypography.labelMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        hintStyle: DesignTypography.bodyMedium.copyWith(
          color: DesignColors.textTertiary,
        ),
        errorStyle: DesignTypography.bodySmall.copyWith(
          color: DesignColors.error,
          fontWeight: FontWeight.w600,
        ),
        helperStyle: DesignTypography.bodySmall,
        prefixIconColor: MaterialStateColor.resolveWith((states) {
          if (states.contains(MaterialState.focused)) {
            return DesignColors.primary;
          }
          return DesignColors.textSecondary;
        }),
        suffixIconColor: MaterialStateColor.resolveWith((states) {
          if (states.contains(MaterialState.focused)) {
            return DesignColors.primary;
          }
          return DesignColors.textSecondary;
        }),
      ),

      // Card Theme - Premium Design
      cardTheme: CardThemeData(
        color: DesignColors.surface,
        elevation: 0,
        shadowColor: DesignColors.primary.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignRadius.lg),
          side: const BorderSide(
            color: DesignColors.border,
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),

      // Dialog Theme - Professional Modals
      dialogTheme: DialogThemeData(
        backgroundColor: DesignColors.surface,
        elevation: 8,
        shadowColor: DesignColors.primary.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignRadius.dialog),
        ),
        alignment: Alignment.center,
        actionsPadding: const EdgeInsets.all(DesignSpacing.lg),
        titleTextStyle: DesignTypography.headlineMedium.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: DesignColors.divider,
        thickness: 1,
        space: DesignSpacing.lg,
      ),

      // Chip Theme - Badges & Tags
      chipTheme: ChipThemeData(
        backgroundColor: DesignColors.surfaceVariant,
        selectedColor: DesignColors.primaryLight.withOpacity(0.3),
        disabledColor: DesignColors.surfaceVariant.withOpacity(0.4),
        labelStyle: DesignTypography.labelMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: DesignTypography.labelMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignSpacing.md,
          vertical: DesignSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignRadius.lg),
        ),
        side: const BorderSide(
          color: DesignColors.border,
          width: 1,
        ),
        elevation: 0,
        pressElevation: 2,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: DesignColors.surface,
        elevation: 8,
        shadowColor: DesignColors.primary.withOpacity(0.15),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(DesignRadius.dialog),
            topRight: Radius.circular(DesignRadius.dialog),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Floating Action Button - Brand Accent
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: DesignColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        highlightElevation: 8,
        focusElevation: 6,
        hoverElevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignRadius.lg),
        ),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: DesignColors.primary,
        linearTrackColor: DesignColors.border,
        linearMinHeight: 4,
        circularTrackColor: DesignColors.surfaceVariant,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DesignColors.text,
        contentTextStyle: DesignTypography.bodyMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignRadius.lg),
        ),
        actionTextColor: DesignColors.accent,
        dismissDirection: DismissDirection.down,
      ),

      // Pop Menu Button Theme
      popupMenuTheme: PopupMenuThemeData(
        color: DesignColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignRadius.lg),
        ),
        textStyle: DesignTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

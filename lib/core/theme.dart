import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Defender cosmic color palette
class DefenderColors {
  DefenderColors._();

  // Core cosmic colors
  static const Color background = Color(0xFF0d001a);
  static const Color backgroundLight = Color(0xFF1a0033);
  static const Color surface = Color(0xFF150025);
  static const Color surfaceLight = Color(0xFF2a0050);

  // Primary accent - cosmic purple
  static const Color primary = Color(0xFF6a1b9a);
  static const Color primaryLight = Color(0xFF9c4dcc);
  static const Color primaryDark = Color(0xFF38006b);

  // Text colors
  static const Color textPrimary = Color(0xFFe0e0ff);
  static const Color textSecondary = Color(0xFFa0a0cc);
  static const Color textMuted = Color(0xFF6060aa);

  // Risk gradient colors
  static const Color safe = Color(0xFF00c853);
  static const Color safeGlow = Color(0xFF69f0ae);
  static const Color suspicious = Color(0xFFff9100);
  static const Color suspiciousGlow = Color(0xFFffab40);
  static const Color dangerous = Color(0xFFff1744);
  static const Color dangerousGlow = Color(0xFFff5252);

  // Glow and effects
  static const Color glow = Color(0xFF9c27b0);
  static const Color glowSoft = Color(0x406a1b9a);
  static const Color particle = Color(0x206a1b9a);
}

/// Defender text styles
class DefenderTextStyles {
  DefenderTextStyles._();

  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: DefenderColors.textPrimary,
        letterSpacing: -1.5,
      );

  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 34,
        fontWeight: FontWeight.w600,
        color: DefenderColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get headlineLarge => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: DefenderColors.textPrimary,
      );

  static TextStyle get headlineMedium => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: DefenderColors.textPrimary,
      );

  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: DefenderColors.textPrimary,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: DefenderColors.textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: DefenderColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: DefenderColors.textSecondary,
      );

  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: DefenderColors.textPrimary,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: DefenderColors.textMuted,
      );
}

/// Defender Material 3 theme
ThemeData defenderTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: DefenderColors.background,
    colorScheme: const ColorScheme.dark(
      surface: DefenderColors.background,
      primary: DefenderColors.primary,
      secondary: DefenderColors.primaryLight,
      onPrimary: DefenderColors.textPrimary,
      onSecondary: DefenderColors.textPrimary,
      onSurface: DefenderColors.textPrimary,
      error: DefenderColors.dangerous,
    ),
    textTheme: TextTheme(
      displayLarge: DefenderTextStyles.displayLarge,
      displayMedium: DefenderTextStyles.displayMedium,
      headlineLarge: DefenderTextStyles.headlineLarge,
      headlineMedium: DefenderTextStyles.headlineMedium,
      titleLarge: DefenderTextStyles.titleLarge,
      titleMedium: DefenderTextStyles.titleMedium,
      bodyLarge: DefenderTextStyles.bodyLarge,
      bodyMedium: DefenderTextStyles.bodyMedium,
      labelLarge: DefenderTextStyles.labelLarge,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DefenderColors.primary,
        foregroundColor: DefenderColors.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        shadowColor: DefenderColors.glowSoft,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DefenderColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: DefenderColors.primaryDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: DefenderColors.primary.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: DefenderColors.primary, width: 2),
      ),
      hintStyle: DefenderTextStyles.bodyMedium.copyWith(
        color: DefenderColors.textMuted,
      ),
      contentPadding: const EdgeInsets.all(20),
    ),
    cardTheme: CardThemeData(
      color: DefenderColors.surface,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      shadowColor: DefenderColors.glowSoft,
    ),
    iconTheme: const IconThemeData(
      color: DefenderColors.textPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: DefenderTextStyles.titleLarge,
      iconTheme: const IconThemeData(color: DefenderColors.textPrimary),
    ),
    listTileTheme: ListTileThemeData(
      tileColor: DefenderColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      titleTextStyle: DefenderTextStyles.titleMedium,
      subtitleTextStyle: DefenderTextStyles.bodyMedium,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: DefenderColors.primary,
      linearTrackColor: DefenderColors.surfaceLight,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: DefenderColors.surface,
      contentTextStyle: DefenderTextStyles.bodyMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}


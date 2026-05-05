import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary accent - Electric Blue
  static const Color primary = Color(0xFF0066FF);
  static const Color primaryLight = Color(0xFF3388FF);
  static const Color accent = Color(0xFF00A3FF);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkBackgroundAlt = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF111111);
  static const Color darkSurfaceLight = Color(0xFF1A1A1A);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFAAAAAA);
  static const Color darkTextMuted = Color(0xFF666666);

  // Light Mode Colors
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightBackgroundAlt = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceLight = Color(0xFFF0F0F0);
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0xFF555555);
  static const Color lightTextMuted = Color(0xFF999999);

  // Glow/Halo colors
  static Color glowColor(bool isDark) =>
      primary.withOpacity(isDark ? 0.3 : 0.2);
  static Color softGlow(bool isDark) =>
      primary.withOpacity(isDark ? 0.15 : 0.1);

  // Border radius
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 20.0;
  static const double radiusLarge = 28.0;
  static const double radiusXL = 40.0;

  // Helper methods for theme-aware colors
  static Color background(bool isDark) =>
      isDark ? darkBackground : lightBackground;
  static Color backgroundAlt(bool isDark) =>
      isDark ? darkBackgroundAlt : lightBackgroundAlt;
  static Color surface(bool isDark) => isDark ? darkSurface : lightSurface;
  static Color surfaceLight(bool isDark) =>
      isDark ? darkSurfaceLight : lightSurfaceLight;
  static Color textPrimary(bool isDark) =>
      isDark ? darkTextPrimary : lightTextPrimary;
  static Color textSecondary(bool isDark) =>
      isDark ? darkTextSecondary : lightTextSecondary;
  static Color textMuted(bool isDark) =>
      isDark ? darkTextMuted : lightTextMuted;

  // Box shadows with glow effect
  static List<BoxShadow> glowShadow(bool isDark) => [
    BoxShadow(
      color: primary.withOpacity(isDark ? 0.3 : 0.15),
      blurRadius: 30,
      spreadRadius: -5,
    ),
  ];

  static List<BoxShadow> softShadow(bool isDark) => [
    BoxShadow(
      color: (isDark ? Colors.black : Colors.black.withOpacity(0.1)),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  // Accent gradient for UI elements
  static const LinearGradient accentGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme => _buildTheme(true);
  static ThemeData get lightTheme => _buildTheme(false);

  static ThemeData _buildTheme(bool isDark) {
    final bg = background(isDark);
    final surfaceColor = surface(isDark);
    final textPri = textPrimary(isDark);
    final textSec = textSecondary(isDark);
    final textMut = textMuted(isDark);

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bg,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: primary,
              secondary: accent,
              surface: surfaceColor,
            )
          : ColorScheme.light(
              primary: primary,
              secondary: accent,
              surface: surfaceColor,
            ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.montserrat(
          fontSize: 120,
          fontWeight: FontWeight.w900,
          color: textPri,
          letterSpacing: -4,
          height: 0.9,
        ),
        displayMedium: GoogleFonts.montserrat(
          fontSize: 72,
          fontWeight: FontWeight.w800,
          color: textPri,
          letterSpacing: -2,
        ),
        displaySmall: GoogleFonts.montserrat(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: textPri,
          letterSpacing: -1,
        ),
        headlineLarge: GoogleFonts.montserrat(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: textPri,
        ),
        headlineMedium: GoogleFonts.montserrat(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textPri,
        ),
        headlineSmall: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPri,
        ),
        titleLarge: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPri,
          letterSpacing: 2,
        ),
        titleMedium: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textSec,
          letterSpacing: 3,
        ),
        bodyLarge: GoogleFonts.montserrat(
          fontSize: 20,
          color: textSec,
          height: 1.8,
        ),
        bodyMedium: GoogleFonts.montserrat(
          fontSize: 16,
          color: textSec,
          height: 1.6,
        ),
        bodySmall: GoogleFonts.montserrat(
          fontSize: 14,
          color: textMut,
          height: 1.5,
        ),
        labelLarge: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primary,
          letterSpacing: 1,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          textStyle: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPri,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          side: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.2)
                : Colors.black.withOpacity(0.2),
          ),
          textStyle: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: textSec),
      ),
    );
  }
}

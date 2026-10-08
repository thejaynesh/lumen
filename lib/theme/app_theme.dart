import 'package:flutter/material.dart';
import 'broadside_theme.dart';

class AppTheme {
  static const primary = Color(0xFF2549CD);
  static const primaryLight = Color(0xFF7792F8);
  static const accent = primaryLight;
  static const darkBackground = Color(0xFF172239);
  static const darkBackgroundAlt = Color(0xFF293B57);
  static const darkSurface = Color(0xFF202E49);
  static const darkSurfaceLight = Color(0xFF344765);
  static const darkTextPrimary = Color(0xFFEDF1F8);
  static const darkTextSecondary = Color(0xFFB8C7DE);
  static const darkTextMuted = Color(0xFFB8C7DE);
  static const lightBackground = Color(0xFFEDF1F8);
  static const lightBackgroundAlt = Color(0xFFF7F9FC);
  static const lightSurface = Color(0xFFF7F9FC);
  static const lightSurfaceLight = Color(0xFFDCE4F2);
  static const lightTextPrimary = Color(0xFF17264B);
  static const lightTextSecondary = Color(0xFF475673);
  static const lightTextMuted = Color(0xFF475673);
  static const radiusSmall = 4.0;
  static const radiusMedium = 6.0;
  static const radiusLarge = 8.0;
  static const radiusXL = 12.0;
  static Color background(bool d) => Broadside.paper(d);
  static Color backgroundAlt(bool d) => Broadside.paperDeep(d);
  static Color surface(bool d) => Broadside.paperAlt(d);
  static Color surfaceLight(bool d) => d ? darkSurfaceLight : lightSurfaceLight;
  static Color textPrimary(bool d) => Broadside.ink(d);
  static Color textSecondary(bool d) => Broadside.inkSoft(d);
  static Color textMuted(bool d) => Broadside.inkSoft(d);
  static Color glowColor(bool d) => Broadside.accent(d).withValues(alpha: 0.15);
  static Color softGlow(bool d) => Broadside.accent(d).withValues(alpha: 0.08);
  static List<BoxShadow> glowShadow(bool d) => const [];
  static List<BoxShadow> softShadow(bool d) => [
    BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16),
  ];
  static const accentGradient = LinearGradient(colors: [primary, primaryLight]);
  static ThemeData get darkTheme => _buildTheme(true);
  static ThemeData get lightTheme => _buildTheme(false);

  static ThemeData _buildTheme(bool dark) {
    final ink = Broadside.ink(dark);
    final muted = Broadside.inkSoft(dark);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: Broadside.accent(dark),
          brightness: dark ? Brightness.dark : Brightness.light,
          surface: Broadside.paperAlt(dark),
        ).copyWith(
          primary: Broadside.accent(dark),
          onPrimary: Broadside.accentInk(dark),
          onSurface: ink,
          onSurfaceVariant: muted,
          outline: Broadside.rule(dark),
        );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Broadside.paper(dark),
    );
    return base.copyWith(
      textTheme: base.textTheme
          .apply(fontFamily: 'Manrope')
          .copyWith(
            headlineLarge: BroadsideText.display(
              letterSpacing: 0,
              size: 40,
              color: ink,
              height: 1.1,
            ),
            headlineMedium: BroadsideText.display(
              letterSpacing: 0,
              size: 32,
              color: ink,
              height: 1.15,
            ),
            headlineSmall: BroadsideText.display(
              letterSpacing: 0,
              size: 26,
              color: ink,
              height: 1.2,
            ),
            bodyLarge: BroadsideText.sans(size: 16, color: ink),
            bodyMedium: BroadsideText.sans(size: 15, color: ink),
            bodySmall: BroadsideText.sans(size: 13, color: muted),
          ),
      cardTheme: CardThemeData(
        color: Broadside.paperAlt(dark),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          side: BorderSide(color: Broadside.rule(dark)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(44, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
          textStyle: BroadsideText.sans(size: 14, weight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(44, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          foregroundColor: ink,
          side: BorderSide(color: Broadside.rule(dark)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
          textStyle: BroadsideText.sans(size: 14, weight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: muted,
          minimumSize: const Size(44, 44),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: BroadsideText.sans(size: 14, color: muted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
      dividerColor: Broadside.rule(dark),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(muted.withValues(alpha: 0.6)),
      ),
    );
  }
}

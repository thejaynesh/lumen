import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Broadside palette. Pass `dark` to every accessor (theme lives in ThemeProvider).
class Broadside {
  static const _lPaper = Color(0xFFECE9E2);
  static const _lPaperDeep = Color(0xFFDFDBD0);
  static const _lPaperAlt = Color(0xFFF5F2EC);
  static const _lInk = Color(0xFF100E0C);
  static const _lInkSoft = Color(0xFF54504A);
  static const _lAccent = Color(0xFFC2382A);
  static const _lAccentInk = Color(0xFFFFFFFF);

  static const _dPaper = Color(0xFF0E0C0A);
  static const _dPaperDeep = Color(0xFF171411);
  static const _dPaperAlt = Color(0xFF1C1915);
  static const _dInk = Color(0xFFF5F0E6);
  static const _dInkSoft = Color(0xFFA39C8E);
  static const _dAccent = Color(0xFFE44A36);
  static const _dAccentInk = Color(0xFF0E0C0A);

  static Color paper(bool d) => d ? _dPaper : _lPaper;
  static Color paperDeep(bool d) => d ? _dPaperDeep : _lPaperDeep;
  static Color paperAlt(bool d) => d ? _dPaperAlt : _lPaperAlt;
  static Color ink(bool d) => d ? _dInk : _lInk;
  static Color inkSoft(bool d) => d ? _dInkSoft : _lInkSoft;
  static Color accent(bool d) => d ? _dAccent : _lAccent;
  static Color accentInk(bool d) => d ? _dAccentInk : _lAccentInk;
  static Color rule(bool d) =>
      d ? const Color(0xFFF5F0E6).withValues(alpha: 0.18) : const Color(0xFF100E0C).withValues(alpha: 0.20);

  static const maxWidth = 1200.0;
  static const pagePad = 40.0;
  static const themeAnim = Duration(milliseconds: 400);
}

/// Text style helpers. Sizes are desktop (>=1200). Callers scale down responsively.
class BroadsideText {
  static TextStyle serif({
    double size = 16, Color? color, FontStyle style = FontStyle.normal,
    double height = 1.0, double letterSpacing = 0,
  }) =>
      GoogleFonts.instrumentSerif(
        fontSize: size, color: color, fontStyle: style,
        height: height, letterSpacing: size * letterSpacing,
      );

  static TextStyle sans({
    double size = 15, Color? color, FontWeight weight = FontWeight.w400,
    double height = 1.6, FontStyle style = FontStyle.normal,
  }) =>
      GoogleFonts.interTight(
        fontSize: size, color: color, fontWeight: weight, height: height, fontStyle: style,
      );

  /// Mono kicker. Caller uppercases the text; tracking is em-based (x size).
  static TextStyle mono({
    double size = 11, Color? color, double trackingEm = 0.18, FontWeight weight = FontWeight.w500,
  }) =>
      GoogleFonts.geistMono(
        fontSize: size, color: color, fontWeight: weight, letterSpacing: size * trackingEm,
      );
}

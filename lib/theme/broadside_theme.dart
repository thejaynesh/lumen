import 'package:flutter/material.dart';

/// Index club's cobalt and apricot palette, shared by the portfolio and studio.
class Broadside {
  static const _lPaper = Color(0xFFEDF1F8);
  static const _lPaperDeep = Color(0xFFDCE4F2);
  static const _lPaperAlt = Color(0xFFF7F9FC);
  static const _lInk = Color(0xFF17264B);
  static const _lInkSoft = Color(0xFF475673);
  static const _lAccent = Color(0xFF2549CD);
  static const _lAccentInk = Color(0xFFFFF5E5);

  static const _dPaper = Color(0xFF172239);
  static const _dPaperDeep = Color(0xFF293B57);
  static const _dPaperAlt = Color(0xFF202E49);
  static const _dInk = Color(0xFFEDF1F8);
  static const _dInkSoft = Color(0xFFB8C7DE);
  static const _dAccent = Color(0xFF7792F8);
  static const _dAccentInk = Color(0xFF111C3A);

  static Color paper(bool d) => d ? _dPaper : _lPaper;
  static Color paperDeep(bool d) => d ? _dPaperDeep : _lPaperDeep;
  static Color paperAlt(bool d) => d ? _dPaperAlt : _lPaperAlt;
  static Color ink(bool d) => d ? _dInk : _lInk;
  static Color inkSoft(bool d) => d ? _dInkSoft : _lInkSoft;
  static Color accent(bool d) => d ? _dAccent : _lAccent;
  static Color accentInk(bool d) => d ? _dAccentInk : _lAccentInk;
  static Color signal(bool d) =>
      d ? const Color(0xFFE1AA84) : const Color(0xFFF1C1A0);
  static Color signalInk(bool d) =>
      d ? const Color(0xFF342519) : const Color(0xFF4B2F23);
  static Color folderPaper(bool d) =>
      d ? const Color(0xFFF4DDC1) : const Color(0xFFFFEBD6);
  static Color folderInk(bool d) => const Color(0xFF332817);
  static Color blueGray(bool d) =>
      d ? const Color(0xFF7594C2) : const Color(0xFF91AACF);
  static Color rule(bool d) =>
      d ? _dInk.withValues(alpha: 0.20) : _lInk.withValues(alpha: 0.22);

  static const maxWidth = 1200.0;
  static const pagePad = 40.0;
  static const themeAnim = Duration(milliseconds: 400);
}

/// Text style helpers. Sizes are desktop (>=1200). Callers scale down responsively.
class BroadsideText {
  static TextStyle display({
    double size = 32,
    Color? color,
    FontWeight weight = FontWeight.w600,
    FontStyle style = FontStyle.normal,
    double height = 1.04,
    double letterSpacing = -0.035,
  }) => TextStyle(
    fontFamily: 'Manrope',
    fontSize: size,
    fontWeight: weight,
    fontStyle: style,
    color: color,
    height: height,
    letterSpacing: size * letterSpacing,
  );

  static TextStyle sans({
    double size = 15,
    Color? color,
    FontWeight weight = FontWeight.w400,
    double height = 1.6,
    FontStyle style = FontStyle.normal,
  }) => TextStyle(
    fontFamily: 'Manrope',
    fontSize: size,
    color: color,
    fontWeight: weight,
    height: height,
    fontStyle: style,
  );

  static TextStyle editorial({
    double size = 32,
    Color? color,
    FontStyle style = FontStyle.normal,
    double height = 1.08,
    double letterSpacing = -0.02,
  }) => TextStyle(
    fontFamily: 'DMSerifDisplay',
    fontSize: size,
    fontWeight: FontWeight.w400,
    fontStyle: style,
    color: color,
    height: height,
    letterSpacing: size * letterSpacing,
  );

  /// Mono kicker. Caller uppercases the text; tracking is em-based (x size).
  static TextStyle mono({
    double size = 11,
    Color? color,
    double trackingEm = 0.18,
    FontWeight weight = FontWeight.w500,
  }) => TextStyle(
    fontFamily: 'GeistMono',
    fontSize: size,
    color: color,
    fontWeight: weight,
    letterSpacing: size * trackingEm,
  );
}

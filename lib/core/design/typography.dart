import 'package:flutter/widgets.dart';

import 'tokens.dart';

/// The Orbix type scale for one script.
///
/// [OxTypography.en] is [OxText] as handed off, with Readex Pro as fallback so
/// Arabic channel/movie names inside an English UI still render in-brand
/// (orbix.css: `--f-ui: 'Manrope', 'Readex Pro', …`).
///
/// [OxTypography.ar] applies the `.ox[dir="rtl"]` rules from orbix.css:
/// every family → Readex Pro; hero/display/h1 → 700, line-height 1.3;
/// overline 12 px, no uppercase; no tracking anywhere (Foundations AR note);
/// weights capped at Readex Pro's 700. The remaining styles
/// get the README's +15–25 % line height (body 1.55 → 1.8, matching the
/// Foundations Arabic spec). Sizes are unchanged so layouts match EN.
@immutable
class OxTypography {
  const OxTypography._({
    required this.hero,
    required this.display,
    required this.h1,
    required this.h2,
    required this.title,
    required this.body,
    required this.small,
    required this.caption,
    required this.overline,
    required this.time,
    required this.uppercaseOverline,
  });

  final TextStyle hero;
  final TextStyle display;
  final TextStyle h1;
  final TextStyle h2;
  final TextStyle title;
  final TextStyle body;
  final TextStyle small;
  final TextStyle caption;
  final TextStyle overline;

  /// Times, durations, channel numbers (`.mono-time`). Always Western digits.
  final TextStyle time;

  /// Overlines are uppercase in EN only — use [overlineText].
  final bool uppercaseOverline;

  String overlineText(String text) => uppercaseOverline ? text.toUpperCase() : text;

  /// Arabic scale: components drop letter-spacing and uppercase when true.
  bool get isArabic => !uppercaseOverline;

  static const _arabicFallback = <String>[OxFonts.arabic];

  static final en = OxTypography._(
    hero: OxText.hero.copyWith(fontFamilyFallback: _arabicFallback),
    display: OxText.display.copyWith(fontFamilyFallback: _arabicFallback),
    h1: OxText.h1.copyWith(fontFamilyFallback: _arabicFallback),
    h2: OxText.h2.copyWith(fontFamilyFallback: _arabicFallback),
    title: OxText.title.copyWith(fontFamilyFallback: _arabicFallback),
    body: OxText.body.copyWith(fontFamilyFallback: _arabicFallback),
    small: OxText.small.copyWith(fontFamilyFallback: _arabicFallback),
    caption: OxText.caption.copyWith(fontFamilyFallback: _arabicFallback),
    overline: OxText.overline.copyWith(fontFamilyFallback: _arabicFallback),
    time: OxText.time.copyWith(fontFamilyFallback: _arabicFallback),
    uppercaseOverline: true,
  );

  static final ar = OxTypography._(
    hero: _arHeading(OxText.hero),
    display: _arHeading(OxText.display),
    h1: _arHeading(OxText.h1),
    h2: _ar(OxText.h2, height: 1.5),
    title: _ar(OxText.title, height: 1.55),
    body: _ar(OxText.body, height: 1.8),
    small: _ar(OxText.small, height: 1.6),
    caption: _ar(OxText.caption, height: 1.55),
    overline: _ar(OxText.overline, fontSize: 12),
    // Readex Pro has no `tnum`; digits stay Western (formatted by the caller).
    time: _ar(OxText.time),
    uppercaseOverline: false,
  );

  /// Arabic: no tracking at all (it breaks cursive joins), and weights capped
  /// at 700 — Readex Pro's heaviest cut, which is what the browser falls back
  /// to for the 800s in orbix.css.
  static TextStyle _ar(TextStyle s, {double? height, double? fontSize}) => s.copyWith(
        fontFamily: OxFonts.arabic,
        fontFamilyFallback: const <String>[],
        height: height ?? s.height,
        fontSize: fontSize ?? s.fontSize,
        letterSpacing: 0,
        fontWeight: (s.fontWeight ?? FontWeight.w400).value > 700 ? FontWeight.w700 : s.fontWeight,
      );

  static TextStyle _arHeading(TextStyle s) => _ar(s, height: 1.3).copyWith(fontWeight: FontWeight.w700);

  static OxTypography forLocale(Locale locale) => locale.languageCode == 'ar' ? ar : en;
}

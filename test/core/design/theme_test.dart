import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbix/core/design/design.dart';

void main() {
  test('dark theme maps the core tokens', () {
    final t = OrbixTheme.dark();
    expect(t.brightness, Brightness.dark);
    expect(t.scaffoldBackgroundColor, OxColors.ink1);
    expect(t.colorScheme.primary, OxColors.ember);
    expect(t.colorScheme.onPrimary, OxColors.emberInk);
    expect(t.splashFactory, NoSplash.splashFactory);
    expect(t.extension<OxTokens>()!.typography, same(OxTypography.en));
  });

  test('theme is memoised per script', () {
    expect(OrbixTheme.dark(const Locale('en')), same(OrbixTheme.dark(const Locale('fr'))));
    expect(OrbixTheme.dark(const Locale('ar')), same(OrbixTheme.dark(const Locale('ar', 'EG'))));
    expect(OrbixTheme.dark(const Locale('ar')), isNot(same(OrbixTheme.dark())));
  });

  test('EN typography is the handed-off scale with an Arabic fallback', () {
    final en = OxTypography.en;
    expect(en.hero.fontFamily, OxFonts.display);
    expect(en.hero.fontSize, OxText.hero.fontSize);
    expect(en.h2.fontFamily, OxFonts.ui);
    expect(en.body.fontFamilyFallback, [OxFonts.arabic]);
    expect(en.overlineText('Featured'), 'FEATURED');
  });

  test('AR typography follows the orbix.css [dir=rtl] rules', () {
    final ar = OxTypography.ar;
    for (final s in [ar.hero, ar.display, ar.h1, ar.h2, ar.title, ar.body, ar.small, ar.caption, ar.overline, ar.time]) {
      expect(s.fontFamily, OxFonts.arabic);
      expect(s.letterSpacing ?? 0, 0, reason: 'no tracking in Arabic');
      expect(s.fontWeight!.value, lessThanOrEqualTo(700), reason: 'Readex Pro tops out at 700');
    }
    for (final s in [ar.hero, ar.display, ar.h1]) {
      expect(s.fontWeight, FontWeight.w700);
      expect(s.height, 1.3);
      expect(s.letterSpacing, 0);
    }
    expect(ar.overline.fontSize, 12);
    expect(ar.overline.letterSpacing, 0);
    expect(ar.overlineText('Featured'), 'Featured');
    expect(ar.body.height, 1.8);
    // Sizes unchanged so EN and AR layouts line up.
    expect(ar.body.fontSize, OxText.body.fontSize);
    expect(ar.title.fontSize, OxText.title.fontSize);
  });

  test('window size classes', () {
    expect(OxWindowSize.fromWidth(412), OxWindowSize.compact);
    expect(OxWindowSize.fromWidth(599.9), OxWindowSize.compact);
    expect(OxWindowSize.fromWidth(600), OxWindowSize.medium);
    expect(OxWindowSize.fromWidth(839), OxWindowSize.medium);
    expect(OxWindowSize.fromWidth(840), OxWindowSize.expanded);
    expect(OxWindowSize.compact.gutter, 20);
    expect(OxWindowSize.expanded.gutter, 32);
    expect(OxWindowSize.compact.hasNavRail, isFalse);
    expect(OxWindowSize.medium.hasNavRail, isTrue);
  });
}

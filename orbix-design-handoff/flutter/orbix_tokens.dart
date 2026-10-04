// Orbix design tokens — generated from design/orbix.css (:root).
// Dark theme only.
import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

abstract final class OxColors {
  // Ink (backgrounds)
  static const ink0 = Color(0xFF050507); // canvas, nav rail
  static const ink1 = Color(0xFF08080B); // app background
  static const ink2 = Color(0xFF101015); // surface
  static const ink3 = Color(0xFF17171E); // raised, inputs
  static const ink4 = Color(0xFF20202A); // tonal controls
  static const ink5 = Color(0xFF2C2C38); // pressed, selected
  static const line = Color(0x14FFFFFF); // 8% white
  static const line2 = Color(0x24FFFFFF); // 14% white

  // Text
  static const text1 = Color(0xFFF5F1EB);
  static const text2 = Color(0xFFB4B0BA);
  static const text3 = Color(0xFF8E8A97);

  // Accents
  static const ember = Color(0xFFFF7A3D);
  static const emberHi = Color(0xFFFF9663);
  static const emberInk = Color(0xFF1C0C04); // text on ember (7.3:1)
  static const emberSoft = Color(0x29FF7A3D); // 16%
  static const halo = Color(0xFF7CC4FF);
  static const haloSoft = Color(0x247CC4FF); // 14%
  static const live = Color(0xFFC93F0E); // LIVE badge bg, white text 5.0:1
  static const ok = Color(0xFF5BD69B);
  static const warn = Color(0xFFFFC65C);
  static const err = Color(0xFFFF6B6B);

  // Glass
  static const glass = Color(0x9E101016); // rgba(16,16,22,.62), use with blur 22
  static const glassLite = Color(0x14FFFFFF);
}

abstract final class OxRadius {
  static const xs = 6.0;
  static const sm = 10.0;
  static const md = 14.0; // posters, buttons, inputs
  static const lg = 20.0; // cards, groups
  static const xl = 28.0; // sheets, dialogs
  static const pill = 999.0;
}

abstract final class OxSpace {
  static const s4 = 4.0, s8 = 8.0, s12 = 12.0, s16 = 16.0, s20 = 20.0;
  static const s24 = 24.0, s32 = 32.0, s40 = 40.0, s56 = 56.0;
  static const phoneGutter = 20.0;
  static const tabletGutter = 32.0;
  static const minTouch = 44.0;
}

abstract final class OxSize {
  static const buttonSm = 38.0, buttonMd = 50.0, buttonLg = 56.0;
  static const input = 54.0;
  static const chip = 36.0;
  static const bottomNav = 70.0;
  static const navRail = 96.0;
  static const posterRail = 120.0; // width, 2:3
  static const channelLogo = 48.0;
}

abstract final class OxBreakpoints {
  static const medium = 600.0; // nav rail, two panes
  static const expanded = 840.0; // three-pane Live TV
}

abstract final class OxFonts {
  static const display = 'Unbounded'; // titles, hero, times/numbers
  static const ui = 'Manrope';
  static const arabic = 'Readex Pro';
}

abstract final class OxText {
  static const hero = TextStyle(fontFamily: OxFonts.display, fontWeight: FontWeight.w600, fontSize: 34, height: 1.02, letterSpacing: -0.85, color: OxColors.text1);
  static const display = TextStyle(fontFamily: OxFonts.display, fontWeight: FontWeight.w600, fontSize: 28, height: 1.08, letterSpacing: -0.56, color: OxColors.text1);
  static const h1 = TextStyle(fontFamily: OxFonts.display, fontWeight: FontWeight.w600, fontSize: 22, height: 1.15, letterSpacing: -0.33, color: OxColors.text1);
  static const h2 = TextStyle(fontFamily: OxFonts.ui, fontWeight: FontWeight.w800, fontSize: 18, height: 1.25, letterSpacing: -0.18, color: OxColors.text1);
  static const title = TextStyle(fontFamily: OxFonts.ui, fontWeight: FontWeight.w700, fontSize: 15, height: 1.3, color: OxColors.text1);
  static const body = TextStyle(fontFamily: OxFonts.ui, fontWeight: FontWeight.w500, fontSize: 14, height: 1.55, color: OxColors.text2);
  static const small = TextStyle(fontFamily: OxFonts.ui, fontWeight: FontWeight.w600, fontSize: 12.5, height: 1.35, color: OxColors.text2);
  static const caption = TextStyle(fontFamily: OxFonts.ui, fontWeight: FontWeight.w600, fontSize: 11.5, height: 1.3, color: OxColors.text3);
  static const overline = TextStyle(fontFamily: OxFonts.ui, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1.76, color: OxColors.text3); // uppercase in EN only
  static const time = TextStyle(fontFamily: OxFonts.display, fontWeight: FontWeight.w500, fontSize: 12, fontFeatures: [FontFeature.tabularFigures()], color: OxColors.text1);
}

abstract final class OxMotion {
  static const fast = Duration(milliseconds: 140);
  static const base = Duration(milliseconds: 240);
  static const slow = Duration(milliseconds: 420);
  static const heroFade = Duration(milliseconds: 600);
  static const heart = Duration(milliseconds: 900);
  static const shimmer = Duration(milliseconds: 1400);
  static const easeOut = Cubic(0.2, 0.8, 0.2, 1);
  static const spring = Cubic(0.34, 1.56, 0.64, 1);
}

abstract final class OxShadows {
  static const e1 = [BoxShadow(color: Color(0x59000000), blurRadius: 30, offset: Offset(0, 10))];
  static const e2 = [BoxShadow(color: Color(0x8C000000), blurRadius: 60, offset: Offset(0, 24))];
  static const emberGlow = [BoxShadow(color: Color(0xA6FF7A3D), blurRadius: 30, spreadRadius: -8, offset: Offset(0, 10))];
}

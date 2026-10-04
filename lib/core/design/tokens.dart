// Orbix design tokens — generated from design/orbix.css (:root).
// Dark theme only.
//
// Source: orbix-design-handoff/flutter/orbix_tokens.dart (copied verbatim).
// Blocks marked "Added from orbix.css" hold values that live in component
// rules rather than :root; they are additive — no handoff token is changed.
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

  // --- Added from orbix.css component rules (not in :root) ---
  static const glassBorder = Color(0x14FFFFFF); // .glass border, 8%
  static const glassLiteBorder = Color(0x1FFFFFFF); // .glass-lite border, 12%
  static const sheet = Color(0xFF121218); // .sheet
  static const dialog = Color(0xFF15151C); // .dialog, E2 overlay
  static const scrim = Color(0x9E040406); // .scrim-full rgba(4,4,6,.62), blur 6
  static const snack = Color(0xFFF2EEE8); // .snack (light on dark)
  static const snackInk = Color(0xFF121216);
  static const snackAction = Color(0xFFC24A10);
  static const onLight = Color(0xFF0B0B0E); // text on .btn-light
  static const onChipOn = Color(0xFF0D0D10); // text on selected chip
  static const skeleton = Color(0xFF17171D); // .sk base
  static const shimmer = Color(0x0FFFFFFF); // .sk sweep, 6%
  static const errSoft = Color(0x24FF6B6B); // .btn-danger bg, 14%
  static const errText = Color(0xFFFF8C8C); // .btn-danger, .hint.error
  static const okBorder = Color(0x8C5BD69B); // .input.ok, 55%
  static const switchKnob = Color(0xFFCFCBD4);
  static const progressTrack = Color(0x2EFFFFFF); // .progress, 18%
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

  // --- Added from orbix.css ---
  static const iconButton = 44.0, iconButtonLg = 56.0, iconButtonXl = 76.0;
  static const chipSm = 30.0;
  static const search = 50.0;
  static const topBar = 92.0;
  static const progress = 3.0, progressLg = 5.0;
}

/// Icon sizes — `.ic-xs` … `.ic-xxl` (default `.ic` is 24).
abstract final class OxIconSize {
  static const xs = 14.0, sm = 18.0, md = 20.0, base = 24.0;
  static const lg = 28.0, xl = 36.0, xxl = 48.0;
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
  static const page = Duration(milliseconds: 300); // shared-axis page transition (Foundations §05)
  static const easeOut = Cubic(0.2, 0.8, 0.2, 1);
  static const spring = Cubic(0.34, 1.56, 0.64, 1);
}

abstract final class OxShadows {
  static const e1 = [BoxShadow(color: Color(0x59000000), blurRadius: 30, offset: Offset(0, 10))];
  static const e2 = [BoxShadow(color: Color(0x8C000000), blurRadius: 60, offset: Offset(0, 24))];
  static const emberGlow = [BoxShadow(color: Color(0xA6FF7A3D), blurRadius: 30, spreadRadius: -8, offset: Offset(0, 10))];

  // --- Added from orbix.css ---
  static const poster = [BoxShadow(color: Color(0xCC000000), blurRadius: 28, spreadRadius: -12, offset: Offset(0, 12))];
  static const posterLift = [BoxShadow(color: Color(0xE6000000), blurRadius: 40, spreadRadius: -14, offset: Offset(0, 20))];
  static const bottomNav = [BoxShadow(color: Color(0x99000000), blurRadius: 40, offset: Offset(0, 18))];
  static const sheet = [BoxShadow(color: Color(0x99000000), blurRadius: 60, offset: Offset(0, -20))];
  static const dialog = [BoxShadow(color: Color(0xB3000000), blurRadius: 80, offset: Offset(0, 30))];
  static const snack = [BoxShadow(color: Color(0x80000000), blurRadius: 40, offset: Offset(0, 16))];
}

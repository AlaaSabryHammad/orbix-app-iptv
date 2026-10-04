import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/breakpoints.dart';
import '../../core/design/icons/ox_icons.dart';
import '../../core/design/motion.dart';
import '../../core/design/theme.dart';
import '../../core/design/tokens.dart';
import '../../core/design/typography.dart';
import '../../core/l10n/l10n.dart';
import '../../core/router/routes.dart';
import 'dev_locale_toggle.dart';

/// Dev-only mirror of `Foundations.dc.html` — colour, type (EN + AR), space,
/// radii, elevation, icons, motion, breakpoints — for side-by-side review.
///
/// The translate action flips the whole app between EN and AR, which also
/// shows RTL icon mirroring and the Arabic type scale in place.
class FoundationsPreviewScreen extends StatelessWidget {
  const FoundationsPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gutter = OxWindowSize.of(context).gutter;

    return Scaffold(
      backgroundColor: OxColors.ink0,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : context.go(Routes.home),
          icon: const OxIcon(OxIcons.back),
        ),
        title: Text(context.l10n.devFoundations),
        actions: const [
          DevLocaleToggle(),
          SizedBox(width: OxSpace.s8),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(gutter, OxSpace.s16, gutter, OxSpace.s56),
        children: const [
          _Header(),
          _Section(n: '01', title: 'Color', note: 'Dark-only ground · one warm accent · one cool signal', child: _Colors()),
          _Section(n: '02', title: 'Typography', note: 'Unbounded · Manrope · Readex Pro (Arabic)', child: _Type()),
          _Section(n: '03', title: 'Space, shape & depth', note: '4-pt grid · 20 phone gutter · 32 tablet gutter', child: _Shape()),
          _Section(n: '04', title: 'Iconography', note: '24 grid · 1.8 rounded stroke · media glyphs never mirror', child: _Icons()),
          _Section(n: '05', title: 'Motion & layout', note: 'Respect “Remove animations” — fade-only fallback', child: _MotionLayout()),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(OxSpace.s24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0x0FFFFFFF)),
        gradient: const RadialGradient(
          center: Alignment(-0.7, 0),
          radius: 1.2,
          colors: [Color(0xFF1E100A), Color(0xFF0B0B0F)],
          stops: [0, 0.7],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: OxSpace.s12,
        children: [
          Text(
            'ORBIX',
            style: OxTypography.en.display.copyWith(fontSize: 40, letterSpacing: 40 * 0.16, height: 1),
          ),
          Text(
            'أوربكس',
            textDirection: TextDirection.rtl,
            style: OxTypography.ar.h2.copyWith(fontWeight: FontWeight.w600, fontSize: 20, color: OxColors.text2),
          ),
          Text(
            'A cinematic IPTV player for Android. The mark is a play button held in orbit — '
            'the ember moon traces every loading state, focus ring and live indicator.',
            textDirection: TextDirection.ltr,
            style: context.oxText.body.copyWith(color: const Color(0xFFD2CED8)),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.n, required this.title, required this.note, required this.child});

  final String n;
  final String title;
  final String note;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.oxText;
    return Padding(
      padding: const EdgeInsets.only(top: OxSpace.s40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            spacing: 14,
            children: [
              Text(n, style: OxTypography.en.h1.copyWith(fontSize: 13, color: OxColors.emberHi)),
              Expanded(child: Text(title, style: OxTypography.en.h1)),
            ],
          ),
          const SizedBox(height: OxSpace.s4),
          Text(note, style: t.caption),
          const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider()),
          child,
        ],
      ),
    );
  }
}

// --- 01 Color --------------------------------------------------------------

class _Colors extends StatelessWidget {
  const _Colors();

  static const _ink = [
    ('Ink 0', OxColors.ink0, 'Canvas, rail'),
    ('Ink 1', OxColors.ink1, 'App background'),
    ('Ink 2', OxColors.ink2, 'Surface'),
    ('Ink 3', OxColors.ink3, 'Raised, inputs'),
    ('Ink 4', OxColors.ink4, 'Tonal controls'),
    ('Ink 5', OxColors.ink5, 'Pressed, selected'),
    ('Text 3', OxColors.text3, 'Tertiary text'),
    ('Text 2', OxColors.text2, 'Secondary text'),
    ('Text 1', OxColors.text1, 'Primary text'),
  ];

  static const _accents = [
    ('Ember', OxColors.ember, 'Action, live, focus'),
    ('Ember Hi', OxColors.emberHi, 'Hover, labels on dark'),
    ('Ember Ink', OxColors.emberInk, 'Text on ember'),
    ('Ember Soft', OxColors.emberSoft, 'Active pills, chips'),
    ('Halo', OxColors.halo, 'Quality, time, info'),
    ('Live Red', OxColors.live, 'LIVE badge only'),
    ('Success', OxColors.ok, 'Connected, watched'),
    ('Caution', OxColors.warn, 'Locks, expiry'),
    ('Error', OxColors.err, 'Failures'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: OxSpace.s24,
      children: [
        _Grid(minTileWidth: 104, children: [for (final c in _ink) _Swatch(c.$1, c.$2, c.$3)]),
        _Grid(minTileWidth: 104, children: [for (final c in _accents) _Swatch(c.$1, c.$2, c.$3)]),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0E0E13),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x0FFFFFFF)),
          ),
          child: Row(
            spacing: 14,
            children: [
              // Token check only — the real button is a Phase 2 component.
              DecoratedBox(
                decoration: BoxDecoration(
                  color: OxColors.ember,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: OxShadows.emberGlow,
                ),
                child: SizedBox(
                  height: OxSize.buttonSm,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: Text('Play', style: context.oxText.title.copyWith(fontWeight: FontWeight.w800, fontSize: 13.5, color: OxColors.emberInk)),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text('Ember buttons carry dark ink text (#1C0C04) — 7.3 : 1 contrast', style: context.oxText.small),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.name, this.color, this.use);

  final String name;
  final Color color;
  final String use;

  @override
  Widget build(BuildContext context) {
    final t = context.oxText;
    final hex = '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Container(
          height: 64,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: OxColors.line),
          ),
        ),
        Text(name, style: t.title.copyWith(fontSize: 13, fontWeight: FontWeight.w800)),
        Text(
          hex.startsWith('#FF') ? '#${hex.substring(3)}' : hex,
          textDirection: TextDirection.ltr, // keep '#' leading in RTL
          style: OxTypography.en.time.copyWith(fontSize: 11, color: OxColors.text3),
        ),
        Text(use, style: t.caption),
      ],
    );
  }
}

// --- 02 Typography ---------------------------------------------------------

class _Type extends StatelessWidget {
  const _Type();

  @override
  Widget build(BuildContext context) {
    final en = OxTypography.en;
    final ar = OxTypography.ar;
    final enCol = Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Spec('Hero', en.hero, en.hero.copyWith(fontSize: 30), 'THE LAST MERIDIAN'),
          _Spec('Display', en.display, en.display, 'Choose an account'),
          _Spec('H1', en.h1, en.h1, 'Live TV'),
          _Spec('H2', en.h2, en.h2, 'Continue watching'),
          _Spec('Title', en.title, en.title, 'Coastal FC vs Northern United'),
          _Spec('Body', en.body, en.body, 'When the last relay on a dying world goes silent, one engineer crosses the meridian.'),
          _Spec('Small', en.small, en.small, 'Drama · 2h 18m · 2026'),
          _Spec('Caption', en.caption, en.caption, 'Pulse Sports 1 · 20:30–22:30'),
          _Spec('Overline', en.overline, en.overline, en.overlineText('Featured series')),
          _Spec('Time', en.time, en.time, '20:30 · 1:12:44 · CH 104'),
        ],
      ),
    );
    final arCol = Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Spec('بطل', ar.hero, ar.hero.copyWith(fontSize: 30), 'خط الزوال الأخير'),
          _Spec('عرض', ar.display, ar.display, 'اختر حسابًا'),
          _Spec('عنوان 1', ar.h1, ar.h1, 'البث المباشر'),
          _Spec('عنوان 2', ar.h2, ar.h2, 'متابعة المشاهدة'),
          _Spec('عنوان', ar.title, ar.title, 'كوستال × نورثرن يونايتد'),
          _Spec('نص', ar.body, ar.body, 'حين يصمت آخر مُرحِّل للإشارة على كوكب يحتضر، يعبر مهندس وحيد خط الزوال.'),
          _Spec('صغير', ar.small, ar.small, 'دراما · 2 س 18 د'),
          _Spec('تسمية', ar.caption, ar.caption, 'بلس الرياضية 1 · 20:30–22:30'),
          _Spec('عنوان علوي', ar.overline, ar.overline, ar.overlineText('مباشر الآن')),
          _Spec('وقت', ar.time, ar.time, '20:30 · 1:12:44'),
        ],
      ),
    );
    return LayoutBuilder(
      builder: (context, c) => c.maxWidth >= 760
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: OxSpace.s40,
              children: [Expanded(child: enCol), Expanded(child: arCol)],
            )
          : Column(spacing: OxSpace.s32, children: [enCol, arCol]),
    );
  }
}

/// One specimen row. The spec label is computed from the live [style] so the
/// preview verifies the tokens rather than restating them.
class _Spec extends StatelessWidget {
  const _Spec(this.name, this.style, this.sample, this.text);

  final String name;
  final TextStyle style;
  final TextStyle sample;
  final String text;

  @override
  Widget build(BuildContext context) {
    final weight = style.fontWeight?.value ?? 400;
    final height = style.height == null ? '' : ' / ${style.height}';
    final track = (style.letterSpacing ?? 0) == 0 ? '' : ' · ${style.letterSpacing}';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x0DFFFFFF)))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Text(
            '$name · ${style.fontFamily} $weight · ${style.fontSize}$height$track',
            style: OxTypography.en.caption.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(text, style: sample),
        ],
      ),
    );
  }
}

// --- 03 Space, shape & depth -----------------------------------------------

class _Shape extends StatelessWidget {
  const _Shape();

  static const _space = [
    (OxSpace.s4, 'Icon-to-label'),
    (OxSpace.s8, 'Chip gaps'),
    (OxSpace.s12, 'Poster gaps'),
    (OxSpace.s16, 'Card padding'),
    (OxSpace.s20, 'Phone gutter'),
    (OxSpace.s24, 'Section inset'),
    (OxSpace.s32, 'Tablet gutter'),
    (OxSpace.s40, 'Block spacing'),
    (OxSpace.s56, 'Hero breathing room'),
  ];

  static const _radii = [
    ('XS', OxRadius.xs, 'Badges'),
    ('SM', OxRadius.sm, 'Logos, thumbs'),
    ('MD', OxRadius.md, 'Posters, buttons'),
    ('LG', OxRadius.lg, 'Cards, groups'),
    ('XL', OxRadius.xl, 'Sheets, dialogs'),
    ('Pill', OxRadius.pill, 'Chips, search'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.oxText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: OxSpace.s32,
      children: [
        Column(
          spacing: 10,
          children: [
            for (final s in _space)
              Row(
                spacing: 14,
                children: [
                  SizedBox(width: 30, child: Text('${s.$1.toInt()}', style: OxTypography.en.time.copyWith(fontSize: 11, color: OxColors.text3))),
                  Container(
                    width: s.$1,
                    height: 12,
                    decoration: BoxDecoration(color: OxColors.ember.withValues(alpha: .85), borderRadius: BorderRadius.circular(3)),
                  ),
                  Text(s.$2, style: t.caption),
                ],
              ),
          ],
        ),
        _Grid(
          minTileWidth: 110,
          children: [
            for (final r in _radii)
              _Tile(
                label: '${r.$1} · ${r.$1 == 'Pill' ? '999' : r.$2.toInt()}',
                note: r.$3,
                child: Container(
                  height: 76,
                  decoration: BoxDecoration(
                    color: OxColors.ink3,
                    border: Border.all(color: const Color(0x1AFFFFFF)),
                    borderRadius: BorderRadius.circular(r.$2),
                  ),
                ),
              ),
          ],
        ),
        _Grid(
          minTileWidth: 150,
          children: [
            _Tile(
              label: 'E0 · Surface',
              note: 'Lists, groups',
              child: Container(
                height: 88,
                decoration: BoxDecoration(
                  color: OxColors.ink2,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: OxColors.line),
                ),
              ),
            ),
            _Tile(
              label: 'E1 · Raised',
              note: 'Cards, posters',
              child: Container(
                height: 88,
                decoration: BoxDecoration(color: OxColors.ink3, borderRadius: BorderRadius.circular(18), boxShadow: OxShadows.e1),
              ),
            ),
            _Tile(
              label: 'E2 · Overlay',
              note: 'Dialogs, sheets, menus',
              child: Container(
                height: 88,
                decoration: BoxDecoration(
                  color: OxColors.dialog,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0x1FFFFFFF)),
                  boxShadow: OxShadows.e2,
                ),
              ),
            ),
            const _Tile(label: 'Glass · blur 22', note: 'Nav bar, over artwork', child: _GlassDemo()),
          ],
        ),
      ],
    );
  }
}

class _GlassDemo extends StatelessWidget {
  const _GlassDemo();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 88,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Stand-in for artwork (demo images are not bundled).
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [OxColors.ember, Color(0xFF6A2BD9), OxColors.halo]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 11, sigmaY: 11), // CSS blur(22px) ≈ σ 11
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: OxColors.glass,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: OxColors.glassBorder),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 04 Iconography --------------------------------------------------------

class _Icons extends StatelessWidget {
  const _Icons();

  @override
  Widget build(BuildContext context) {
    final t = context.oxText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: OxSpace.s16,
      children: [
        Text(
          '${OxIcons.values.length} icons. Mirrored in RTL: '
          '${OxIcons.values.where((i) => i.mirrorInRtl).map((i) => i.id).join(', ')} — switch to عربي to check.',
          style: t.small,
        ),
        _Grid(
          minTileWidth: 76,
          spacing: 10,
          children: [
            for (final i in OxIcons.values)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E0E13),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x0DFFFFFF)),
                ),
                child: Column(
                  spacing: 8,
                  children: [
                    OxIcon(i, color: i.mirrorInRtl ? OxColors.emberHi : null),
                    Text(
                      i.id,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: OxTypography.en.caption.copyWith(fontSize: 10.5),
                    ),
                  ],
                ),
              ),
          ],
        ),
        Row(
          spacing: OxSpace.s16,
          children: [
            for (final s in const [OxIconSize.xs, OxIconSize.sm, OxIconSize.md, OxIconSize.base, OxIconSize.lg, OxIconSize.xl, OxIconSize.xxl])
              OxIcon(OxIcons.play, size: s, color: OxColors.ember),
          ],
        ),
      ],
    );
  }
}

// --- 05 Motion & layout ----------------------------------------------------

class _MotionLayout extends StatelessWidget {
  const _MotionLayout();

  static final _motion = [
    ('Poster press / hover', OxMotion.fast, 'Scale .97 on press, lift 4 + 1.03 on focus · ease-out'),
    ('Hero transition', OxMotion.heroFade, 'Cross-fade between titles; 18 s Ken Burns drift'),
    ('Page transition', OxMotion.page, 'Shared-axis: poster expands into the details backdrop'),
    ('Bottom sheet', OxMotion.slow, 'Rise 40 + fade, scrim blur 6'),
    ('Favorite heart', OxMotion.heart, 'Spring 1 → 1.35 → .9 → 1 with ember ring burst'),
    ('Base', OxMotion.base, 'Default state change'),
    ('Skeleton shimmer', OxMotion.shimmer, 'Shimmer sweep, then artwork fades in over it'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.oxText;
    final size = MediaQuery.sizeOf(context);
    final windowSize = OxWindowSize.of(context);
    final hinge = oxVerticalHinge(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        for (final m in _motion)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0E0E13),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x0DFFFFFF)),
            ),
            child: Row(
              spacing: 14,
              children: [
                Expanded(flex: 3, child: Text(m.$1, style: t.title.copyWith(fontSize: 13.5, fontWeight: FontWeight.w800))),
                SizedBox(
                  width: 64,
                  child: Text('${m.$2.inMilliseconds} ms', style: OxTypography.en.time.copyWith(fontSize: 11.5, color: OxColors.emberHi)),
                ),
                Expanded(flex: 4, child: Text(m.$3, style: t.caption)),
              ],
            ),
          ),
        const SizedBox(height: OxSpace.s16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF0E0E13),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x0FFFFFFF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(t.overlineText('This window'), style: t.overline.copyWith(color: OxColors.emberHi)),
              Text(
                '${size.width.round()} × ${size.height.round()} dp → ${windowSize.name}'
                '${windowSize.hasNavRail ? ' · nav rail' : ' · bottom nav'} · gutter ${windowSize.gutter.toInt()}',
                style: t.title,
              ),
              Text(
                'Hinge: ${hinge == null ? 'none' : '${hinge.left.round()}–${hinge.right.round()} dp'}'
                ' · Reduce motion: ${context.reduceMotion ? 'on (fade-only)' : 'off'}',
                style: t.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- helpers ---------------------------------------------------------------

/// Responsive grid: as many columns of at least [minTileWidth] as fit.
class _Grid extends StatelessWidget {
  const _Grid({required this.minTileWidth, required this.children, this.spacing = 14});

  final double minTileWidth;
  final double spacing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final cols = ((c.maxWidth + spacing) / (minTileWidth + spacing)).floor().clamp(1, 14);
        final w = (c.maxWidth - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [for (final child in children) SizedBox(width: w, child: child)],
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.note, required this.child});

  final String label;
  final String note;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.oxText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        child,
        Text(label, style: t.title.copyWith(fontSize: 12.5, fontWeight: FontWeight.w800)),
        Text(note, style: t.caption),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/design/design.dart';
import '../../core/l10n/l10n.dart';

enum OxBadgeTone {
  /// `.b-4k` — halo on deep blue: 4K, UHD, HDR.
  uhd,

  /// `.b-fhd` / `.b-hd` — white on black.
  hd,

  /// `.b-live` — white on live red, pulsing dot.
  live,

  /// `.b-new` — ink on ember.
  fresh,

  /// `.b-soft` — age ratings, audio formats.
  soft,

  /// `.b-lock` — caution, PIN-protected.
  lock,
}

/// `.badge` — 20 dp (17 dp [dense]) label for quality, live, new, locks.
///
/// Technical labels (4K, FHD, 5.1, HDR10) stay Latin in every locale; use
/// [OxBadge.live], [OxBadge.fresh] and [OxBadge.pin] for translated ones.
class OxBadge extends StatelessWidget {
  const OxBadge(this.label, {super.key, this.tone = OxBadgeTone.soft, this.dense = false, this.icon});

  /// Picks the tone from a playlist quality string ("4K", "UHD", "FHD", "HD"…).
  factory OxBadge.quality(String quality, {Key? key, bool dense = false}) {
    final q = quality.toUpperCase();
    final uhd = q.contains('4K') || q.contains('UHD') || q.contains('HDR') || q.contains('2160');
    return OxBadge(quality, key: key, tone: uhd ? OxBadgeTone.uhd : OxBadgeTone.hd, dense: dense);
  }

  static Widget live(BuildContext context, {bool dense = false}) =>
      OxBadge(context.l10n.badgeLive, tone: OxBadgeTone.live, dense: dense);

  static Widget fresh(BuildContext context, {bool dense = false}) =>
      OxBadge(context.l10n.badgeNew, tone: OxBadgeTone.fresh, dense: dense);

  static Widget pin(BuildContext context, {bool dense = false}) =>
      OxBadge(context.l10n.badgePin, tone: OxBadgeTone.lock, dense: dense, icon: OxIcons.lock);

  final String label;
  final OxBadgeTone tone;
  final bool dense;
  final OxIcons? icon;

  @override
  Widget build(BuildContext context) {
    final type = context.oxText;
    final (Color fg, Color bg, Color? border) = switch (tone) {
      OxBadgeTone.uhd => (OxColors.halo, const Color(0xB30A1E32), const Color(0x737CC4FF)),
      OxBadgeTone.hd => (OxColors.text1, const Color(0x73000000), const Color(0x47FFFFFF)),
      OxBadgeTone.live => (const Color(0xFFFFFFFF), OxColors.live, null),
      OxBadgeTone.fresh => (OxColors.emberInk, OxColors.ember, null),
      OxBadgeTone.soft => (OxColors.text2, OxColors.glassLite, null),
      OxBadgeTone.lock => (OxColors.warn, const Color(0x1FFFC65C), const Color(0x4DFFC65C)),
    };
    final fontSize = dense ? 9.5 : 10.5;

    return Container(
      height: dense ? 17 : 20,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(OxRadius.xs),
        border: border == null ? null : Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          if (tone == OxBadgeTone.live) const _PulseDot(),
          if (icon != null) OxIcon(icon!, size: OxIconSize.xs - (dense ? 2 : 0), color: fg),
          Text(
            label,
            style: TextStyle(
              fontFamily: type.title.fontFamily,
              fontWeight: type.isArabic ? FontWeight.w700 : FontWeight.w800,
              fontSize: fontSize,
              height: 1,
              letterSpacing: type.isArabic ? 0 : fontSize * 0.04,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

/// The 6 dp white dot inside `.b-live` — `ox-pulse` 1.6 s.
class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.reduceMotion ? _c.stop() : _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const dot = DecoratedBox(
      decoration: BoxDecoration(color: Color(0xFFFFFFFF), shape: BoxShape.circle),
      child: SizedBox.square(dimension: 6),
    );
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        // 0 → 50 % → 100 %: opacity 1 → .35 → 1, scale 1 → .7 → 1 (ease).
        final t = Curves.ease.transform(1 - (2 * _c.value - 1).abs());
        return Opacity(opacity: 1 - 0.65 * t, child: Transform.scale(scale: 1 - 0.3 * t, child: child));
      },
      child: dot,
    );
  }
}

/// `.rating` — ember star + score.
class OxRating extends StatelessWidget {
  const OxRating(this.value, {super.key});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        const OxIcon(OxIcons.star, size: 13, color: OxColors.ember),
        Text(value, style: context.oxText.small.copyWith(fontWeight: FontWeight.w800, color: OxColors.text1)),
      ],
    );
  }
}

/// `.dot-sep` — 3 dp separator dot.
class OxDotSeparator extends StatelessWidget {
  const OxDotSeparator({super.key});

  @override
  Widget build(BuildContext context) => const DecoratedBox(
        decoration: BoxDecoration(color: OxColors.text3, shape: BoxShape.circle),
        child: SizedBox.square(dimension: 3),
      );
}

/// `.meta` — "★ 8.6 · 2026 · Sci-Fi · Drama · 2h 18m". Strings become
/// caption text; widgets (e.g. [OxRating], [OxBadge]) are placed as-is.
class OxMetaLine extends StatelessWidget {
  const OxMetaLine(this.items, {super.key, this.color});

  final List<Object> items;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = context.oxText.small.copyWith(color: color ?? OxColors.text2);
    final children = <Widget>[];
    for (final item in items) {
      if (children.isNotEmpty) children.add(const OxDotSeparator());
      children.add(item is Widget ? item : Text('$item', style: style));
    }
    return Wrap(
      spacing: 7,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}

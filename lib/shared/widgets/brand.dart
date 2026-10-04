import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/design/design.dart';

/// `.logo-mark` — a play button held in orbit: warm-white ring, ember play
/// core, ember moon with glow. Proportions scale from the 36 dp master.
///
/// [orbiting] sends the moon round the ring (Foundations header, splash);
/// static otherwise and under reduced motion.
class OxLogoMark extends StatefulWidget {
  const OxLogoMark({super.key, this.size = 36, this.orbiting = false, this.orbitPeriod = const Duration(seconds: 6), this.glow = false});

  final double size;
  final bool orbiting;
  final Duration orbitPeriod;

  /// Splash: ember glow on the ring and the play core.
  final bool glow;

  @override
  State<OxLogoMark> createState() => _OxLogoMarkState();
}

class _OxLogoMarkState extends State<OxLogoMark> with SingleTickerProviderStateMixin {
  AnimationController? _c;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animate = widget.orbiting && !context.reduceMotion;
    if (animate && _c == null) {
      _c = AnimationController(vsync: this, duration: widget.orbitPeriod)..repeat();
    } else if (!animate) {
      _c?.dispose();
      _c = null;
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _LogoPainter(_c, orbiting: _c != null, glow: widget.glow),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  _LogoPainter(this.t, {required this.orbiting, required this.glow}) : super(repaint: t);

  final Animation<double>? t;
  final bool orbiting;
  final bool glow;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final k = s / 36;
    final c = size.center(Offset.zero);

    // Ring: 2.5 @36 (min 2) for marks; 4 @92, 5 @112 for the hero sizes.
    final w = s <= 40 ? (2.5 * k).clamp(2.0, 2.5) : s * 0.0445;
    if (glow) {
      canvas.drawCircle(c, s / 2, Paint()..color = OxColors.ember.withValues(alpha: 0.25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20));
    }
    canvas.drawCircle(
      c,
      s / 2 - w / 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..color = OxColors.text1,
    );

    // Core: 11 × 14 triangle, translate(-30%, -50%) from the centre.
    final tw = 11 * k, th = 14 * k;
    final left = c.dx - 0.3 * tw, top = c.dy - th / 2;
    final core = Path()
      ..moveTo(left, top)
      ..lineTo(left + tw, c.dy)
      ..lineTo(left, top + th)
      ..close();
    if (glow) canvas.drawPath(core, Paint()..color = OxColors.ember.withValues(alpha: 0.7)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7));
    canvas.drawPath(
      Path()
        ..moveTo(left, top)
        ..lineTo(left + tw, c.dy)
        ..lineTo(left, top + th)
        ..close(),
      Paint()..color = OxColors.ember,
    );

    // Moon: 9 dp at the top-end of the ring, or (orbiting) a smaller moon
    // circling just outside it (16 @112 on the splash).
    final d = orbiting ? s * 0.143 : 9 * k;
    final Offset moon;
    if (orbiting) {
      final a = -math.pi / 2 + t!.value * 2 * math.pi;
      moon = c + Offset(math.cos(a), math.sin(a)) * (s / 2 + 12 * s / 92);
    } else {
      moon = Offset(s + 1 * k - d / 2, 1 * k + d / 2);
    }
    canvas.drawCircle(moon, d / 2 + 2 * k, Paint()..color = OxColors.ember.withValues(alpha: 0.55)..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 * k));
    canvas.drawCircle(moon, d / 2, Paint()..color = OxColors.ember);
  }

  @override
  bool shouldRepaint(_LogoPainter old) => old.orbiting != orbiting;
}

/// `.wordmark` — "ORBIX" in Unbounded 600, always Latin.
class OxWordmark extends StatelessWidget {
  const OxWordmark({super.key, this.fontSize = 15, this.tracking = 0.14, this.color = OxColors.text1});

  final double fontSize;

  /// Letter-spacing in em (top bar .14, splash .22).
  final double tracking;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      'ORBIX',
      textDirection: TextDirection.ltr,
      semanticsLabel: 'Orbix',
      style: TextStyle(
        fontFamily: OxFonts.display,
        fontWeight: FontWeight.w600,
        fontSize: fontSize,
        height: 1,
        letterSpacing: fontSize * tracking,
        color: color,
      ),
    );
  }
}

/// Logo mark + wordmark, as in the phone top bar (26 dp mark, 15 dp type).
class OxBrandLockup extends StatelessWidget {
  const OxBrandLockup({super.key, this.markSize = 26, this.fontSize = 15});

  final double markSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 9,
      children: [OxLogoMark(size: markSize), OxWordmark(fontSize: fontSize)],
    );
  }
}

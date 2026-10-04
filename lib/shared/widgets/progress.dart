import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/design/design.dart';
import '../../core/l10n/l10n.dart';

/// `.progress` — 3 dp (5 dp [large]) track with an ember or halo fill.
/// Fills from the inline start, so it fills from the right in RTL.
class OxProgressBar extends StatelessWidget {
  const OxProgressBar({
    super.key,
    required this.value,
    this.halo = false,
    this.large = false,
    this.flush = false,
    this.trackColor = OxColors.progressTrack,
  });

  /// 0 … 1.
  final double value;
  final bool halo;
  final bool large;

  /// Square ends — sits flush along a thumbnail's bottom edge.
  final bool flush;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    final h = large ? OxSize.progressLg : OxSize.progress;
    final r = BorderRadius.circular(flush ? 0 : h);
    return Semantics(
      value: '${(value.clamp(0, 1) * 100).round()}%',
      child: Container(
        height: h,
        decoration: BoxDecoration(color: trackColor, borderRadius: r),
        clipBehavior: Clip.antiAlias,
        alignment: AlignmentDirectional.centerStart,
        child: AnimatedFractionallySizedBox(
          duration: OxMotion.base,
          curve: OxMotion.easeOut,
          widthFactor: value.clamp(0, 1),
          heightFactor: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(color: halo ? OxColors.halo : OxColors.ember, borderRadius: r),
          ),
        ),
      ),
    );
  }
}

/// Mixin for looping decorative animations: stops (or never starts) when the
/// system asks for reduced motion. Set [essential] for indicators that carry
/// meaning (loading spinners), which keep running.
mixin _OxLoop<T extends StatefulWidget> on State<T>, SingleTickerProviderStateMixin<T> {
  late final AnimationController loop = AnimationController(vsync: this, duration: loopDuration);

  Duration get loopDuration;
  bool get essential => false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!essential && context.reduceMotion) {
      loop.value = 0.5;
      loop.stop();
    } else if (!loop.isAnimating) {
      loop.repeat();
    }
  }

  @override
  void dispose() {
    loop.dispose();
    super.dispose();
  }
}

/// `.orbit-loader` — the brand loader: a faint ring, an ember arc (1 s) and the
/// ember moon orbiting it (1.6 s).
class OxOrbitLoader extends StatefulWidget {
  const OxOrbitLoader({super.key, this.size = 56, this.semanticLabel});

  final double size;
  final String? semanticLabel;

  @override
  State<OxOrbitLoader> createState() => _OxOrbitLoaderState();
}

class _OxOrbitLoaderState extends State<OxOrbitLoader> with SingleTickerProviderStateMixin, _OxLoop {
  // One 8 s loop = lcm(1 s, 1.6 s), so both rotations stay seamless.
  @override
  Duration get loopDuration => const Duration(seconds: 8);

  @override
  bool get essential => true;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel ?? context.l10n.a11yLoading,
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.square(widget.size),
          painter: _OrbitPainter(loop),
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  _OrbitPainter(this.t) : super(repaint: t);

  final Animation<double> t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 1; // 2 dp border drawn inside the box
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(c, r, ring..color = const Color(0x1AFFFFFF));

    // border-top-color arc: the top quarter, rotating once per second.
    final arcAngle = t.value * 8 * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -3 * math.pi / 4 + arcAngle,
      math.pi / 2,
      false,
      ring..color = OxColors.ember,
    );

    // The moon: 7 dp dot centred 3 dp outside the top edge, 1.6 s per orbit.
    final moonAngle = -math.pi / 2 + t.value * 5 * 2 * math.pi;
    final mr = size.width / 2 + 0.5;
    final moon = c + Offset(math.cos(moonAngle), math.sin(moonAngle)) * mr;
    canvas.drawCircle(moon, 6, Paint()..color = OxColors.ember.withValues(alpha: 0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawCircle(moon, 3.5, Paint()..color = OxColors.ember);
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => false;
}

/// Small inline spinner — 3 dp ember ring with an open quarter, .9 s.
class OxSpinner extends StatefulWidget {
  const OxSpinner({super.key, this.size = 28, this.strokeWidth = 3, this.color = OxColors.ember});

  final double size;
  final double strokeWidth;
  final Color color;

  @override
  State<OxSpinner> createState() => _OxSpinnerState();
}

class _OxSpinnerState extends State<OxSpinner> with SingleTickerProviderStateMixin, _OxLoop {
  @override
  Duration get loopDuration => const Duration(milliseconds: 900);

  @override
  bool get essential => true;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.a11yLoading,
      child: RotationTransition(
        turns: loop,
        child: CustomPaint(
          size: Size.square(widget.size),
          painter: _SpinnerPainter(widget.color, widget.strokeWidth),
        ),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  _SpinnerPainter(this.color, this.stroke);

  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // border-right transparent: everything except the right quarter.
    canvas.drawArc(
      rect.deflate(stroke / 2),
      math.pi / 4,
      3 * math.pi / 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) => old.color != color || old.stroke != stroke;
}

/// `.eq` — three ember bars bouncing (.9 s, staggered .2 s): "now playing".
class OxEqualizer extends StatefulWidget {
  const OxEqualizer({super.key, this.height = 12, this.color = OxColors.ember});

  final double height;
  final Color color;

  @override
  State<OxEqualizer> createState() => _OxEqualizerState();
}

class _OxEqualizerState extends State<OxEqualizer> with SingleTickerProviderStateMixin, _OxLoop {
  @override
  Duration get loopDuration => const Duration(milliseconds: 900);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.a11yNowPlaying,
      child: AnimatedBuilder(
        animation: loop,
        builder: (context, _) => Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 2,
          children: [
            for (var i = 0; i < 3; i++)
              Container(
                width: 3,
                height: widget.height * _scale((loop.value - i * 0.2 / 0.9) % 1),
                decoration: BoxDecoration(color: widget.color, borderRadius: BorderRadius.circular(2)),
              ),
          ],
        ),
      ),
    );
  }

  // ox-bar: scaleY .35 → 1 → .35, ease-in-out.
  double _scale(double t) => 0.35 + 0.65 * Curves.easeInOut.transform(1 - (2 * t - 1).abs());
}

/// `.live-dot` — 8 dp ember dot with an expanding ring (1.6 s).
class OxLiveDot extends StatefulWidget {
  const OxLiveDot({super.key, this.size = 8, this.color = OxColors.ember});

  final double size;

  /// White on the player's red LIVE button.
  final Color color;

  @override
  State<OxLiveDot> createState() => _OxLiveDotState();
}

class _OxLiveDotState extends State<OxLiveDot> with SingleTickerProviderStateMixin, _OxLoop {
  @override
  Duration get loopDuration => const Duration(milliseconds: 1600);

  @override
  Widget build(BuildContext context) {
    final dot = DecoratedBox(
      decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      child: SizedBox.square(dimension: widget.size),
    );
    return SizedBox.square(
      dimension: widget.size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (!context.reduceMotion)
            AnimatedBuilder(
              animation: loop,
              builder: (context, child) => Opacity(
                opacity: 0.9 * (1 - loop.value),
                child: Transform.scale(scale: 0.6 + 1.2 * loop.value, child: child),
              ),
              child: dot,
            ),
          dot,
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/design/design.dart';

/// The shared language of every system state (States.dc.html): an emblem in
/// a dashed orbit, one sentence that says what happened, and one primary
/// action that fixes it.
class OxStateView extends StatelessWidget {
  const OxStateView({
    super.key,
    this.emblem,
    required this.title,
    this.message,
    this.detail,
    this.actions = const [],
    this.children = const [],
    this.titleSize = 20,
  });

  /// 20 for every state; 22 for the success screen.
  final double titleSize;

  /// Usually an [OxStateEmblem]; any widget (e.g. a loader) works.
  final Widget? emblem;
  final String title;
  final String? message;

  /// Small technical line ("DNS lookup failed · host:8080").
  final String? detail;
  final List<Widget> actions;

  /// Extra content between the text and the actions.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = context.oxText;
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        ?emblem,
        Semantics(header: true, child: Text(title, textAlign: TextAlign.center, style: t.h1.copyWith(fontSize: titleSize))),
        if (message != null) Text(message!, textAlign: TextAlign.center, style: t.body.copyWith(fontSize: 13)),
        if (detail != null)
          Text(detail!, textAlign: TextAlign.center, textDirection: TextDirection.ltr, style: t.caption),
        ...children,
        if (actions.isNotEmpty) Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 10, children: actions),
      ],
    );
  }
}

/// `.emblem` — 96 dp disc with a dashed orbit 14 dp outside.
class OxStateEmblem extends StatefulWidget {
  const OxStateEmblem({super.key, required this.icon, required this.background, required this.foreground, this.glow, this.beat = false});

  /// `anim-heart`: the glyph beats (No favorites). Off with reduced motion.
  final bool beat;

  final OxIcons icon;
  final Color background;
  final Color foreground;
  final Color? glow;

  /// Success (States 11): green disc, dark glyph, green glow.
  const OxStateEmblem.success({super.key})
      : icon = OxIcons.check,
        background = OxColors.ok,
        foreground = const Color(0xFF04150C),
        glow = const Color(0x735BD69B),
        beat = false;

  @override
  State<OxStateEmblem> createState() => _OxStateEmblemState();
}

class _OxStateEmblemState extends State<OxStateEmblem> with SingleTickerProviderStateMixin {
  AnimationController? _beat;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final on = widget.beat && !context.reduceMotion;
    if (on && _beat == null) {
      _beat = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
    } else if (!on) {
      _beat?.dispose();
      _beat = null;
    }
  }

  @override
  void dispose() {
    _beat?.dispose();
    super.dispose();
  }

  /// Two quick pulses, then rest (ox-heart).
  static double _scale(double t) => switch (t) {
        < 0.14 => 1 + 0.18 * (t / 0.14),
        < 0.28 => 1.18 - 0.18 * ((t - 0.14) / 0.14),
        < 0.42 => 1 + 0.12 * ((t - 0.28) / 0.14),
        < 0.56 => 1.12 - 0.12 * ((t - 0.42) / 0.14),
        _ => 1.0,
      };

  @override
  Widget build(BuildContext context) {
    final icon = widget.icon, background = widget.background, foreground = widget.foreground, glow = widget.glow;
    final glyph = OxIcon(icon, size: OxIconSize.xl, color: foreground);
    return SizedBox.square(
      dimension: 124,
      child: CustomPaint(
        painter: _DashedRing(),
        child: Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
              boxShadow: glow == null ? null : [BoxShadow(color: glow, blurRadius: 50)],
            ),
            child: Center(
              child: _beat == null ? glyph : AnimatedBuilder(animation: _beat!, builder: (_, child) => Transform.scale(scale: _scale(_beat!.value), child: child), child: glyph),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRing extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2 - 0.5;
    final c = size.center(Offset.zero);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x1FFFFFFF);
    const dash = 4.0, gap = 4.0;
    final circumference = 2 * 3.141592653589793 * r;
    final n = (circumference / (dash + gap)).floor();
    final step = 2 * 3.141592653589793 / n;
    for (var i = 0; i < n; i++) {
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), i * step, step * dash / (dash + gap), false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedRing old) => false;
}

import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../tokens.dart';

// Not *.g.dart: build_runner owns that suffix and deletes foreign files.
part 'ox_icons.data.dart';

/// One draw operation of an [OxIcons] glyph, in 24 × 24 viewBox units.
///
/// [path] is a flat opcode list — see the header of `ox_icons.data.dart`.
@immutable
class OxIconOp {
  const OxIconOp.stroke(this.path, {required this.width, this.cap = StrokeCap.butt, this.join = StrokeJoin.miter})
      : isStroke = true,
        evenOdd = false;

  const OxIconOp.fill(this.path, {this.evenOdd = false})
      : isStroke = false,
        width = 0,
        cap = StrokeCap.butt,
        join = StrokeJoin.miter;

  final List<double> path;
  final bool isStroke;
  final double width;
  final StrokeCap cap;
  final StrokeJoin join;
  final bool evenOdd;

  static final _cache = Expando<ui.Path>('OxIconOp.path');

  /// The decoded path, built once per op and reused for every paint.
  ui.Path get uiPath => _cache[this] ??= _decode();

  ui.Path _decode() {
    final p = ui.Path()..fillType = evenOdd ? ui.PathFillType.evenOdd : ui.PathFillType.nonZero;
    final d = path;
    var i = 0;
    while (i < d.length) {
      switch (d[i].toInt()) {
        case 0:
          p.moveTo(d[i + 1], d[i + 2]);
          i += 3;
        case 1:
          p.lineTo(d[i + 1], d[i + 2]);
          i += 3;
        case 2:
          p.cubicTo(d[i + 1], d[i + 2], d[i + 3], d[i + 4], d[i + 5], d[i + 6]);
          i += 7;
        default:
          p.close();
          i += 1;
      }
    }
    return p;
  }
}

/// Text that is part of a glyph — the "10" inside `rew` / `fwd`.
/// Coordinates are in viewBox units; [x] is the horizontal centre.
@immutable
class OxIconLabel {
  const OxIconLabel(this.text, {required this.x, required this.baseline, required this.size});

  final String text;
  final double x;
  final double baseline;
  final double size;
}

/// Renders an [OxIcons] glyph — the Flutter equivalent of `<span class="ic i-*">`.
///
/// Like the CSS mask icons it takes the ambient colour ([IconTheme], i.e.
/// `currentColor`) unless [color] is given. Sizes: [OxIconSize].
/// Directional glyphs mirror in RTL; media glyphs never do.
class OxIcon extends StatelessWidget {
  const OxIcon(this.icon, {super.key, this.size, this.color, this.semanticLabel});

  final OxIcons icon;
  final double? size;
  final Color? color;

  /// Announced by screen readers. Null = decorative (excluded from semantics).
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final s = size ?? theme.size ?? OxIconSize.base;
    var c = color ?? theme.color ?? OxColors.text1;
    final opacity = theme.opacity ?? 1;
    if (opacity < 1) c = c.withValues(alpha: c.a * opacity);

    Widget glyph = CustomPaint(
      size: Size.square(s),
      painter: _OxIconPainter(icon, c),
    );
    if (icon.mirrorInRtl && Directionality.of(context) == TextDirection.rtl) {
      glyph = Transform.flip(flipX: true, child: glyph);
    }

    final label = semanticLabel;
    if (label == null) return ExcludeSemantics(child: glyph);
    return Semantics(label: label, image: true, child: ExcludeSemantics(child: glyph));
  }
}

class _OxIconPainter extends CustomPainter {
  _OxIconPainter(this.icon, this.color);

  final OxIcons icon;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24;
    canvas
      ..save()
      ..scale(scale);
    for (final op in icon.ops) {
      final paint = Paint()
        ..color = color
        ..isAntiAlias = true;
      if (op.isStroke) {
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = op.width
          ..strokeCap = op.cap
          ..strokeJoin = op.join;
      }
      canvas.drawPath(op.uiPath, paint);
    }
    canvas.restore();

    final label = icon.label;
    if (label != null) {
      // Bold sans like the source's Arial 700; Manrope is our bundled UI face.
      final tp = TextPainter(
        text: TextSpan(
          text: label.text,
          style: TextStyle(
            fontFamily: OxFonts.ui,
            fontWeight: FontWeight.w800,
            fontSize: label.size * scale,
            height: 1,
            color: color,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final baseline = tp.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      tp.paint(canvas, Offset(label.x * scale - tp.width / 2, label.baseline * scale - baseline));
      tp.dispose();
    }
  }

  @override
  bool shouldRepaint(_OxIconPainter old) => old.icon != icon || old.color != color;
}

import 'package:flutter/widgets.dart';

/// `.ambient` — a soft coloured glow (CSS: circle + `filter: blur(70px)`,
/// opacity .5 × [opacity]). Drawn as a radial gradient over the blurred
/// footprint instead of a real blur, so it costs nothing per frame.
///
/// Position it like the HTML: [left]/[top] of the un-blurred circle.
class OxAmbient extends StatelessWidget {
  const OxAmbient({super.key, required this.color, required this.size, this.opacity = 1, this.left, this.top, this.right, this.bottom});

  final Color color;

  /// Diameter of the source circle (CSS width/height).
  final Size size;
  final double opacity;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;

  static const _blur = 70.0;

  @override
  Widget build(BuildContext context) {
    final a = 0.5 * opacity;
    return Positioned(
      left: left == null ? null : left! - _blur,
      top: top == null ? null : top! - _blur,
      right: right == null ? null : right! - _blur,
      bottom: bottom == null ? null : bottom! - _blur,
      width: size.width + 2 * _blur,
      height: size.height + 2 * _blur,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            gradient: RadialGradient(
              colors: [color.withValues(alpha: a), color.withValues(alpha: a * 0.6), color.withValues(alpha: 0)],
              stops: const [0, 0.42, 1],
            ),
          ),
        ),
      ),
    );
  }
}

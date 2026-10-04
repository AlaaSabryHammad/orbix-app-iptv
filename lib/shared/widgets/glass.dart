import 'dart:ui' show ImageFilter;

import 'package:flutter/widgets.dart';

import '../../core/design/design.dart';

/// Frosted surface over artwork — `.glass` (blur 22, nav bar) and
/// `.glass-lite` (blur 16, glass buttons).
class OxGlass extends StatelessWidget {
  const OxGlass({
    super.key,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.lite = false,
    this.color,
    this.borderColor,
    this.shadows,
    this.padding,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final bool lite;
  final Color? color;
  final Color? borderColor;
  final List<BoxShadow>? shadows;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    // CSS blur(Npx) is a Gaussian with σ = N / 2.
    final sigma = lite ? 8.0 : 11.0;
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: borderRadius, boxShadow: shadows),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color ?? (lite ? OxColors.glassLite : OxColors.glass),
              borderRadius: borderRadius,
              border: Border.all(color: borderColor ?? (lite ? OxColors.glassLiteBorder : OxColors.glassBorder)),
            ),
            child: padding == null ? child : Padding(padding: padding!, child: child),
          ),
        ),
      ),
    );
  }
}

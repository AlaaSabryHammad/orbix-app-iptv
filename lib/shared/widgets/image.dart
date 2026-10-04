import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/design/design.dart';
import 'skeleton.dart';

/// Artwork image: shimmer while loading, then a 600 ms fade-in
/// (`ox-fade` on `.poster img`). Decodes at display size to keep long
/// playlist grids light on memory.
///
/// [src] is a URL, or a bundled path starting with `assets/`. Null or a
/// failed load shows [fallback] (default: plain Ink 3).
class OxImage extends StatelessWidget {
  const OxImage(this.src, {super.key, this.fit = BoxFit.cover, this.alignment = Alignment.center, this.fallback});

  final String? src;
  final BoxFit fit;
  final Alignment alignment;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final src = this.src;
    final empty = fallback ?? const ColoredBox(color: OxColors.ink3, child: SizedBox.expand());
    if (src == null || src.isEmpty) return empty;

    final duration = context.reduceMotion ? OxMotion.base : OxMotion.heroFade;

    return LayoutBuilder(
      builder: (context, c) {
        final dpr = MediaQuery.devicePixelRatioOf(context);
        final w = c.maxWidth.isFinite ? (c.maxWidth * dpr).round() : null;

        if (src.startsWith('assets/')) {
          return Image.asset(
            src,
            fit: fit,
            alignment: alignment,
            width: double.infinity,
            height: double.infinity,
            cacheWidth: w,
            errorBuilder: (_, _, _) => empty,
            frameBuilder: (context, child, frame, sync) => sync
                ? child
                : AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: duration,
                    curve: OxMotion.easeOut,
                    child: child,
                  ),
          );
        }

        return CachedNetworkImage(
          imageUrl: src,
          fit: fit,
          alignment: alignment,
          width: double.infinity,
          height: double.infinity,
          memCacheWidth: w,
          fadeInDuration: duration,
          fadeInCurve: OxMotion.easeOut,
          fadeOutDuration: Duration.zero,
          placeholder: (_, _) => const OxSkeleton.fill(),
          errorWidget: (_, _, _) => empty,
        );
      },
    );
  }
}

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import 'tokens.dart';

/// Reduced-motion awareness. Durations and curves live in [OxMotion].
///
/// Foundations §05: respect Android's "Remove animations" — every motion has a
/// fade-only fallback. Components check [reduceMotion] and swap movement
/// (scale, slide, Ken Burns, spring) for a plain fade.
extension OxMotionContext on BuildContext {
  bool get reduceMotion => MediaQuery.maybeDisableAnimationsOf(this) ?? false;
}

/// Page transition: shared-axis (z / scaled — "poster expands into the details
/// backdrop"; direction-neutral, so it needs no RTL handling). Fade only when
/// the system asks for reduced motion.
class OxPageTransitionsBuilder extends PageTransitionsBuilder {
  const OxPageTransitionsBuilder();

  static const _sharedAxis = SharedAxisPageTransitionsBuilder(
    transitionType: SharedAxisTransitionType.scaled,
    fillColor: OxColors.ink1,
  );

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (context.reduceMotion) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: OxMotion.easeOut),
        child: child,
      );
    }
    return _sharedAxis.buildTransitions(route, context, animation, secondaryAnimation, child);
  }
}

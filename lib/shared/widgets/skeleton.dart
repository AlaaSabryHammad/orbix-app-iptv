import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/design/design.dart';

/// `.sk` — loading placeholder with a 1.4 s shimmer sweep.
///
/// All skeletons share one clock so a screen full of them sweeps in unison
/// (and costs one ticker). Under reduced motion the sweep becomes a gentle
/// opacity fade.
class OxSkeleton extends StatelessWidget {
  const OxSkeleton({super.key, this.width, this.height, this.radius = OxRadius.sm, this.circle = false});

  /// Fills its parent (e.g. behind a loading image).
  const OxSkeleton.fill({super.key, this.radius = 0})
      : width = double.infinity,
        height = double.infinity,
        circle = false;

  final double? width;
  final double? height;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final clock = _ShimmerClock.of(context);
    final reduce = context.reduceMotion;
    final shape = circle ? null : BorderRadius.circular(radius);

    return SizedBox(
      width: width,
      height: height,
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: ClipRRect(
            borderRadius: shape ?? BorderRadius.circular(9999),
            child: ValueListenableBuilder<double>(
              valueListenable: clock,
              builder: (context, t, _) {
                if (reduce) {
                  final a = 0.6 + 0.4 * (1 - (2 * t - 1).abs());
                  return ColoredBox(color: OxColors.skeleton.withValues(alpha: a));
                }
                return DecoratedBox(
                  decoration: const BoxDecoration(color: OxColors.skeleton),
                  child: FractionalTranslation(
                    translation: Offset(-1 + 2 * Curves.ease.transform(t), 0),
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0x00FFFFFF), OxColors.shimmer, Color(0x00FFFFFF)],
                        ),
                      ),
                      child: SizedBox.expand(),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Provides the shared shimmer clock. Mounted once in the app's builder;
/// skeletons outside it fall back to a private, static clock.
///
/// The clock only ticks while at least one skeleton is on screen, so the
/// scope costs nothing once content has loaded.
class OxShimmerScope extends StatefulWidget {
  const OxShimmerScope({super.key, required this.child});

  final Widget child;

  @override
  State<OxShimmerScope> createState() => _OxShimmerScopeState();
}

class _OxShimmerScopeState extends State<OxShimmerScope> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: OxMotion.shimmer);
  late final _clock = _OnDemandClock(_c);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _ShimmerClock(clock: _clock, child: widget.child);
}

/// Exposes [controller] as a listenable that runs it only while listened to.
class _OnDemandClock implements ValueListenable<double> {
  _OnDemandClock(this.controller);

  final AnimationController controller;
  int _listeners = 0;

  @override
  double get value => controller.value;

  @override
  void addListener(VoidCallback listener) {
    controller.addListener(listener);
    if (_listeners++ == 0) controller.repeat();
  }

  @override
  void removeListener(VoidCallback listener) {
    controller.removeListener(listener);
    if (--_listeners == 0) controller.stop();
  }
}

class _ShimmerClock extends InheritedWidget {
  const _ShimmerClock({required this.clock, required super.child});

  final ValueListenable<double> clock;

  static final _still = ValueNotifier<double>(0.5);

  static ValueListenable<double> of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ShimmerClock>()?.clock ?? _still;

  @override
  bool updateShouldNotify(_ShimmerClock old) => old.clock != clock;
}

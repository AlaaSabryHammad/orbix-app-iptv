import 'package:flutter/material.dart';

import '../../core/design/design.dart';
import '../../core/l10n/l10n.dart';
import 'pressable.dart';

/// Favourite toggle with the C6 "favorite pop": heart springs
/// 1 → 1.35 → .9 → 1 over 900 ms while an ember ring bursts outwards.
/// Reduced motion: a plain cross-fade between outline and filled heart.
class OxFavoriteButton extends StatefulWidget {
  const OxFavoriteButton({super.key, required this.value, required this.onChanged, this.size = OxIconSize.base, this.dimension = OxSize.iconButton});

  final bool value;
  final ValueChanged<bool>? onChanged;
  final double size;
  final double dimension;

  @override
  State<OxFavoriteButton> createState() => _OxFavoriteButtonState();
}

class _OxFavoriteButtonState extends State<OxFavoriteButton> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: OxMotion.heart);

  static final _pop = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35).chain(CurveTween(curve: OxMotion.spring)), weight: 30),
    TweenSequenceItem(tween: Tween(begin: 1.35, end: 0.9).chain(CurveTween(curve: OxMotion.spring)), weight: 25),
    TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0).chain(CurveTween(curve: OxMotion.spring)), weight: 45),
  ]);

  @override
  void didUpdateWidget(OxFavoriteButton old) {
    super.didUpdateWidget(old);
    if (widget.value && !old.value && !context.reduceMotion) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final on = widget.value;
    return OxPressable(
      onTap: widget.onChanged == null ? null : () => widget.onChanged!(!on),
      semanticLabel: on ? l.a11yRemoveFavorite : l.a11yAddFavorite,
      toggled: on,
      pressedScale: 0.9,
      child: SizedBox.square(
        dimension: widget.dimension,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            final ring = t == 0 || t == 1 ? 0.0 : (t / 0.7).clamp(0.0, 1.0);
            return Stack(
              alignment: Alignment.center,
              children: [
                if (ring > 0 && ring < 1)
                  Opacity(
                    opacity: 0.9 * (1 - ring),
                    child: Transform.scale(
                      scale: 0.6 + 1.2 * ring,
                      child: Container(
                        width: widget.size * 1.55,
                        height: widget.size * 1.55,
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: OxColors.ember, width: 2)),
                      ),
                    ),
                  ),
                Transform.scale(
                  scale: _c.isAnimating ? _pop.transform(t) : 1,
                  child: AnimatedSwitcher(
                    duration: OxMotion.fast,
                    child: OxIcon(
                      on ? OxIcons.heartFill : OxIcons.heart,
                      key: ValueKey(on),
                      size: widget.size,
                      color: on ? OxColors.ember : OxColors.text1,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// C6 "play glow" — a soft ember pulse (2.4 s) behind the hero play CTA only.
class OxPlayGlow extends StatefulWidget {
  const OxPlayGlow({super.key, required this.child, this.borderRadius, this.enabled = true});

  final Widget child;

  /// Null = circle.
  final BorderRadius? borderRadius;
  final bool enabled;

  @override
  State<OxPlayGlow> createState() => _OxPlayGlowState();
}

class _OxPlayGlowState extends State<OxPlayGlow> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.enabled && !context.reduceMotion ? _c.repeat() : _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        // ox-glow: 0 % / 100 % → 0 spread @ .55; 50 % → 14 spread @ 0.
        final k = 1 - (2 * _c.value - 1).abs();
        return DecoratedBox(
          decoration: BoxDecoration(
            shape: widget.borderRadius == null ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: widget.borderRadius,
            boxShadow: [
              if (_c.isAnimating) BoxShadow(color: OxColors.ember.withValues(alpha: 0.55 * (1 - k)), spreadRadius: 14 * k),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

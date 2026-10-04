import 'package:flutter/material.dart';

import '../../../core/design/design.dart';
import '../../../core/l10n/l10n.dart';
import '../../../shared/format/format.dart';

/// PlayerVOD seek bar: buffered (white 38 %), played (ember with glow),
/// a white thumb with an ember halo, and a time bubble while dragging.
/// Always left-to-right: time runs that way in every language.
class ScrubBar extends StatefulWidget {
  const ScrubBar({
    super.key,
    required this.position,
    required this.duration,
    required this.buffered,
    required this.onSeek,
    this.onScrubStart,
    this.onScrubEnd,
    this.scrubbing,
  });

  final Duration position;
  final Duration duration;
  final Duration buffered;
  final ValueChanged<Duration> onSeek;
  final VoidCallback? onScrubStart;
  final VoidCallback? onScrubEnd;

  /// An external scrub (horizontal swipe on the video) to show.
  final Duration? scrubbing;

  @override
  State<ScrubBar> createState() => _ScrubBarState();
}

class _ScrubBarState extends State<ScrubBar> {
  double? _drag;

  double get _total => widget.duration.inMilliseconds.toDouble();

  double _fraction(Duration d) => _total <= 0 ? 0 : (d.inMilliseconds / _total).clamp(0, 1);

  void _update(Offset local, double width) => setState(() => _drag = (local.dx / width).clamp(0, 1));

  Duration _clamp(Duration d) => d < Duration.zero ? Duration.zero : (d > widget.duration ? widget.duration : d);

  Duration _at(double f) => Duration(milliseconds: (f * _total).round());

  @override
  Widget build(BuildContext context) {
    final played = _drag ?? (widget.scrubbing != null ? _fraction(widget.scrubbing!) : _fraction(widget.position));
    final shown = _drag != null ? _at(_drag!) : (widget.scrubbing ?? widget.position);
    final remaining = widget.duration - shown;
    final time = OxTypography.en.time.copyWith(fontSize: 12, color: OxColors.text1);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        spacing: 14,
        children: [
          Text(Fmt.position(shown), style: time),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                final bubble = _drag != null || widget.scrubbing != null;
                return Semantics(
                  slider: true,
                  label: context.l10n.a11ySeek,
                  value: Fmt.position(shown),
                  increasedValue: Fmt.position(_clamp(shown + const Duration(seconds: 10))),
                  decreasedValue: Fmt.position(_clamp(shown - const Duration(seconds: 10))),
                  onIncrease: () => widget.onSeek(widget.position + const Duration(seconds: 10)),
                  onDecrease: () => widget.onSeek(widget.position - const Duration(seconds: 10)),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragStart: (d) {
                      widget.onScrubStart?.call();
                      _update(d.localPosition, w);
                    },
                    onHorizontalDragUpdate: (d) => _update(d.localPosition, w),
                    onHorizontalDragEnd: (_) {
                      if (_drag != null) widget.onSeek(_at(_drag!));
                      setState(() => _drag = null);
                      widget.onScrubEnd?.call();
                    },
                    onTapUp: (d) => widget.onSeek(_at((d.localPosition.dx / w).clamp(0, 1))),
                    child: SizedBox(
                      height: 28,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.centerLeft,
                        children: [
                          _bar(w, 1, const Color(0x33FFFFFF)),
                          _bar(w, _fraction(widget.buffered), const Color(0x61FFFFFF)),
                          _bar(w, played, OxColors.ember, glow: true),
                          Positioned(
                            left: played * w - 8,
                            child: AnimatedScale(
                              duration: OxMotion.fast,
                              scale: _drag != null ? 1.25 : 1,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFFFFFFF),
                                  boxShadow: [BoxShadow(color: Color(0x59FF7A3D), spreadRadius: 5)],
                                ),
                              ),
                            ),
                          ),
                          if (bubble)
                            Positioned(
                              left: (played * w - 40).clamp(-14.0, w - 66),
                              bottom: 30,
                              child: Container(
                                width: 80,
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0x99000000),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: OxColors.text1, width: 1.5),
                                ),
                                child: Text(Fmt.position(shown), style: time.copyWith(fontSize: 12.5, fontWeight: FontWeight.w700)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Text('-${Fmt.position(remaining.isNegative ? Duration.zero : remaining)}', style: time.copyWith(color: OxColors.text2)),
        ],
      ),
    );
  }

  Widget _bar(double w, double f, Color color, {bool glow = false}) => Container(
        width: (w * f).clamp(0, w),
        height: 4,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          boxShadow: glow ? const [BoxShadow(color: Color(0x99FF7A3D), blurRadius: 10)] : null,
        ),
      );
}

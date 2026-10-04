import 'package:flutter/material.dart';

import '../../core/design/design.dart';
import 'pressable.dart';

/// `.switch` — 46 × 28 track, 22 dp knob, spring travel (240 ms).
/// The knob sits at the inline start when off, so it mirrors in RTL.
class OxSwitch extends StatelessWidget {
  const OxSwitch({super.key, required this.value, required this.onChanged, this.semanticLabel});

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final curve = context.reduceMotion ? OxMotion.easeOut : OxMotion.spring;
    return OxPressable.builder(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      semanticLabel: semanticLabel,
      toggled: value,
      isButton: false,
      pressedScale: 1,
      // Pad the 28 dp track to a 44 dp touch target without changing layout height much.
      builder: (context, s) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: AnimatedContainer(
          duration: OxMotion.base,
          curve: OxMotion.easeOut,
          width: 46,
          height: 28,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: value ? OxColors.ember : OxColors.ink5,
            borderRadius: BorderRadius.circular(OxRadius.pill),
            boxShadow: s.focused ? oxFocusRing : null,
          ),
          child: AnimatedAlign(
            duration: OxMotion.base,
            curve: curve,
            alignment: value ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
            child: AnimatedContainer(
              duration: OxMotion.base,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: value ? const Color(0xFFFFFFFF) : OxColors.switchKnob,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One option of an [OxSegmented].
@immutable
class OxSegment<T> {
  const OxSegment(this.value, this.label, {this.icon});

  final T value;
  final String label;
  final OxIcons? icon;
}

/// `.seg` — equal-width segmented control (Xtream / M3U / File).
class OxSegmented<T> extends StatelessWidget {
  const OxSegmented({super.key, required this.segments, required this.selected, required this.onChanged});

  final List<OxSegment<T>> segments;
  final T selected;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    final type = context.oxText;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: OxColors.ink3,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OxColors.line),
      ),
      child: Row(
        spacing: 4,
        children: [
          for (final seg in segments)
            Expanded(
              child: OxPressable.builder(
                onTap: onChanged == null ? null : () => onChanged!(seg.value),
                selected: seg.value == selected,
                pressedScale: 1,
                builder: (context, s) {
                  final on = seg.value == selected;
                  final fg = on ? OxColors.text1 : OxColors.text2;
                  return AnimatedContainer(
                    duration: OxMotion.base,
                    curve: OxMotion.easeOut,
                    height: 38,
                    decoration: BoxDecoration(
                      color: on ? OxColors.ink5 : const Color(0x00000000),
                      borderRadius: BorderRadius.circular(OxRadius.sm),
                      boxShadow: [
                        if (on) const BoxShadow(color: Color(0x59000000), blurRadius: 12, offset: Offset(0, 4)),
                        if (s.focused) ...oxFocusRing,
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 6,
                      children: [
                        if (seg.icon != null) OxIcon(seg.icon!, size: OxIconSize.xs, color: fg),
                        Flexible(
                          child: Text(
                            seg.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: type.title.copyWith(fontSize: 13, fontWeight: FontWeight.w800, height: 1.2, color: fg),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// `.tabs` — text tabs with a 3 dp ember underline and a hairline below.
/// Scrolls horizontally only when the labels don't fit (long Arabic labels,
/// large font scale).
class OxTabs extends StatelessWidget {
  const OxTabs({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
    this.padding = const EdgeInsets.symmetric(horizontal: OxSpace.phoneGutter),
    this.counts,
  });

  final List<String> labels;

  /// Optional count after each label, in Text 3 ("Channels 12").
  final List<int?>? counts;
  final int index;
  final ValueChanged<int>? onChanged;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final type = context.oxText;
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 22,
      children: [
        for (var i = 0; i < labels.length; i++)
          OxPressable.builder(
            onTap: onChanged == null ? null : () => onChanged!(i),
            selected: i == index,
            pressedScale: 1,
            builder: (context, s) {
              final on = i == index;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 14),
                    child: AnimatedDefaultTextStyle(
                      duration: OxMotion.base,
                      style: type.title.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                        color: on || s.highlighted ? OxColors.text1 : OxColors.text3,
                      ),
                      child: Text.rich(TextSpan(children: [
                        TextSpan(text: labels[i]),
                        if (counts?[i] case final n?) TextSpan(text: '  $n', style: const TextStyle(color: OxColors.text3)),
                      ])),
                    ),
                  ),
                  PositionedDirectional(
                    start: 0,
                    end: 0,
                    bottom: -1,
                    child: AnimatedScale(
                      duration: OxMotion.base,
                      curve: OxMotion.easeOut,
                      scale: on ? 1 : 0,
                      child: Container(
                        height: 3,
                        decoration: const BoxDecoration(
                          color: OxColors.ember,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(3)),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );

    return DecoratedBox(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: OxColors.line))),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: SingleChildScrollView(scrollDirection: Axis.horizontal, padding: padding, child: row),
      ),
    );
  }
}

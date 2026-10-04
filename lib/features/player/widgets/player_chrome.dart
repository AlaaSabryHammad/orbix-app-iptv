import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/design/design.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/settings/app_settings.dart';
import '../../../shared/widgets/widgets.dart';

/// Player chrome text is always white on video.
const _white = Color(0xFFFFFFFF);

/// Glass-looking surface for use over video: no backdrop blur. Re-blurring
/// a frame that changes 30–60 times a second saturates mid-range GPUs at
/// tablet resolutions (input and timers then stall), so the "glass" here is a
/// denser translucent fill with the glass border.
class VideoGlass extends StatelessWidget {
  const VideoGlass({super.key, required this.child, this.borderRadius = BorderRadius.zero, this.shadows, this.padding});

  final Widget child;
  final BorderRadius borderRadius;
  final List<BoxShadow>? shadows;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: const Color(0xD9121218),
      borderRadius: borderRadius,
      border: Border.all(color: OxColors.glassBorder),
      boxShadow: shadows,
    ),
    child: child,
  );
}

/// `.ibtn` on video — 44 dp, white glyph, optional glass.
class PlayerIconButton extends StatelessWidget {
  const PlayerIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.size = 44,
    this.iconSize = OxIconSize.md,
    this.glass = false,
    this.opacity = 1,
    this.color,
  });

  final OxIcons icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final bool glass;
  final double opacity;
  final Color? color;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: onPressed == null ? 0.4 : opacity,
    child: OxPressable.builder(
      onTap: onPressed,
      semanticLabel: semanticLabel,
      pressedScale: 0.92,
      builder: (context, s) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: glass ? const Color(0x24FFFFFF) : (s.pressed || s.hovered ? const Color(0x14FFFFFF) : null),
          border: glass ? Border.all(color: const Color(0x33FFFFFF)) : null,
          boxShadow: s.focused ? oxFocusRing : null,
        ),
        child: OxIcon(icon, size: iconSize, color: color ?? _white),
      ),
    ),
  );
}

/// The big glass play / pause button.
class PlayPauseButton extends StatelessWidget {
  const PlayPauseButton({super.key, required this.playing, required this.onPressed, this.size = 76});

  final bool playing;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return OxPressable.builder(
      onTap: onPressed,
      semanticLabel: playing ? l.a11yPause : l.a11yPlay,
      pressedScale: 0.94,
      builder: (context, s) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0x24FFFFFF),
          border: Border.all(color: const Color(0x40FFFFFF)),
          boxShadow: [
            const BoxShadow(color: Color(0x0AFFFFFF), spreadRadius: 10),
            if (s.focused) ...oxFocusRing,
          ],
        ),
        child: AnimatedSwitcher(
          duration: OxMotion.fast,
          child: OxIcon(playing ? OxIcons.pause : OxIcons.play, key: ValueKey(playing), size: OxIconSize.xl, color: _white),
        ),
      ),
    );
  }
}

/// `.chip.chip-sm` on video (Fit · 1.0× · 4K · English).
class PlayerChip extends StatelessWidget {
  const PlayerChip({super.key, required this.label, this.icon, this.iconColor, this.selected = false, this.onTap});

  final String label;
  final OxIcons? icon;
  final Color? iconColor;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => OxPressable.builder(
    onTap: onTap,
    selected: selected,
    semanticLabel: label,
    builder: (context, s) => Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: selected ? OxColors.text1 : const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(OxRadius.pill),
        border: Border.all(color: selected ? OxColors.text1 : const Color(0x24FFFFFF)),
        boxShadow: s.focused ? oxFocusRing : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          if (icon != null) OxIcon(icon!, size: OxIconSize.xs, color: iconColor ?? (selected ? OxColors.onChipOn : _white)),
          Text(
            label,
            style: context.oxText.small.copyWith(fontSize: 12, fontWeight: FontWeight.w800, color: selected ? OxColors.onChipOn : _white),
          ),
        ],
      ),
    ),
  );
}

/// Brightness / volume pill shown while dragging (44 × 150 glass).
class LevelPill extends StatelessWidget {
  const LevelPill({super.key, required this.icon, required this.value, required this.color, required this.label});

  final OxIcons icon;

  /// 0…1.
  final double value;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    value: '${(value * 100).round()}',
    child: VideoGlass(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        width: 44,
        height: 150,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            spacing: 10,
            children: [
              OxIcon(icon, size: OxIconSize.sm, color: OxColors.text1),
              Expanded(
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(color: const Color(0x33FFFFFF), borderRadius: BorderRadius.circular(4)),
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: value.clamp(0, 1),
                    child: Container(
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
              ),
              Text('${(value * 100).round()}', style: OxTypography.en.time.copyWith(fontSize: 10, color: OxColors.text1)),
            ],
          ),
        ),
      ),
    ),
  );
}

/// "−10 s" / "+10 s" bubble after a double-tap seek.
class SeekBadge extends StatelessWidget {
  const SeekBadge({super.key, required this.forward, required this.seconds});

  final bool forward;
  final int seconds;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      width: 96,
      height: 96,
      alignment: Alignment.center,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x33FFFFFF)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          OxIcon(forward ? OxIcons.fwd : OxIcons.rew, size: OxIconSize.lg, color: _white),
          Text(
            forward ? l.seekForwardLabel(seconds) : l.seekBackLabel(seconds),
            textDirection: TextDirection.ltr,
            style: OxTypography.en.time.copyWith(fontSize: 12, fontWeight: FontWeight.w700, color: _white),
          ),
        ],
      ),
    );
  }
}

/// Subtitles drawn by Orbix (not media_kit): each line takes its own
/// direction, so Arabic lines read right-to-left; size and style follow
/// Settings › Subtitle settings; they rise above the controls.
class SubtitleOverlay extends StatelessWidget {
  const SubtitleOverlay({super.key, required this.lines, required this.size, required this.style, required this.bottom, this.end = 0, this.side = 24});

  final List<String> lines;
  final SubtitleSize size;
  final SubtitleStyle style;
  final double bottom;

  /// Room kept clear on the end side (live channel list).
  final double end;

  /// Side margin (smaller in picture-in-picture).
  final double side;

  @override
  Widget build(BuildContext context) {
    final text = lines.map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    return LayoutBuilder(
      builder: (context, c) {
        final h = math.min(c.maxHeight, c.maxWidth);
        final fontSize =
            h *
            switch (size) {
              SubtitleSize.small => 0.036,
              SubtitleSize.medium => 0.044,
              SubtitleSize.large => 0.054,
            };
        final base = TextStyle(
          fontFamily: OxFonts.ui,
          fontFamilyFallback: const [OxFonts.arabic],
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          height: 1.3,
          color: _white,
          shadows: switch (style) {
            SubtitleStyle.outline => [
              for (final o in const [
                Offset(-1.5, -1.5),
                Offset(1.5, -1.5),
                Offset(-1.5, 1.5),
                Offset(1.5, 1.5),
                Offset(0, 2),
                Offset(0, -2),
                Offset(2, 0),
                Offset(-2, 0),
              ])
                Shadow(color: const Color(0xFF000000), offset: o),
            ],
            SubtitleStyle.shadow => const [Shadow(color: Color(0xE6000000), blurRadius: 6, offset: Offset(0, 2))],
            SubtitleStyle.box => null,
          },
        );
        return AnimatedPadding(
          duration: OxMotion.base,
          curve: OxMotion.easeOut,
          padding: EdgeInsetsDirectional.fromSTEB(side, 0, side + end, bottom),
          // Tiny windows (picture-in-picture) clip the oldest line, never overflow.
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.bottomCenter,
              minHeight: 0,
              maxHeight: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final line in text)
                    Container(
                      padding: style == SubtitleStyle.box ? const EdgeInsets.symmetric(horizontal: 8, vertical: 1) : null,
                      color: style == SubtitleStyle.box ? const Color(0xB3000000) : null,
                      child: Text(line, textAlign: TextAlign.center, textDirection: oxDirectionOf(line), style: base),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

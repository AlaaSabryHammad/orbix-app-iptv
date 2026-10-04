import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../core/design/design.dart';
import '../../core/l10n/l10n.dart';
import 'image.dart';
import 'pressable.dart';
import 'progress.dart';

/// `.poster` — 2:3 artwork card, radius 14.
///
/// Hover/focus: lift 4 dp + scale 1.03 (focus adds the 2 dp warm-white ring);
/// press: scale .97. Locked posters blur and dim the art behind a PIN tile.
class OxPoster extends StatelessWidget {
  const OxPoster({
    super.key,
    required this.image,
    this.title,
    this.width,
    this.badges = const [],
    this.topEnd,
    this.progress,
    this.locked = false,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
    this.titleSize = 13,
  });

  final String? image;

  /// Printed on the art over a bottom shade (`.ptitle`) — for posters
  /// without baked-in titles.
  final String? title;

  /// Null = fill the parent's width.
  final double? width;

  /// Top-start badge stack (`.tl`).
  final List<Widget> badges;

  /// Top-end slot (`.tr`), e.g. a favourite heart.
  final Widget? topEnd;

  /// Watch progress 0…1, drawn 6 dp from the bottom edge.
  final double? progress;
  final bool locked;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? semanticLabel;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    final type = context.oxText;
    final radius = BorderRadius.circular(OxRadius.md);
    final reduce = context.reduceMotion;

    Widget art = OxImage(image);
    if (locked) {
      art = ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: ColorFiltered(
          colorFilter: const ColorFilter.mode(Color(0x80000000), BlendMode.darken),
          child: art,
        ),
      );
    }

    final card = Stack(
      fit: StackFit.expand,
      children: [
        art,
        if (title != null) ...[
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x00000000), Color(0xD1000000)],
                stops: [0.45, 1],
              ),
            ),
          ),
          PositionedDirectional(
            start: 10,
            end: 10,
            bottom: 10,
            child: OxContentText(
              type.isArabic ? title! : title!.toUpperCase(),
              maxLines: 3,
              style: type.isArabic
                  ? type.title.copyWith(fontSize: titleSize + 1, height: 1.35, color: const Color(0xFFFFFFFF), shadows: _titleShadow)
                  : OxTypography.en.h1.copyWith(
                      fontSize: titleSize,
                      height: 1.1,
                      letterSpacing: -0.01 * titleSize,
                      color: const Color(0xFFFFFFFF),
                      shadows: _titleShadow,
                    ),
            ),
          ),
        ],
        if (badges.isNotEmpty)
          PositionedDirectional(top: 8, start: 8, child: Row(mainAxisSize: MainAxisSize.min, spacing: 4, children: badges)),
        if (topEnd != null) PositionedDirectional(top: 8, end: 8, child: topEnd!),
        if (progress != null && !locked)
          PositionedDirectional(start: 6, end: 6, bottom: 6, child: OxProgressBar(value: progress!)),
        if (locked)
          Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0x80000000),
                borderRadius: BorderRadius.circular(OxRadius.md),
                border: Border.all(color: const Color(0x66FFC65C)),
              ),
              alignment: Alignment.center,
              child: OxIcon(OxIcons.lock, size: OxIconSize.md, color: OxColors.warn, semanticLabel: context.l10n.a11yLocked),
            ),
          ),
      ],
    );

    return OxPressable.builder(
      onTap: onTap,
      onLongPress: onLongPress,
      semanticLabel: semanticLabel ?? title,
      dimWhenDisabled: false,
      builder: (context, s) {
        final lifted = s.highlighted && !reduce;
        return AnimatedContainer(
          duration: OxMotion.base,
          curve: OxMotion.easeOut,
          width: width,
          transformAlignment: Alignment.center,
          transform: lifted
              ? (Matrix4.translationValues(0, -4, 0)..scaleByDouble(1.03, 1.03, 1, 1))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: OxColors.ink3,
            borderRadius: radius,
            boxShadow: [
              ...(lifted ? OxShadows.posterLift : OxShadows.poster),
              if (s.focused)
                const BoxShadow(color: OxColors.text1, spreadRadius: 2)
              else if (s.hovered)
                const BoxShadow(color: Color(0x1FFFFFFF), spreadRadius: 1),
            ],
          ),
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: ClipRRect(borderRadius: radius, child: card),
          ),
        );
      },
    );
  }

  static const _titleShadow = [Shadow(color: Color(0x99000000), blurRadius: 10, offset: Offset(0, 2))];
}

/// `.thumb` — 16:9 card: episodes, continue watching, live previews.
///
/// Slots are inline-direction aware: [topStart] (LIVE badge), [bottomStart]
/// (channel logo), [center] (play glyph). [progress] sits flush on the
/// bottom edge.
class OxThumb extends StatelessWidget {
  const OxThumb({
    super.key,
    required this.image,
    this.width,
    this.progress,
    this.shade = true,
    this.topStart,
    this.topEnd,
    this.bottomStart,
    this.bottomEnd,
    this.center,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
    this.art,
    this.radius = OxRadius.md,
  });

  final String? image;

  /// Replaces [image] (e.g. a generated gradient when there is no artwork).
  final Widget? art;
  final double radius;
  final double? width;
  final double? progress;
  final bool shade;
  final Widget? topStart;
  final Widget? topEnd;
  final Widget? bottomStart;
  final Widget? bottomEnd;
  final Widget? center;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(this.radius);
    return OxPressable.builder(
      onTap: onTap,
      onLongPress: onLongPress,
      semanticLabel: semanticLabel,
      dimWhenDisabled: false,
      builder: (context, s) => AnimatedContainer(
        duration: OxMotion.base,
        width: width,
        decoration: BoxDecoration(
          color: OxColors.ink3,
          borderRadius: radius,
          boxShadow: s.focused ? const [BoxShadow(color: OxColors.text1, spreadRadius: 2)] : null,
        ),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                art ?? OxImage(image),
                if (shade)
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00000000), Color(0xBF000000)],
                        stops: [0.4, 1],
                      ),
                    ),
                  ),
                if (center != null) Center(child: center),
                if (topStart != null) PositionedDirectional(top: 8, start: 8, child: topStart!),
                if (topEnd != null) PositionedDirectional(top: 8, end: 8, child: topEnd!),
                if (bottomStart != null) PositionedDirectional(bottom: 8, start: 8, child: bottomStart!),
                if (bottomEnd != null) PositionedDirectional(bottom: 10, end: 10, child: bottomEnd!),
                if (progress != null)
                  PositionedDirectional(start: 0, end: 0, bottom: 0, child: OxProgressBar(value: progress!, flush: true)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/design/design.dart';
import '../../core/l10n/l10n.dart';
import 'badges.dart';
import 'image.dart';
import 'pressable.dart';
import 'progress.dart';

/// `.chlogo` — channel logo tile (48 dp default).
///
/// Shows [logoUrl] when the playlist has one; otherwise initials on a gradient
/// derived from the channel name, so a channel keeps the same colours
/// everywhere. Initials follow the design: "Pulse Sports 1" → P1,
/// "Meridian News" → MN.
class OxChannelLogo extends StatelessWidget {
  const OxChannelLogo({super.key, required this.name, this.logoUrl, this.size = OxSize.channelLogo, this.colors, this.initials});

  final String name;
  final String? logoUrl;
  final double size;

  /// Explicit gradient (145°); default picks from [palette] by name.
  final List<Color>? colors;
  final String? initials;

  /// The gradients used across the HTML specs.
  static const palette = <List<Color>>[
    [Color(0xFF2F7DFF), Color(0xFF13306B)],
    [Color(0xFF2FBF71), Color(0xFF0E4A2B)],
    [Color(0xFF1FA88A), Color(0xFF0B3A33)],
    [Color(0xFFFF7A3D), Color(0xFF6B1E05)],
    [Color(0xFF4FD1C5), Color(0xFF0F4C4A)],
    [Color(0xFFFFB547), Color(0xFF7A4A0B)],
    [Color(0xFFE2508F), Color(0xFF4E1235)],
    [Color(0xFF8B6CFF), Color(0xFF2B1A6B)],
  ];

  static String initialsOf(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '';
    String first(String w) => String.fromCharCode(w.runes.first).toUpperCase();
    final last = words.last;
    if (words.length > 1 && RegExp(r'^\d{1,2}$').hasMatch(last)) return first(words.first) + last;
    if (words.length > 1) return first(words[0]) + first(words[1]);
    final w = words.first;
    return w.runes.length > 1 ? (first(w) + String.fromCharCode(w.runes.elementAt(1))).toUpperCase() : first(w);
  }

  static List<Color> gradientFor(String name) {
    var h = 0;
    for (final c in name.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return palette[h % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size >= 40 ? 12 : size * 0.27);
    final hasLogo = logoUrl != null && logoUrl!.isNotEmpty;
    final g = colors ?? gradientFor(name);

    final initialsText = Center(
      child: Text(
        initials ?? initialsOf(name),
        maxLines: 1,
        textDirection: TextDirection.ltr,
        style: OxTypography.en.h1.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: size * 0.27,
          letterSpacing: -0.02 * size * 0.27,
          height: 1,
          color: const Color(0xFFFFFFFF),
          fontFamilyFallback: const [OxFonts.arabic],
        ),
      ),
    );

    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: const Color(0x1AFFFFFF)),
          gradient: LinearGradient(
            // 145° CSS ≈ top-start → bottom-end, slightly steep.
            begin: const Alignment(-0.6, -1),
            end: const Alignment(0.6, 1),
            colors: hasLogo ? const [Color(0x24FFFFFF), Color(0x05FFFFFF)] : g,
          ),
        ),
        child: hasLogo
            ? Padding(
                padding: EdgeInsets.all(size * 0.14),
                child: OxImage(logoUrl, fit: BoxFit.contain, fallback: initialsText),
              )
            : initialsText,
      ),
    );
  }
}

/// A channel in the Live TV list — 66 dp row (LiveTV spec).
///
/// [nowPlaying] tints the row, adds the ember start bar, the equalizer and an
/// ember programme title. [locked] adds the PIN badge.
class OxChannelRow extends StatelessWidget {
  const OxChannelRow({
    super.key,
    required this.number,
    required this.name,
    this.logoUrl,
    this.logoColors,
    this.quality,
    this.programme,
    this.progress,
    this.nowPlaying = false,
    this.locked = false,
    this.favorite = false,
    this.onTap,
    this.onLongPress,
    this.onFavoriteTap,
  });

  final String number;
  final String name;
  final String? logoUrl;
  final List<Color>? logoColors;
  final String? quality;

  /// Current programme ("Coastal FC vs Northern United · 20:00–22:00").
  final String? programme;
  final double? progress;
  final bool nowPlaying;
  final bool locked;
  final bool favorite;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final type = context.oxText;
    final l = context.l10n;

    return Semantics(
      container: true,
      label: [number, name, ?programme, if (nowPlaying) l.a11yNowPlaying, if (locked) l.a11yLocked].join(', '),
      child: OxPressable.builder(
        onTap: onTap,
        onLongPress: onLongPress,
        pressedScale: 0.985,
        dimWhenDisabled: false,
        builder: (context, s) => AnimatedContainer(
          duration: OxMotion.base,
          height: 66,
          decoration: BoxDecoration(
            color: nowPlaying
                ? const Color(0x1AFF7A3D)
                : (s.highlighted || s.pressed ? OxColors.glassLite.withValues(alpha: 0.05) : const Color(0x00000000)),
            borderRadius: BorderRadius.circular(16),
            boxShadow: s.focused ? oxFocusRing : null,
          ),
          child: Stack(
            children: [
              if (nowPlaying)
                PositionedDirectional(
                  start: 0,
                  top: 16,
                  bottom: 16,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(color: OxColors.ember, borderRadius: BorderRadius.circular(3)),
                  ),
                ),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 10),
                child: Row(
                  spacing: 12,
                  children: [
                    SizedBox(
                      width: 26,
                      // 3-digit numbers run a hair past 26 dp, as in the HTML — never wrap.
                      child: Text(
                        number,
                        textDirection: TextDirection.ltr,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.visible,
                        style: OxTypography.en.time.copyWith(fontSize: 11.5, color: OxColors.text3),
                      ),
                    ),
                    OxChannelLogo(name: name, logoUrl: logoUrl, colors: logoColors, size: 42),
                    Expanded(
                      child: ExcludeSemantics(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 5,
                          children: [
                            Row(
                              spacing: 6,
                              children: [
                                Flexible(child: OxContentText(name, style: type.title.copyWith(fontSize: 14, height: 1.2))),
                                if (quality != null) OxBadge.quality(quality!, dense: true),
                                if (nowPlaying) const OxEqualizer(),
                                if (locked) OxBadge.pin(context, dense: true),
                              ],
                            ),
                            Row(
                              spacing: 8,
                              children: [
                                Expanded(
                                  child: OxContentText(
                                    programme ?? '',
                                    style: type.caption.copyWith(color: nowPlaying ? OxColors.emberHi : OxColors.text3, height: 1.2),
                                  ),
                                ),
                                if (progress != null) SizedBox(width: 48, child: OxProgressBar(value: progress!)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 44 dp hit target; the glyph stays where the 18 dp icon sits in the spec.
                    OxPressable(
                      onTap: onFavoriteTap,
                      semanticLabel: favorite ? l.a11yRemoveFavorite : l.a11yAddFavorite,
                      toggled: favorite,
                      dimWhenDisabled: false,
                      pressedScale: 0.85,
                      child: SizedBox(
                        width: 44,
                        height: 66,
                        child: Center(
                          child: OxIcon(
                            favorite ? OxIcons.heartFill : OxIcons.heart,
                            size: OxIconSize.sm,
                            color: favorite ? OxColors.ember : const Color(0xFF5C5966),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Channel tile — 96 × 112 grid cell (Components C4).
class OxChannelTile extends StatelessWidget {
  const OxChannelTile({super.key, required this.name, this.logoUrl, this.logoColors, this.onTap, this.width = 96});

  final String name;
  final String? logoUrl;
  final List<Color>? logoColors;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return OxPressable.builder(
      onTap: onTap,
      semanticLabel: name,
      dimWhenDisabled: false,
      builder: (context, s) => AnimatedContainer(
        duration: OxMotion.base,
        width: width,
        height: 112,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: s.highlighted ? OxColors.ink3 : OxColors.ink2,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: OxColors.line),
          boxShadow: s.focused ? oxFocusRing : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            OxChannelLogo(name: name, logoUrl: logoUrl, colors: logoColors),
            ExcludeSemantics(
              child: OxContentText(name, align: TextAlign.center, style: context.oxText.caption),
            ),
          ],
        ),
      ),
    );
  }
}

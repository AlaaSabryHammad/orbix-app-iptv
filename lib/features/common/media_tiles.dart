import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/design.dart';
import '../../core/l10n/l10n.dart';
import '../../data/data.dart';
import '../../shared/format/format.dart';
import '../../shared/widgets/widgets.dart';
import 'navigation.dart';
import 'providers.dart';

/// "Continue watching" card — 16:9 still, glass play glyph, flush progress,
/// title + "S3 · E4 · 18 min left".
class ContinueCard extends ConsumerWidget {
  const ContinueCard({super.key, required this.item, this.width = 232, this.compactText = false});

  final ContinueItem item;
  final double width;
  final bool compactText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.oxText;
    final ep = item.episode;
    final movie = item.movie;
    final title = ep != null ? (item.show?.name ?? ep.title) : (movie?.name ?? '');
    final left = Fmt.left(context.l10n, item.remaining);
    final sub = ep != null ? '${context.l10n.episodeShort(ep.season, ep.episode)} · $left' : left;
    final backdrop = movie == null ? null : ref.watch(movieDetailsProvider(movie.id)).value?.backdrop;
    final image = ep?.still ?? item.show?.backdrop ?? backdrop ?? movie?.poster ?? item.show?.cover;

    void open() => ep != null ? context.playEpisode(ep.seriesId, ep.id) : context.playMovie(item.progress.itemId);

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          OxThumb(
            image: image,
            progress: item.fraction,
            onTap: open,
            semanticLabel: '$title, $sub',
            bottomStart: Padding(
              padding: const EdgeInsetsDirectional.only(start: 4, bottom: 6),
              child: OxGlass(
                lite: true,
                borderRadius: BorderRadius.circular(17),
                color: const Color(0x2EFFFFFF),
                borderColor: const Color(0x00000000),
                child: const SizedBox.square(
                  dimension: 34,
                  child: Padding(padding: EdgeInsets.only(left: 2), child: Center(child: OxIcon(OxIcons.play, size: OxIconSize.sm))),
                ),
              ),
            ),
          ),
          ExcludeSemantics(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OxContentText(title, style: t.title.copyWith(fontSize: 14)),
                      Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.caption),
                    ],
                  ),
                ),
                if (!compactText) const Padding(padding: EdgeInsets.only(top: 2), child: OxIcon(OxIcons.more, size: OxIconSize.sm, color: OxColors.text3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Programme artwork, else a soft gradient from the channel's colours.
Widget liveArtwork(LiveItem item) {
  final img = item.nowNext?.now?.image;
  if (img != null) return OxImage(img);
  final g = OxChannelLogo.gradientFor(item.channel.name);
  return DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [g.first.withValues(alpha: 0.55), OxColors.ink2]),
    ),
  );
}

/// "Live now" card (Home) — artwork, LIVE, channel logo, time range; programme
/// title and channel with progress below.
class LiveCard extends ConsumerWidget {
  const LiveCard({super.key, required this.item, this.width = 232});

  final LiveItem item;
  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.oxText;
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final p = item.nowNext?.now;
    final title = p?.title ?? item.channel.name;
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          OxThumb(
            image: null,
            art: liveArtwork(item),
            onTap: () => context.playChannel(item.channel.id),
            semanticLabel: '${item.channel.name}, $title',
            topStart: Padding(padding: const EdgeInsetsDirectional.only(start: 2, top: 2), child: OxBadge.live(context)),
            bottomStart: Padding(
              padding: const EdgeInsetsDirectional.only(start: 2, bottom: 2),
              child: OxChannelLogo(name: item.channel.name, logoUrl: item.channel.logo, size: 38),
            ),
            bottomEnd: p == null
                ? null
                : Text(Fmt.range(p.start, p.stop), textDirection: TextDirection.ltr, style: OxTypography.en.time.copyWith(fontSize: 11)),
          ),
          ExcludeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                OxContentText(title, style: t.title.copyWith(fontSize: 14)),
                Row(
                  spacing: 8,
                  children: [
                    Flexible(child: OxContentText(item.channel.name, style: t.caption)),
                    if (p != null) Expanded(child: OxProgressBar(value: item.nowNext!.progressAt(now))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Poster with caption lines below (Popular movies / series).
class PosterTile extends StatelessWidget {
  const PosterTile({
    super.key,
    required this.image,
    required this.title,
    required this.onTap,
    this.width = OxSize.posterRail,
    this.subtitle,
    this.rating,
    this.badges = const [],
    this.titleOnPoster = false,
    this.showCaptionTitle = true,
  });

  final String? image;
  final String title;
  final VoidCallback onTap;
  final double width;
  final String? subtitle;
  final double? rating;
  final List<Widget> badges;

  /// Print the title on the art (posters without baked-in titles).
  final bool titleOnPoster;
  final bool showCaptionTitle;

  @override
  Widget build(BuildContext context) {
    final t = context.oxText;
    final hasCaption = showCaptionTitle || subtitle != null || rating != null;
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          OxPoster(image: image, title: titleOnPoster ? title : null, titleSize: 12, badges: badges, onTap: onTap, semanticLabel: title),
          if (hasCaption)
            ExcludeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showCaptionTitle) OxContentText(title, style: t.title.copyWith(fontSize: 13)),
                  if (subtitle != null || rating != null)
                    Row(
                      spacing: 6,
                      children: [
                        if (subtitle != null) Flexible(child: Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.caption.copyWith(color: OxColors.text2))),
                        if (rating != null) _SmallRating(rating!),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SmallRating extends StatelessWidget {
  const _SmallRating(this.value);

  final double value;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          const OxIcon(OxIcons.star, size: 13, color: OxColors.ember),
          Text(value.toStringAsFixed(1), style: context.oxText.caption.copyWith(fontWeight: FontWeight.w800, color: OxColors.text1)),
        ],
      );
}

/// Wide 16:9 card with the title printed on it (Recommended).
class WideCard extends StatelessWidget {
  const WideCard({super.key, required this.image, required this.title, required this.caption, required this.onTap, this.width = 272});

  final String? image;
  final String title;
  final String caption;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final t = context.oxText;
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          OxPressable(
            onTap: onTap,
            semanticLabel: title,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    OxImage(image),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xCC000000), Color(0x00000000)], stops: [0, 0.6]),
                      ),
                    ),
                    PositionedDirectional(
                      start: 14,
                      end: 14,
                      bottom: 12,
                      child: OxContentText(
                        t.isArabic ? title : title.toUpperCase(),
                        style: t.isArabic ? t.title.copyWith(fontSize: 17) : OxTypography.en.h1.copyWith(fontSize: 17, letterSpacing: -0.17),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            spacing: 6,
            children: [
              const OxIcon(OxIcons.trending, size: OxIconSize.xs, color: OxColors.emberHi),
              Expanded(child: Text(caption, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.caption)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Favorite channel tile (Home › Your favorites) — 104 × 120.
class FavoriteChannelTile extends StatelessWidget {
  const FavoriteChannelTile({super.key, required this.channel});

  final Channel channel;

  @override
  Widget build(BuildContext context) => OxPressable(
        onTap: () => context.playChannel(channel.id),
        semanticLabel: channel.name,
        child: Container(
          width: 104,
          height: 120,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(color: OxColors.ink2, borderRadius: BorderRadius.circular(18), border: Border.all(color: OxColors.line)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              OxChannelLogo(name: channel.name, logoUrl: channel.logo, size: 52),
              OxContentText(channel.name, align: TextAlign.center, style: context.oxText.caption.copyWith(color: OxColors.text2)),
            ],
          ),
        ),
      );
}

/// "NEW" if added within 30 days.
bool isNew(DateTime? addedAt) => addedAt != null && DateTime.now().difference(addedAt) < const Duration(days: 30);

/// Section scaffold for rails: header + horizontal list, hidden when empty.
class RailSection extends StatelessWidget {
  const RailSection({
    super.key,
    required this.title,
    required this.itemCount,
    required this.itemBuilder,
    required this.height,
    this.leading,
    this.actionLabel,
    this.onAction,
    this.gap = 12,
    this.gutter = OxSpace.phoneGutter,
    this.titleSize,
  });

  final String title;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double height;
  final Widget? leading;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double gap;
  final double gutter;
  final double? titleSize;

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OxSectionHeader(
          title: title,
          leading: leading,
          actionLabel: actionLabel,
          onAction: onAction,
          padding: EdgeInsets.symmetric(horizontal: gutter),
        ),
        SizedBox(height: actionLabel == null ? 12 : 2),
        OxRail(
          height: height,
          itemCount: itemCount,
          spacing: gap,
          padding: EdgeInsets.symmetric(horizontal: gutter),
          itemBuilder: itemBuilder,
        ),
      ],
    );
  }
}

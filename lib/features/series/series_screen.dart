import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/design.dart';
import '../../core/l10n/l10n.dart';
import '../../core/session/session.dart';
import '../../data/data.dart';
import '../../shared/format/format.dart';
import '../../shared/widgets/widgets.dart';
import '../common/browse.dart';
import '../common/media_tiles.dart';
import '../common/navigation.dart';
import '../common/providers.dart';

final _seriesListing = StreamProvider.autoDispose.family<List<Show>, (String?, MovieSort)>((ref, args) {
  return ref.watch(catalogRepositoryProvider).watchSeries(ref.watch(activeAccountIdProvider) ?? '', categoryId: args.$1, sort: args.$2);
});

/// 11 Series. "All" shows the curated page; a genre chip (or a sort from
/// the filter button) shows the full listing.
class SeriesScreen extends ConsumerStatefulWidget {
  const SeriesScreen({super.key});

  @override
  ConsumerState<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends ConsumerState<SeriesScreen> {
  String? _category;
  MovieSort? _sort;

  Future<void> _filter() async {
    final l = context.l10n;
    final options = [
      (MovieSort.rating, l.sortRating, OxIcons.star),
      (MovieSort.recentlyAdded, l.sortRecent, OxIcons.history),
      (MovieSort.name, l.sortName, OxIcons.translate),
      (MovieSort.playlist, l.sortPlaylist, OxIcons.list),
    ];
    final picked = await showOxSheet<MovieSort>(
      context,
      title: l.sortTitle,
      builder: (s) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (sort, label, icon) in options)
            OxSheetOption(icon: icon, label: label, selected: _sort == sort, onTap: () => Navigator.pop(s, sort)),
        ],
      ),
    );
    if (picked != null) setState(() => _sort = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final listing = _category != null || _sort != null;
    return Scaffold(
      body: Stack(
        children: [
          const OxAmbient(color: Color(0xFFFFB060), size: Size(360, 280), opacity: 0.12, left: 30, top: 140),
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ScreenHeader(
                  title: l.seriesTitle,
                  actions: [
                    OxIconButton(icon: OxIcons.search, semanticLabel: l.actionSearch, onPressed: context.openSearch),
                    OxIconButton(
                      icon: OxIcons.filter,
                      semanticLabel: l.actionFilter,
                      color: _sort != null ? OxColors.ember : null,
                      onPressed: _filter,
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: CategoryChips(
                  kind: ContentKind.series,
                  selected: _category,
                  onSelected: (c) => setState(() {
                    _category = c;
                    if (c == null) _sort = null;
                  }),
                ),
              ),
              if (listing) _Listing(categoryId: _category, sort: _sort ?? MovieSort.playlist) else SliverToBoxAdapter(
                  child: _Curated(
                    onGenre: (c) => setState(() => _category = c),
                    onSeeAll: (sort) => setState(() => _sort = sort),
                  ),
                ),
              SliverPadding(padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 24)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Listing extends ConsumerWidget {
  const _Listing({required this.categoryId, required this.sort});

  final String? categoryId;
  final MovieSort sort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shows = ref.watch(_seriesListing((categoryId, sort))).value;
    if (shows == null) return const SliverToBoxAdapter(child: SizedBox.shrink());
    if (shows.isEmpty) return const SliverToBoxAdapter(child: EmptyCategory());
    return SliverMainAxisGroup(slivers: [
      const SliverPadding(padding: EdgeInsets.only(top: 18)),
      PosterGridSliver(
        itemCount: shows.length,
        itemBuilder: (context, i) => PosterTile(
          image: shows[i].cover,
          title: shows[i].name,
          subtitle: shows[i].genre,
          rating: shows[i].rating,
          width: double.infinity,
          onTap: () => context.openSeries(shows[i].id),
        ),
      ),
    ]);
  }
}

class _Curated extends ConsumerWidget {
  const _Curated({required this.onGenre, required this.onSeeAll});

  final ValueChanged<String> onGenre;
  final ValueChanged<MovieSort> onSeeAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final g = OxWindowSize.of(context).gutter;
    final popular = ref.watch(popularSeriesProvider).value ?? const [];
    final recent = ref.watch(recentSeriesProvider).value ?? const [];
    final cont = (ref.watch(continueWatchingProvider).value ?? const []).where((c) => c.episode != null).toList();
    final cats = ref.watch(categoriesProvider(ContentKind.series)).value ?? const [];
    final counts = ref.watch(_seriesCounts).value ?? const {};

    // Featured: the series you're in the middle of, else the top rated.
    final featuredShow = cont.firstOrNull?.show ?? popular.firstOrNull;
    final resume = cont.where((c) => c.show?.id == featuredShow?.id).firstOrNull;

    // One backdrop per genre, from its best rated series.
    final genreArt = <String, String?>{};
    for (final s in popular) {
      if (s.categoryId != null && s.backdrop != null) genreArt.putIfAbsent(s.categoryId!, () => s.backdrop);
    }
    final genres = cats.where((c) => (counts[c.id] ?? 0) > 0).take(8).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 30,
        children: [
          if (featuredShow != null) Padding(padding: EdgeInsets.symmetric(horizontal: g), child: _FeaturedSeries(show: featuredShow, resume: resume)),
          RailSection(
            title: l.homeContinue,
            itemCount: cont.length,
            height: 168,
            gutter: g,
            itemBuilder: (context, i) => _EpisodeContinueCard(item: cont[i]),
          ),
          RailSection(
            title: l.popular,
            itemCount: popular.length,
            height: 180,
            gutter: g,
            actionLabel: l.actionSeeAll,
            onAction: () => onSeeAll(MovieSort.rating),
            itemBuilder: (context, i) => SizedBox(
              width: OxSize.posterRail,
              child: OxPoster(
                image: popular[i].cover,
                title: popular[i].name,
                titleSize: 12,
                topEnd: popular[i].rating == null ? null : _RatingChip(popular[i].rating!),
                onTap: () => context.openSeries(popular[i].id),
              ),
            ),
          ),
          RailSection(
            title: l.homeRecentlyAdded,
            itemCount: recent.length,
            height: 180,
            gutter: g,
            actionLabel: l.actionSeeAll,
            onAction: () => onSeeAll(MovieSort.recentlyAdded),
            itemBuilder: (context, i) => SizedBox(
              width: OxSize.posterRail,
              child: OxPoster(
                image: recent[i].cover,
                title: recent[i].name,
                titleSize: 12,
                badges: [if (isNew(recent[i].updatedAt)) OxBadge.fresh(context)],
                onTap: () => context.openSeries(recent[i].id),
              ),
            ),
          ),
          if (genres.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OxSectionHeader(title: l.genres, padding: EdgeInsets.symmetric(horizontal: g)),
                const SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: g),
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final cols = c.maxWidth >= 700 ? 4 : 2;
                      final w = (c.maxWidth - 12 * (cols - 1)) / cols;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final cat in genres)
                            SizedBox(
                              width: w,
                              child: _GenreTile(name: cat.name, count: counts[cat.id] ?? 0, image: genreArt[cat.id], onTap: () => onGenre(cat.id)),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

final _seriesCounts = StreamProvider.autoDispose<Map<String, int>>((ref) {
  return ref.watch(catalogRepositoryProvider).watchCategoryCounts(ref.watch(activeAccountIdProvider) ?? '', ContentKind.series);
});

class _RatingChip extends StatelessWidget {
  const _RatingChip(this.value);

  final double value;

  @override
  Widget build(BuildContext context) => Container(
        height: 22,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(color: const Color(0x8C000000), borderRadius: BorderRadius.circular(6)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            const OxIcon(OxIcons.star, size: 13, color: OxColors.ember),
            Text(value.toStringAsFixed(1), style: context.oxText.caption.copyWith(fontSize: 11, fontWeight: FontWeight.w800, color: OxColors.text1)),
          ],
        ),
      );
}

class _FeaturedSeries extends ConsumerWidget {
  const _FeaturedSeries({required this.show, this.resume});

  final Show show;
  final ContinueItem? resume;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = context.oxText;
    final ep = resume?.episode;
    return OxPressable(
      onTap: () => context.openSeries(show.id),
      semanticLabel: show.name,
      pressedScale: 0.985,
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(color: Color(0x59FFAA5A), blurRadius: 60, spreadRadius: -24, offset: Offset(0, 30)),
            BoxShadow(color: Color(0x0FFFFFFF), spreadRadius: 1),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            fit: StackFit.expand,
            children: [
              OxImage(show.backdrop ?? show.cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xF208080B), Color(0x4008080B), Color(0x0D08080B)],
                    stops: [0, 0.55, 1],
                  ),
                ),
              ),
              if (isNew(show.updatedAt)) PositionedDirectional(start: 18, top: 16, child: OxBadge.fresh(context)),
              PositionedDirectional(
                start: 18,
                end: 18,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    Text(t.overlineText(l.featuredSeries), style: t.overline.copyWith(color: const Color(0xFFFFC879))),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: OxContentText(t.isArabic ? show.name : show.name.toUpperCase(), maxLines: 2, style: t.h1.copyWith(fontSize: 24)),
                    ),
                    OxMetaLine([
                      if (show.rating != null) OxRating(show.rating!.toStringAsFixed(1)),
                      if (show.year != null) '${show.year}',
                      ?show.genre,
                    ]),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        spacing: 10,
                        children: [
                          OxButton(
                            label: ep != null ? l.resumeEpisode(ep.season, ep.episode) : l.actionPlay,
                            icon: OxIcons.play,
                            size: OxButtonSize.sm,
                            onPressed: () => ep != null ? context.playEpisode(show.id, ep.id) : context.openSeries(show.id),
                          ),
                          OxButton(
                            label: l.actionDetails,
                            icon: OxIcons.info,
                            size: OxButtonSize.sm,
                            variant: OxButtonVariant.glass,
                            onPressed: () => context.openSeries(show.id),
                          ),
                        ],
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

/// Series continue card: S·E badge on the still.
class _EpisodeContinueCard extends StatelessWidget {
  const _EpisodeContinueCard({required this.item});

  final ContinueItem item;

  @override
  Widget build(BuildContext context) {
    final t = context.oxText;
    final ep = item.episode!;
    final title = item.show?.name ?? ep.title;
    return SizedBox(
      width: 210,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 9,
        children: [
          OxThumb(
            image: ep.still ?? item.show?.backdrop,
            progress: item.fraction,
            onTap: () => context.playEpisode(ep.seriesId, ep.id),
            semanticLabel: '$title, ${context.l10n.episodeShort(ep.season, ep.episode)}',
            topStart: Padding(
              padding: const EdgeInsetsDirectional.only(start: 2, top: 2),
              child: OxBadge(context.l10n.episodeShort(ep.season, ep.episode), tone: OxBadgeTone.hd),
            ),
          ),
          ExcludeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OxContentText(title, style: t.title.copyWith(fontSize: 14)),
                Text('${ep.title} · ${Fmt.left(context.l10n, item.remaining)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: t.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GenreTile extends StatelessWidget {
  const _GenreTile({required this.name, required this.count, required this.image, required this.onTap});

  final String name;
  final int count;
  final String? image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OxPressable(
        onTap: onTap,
        semanticLabel: name,
        child: SizedBox(
          height: 96,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                OxImage(image, fallback: const ColoredBox(color: OxColors.ink3)),
                const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xD908080B), Color(0x2608080B)]))),
                PositionedDirectional(
                  start: 14,
                  bottom: 12,
                  end: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OxContentText(name, style: context.oxText.isArabic ? context.oxText.title : OxTypography.en.h1.copyWith(fontSize: 15)),
                      Text(context.l10n.seriesCount(count), style: context.oxText.caption.copyWith(color: const Color(0xFFD2CED8))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

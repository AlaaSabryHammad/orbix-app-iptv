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
import '../home/hero_carousel.dart';

final _moviesInCategory = StreamProvider.autoDispose.family<List<Movie>, String>((ref, categoryId) {
  return ref.watch(catalogRepositoryProvider).watchMovies(ref.watch(activeAccountIdProvider) ?? '', categoryId: categoryId);
});

/// 09 Movies. "All" shows the curated page; a genre chip shows the whole
/// category as a grid or list.
class MoviesScreen extends ConsumerStatefulWidget {
  const MoviesScreen({super.key});

  @override
  ConsumerState<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends ConsumerState<MoviesScreen> {
  String? _category;
  bool _grid = true;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bottom = MediaQuery.paddingOf(context).bottom + 24;

    return Scaffold(
      body: Stack(
        children: [
          const OxAmbient(color: Color(0xFFFF8A3D), size: Size(340, 260), opacity: 0.14, left: 40, top: 120),
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ScreenHeader(
                  title: l.moviesTitle,
                  actions: [
                    OxIconButton(icon: OxIcons.search, semanticLabel: l.actionSearch, onPressed: context.openSearch),
                    ViewToggle(grid: _grid, onChanged: (g) => setState(() => _grid = g)),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: CategoryChips(kind: ContentKind.movie, selected: _category, onSelected: (c) => setState(() => _category = c)),
              ),
              if (_category == null) const SliverToBoxAdapter(child: _Curated()) else _CategoryListing(categoryId: _category!, grid: _grid),
              SliverPadding(padding: EdgeInsets.only(bottom: bottom)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryListing extends ConsumerWidget {
  const _CategoryListing({required this.categoryId, required this.grid});

  final String categoryId;
  final bool grid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movies = ref.watch(_moviesInCategory(categoryId)).value;
    if (movies == null) return const SliverToBoxAdapter(child: SizedBox.shrink());
    if (movies.isEmpty) return const SliverToBoxAdapter(child: EmptyCategory());
    const top = SliverPadding(padding: EdgeInsets.only(top: 18));
    if (grid) {
      return SliverMainAxisGroup(slivers: [
        top,
        PosterGridSliver(
          itemCount: movies.length,
          itemBuilder: (context, i) => PosterTile(
            image: movies[i].poster,
            title: movies[i].name,
            subtitle: movies[i].year?.toString(),
            rating: movies[i].rating,
            width: double.infinity,
            onTap: () => context.openMovie(movies[i].id),
          ),
        ),
      ]);
    }
    final g = OxWindowSize.of(context).gutter;
    return SliverMainAxisGroup(slivers: [
      top,
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: g),
        sliver: SliverList.separated(
          itemCount: movies.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) => MovieListCard(movie: movies[i]),
        ),
      ),
    ]);
  }
}

/// The "All" page: featured carousel, trending, top rated, recently added,
/// recommended.
class _Curated extends ConsumerWidget {
  const _Curated();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final featured = ref.watch(heroItemsProvider).value ?? const [];
    final recent = ref.watch(recentMoviesProvider).value ?? const [];
    final popular = ref.watch(popularMoviesProvider).value ?? const [];
    final g = OxWindowSize.of(context).gutter;
    final wide = MediaQuery.sizeOf(context).width >= OxBreakpoints.medium;

    final trending = [...recent.take(12)]..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    final top = popular.take(wide ? 6 : 3).toList();
    final added = recent.take(wide ? 12 : 6).toList();
    final reco = popular.skip(3).take(12).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 30,
        children: [
          if (featured.isNotEmpty) _Featured(items: featured),
          RailSection(
            title: l.trending,
            leading: const OxIcon(OxIcons.trending, size: OxIconSize.md, color: OxColors.ember),
            itemCount: trending.length,
            height: 180,
            gutter: g,
            itemBuilder: (context, i) => SizedBox(
              width: OxSize.posterRail,
              child: OxPoster(image: trending[i].poster, title: trending[i].name, titleSize: 12, onTap: () => context.openMovie(trending[i].id)),
            ),
          ),
          if (top.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OxSectionHeader(title: l.topRated, padding: EdgeInsets.symmetric(horizontal: g)),
                const SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: g),
                  child: wide
                      ? Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [for (final (i, m) in top.indexed) SizedBox(width: 400, child: MovieListCard(movie: m, rank: i + 1))],
                        )
                      : Column(spacing: 10, children: [for (final (i, m) in top.indexed) MovieListCard(movie: m, rank: i + 1)]),
                ),
              ],
            ),
          if (added.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OxSectionHeader(title: l.homeRecentlyAdded, padding: EdgeInsets.symmetric(horizontal: g)),
                const SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: g),
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final cols = posterColumns(c.maxWidth);
                      final w = (c.maxWidth - 12 * (cols - 1)) / cols;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 18,
                        children: [
                          for (final m in added)
                            PosterTile(
                              image: m.poster,
                              title: m.name,
                              subtitle: m.year?.toString(),
                              rating: m.rating,
                              width: w,
                              onTap: () => context.openMovie(m.id),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          RailSection(
            title: l.recommended,
            itemCount: reco.length,
            height: 180,
            gutter: g,
            itemBuilder: (context, i) => SizedBox(
              width: OxSize.posterRail,
              child: OxPoster(image: reco[i].poster, title: reco[i].name, titleSize: 12, onTap: () => context.openMovie(reco[i].id)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Featured carousel: 236 dp cards with the next one peeking.
class _Featured extends StatefulWidget {
  const _Featured({required this.items});

  final List<HeroItem> items;

  @override
  State<_Featured> createState() => _FeaturedState();
}

class _FeaturedState extends State<_Featured> {
  int _page = 0;
  PageController? _pages;

  @override
  void dispose() {
    _pages?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.oxText;
    final g = OxWindowSize.of(context).gutter;
    return LayoutBuilder(
      builder: (context, c) {
        final cardWidth = (c.maxWidth - 2 * g).clamp(0.0, 560.0);
        final fraction = (cardWidth + 12) / c.maxWidth;
        if (_pages == null || (_pages!.viewportFraction - fraction).abs() > 0.001) {
          _pages?.dispose();
          _pages = PageController(viewportFraction: fraction, initialPage: _page);
        }
        return Column(
          spacing: 14,
          children: [
            SizedBox(
              height: 236,
              child: PageView.builder(
                controller: _pages,
                padEnds: false,
                itemCount: widget.items.length,
                onPageChanged: (p) => setState(() => _page = p),
                itemBuilder: (context, i) {
                  final item = widget.items[i];
                  final m = item.movie;
                  return Padding(
                    padding: EdgeInsetsDirectional.only(start: i == 0 ? g : 0, end: 12),
                    child: AnimatedOpacity(
                      duration: OxMotion.base,
                      opacity: i == _page ? 1 : 0.6,
                      child: OxPressable(
                        onTap: () => context.openMovie(m.id),
                        semanticLabel: m.name,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [BoxShadow(color: Color(0x73FF7A3D), blurRadius: 50, spreadRadius: -20, offset: Offset(0, 24))],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                OxImage(item.image),
                                const DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [Color(0xEB08080B), Color(0x3308080B), Color(0x0008080B)],
                                      stops: [0, 0.55, 1],
                                    ),
                                  ),
                                ),
                                PositionedDirectional(
                                  start: 18,
                                  top: 16,
                                  child: Row(spacing: 6, children: [OxBadge(l.featuredBadge, tone: OxBadgeTone.fresh)]),
                                ),
                                PositionedDirectional(
                                  start: 18,
                                  end: 18,
                                  bottom: 16,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    spacing: 12,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          spacing: 6,
                                          children: [
                                            OxContentText(t.isArabic ? m.name : m.name.toUpperCase(), style: t.h1),
                                            OxMetaLine([
                                              if (m.rating != null) OxRating(m.rating!.toStringAsFixed(1)),
                                              if (m.year != null) '${m.year}',
                                              if (item.details?.genre != null) item.details!.genre!.split('·').first.trim(),
                                            ]),
                                          ],
                                        ),
                                      ),
                                      DecoratedBox(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [BoxShadow(color: Color(0xCCFF7A3D), blurRadius: 24, spreadRadius: -6, offset: Offset(0, 10))],
                                        ),
                                        child: OxIconButton(
                                          icon: OxIcons.play,
                                          semanticLabel: l.actionPlay,
                                          variant: OxIconButtonVariant.accent,
                                          round: true,
                                          dimension: 52,
                                          onPressed: () => context.playMovie(m.id),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 5,
              children: [
                for (var i = 0; i < widget.items.length; i++)
                  AnimatedContainer(
                    duration: OxMotion.base,
                    width: i == _page ? 22 : 8,
                    height: 4,
                    decoration: BoxDecoration(color: i == _page ? OxColors.text1 : const Color(0x40FFFFFF), borderRadius: BorderRadius.circular(4)),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Top-rated / list-view row: poster, rank, title, meta, rating, play.
class MovieListCard extends ConsumerWidget {
  const MovieListCard({super.key, required this.movie, this.rank});

  final Movie movie;
  final int? rank;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = context.oxText;
    final d = rank == null ? null : ref.watch(movieDetailsProvider(movie.id)).value;
    return OxPressable(
      onTap: () => context.openMovie(movie.id),
      semanticLabel: movie.name,
      pressedScale: 0.985,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: OxColors.ink2, borderRadius: BorderRadius.circular(18), border: Border.all(color: OxColors.line)),
        child: Row(
          spacing: 14,
          children: [
            SizedBox(
              width: 62,
              child: ClipRRect(borderRadius: BorderRadius.circular(OxRadius.sm), child: AspectRatio(aspectRatio: 2 / 3, child: OxImage(movie.poster))),
            ),
            Expanded(
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 5,
                  children: [
                    Row(
                      spacing: 8,
                      children: [
                        if (rank != null)
                          Text(rank!.toString().padLeft(2, '0'), style: OxTypography.en.time.copyWith(color: OxColors.emberHi)),
                        Expanded(child: OxContentText(movie.name, style: t.title)),
                      ],
                    ),
                    OxMetaLine([
                      if (movie.year != null) '${movie.year}',
                      if (d?.genre != null) d!.genre!.split('·').first.trim(),
                      if (d?.durationSecs != null) Fmt.runtime(context.l10n, Duration(seconds: d!.durationSecs!)),
                    ]),
                    if (movie.rating != null) OxRating(movie.rating!.toStringAsFixed(1)),
                  ],
                ),
              ),
            ),
            OxIconButton(
              icon: OxIcons.play,
              semanticLabel: l.actionPlay,
              variant: OxIconButtonVariant.tonal,
              round: true,
              dimension: 42,
              iconSize: OxIconSize.sm,
              onPressed: () => context.playMovie(movie.id),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/design/design.dart';
import '../../core/l10n/l10n.dart';
import '../../core/router/routes.dart';
import '../../core/session/session.dart';
import '../../data/data.dart';
import '../../shared/format/format.dart';
import '../../shared/widgets/widgets.dart';
import '../accounts/account_avatar.dart';
import '../accounts/sync_controller.dart';
import '../common/media_tiles.dart';
import '../common/navigation.dart';
import '../common/providers.dart';
import 'hero_carousel.dart';

/// 08 Home (phone), 32 small-phone variant, 28 tablet layout.
/// States 01 — first paint, or the first catalog sync still running with
/// nothing to show yet: Home draws skeletons instead of an empty page.
final _homeLoadingProvider = Provider.autoDispose<bool>((ref) {
  final heroes = ref.watch(heroItemsProvider);
  if (heroes.isLoading && !heroes.hasValue) return true;
  if ((heroes.value ?? const []).isNotEmpty) return false;
  final id = ref.watch(activeAccountIdProvider);
  final sync = ref.watch(syncControllerProvider.select((m) => m[id]));
  return sync != null && !sync.catalogDone && sync.catalog.failure == null;
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final layout = width >= OxBreakpoints.expanded
        ? HeroLayout.tablet
        : width < 380
            ? HeroLayout.compact
            : HeroLayout.phone;
    return Scaffold(body: layout == HeroLayout.tablet ? const _TabletHome() : _PhoneHome(compact: layout == HeroLayout.compact));
  }
}

/// Phone + small phone: full-bleed hero with the top bar on it, then rails.
class _PhoneHome extends ConsumerWidget {
  const _PhoneHome({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heroes = ref.watch(heroItemsProvider).value ?? const [];
    final resume = ref.watch(continueWatchingProvider).value ?? const [];
    final size = MediaQuery.sizeOf(context);
    final heroHeight = compact ? 470.0 : (size.height * 0.72).clamp(420.0, 600.0);
    final items = [
      // The small-phone hero leads with what you were watching (CompactHome).
      if (compact && resume.isNotEmpty && resume.first.movie != null) HeroItem(movie: resume.first.movie!, resume: resume.first),
      ...heroes,
    ];

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: heroHeight,
            child: items.isEmpty
                ? Stack(
                    children: [
                      if (ref.watch(_homeLoadingProvider))
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, MediaQuery.paddingOf(context).top + 64, 16, 0),
                          child: const _HeroSkeleton(),
                        ),
                      _TopBar(compact: compact),
                    ],
                  )
                : HeroCarousel(items: items, layout: compact ? HeroLayout.compact : HeroLayout.phone, topBar: _TopBar(compact: compact)),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.only(top: compact ? 18 : 8, bottom: MediaQuery.paddingOf(context).bottom + 24),
          sliver: SliverToBoxAdapter(child: _Rails(compact: compact, gutter: compact ? 16 : OxSpace.phoneGutter)),
        ),
      ],
    );
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final account = ref.watch(activeAccountProvider).value;
    final top = MediaQuery.paddingOf(context).top;
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: Container(
        height: (compact ? 50 : 58) + top,
        padding: EdgeInsetsDirectional.only(start: compact ? 16 : 20, end: compact ? 8 : 12, top: top),
        child: Row(
          spacing: 2,
          children: [
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: OxBrandLockup(markSize: compact ? 24 : 26, fontSize: compact ? 13 : 15),
              ),
            ),
            OxIconButton(icon: OxIcons.search, semanticLabel: l.actionSearch, iconSize: compact ? OxIconSize.md : null, onPressed: context.openSearch),
            if (account != null)
              OxPressable(
                onTap: () => context.go(Routes.accounts),
                semanticLabel: l.switchAccount,
                child: SizedBox.square(dimension: 44, child: Center(child: AccountAvatar(account: account, size: compact ? 28 : 30))),
              ),
          ],
        ),
      ),
    );
  }
}

/// Tablet (≥840): greeting + search header, hero card with a "Live now"
/// column, then the rails.
class _TabletHome extends ConsumerWidget {
  const _TabletHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = context.oxText;
    final account = ref.watch(activeAccountProvider).value;
    final heroes = ref.watch(heroItemsProvider).value ?? const [];
    final live = ref.watch(liveNowProvider).value ?? const [];
    final now = DateTime.now();
    final greeting = now.hour < 12 ? l.goodMorning : (now.hour < 18 ? l.goodAfternoon : l.goodEvening);
    final date = DateFormat('EEEE, d MMMM', Localizations.localeOf(context).languageCode).format(now);
    final top = MediaQuery.paddingOf(context).top;

    return Stack(
      children: [
        const OxAmbient(color: OxColors.ember, size: Size(600, 300), opacity: 0.12, left: 100, top: 120),
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(32, 20 + top, 28, 0),
                child: Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(date, style: t.caption),
                          Text(greeting, style: t.h1),
                        ],
                      ),
                    ),
                    SizedBox(width: 340, child: OxSearchField(hint: l.searchHintLong, readOnly: true, onTap: context.openSearch, onVoice: context.openSearch)),
                    if (account != null)
                      OxPressable(
                        onTap: () => context.go(Routes.accounts),
                        semanticLabel: l.switchAccount,
                        child: SizedBox.square(dimension: 44, child: Center(child: AccountAvatar(account: account, size: 32))),
                      ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(32, 18, 28, 0),
                child: SizedBox(
                  height: 360,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 20,
                    children: [
                      Expanded(child: heroes.isEmpty ? const OxSkeleton(radius: 28) : HeroCarousel(items: heroes, layout: HeroLayout.tablet)),
                      if (live.isNotEmpty)
                        SizedBox(
                          width: 330,
                          child: Column(
                            spacing: 10,
                            children: [
                              SizedBox(
                                height: 24,
                                child: Row(
                                  children: [
                                    const OxLiveDot(),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(l.homeLiveNow, style: t.h2.copyWith(fontSize: 16))),
                                    OxPressable(
                                      onTap: () => context.go(Routes.live),
                                      child: Text(l.homeAllChannels, style: t.caption.copyWith(color: OxColors.text2, fontWeight: FontWeight.w700)),
                                    ),
                                  ],
                                ),
                              ),
                              for (final item in live.take(3)) _LiveSideCard(item: item),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(top: 26, bottom: MediaQuery.paddingOf(context).bottom + 32),
              sliver: const SliverToBoxAdapter(child: _Rails(compact: false, gutter: OxSpace.tabletGutter, skipLive: true, wideContinue: true)),
            ),
          ],
        ),
      ],
    );
  }
}

/// Tablet "Live now" column card.
class _LiveSideCard extends ConsumerWidget {
  const _LiveSideCard({required this.item});

  final LiveItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.oxText;
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final p = item.nowNext?.now;
    return Expanded(
      child: OxPressable(
        onTap: () => context.playChannel(item.channel.id),
        semanticLabel: '${item.channel.name}, ${p?.title ?? ''}',
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: OxColors.ink2, borderRadius: BorderRadius.circular(18), border: Border.all(color: OxColors.line)),
          child: Row(
            spacing: 12,
            children: [
              SizedBox(
                width: 132,
                child: OxThumb(
                  image: null,
                  art: liveArtwork(item),
                  radius: 12,
                  shade: false,
                  bottomStart: Transform.translate(offset: const Offset(-2, 2), child: OxChannelLogo(name: item.channel.name, logoUrl: item.channel.logo, size: 28)),
                ),
              ),
              Expanded(
                child: ExcludeSemantics(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 5,
                    children: [
                      OxContentText(
                        p == null ? item.channel.name : '${item.channel.name} · ${Fmt.range(p.start, p.stop)}',
                        style: t.caption.copyWith(color: OxColors.halo),
                      ),
                      OxContentText(p?.title ?? '', maxLines: 2, style: t.title.copyWith(fontSize: 13.5, fontWeight: FontWeight.w800, height: 1.25)),
                      if (p != null) OxProgressBar(value: item.nowNext!.progressAt(now)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The rail stack shared by every Home layout.
class _Rails extends ConsumerWidget {
  const _Rails({required this.compact, required this.gutter, this.skipLive = false, this.wideContinue = false});

  final bool compact;
  final double gutter;
  final bool skipLive;
  final bool wideContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cont = ref.watch(continueWatchingProvider).value ?? const [];
    final live = ref.watch(liveNowProvider).value ?? const [];
    final recent = (ref.watch(recentMoviesProvider).value ?? const []).take(12).toList();
    final movies = ref.watch(popularMoviesProvider).value ?? const [];
    final series = ref.watch(popularSeriesProvider).value ?? const [];
    final finished = ref.watch(finishedMoviesProvider).value ?? const [];
    final favCh = ref.watch(favoriteChannelsProvider).value ?? const [];
    final favMv = ref.watch(favoriteMoviesProvider).value ?? const [];

    final last = cont.firstOrNull;
    final lastTitle = last == null ? null : (last.show?.name ?? last.movie?.name);
    final reco = series.where((s) => s.backdrop != null).take(4).toList();

    final sections = <Widget>[
      if (!compact)
        RailSection(
          title: l.homeContinue,
          itemCount: cont.length,
          height: wideContinue ? 200 : 186,
          gutter: gutter,
          actionLabel: l.actionSeeAll,
          onAction: () => context.go(Routes.favorites),
          itemBuilder: (_, i) => ContinueCard(item: cont[i], width: wideContinue ? 250 : 232),
        ),
      if (!skipLive)
        RailSection(
          title: l.homeLiveNow,
          leading: const OxLiveDot(),
          itemCount: live.length,
          height: compact ? 110 : 196,
          gutter: gutter,
          gap: compact ? 10 : 12,
          actionLabel: compact ? l.actionAll : l.homeAllChannels,
          onAction: () => context.go(Routes.live),
          itemBuilder: (_, i) => compact ? _CompactLiveCard(item: live[i]) : LiveCard(item: live[i]),
        ),
      if (!compact)
        RailSection(
          title: l.homeRecentlyAdded,
          itemCount: recent.length,
          height: 180,
          gutter: gutter,
          actionLabel: l.actionSeeAll,
          onAction: () => context.go(Routes.movies),
          itemBuilder: (_, i) => SizedBox(
            width: OxSize.posterRail,
            child: OxPoster(
              image: recent[i].poster,
              title: recent[i].name,
              badges: [if (isNew(recent[i].addedAt)) OxBadge.fresh(context)],
              onTap: () => context.openMovie(recent[i].id),
            ),
          ),
        ),
      RailSection(
        title: l.homePopularMovies,
        itemCount: movies.length,
        height: compact ? 144 : 226,
        gutter: gutter,
        gap: compact ? 10 : 12,
        actionLabel: compact ? l.actionAll : l.actionSeeAll,
        onAction: () => context.go(Routes.movies),
        itemBuilder: (_, i) => compact
            ? SizedBox(width: 96, child: OxPoster(image: movies[i].poster, onTap: () => context.openMovie(movies[i].id), semanticLabel: movies[i].name))
            : PosterTile(
                image: movies[i].poster,
                title: movies[i].name,
                subtitle: movies[i].year?.toString(),
                rating: movies[i].rating,
                onTap: () => context.openMovie(movies[i].id),
              ),
      ),
      if (!compact)
        RailSection(
          title: l.homePopularSeries,
          itemCount: series.length,
          height: 216,
          gutter: gutter,
          actionLabel: l.actionSeeAll,
          onAction: () => context.go(Routes.series),
          itemBuilder: (_, i) => PosterTile(
            image: series[i].cover,
            title: series[i].name,
            titleOnPoster: true,
            showCaptionTitle: false,
            subtitle: series[i].genre,
            rating: series[i].rating,
            onTap: () => context.openSeries(series[i].id),
          ),
        ),
      if (!compact)
        RailSection(
          title: l.homeRecommended,
          itemCount: reco.length,
          height: 182,
          gutter: gutter,
          itemBuilder: (_, i) => WideCard(
            image: reco[i].backdrop,
            title: reco[i].name,
            caption: lastTitle != null && i == 0 ? l.becauseYouWatched(lastTitle) : l.topPicksTonight,
            onTap: () => context.openSeries(reco[i].id),
          ),
        ),
      if (!compact)
        RailSection(
          title: l.homeRecentlyWatched,
          itemCount: finished.length,
          height: 156,
          gap: 10,
          gutter: gutter,
          itemBuilder: (_, i) => SizedBox(width: 104, child: _WatchedPoster(movie: finished[i])),
        ),
      if (!compact)
        RailSection(
          title: l.homeFavorites,
          itemCount: favCh.length + favMv.length,
          height: 120,
          gap: 10,
          gutter: gutter,
          actionLabel: l.homeManage,
          onAction: () => context.go(Routes.favorites),
          itemBuilder: (_, i) => i < favCh.length
              ? FavoriteChannelTile(channel: favCh[i])
              : _FavoritePoster(movie: favMv[i - favCh.length]),
        ),
    ];

    // Hide empty sections and space the rest 30 dp apart (18 compact).
    final visible = sections.where((w) => w is! RailSection || w.itemCount > 0).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, w) in visible.indexed) ...[if (i > 0) SizedBox(height: compact ? 18 : 30), w],
        if (visible.isEmpty) ref.watch(_homeLoadingProvider) ? _RailSkeleton(gutter: gutter) : _EmptyHome(gutter: gutter),
      ],
    );
  }
}

class _CompactLiveCard extends ConsumerWidget {
  const _CompactLiveCard({required this.item});

  final LiveItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final p = item.nowNext?.now;
    return SizedBox(
      width: 196,
      child: Stack(
        children: [
          OxThumb(
            image: null,
            art: liveArtwork(item),
            radius: 12,
            onTap: () => context.playChannel(item.channel.id),
            semanticLabel: '${item.channel.name}, ${p?.title ?? ''}',
            topStart: OxBadge.live(context),
          ),
          PositionedDirectional(
            start: 8,
            end: 8,
            bottom: 8,
            child: IgnorePointer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children: [
                  OxContentText(p?.title ?? item.channel.name, style: context.oxText.title.copyWith(fontSize: 12, fontWeight: FontWeight.w800)),
                  if (p != null) OxProgressBar(value: item.nowNext!.progressAt(now)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WatchedPoster extends StatelessWidget {
  const _WatchedPoster({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: 0.92,
        child: Stack(
          children: [
            OxPoster(image: movie.poster, onTap: () => context.openMovie(movie.id), semanticLabel: '${movie.name}, ${context.l10n.watched}'),
            PositionedDirectional(
              start: 8,
              end: 8,
              bottom: 8,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: const BoxDecoration(boxShadow: [BoxShadow(color: Color(0x99000000), blurRadius: 16)]),
                  child: Row(
                    spacing: 4,
                    children: [
                      const OxIcon(OxIcons.check, size: OxIconSize.xs, color: OxColors.ok),
                      Text(context.l10n.watched, style: context.oxText.caption.copyWith(fontSize: 10.5, fontWeight: FontWeight.w800, color: OxColors.text1)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class _FavoritePoster extends StatelessWidget {
  const _FavoritePoster({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) => OxPressable(
        onTap: () => context.openMovie(movie.id),
        semanticLabel: movie.name,
        child: SizedBox(
          width: 80,
          height: 120,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(OxRadius.md),
            child: Stack(
              fit: StackFit.expand,
              children: [
                OxImage(movie.poster),
                const PositionedDirectional(top: 6, end: 6, child: OxIcon(OxIcons.heartFill, size: OxIconSize.sm, color: OxColors.ember)),
              ],
            ),
          ),
        ),
      );
}

/// Skeleton hero: artwork, title and two lines of text (States 01).
class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: OxSkeleton(radius: 22)),
          SizedBox(height: 18),
          FractionallySizedBox(widthFactor: 0.6, child: OxSkeleton(height: 22, radius: OxRadius.xs)),
          SizedBox(height: 10),
          FractionallySizedBox(widthFactor: 0.85, child: OxSkeleton(height: 12, radius: OxRadius.xs)),
          SizedBox(height: 10),
          FractionallySizedBox(widthFactor: 0.7, child: OxSkeleton(height: 12, radius: OxRadius.xs)),
        ],
      );
}

/// Skeleton rail: a section label and a row of posters (States 01).
class _RailSkeleton extends StatelessWidget {
  const _RailSkeleton({required this.gutter});

  final double gutter;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(horizontal: gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const FractionallySizedBox(widthFactor: 0.4, child: OxSkeleton(height: 16, radius: OxRadius.xs)),
            const SizedBox(height: 12),
            SizedBox(
              height: 144,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 8,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, _) => const OxSkeleton(width: 96, height: 144, radius: 14),
              ),
            ),
          ],
        ),
      );
}

class _EmptyHome extends StatelessWidget {
  const _EmptyHome({required this.gutter});

  final double gutter;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(horizontal: gutter, vertical: 40),
        child: OxStateView(
          emblem: const OxOrbitLoader(size: 64),
          title: context.l10n.homeEmptyTitle,
          message: context.l10n.homeEmptyBody,
        ),
      );
}

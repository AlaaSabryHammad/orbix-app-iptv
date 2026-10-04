import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/design/design.dart';
import '../../core/l10n/l10n.dart';
import '../../core/session/session.dart';
import '../../data/data.dart';
import '../../shared/format/format.dart';
import '../../shared/widgets/widgets.dart';
import '../common/browse.dart';
import '../common/favorites.dart';
import '../common/media_tiles.dart';
import '../common/navigation.dart';
import '../common/providers.dart';

final _movieProvider = StreamProvider.autoDispose.family<Movie?, String>((ref, id) {
  return ref.watch(catalogRepositoryProvider).watchMovie(ref.watch(activeAccountIdProvider) ?? '', id);
});

final _progressProvider = StreamProvider.autoDispose.family<WatchProgress?, String>((ref, id) {
  return ref.watch(libraryRepositoryProvider).watchProgress(ref.watch(activeAccountIdProvider) ?? '', ProgressKind.movie, id);
});

final _sameCategoryProvider = StreamProvider.autoDispose.family<List<Movie>, String?>((ref, categoryId) {
  return ref.watch(catalogRepositoryProvider).watchMovies(ref.watch(activeAccountIdProvider) ?? '', categoryId: categoryId, sort: MovieSort.rating, limit: 16);
});

/// 10 Movie details.
class MovieDetailsScreen extends ConsumerWidget {
  const MovieDetailsScreen({super.key, required this.movieId});

  final String movieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = context.oxText;
    final movie = ref.watch(_movieProvider(movieId)).value;
    final details = ref.watch(movieDetailsProvider(movieId)).value;
    final progress = ref.watch(_progressProvider(movieId)).value;
    final favorites = ref.watch(favoriteIdsProvider(ContentKind.movie)).value ?? const {};
    final related = (ref.watch(_sameCategoryProvider(movie?.categoryId)).value ?? const []).where((m) => m.id != movieId).toList();
    final popular = (ref.watch(popularMoviesProvider).value ?? const []).where((m) => m.id != movieId && m.categoryId != movie?.categoryId).toList();
    final account = ref.watch(activeAccountIdProvider) ?? '';
    final width = MediaQuery.sizeOf(context).width;
    final g = OxWindowSize.of(context).gutter;
    final top = MediaQuery.paddingOf(context).top;

    if (movie == null) {
      return const Scaffold(body: Center(child: OxOrbitLoader()));
    }

    final fav = favorites.contains(movie.id);
    final watched = progress?.completed ?? false;
    final resumeAt = progress != null && !progress.completed && progress.positionMs >= LibraryRepository.minResume.inMilliseconds
        ? Duration(milliseconds: progress.positionMs)
        : null;
    final duration = details?.durationSecs == null ? null : Duration(seconds: details!.durationSecs!);
    final genres = (details?.genre ?? '').split(RegExp(r'[,·/|]')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final cast = (details?.cast ?? '').split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).take(12).toList();
    final contentWidth = width.clamp(0.0, 760.0);

    Future<void> openTrailer() async {
      final id = details?.trailerYoutubeId;
      if (id == null) return;
      await launchUrl(Uri.parse('https://www.youtube.com/watch?v=$id'), mode: LaunchMode.externalApplication);
    }

    Future<void> more() async {
      final action = await showOxSheet<String>(
        context,
        title: movie.name,
        builder: (s) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OxSheetOption(icon: fav ? OxIcons.heartFill : OxIcons.heart, label: fav ? l.a11yRemoveFavorite : l.a11yAddFavorite, onTap: () => Navigator.pop(s, 'fav')),
            OxSheetOption(icon: OxIcons.check, label: watched ? l.markUnwatched : l.markWatched, onTap: () => Navigator.pop(s, 'watched')),
            OxSheetOption(icon: OxIcons.share, label: l.share, onTap: () => Navigator.pop(s, 'share')),
          ],
        ),
      );
      switch (action) {
        case 'fav':
          if (context.mounted) await toggleFavoriteWithFeedback(context, ref, ContentKind.movie, movie.id);
        case 'watched':
          await ref.read(libraryRepositoryProvider).markWatched(account, ProgressKind.movie, movie.id, watched: !watched);
        case 'share':
          await SharePlus.instance.share(ShareParams(text: l.shareText(movie.name)));
      }
    }

    final header = Padding(
      padding: EdgeInsetsDirectional.fromSTEB(10, top + 8, g - 8, 0),
      child: Row(
        children: [
          OxIconButton(icon: OxIcons.back, semanticLabel: l.actionBack, variant: OxIconButtonVariant.glass, onPressed: () => context.pop()),
          const Spacer(),
          OxIconButton(icon: OxIcons.more, semanticLabel: l.moreActions, variant: OxIconButtonVariant.glass, onPressed: more),
        ],
      ),
    );

    final body = Center(
      child: SizedBox(
        width: contentWidth,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: g),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 22,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 16,
                children: [
                  Container(
                    width: 116,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Color(0xE6000000), blurRadius: 50, spreadRadius: -12, offset: Offset(0, 24)),
                        BoxShadow(color: Color(0x24FFFFFF), spreadRadius: 1),
                      ],
                    ),
                    child: ClipRRect(borderRadius: BorderRadius.circular(16), child: AspectRatio(aspectRatio: 2 / 3, child: OxImage(movie.poster))),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10,
                        children: [
                          if (isNew(movie.addedAt)) Row(children: [OxBadge.fresh(context)]),
                          Semantics(
                            header: true,
                            child: OxContentText(t.isArabic ? movie.name : movie.name.toUpperCase(), maxLines: 3, style: t.h1.copyWith(fontSize: 25)),
                          ),
                          OxMetaLine([
                            if (movie.rating != null) OxRating(movie.rating!.toStringAsFixed(1)),
                            if (movie.year != null) '${movie.year}',
                            if (duration != null) Fmt.runtime(context.l10n, duration),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (genres.isNotEmpty) Wrap(spacing: 8, runSpacing: 8, children: [for (final gn in genres) OxChip(label: gn, small: true)]),
              Column(
                spacing: 10,
                children: [
                  OxPlayGlow(
                    borderRadius: BorderRadius.circular(16),
                    child: OxButton(
                      label: resumeAt != null ? l.resumeAt(Fmt.position(resumeAt)) : l.actionPlay,
                      icon: OxIcons.play,
                      size: OxButtonSize.lg,
                      expand: true,
                      onPressed: () => context.playMovie(movie.id),
                    ),
                  ),
                  if (resumeAt != null && progress!.durationMs > 0)
                    Row(
                      spacing: 10,
                      children: [
                        Expanded(child: OxProgressBar(value: progress.positionMs / progress.durationMs)),
                        Text(Fmt.left(context.l10n, Duration(milliseconds: progress.durationMs - progress.positionMs)), style: t.caption),
                      ],
                    ),
                ],
              ),
              Row(
                spacing: 8,
                children: [
                  Expanded(child: _ActionTile(icon: OxIcons.trailer, label: l.trailer, onTap: details?.trailerYoutubeId == null ? null : openTrailer)),
                  Expanded(
                    child: _ActionTile(
                      icon: fav ? OxIcons.heartFill : OxIcons.heart,
                      label: fav ? l.favorited : l.favorite,
                      active: fav,
                      pop: true,
                      onTap: () => toggleFavoriteWithFeedback(context, ref, ContentKind.movie, movie.id),
                    ),
                  ),
                  Expanded(
                    child: _ActionTile(
                      icon: OxIcons.share,
                      label: l.share,
                      onTap: () => SharePlus.instance.share(ShareParams(text: l.shareText(movie.name))),
                    ),
                  ),
                  Expanded(
                    child: _ActionTile(
                      icon: OxIcons.check,
                      label: l.markWatched,
                      active: watched,
                      activeColor: OxColors.ok,
                      onTap: () => ref.read(libraryRepositoryProvider).markWatched(account, ProgressKind.movie, movie.id, watched: !watched),
                    ),
                  ),
                ],
              ),
              if (details?.plot != null || details?.director != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    if (details?.plot != null) OxContentText.paragraph(details!.plot!, style: t.body.copyWith(fontSize: 14.5, color: const Color(0xFFD2CED8))),
                    for (final (label, value) in [
                      (l.director, details?.director),
                      (l.released, details?.releaseDate),
                    ])
                      if (value != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 12,
                          children: [
                            SizedBox(width: 92, child: Text(label, style: t.caption.copyWith(fontSize: 12.5))),
                            Expanded(child: OxContentText(value, maxLines: 2, style: t.small.copyWith(fontSize: 13, fontWeight: FontWeight.w700, color: OxColors.text1))),
                          ],
                        ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    SizedBox(
                      height: 470,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          OxImage(details?.backdrop ?? movie.poster, alignment: const Alignment(-0.2, 0)),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0x9908080B), Color(0x0008080B), Color(0x4D08080B), OxColors.ink1],
                                stops: [0, 0.25, 0.55, 1],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const OxAmbient(color: Color(0xFFE27A3A), size: Size(380, 260), opacity: 0.16, left: 20, top: 380),
                    Padding(padding: const EdgeInsets.only(top: 300), child: body),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(top: 32, bottom: 40),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 30,
                    children: [
                      RailSection(
                        title: l.cast,
                        itemCount: cast.length,
                        height: 124,
                        gap: 16,
                        gutter: g,
                        itemBuilder: (context, i) => _CastMember(name: cast[i]),
                      ),
                      RailSection(
                        title: l.relatedMovies,
                        itemCount: related.length,
                        height: 180,
                        gutter: g,
                        itemBuilder: (context, i) => SizedBox(
                          width: OxSize.posterRail,
                          child: OxPoster(image: related[i].poster, title: related[i].name, titleSize: 12, onTap: () => context.openMovie(related[i].id)),
                        ),
                      ),
                      RailSection(
                        title: l.recommended,
                        itemCount: popular.take(6).length,
                        height: 136,
                        gutter: g,
                        itemBuilder: (context, i) => _RecoCard(movie: popular[i]),
                      ),
                      if (popular.length > 6)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OxSectionHeader(title: l.moreLikeThis, padding: EdgeInsets.symmetric(horizontal: g)),
                            const SizedBox(height: 12),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: g),
                              child: LayoutBuilder(
                                builder: (context, c) {
                                  final cols = posterColumns(c.maxWidth);
                                  final w = (c.maxWidth - 12 * (cols - 1)) / cols;
                                  return Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      for (final m in popular.skip(6).take(cols * 2))
                                        SizedBox(width: w, child: OxPoster(image: m.poster, onTap: () => context.openMovie(m.id), semanticLabel: m.name)),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(left: 0, right: 0, top: 0, child: header),
        ],
      ),
    );
  }
}

/// One of the four tiles under Play (Trailer / Favorite / Share / Watched).
class _ActionTile extends StatefulWidget {
  const _ActionTile({required this.icon, required this.label, required this.onTap, this.active = false, this.activeColor = OxColors.ember, this.pop = false});

  final OxIcons icon;
  final String label;
  final VoidCallback? onTap;
  final bool active;
  final Color activeColor;
  final bool pop;

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: OxMotion.heart);

  @override
  void didUpdateWidget(_ActionTile old) {
    super.didUpdateWidget(old);
    if (widget.pop && widget.active && !old.active && !context.reduceMotion) unawaited(_c.forward(from: 0));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final on = widget.active;
    final c = widget.activeColor;
    final scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 0.9), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 45),
    ]).chain(CurveTween(curve: OxMotion.spring));
    return OxPressable(
      onTap: widget.onTap,
      semanticLabel: widget.label,
      toggled: widget.pop || widget.activeColor == OxColors.ok ? on : null,
      child: AnimatedContainer(
        duration: OxMotion.base,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: on ? c.withValues(alpha: 0.12) : OxColors.ink2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: on ? c.withValues(alpha: 0.3) : OxColors.line),
        ),
        child: Column(
          spacing: 8,
          children: [
            AnimatedBuilder(
              animation: _c,
              builder: (context, child) => Transform.scale(scale: _c.isAnimating ? scale.evaluate(_c) : 1, child: child),
              child: OxIcon(widget.icon, color: on ? c : OxColors.text1),
            ),
            Text(widget.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.oxText.caption.copyWith(color: on ? Color.lerp(c, OxColors.text1, 0.25) : OxColors.text2)),
          ],
        ),
      ),
    );
  }
}

class _CastMember extends StatelessWidget {
  const _CastMember({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final g = OxChannelLogo.gradientFor(name);
    return SizedBox(
      width: 76,
      child: Column(
        spacing: 8,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [g.first.withValues(alpha: 0.7), g.last]),
              boxShadow: const [BoxShadow(color: Color(0x1AFFFFFF), spreadRadius: 2)],
            ),
            alignment: Alignment.center,
            child: Text(OxChannelLogo.initialsOf(name), style: OxTypography.en.h1.copyWith(fontSize: 18, color: const Color(0xFFFFFFFF), fontFamilyFallback: const [OxFonts.arabic])),
          ),
          OxContentText(name, maxLines: 2, align: TextAlign.center, style: context.oxText.title.copyWith(fontSize: 12, fontWeight: FontWeight.w800, height: 1.25)),
        ],
      ),
    );
  }
}

class _RecoCard extends ConsumerWidget {
  const _RecoCard({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.oxText;
    final d = ref.watch(movieDetailsProvider(movie.id)).value;
    final genre = d?.genre?.split('·').first.trim();
    return OxPressable(
      onTap: () => context.openMovie(movie.id),
      semanticLabel: movie.name,
      child: SizedBox(
        width: 240,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                OxImage(d?.backdrop ?? movie.poster),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xCC000000), Color(0x00000000)], stops: [0, 0.6]),
                  ),
                ),
                PositionedDirectional(
                  start: 14,
                  end: 14,
                  bottom: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      OxContentText(t.isArabic ? movie.name : movie.name.toUpperCase(), style: t.isArabic ? t.title : OxTypography.en.h1.copyWith(fontSize: 15)),
                      Text(
                        [if (movie.year != null) '${movie.year}', ?genre, if (movie.rating != null) movie.rating!.toStringAsFixed(1)].join(' · '),
                        style: t.caption.copyWith(color: const Color(0xFFD2CED8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

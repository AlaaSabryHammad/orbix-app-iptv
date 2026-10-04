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
import '../common/favorites.dart';
import '../common/navigation.dart';
import '../common/providers.dart';

final _showProvider = StreamProvider.autoDispose.family<Show?, String>((ref, id) {
  return ref.watch(catalogRepositoryProvider).watchShow(ref.watch(activeAccountIdProvider) ?? '', id);
});

final _episodeProgress = StreamProvider.autoDispose.family<Map<String, WatchProgress>, String>((ref, seriesId) {
  return ref.watch(libraryRepositoryProvider).watchSeriesProgress(ref.watch(activeAccountIdProvider) ?? '', seriesId);
});

enum _EpState { watched, inProgress, upNext, normal }

/// Where the viewer is in a series: the episode to resume or play next.
class _Position {
  const _Position({this.current, this.currentProgress, this.upNext});

  final CatalogEpisode? current;
  final WatchProgress? currentProgress;
  final CatalogEpisode? upNext;

  static _Position of(List<CatalogEpisode> eps, Map<String, WatchProgress> progress) {
    // Most recently touched unfinished episode.
    WatchProgress? latest;
    for (final p in progress.values) {
      if (!p.completed && p.positionMs >= LibraryRepository.minResume.inMilliseconds && (latest == null || p.updatedAt.isAfter(latest.updatedAt))) latest = p;
    }
    final current = latest == null ? null : eps.where((e) => e.id == latest!.itemId).firstOrNull;
    // Up next: the first unwatched episode after the last one touched.
    final lastIdx = eps.lastIndexWhere((e) => progress.containsKey(e.id));
    final next = eps.skip(lastIdx + 1).where((e) => !(progress[e.id]?.completed ?? false) && e.id != current?.id).firstOrNull;
    return _Position(current: current, currentProgress: latest, upNext: lastIdx < 0 ? null : next);
  }

  _EpState stateOf(CatalogEpisode e, Map<String, WatchProgress> progress) {
    if (e.id == current?.id) return _EpState.inProgress;
    if (progress[e.id]?.completed ?? false) return _EpState.watched;
    if (e.id == upNext?.id) return _EpState.upNext;
    return _EpState.normal;
  }
}

/// 12 Series details; 31 foldable / tablet two-pane.
class SeriesDetailsScreen extends ConsumerStatefulWidget {
  const SeriesDetailsScreen({super.key, required this.seriesId});

  final String seriesId;

  @override
  ConsumerState<SeriesDetailsScreen> createState() => _SeriesDetailsScreenState();
}

class _SeriesDetailsScreenState extends ConsumerState<SeriesDetailsScreen> {
  int? _season;

  @override
  Widget build(BuildContext context) {
    final show = ref.watch(_showProvider(widget.seriesId)).value;
    final details = ref.watch(seriesDetailsProvider(widget.seriesId));
    final progress = ref.watch(_episodeProgress(widget.seriesId)).value ?? const {};
    if (show == null) return const Scaffold(body: Center(child: OxOrbitLoader()));

    final eps = details.value?.episodes ?? const <CatalogEpisode>[];
    final seasons = details.value?.seasons.map((s) => s.number).toList() ?? const <int>[];
    final pos = _Position.of(eps, progress);
    final season = _season ?? pos.current?.season ?? pos.upNext?.season ?? seasons.firstOrNull ?? 1;
    final seasonEps = eps.where((e) => e.season == season).toList();

    final mq = MediaQuery.of(context);
    final hinge = oxVerticalHinge(context);
    final twoPane = hinge != null || mq.size.width >= OxBreakpoints.medium;

    final info = _InfoPane(
      show: show,
      details: details.value,
      position: pos,
      twoPane: twoPane,
      seasonCount: seasons.length,
    );
    final episodes = _EpisodesPane(
      seriesId: widget.seriesId,
      seasons: seasons,
      season: season,
      episodes: seasonEps,
      progress: progress,
      position: pos,
      loading: details.isLoading,
      twoPane: twoPane,
      onSeason: (s) => setState(() => _season = s),
    );

    if (!twoPane) {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: info),
            SliverToBoxAdapter(child: episodes),
            SliverPadding(padding: EdgeInsets.only(bottom: mq.padding.bottom + 40)),
          ],
        ),
      );
    }

    // Two panes split at the hinge (foldable) or near the middle (tablet).
    final leftWidth = hinge?.left ?? (mq.size.width * 0.495).clamp(380.0, 560.0);
    final gap = hinge == null ? 8.0 : hinge.width.clamp(8.0, 64.0);
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: leftWidth, child: SingleChildScrollView(child: info)),
          Container(
            width: gap,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [OxColors.ink0, Color(0xFF0D0D12), OxColors.ink0]),
              border: Border.symmetric(vertical: BorderSide(color: Color(0x0AFFFFFF))),
            ),
          ),
          Expanded(
            child: ColoredBox(
              color: const Color(0xFF0B0B0F),
              child: MediaQuery.removePadding(
                context: context,
                removeLeft: true,
                removeRight: true,
                child: SingleChildScrollView(padding: EdgeInsets.only(top: mq.padding.top + 24, bottom: mq.padding.bottom + 24), child: episodes),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPane extends ConsumerWidget {
  const _InfoPane({required this.show, required this.details, required this.position, required this.twoPane, required this.seasonCount});

  final Show show;
  final SeriesDetails? details;
  final _Position position;
  final bool twoPane;
  final int seasonCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = context.oxText;
    final fav = (ref.watch(favoriteIdsProvider(ContentKind.series)).value ?? const {}).contains(show.id);
    final top = MediaQuery.paddingOf(context).top;
    final g = twoPane ? 28.0 : OxWindowSize.of(context).gutter;
    final current = position.current;
    final cp = position.currentProgress;
    final next = position.upNext ?? details?.episodes.firstOrNull;
    final trailer = details?.trailerYoutubeId;
    final plot = details?.series.plot ?? show.plot;

    final playTarget = current ?? next;
    final playLabel = current != null
        ? l.resumeEpisode(current.season, current.episode)
        : next != null
            ? l.playEpisode(next.season, next.episode)
            : l.actionPlay;

    final actions = Row(
      spacing: 8,
      children: [
        Expanded(
          child: _PillAction(
            icon: OxIcons.trailer,
            label: l.trailer,
            onTap: trailer == null ? null : () => launchUrl(Uri.parse('https://www.youtube.com/watch?v=$trailer'), mode: LaunchMode.externalApplication),
          ),
        ),
        Expanded(
          child: _PillAction(
            icon: fav ? OxIcons.heartFill : OxIcons.heart,
            label: fav ? l.favorited : l.favorite,
            active: fav,
            onTap: () => toggleFavoriteWithFeedback(context, ref, ContentKind.series, show.id),
          ),
        ),
        Expanded(
          child: _PillAction(icon: OxIcons.share, label: l.share, onTap: () => SharePlus.instance.share(ShareParams(text: l.shareText(show.name)))),
        ),
      ],
    );

    return Stack(
      children: [
        SizedBox(
          height: twoPane ? 520 : 460,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              OxImage(show.backdrop ?? details?.series.backdrop ?? show.cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x9908080B), Color(0x0008080B), Color(0x5908080B), OxColors.ink1],
                    stops: [0, 0.25, 0.55, 1],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!twoPane) const OxAmbient(color: Color(0xFFFFB060), size: Size(380, 240), opacity: 0.1, left: 20, top: 380),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(twoPane ? 14 : 10, top + 8, twoPane ? 14 : 12, 0),
          child: Row(
            children: [
              OxIconButton(icon: OxIcons.back, semanticLabel: l.actionBack, variant: OxIconButtonVariant.glass, onPressed: () => context.pop()),
              const Spacer(),
              OxIconButton(
                icon: OxIcons.share,
                semanticLabel: l.share,
                variant: OxIconButtonVariant.glass,
                onPressed: () => SharePlus.instance.share(ShareParams(text: l.shareText(show.name))),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(g, twoPane ? 360 : 292, g, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: twoPane ? 18 : 20,
            children: [
              if (twoPane) ...[
                if (show.updatedAt != null && DateTime.now().difference(show.updatedAt!).inDays < 30) Row(children: [OxBadge.fresh(context)]),
                Semantics(header: true, child: OxContentText(t.isArabic ? show.name : show.name.toUpperCase(), maxLines: 3, style: t.hero.copyWith(fontSize: 36))),
                OxMetaLine([
                  if (show.rating != null) OxRating(show.rating!.toStringAsFixed(1)),
                  if (show.year != null) '${show.year}',
                  ?show.genre,
                  if (seasonCount > 0) l.seasonsCount(seasonCount),
                ]),
                if (plot != null) OxContentText.paragraph(plot, style: t.body.copyWith(fontSize: 15, color: const Color(0xFFD2CED8))),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 16,
                  children: [
                    Container(
                      width: 112,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(color: Color(0xE6000000), blurRadius: 50, spreadRadius: -12, offset: Offset(0, 24)),
                          BoxShadow(color: Color(0x24FFFFFF), spreadRadius: 1),
                        ],
                      ),
                      child: ClipRRect(borderRadius: BorderRadius.circular(16), child: AspectRatio(aspectRatio: 2 / 3, child: OxImage(show.cover))),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 10,
                          children: [
                            Semantics(header: true, child: OxContentText(t.isArabic ? show.name : show.name.toUpperCase(), maxLines: 3, style: t.h1.copyWith(fontSize: 23))),
                            OxMetaLine([
                              if (show.rating != null) OxRating(show.rating!.toStringAsFixed(1)),
                              if (show.year != null) '${show.year}',
                              ?show.genre,
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              Column(
                spacing: 10,
                children: [
                  OxPlayGlow(
                    borderRadius: BorderRadius.circular(16),
                    child: OxButton(
                      label: playLabel,
                      icon: OxIcons.play,
                      size: OxButtonSize.lg,
                      expand: true,
                      onPressed: playTarget == null ? null : () => context.playEpisode(show.id, playTarget.id),
                    ),
                  ),
                  if (current != null && cp != null && cp.durationMs > 0)
                    Row(
                      spacing: 10,
                      children: [
                        Expanded(child: OxProgressBar(value: cp.positionMs / cp.durationMs)),
                        Text(Fmt.left(context.l10n, Duration(milliseconds: cp.durationMs - cp.positionMs)), style: t.caption),
                      ],
                    ),
                ],
              ),
              actions,
              if (!twoPane && plot != null) OxContentText.paragraph(plot, style: t.body.copyWith(fontSize: 14.5, color: const Color(0xFFD2CED8))),
              if (twoPane)
                Column(
                  spacing: 8,
                  children: [
                    for (final (label, value) in [(l.director, details?.director), (l.castLabel, details?.cast)])
                      if (value != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 12,
                          children: [
                            SizedBox(width: 90, child: Text(label, style: t.caption.copyWith(fontSize: 12.5))),
                            Expanded(child: OxContentText(value, maxLines: 3, style: t.small.copyWith(fontSize: 13, fontWeight: FontWeight.w700, color: OxColors.text1))),
                          ],
                        ),
                  ],
                ),
              if (twoPane) const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

/// 48 dp tonal action (Trailer / Favorite / Share).
class _PillAction extends StatelessWidget {
  const _PillAction({required this.icon, required this.label, required this.onTap, this.active = false});

  final OxIcons icon;
  final String label;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) => OxPressable(
        onTap: onTap,
        semanticLabel: label,
        toggled: icon == OxIcons.heart || icon == OxIcons.heartFill ? active : null,
        child: AnimatedContainer(
          duration: OxMotion.base,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: active ? const Color(0x24FF7A3D) : OxColors.ink2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: active ? const Color(0x4DFF7A3D) : OxColors.line),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              OxIcon(icon, size: OxIconSize.md, color: active ? OxColors.ember : null),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.oxText.title.copyWith(fontSize: 13, fontWeight: FontWeight.w800, color: active ? OxColors.emberHi : null),
                ),
              ),
            ],
          ),
        ),
      );
}

class _EpisodesPane extends StatelessWidget {
  const _EpisodesPane({
    required this.seriesId,
    required this.seasons,
    required this.season,
    required this.episodes,
    required this.progress,
    required this.position,
    required this.loading,
    required this.twoPane,
    required this.onSeason,
  });

  final String seriesId;
  final List<int> seasons;
  final int season;
  final List<CatalogEpisode> episodes;
  final Map<String, WatchProgress> progress;
  final _Position position;
  final bool loading;
  final bool twoPane;
  final ValueChanged<int> onSeason;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.oxText;
    final g = twoPane ? 24.0 : OxWindowSize.of(context).gutter;

    Future<void> pickSeason() async {
      final s = await showOxSheet<int>(
        context,
        title: l.episodesTitle,
        builder: (sheet) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [for (final n in seasons) OxSheetOption(label: l.seasonN(n), selected: n == season, onTap: () => Navigator.pop(sheet, n))],
        ),
      );
      if (s != null) onSeason(s);
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(g, twoPane ? 16 : 20, g, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: twoPane ? 18 : 14,
        children: [
          Row(
            children: [
              Expanded(child: Semantics(header: true, child: Text(l.episodesTitle, style: twoPane ? t.h1 : t.h2))),
              if (twoPane)
                Text('${l.seasonN(season)} · ${l.episodesCount(episodes.length)}', style: t.caption)
              else if (seasons.length > 1)
                OxButton(label: l.seasonN(season), trailingIcon: OxIcons.chevD, variant: OxButtonVariant.tonal, size: OxButtonSize.sm, onPressed: pickSeason),
            ],
          ),
          if (seasons.length > 1)
            twoPane && seasons.length <= 5
                ? OxSegmented<int>(segments: [for (final n in seasons) OxSegment(n, l.seasonN(n))], selected: season, onChanged: onSeason)
                : SizedBox(
                    height: OxSize.chip,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: seasons.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, i) => OxChip(label: l.seasonN(seasons[i]), selected: seasons[i] == season, onTap: () => onSeason(seasons[i])),
                    ),
                  ),
          if (loading && episodes.isEmpty)
            for (var i = 0; i < 4; i++)
              const Row(
                spacing: 14,
                children: [OxSkeleton(width: 140, height: 79, radius: 12), Expanded(child: OxSkeleton(height: 40))],
              ),
          for (final e in episodes)
            _EpisodeRow(
              seriesId: seriesId,
              episode: e,
              progress: progress[e.id],
              state: position.stateOf(e, progress),
              card: twoPane,
            ),
        ],
      ),
    );
  }
}

class _EpisodeRow extends StatelessWidget {
  const _EpisodeRow({required this.seriesId, required this.episode, required this.progress, required this.state, required this.card});

  final String seriesId;
  final CatalogEpisode episode;
  final WatchProgress? progress;
  final _EpState state;

  /// Two-pane style: everything in one card row, duration badge on the still.
  final bool card;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.oxText;
    final e = episode;
    final (String label, Color color) = switch (state) {
      _EpState.watched => (l.watched, OxColors.ok),
      _EpState.inProgress => (l.continueWatchingShort, OxColors.emberHi),
      _EpState.upNext => (l.upNext, OxColors.halo),
      _EpState.normal => (l.episodeN(e.episode), OxColors.text3),
    };
    final p = progress;
    final fraction = state == _EpState.watched ? 1.0 : (p != null && p.durationMs > 0 ? p.positionMs / p.durationMs : null);
    final duration = e.durationSecs == null ? null : Duration(seconds: e.durationSecs!);
    final durText = [
      if (duration != null) Fmt.runtime(context.l10n, duration),
      if (state == _EpState.inProgress && p != null && p.durationMs > 0) Fmt.left(context.l10n, Duration(milliseconds: p.durationMs - p.positionMs)),
    ].join(' · ');

    final thumb = SizedBox(
      width: card ? 150 : 140,
      child: OxThumb(
        image: e.still,
        radius: 12,
        shade: false,
        progress: fraction,
        topStart: card && duration != null ? OxBadge(Fmt.runtime(context.l10n, duration)) : null,
        center: card
            ? null
            : Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: const Color(0x80000000), shape: BoxShape.circle, border: Border.all(color: const Color(0x4DFFFFFF))),
                child: const Padding(padding: EdgeInsets.only(left: 2), child: Center(child: OxIcon(OxIcons.play, size: OxIconSize.xs))),
              ),
      ),
    );

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(label, style: t.caption.copyWith(color: color)),
        OxContentText('${e.episode}. ${e.title}', maxLines: 2, style: t.title.copyWith(fontSize: 14.5)),
        if (card && e.plot != null)
          OxContentText.paragraph(e.plot!, maxLines: 2, style: t.body.copyWith(fontSize: 12.5, height: 1.45))
        else if (!card && durText.isNotEmpty)
          Text(durText, style: t.caption),
      ],
    );

    final row = card
        ? AnimatedContainer(
            duration: OxMotion.base,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: state == _EpState.inProgress ? const Color(0x1AFF7A3D) : const Color(0x00000000),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: state == _EpState.inProgress ? const Color(0x40FF7A3D) : const Color(0x00000000)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, spacing: 14, children: [thumb, Expanded(child: text)]),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Row(spacing: 14, children: [thumb, Expanded(child: text)]),
              if (e.plot != null) OxContentText.paragraph(e.plot!, style: t.body.copyWith(fontSize: 13, height: 1.5)),
            ],
          );

    return Opacity(
      opacity: state == _EpState.watched ? 0.78 : 1,
      child: OxPressable(
        onTap: () => context.playEpisode(seriesId, e.id),
        semanticLabel: '${e.episode}. ${e.title}, $label',
        pressedScale: 0.985,
        child: row,
      ),
    );
  }
}

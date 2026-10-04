import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/design.dart';
import '../../core/l10n/l10n.dart';
import '../../core/router/routes.dart';
import '../../core/session/session.dart';
import '../../core/settings/app_settings.dart';
import '../../data/data.dart';
import '../../shared/format/format.dart';
import '../../shared/widgets/widgets.dart';
import '../common/navigation.dart';
import '../common/providers.dart';
import 'voice_search_sheet.dart';

enum _Type { all, movies, series, channels }

/// 13 Search, 14 results with instant suggestions, 15 voice (sheet).
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _query = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  SearchResults? _results;
  Map<String, NowNext> _now = const {};
  _Type _type = _Type.all;
  int? _year;
  String? _genre;

  @override
  void initState() {
    super.initState();
    _query.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), _run);
    setState(() {});
  }

  Future<void> _run() async {
    final q = _query.text.trim();
    if (q.isEmpty) {
      setState(() => _results = null);
      return;
    }
    final account = ref.read(activeAccountIdProvider) ?? '';
    final r = await ref.read(catalogRepositoryProvider).search(account, q, limit: 60);
    final nn = await ref.read(epgRepositoryProvider).nowNext(account, r.channels.take(10).map(EpgRepository.guideIdOf));
    if (!mounted || _query.text.trim() != q) return;
    setState(() {
      _results = r;
      _now = nn;
    });
  }

  void _setQuery(String q) {
    _query.text = q;
    _query.selection = TextSelection.collapsed(offset: q.length);
    unawaited(ref.read(appSettingsProvider.notifier).addRecentSearch(q));
  }

  void _remember() => unawaited(ref.read(appSettingsProvider.notifier).addRecentSearch(_query.text));

  Future<void> _voice() async {
    final text = await showVoiceSearch(context);
    if (text != null) _setQuery(text);
  }

  Future<void> _pickYear(List<int> years) async {
    final l = context.l10n;
    final picked = await showOxSheet<int>(
      context,
      title: l.filterYear,
      builder: (s) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OxSheetOption(label: l.anyYear, selected: _year == null, onTap: () => Navigator.pop(s, -1)),
          for (final y in years) OxSheetOption(label: '$y', selected: _year == y, onTap: () => Navigator.pop(s, y)),
        ],
      ),
    );
    if (picked != null) setState(() => _year = picked == -1 ? null : picked);
  }

  Future<void> _pickGenre(List<String> genres) async {
    final l = context.l10n;
    final picked = await showOxSheet<String>(
      context,
      title: l.filterGenre,
      builder: (s) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OxSheetOption(label: l.anyGenre, selected: _genre == null, onTap: () => Navigator.pop(s, '')),
            for (final g in genres) OxSheetOption(label: g, selected: _genre == g, onTap: () => Navigator.pop(s, g)),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _genre = picked.isEmpty ? null : picked);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final top = MediaQuery.paddingOf(context).top;
    final movieCats = ref.watch(_categoryNames(ContentKind.movie)).value ?? const {};
    final seriesCats = ref.watch(_categoryNames(ContentKind.series)).value ?? const {};

    // Filter the raw results by year and genre (category).
    final r = _results;
    bool keepYear(int? y) => _year == null || y == _year;
    bool keepGenre(Map<String, String> names, String? cat) => _genre == null || names[cat] == _genre;
    final movies = r?.movies.where((m) => keepYear(m.year) && keepGenre(movieCats, m.categoryId)).toList() ?? const <Movie>[];
    final series = r?.series.where((s) => keepYear(s.year) && keepGenre(seriesCats, s.categoryId)).toList() ?? const <Show>[];
    final channels = _year == null && _genre == null ? (r?.channels ?? const <Channel>[]) : const <Channel>[];
    final total = movies.length + series.length + channels.length;
    final years = {...?r?.movies.map((m) => m.year), ...?r?.series.map((s) => s.year)}.whereType<int>().toList()..sort((a, b) => b.compareTo(a));
    final genres = {...movieCats.values, ...seriesCats.values}.toList()..sort();
    final searching = _query.text.trim().isNotEmpty;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(8, top + 8, 16, 0),
            child: Row(
              spacing: 6,
              children: [
                OxIconButton(icon: OxIcons.back, semanticLabel: l.actionBack, onPressed: () => context.pop()),
                Expanded(
                  child: OxSearchField(
                    controller: _query,
                    focusNode: _focus,
                    autofocus: true,
                    hint: l.searchHint,
                    onVoice: _voice,
                    onSubmitted: (_) => _remember(),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsetsDirectional.fromSTEB(20, 14, 20, 2),
              children: [
                for (final (type, label, icon) in [
                  (_Type.all, searching ? l.allCount(total) : l.actionAll, null),
                  (_Type.movies, searching ? l.typeCount(l.filterMovies, movies.length) : l.filterMovies, OxIcons.film),
                  (_Type.series, searching ? l.typeCount(l.filterSeries, series.length) : l.filterSeries, OxIcons.series),
                  (_Type.channels, searching ? l.typeCount(l.filterChannels, channels.length) : l.filterChannels, OxIcons.live),
                ]) ...[
                  OxChip(label: label, icon: searching ? null : icon, selected: _type == type, onTap: () => setState(() => _type = type)),
                  const SizedBox(width: 8),
                ],
                if (_genre != null)
                  OxChip(label: _genre!, tone: OxChipTone.ember, trailingIcon: OxIcons.close, onTap: () => setState(() => _genre = null))
                else
                  OxChip(label: l.filterGenre, trailingIcon: OxIcons.chevD, onTap: () => _pickGenre(genres)),
                const SizedBox(width: 8),
                if (_year != null)
                  OxChip(label: '$_year', tone: OxChipTone.ember, trailingIcon: OxIcons.close, onTap: () => setState(() => _year = null))
                else
                  OxChip(label: l.filterYear, trailingIcon: OxIcons.chevD, onTap: searching && years.isNotEmpty ? () => _pickYear(years) : null),
              ],
            ),
          ),
          Expanded(
            child: !searching
                ? _Landing(onQuery: _setQuery)
                : r == null
                    ? const SizedBox.shrink()
                    : total == 0
                        ? _NoResults(
                            query: _query.text.trim(),
                            filter: _genre ?? _year?.toString(),
                            suggestions: genres.take(3).toList(),
                            onSuggestion: _setQuery,
                            onClear: () => setState(() {
                              _year = null;
                              _genre = null;
                              _type = _Type.all;
                            }),
                          )
                        : _Results(
                            query: _query.text.trim(),
                            type: _type,
                            movies: movies,
                            series: series,
                            channels: channels,
                            now: _now,
                            onOpen: _remember,
                          ),
          ),
        ],
      ),
    );
  }
}

final _categoryNames = StreamProvider.autoDispose.family<Map<String, String>, ContentKind>((ref, kind) {
  return ref.watch(catalogRepositoryProvider).watchCategories(ref.watch(activeAccountIdProvider) ?? '', kind).map((c) => {for (final x in c) x.id: x.name});
});

/// Query text with the matching part in bold ember.
class _Highlight extends StatelessWidget {
  const _Highlight({required this.text, required this.query, required this.style});

  final String text;
  final String query;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final i = text.toLowerCase().indexOf(query.toLowerCase());
    final dir = oxDirectionOf(text) ?? Directionality.of(context);
    if (i < 0 || query.isEmpty) return Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: style, textDirection: dir);
    return Text.rich(
      TextSpan(children: [
        TextSpan(text: text.substring(0, i)),
        TextSpan(text: text.substring(i, i + query.length), style: const TextStyle(color: OxColors.emberHi, fontWeight: FontWeight.w800)),
        TextSpan(text: text.substring(i + query.length)),
      ]),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
      textDirection: dir,
    );
  }
}

class _Landing extends ConsumerWidget {
  const _Landing({required this.onQuery});

  final ValueChanged<String> onQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = context.oxText;
    final recent = ref.watch(appSettingsProvider.select((s) => s.recentSearches));
    final popularNames = [
      ...?ref.watch(popularMoviesProvider).value?.take(3).map((m) => m.name),
      ...?ref.watch(popularSeriesProvider).value?.take(2).map((s) => s.name),
    ];
    final live = ref.watch(liveNowProvider).value ?? const [];
    final topMovie = ref.watch(popularMoviesProvider).value?.firstOrNull;
    final topShow = ref.watch(popularSeriesProvider).value?.firstOrNull;
    final favMovie = ref.watch(favoriteMoviesProvider).value?.firstOrNull;

    return ListView(
      padding: EdgeInsets.fromLTRB(20, 26, 20, MediaQuery.paddingOf(context).bottom + 24),
      children: [
        if (recent.isNotEmpty) ...[
          Row(
            children: [
              Expanded(child: Text(l.recentSearches, style: t.h2.copyWith(fontSize: 16))),
              OxButton(
                label: l.clearAll,
                variant: OxButtonVariant.ghost,
                size: OxButtonSize.sm,
                onPressed: () => ref.read(appSettingsProvider.notifier).update((s) => s.copyWith(recentSearches: const [])),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final q in recent)
            OxPressable(
              onTap: () => onQuery(q),
              pressedScale: 1,
              child: SizedBox(
                height: 46,
                child: Row(
                  spacing: 14,
                  children: [
                    const OxIcon(OxIcons.history, size: OxIconSize.md, color: OxColors.text3),
                    Expanded(child: OxContentText(q, style: t.title.copyWith(fontSize: 15))),
                    OxIconButton(
                      icon: OxIcons.close,
                      semanticLabel: l.a11yClear,
                      dimension: 36,
                      iconSize: OxIconSize.sm,
                      color: OxColors.text3,
                      onPressed: () => ref.read(appSettingsProvider.notifier).update((s) => s.copyWith(recentSearches: s.recentSearches.where((x) => x != q).toList())),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 22),
        ],
        if (popularNames.isNotEmpty) ...[
          Row(
            spacing: 8,
            children: [
              const OxIcon(OxIcons.trending, size: OxIconSize.md, color: OxColors.ember),
              Text(l.trendingSearches, style: t.h2.copyWith(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (i, name) in popularNames.indexed)
                OxPressable(
                  onTap: () => onQuery(name),
                  child: Container(
                    height: OxSize.chip,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(color: OxColors.ink3, borderRadius: BorderRadius.circular(OxRadius.pill), border: Border.all(color: OxColors.line)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 6,
                      children: [
                        Text('${i + 1}', style: OxTypography.en.time.copyWith(fontSize: 11, color: OxColors.emberHi)),
                        OxContentText(name, style: t.title.copyWith(fontSize: 13, color: OxColors.text1)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 26),
        ],
        Text(l.browse, style: t.h2.copyWith(fontSize: 16)),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, c) {
            final cols = c.maxWidth >= 600 ? 4 : 2;
            final w = (c.maxWidth - 10 * (cols - 1)) / cols;
            final tiles = [
              (l.browseLive, OxIcons.live, live.firstOrNull?.nowNext?.now?.image, Routes.live),
              (l.browseMovies, OxIcons.film, topMovie?.poster, Routes.movies),
              (l.browseSeries, OxIcons.series, topShow?.backdrop ?? topShow?.cover, Routes.series),
              (l.browseFavorites, OxIcons.heart, favMovie?.poster, Routes.favorites),
            ];
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final (name, icon, image, route) in tiles)
                  SizedBox(
                    width: w,
                    child: OxPressable(
                      onTap: () => context.go(route),
                      semanticLabel: name,
                      child: SizedBox(
                        height: 84,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              OxImage(image, fallback: const ColoredBox(color: OxColors.ink3)),
                              const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xE608080B), Color(0x3308080B)]))),
                              PositionedDirectional(
                                start: 14,
                                top: 0,
                                bottom: 0,
                                child: Row(spacing: 10, children: [OxIcon(icon, size: OxIconSize.md), Text(name, style: t.title.copyWith(fontSize: 14.5, fontWeight: FontWeight.w800))]),
                              ),
                            ],
                          ),
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
  }
}

class _Results extends StatelessWidget {
  const _Results({
    required this.query,
    required this.type,
    required this.movies,
    required this.series,
    required this.channels,
    required this.now,
    required this.onOpen,
  });

  final String query;
  final _Type type;
  final List<Movie> movies;
  final List<Show> series;
  final List<Channel> channels;
  final Map<String, NowNext> now;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.oxText;
    final showChannels = type == _Type.all || type == _Type.channels;
    final showMovies = type == _Type.all || type == _Type.movies;
    final showSeries = type == _Type.all || type == _Type.series;

    // Instant suggestions: the best hit of each kind.
    final sugg = <(OxIcons, String, String, VoidCallback)>[
      if (showMovies && movies.isNotEmpty)
        (OxIcons.film, movies.first.name, [l.kindMovie, if (movies.first.year != null) '${movies.first.year}'].join(' · '), () => context.openMovie(movies.first.id)),
      if (showChannels && channels.isNotEmpty)
        (
          OxIcons.live,
          now[EpgRepository.guideIdOf(channels.first)]?.now?.title ?? channels.first.name,
          l.liveNowLabel,
          () => context.playChannel(channels.first.id),
        ),
      if (showSeries && series.isNotEmpty) (OxIcons.series, series.first.name, l.kindSeries, () => context.openSeries(series.first.id)),
    ];

    final titles = <(String, String?, String, VoidCallback)>[
      if (showMovies) for (final m in movies) (m.name, m.poster, l.kindMovie, () => context.openMovie(m.id)),
      if (showSeries) for (final s in series) (s.name, s.cover, l.kindSeries, () => context.openSeries(s.id)),
    ];

    return ListView(
      padding: EdgeInsets.only(top: 14, bottom: MediaQuery.paddingOf(context).bottom + 24),
      children: [
        if (sugg.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: OxColors.ink2, borderRadius: BorderRadius.circular(20), border: Border.all(color: OxColors.line)),
            child: Column(
              children: [
                for (final (icon, text, kind, open) in sugg)
                  OxPressable(
                    onTap: () {
                      onOpen();
                      open();
                    },
                    pressedScale: 0.985,
                    child: SizedBox(
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          spacing: 12,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(color: OxColors.ink4, borderRadius: BorderRadius.circular(10)),
                              child: Center(child: OxIcon(icon, size: OxIconSize.sm, color: OxColors.text2)),
                            ),
                            Expanded(child: _Highlight(text: text, query: query, style: t.title.copyWith(fontSize: 14.5, fontWeight: FontWeight.w600))),
                            Text(kind, style: t.caption),
                            Transform.rotate(angle: -0.785, child: const OxIcon(OxIcons.chevU, size: OxIconSize.sm, color: OxColors.text3)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (showChannels && channels.isNotEmpty) ...[
          Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 10), child: Text(t.overlineText(l.searchChannels), style: t.overline)),
          for (final c in channels.take(8))
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: OxPressable(
                onTap: () {
                  onOpen();
                  context.playChannel(c.id);
                },
                semanticLabel: c.name,
                pressedScale: 0.985,
                child: Row(
                  spacing: 12,
                  children: [
                    OxChannelLogo(name: c.name, logoUrl: c.logo, size: 44),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Highlight(text: c.name, query: query, style: t.title.copyWith(fontSize: 14)),
                          if (now[EpgRepository.guideIdOf(c)]?.now case final p?)
                            OxContentText('${p.title} · ${Fmt.range(p.start, p.stop)}', style: t.caption),
                        ],
                      ),
                    ),
                    OxBadge.live(context),
                  ],
                ),
              ),
            ),
        ],
        if (titles.isNotEmpty) ...[
          Padding(padding: const EdgeInsets.fromLTRB(20, 22, 20, 10), child: Text(t.overlineText(l.searchTitles), style: t.overline)),
          SizedBox(
            height: 186,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: titles.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final (name, image, kind, open) = titles[i];
                return SizedBox(
                  width: 104,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 6,
                    children: [
                      OxPoster(
                        image: image,
                        semanticLabel: name,
                        badges: [OxBadge(t.isArabic ? kind : kind.toUpperCase(), tone: OxBadgeTone.hd)],
                        onTap: () {
                          onOpen();
                          open();
                        },
                      ),
                      OxContentText(name, style: t.title.copyWith(fontSize: 12.5)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

/// States 04 — nothing matched: name the filter that may be in the way,
/// offer a few genres to try, and a way to clear the filters.
class _NoResults extends StatelessWidget {
  const _NoResults({required this.query, required this.onClear, required this.onSuggestion, this.filter, this.suggestions = const []});

  final String query;

  /// The active genre / year filter, if any.
  final String? filter;
  final List<String> suggestions;
  final ValueChanged<String> onSuggestion;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(34),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: OxStateView(
            emblem: const OxStateEmblem(icon: OxIcons.search, background: Color(0x0DFFFFFF), foreground: OxColors.text2),
            title: l.noResultsTitle(query),
            message: filter == null ? l.noResultsBody : l.noResultsFiltered(filter!),
            actions: [if (filter != null) OxButton(label: l.clearFilters, variant: OxButtonVariant.tonal, size: OxButtonSize.sm, onPressed: onClear)],
            children: [
              if (suggestions.isNotEmpty)
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [for (final s in suggestions) OxChip(label: s, small: true, onTap: () => onSuggestion(s))],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

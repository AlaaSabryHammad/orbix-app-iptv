import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../core/background.dart';
import '../core/failures.dart';
import '../credentials/credential_store.dart';
import '../credentials/credentials.dart';
import '../db/database.dart';
import '../models/catalog.dart';
import '../sources/m3u/m3u_parser.dart';
import '../sources/m3u/playlist_loader.dart';
import '../sources/xtream/xtream_client.dart';

enum SectionPhase { waiting, loading, ready, failed }

/// One catalog section during a sync ("Movies 2,140 / 8,930").
class SectionProgress {
  const SectionProgress(this.phase, {this.done = 0, this.total, this.failure});

  static const waiting = SectionProgress(SectionPhase.waiting);

  final SectionPhase phase;
  final int done;
  final int? total;
  final OrbixFailure? failure;
}

/// Progressive sync state (States 02 "Loading your playlist"): Live TV is
/// usable as soon as [live] is ready while movies and series keep loading.
class SyncProgress {
  const SyncProgress({this.live = SectionProgress.waiting, this.movies = SectionProgress.waiting, this.series = SectionProgress.waiting, this.downloadedBytes});

  final SectionProgress live;
  final SectionProgress movies;
  final SectionProgress series;

  /// M3U only: bytes downloaded so far.
  final int? downloadedBytes;

  bool get liveReady => live.phase == SectionPhase.ready;
  bool get finished => [live, movies, series].every((s) => s.phase == SectionPhase.ready || s.phase == SectionPhase.failed);

  /// The first failure, if any section failed.
  OrbixFailure? get failure => [live, movies, series].map((s) => s.failure).whereType<OrbixFailure>().firstOrNull;

  SyncProgress copyWith({SectionProgress? live, SectionProgress? movies, SectionProgress? series, int? downloadedBytes}) => SyncProgress(
        live: live ?? this.live,
        movies: movies ?? this.movies,
        series: series ?? this.series,
        downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      );
}

enum MovieSort { playlist, recentlyAdded, rating, name }

/// A playable URL plus the headers the provider requires.
class ResolvedStream {
  const ResolvedStream(this.url, {this.headers = const {}});

  final String url;
  final Map<String, String> headers;
}

class SearchResults {
  const SearchResults({this.channels = const [], this.movies = const [], this.series = const []});

  final List<Channel> channels;
  final List<Movie> movies;
  final List<Show> series;

  bool get isEmpty => channels.isEmpty && movies.isEmpty && series.isEmpty;
}

/// The local catalog: syncing it from the provider and reading it back.
class CatalogRepository {
  CatalogRepository(this._db, this._dio, this._credentials);

  final OrbixDatabase _db;
  final Dio _dio;
  final CredentialStore _credentials;

  static const _chunk = 2000;

  // --- Sync -------------------------------------------------------------------------

  /// Refreshes the account's catalog, section by section. The stream ends
  /// when every section is ready or failed; it does not throw.
  ///
  /// Pass [prefetched] (from the connection test) to skip re-downloading an
  /// M3U playlist that was just parsed.
  Stream<SyncProgress> sync(Account account, {CatalogSnapshot? prefetched, CancelToken? cancel}) {
    final out = StreamController<SyncProgress>();
    var state = const SyncProgress();
    void emit(SyncProgress s) {
      state = s;
      if (!out.isClosed) out.add(s);
    }

    () async {
      try {
        final creds = await _credentials.load(account.id);
        if (creds == null) throw const InvalidCredentialsFailure();
        switch (creds) {
          case XtreamCredentials():
            await _syncXtream(account, XtreamClient(_dio, creds), () => state, emit, cancel);
          case PlaylistCredentials():
            await _syncPlaylist(account, creds, prefetched, () => state, emit, cancel);
        }
        await (_db.update(_db.accounts)..where((a) => a.id.equals(account.id))).write(AccountsCompanion(lastSyncedAt: Value(DateTime.now())));
      } catch (e) {
        final f = OrbixFailure.from(e);
        SectionProgress fail(SectionProgress s) => s.phase == SectionPhase.ready ? s : SectionProgress(SectionPhase.failed, failure: f);
        emit(state.copyWith(live: fail(state.live), movies: fail(state.movies), series: fail(state.series)));
      } finally {
        await out.close();
      }
    }();
    return out.stream;
  }

  /// Failures that make every remaining section fail the same way.
  static bool _isAccountLevel(OrbixFailure f) => switch (f) {
        InvalidCredentialsFailure() ||
        AccountExpiredFailure() ||
        AccountDisabledFailure() ||
        OfflineFailure() ||
        HostNotFoundFailure() ||
        ConnectionRefusedFailure() ||
        TlsFailure() ||
        CancelledFailure() =>
          true,
        _ => false,
      };

  Future<void> _syncXtream(
    Account account,
    XtreamClient client,
    SyncProgress Function() state,
    void Function(SyncProgress) emit,
    CancelToken? cancel,
  ) async {
    final info = await client.authenticate(cancel: cancel);
    await (_db.update(_db.accounts)..where((a) => a.id.equals(account.id))).write(AccountsCompanion(
      status: Value(info.isActive ? AccountStatus.active : AccountStatus.unknown),
      expiresAt: Value(info.expiresAt),
      maxConnections: Value(info.maxConnections),
    ));

    Future<void> section(
      SectionProgress Function(SyncProgress) get,
      SyncProgress Function(SyncProgress, SectionProgress) set,
      Future<void> Function(void Function(int done, int total) progress) run,
    ) async {
      emit(set(state(), const SectionProgress(SectionPhase.loading)));
      try {
        await run((done, total) => emit(set(state(), SectionProgress(SectionPhase.loading, done: done, total: total))));
        final s = get(state());
        emit(set(state(), SectionProgress(SectionPhase.ready, done: s.total ?? s.done, total: s.total)));
      } catch (e) {
        final f = OrbixFailure.from(e);
        emit(set(state(), SectionProgress(SectionPhase.failed, failure: f)));
        if (_isAccountLevel(f)) rethrow;
      }
    }

    await section((s) => s.live, (s, p) => s.copyWith(live: p), (progress) async {
      final cats = await client.categories(ContentKind.live, cancel: cancel);
      final items = await client.liveStreams(cancel: cancel);
      await _writeChannels(account.id, cats, items, progress);
    });
    await section((s) => s.movies, (s, p) => s.copyWith(movies: p), (progress) async {
      final cats = await client.categories(ContentKind.movie, cancel: cancel);
      final items = await client.vodStreams(cancel: cancel);
      await _writeMovies(account.id, cats, items, progress);
    });
    await section((s) => s.series, (s, p) => s.copyWith(series: p), (progress) async {
      final cats = await client.categories(ContentKind.series, cancel: cancel);
      final items = await client.series(cancel: cancel);
      await _writeSeries(account.id, cats, items, const [], progress);
    });
  }

  Future<void> _syncPlaylist(
    Account account,
    PlaylistCredentials creds,
    CatalogSnapshot? prefetched,
    SyncProgress Function() state,
    void Function(SyncProgress) emit,
    CancelToken? cancel,
  ) async {
    const loading = SectionProgress(SectionPhase.loading);
    emit(state().copyWith(live: loading, movies: loading, series: loading));

    final s = prefetched ?? await _loadPlaylist(creds, (received) => emit(state().copyWith(downloadedBytes: received)), cancel);

    if (!_sameList(s.epgUrls, creds.headerEpgUrls)) {
      await _credentials.save(account.id, creds.withHeaderEpgUrls(s.epgUrls));
    }

    final live = s.categories.where((c) => c.kind == ContentKind.live).toList();
    await _writeChannels(account.id, live, s.channels, (d, t) => emit(state().copyWith(live: SectionProgress(SectionPhase.loading, done: d, total: t))));
    emit(state().copyWith(live: SectionProgress(SectionPhase.ready, done: s.channels.length, total: s.channels.length)));

    final movieCats = s.categories.where((c) => c.kind == ContentKind.movie).toList();
    await _writeMovies(account.id, movieCats, s.movies, (d, t) => emit(state().copyWith(movies: SectionProgress(SectionPhase.loading, done: d, total: t))));
    emit(state().copyWith(movies: SectionProgress(SectionPhase.ready, done: s.movies.length, total: s.movies.length)));

    final seriesCats = s.categories.where((c) => c.kind == ContentKind.series).toList();
    await _writeSeries(account.id, seriesCats, s.series, s.episodes, (d, t) => emit(state().copyWith(series: SectionProgress(SectionPhase.loading, done: d, total: t))));
    emit(state().copyWith(series: SectionProgress(SectionPhase.ready, done: s.series.length, total: s.series.length)));
  }

  Future<CatalogSnapshot> _loadPlaylist(PlaylistCredentials creds, void Function(int received) onBytes, CancelToken? cancel) async {
    final bytes = creds.filePath != null
        ? await PlaylistFiles.read(creds.filePath!)
        : (await PlaylistLoader(_dio).download(creds.playlistUrl!, cancel: cancel, onBytes: (received, _) => onBytes(received))).bytes;
    return runInBackground(parseM3uCatalog, bytes);
  }

  static bool _sameList(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<void> _replaceCategories(String accountId, ContentKind kind, List<CatalogCategory> cats) async {
    await (_db.delete(_db.categories)..where((c) => c.accountId.equals(accountId) & c.kind.equalsValue(kind))).go();
    await _db.batch((b) => b.insertAll(_db.categories, [
          for (final c in cats)
            CategoriesCompanion.insert(accountId: accountId, kind: kind, id: c.id, name: c.name, sortIndex: c.sortIndex, isAdult: Value(c.isAdult)),
        ], mode: InsertMode.insertOrReplace));
  }

  Future<void> _insertChunked<T, C extends Insertable<Object?>>(
    TableInfo<Table, Object?> table,
    List<T> items,
    C Function(T) toRow,
    void Function(int done, int total) progress,
  ) async {
    for (var i = 0; i < items.length; i += _chunk) {
      final end = i + _chunk < items.length ? i + _chunk : items.length;
      await _db.batch((b) => b.insertAll(table, [for (var j = i; j < end; j++) toRow(items[j])], mode: InsertMode.insertOrReplace));
      progress(end, items.length);
    }
    if (items.isEmpty) progress(0, 0);
  }

  Future<void> _writeChannels(String accountId, List<CatalogCategory> cats, List<CatalogChannel> items, void Function(int, int) progress) =>
      _db.transaction(() async {
        await _replaceCategories(accountId, ContentKind.live, cats);
        await (_db.delete(_db.channels)..where((c) => c.accountId.equals(accountId))).go();
        await _insertChunked(
          _db.channels,
          items,
          (c) => ChannelsCompanion.insert(
            accountId: accountId,
            id: c.id,
            name: c.name,
            number: Value(c.number),
            logo: Value(c.logo),
            categoryId: Value(c.categoryId),
            epgId: Value(c.epgId),
            streamUrl: Value(c.streamUrl),
            headers: Value(c.headers == null ? null : jsonEncode(c.headers)),
            catchupDays: Value(c.catchupDays),
            sortIndex: c.sortIndex,
            addedAt: Value(c.addedAt),
          ),
          progress,
        );
        await _setCount(accountId, liveCount: items.length);
      });

  Future<void> _writeMovies(String accountId, List<CatalogCategory> cats, List<CatalogMovie> items, void Function(int, int) progress) =>
      _db.transaction(() async {
        await _replaceCategories(accountId, ContentKind.movie, cats);
        await (_db.delete(_db.movies)..where((m) => m.accountId.equals(accountId))).go();
        await _insertChunked(
          _db.movies,
          items,
          (m) => MoviesCompanion.insert(
            accountId: accountId,
            id: m.id,
            name: m.name,
            poster: Value(m.poster),
            rating: Value(m.rating),
            year: Value(m.year),
            addedAt: Value(m.addedAt),
            categoryId: Value(m.categoryId),
            containerExt: Value(m.containerExt),
            streamUrl: Value(m.streamUrl),
            sortIndex: m.sortIndex,
          ),
          progress,
        );
        await _setCount(accountId, movieCount: items.length);
      });

  Future<void> _writeSeries(
    String accountId,
    List<CatalogCategory> cats,
    List<CatalogSeries> items,
    List<CatalogEpisode> episodes,
    void Function(int, int) progress,
  ) =>
      _db.transaction(() async {
        await _replaceCategories(accountId, ContentKind.series, cats);
        await (_db.delete(_db.seriesTable)..where((s) => s.accountId.equals(accountId))).go();
        await (_db.delete(_db.episodes)..where((e) => e.accountId.equals(accountId))).go();
        await _insertChunked(_db.seriesTable, items, (s) => _showRow(accountId, s), progress);
        await _insertChunked(_db.episodes, episodes, (e) => _episodeRow(accountId, e), (_, _) {});
        await _setCount(accountId, seriesCount: items.length);
      });

  static SeriesTableCompanion _showRow(String accountId, CatalogSeries s) => SeriesTableCompanion.insert(
        accountId: accountId,
        id: s.id,
        name: s.name,
        cover: Value(s.cover),
        backdrop: Value(s.backdrop),
        plot: Value(s.plot),
        rating: Value(s.rating),
        year: Value(s.year),
        genre: Value(s.genre),
        updatedAt: Value(s.updatedAt),
        categoryId: Value(s.categoryId),
        sortIndex: s.sortIndex,
      );

  static EpisodesCompanion _episodeRow(String accountId, CatalogEpisode e) => EpisodesCompanion.insert(
        accountId: accountId,
        id: e.id,
        seriesId: e.seriesId,
        season: e.season,
        episode: e.episode,
        title: e.title,
        containerExt: Value(e.containerExt),
        streamUrl: Value(e.streamUrl),
        durationSecs: Value(e.durationSecs),
        plot: Value(e.plot),
        still: Value(e.still),
        airDate: Value(e.airDate),
      );

  Future<void> _setCount(String accountId, {int? liveCount, int? movieCount, int? seriesCount}) =>
      (_db.update(_db.accounts)..where((a) => a.id.equals(accountId))).write(AccountsCompanion(
        liveCount: liveCount == null ? const Value.absent() : Value(liveCount),
        movieCount: movieCount == null ? const Value.absent() : Value(movieCount),
        seriesCount: seriesCount == null ? const Value.absent() : Value(seriesCount),
      ));

  // --- Reading ----------------------------------------------------------------------

  Stream<List<MediaCategory>> watchCategories(String accountId, ContentKind kind, {bool hideAdult = false}) {
    final q = _db.select(_db.categories)
      ..where((c) => c.accountId.equals(accountId) & c.kind.equalsValue(kind))
      ..orderBy([(c) => OrderingTerm.asc(c.sortIndex)]);
    if (hideAdult) q.where((c) => c.isAdult.equals(false));
    return q.watch();
  }

  /// Items per category ("Sports 142") — keys are category ids.
  Stream<Map<String, int>> watchCategoryCounts(String accountId, ContentKind kind) {
    final (String table, ResultSetImplementation<Object?, Object?> tableInfo) = switch (kind) {
      ContentKind.live => ('channels', _db.channels),
      ContentKind.movie => ('movies', _db.movies),
      ContentKind.series => ('series', _db.seriesTable),
    };
    return _db
        .customSelect(
          'SELECT category_id AS id, COUNT(*) AS n FROM $table WHERE account_id = ? AND category_id IS NOT NULL GROUP BY category_id',
          variables: [Variable.withString(accountId)],
          readsFrom: {tableInfo},
        )
        .watch()
        .map((rows) => {for (final r in rows) r.read<String>('id'): r.read<int>('n')});
  }

  Stream<List<Channel>> watchChannels(String accountId, {String? categoryId, Set<String>? excludeCategoryIds}) {
    final q = _db.select(_db.channels)..where((c) => c.accountId.equals(accountId));
    if (categoryId != null) q.where((c) => c.categoryId.equals(categoryId));
    if (excludeCategoryIds != null && excludeCategoryIds.isNotEmpty) {
      q.where((c) => c.categoryId.isNull() | c.categoryId.isNotIn(excludeCategoryIds));
    }
    q.orderBy([(c) => OrderingTerm.asc(c.sortIndex)]);
    return q.watch();
  }

  Future<Channel?> channel(String accountId, String id) =>
      (_db.select(_db.channels)..where((c) => c.accountId.equals(accountId) & c.id.equals(id))).getSingleOrNull();

  /// The channel before/after [id] in list order — player channel up/down.
  Future<Channel?> adjacentChannel(String accountId, String id, {required bool next, String? categoryId}) async {
    final current = await channel(accountId, id);
    if (current == null) return null;
    final q = _db.select(_db.channels)..where((c) => c.accountId.equals(accountId));
    if (categoryId != null) q.where((c) => c.categoryId.equals(categoryId));
    q
      ..where((c) => next ? c.sortIndex.isBiggerThanValue(current.sortIndex) : c.sortIndex.isSmallerThanValue(current.sortIndex))
      ..orderBy([(c) => next ? OrderingTerm.asc(c.sortIndex) : OrderingTerm.desc(c.sortIndex)])
      ..limit(1);
    return q.getSingleOrNull();
  }

  Stream<List<Movie>> watchMovies(String accountId, {String? categoryId, MovieSort sort = MovieSort.playlist, int? limit}) {
    final q = _db.select(_db.movies)..where((m) => m.accountId.equals(accountId));
    if (categoryId != null) q.where((m) => m.categoryId.equals(categoryId));
    q.orderBy([
      switch (sort) {
        MovieSort.playlist => (m) => OrderingTerm.asc(m.sortIndex),
        MovieSort.recentlyAdded => (m) => OrderingTerm(expression: m.addedAt, mode: OrderingMode.desc, nulls: NullsOrder.last),
        MovieSort.rating => (m) => OrderingTerm(expression: m.rating, mode: OrderingMode.desc, nulls: NullsOrder.last),
        MovieSort.name => (m) => OrderingTerm.asc(m.name.collate(Collate.noCase)),
      },
    ]);
    if (limit != null) q.limit(limit);
    return q.watch();
  }

  Stream<Movie?> watchMovie(String accountId, String id) =>
      (_db.select(_db.movies)..where((m) => m.accountId.equals(accountId) & m.id.equals(id))).watchSingleOrNull();

  Stream<Show?> watchShow(String accountId, String id) =>
      (_db.select(_db.seriesTable)..where((s) => s.accountId.equals(accountId) & s.id.equals(id))).watchSingleOrNull();

  Future<Movie?> movie(String accountId, String id) =>
      (_db.select(_db.movies)..where((m) => m.accountId.equals(accountId) & m.id.equals(id))).getSingleOrNull();

  Stream<List<Show>> watchSeries(String accountId, {String? categoryId, MovieSort sort = MovieSort.playlist, int? limit}) {
    final q = _db.select(_db.seriesTable)..where((s) => s.accountId.equals(accountId));
    if (categoryId != null) q.where((s) => s.categoryId.equals(categoryId));
    q.orderBy([
      switch (sort) {
        MovieSort.playlist => (s) => OrderingTerm.asc(s.sortIndex),
        MovieSort.recentlyAdded => (s) => OrderingTerm(expression: s.updatedAt, mode: OrderingMode.desc, nulls: NullsOrder.last),
        MovieSort.rating => (s) => OrderingTerm(expression: s.rating, mode: OrderingMode.desc, nulls: NullsOrder.last),
        MovieSort.name => (s) => OrderingTerm.asc(s.name.collate(Collate.noCase)),
      },
    ]);
    if (limit != null) q.limit(limit);
    return q.watch();
  }

  Future<Show?> show(String accountId, String id) =>
      (_db.select(_db.seriesTable)..where((s) => s.accountId.equals(accountId) & s.id.equals(id))).getSingleOrNull();

  Future<List<Episode>> episodes(String accountId, String seriesId) => (_db.select(_db.episodes)
        ..where((e) => e.accountId.equals(accountId) & e.seriesId.equals(seriesId))
        ..orderBy([(e) => OrderingTerm.asc(e.season), (e) => OrderingTerm.asc(e.episode)]))
      .get();

  /// Instant search across channels, movies and series (name contains).
  Future<SearchResults> search(String accountId, String query, {int limit = 40}) async {
    final q = query.trim();
    if (q.isEmpty) return const SearchResults();
    final pattern = '%${q.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_')}%';
    final channels = await (_db.select(_db.channels)
          ..where((c) => c.accountId.equals(accountId) & c.name.like(pattern, escapeChar: r'\'))
          ..orderBy([(c) => OrderingTerm.asc(c.sortIndex)])
          ..limit(limit))
        .get();
    final movies = await (_db.select(_db.movies)
          ..where((m) => m.accountId.equals(accountId) & m.name.like(pattern, escapeChar: r'\'))
          ..orderBy([(m) => OrderingTerm(expression: m.rating, mode: OrderingMode.desc, nulls: NullsOrder.last)])
          ..limit(limit))
        .get();
    final series = await (_db.select(_db.seriesTable)
          ..where((s) => s.accountId.equals(accountId) & s.name.like(pattern, escapeChar: r'\'))
          ..orderBy([(s) => OrderingTerm(expression: s.rating, mode: OrderingMode.desc, nulls: NullsOrder.last)])
          ..limit(limit))
        .get();
    return SearchResults(channels: channels, movies: movies, series: series);
  }

  // --- Details (Xtream fetches on demand) ----------------------------------------------

  /// Movie details; null for M3U accounts (playlists carry no metadata).
  Future<MovieDetails?> movieDetails(String accountId, String movieId, {CancelToken? cancel}) async {
    final client = await _xtream(accountId);
    return client?.vodInfo(movieId, cancel: cancel);
  }

  /// Series with all episodes. Xtream: fetched and cached; M3U: from the
  /// imported playlist.
  Future<SeriesDetails?> seriesDetails(String accountId, String seriesId, {CancelToken? cancel}) async {
    final client = await _xtream(accountId);
    if (client != null) {
      final details = await client.seriesInfo(seriesId, cancel: cancel);
      await _db.transaction(() async {
        await (_db.delete(_db.episodes)..where((e) => e.accountId.equals(accountId) & e.seriesId.equals(seriesId))).go();
        await _db.batch((b) => b.insertAll(_db.episodes, [for (final e in details.episodes) _episodeRow(accountId, e)], mode: InsertMode.insertOrReplace));
      });
      return details;
    }
    final show = await this.show(accountId, seriesId);
    if (show == null) return null;
    final eps = await episodes(accountId, seriesId);
    final seasons = eps.map((e) => e.season).toSet().toList()..sort();
    return SeriesDetails(
      series: CatalogSeries(id: show.id, name: show.name, cover: show.cover, backdrop: show.backdrop, plot: show.plot, rating: show.rating, year: show.year, genre: show.genre),
      seasons: [for (final s in seasons) SeasonInfo(number: s, episodeCount: eps.where((e) => e.season == s).length)],
      episodes: [
        for (final e in eps)
          CatalogEpisode(
            id: e.id,
            seriesId: e.seriesId,
            season: e.season,
            episode: e.episode,
            title: e.title,
            containerExt: e.containerExt,
            streamUrl: e.streamUrl,
            durationSecs: e.durationSecs,
            plot: e.plot,
            still: e.still,
            airDate: e.airDate,
          ),
      ],
    );
  }

  // --- Playback URLs --------------------------------------------------------------------

  Future<ResolvedStream> channelStream(String accountId, Channel channel, {XtreamLiveFormat format = XtreamLiveFormat.ts}) async {
    if (channel.streamUrl != null) return ResolvedStream(channel.streamUrl!, headers: _headers(channel.headers));
    final client = await _requireXtream(accountId);
    return ResolvedStream(client.liveUrl(channel.id, format: format));
  }

  Future<ResolvedStream> movieStream(String accountId, Movie movie) async {
    if (movie.streamUrl != null) return ResolvedStream(movie.streamUrl!);
    final client = await _requireXtream(accountId);
    return ResolvedStream(client.movieUrl(movie.id, movie.containerExt));
  }

  Future<ResolvedStream> episodeStream(String accountId, CatalogEpisode episode) async {
    if (episode.streamUrl != null) return ResolvedStream(episode.streamUrl!);
    final client = await _requireXtream(accountId);
    return ResolvedStream(client.episodeUrl(episode.id, episode.containerExt));
  }

  static Map<String, String> _headers(String? json) =>
      json == null ? const {} : (jsonDecode(json) as Map).map((k, v) => MapEntry('$k', '$v'));

  Future<XtreamClient?> _xtream(String accountId) async {
    final creds = await _credentials.load(accountId);
    return creds is XtreamCredentials ? XtreamClient(_dio, creds) : null;
  }

  Future<XtreamClient> _requireXtream(String accountId) async =>
      await _xtream(accountId) ?? (throw const InvalidCredentialsFailure());
}

import 'package:drift/drift.dart';

import '../db/database.dart';
import '../models/catalog.dart';

/// A removed favorite, kept for "Undo" (Favorites screen snackbar).
class RemovedFavorite {
  const RemovedFavorite(this.favorite);

  final Favorite favorite;
}

/// "Continue watching" — a resume point with what it belongs to.
class ContinueItem {
  const ContinueItem({required this.progress, this.movie, this.episode, this.show});

  final WatchProgress progress;
  final Movie? movie;
  final Episode? episode;
  final Show? show;

  double get fraction => progress.durationMs == 0 ? 0 : (progress.positionMs / progress.durationMs).clamp(0, 1);
  Duration get remaining => Duration(milliseconds: (progress.durationMs - progress.positionMs).clamp(0, 1 << 62));
}

/// Favorites and watch progress — both per account, both local only.
class LibraryRepository {
  LibraryRepository(this._db);

  final OrbixDatabase _db;

  /// Below this a title counts as "not started" (no resume prompt).
  static const minResume = Duration(seconds: 30);

  // --- Favorites ----------------------------------------------------------------

  Stream<bool> watchIsFavorite(String accountId, ContentKind kind, String itemId) =>
      (_db.select(_db.favorites)..where((f) => f.accountId.equals(accountId) & f.kind.equalsValue(kind) & f.itemId.equals(itemId)))
          .watchSingleOrNull()
          .map((f) => f != null);

  Stream<Set<String>> watchFavoriteIds(String accountId, ContentKind kind) =>
      (_db.select(_db.favorites)..where((f) => f.accountId.equals(accountId) & f.kind.equalsValue(kind))).watch().map((rows) => {for (final r in rows) r.itemId});

  /// Adds at the end, or removes. Returns the new state.
  Future<bool> toggleFavorite(String accountId, ContentKind kind, String itemId, {DateTime? now}) => _db.transaction(() async {
        final where = (_db.delete(_db.favorites)..where((f) => f.accountId.equals(accountId) & f.kind.equalsValue(kind) & f.itemId.equals(itemId)));
        if (await where.go() > 0) return false;
        await _db.into(_db.favorites).insert(FavoritesCompanion.insert(
              accountId: accountId,
              kind: kind,
              itemId: itemId,
              position: await _nextPosition(accountId, kind),
              addedAt: now ?? DateTime.now(),
            ));
        return true;
      });

  Future<int> _nextPosition(String accountId, ContentKind kind) async {
    final max = _db.favorites.position.max();
    final row = await (_db.selectOnly(_db.favorites)
          ..addColumns([max])
          ..where(_db.favorites.accountId.equals(accountId) & _db.favorites.kind.equalsValue(kind)))
        .getSingle();
    return (row.read(max) ?? -1) + 1;
  }

  /// Removes and returns what is needed to [restoreFavorite] (undo).
  Future<RemovedFavorite?> removeFavorite(String accountId, ContentKind kind, String itemId) => _db.transaction(() async {
        final q = _db.select(_db.favorites)..where((f) => f.accountId.equals(accountId) & f.kind.equalsValue(kind) & f.itemId.equals(itemId));
        final row = await q.getSingleOrNull();
        if (row == null) return null;
        await (_db.delete(_db.favorites)..where((f) => f.accountId.equals(accountId) & f.kind.equalsValue(kind) & f.itemId.equals(itemId))).go();
        return RemovedFavorite(row);
      });

  /// Puts a removed favorite back at its old position.
  Future<void> restoreFavorite(RemovedFavorite removed) => _db.into(_db.favorites).insert(removed.favorite, mode: InsertMode.insertOrReplace);

  /// Drag-to-reorder: [orderedItemIds] is the full new order.
  Future<void> reorderFavorites(String accountId, ContentKind kind, List<String> orderedItemIds) => _db.batch((b) {
        for (var i = 0; i < orderedItemIds.length; i++) {
          b.update(
            _db.favorites,
            FavoritesCompanion(position: Value(i)),
            where: (f) => f.accountId.equals(accountId) & f.kind.equalsValue(kind) & f.itemId.equals(orderedItemIds[i]),
          );
        }
      });

  Stream<List<Channel>> watchFavoriteChannels(String accountId) {
    final q = _db.select(_db.channels).join([
      innerJoin(
        _db.favorites,
        _db.favorites.accountId.equalsExp(_db.channels.accountId) &
            _db.favorites.itemId.equalsExp(_db.channels.id) &
            _db.favorites.kind.equalsValue(ContentKind.live),
      ),
    ])
      ..where(_db.channels.accountId.equals(accountId))
      ..orderBy([OrderingTerm.asc(_db.favorites.position)]);
    return q.watch().map((rows) => [for (final r in rows) r.readTable(_db.channels)]);
  }

  Stream<List<Movie>> watchFavoriteMovies(String accountId) {
    final q = _db.select(_db.movies).join([
      innerJoin(
        _db.favorites,
        _db.favorites.accountId.equalsExp(_db.movies.accountId) &
            _db.favorites.itemId.equalsExp(_db.movies.id) &
            _db.favorites.kind.equalsValue(ContentKind.movie),
      ),
    ])
      ..where(_db.movies.accountId.equals(accountId))
      ..orderBy([OrderingTerm.asc(_db.favorites.position)]);
    return q.watch().map((rows) => [for (final r in rows) r.readTable(_db.movies)]);
  }

  Stream<List<Show>> watchFavoriteSeries(String accountId) {
    final q = _db.select(_db.seriesTable).join([
      innerJoin(
        _db.favorites,
        _db.favorites.accountId.equalsExp(_db.seriesTable.accountId) &
            _db.favorites.itemId.equalsExp(_db.seriesTable.id) &
            _db.favorites.kind.equalsValue(ContentKind.series),
      ),
    ])
      ..where(_db.seriesTable.accountId.equals(accountId))
      ..orderBy([OrderingTerm.asc(_db.favorites.position)]);
    return q.watch().map((rows) => [for (final r in rows) r.readTable(_db.seriesTable)]);
  }

  // --- Watch progress ---------------------------------------------------------------

  /// Saves a resume point (call every few seconds while playing and on exit).
  /// Within 95 % or the last minute counts as watched.
  Future<void> saveProgress(
    String accountId,
    ProgressKind kind,
    String itemId, {
    required Duration position,
    required Duration duration,
    String? seriesId,
    DateTime? now,
  }) {
    final p = position.inMilliseconds, d = duration.inMilliseconds;
    final completed = d > 0 && (p >= d * 0.95 || d - p < 60000);
    return _db.into(_db.watchProgressEntries).insertOnConflictUpdate(WatchProgressEntriesCompanion.insert(
          accountId: accountId,
          kind: kind,
          itemId: itemId,
          seriesId: Value(seriesId),
          positionMs: Value(p),
          durationMs: Value(d),
          completed: Value(completed),
          updatedAt: now ?? DateTime.now(),
        ));
  }

  /// Records that a live channel was watched ("Recently watched").
  Future<void> recordLiveWatch(String accountId, String channelId, {DateTime? now}) => _db.into(_db.watchProgressEntries).insertOnConflictUpdate(
        WatchProgressEntriesCompanion.insert(accountId: accountId, kind: ProgressKind.live, itemId: channelId, updatedAt: now ?? DateTime.now()),
      );

  Stream<WatchProgress?> watchProgress(String accountId, ProgressKind kind, String itemId) => (_db.select(_db.watchProgressEntries)
        ..where((p) => p.accountId.equals(accountId) & p.kind.equalsValue(kind) & p.itemId.equals(itemId)))
      .watchSingleOrNull();

  Future<WatchProgress?> progress(String accountId, ProgressKind kind, String itemId) => (_db.select(_db.watchProgressEntries)
        ..where((p) => p.accountId.equals(accountId) & p.kind.equalsValue(kind) & p.itemId.equals(itemId)))
      .getSingleOrNull();

  /// Where to resume, or null to start from the beginning.
  Future<Duration?> resumePosition(String accountId, ProgressKind kind, String itemId) async {
    final p = await progress(accountId, kind, itemId);
    if (p == null || p.completed || p.positionMs < minResume.inMilliseconds) return null;
    return Duration(milliseconds: p.positionMs);
  }

  Future<void> markWatched(String accountId, ProgressKind kind, String itemId, {bool watched = true, String? seriesId}) async {
    if (!watched) {
      await (_db.delete(_db.watchProgressEntries)..where((p) => p.accountId.equals(accountId) & p.kind.equalsValue(kind) & p.itemId.equals(itemId))).go();
      return;
    }
    final existing = await progress(accountId, kind, itemId);
    await _db.into(_db.watchProgressEntries).insertOnConflictUpdate(WatchProgressEntriesCompanion.insert(
          accountId: accountId,
          kind: kind,
          itemId: itemId,
          seriesId: Value(seriesId ?? existing?.seriesId),
          positionMs: Value(existing?.durationMs ?? 0),
          durationMs: Value(existing?.durationMs ?? 0),
          completed: const Value(true),
          updatedAt: DateTime.now(),
        ));
  }

  /// Episode progress for one series (episode id → progress).
  Stream<Map<String, WatchProgress>> watchSeriesProgress(String accountId, String seriesId) => (_db.select(_db.watchProgressEntries)
        ..where((p) => p.accountId.equals(accountId) & p.kind.equalsValue(ProgressKind.episode) & p.seriesId.equals(seriesId)))
      .watch()
      .map((rows) => {for (final r in rows) r.itemId: r});

  /// Started, unfinished movies and episodes, most recent first.
  Stream<List<ContinueItem>> watchContinueWatching(String accountId, {int limit = 20}) {
    final q = _db.select(_db.watchProgressEntries).join([
      leftOuterJoin(
        _db.movies,
        _db.movies.accountId.equalsExp(_db.watchProgressEntries.accountId) &
            _db.movies.id.equalsExp(_db.watchProgressEntries.itemId) &
            _db.watchProgressEntries.kind.equalsValue(ProgressKind.movie),
      ),
      leftOuterJoin(
        _db.episodes,
        _db.episodes.accountId.equalsExp(_db.watchProgressEntries.accountId) &
            _db.episodes.id.equalsExp(_db.watchProgressEntries.itemId) &
            _db.watchProgressEntries.kind.equalsValue(ProgressKind.episode),
      ),
      leftOuterJoin(
        _db.seriesTable,
        _db.seriesTable.accountId.equalsExp(_db.watchProgressEntries.accountId) & _db.seriesTable.id.equalsExp(_db.watchProgressEntries.seriesId),
      ),
    ])
      ..where(_db.watchProgressEntries.accountId.equals(accountId) &
          _db.watchProgressEntries.kind.isNotValue(ProgressKind.live.name) &
          _db.watchProgressEntries.completed.equals(false) &
          _db.watchProgressEntries.positionMs.isBiggerOrEqualValue(minResume.inMilliseconds))
      ..orderBy([OrderingTerm.desc(_db.watchProgressEntries.updatedAt)])
      ..limit(limit);
    return q.watch().map((rows) => [
          for (final r in rows)
            ContinueItem(
              progress: r.readTable(_db.watchProgressEntries),
              movie: r.readTableOrNull(_db.movies),
              episode: r.readTableOrNull(_db.episodes),
              show: r.readTableOrNull(_db.seriesTable),
            ),
        ]);
  }

  /// Finished movies, most recent first (Home › Recently watched).
  Stream<List<Movie>> watchRecentlyFinishedMovies(String accountId, {int limit = 12}) {
    final q = _db.select(_db.movies).join([
      innerJoin(
        _db.watchProgressEntries,
        _db.watchProgressEntries.accountId.equalsExp(_db.movies.accountId) &
            _db.watchProgressEntries.itemId.equalsExp(_db.movies.id) &
            _db.watchProgressEntries.kind.equalsValue(ProgressKind.movie) &
            _db.watchProgressEntries.completed.equals(true),
      ),
    ])
      ..where(_db.movies.accountId.equals(accountId))
      ..orderBy([OrderingTerm.desc(_db.watchProgressEntries.updatedAt)])
      ..limit(limit);
    return q.watch().map((rows) => [for (final r in rows) r.readTable(_db.movies)]);
  }

  /// Recently watched live channels, most recent first.
  Stream<List<Channel>> watchRecentChannels(String accountId, {int limit = 20}) {
    final q = _db.select(_db.channels).join([
      innerJoin(
        _db.watchProgressEntries,
        _db.watchProgressEntries.accountId.equalsExp(_db.channels.accountId) &
            _db.watchProgressEntries.itemId.equalsExp(_db.channels.id) &
            _db.watchProgressEntries.kind.equalsValue(ProgressKind.live),
      ),
    ])
      ..where(_db.channels.accountId.equals(accountId))
      ..orderBy([OrderingTerm.desc(_db.watchProgressEntries.updatedAt)])
      ..limit(limit);
    return q.watch().map((rows) => [for (final r in rows) r.readTable(_db.channels)]);
  }

  /// Settings › clear history.
  Future<void> clearHistory(String accountId) => (_db.delete(_db.watchProgressEntries)..where((p) => p.accountId.equals(accountId))).go();
}

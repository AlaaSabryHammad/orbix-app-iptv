import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';

import '../core/failures.dart';
import '../credentials/credential_store.dart';
import '../credentials/credentials.dart';
import '../db/database.dart';
import '../models/catalog.dart';
import '../sources/epg/xmltv_parser.dart';
import '../sources/m3u/playlist_loader.dart';
import '../sources/xtream/xtream_client.dart';

/// Guide refresh progress (States 03 "Updating 62%").
class GuideProgress {
  const GuideProgress({required this.fraction, required this.source, required this.sourceCount, this.programmes = 0});

  /// 0…1 across all sources.
  final double fraction;

  /// 1-based index of the source being processed.
  final int source;
  final int sourceCount;
  final int programmes;
}

/// What's on now and next on one channel.
class NowNext {
  const NowNext(this.now, this.next);

  final EpgProgramme? now;
  final EpgProgramme? next;

  /// Elapsed share of [now] at [at] (0…1).
  double progressAt(DateTime at) {
    final p = now;
    if (p == null) return 0;
    final total = p.stop.difference(p.start).inSeconds;
    return total <= 0 ? 0 : (at.difference(p.start).inSeconds / total).clamp(0, 1);
  }
}

/// The cached TV guide: refreshing it from XMLTV sources and querying it.
class EpgRepository {
  EpgRepository(this._db, this._dio, this._credentials, {Future<Directory> Function()? tempDir}) : _tempDir = tempDir ?? getTemporaryDirectory;

  final OrbixDatabase _db;
  final Dio _dio;
  final CredentialStore _credentials;
  final Future<Directory> Function() _tempDir;

  /// Keep 12 h of history (for "started 20 min ago") and 7 days ahead.
  static const history = Duration(hours: 12);
  static const ahead = Duration(days: 7);

  /// Guide URLs in priority order: the user's own EPG URL first, then the
  /// provider's (Xtream `xmltv.php`) or the playlist's advertised guides.
  Future<List<String>> sources(String accountId) async {
    final creds = await _credentials.load(accountId);
    final urls = <String>[
      ?creds?.epgUrl,
      ...switch (creds) {
        XtreamCredentials() => [XtreamClient(_dio, creds).xmltvUri.toString()],
        PlaylistCredentials() => creds.headerEpgUrls,
        null => const <String>[],
      },
    ];
    return urls.map((u) => u.trim()).where((u) => u.isNotEmpty).toSet().toList();
  }

  /// Downloads and imports every guide source. Emits progress; errors with
  /// the first failure only if every source failed. Earlier sources win when
  /// two describe the same programme.
  Stream<GuideProgress> refresh(Account account, {DateTime? now, CancelToken? cancel}) {
    final out = StreamController<GuideProgress>();
    () async {
      final at = (now ?? DateTime.now()).toUtc();
      try {
        final urls = await sources(account.id);
        if (urls.isEmpty) throw const InvalidGuideFailure('No guide source');
        final channelIds = await _channelEpgIds(account.id);
        final filter = XmltvFilter(channelIds: channelIds.isEmpty ? null : channelIds, from: at.subtract(history), to: at.add(ahead));
        final n = urls.length;
        final results = <List<GuideEntry>>[];
        OrbixFailure? firstFailure;
        final dir = await _tempDir();

        for (var i = 0; i < n; i++) {
          void report(double within) => out.add(GuideProgress(fraction: (i + within) / n * 0.9, source: i + 1, sourceCount: n));
          final file = File('${dir.path}/orbix_epg_${account.id}_$i.xml');
          try {
            report(0);
            await PlaylistLoader(_dio).downloadToFile(
              urls[i],
              file,
              cancel: cancel,
              onBytes: (r, t) => t > 0 ? report(0.5 * r / t) : null,
            );
            final result = await XmltvParser.parseFile(file.path, filter: filter, onProgress: (p) => report(0.5 + 0.5 * p));
            results.add(result.programmes);
          } catch (e) {
            final f = OrbixFailure.from(e);
            if (f is CancelledFailure) rethrow;
            firstFailure ??= f;
          } finally {
            if (await file.exists()) await file.delete();
          }
        }
        if (results.isEmpty) throw firstFailure ?? const InvalidGuideFailure('No guide data');

        var written = 0;
        await _db.transaction(() async {
          await (_db.delete(_db.epgProgrammes)..where((p) => p.accountId.equals(account.id))).go();
          final total = results.fold<int>(0, (a, r) => a + r.length);
          for (final list in results) {
            for (var i = 0; i < list.length; i += 2000) {
              final end = i + 2000 < list.length ? i + 2000 : list.length;
              await _db.batch((b) => b.insertAll(
                    _db.epgProgrammes,
                    [for (var j = i; j < end; j++) _row(account.id, list[j])],
                    mode: InsertMode.insertOrIgnore,
                  ));
              written += end - i;
              out.add(GuideProgress(fraction: 0.9 + 0.1 * written / (total == 0 ? 1 : total), source: n, sourceCount: n, programmes: written));
            }
          }
          await (_db.update(_db.accounts)..where((a) => a.id.equals(account.id)))
              .write(AccountsCompanion(guideUpdatedAt: Value(DateTime.now()), guideSourceCount: Value(results.length)));
        });
        out.add(GuideProgress(fraction: 1, source: n, sourceCount: n, programmes: written));
      } catch (e) {
        out.addError(OrbixFailure.from(e));
      } finally {
        await out.close();
      }
    }();
    return out.stream;
  }

  Future<Set<String>> _channelEpgIds(String accountId) async {
    final rows = await (_db.selectOnly(_db.channels, distinct: true)
          ..addColumns([_db.channels.epgId])
          ..where(_db.channels.accountId.equals(accountId) & _db.channels.epgId.isNotNull()))
        .get();
    return {for (final r in rows) r.read(_db.channels.epgId)!};
  }

  static EpgProgrammesCompanion _row(String accountId, GuideEntry e) => EpgProgrammesCompanion.insert(
        accountId: accountId,
        channelId: e.channelId,
        start: e.start,
        stop: e.stop,
        title: e.title,
        description: Value(e.description),
        category: Value(e.category),
        image: Value(e.image),
      );

  /// Xtream fallback when a channel has no XMLTV data: fetches the short EPG
  /// and caches it.
  Future<void> fetchShortEpg(String accountId, Channel channel) async {
    final creds = await _credentials.load(accountId);
    if (creds is! XtreamCredentials) return;
    final entries = await XtreamClient(_dio, creds).shortEpg(channel.id, epgChannelId: channel.epgId ?? 'stream:${channel.id}');
    await _db.batch((b) => b.insertAll(_db.epgProgrammes, [for (final e in entries) _row(accountId, e)], mode: InsertMode.insertOrIgnore));
  }

  /// Guide channel id used for [channel] — its tvg-id, or the short-EPG key.
  static String guideIdOf(Channel channel) => channel.epgId ?? 'stream:${channel.id}';

  // --- Queries (times shifted by the account's guide time shift) -------------------------

  Future<Duration> _shift(String accountId) async {
    final a = await (_db.select(_db.accounts)..where((a) => a.id.equals(accountId))).getSingleOrNull();
    return Duration(minutes: a?.guideShiftMinutes ?? 0);
  }

  static EpgProgramme _shifted(EpgProgramme p, Duration shift) =>
      shift == Duration.zero ? p : p.copyWith(start: p.start.add(shift), stop: p.stop.add(shift));

  /// Now / next for many channels at once (Live TV list, player).
  Future<Map<String, NowNext>> nowNext(String accountId, Iterable<String> channelIds, {DateTime? at}) async {
    final ids = channelIds.toSet();
    if (ids.isEmpty) return const {};
    final shift = await _shift(accountId);
    final t = (at ?? DateTime.now()).toUtc().subtract(shift);
    final rows = await (_db.select(_db.epgProgrammes)
          ..where((p) =>
              p.accountId.equals(accountId) &
              p.channelId.isIn(ids) &
              p.stop.isBiggerThanValue(t) &
              p.start.isSmallerThanValue(t.add(const Duration(hours: 12))))
          ..orderBy([(p) => OrderingTerm.asc(p.channelId), (p) => OrderingTerm.asc(p.start)]))
        .get();
    final out = <String, NowNext>{};
    final grouped = <String, List<EpgProgramme>>{};
    for (final r in rows) {
      (grouped[r.channelId] ??= []).add(r);
    }
    for (final MapEntry(key: id, value: list) in grouped.entries) {
      final nowIdx = list.indexWhere((p) => !p.start.isAfter(t));
      final now = nowIdx >= 0 ? list[nowIdx] : null;
      final next = nowIdx >= 0 ? (nowIdx + 1 < list.length ? list[nowIdx + 1] : null) : list.first;
      out[id] = NowNext(now == null ? null : _shifted(now, shift), next == null ? null : _shifted(next, shift));
    }
    return out;
  }

  /// Programmes overlapping [from, to) for the guide grid, by channel.
  Future<Map<String, List<EpgProgramme>>> programmes(String accountId, Iterable<String> channelIds, DateTime from, DateTime to) async {
    final shift = await _shift(accountId);
    final f = from.toUtc().subtract(shift), u = to.toUtc().subtract(shift);
    final rows = await (_db.select(_db.epgProgrammes)
          ..where((p) => p.accountId.equals(accountId) & p.channelId.isIn(channelIds.toSet()) & p.stop.isBiggerThanValue(f) & p.start.isSmallerThanValue(u))
          ..orderBy([(p) => OrderingTerm.asc(p.channelId), (p) => OrderingTerm.asc(p.start)]))
        .get();
    final out = <String, List<EpgProgramme>>{};
    for (final r in rows) {
      (out[r.channelId] ??= []).add(_shifted(r, shift));
    }
    return out;
  }

  /// First and last day with guide data ("7 days").
  Future<(DateTime, DateTime)?> coverage(String accountId) async {
    final min = _db.epgProgrammes.start.min();
    final max = _db.epgProgrammes.stop.max();
    final row = await (_db.selectOnly(_db.epgProgrammes)
          ..addColumns([min, max])
          ..where(_db.epgProgrammes.accountId.equals(accountId)))
        .getSingle();
    final a = row.read(min), b = row.read(max);
    return a == null || b == null ? null : (a, b);
  }

  /// Drops programmes that ended more than [history] ago.
  Future<int> prune(String accountId, {DateTime? now}) => (_db.delete(_db.epgProgrammes)
        ..where((p) => p.accountId.equals(accountId) & p.stop.isSmallerThanValue((now ?? DateTime.now()).toUtc().subtract(history))))
      .go();
}

import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbix/data/data.dart';

import '../support/fake_http.dart';

void main() {
  late OrbixDatabase db;
  late MemorySecretStore secrets;
  late CredentialStore creds;
  late AccountRepository accounts;
  late LibraryRepository library;

  final xtream = XtreamCredentials(serverUrl: 'line.example:8080', username: 'user', password: 'pass');

  setUp(() {
    db = OrbixDatabase(NativeDatabase.memory());
    secrets = MemorySecretStore();
    creds = CredentialStore(secrets);
    accounts = AccountRepository(db, creds);
    library = LibraryRepository(db);
  });
  tearDown(() => db.close());

  group('AccountRepository', () {
    test('first account is default; credentials are not in the database', () async {
      final a = await accounts.create(name: ' Living Room ', kind: AccountKind.xtream, credentials: xtream);
      final b = await accounts.create(name: 'Sports Pack', kind: AccountKind.xtream, credentials: xtream);
      expect(a.name, 'Living Room');
      expect(a.isDefault, isTrue);
      expect(b.isDefault, isFalse);
      expect(a.displayHost, 'line.example:8080');
      expect((await accounts.credentials(a.id)) is XtreamCredentials, isTrue);
      expect(secrets.values.keys, everyElement(startsWith('account.')));

      // Nothing secret reaches SQLite.
      final dump = (await db.customSelect('SELECT * FROM accounts').get()).map((r) => r.data.values.join('|')).join('\n');
      expect(dump, isNot(contains('pass')));

      await accounts.setDefault(b.id);
      expect((await accounts.defaultAccount())?.id, b.id);
    });

    test('delete cascades and hands default to the next account', () async {
      final a = await accounts.create(name: 'A', kind: AccountKind.xtream, credentials: xtream);
      final b = await accounts.create(name: 'B', kind: AccountKind.xtream, credentials: xtream);
      await library.toggleFavorite(a.id, ContentKind.live, '1001');
      await library.saveProgress(a.id, ProgressKind.movie, '5001', position: const Duration(minutes: 10), duration: const Duration(minutes: 100));

      await accounts.delete(a.id);
      expect(await accounts.byId(a.id), isNull);
      expect(await accounts.credentials(a.id), isNull);
      expect(await db.favorites.count().getSingle(), 0);
      expect(await db.watchProgressEntries.count().getSingle(), 0);
      expect((await accounts.byId(b.id))!.isDefault, isTrue);
    });
  });

  group('CatalogRepository · Xtream', () {
    late CatalogRepository catalog;
    late Account account;

    setUp(() async {
      catalog = CatalogRepository(db, fakeDio(xtreamServer), creds);
      account = await accounts.create(name: 'Living Room', kind: AccountKind.xtream, credentials: xtream);
    });

    test('progressive sync: live is ready before movies and series', () async {
      final events = await catalog.sync(account).toList();
      final firstLiveReady = events.indexWhere((e) => e.liveReady);
      final firstMoviesReady = events.indexWhere((e) => e.movies.phase == SectionPhase.ready);
      expect(firstLiveReady, greaterThanOrEqualTo(0));
      expect(firstMoviesReady, greaterThan(firstLiveReady));
      expect(events[firstLiveReady].movies.phase, isNot(SectionPhase.ready));
      expect(events.last.finished, isTrue);
      expect(events.last.failure, isNull);

      final a = (await accounts.byId(account.id))!;
      expect((a.liveCount, a.movieCount, a.seriesCount), (3, 2, 1));
      expect(a.status, AccountStatus.active);
      expect(a.maxConnections, 2);
      expect(a.lastSyncedAt, isNotNull);
    });

    test('favorites survive a re-sync; counts per category; adult flag', () async {
      await catalog.sync(account).drain<void>();
      await library.toggleFavorite(account.id, ContentKind.live, '1002');
      await catalog.sync(account).drain<void>();
      expect((await library.watchFavoriteChannels(account.id).first).map((c) => c.name), ['Pulse Sports 1']);

      expect(await catalog.watchCategoryCounts(account.id, ContentKind.live).first, {'1': 1, '2': 2});
      final visible = await catalog.watchCategories(account.id, ContentKind.live, hideAdult: true).first;
      expect(visible.map((c) => c.name), ['News', 'Sports']);
    });

    test('wrong password fails every section without throwing', () async {
      await creds.save(account.id, XtreamCredentials(serverUrl: 'line.example:8080', username: 'user', password: 'bad'));
      final last = await catalog.sync(account).last;
      expect(last.finished, isTrue);
      expect(last.failure, isA<InvalidCredentialsFailure>());
      expect(last.live.phase, SectionPhase.failed);
      expect(last.series.phase, SectionPhase.failed);
    });

    test('queries: sorting, search, adjacent channel, details, stream URLs', () async {
      await catalog.sync(account).drain<void>();
      final byRating = await catalog.watchMovies(account.id, sort: MovieSort.rating).first;
      expect(byRating.map((m) => m.name), ['The Last Meridian (2026)', 'Iron Tide']);
      final recent = await catalog.watchMovies(account.id, sort: MovieSort.recentlyAdded, limit: 1).first;
      expect(recent.single.id, '5001');

      final found = await catalog.search(account.id, 'pulse');
      expect(found.channels.map((c) => c.name), ['Pulse Sports 1', 'Pulse Sports 2']);
      expect((await catalog.search(account.id, '100%')).isEmpty, isTrue, reason: 'LIKE wildcards are escaped');

      final next = await catalog.adjacentChannel(account.id, '1001', next: true);
      expect(next?.id, '1002');
      expect(await catalog.adjacentChannel(account.id, '1001', next: false), isNull);

      final details = await catalog.seriesDetails(account.id, '7001');
      expect(details!.episodes, hasLength(3));
      expect(await catalog.episodes(account.id, '7001'), hasLength(3), reason: 'cached for offline / progress joins');

      final ch = (await catalog.channel(account.id, '1001'))!;
      expect((await catalog.channelStream(account.id, ch)).url, 'http://line.example:8080/live/user/pass/1001.ts');
      final mv = (await catalog.movie(account.id, '5001'))!;
      expect((await catalog.movieStream(account.id, mv)).url, 'http://line.example:8080/movie/user/pass/5001.mkv');
    });
  });

  group('CatalogRepository · M3U', () {
    test('imports a prefetched playlist and keeps per-stream headers', () async {
      const pl = PlaylistCredentials(playlistUrl: 'http://list.example/get.m3u');
      final account = await accounts.create(name: 'Travel', kind: AccountKind.m3u, credentials: pl);
      final catalog = CatalogRepository(db, fakeDio((_) => sampleM3u), creds);

      final last = await catalog.sync(account).last;
      expect(last.failure, isNull);
      final a = (await accounts.byId(account.id))!;
      expect((a.liveCount, a.movieCount, a.seriesCount), (4, 2, 1));
      expect(a.displayHost, 'list.example');

      // Header guides were stored with the (secret) credentials.
      final stored = (await creds.load(account.id))! as PlaylistCredentials;
      expect(stored.headerEpgUrls, ['http://epg.example/guide.xml.gz', 'http://epg.example/b.xml']);

      final channels = await catalog.watchChannels(account.id).first;
      final pulse = channels.firstWhere((c) => c.name.startsWith('Pulse'));
      final stream = await catalog.channelStream(account.id, pulse);
      expect(stream.url, 'http://cdn.example/hls/pulse1/index.m3u8');
      expect(stream.headers['User-Agent'], 'OrbixTest/1.0');

      final series = await catalog.seriesDetails(account.id, (await catalog.watchSeries(account.id).first).single.id);
      expect(series!.seasons.map((s) => s.number), [1, 2]);
    });
  });

  group('LibraryRepository', () {
    late Account account;
    setUp(() async => account = await accounts.create(name: 'A', kind: AccountKind.xtream, credentials: xtream));

    test('toggle, remove + undo at the same position, reorder', () async {
      for (final id in ['a', 'b', 'c']) {
        expect(await library.toggleFavorite(account.id, ContentKind.movie, id), isTrue);
      }
      expect(await library.toggleFavorite(account.id, ContentKind.movie, 'b'), isFalse);
      await library.toggleFavorite(account.id, ContentKind.movie, 'b');
      Future<List<String>> order() async =>
          ((await (db.select(db.favorites)..orderBy([(f) => OrderingTerm.asc(f.position)])).get())).map((f) => f.itemId).toList();
      expect(await order(), ['a', 'c', 'b']);

      final removed = await library.removeFavorite(account.id, ContentKind.movie, 'a');
      expect(await order(), ['c', 'b']);
      await library.restoreFavorite(removed!);
      expect(await order(), ['a', 'c', 'b']);

      await library.reorderFavorites(account.id, ContentKind.movie, ['b', 'a', 'c']);
      expect(await order(), ['b', 'a', 'c']);
    });

    test('resume rules: under 30 s → start over; 95 % or last minute → watched', () async {
      Future<Duration?> resume(Duration pos, Duration dur) async {
        await library.saveProgress(account.id, ProgressKind.movie, 'm', position: pos, duration: dur);
        return library.resumePosition(account.id, ProgressKind.movie, 'm');
      }

      const d = Duration(minutes: 100);
      expect(await resume(const Duration(seconds: 20), d), isNull);
      expect(await resume(const Duration(minutes: 42, seconds: 13), d), const Duration(minutes: 42, seconds: 13));
      expect(await resume(const Duration(minutes: 96), d), isNull);
      expect(await resume(const Duration(minutes: 99, seconds: 10), const Duration(minutes: 200)), const Duration(minutes: 99, seconds: 10));
    });

    test('continue watching joins movies and episodes, newest first', () async {
      final catalog = CatalogRepository(db, fakeDio(xtreamServer), creds);
      await catalog.sync(account).drain<void>();
      await catalog.seriesDetails(account.id, '7001');

      await library.saveProgress(account.id, ProgressKind.movie, '5001',
          position: const Duration(minutes: 30), duration: const Duration(minutes: 138), now: DateTime(2026, 10, 1));
      await library.saveProgress(account.id, ProgressKind.episode, '9002',
          seriesId: '7001', position: const Duration(minutes: 5), duration: const Duration(minutes: 44), now: DateTime(2026, 10, 2));
      await library.saveProgress(account.id, ProgressKind.movie, '5002',
          position: const Duration(minutes: 90), duration: const Duration(minutes: 92), now: DateTime(2026, 10, 3));
      await library.recordLiveWatch(account.id, '1002');

      final items = await library.watchContinueWatching(account.id).first;
      expect(items.map((i) => i.progress.itemId), ['9002', '5001'], reason: 'finished 5002 and live entries excluded');
      expect(items.first.episode?.title, 'Northbound S01E02');
      expect(items.first.show?.name, 'Northbound');
      expect(items.last.movie?.name, 'The Last Meridian (2026)');
      expect(items.last.fraction, closeTo(30 / 138, 1e-9));

      expect((await library.watchRecentChannels(account.id).first).single.id, '1002');
      expect((await library.watchSeriesProgress(account.id, '7001').first).keys, ['9002']);
    });
  });

  group('EpgRepository', () {
    test('imports XMLTV for the account channels and answers now / next with time shift', () async {
      final dio = fakeDio(xtreamServer);
      final account = await accounts.create(name: 'A', kind: AccountKind.xtream, credentials: xtream);
      await CatalogRepository(db, dio, creds).sync(account).drain<void>();
      final tmp = await Directory.systemTemp.createTemp('epg');
      addTearDown(() => tmp.delete(recursive: true));
      final epg = EpgRepository(db, dio, creds, tempDir: () async => tmp);

      final now = DateTime.utc(2026, 10, 3, 20, 30);
      final progress = await epg.refresh(account, now: now).toList();
      expect(progress.last.fraction, 1.0);
      expect(progress.map((p) => p.fraction), orderedEquals([...progress.map((p) => p.fraction)]..sort()));
      expect(await db.epgProgrammes.count().getSingle(), 4, reason: 'unknown channel and far-future dropped');
      final a = (await accounts.byId(account.id))!;
      expect(a.guideSourceCount, 1);
      expect(a.guideUpdatedAt, isNotNull);

      final nn = await epg.nowNext(account.id, ['meridian.uk', 'pulse1.uk'], at: now);
      expect(nn['meridian.uk']!.now?.title, 'The Evening Bulletin');
      expect(nn['meridian.uk']!.next?.title, 'Late Edition');
      expect(nn['meridian.uk']!.progressAt(now), 0.5);
      expect(nn['pulse1.uk']!.now?.title, 'Coastal FC vs Northern United');

      // Guide time shift +1 h: the 20:00–21:00 programme now airs 21:00–22:00.
      await accounts.setGuideShift(account.id, 60);
      final shifted = await epg.nowNext(account.id, ['meridian.uk'], at: now);
      expect(shifted['meridian.uk']!.now?.title, 'Early News');
      // Drift returns local DateTimes — compare instants.
      expect(shifted['meridian.uk']!.now?.start.isAtSameMomentAs(DateTime.utc(2026, 10, 3, 20)), isTrue);

      final grid = await epg.programmes(account.id, ['meridian.uk'], DateTime.utc(2026, 10, 3, 20), DateTime.utc(2026, 10, 3, 23));
      expect(grid['meridian.uk']!.map((p) => p.title), ['Early News', 'The Evening Bulletin', 'Late Edition']);

      // Cutoff = now − 12 h = 21:45Z: drops the three that ended earlier, keeps Late Edition (22:00).
      expect(await epg.prune(account.id, now: DateTime.utc(2026, 10, 4, 9, 45)), 3);
      expect((await db.select(db.epgProgrammes).get()).single.title, 'Late Edition');
    });

    test('every source failing surfaces the failure', () async {
      final dio = fakeDio((r) => r.uri.path.endsWith('xmltv.php') ? const FakeResponse('oops', status: 500, contentType: 'text/plain') : xtreamServer(r));
      final account = await accounts.create(name: 'A', kind: AccountKind.xtream, credentials: xtream);
      final tmp = await Directory.systemTemp.createTemp('epg');
      addTearDown(() => tmp.delete(recursive: true));
      final epg = EpgRepository(db, dio, creds, tempDir: () async => tmp);
      await expectLater(epg.refresh(account).drain<void>(), throwsA(isA<ServerErrorFailure>()));
    });
  });
}

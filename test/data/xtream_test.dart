import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbix/data/core/failures.dart';
import 'package:orbix/data/credentials/credentials.dart';
import 'package:orbix/data/models/catalog.dart';
import 'package:orbix/data/repositories/connection_tester.dart';
import 'package:orbix/data/sources/xtream/xtream_client.dart';

import '../support/fake_http.dart';

void main() {
  final good = XtreamCredentials(serverUrl: 'line.example:8080', username: 'user', password: 'pass');

  group('XtreamClient', () {
    test('authenticate reads status and expiry', () async {
      final c = XtreamClient(fakeDio(xtreamServer), good);
      final info = await c.authenticate(now: DateTime.utc(2026, 10, 3));
      expect(info.isActive, isTrue);
      expect(info.expiresAt, DateTime.fromMillisecondsSinceEpoch(1830000000 * 1000, isUtc: true));
      expect(info.maxConnections, 2);
      expect(info.allowedFormats, ['m3u8', 'ts']);
    });

    test('auth 0 → invalid credentials', () async {
      final bad = XtreamCredentials(serverUrl: 'line.example:8080', username: 'user', password: 'nope');
      await expectLater(XtreamClient(fakeDio(xtreamServer), bad).authenticate(), throwsA(isA<InvalidCredentialsFailure>()));
    });

    test('expired and banned accounts', () async {
      final expired = XtreamClient(fakeDio((r) => xtreamServer(r, status: 'Expired', expEpoch: 1790000000)), good);
      await expectLater(
        expired.authenticate(),
        throwsA(isA<AccountExpiredFailure>().having((f) => f.expiresAt, 'expiresAt', DateTime.fromMillisecondsSinceEpoch(1790000000 * 1000, isUtc: true))),
      );
      // "Active" but past its expiry date also counts as expired.
      final lapsed = XtreamClient(fakeDio((r) => xtreamServer(r, expEpoch: 1700000000)), good);
      await expectLater(lapsed.authenticate(now: DateTime.utc(2026)), throwsA(isA<AccountExpiredFailure>()));
      final banned = XtreamClient(fakeDio((r) => xtreamServer(r, status: 'Banned')), good);
      await expectLater(banned.authenticate(), throwsA(isA<AccountDisabledFailure>()));
    });

    test('HTML instead of JSON → not an IPTV server', () async {
      final c = XtreamClient(fakeDio((_) => const FakeResponse('<html><body>Welcome to nginx</body></html>', contentType: 'text/html')), good);
      await expectLater(c.authenticate(), throwsA(isA<NotIptvServerFailure>()));
    });

    test('lists tolerate inconsistent field types', () async {
      final c = XtreamClient(fakeDio(xtreamServer), good);
      final cats = await c.categories(ContentKind.live);
      expect(cats.map((x) => x.name), ['News', 'Sports', 'XXX Adults']);
      expect(cats.last.isAdult, isTrue);

      final live = await c.liveStreams();
      expect(live.map((x) => (x.id, x.number)), [('1001', 101), ('1002', 102), ('1003', 103)]);
      expect(live.first.epgId, 'meridian.uk');
      expect(live.first.catchupDays, 3);
      expect(live[1].logo, isNull, reason: 'empty string is null');

      final vod = await c.vodStreams();
      expect(vod.first.rating, 8.6);
      expect(vod.first.year, 2026);
      expect(vod[1].rating, 7.0, reason: 'rating_5based × 2');

      final series = await c.series();
      expect(series.single.backdrop, 'http://img/nb.jpg');
      expect(series.single.year, 2025);
    });

    test('series info: map-of-seasons episodes, durations, derived seasons', () async {
      final d = await XtreamClient(fakeDio(xtreamServer), good).seriesInfo('7001');
      expect(d.episodes.map((e) => (e.season, e.episode)), [(1, 1), (1, 2), (2, 1)]);
      expect(d.episodes[0].durationSecs, 2700);
      expect(d.episodes[1].durationSecs, 44 * 60 + 30);
      expect(d.seasons.map((s) => (s.number, s.episodeCount)), [(1, 2), (2, 1)]);
      expect(d.trailerYoutubeId, 'abc123');
    });

    test('vod info and base64 short EPG', () async {
      final c = XtreamClient(fakeDio(xtreamServer), good);
      final m = await c.vodInfo('5001');
      expect(m.durationSecs, 2 * 3600 + 18 * 60);
      expect(m.backdrop, 'http://img/b.jpg');
      final epg = await c.shortEpg('1001', epgChannelId: 'Meridian.uk');
      expect(epg.single.title, 'Evening Bulletin');
      expect(epg.single.description, 'The news.');
      expect(epg.single.channelId, 'meridian.uk');
    });

    test('stream URLs escape credentials', () {
      final c = XtreamClient(fakeDio(xtreamServer), XtreamCredentials(serverUrl: 'line.example:8080', username: 'a b', password: 'p/ss'));
      expect(c.liveUrl('1001'), 'http://line.example:8080/live/a%20b/p%2Fss/1001.ts');
      expect(c.movieUrl('5001', 'mkv'), 'http://line.example:8080/movie/a%20b/p%2Fss/5001.mkv');
      expect(c.episodeUrl('9001', null), 'http://line.example:8080/series/a%20b/p%2Fss/9001.mp4');
      expect(c.xmltvUri.toString(), 'http://line.example:8080/xmltv.php?username=a+b&password=p%2Fss');
    });
  });

  group('failure classification', () {
    final uri = Uri.parse('http://line.example:8080/player_api.php');
    DioException dioErr(DioExceptionType t, {Object? error, int? status}) => DioException(
          requestOptions: RequestOptions(path: uri.toString()),
          type: t,
          error: error,
          response: status == null ? null : Response(requestOptions: RequestOptions(path: uri.toString()), statusCode: status),
        );

    test('maps transport errors to the designed states', () {
      expect(OrbixFailure.from(dioErr(DioExceptionType.connectionTimeout)), isA<ServerTimeoutFailure>().having((f) => f.host, 'host', 'line.example:8080'));
      expect(OrbixFailure.from(dioErr(DioExceptionType.connectionError, error: const SocketException('Failed host lookup: line.example'))),
          isA<HostNotFoundFailure>());
      expect(OrbixFailure.from(dioErr(DioExceptionType.connectionError, error: const SocketException('x', osError: OSError('Network is unreachable', 101)))),
          isA<OfflineFailure>());
      expect(OrbixFailure.from(dioErr(DioExceptionType.connectionError, error: const SocketException('x', osError: OSError('Connection refused', 111)))),
          isA<ConnectionRefusedFailure>());
      expect(OrbixFailure.from(dioErr(DioExceptionType.badResponse, status: 503)), isA<ServerErrorFailure>());
      expect(OrbixFailure.from(dioErr(DioExceptionType.badResponse, status: 403)), isA<AccessDeniedFailure>());
      expect(OrbixFailure.from(dioErr(DioExceptionType.badCertificate)), isA<TlsFailure>());
      expect(OrbixFailure.from(dioErr(DioExceptionType.cancel)), isA<CancelledFailure>());
    });

    test('adapter-level socket errors arrive classified', () async {
      final c = XtreamClient(fakeDio((_) => throw const SocketException('Failed host lookup: nowhere.example')), good);
      await expectLater(c.authenticate(), throwsA(isA<HostNotFoundFailure>()));
    });
  });

  group('ConnectionTester', () {
    test('Xtream success: reach (with latency) then sign-in', () async {
      final states = await ConnectionTester(fakeDio(xtreamServer)).testXtream(good).toList();
      final last = states.last;
      expect(last.succeeded, isTrue);
      expect(last.step(TestStepId.reach).latency, isNotNull);
      expect(last.step(TestStepId.signIn).state, TestStepState.done);
      expect(last.accountInfo?.maxConnections, 2);
      expect(states.first.steps.every((s) => s.state == TestStepState.waiting), isTrue);
    });

    test('Xtream wrong password fails the sign-in step, not reach', () async {
      final bad = XtreamCredentials(serverUrl: 'line.example:8080', username: 'user', password: 'x');
      final last = await ConnectionTester(fakeDio(xtreamServer)).testXtream(bad).last;
      expect(last.succeeded, isFalse);
      expect(last.failure, isA<InvalidCredentialsFailure>());
      expect(last.step(TestStepId.reach).state, TestStepState.done);
      expect(last.step(TestStepId.signIn).state, TestStepState.failed);
    });

    test('DNS failure fails the reach step', () async {
      final last = await ConnectionTester(fakeDio((_) => throw const SocketException('Failed host lookup: x'))).testXtream(good).last;
      expect(last.failure, isA<HostNotFoundFailure>());
      expect(last.step(TestStepId.reach).state, TestStepState.failed);
      expect(last.step(TestStepId.signIn).state, TestStepState.waiting);
    });

    test('M3U: reach → download (bytes) → read (counts) → guide', () async {
      final dio = fakeDio((r) => r.uri.host == 'epg.example'
          ? const FakeResponse(sampleXmltv, contentType: 'application/xml')
          : const FakeResponse(sampleM3u, contentType: 'audio/x-mpegurl'));
      final states = await ConnectionTester(dio).testPlaylist(const PlaylistCredentials(playlistUrl: 'http://list.example/get.m3u')).toList();
      final last = states.last;
      expect(last.succeeded, isTrue);
      expect(last.step(TestStepId.download).bytes, greaterThan(1000));
      expect(last.step(TestStepId.read).count, 4 + 2 + 1);
      expect(last.step(TestStepId.guide).state, TestStepState.done);
      expect(last.catalog?.channels, hasLength(4));
      // Download progress was reported while running.
      expect(states.where((s) => s.step(TestStepId.download).state == TestStepState.running), isNotEmpty);
    });

    test('M3U: an HTML page fails the read step', () async {
      final dio = fakeDio((_) => const FakeResponse('<!DOCTYPE html><html>Login</html>', contentType: 'text/html'));
      final last = await ConnectionTester(dio).testPlaylist(const PlaylistCredentials(playlistUrl: 'http://list.example/x')).last;
      expect(last.failure, isA<InvalidPlaylistFailure>());
      expect(last.step(TestStepId.read).state, TestStepState.failed);
    });

    test('M3U: a broken guide is a warning, not a failure', () async {
      final dio = fakeDio((r) => r.uri.host == 'epg.example'
          ? const FakeResponse('<html>nope</html>', contentType: 'text/html')
          : const FakeResponse(sampleM3u));
      final last = await ConnectionTester(dio).testPlaylist(const PlaylistCredentials(playlistUrl: 'http://list.example/get.m3u')).last;
      expect(last.succeeded, isTrue);
      expect(last.step(TestStepId.guide).state, TestStepState.failed);
    });
  });
}

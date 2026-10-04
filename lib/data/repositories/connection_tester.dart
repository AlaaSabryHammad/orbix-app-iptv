import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../core/background.dart';
import '../core/failures.dart';
import '../credentials/credentials.dart';
import '../models/catalog.dart';
import '../sources/m3u/m3u_parser.dart';
import '../sources/m3u/playlist_loader.dart';
import '../sources/xtream/xtream_client.dart';

enum TestStepId {
  /// "Server reachable · 118 ms"
  reach,

  /// Xtream: "Signed in" (credentials + subscription status).
  signIn,

  /// M3U: "Playlist downloaded · 4.2 MB"
  download,

  /// M3U: "Reading channels & VOD · 796 / 1,284"
  read,

  /// "Guide data (EPG)"
  guide,
}

enum TestStepState { waiting, running, done, failed, skipped }

class TestStep {
  const TestStep(this.id, this.state, {this.latency, this.bytes, this.count, this.total, this.failure});

  final TestStepId id;
  final TestStepState state;
  final Duration? latency;
  final int? bytes;
  final int? count;
  final int? total;
  final OrbixFailure? failure;

  TestStep copyWith({TestStepState? state, Duration? latency, int? bytes, int? count, int? total, OrbixFailure? failure}) => TestStep(
        id,
        state ?? this.state,
        latency: latency ?? this.latency,
        bytes: bytes ?? this.bytes,
        count: count ?? this.count,
        total: total ?? this.total,
        failure: failure ?? this.failure,
      );
}

/// Snapshot of a running connection test (AddAccountM3U "Testing connection…").
class ConnectionTest {
  const ConnectionTest(this.steps, {this.failure, this.accountInfo, this.catalog, this.done = false});

  final List<TestStep> steps;

  /// Set when the test failed — maps to States 07–10.
  final OrbixFailure? failure;

  /// Xtream: subscription status (expiry for the Profiles card).
  final XtreamAccountInfo? accountInfo;

  /// M3U: the parsed playlist — pass to `CatalogRepository.sync(prefetched:)`
  /// so it is not downloaded twice.
  final CatalogSnapshot? catalog;
  final bool done;

  bool get succeeded => done && failure == null;

  TestStep step(TestStepId id) => steps.firstWhere((s) => s.id == id);
}

/// Validates account details before saving, step by step.
class ConnectionTester {
  ConnectionTester(this._dio);

  final Dio _dio;

  Stream<ConnectionTest> testXtream(XtreamCredentials creds, {CancelToken? cancel}) {
    final c = _Run([TestStepId.reach, TestStepId.signIn, if (creds.epgUrl != null) TestStepId.guide]);
    () async {
      try {
        c.update(TestStepId.reach, (s) => s.copyWith(state: TestStepState.running));
        final sw = Stopwatch()..start();
        final client = XtreamClient(_dio, creds);
        XtreamAccountInfo info;
        try {
          info = await client.authenticate(cancel: cancel);
        } on OrbixFailure catch (f) {
          final isCredentialProblem = f is InvalidCredentialsFailure || f is AccountExpiredFailure || f is AccountDisabledFailure;
          if (isCredentialProblem) {
            c.update(TestStepId.reach, (s) => s.copyWith(state: TestStepState.done, latency: sw.elapsed));
            c.fail(TestStepId.signIn, f);
          } else {
            c.fail(TestStepId.reach, f);
          }
          return;
        }
        c.update(TestStepId.reach, (s) => s.copyWith(state: TestStepState.done, latency: sw.elapsed));
        c.update(TestStepId.signIn, (s) => s.copyWith(state: TestStepState.done));
        c.accountInfo = info;
        if (creds.epgUrl != null) await _checkGuide(c, creds.epgUrl!, cancel);
        c.finish();
      } catch (e) {
        c.failRunning(OrbixFailure.from(e));
      }
    }();
    return c.stream;
  }

  /// Tests a playlist URL or an already-imported local file.
  Stream<ConnectionTest> testPlaylist(PlaylistCredentials creds, {CancelToken? cancel}) {
    final isFile = creds.filePath != null;
    final c = _Run([if (!isFile) TestStepId.reach, if (!isFile) TestStepId.download, TestStepId.read, TestStepId.guide]);
    () async {
      try {
        Uint8List bytes;
        if (isFile) {
          bytes = await PlaylistFiles.read(creds.filePath!);
        } else {
          c.update(TestStepId.reach, (s) => s.copyWith(state: TestStepState.running));
          try {
            final r = await PlaylistLoader(_dio).download(
              creds.playlistUrl!,
              cancel: cancel,
              onHeaders: (latency) {
                c.update(TestStepId.reach, (s) => s.copyWith(state: TestStepState.done, latency: latency));
                c.update(TestStepId.download, (s) => s.copyWith(state: TestStepState.running));
              },
              onBytes: (received, total) => c.update(TestStepId.download, (s) => s.copyWith(bytes: received, total: total > 0 ? total : null)),
            );
            bytes = r.bytes;
            c.update(TestStepId.download, (s) => s.copyWith(state: TestStepState.done, bytes: r.bytes.length));
          } on OrbixFailure catch (f) {
            c.failRunning(f);
            return;
          }
        }

        c.update(TestStepId.read, (s) => s.copyWith(state: TestStepState.running));
        final CatalogSnapshot catalog;
        try {
          catalog = await runInBackground(parseM3uCatalog, bytes);
        } catch (e) {
          c.fail(TestStepId.read, OrbixFailure.from(e));
          return;
        }
        final total = catalog.channels.length + catalog.movies.length + catalog.series.length;
        c.update(TestStepId.read, (s) => s.copyWith(state: TestStepState.done, count: total, total: total));
        c.catalog = catalog;

        final guideUrl = creds.epgUrl ?? catalog.epgUrls.firstOrNull;
        if (guideUrl == null) {
          c.update(TestStepId.guide, (s) => s.copyWith(state: TestStepState.skipped));
        } else {
          await _checkGuide(c, guideUrl, cancel);
        }
        c.finish();
      } catch (e) {
        c.failRunning(OrbixFailure.from(e));
      }
    }();
    return c.stream;
  }

  /// Guide check: reachable and looks like XMLTV (plain or gzip). A broken
  /// guide is a warning, not a failed test — the account still works.
  Future<void> _checkGuide(_Run c, String url, CancelToken? cancel) async {
    c.update(TestStepId.guide, (s) => s.copyWith(state: TestStepState.running));
    final uri = Uri.parse(url);
    final sw = Stopwatch()..start();
    try {
      final r = await _dio.getUri<ResponseBody>(
        uri,
        options: Options(responseType: ResponseType.stream, headers: {HttpHeaders.rangeHeader: 'bytes=0-2047'}),
        cancelToken: cancel,
      );
      final head = <int>[];
      await for (final chunk in r.data!.stream) {
        head.addAll(chunk);
        if (head.length >= 512) break;
      }
      final gz = head.length > 1 && head[0] == 0x1f && head[1] == 0x8b;
      final text = String.fromCharCodes(head.take(512)).toLowerCase();
      final ok = gz || text.contains('<tv') || text.contains('<?xml');
      c.update(
        TestStepId.guide,
        (s) => ok
            ? s.copyWith(state: TestStepState.done, latency: sw.elapsed)
            : s.copyWith(state: TestStepState.failed, failure: const InvalidGuideFailure('Not XMLTV')),
      );
    } catch (e) {
      final f = OrbixFailure.from(e, uri: uri);
      if (f is CancelledFailure) rethrow;
      c.update(TestStepId.guide, (s) => s.copyWith(state: TestStepState.failed, failure: f));
    }
  }
}

/// Mutable state behind a test stream.
class _Run {
  _Run(List<TestStepId> ids) : _steps = [for (final id in ids) TestStep(id, TestStepState.waiting)] {
    _emit();
  }

  final _out = StreamController<ConnectionTest>();
  final List<TestStep> _steps;
  OrbixFailure? _failure;
  XtreamAccountInfo? accountInfo;
  CatalogSnapshot? catalog;

  Stream<ConnectionTest> get stream => _out.stream;

  void _emit({bool done = false}) {
    if (_out.isClosed) return;
    _out.add(ConnectionTest(List.unmodifiable(_steps), failure: _failure, accountInfo: accountInfo, catalog: catalog, done: done));
    if (done) _out.close();
  }

  void update(TestStepId id, TestStep Function(TestStep) f) {
    final i = _steps.indexWhere((s) => s.id == id);
    if (i < 0) return;
    _steps[i] = f(_steps[i]);
    _emit();
  }

  void fail(TestStepId id, OrbixFailure failure) {
    _failure = failure;
    update(id, (s) => s.copyWith(state: TestStepState.failed, failure: failure));
    finish();
  }

  /// Fails whichever step is running (or the first waiting one).
  void failRunning(OrbixFailure failure) {
    final s = _steps.where((s) => s.state == TestStepState.running).firstOrNull ?? _steps.where((s) => s.state == TestStepState.waiting).firstOrNull;
    if (s == null) {
      _failure = failure;
      finish();
    } else {
      fail(s.id, failure);
    }
  }

  void finish() => _emit(done: true);
}

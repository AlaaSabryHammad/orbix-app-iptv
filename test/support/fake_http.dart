import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:orbix/data/core/http.dart';

typedef Handler = Object Function(RequestOptions request);

/// A Dio wired to an in-process fake server. [handler] returns:
/// a String / Map / List (JSON) body, `Uint8List` raw bytes, a [FakeResponse],
/// or throws (e.g. a SocketException) to simulate transport errors.
Dio fakeDio(Handler handler) {
  final dio = createDio();
  dio.httpClientAdapter = _FakeAdapter(handler);
  return dio;
}

class FakeResponse {
  const FakeResponse(this.body, {this.status = 200, this.contentType = 'application/json'});

  final Object body;
  final int status;
  final String contentType;
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final Handler handler;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    final r = handler(options);
    final res = r is FakeResponse ? r : FakeResponse(r);
    final Uint8List bytes = switch (res.body) {
      final Uint8List b => b,
      final String s => Uint8List.fromList(utf8.encode(s)),
      final other => Uint8List.fromList(utf8.encode(jsonEncode(other))),
    };
    // Deliver in chunks so progress callbacks fire more than once.
    final chunks = <Uint8List>[
      for (var i = 0; i < bytes.length; i += 4096) Uint8List.sublistView(bytes, i, i + 4096 > bytes.length ? bytes.length : i + 4096),
    ];
    return ResponseBody(
      Stream.fromIterable(chunks),
      res.status,
      headers: {
        Headers.contentTypeHeader: [res.contentType],
        Headers.contentLengthHeader: ['${bytes.length}'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// A small Xtream panel: credentials `user` / `pass`.
Object xtreamServer(RequestOptions r, {String status = 'Active', int? expEpoch, bool auth = true}) {
  final q = r.uri.queryParameters;
  if (r.uri.path.endsWith('xmltv.php')) return const FakeResponse(sampleXmltv, contentType: 'application/xml');
  if (!r.uri.path.endsWith('player_api.php')) return const FakeResponse('<html>404</html>', status: 404, contentType: 'text/html');
  if (!auth || q['username'] != 'user' || q['password'] != 'pass') return {'user_info': {'auth': 0}};
  return switch (q['action']) {
    null => {
        'user_info': {
          'username': 'user',
          'auth': 1,
          'status': status,
          'exp_date': '${expEpoch ?? 1830000000}',
          'is_trial': '0',
          'active_cons': '0',
          'max_connections': '2',
          'allowed_output_formats': ['m3u8', 'ts'],
        },
        'server_info': {'timezone': 'Europe/London', 'timestamp_now': 1790000000},
      },
    'get_live_categories' => [
        {'category_id': '1', 'category_name': 'News', 'parent_id': 0},
        {'category_id': '2', 'category_name': 'Sports', 'parent_id': 0},
        {'category_id': '9', 'category_name': 'XXX Adults', 'parent_id': 0},
      ],
    'get_live_streams' => [
        {'num': 101, 'name': 'Meridian News', 'stream_id': 1001, 'stream_icon': 'http://img/mn.png', 'epg_channel_id': 'Meridian.uk', 'category_id': '1', 'tv_archive': 1, 'tv_archive_duration': '3', 'added': '1700000000'},
        {'num': '102', 'name': 'Pulse Sports 1', 'stream_id': '1002', 'stream_icon': '', 'epg_channel_id': 'pulse1.uk', 'category_id': '2', 'tv_archive': 0},
        {'num': 103, 'name': 'Pulse Sports 2', 'stream_id': 1003, 'stream_icon': null, 'epg_channel_id': null, 'category_id': '2'},
      ],
    'get_vod_categories' => [
        {'category_id': '10', 'category_name': 'Sci-Fi'},
      ],
    'get_vod_streams' => [
        {'name': 'The Last Meridian (2026)', 'stream_id': 5001, 'stream_icon': 'http://img/p.jpg', 'rating': '8.6', 'added': '1780000000', 'category_id': '10', 'container_extension': 'mkv'},
        {'name': 'Iron Tide', 'stream_id': '5002', 'rating': '', 'rating_5based': 3.5, 'added': '1770000000', 'category_id': '10', 'container_extension': 'mp4'},
      ],
    'get_series_categories' => [
        {'category_id': '20', 'category_name': 'Drama'},
      ],
    'get_series' => [
        {'series_id': 7001, 'name': 'Northbound', 'cover': 'http://img/n.jpg', 'plot': 'A road north.', 'rating': '7.9', 'releaseDate': '2025-04-01', 'last_modified': '1785000000', 'category_id': '20', 'backdrop_path': ['http://img/nb.jpg']},
      ],
    'get_series_info' => {
        'seasons': [],
        'info': {'name': 'Northbound', 'cover': 'http://img/n.jpg', 'plot': 'A road north.', 'cast': 'A, B', 'youtube_trailer': 'abc123'},
        'episodes': {
          '1': [
            {'id': '9001', 'episode_num': 1, 'title': 'Northbound S01E01', 'container_extension': 'mkv', 'season': 1, 'info': {'duration_secs': 2700, 'plot': 'Start.'}},
            {'id': '9002', 'episode_num': '2', 'title': 'Northbound S01E02', 'container_extension': 'mkv', 'season': '1', 'info': {'duration': '00:44:30'}},
          ],
          '2': [
            {'id': '9003', 'episode_num': 1, 'title': 'Northbound S02E01', 'container_extension': 'mkv', 'info': <String, Object>{}},
          ],
        },
      },
    'get_vod_info' => {
        'info': {'plot': 'When the last relay…', 'cast': 'M. Okonkwo-Lind', 'director': 'R. Vale', 'genre': 'Sci-Fi', 'duration': '02:18:00', 'backdrop_path': ['http://img/b.jpg'], 'rating': '8.6', 'youtube_trailer': 'xyz'},
        'movie_data': {'stream_id': 5001, 'name': 'The Last Meridian', 'container_extension': 'mkv'},
      },
    'get_short_epg' => {
        'epg_listings': [
          {'title': base64.encode(utf8.encode('Evening Bulletin')), 'description': base64.encode(utf8.encode('The news.')), 'start_timestamp': '1790000000', 'stop_timestamp': '1790003600'},
        ],
      },
    _ => <Object>[],
  };
}

/// XMLTV sample: 2 channels, offsets, an entity, CDATA, an out-of-window and
/// an unknown-channel programme. Times around 2026-10-03 20:00 UTC.
const sampleXmltv = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE tv SYSTEM "xmltv.dtd">
<tv generator-info-name="test">
  <channel id="Meridian.uk"><display-name lang="en">Meridian News</display-name><icon src="http://img/mn.png"/></channel>
  <channel id="pulse1.uk"><display-name>Pulse Sports 1</display-name></channel>
  <programme start="20261003190000 +0000" stop="20261003200000 +0000" channel="Meridian.uk"><title lang="en">Early News</title></programme>
  <programme start="20261003230000 +0300" stop="20261004000000 +0300" channel="Meridian.uk">
    <title lang="en">The Evening Bulletin</title><title lang="ar">النشرة المسائية</title>
    <desc lang="en">Headlines &amp; weather</desc><category>News</category>
  </programme>
  <programme start="20261003210000 +0000" stop="20261003220000 +0000" channel="Meridian.uk"><title>Late Edition</title><desc><![CDATA[In <depth>.]]></desc></programme>
  <programme start="20261003193000" stop="20261003213000" channel="PULSE1.uk"><title>Coastal FC vs Northern United</title></programme>
  <programme start="20261020200000 +0000" stop="20261020210000 +0000" channel="Meridian.uk"><title>Too far ahead</title></programme>
  <programme start="20261003200000 +0000" stop="20261003210000 +0000" channel="unknown.channel"><title>Not ours</title></programme>
</tv>
''';

/// M3U sample covering the formats seen in the wild.
const sampleM3u = '''﻿#EXTM3U url-tvg="http://epg.example/guide.xml.gz" x-tvg-url="http://epg.example/b.xml"\r
#EXTINF:-1 tvg-id="Meridian.uk" tvg-name="Meridian News" tvg-logo="http://img/mn.png" tvg-chno="101" group-title="News",Meridian News\r
http://line.example:8080/live/u/p/1001.ts\r
#EXTINF:-1 tvg-id="pulse1.uk" tvg-logo="http://img/p1.png" group-title="Sports, Live",Pulse Sports 1, HD\r
#EXTVLCOPT:http-user-agent=OrbixTest/1.0\r
#EXTVLCOPT:http-referrer=http://ref.example/\r
http://cdn.example/hls/pulse1/index.m3u8\r
#EXTINF:0,Kodi Style\r
#EXTGRP:Kids\r
http://cdn.example/kids.m3u8|User-Agent=Kodi%2F20&Referer=http://kodi.example\r
#EXTINF:-1 tvg-logo="http://img/meridian.jpg" group-title="Movies: Sci-Fi",The Last Meridian (2026)\r
http://line.example:8080/movie/u/p/5001.mkv\r
#EXTINF:-1 group-title="Movies: Sci-Fi",Iron Tide\r
http://vod.example/files/iron_tide.mp4\r
#EXTINF:-1 tvg-logo="http://img/nb.jpg" group-title="Series: Drama",Northbound S01 E01\r
http://line.example:8080/series/u/p/9001.mkv\r
#EXTINF:-1 group-title="Series: Drama",Northbound S01E02 The Border\r
http://line.example:8080/series/u/p/9002.mkv\r
#EXTINF:-1 group-title="Series: Drama",Northbound S02E01\r
http://vod.example/nb/s02e01.mkv\r
# a comment line\r
#EXTINF:-1,Broken entry with no url\r
#EXTINF:-1 tvg-id="" group-title="News",Meridian News\r
http://other.example/meridian-backup.m3u8\r
''';

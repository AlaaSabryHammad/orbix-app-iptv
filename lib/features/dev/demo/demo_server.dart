import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Dev-only demo provider: an Xtream Codes panel served in-process from the
/// design handoff's demo data and artwork, so every screen can be reviewed
/// through the real code paths (sign-in, sync, details, guide) without a
/// provider. Lives on a reserved `.invalid` host — it can never reach, or be
/// mistaken for, a real server. Installed in debug builds only (main.dart).
abstract final class DemoServer {
  static const host = 'demo.orbix.invalid';
  static const serverUrl = 'http://$host';
  static const username = 'demo';
  static const password = 'demo';

  /// Streams of the demo provider play bundled clips (two audio tracks, two
  /// subtitle tracks) — the URLs don't exist on any network.
  static String rewriteStream(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host != host) return url;
    return uri.pathSegments.firstOrNull == 'live' ? 'asset:///assets/demo/demo_live.mkv' : 'asset:///assets/demo/demo_vod.mkv';
  }
}

/// Wraps the real adapter; answers requests for [DemoServer.host] itself.
class DemoAdapter implements HttpClientAdapter {
  DemoAdapter(this._inner, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final HttpClientAdapter _inner;
  final DateTime Function() _clock;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    if (options.uri.host != DemoServer.host) return _inner.fetch(options, requestStream, cancelFuture);
    await Future<void>.delayed(const Duration(milliseconds: 120)); // feels like a network
    final (body, type) = _route(options.uri);
    final bytes = Uint8List.fromList(utf8.encode(body));
    return ResponseBody.fromBytes(bytes, 200, headers: {
      Headers.contentTypeHeader: [type],
      Headers.contentLengthHeader: ['${bytes.length}'],
    });
  }

  @override
  void close({bool force = false}) => _inner.close(force: force);

  (String, String) _route(Uri uri) {
    if (uri.path.endsWith('xmltv.php')) return (_xmltv(_clock()), 'application/xml');
    final q = uri.queryParameters;
    if (q['username'] != DemoServer.username || q['password'] != DemoServer.password) {
      return (jsonEncode({'user_info': {'auth': 0}}), 'application/json');
    }
    final Object json = switch (q['action']) {
      null => _auth(),
      'get_live_categories' => _cats(_liveCats),
      'get_vod_categories' => _cats(_movieCats),
      'get_series_categories' => _cats(_seriesCats),
      'get_live_streams' => _live(),
      'get_vod_streams' => _vod(),
      'get_series' => _series(),
      'get_vod_info' => _vodInfo(q['vod_id'] ?? ''),
      'get_series_info' => _seriesInfo(q['series_id'] ?? ''),
      _ => const <Object>[],
    };
    return (jsonEncode(json), 'application/json');
  }

  int get _now => _clock().millisecondsSinceEpoch ~/ 1000;

  Map<String, Object> _auth() => {
        'user_info': {
          'username': DemoServer.username,
          'auth': 1,
          'status': 'Active',
          'exp_date': '${_now + 180 * 86400}',
          'is_trial': '0',
          'active_cons': '0',
          'max_connections': '2',
          'allowed_output_formats': ['m3u8', 'ts'],
        },
        'server_info': {'timezone': 'UTC', 'timestamp_now': _now},
      };

  List<Map<String, Object>> _cats(List<String> names) => [
        for (var i = 0; i < names.length; i++) {'category_id': '${i + 1}', 'category_name': names[i], 'parent_id': 0},
      ];

  static const _a = 'assets/demo';

  static const _liveCats = ['News', 'Sports', 'Entertainment', 'Kids', 'Documentaries', 'Movies', 'Music', 'International', 'Late Night'];

  // num, name, category (1-based), epg id
  static const _channels = [
    (101, 'Meridian News', 1, 'mn.demo'),
    (102, 'Pulse Sports 1', 2, 'p1.demo'),
    (103, 'Pulse Sports 2', 2, 'p2.demo'),
    (104, 'Cine Prime', 6, 'cp.demo'),
    (105, 'Atlas Docs', 5, 'ad.demo'),
    (106, 'Kitezoo Kids', 4, 'kz.demo'),
    (107, 'Wave Music', 7, 'wv.demo'),
    (108, 'Horizon One', 3, 'h1.demo'),
    (109, 'North+ Nature', 5, 'nn.demo'),
    (110, 'Orbit World', 8, 'ow.demo'),
    (190, 'Late Night Cinema', 9, 'ln.demo'),
  ];

  List<Map<String, Object?>> _live() => [
        for (final (n, name, cat, epg) in _channels)
          {
            'num': n,
            'name': name,
            'stream_type': 'live',
            'stream_id': n,
            'stream_icon': '',
            'epg_channel_id': epg,
            'category_id': '$cat',
            'tv_archive': n < 104 ? 1 : 0,
            'tv_archive_duration': 3,
            'added': '${_now - 86400 * 30}',
          },
      ];

  static const _movieCats = ['Action', 'Sci-Fi', 'Drama', 'Thriller', 'Family', 'Adventure'];

  // id, title, poster, backdrop, category, year, rating, minutes, added (days ago)
  static const _movies = [
    (5001, 'The Last Meridian', 'p-meridian', 'b-meridian', 2, 2026, 8.6, 138, 9),
    (5002, 'Little Lantern', 'p-lantern', null, 5, 2025, 8.4, 94, 40),
    (5003, 'Sands of Avar', 'p-avar', 'b-avar', 6, 2025, 8.3, 126, 20),
    (5004, 'Neon Requiem', 'p-neon', 'b-neon', 4, 2026, 7.7, 125, 6),
    (5005, 'Ashfall', 'p-ashfall', null, 1, 2025, 7.9, 112, 25),
    (5006, 'Quiet Harbor', 'p-harbor', null, 3, 2024, 8.1, 104, 2),
    (5007, 'Iron Tide', 'p-irontide', 'b-irontide', 1, 2026, 7.6, 118, 1),
    (5008, 'The Cartographer', 'p-cartographer', null, 6, 2024, 7.5, 109, 3),
    (5009, 'Glass Orchard', 'p-orchard', null, 3, 2023, 7.2, 98, 4),
    (5010, 'Saltwater Kings', 'p-saltwater', null, 3, 2024, 7.4, 101, 5),
    (5011, 'Halcyon Drift', 'p-halcyon', null, 2, 2025, 7.8, 115, 7),
    (5012, 'Northbound', 'p-northbound', 'b-northbound', 4, 2026, 8.0, 122, 12),
  ];

  List<Map<String, Object?>> _vod() => [
        for (final (id, title, poster, _, cat, year, rating, _, ago) in _movies)
          {
            'num': id - 5000,
            'name': title,
            'stream_type': 'movie',
            'stream_id': id,
            'stream_icon': '$_a/$poster.jpg',
            'rating': '$rating',
            'year': '$year',
            'added': '${_now - ago * 86400}',
            'category_id': '$cat',
            'container_extension': 'mp4',
          },
      ];

  Map<String, Object?> _vodInfo(String id) {
    final m = _movies.where((m) => '${m.$1}' == id).firstOrNull;
    if (m == null) return const {};
    final (_, title, poster, backdrop, cat, year, rating, minutes, _) = m;
    return {
      'info': {
        'name': title,
        'movie_image': '$_a/$poster.jpg',
        'backdrop_path': ['$_a/${backdrop ?? 'b-avar'}.jpg'],
        'plot': title == 'Sands of Avar'
            ? 'A cartographer’s daughter follows the last map her missing father left behind into the shifting sands of Avar, where a caravan city moves with the dunes.'
            : 'When the last relay on a dying world goes silent, one engineer crosses the frozen meridian to bring the signal home before the long night closes in.',
        'cast': 'Ilse Varga, Tomas Reyne, Odile Faure, Kenji Arlo, Selin Marr, Bram Okoye',
        'director': 'Mari Okonkwo-Lind',
        'genre': '${_movieCats[cat - 1]} · Drama',
        'releasedate': '$year-03-14',
        'duration_secs': minutes * 60,
        'rating': '$rating',
        'youtube_trailer': 'dQw4w9WgXcQ',
      },
      'movie_data': {'stream_id': int.parse(id), 'name': title, 'container_extension': 'mp4', 'category_id': '$cat'},
    };
  }

  static const _seriesCats = ['Crime', 'Sci-Fi', 'Docuseries', 'Fantasy', 'Thriller', 'Survival'];

  // id, title, poster, backdrop, category, rating, seasons, updated (days ago)
  static const _shows = [
    (7001, 'Hollow Crown District', 'p-hollow', 'b-hollow', 1, 8.7, 3, 1),
    (7002, 'Signal & Noise', 'p-signal', 'b-signal', 5, 8.2, 2, 6),
    (7003, 'Embers of Kesh', 'p-embers', 'b-embers', 4, 8.5, 1, 8),
    (7004, 'The Frost Line', 'p-frost', null, 6, 8.0, 4, 14),
    (7005, 'Parallel Station', 'p-parallel', null, 2, 7.9, 1, 0),
    (7006, 'The Keepers', 'p-lighthouse', 'b-lighthouse', 1, 7.8, 2, 2),
    (7007, 'Atlas of Rivers', 'p-rivers', 'b-rivers', 3, 8.4, 1, 3),
  ];

  List<Map<String, Object?>> _series() => [
        for (final (id, title, poster, backdrop, cat, rating, _, ago) in _shows)
          {
            'series_id': id,
            'name': title,
            'cover': '$_a/$poster.jpg',
            'backdrop_path': ['$_a/${backdrop ?? 'b-hollow'}.jpg'],
            'plot': 'A ${_seriesCats[cat - 1].toLowerCase()} series from the demo provider.',
            'genre': _seriesCats[cat - 1],
            'rating': '$rating',
            'releaseDate': '2024-01-01',
            'last_modified': '${_now - ago * 86400}',
            'category_id': '$cat',
          },
      ];

  static const _hollowS3 = [
    ('The Quiet Succession', 52, 'A funeral on the waterfront leaves an empty chair at the head of the Varro table.'),
    ('Paper Kings', 49, 'Ines follows a ledger that should not exist into the port authority archive.'),
    ('Lanterns Out', 55, 'A citywide blackout gives both sides one night to move without being seen.'),
    ('Ash on the Avenue', 51, 'The union vote is moved up, and someone inside the precinct makes a call.'),
    ('Low Tide at Pier 9', 47, 'An old witness surfaces with a photograph that rewrites the first season.'),
    ('Crown of Nothing', 58, 'The district chooses its next owner — and the price of keeping it.'),
  ];

  Map<String, Object?> _seriesInfo(String id) {
    final s = _shows.where((s) => '${s.$1}' == id).firstOrNull;
    if (s == null) return const {};
    final (sid, title, poster, backdrop, cat, rating, seasons, _) = s;
    final episodes = <String, List<Map<String, Object?>>>{};
    for (var season = 1; season <= seasons; season++) {
      final hollowFinal = sid == 7001 && season == 3;
      final count = hollowFinal ? _hollowS3.length : 6;
      episodes['$season'] = [
        for (var e = 1; e <= count; e++)
          {
            'id': '${sid * 100 + season * 10 + e}',
            'episode_num': e,
            'title': hollowFinal ? _hollowS3[e - 1].$1 : 'Episode $e',
            'container_extension': 'mp4',
            'season': season,
            'info': {
              'duration_secs': (hollowFinal ? _hollowS3[e - 1].$2 : 45) * 60,
              'plot': hollowFinal ? _hollowS3[e - 1].$3 : 'Season $season, episode $e of $title.',
              'movie_image': '$_a/e-${(e - 1) % 6 + 1}.jpg',
            },
          },
      ];
    }
    return {
      'seasons': [for (var n = 1; n <= seasons; n++) {'season_number': n, 'name': 'Season $n', 'episode_count': episodes['$n']!.length}],
      'info': {
        'name': title,
        'cover': '$_a/$poster.jpg',
        'backdrop_path': ['$_a/${backdrop ?? 'b-hollow'}.jpg'],
        'plot': sid == 7001
            ? 'Three families, one waterfront district, and a crown nobody can keep for long.'
            : 'A ${_seriesCats[cat - 1].toLowerCase()} series from the demo provider.',
        'cast': 'Ines Varro, Teo Marsh, Lena Okafor',
        'director': 'R. Vale',
        'genre': _seriesCats[cat - 1],
        'rating': '$rating',
        'youtube_trailer': 'dQw4w9WgXcQ',
      },
      'episodes': episodes,
    };
  }

  // Guide: each channel loops its line-up, anchored so the design's evening
  // schedule plays around the current time.
  static const _lineups = {
    'mn.demo': ('b-news', [('World at Seven', 60), ('The Evening Bulletin', 60), ('World Desk', 30), ('Markets Tonight', 30), ('The Briefing', 60)]),
    'p1.demo': ('b-stadium', [('Pre-Match Live', 60), ('Coastal FC vs Northern United', 120), ('Match Review', 30)]),
    'p2.demo': ('b-stadium', [('Grand Prix Qualifying', 90), ('Paddock Talk', 30), ('Tennis Classics', 90)]),
    'cp.demo': ('b-neon', [('Neon Requiem', 125), ('Iron Tide', 110)]),
    'ad.demo': ('b-rivers', [('Atlas of Rivers: The Delta', 60), ('Deep Ocean Cities', 60), ('Wild Plains', 60)]),
    'kz.demo': ('b-kids', [('Little Lantern Tales', 30), ('Paper Planets', 30), ('Moon Garden', 30), ('Bedtime Beats', 60)]),
    'wv.demo': ('b-concert', [('Live at the Arena', 120), ('Chart Rewind', 60)]),
    'h1.demo': ('b-hollow', [('Kitchen Duel', 45), ('Hollow Crown District', 60), ('Late Lounge', 75)]),
    'nn.demo': ('b-northbound', [('Northbound: An Arctic Year', 60), ('Coastlines', 60)]),
    'ow.demo': ('b-signal', [('World Report', 30), ('Signal & Noise', 50), ('Culture Hour', 60)]),
    'ln.demo': ('b-neon', [('Late Night Feature', 120)]),
  };

  static String _xmltv(DateTime now) {
    String ts(DateTime t) {
      final u = t.toUtc();
      String two(int v) => v.toString().padLeft(2, '0');
      return '${u.year}${two(u.month)}${two(u.day)}${two(u.hour)}${two(u.minute)}00 +0000';
    }

    String esc(String s) => s.replaceAll('&', '&amp;').replaceAll('<', '&lt;');
    final b = StringBuffer('<?xml version="1.0" encoding="UTF-8"?>\n<tv generator-info-name="orbix-demo">\n');
    for (final (_, name, _, epg) in _channels) {
      b.write('<channel id="$epg"><display-name>${esc(name)}</display-name></channel>\n');
    }
    // Anchor: the evening line-up starts 45 min before "now" (design NOW = 20:45).
    final anchor = DateTime.utc(now.year, now.month, now.day, now.hour, now.minute).subtract(const Duration(minutes: 45));
    for (final MapEntry(key: epg, value: (art, lineup)) in _lineups.entries) {
      final loop = lineup.fold<int>(0, (a, p) => a + p.$2);
      // Back 24 h, forward 3 days.
      var t = anchor.subtract(Duration(minutes: (24 * 60 ~/ loop + 1) * loop));
      final end = now.add(const Duration(days: 3));
      while (t.isBefore(end)) {
        for (final (title, minutes) in lineup) {
          final stop = t.add(Duration(minutes: minutes));
          b.write('<programme start="${ts(t)}" stop="${ts(stop)}" channel="$epg"><title lang="en">${esc(title)}</title>'
              '<desc lang="en">${esc(title)} on the demo provider.</desc><icon src="$_a/$art.jpg"/></programme>\n');
          t = stop;
        }
      }
    }
    b.write('</tv>\n');
    return b.toString();
  }
}

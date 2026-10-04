import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../core/background.dart';
import '../../core/failures.dart';
import '../../core/ids.dart';
import '../../core/json.dart';
import '../../credentials/credentials.dart';
import '../../models/catalog.dart';

/// Subscription status from `player_api.php` (`user_info` + `server_info`).
class XtreamAccountInfo {
  const XtreamAccountInfo({
    required this.status,
    this.expiresAt,
    this.isTrial = false,
    this.activeConnections,
    this.maxConnections,
    this.createdAt,
    this.allowedFormats = const [],
    this.serverTimezone,
    this.serverTime,
    this.message,
  });

  /// "Active", "Expired", "Banned", "Disabled"…
  final String status;
  final DateTime? expiresAt;
  final bool isTrial;
  final int? activeConnections;
  final int? maxConnections;
  final DateTime? createdAt;

  /// Live output formats the panel allows: "ts", "m3u8", "rtmp".
  final List<String> allowedFormats;
  final String? serverTimezone;
  final DateTime? serverTime;
  final String? message;

  bool get isActive => status.toLowerCase() == 'active';
}

/// Live output container for [XtreamClient.liveUrl].
enum XtreamLiveFormat { ts, m3u8 }

/// Xtream Codes `player_api.php` client.
///
/// Every call maps transport and protocol errors to [OrbixFailure]. Large
/// lists are decoded and mapped in a background isolate so a 30 MB VOD list
/// never stalls the UI.
class XtreamClient {
  XtreamClient(this._dio, this.credentials);

  final Dio _dio;
  final XtreamCredentials credentials;

  String get _base => credentials.serverUrl;

  Uri _api([Map<String, String> params = const {}]) => Uri.parse('$_base/player_api.php').replace(
        queryParameters: {'username': credentials.username, 'password': credentials.password, ...params},
      );

  Future<Uint8List> _get(Uri uri, {CancelToken? cancel, ProgressCallback? onReceive}) async {
    try {
      final r = await _dio.getUri<List<int>>(
        uri,
        options: Options(responseType: ResponseType.bytes),
        cancelToken: cancel,
        onReceiveProgress: onReceive,
      );
      final data = r.data ?? const <int>[];
      return data is Uint8List ? data : Uint8List.fromList(data);
    } catch (e) {
      throw OrbixFailure.from(e, uri: uri);
    }
  }

  /// Signs in and checks the subscription. Throws
  /// [InvalidCredentialsFailure], [AccountExpiredFailure] or
  /// [AccountDisabledFailure] for the designed error states.
  Future<XtreamAccountInfo> authenticate({CancelToken? cancel, DateTime? now}) async {
    final body = await _get(_api(), cancel: cancel);
    final json = _decodeJson(body);
    // Wrong credentials: `{"user_info":{"auth":0}}`, `[]` or an empty object.
    if (json is! Map || json['user_info'] is! Map) throw const InvalidCredentialsFailure();
    final user = jMap(json['user_info']);
    if (jInt(user['auth']) != 1) throw const InvalidCredentialsFailure();
    final server = jMap(json['server_info']);
    final info = XtreamAccountInfo(
      status: jStr(user['status']) ?? 'Active',
      expiresAt: jEpoch(user['exp_date']),
      isTrial: jBool(user['is_trial']),
      activeConnections: jInt(user['active_cons']),
      maxConnections: jInt(user['max_connections']),
      createdAt: jEpoch(user['created_at']),
      allowedFormats: jList(user['allowed_output_formats']).map(jStr).whereType<String>().toList(),
      serverTimezone: jStr(server['timezone']),
      serverTime: jEpoch(server['timestamp_now']),
      message: jStr(user['message']),
    );
    final status = info.status.toLowerCase();
    final clock = now ?? DateTime.now().toUtc();
    if (status == 'expired' || (info.expiresAt != null && info.expiresAt!.isBefore(clock))) {
      throw AccountExpiredFailure(info.expiresAt);
    }
    if (status == 'banned' || status == 'disabled') throw AccountDisabledFailure(info.status);
    return info;
  }

  // --- Catalog ----------------------------------------------------------------

  Future<List<CatalogCategory>> categories(ContentKind kind, {CancelToken? cancel}) async {
    final action = switch (kind) {
      ContentKind.live => 'get_live_categories',
      ContentKind.movie => 'get_vod_categories',
      ContentKind.series => 'get_series_categories',
    };
    final body = await _get(_api({'action': action}), cancel: cancel);
    return runInBackground(_parseCategories, (body, kind));
  }

  Future<List<CatalogChannel>> liveStreams({String? categoryId, CancelToken? cancel, ProgressCallback? onReceive}) async {
    final body = await _get(
      _api({'action': 'get_live_streams', 'category_id': ?categoryId}),
      cancel: cancel,
      onReceive: onReceive,
    );
    return runInBackground(_parseLive, body);
  }

  Future<List<CatalogMovie>> vodStreams({String? categoryId, CancelToken? cancel, ProgressCallback? onReceive}) async {
    final body = await _get(
      _api({'action': 'get_vod_streams', 'category_id': ?categoryId}),
      cancel: cancel,
      onReceive: onReceive,
    );
    return runInBackground(_parseVod, body);
  }

  Future<List<CatalogSeries>> series({String? categoryId, CancelToken? cancel, ProgressCallback? onReceive}) async {
    final body = await _get(
      _api({'action': 'get_series', 'category_id': ?categoryId}),
      cancel: cancel,
      onReceive: onReceive,
    );
    return runInBackground(_parseSeriesList, body);
  }

  Future<MovieDetails> vodInfo(String vodId, {CancelToken? cancel}) async {
    final body = await _get(_api({'action': 'get_vod_info', 'vod_id': vodId}), cancel: cancel);
    return _parseVodInfo(body, vodId);
  }

  Future<SeriesDetails> seriesInfo(String seriesId, {CancelToken? cancel}) async {
    final body = await _get(_api({'action': 'get_series_info', 'series_id': seriesId}), cancel: cancel);
    return runInBackground(_parseSeriesInfo, (body, seriesId));
  }

  /// Now / next for one channel — fallback when there is no XMLTV guide.
  Future<List<GuideEntry>> shortEpg(String streamId, {String? epgChannelId, int limit = 4, CancelToken? cancel}) async {
    final body = await _get(_api({'action': 'get_short_epg', 'stream_id': streamId, 'limit': '$limit'}), cancel: cancel);
    return _parseShortEpg(body, (epgChannelId ?? streamId).toLowerCase());
  }

  // --- URLs --------------------------------------------------------------------

  String get _u => Uri.encodeComponent(credentials.username);
  String get _p => Uri.encodeComponent(credentials.password);

  String liveUrl(String streamId, {XtreamLiveFormat format = XtreamLiveFormat.ts}) => '$_base/live/$_u/$_p/$streamId.${format.name}';

  String movieUrl(String streamId, String? containerExt) => '$_base/movie/$_u/$_p/$streamId.${containerExt ?? 'mp4'}';

  String episodeUrl(String episodeId, String? containerExt) => '$_base/series/$_u/$_p/$episodeId.${containerExt ?? 'mp4'}';

  /// Catch-up: [start] in the server's local time, [minutes] long.
  String timeshiftUrl(String streamId, DateTime start, int minutes) {
    String two(int v) => v.toString().padLeft(2, '0');
    final t = '${start.year}-${two(start.month)}-${two(start.day)}:${two(start.hour)}-${two(start.minute)}';
    return '$_base/timeshift/$_u/$_p/$minutes/$t/$streamId.ts';
  }

  /// The provider's full XMLTV guide.
  Uri get xmltvUri => Uri.parse('$_base/xmltv.php').replace(queryParameters: {'username': credentials.username, 'password': credentials.password});
}

// --- Parsing (top-level so it can run in Isolate.run) --------------------------

Object? _decodeJson(Uint8List body) {
  final text = utf8.decode(body, allowMalformed: true).trim();
  if (text.isEmpty) return null;
  if (!(text.startsWith('{') || text.startsWith('['))) {
    throw const NotIptvServerFailure('Response is not JSON');
  }
  try {
    return jsonDecode(text);
  } on FormatException catch (e) {
    throw NotIptvServerFailure(e.message);
  }
}

List<Object?> _decodeList(Uint8List body) {
  final json = _decodeJson(body);
  // Some panels answer an empty list as `{}` or `null`, or wrap it in a map.
  return json == null ? const [] : jList(json);
}

List<CatalogCategory> _parseCategories((Uint8List, ContentKind) args) {
  final (body, kind) = args;
  final out = <CatalogCategory>[];
  var i = 0;
  for (final raw in _decodeList(body)) {
    final m = jMap(raw);
    final id = jStr(m['category_id']);
    final name = jStr(m['category_name']);
    if (id == null || name == null) continue;
    out.add(CatalogCategory(id: id, kind: kind, name: name, sortIndex: i++, isAdult: looksAdult(name)));
  }
  return out;
}

List<CatalogChannel> _parseLive(Uint8List body) {
  final out = <CatalogChannel>[];
  var i = 0;
  for (final raw in _decodeList(body)) {
    final m = jMap(raw);
    final id = jStr(m['stream_id']);
    if (id == null) continue;
    out.add(CatalogChannel(
      id: id,
      name: jStr(m['name']) ?? id,
      number: jInt(m['num']),
      logo: jStr(m['stream_icon']),
      categoryId: jStr(m['category_id']),
      epgId: jStr(m['epg_channel_id'])?.toLowerCase(),
      catchupDays: jInt(m['tv_archive']) == 1 ? (jInt(m['tv_archive_duration']) ?? 0) : 0,
      sortIndex: i++,
      addedAt: jEpoch(m['added']),
    ));
  }
  return out;
}

List<CatalogMovie> _parseVod(Uint8List body) {
  final out = <CatalogMovie>[];
  var i = 0;
  for (final raw in _decodeList(body)) {
    final m = jMap(raw);
    final id = jStr(m['stream_id']);
    if (id == null) continue;
    final name = jStr(m['name']) ?? id;
    out.add(CatalogMovie(
      id: id,
      name: name,
      poster: jStr(m['stream_icon']),
      rating: _rating10(m),
      year: jYear(m['year']) ?? jYear(m['releaseDate']) ?? _yearInTitle(name),
      addedAt: jEpoch(m['added']),
      categoryId: jStr(m['category_id']),
      containerExt: jStr(m['container_extension']),
      sortIndex: i++,
    ));
  }
  return out;
}

List<CatalogSeries> _parseSeriesList(Uint8List body) {
  final out = <CatalogSeries>[];
  var i = 0;
  for (final raw in _decodeList(body)) {
    final m = jMap(raw);
    final id = jStr(m['series_id']);
    if (id == null) continue;
    out.add(_seriesFrom(m, id, i++));
  }
  return out;
}

CatalogSeries _seriesFrom(Map<String, Object?> m, String id, int sortIndex) => CatalogSeries(
      id: id,
      name: jStr(m['name']) ?? id,
      cover: jStr(m['cover']),
      backdrop: jFirstStr(m['backdrop_path']),
      plot: jStr(m['plot']),
      rating: _rating10(m),
      year: jYear(m['releaseDate']) ?? jYear(m['release_date']) ?? jYear(m['year']),
      genre: jStr(m['genre']),
      updatedAt: jEpoch(m['last_modified']),
      categoryId: jStr(m['category_id']),
      sortIndex: sortIndex,
    );

/// `rating` is 0–10 on most panels; fall back to `rating_5based` × 2.
double? _rating10(Map<String, Object?> m) {
  final r = jDouble(m['rating']);
  if (r != null && r > 0) return r > 10 ? r / 10 : r;
  final r5 = jDouble(m['rating_5based']);
  return r5 != null && r5 > 0 ? r5 * 2 : null;
}

int? _yearInTitle(String name) {
  final m = RegExp(r'[\(\[]((?:19|20)\d\d)[\)\]]\s*$').firstMatch(name);
  return m == null ? null : int.parse(m.group(1)!);
}

MovieDetails _parseVodInfo(Uint8List body, String id) {
  final json = jMap(_decodeJson(body));
  final info = jMap(json['info']);
  final data = jMap(json['movie_data']);
  return MovieDetails(
    id: id,
    name: jStr(data['name']) ?? jStr(info['name']) ?? jStr(info['o_name']),
    plot: jStr(info['plot']) ?? jStr(info['description']),
    cast: jStr(info['cast']) ?? jStr(info['actors']),
    director: jStr(info['director']),
    genre: jStr(info['genre']),
    durationSecs: jInt(info['duration_secs']) ?? _hms(jStr(info['duration'])),
    backdrop: jFirstStr(info['backdrop_path']),
    poster: jStr(info['movie_image']) ?? jStr(info['cover_big']),
    trailerYoutubeId: jStr(info['youtube_trailer']),
    releaseDate: jStr(info['releasedate']) ?? jStr(info['release_date']),
    rating: _rating10(info),
    tmdbId: jStr(info['tmdb_id']),
    containerExt: jStr(data['container_extension']),
  );
}

SeriesDetails _parseSeriesInfo((Uint8List, String) args) {
  final (body, seriesId) = args;
  final json = jMap(_decodeJson(body));
  final info = jMap(json['info']);
  final seasons = <SeasonInfo>[
    for (final raw in jList(json['seasons']))
      if (jInt(jMap(raw)['season_number']) case final n?)
        SeasonInfo(
          number: n,
          name: jStr(jMap(raw)['name']),
          episodeCount: jInt(jMap(raw)['episode_count']),
          cover: jStr(jMap(raw)['cover_big']) ?? jStr(jMap(raw)['cover']),
          overview: jStr(jMap(raw)['overview']),
        ),
  ];
  // `episodes` is `{"1": [...], "2": [...]}` — or a list of lists on some panels.
  final episodes = <CatalogEpisode>[];
  final rawEpisodes = json['episodes'];
  final groups = rawEpisodes is Map ? rawEpisodes.entries.map((e) => (jInt(e.key), e.value)) : jList(rawEpisodes).map((v) => (null, v));
  for (final (seasonKey, list) in groups) {
    for (final raw in jList(list)) {
      final e = jMap(raw);
      final id = jStr(e['id']);
      if (id == null) continue;
      final epInfo = jMap(e['info']);
      final season = jInt(e['season']) ?? seasonKey ?? 1;
      final number = jInt(e['episode_num']) ?? 0;
      episodes.add(CatalogEpisode(
        id: id,
        seriesId: seriesId,
        season: season,
        episode: number,
        title: jStr(e['title']) ?? 'S$season E$number',
        containerExt: jStr(e['container_extension']),
        durationSecs: jInt(epInfo['duration_secs']) ?? _hms(jStr(epInfo['duration'])),
        plot: jStr(epInfo['plot']),
        still: jStr(epInfo['movie_image']),
        airDate: DateTime.tryParse(jStr(epInfo['releasedate']) ?? jStr(epInfo['air_date']) ?? ''),
      ));
    }
  }
  episodes.sort((a, b) => a.season != b.season ? a.season.compareTo(b.season) : a.episode.compareTo(b.episode));
  if (seasons.isEmpty) {
    for (final s in episodes.map((e) => e.season).toSet()) {
      seasons.add(SeasonInfo(number: s, episodeCount: episodes.where((e) => e.season == s).length));
    }
  }
  seasons.sort((a, b) => a.number.compareTo(b.number));
  return SeriesDetails(
    series: _seriesFrom(info, seriesId, 0),
    seasons: seasons,
    episodes: episodes,
    cast: jStr(info['cast']),
    director: jStr(info['director']),
    trailerYoutubeId: jStr(info['youtube_trailer']),
  );
}

/// "01:52:10" → seconds.
int? _hms(String? s) {
  if (s == null) return null;
  final parts = s.split(':').map(int.tryParse).toList();
  if (parts.isEmpty || parts.contains(null)) return null;
  return parts.fold<int>(0, (acc, p) => acc * 60 + p!);
}

List<GuideEntry> _parseShortEpg(Uint8List body, String channelId) {
  final json = jMap(_decodeJson(body));
  final out = <GuideEntry>[];
  for (final raw in jList(json['epg_listings'])) {
    final m = jMap(raw);
    final start = jEpoch(m['start_timestamp']);
    final stop = jEpoch(m['stop_timestamp']);
    if (start == null || stop == null) continue;
    out.add(GuideEntry(
      channelId: channelId,
      start: start,
      stop: stop,
      // Titles and descriptions are base64 in this endpoint.
      title: _b64(jStr(m['title'])) ?? '',
      description: _b64(jStr(m['description'])),
    ));
  }
  return out;
}

String? _b64(String? s) {
  if (s == null) return null;
  try {
    return utf8.decode(base64.decode(base64.normalize(s)), allowMalformed: true).trim();
  } on FormatException {
    return s;
  }
}

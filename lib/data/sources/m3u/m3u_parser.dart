import 'dart:convert';
import 'dart:typed_data';

import '../../core/failures.dart';
import '../../core/ids.dart';
import '../../models/catalog.dart';

/// One `#EXTINF` entry with its URL.
class M3uEntry {
  const M3uEntry({required this.title, required this.url, this.attributes = const {}, this.group, this.headers, this.duration});

  final String title;
  final String url;

  /// `tvg-id`, `tvg-name`, `tvg-logo`, `group-title`, `tvg-chno`, `catchup-days`…
  /// Keys lower-cased.
  final Map<String, String> attributes;

  /// `group-title`, or the preceding `#EXTGRP`.
  final String? group;

  /// From `#EXTVLCOPT:http-user-agent=` / `http-referrer=` or a Kodi-style
  /// `url|User-Agent=…&Referer=…` suffix.
  final Map<String, String>? headers;
  final int? duration;
}

class M3uPlaylist {
  const M3uPlaylist({required this.entries, this.epgUrls = const []});

  final List<M3uEntry> entries;

  /// From the header: `#EXTM3U url-tvg="a.xml,b.xml" x-tvg-url="…"`.
  final List<String> epgUrls;
}

/// Parser for M3U / M3U8 (extended) playlists.
abstract final class M3uParser {
  /// Parses [text]. Throws [InvalidPlaylistFailure] when it is not a
  /// playlist (HTML error page, empty body, no entries).
  static M3uPlaylist parse(String text) {
    var s = text;
    if (s.startsWith('﻿')) s = s.substring(1);
    final head = s.trimLeft();
    if (head.isEmpty) throw const InvalidPlaylistFailure('Empty playlist');
    final lower = head.length > 200 ? head.substring(0, 200).toLowerCase() : head.toLowerCase();
    if (lower.startsWith('<!doctype') || lower.startsWith('<html') || lower.startsWith('{')) {
      throw const InvalidPlaylistFailure('Not an M3U playlist');
    }

    final entries = <M3uEntry>[];
    final epgUrls = <String>[];
    String? pendingInfo;
    String? pendingGroup;
    Map<String, String>? pendingHeaders;

    var start = 0;
    final n = s.length;
    while (start < n) {
      var end = s.indexOf('\n', start);
      if (end < 0) end = n;
      final line = s.substring(start, end).trim();
      start = end + 1;
      if (line.isEmpty) continue;

      if (line.startsWith('#')) {
        final upper = line.length >= 8 ? line.substring(0, 8).toUpperCase() : line.toUpperCase();
        if (upper.startsWith('#EXTM3U')) {
          final attrs = _parseAttributes(line, 7, line.length).$1;
          for (final key in const ['url-tvg', 'x-tvg-url', 'tvg-url']) {
            final v = attrs[key];
            if (v != null) epgUrls.addAll(v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty));
          }
        } else if (upper.startsWith('#EXTINF:')) {
          pendingInfo = line;
        } else if (upper.startsWith('#EXTGRP:')) {
          pendingGroup = line.substring(8).trim();
        } else if (upper.startsWith('#EXTVLCO')) {
          final opt = line.substring(line.indexOf(':') + 1);
          final eq = opt.indexOf('=');
          if (eq > 0) {
            final key = _headerName(opt.substring(0, eq).trim());
            if (key != null) (pendingHeaders ??= {})[key] = opt.substring(eq + 1).trim();
          }
        }
        continue;
      }

      // A URL line closes the entry.
      var url = line;
      Map<String, String>? headers = pendingHeaders;
      final pipe = url.indexOf('|');
      if (pipe > 0) {
        headers = {...?headers, ..._kodiHeaders(url.substring(pipe + 1))};
        url = url.substring(0, pipe);
      }
      if (!_looksLikeUrl(url)) {
        pendingInfo = null;
        pendingHeaders = null;
        continue;
      }

      String title;
      var attrs = const <String, String>{};
      int? duration;
      if (pendingInfo != null) {
        final info = pendingInfo;
        final colon = info.indexOf(':');
        // Duration runs to the first space or comma.
        var i = colon + 1;
        while (i < info.length && info[i] != ' ' && info[i] != ',') {
          i++;
        }
        duration = int.tryParse(info.substring(colon + 1, i).trim());
        final (parsed, titleStart) = _parseAttributes(info, i, info.length);
        attrs = parsed;
        title = titleStart < info.length ? info.substring(titleStart).trim() : '';
      } else {
        title = '';
      }
      if (title.isEmpty) title = attrs['tvg-name'] ?? _nameFromUrl(url);

      entries.add(M3uEntry(
        title: title,
        url: url,
        attributes: attrs,
        group: _nonEmpty(attrs['group-title']) ?? _nonEmpty(pendingGroup),
        headers: headers == null || headers.isEmpty ? null : headers,
        duration: duration,
      ));
      pendingInfo = null;
      pendingHeaders = null;
      // #EXTGRP applies until the next one.
    }

    if (entries.isEmpty) throw const InvalidPlaylistFailure('No channels found');
    return M3uPlaylist(entries: entries, epgUrls: epgUrls);
  }

  /// Parses `key="value"` pairs from [from] until the title comma (the first
  /// comma outside quotes). Returns the attributes and the index where the
  /// title starts (after the comma), or `to` if there is none.
  static (Map<String, String>, int) _parseAttributes(String line, int from, int to) {
    final attrs = <String, String>{};
    var i = from;
    while (i < to) {
      // skip spaces
      while (i < to && line[i] == ' ') {
        i++;
      }
      if (i >= to) break;
      if (line[i] == ',') return (attrs, i + 1);
      // key
      final keyStart = i;
      while (i < to && line[i] != '=' && line[i] != ' ' && line[i] != ',') {
        i++;
      }
      final key = line.substring(keyStart, i).toLowerCase();
      if (i >= to || line[i] != '=') {
        // A bare token (no value) — ignore; a comma here ends attributes.
        if (i < to && line[i] == ',') return (attrs, i + 1);
        continue;
      }
      i++; // '='
      String value;
      if (i < to && (line[i] == '"' || line[i] == "'")) {
        final quote = line[i];
        final close = line.indexOf(quote, i + 1);
        final valueEnd = close < 0 || close > to ? to : close;
        value = line.substring(i + 1, valueEnd);
        i = valueEnd + 1;
      } else {
        final valueStart = i;
        while (i < to && line[i] != ' ' && line[i] != ',') {
          i++;
        }
        value = line.substring(valueStart, i);
      }
      if (key.isNotEmpty) attrs[key] = value.trim();
    }
    return (attrs, to);
  }

  static String? _headerName(String vlcKey) => switch (vlcKey.toLowerCase()) {
        'http-user-agent' => 'User-Agent',
        'http-referrer' || 'http-referer' => 'Referer',
        'http-origin' => 'Origin',
        'http-cookie' => 'Cookie',
        _ => null,
      };

  static Map<String, String> _kodiHeaders(String s) {
    final out = <String, String>{};
    for (final pair in s.split('&')) {
      final eq = pair.indexOf('=');
      if (eq <= 0) continue;
      out[pair.substring(0, eq).trim()] = Uri.decodeComponent(pair.substring(eq + 1).trim());
    }
    return out;
  }

  static bool _looksLikeUrl(String s) {
    final i = s.indexOf('://');
    return i > 0 && i < 12 || s.startsWith('/');
  }

  static String _nameFromUrl(String url) {
    final path = Uri.tryParse(url)?.pathSegments.where((p) => p.isNotEmpty).lastOrNull;
    return path ?? url;
  }

  static String? _nonEmpty(String? s) => s == null || s.trim().isEmpty ? null : s.trim();
}

// --- Playlist → catalog ------------------------------------------------------------

const _vodExtensions = {'mp4', 'mkv', 'avi', 'mov', 'm4v', 'webm', 'wmv', 'mpg', 'mpeg', 'divx', 'flv', '3gp'};

final _episodePattern = RegExp(r'^(.*?)[\s._\-:|]*\bS(\d{1,2})[\s._-]*E(\d{1,4})\b[\s._\-:|]*(.*)$', caseSensitive: false);

/// Xtream-style paths carry a stable numeric id: `/live/u/p/123.ts`,
/// `/movie/u/p/456.mkv`, `/u/p/789`.
final _xtreamPath = RegExp(r'/(?:(live|movie|series)/)?[^/]+/[^/]+/(\d+)(?:\.(\w+))?$');

enum _EntryKind { live, movie, episode }

/// Classifies playlist entries and builds a [CatalogSnapshot]. Pure — runs in
/// a background isolate via [parseM3uCatalog].
CatalogSnapshot buildM3uCatalog(M3uPlaylist playlist) {
  final categories = <String, CatalogCategory>{};
  final channels = <CatalogChannel>[];
  final movies = <CatalogMovie>[];
  final series = <String, CatalogSeries>{};
  final episodes = <CatalogEpisode>[];
  final usedIds = <String>{};

  String unique(String id) {
    if (usedIds.add(id)) return id;
    var i = 2;
    while (!usedIds.add('$id~$i')) {
      i++;
    }
    return '$id~$i';
  }

  String? categoryFor(ContentKind kind, String? group) {
    if (group == null) return null;
    final id = stableId('${kind.name}|$group');
    categories.putIfAbsent(
      id,
      () => CatalogCategory(id: id, kind: kind, name: group, sortIndex: categories.length, isAdult: looksAdult(group)),
    );
    return id;
  }

  var order = 0;
  for (final e in playlist.entries) {
    final uri = Uri.tryParse(e.url);
    final path = uri?.path ?? e.url;
    final x = _xtreamPath.firstMatch(path);
    final ext = (x?.group(3) ?? _extension(path))?.toLowerCase();
    final pathKind = x?.group(1);
    final typeAttr = e.attributes['tvg-type']?.toLowerCase();
    final episodeMatch = _episodePattern.firstMatch(e.title);

    final kind = switch ((pathKind, typeAttr)) {
      ('series', _) || (_, 'series') => _EntryKind.episode,
      ('movie', _) || (_, 'movie') || (_, 'vod') => episodeMatch != null ? _EntryKind.episode : _EntryKind.movie,
      ('live', _) || (_, 'live') => _EntryKind.live,
      _ when ext != null && _vodExtensions.contains(ext) => episodeMatch != null ? _EntryKind.episode : _EntryKind.movie,
      _ => _EntryKind.live,
    };
    final providerId = x?.group(2);
    final logo = e.attributes['tvg-logo'] ?? e.attributes['logo'];
    order++;

    switch (kind) {
      case _EntryKind.live:
        channels.add(CatalogChannel(
          id: unique(providerId != null ? 'l$providerId' : stableId('live|${e.title}|${e.group}|${e.attributes['tvg-id']}')),
          name: e.title,
          number: int.tryParse(e.attributes['tvg-chno'] ?? e.attributes['channel-number'] ?? ''),
          logo: logo,
          categoryId: categoryFor(ContentKind.live, e.group),
          epgId: e.attributes['tvg-id']?.trim().toLowerCase().nullIfEmpty,
          streamUrl: e.url,
          headers: e.headers,
          catchupDays: int.tryParse(e.attributes['catchup-days'] ?? e.attributes['timeshift'] ?? '') ?? 0,
          sortIndex: order,
        ));
      case _EntryKind.movie:
        movies.add(CatalogMovie(
          id: unique(providerId != null ? 'm$providerId' : stableId('movie|${e.title}|${e.group}')),
          name: e.title,
          poster: logo,
          year: _yearIn(e.title),
          categoryId: categoryFor(ContentKind.movie, e.group),
          containerExt: ext,
          streamUrl: e.url,
          sortIndex: order,
        ));
      case _EntryKind.episode:
        final name = (episodeMatch?.group(1) ?? e.title).trim();
        final seriesName = name.isEmpty ? (e.group ?? e.title) : name;
        final seriesId = stableId('series|$seriesName|${e.group}');
        series.putIfAbsent(
          seriesId,
          () => CatalogSeries(id: seriesId, name: seriesName, cover: logo, categoryId: categoryFor(ContentKind.series, e.group), sortIndex: series.length),
        );
        final season = int.tryParse(episodeMatch?.group(2) ?? '') ?? 1;
        final number = int.tryParse(episodeMatch?.group(3) ?? '') ?? 0;
        final rest = episodeMatch?.group(4)?.trim();
        episodes.add(CatalogEpisode(
          id: unique(providerId != null ? 'e$providerId' : stableId('episode|$seriesId|$season|$number|${e.title}')),
          seriesId: seriesId,
          season: season,
          episode: number,
          title: rest == null || rest.isEmpty ? e.title : rest,
          containerExt: ext,
          streamUrl: e.url,
          still: logo,
        ));
    }
  }

  return CatalogSnapshot(
    categories: categories.values.toList(),
    channels: channels,
    movies: movies,
    series: series.values.toList(),
    episodes: episodes,
    epgUrls: playlist.epgUrls,
  );
}

/// Decode + parse + classify — the whole import, meant for [runInBackground].
CatalogSnapshot parseM3uCatalog(Uint8List bytes) => buildM3uCatalog(M3uParser.parse(utf8.decode(bytes, allowMalformed: true)));

String? _extension(String path) {
  final slash = path.lastIndexOf('/');
  final dot = path.lastIndexOf('.');
  return dot > slash && dot < path.length - 1 ? path.substring(dot + 1) : null;
}

int? _yearIn(String title) {
  final m = RegExp(r'[\(\[\s-]((?:19|20)\d\d)[\)\]]?\s*$').firstMatch(title);
  return m == null ? null : int.parse(m.group(1)!);
}

extension on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:orbix/data/core/failures.dart';
import 'package:orbix/data/core/json.dart';
import 'package:orbix/data/credentials/credentials.dart';
import 'package:orbix/data/models/catalog.dart';
import 'package:orbix/data/sources/epg/xmltv_parser.dart';
import 'package:orbix/data/sources/m3u/m3u_parser.dart';

import '../support/fake_http.dart';

void main() {
  group('M3U parser', () {
    final playlist = M3uParser.parse(sampleM3u);

    test('header guides, BOM and CRLF', () {
      expect(playlist.epgUrls, ['http://epg.example/guide.xml.gz', 'http://epg.example/b.xml']);
      expect(playlist.entries.first.title, 'Meridian News');
      expect(playlist.entries.first.url, 'http://line.example:8080/live/u/p/1001.ts');
    });

    test('attributes, quoted commas and title commas', () {
      final p1 = playlist.entries[1];
      expect(p1.group, 'Sports, Live');
      expect(p1.title, 'Pulse Sports 1, HD');
      expect(p1.attributes['tvg-id'], 'pulse1.uk');
    });

    test('per-stream headers from EXTVLCOPT and Kodi pipes; EXTGRP group', () {
      expect(playlist.entries[1].headers, {'User-Agent': 'OrbixTest/1.0', 'Referer': 'http://ref.example/'});
      final kodi = playlist.entries[2];
      expect(kodi.url, 'http://cdn.example/kids.m3u8');
      expect(kodi.headers, {'User-Agent': 'Kodi/20', 'Referer': 'http://kodi.example'});
      expect(kodi.group, 'Kids');
    });

    test('entries without URL are dropped', () {
      expect(playlist.entries.where((e) => e.title.startsWith('Broken')), isEmpty);
      expect(playlist.entries, hasLength(9));
    });

    test('rejects non-playlists', () {
      expect(() => M3uParser.parse('<!DOCTYPE html><html>Login</html>'), throwsA(isA<InvalidPlaylistFailure>()));
      expect(() => M3uParser.parse('   '), throwsA(isA<InvalidPlaylistFailure>()));
      expect(() => M3uParser.parse('#EXTM3U\n#EXTINF:-1,No URL\n'), throwsA(isA<InvalidPlaylistFailure>()));
    });

    test('classifies live / movie / series and builds stable ids', () {
      final c = buildM3uCatalog(playlist);
      expect(c.channels.map((e) => e.name), ['Meridian News', 'Pulse Sports 1, HD', 'Kodi Style', 'Meridian News']);
      expect(c.movies.map((e) => e.name), ['The Last Meridian (2026)', 'Iron Tide']);
      expect(c.series.single.name, 'Northbound');
      expect(c.episodes.map((e) => (e.season, e.episode)), [(1, 1), (1, 2), (2, 1)]);
      expect(c.episodes[1].title, 'The Border');

      // Xtream-shaped URLs keep the provider id (survives credential changes).
      expect(c.channels.first.id, 'l1001');
      expect(c.movies.first.id, 'm5001');
      expect(c.movies.first.year, 2026);
      expect(c.movies.first.containerExt, 'mkv');
      expect(c.channels.first.number, 101);
      expect(c.channels.first.epgId, 'meridian.uk');
      // Duplicate names in the same group still get distinct ids.
      expect(c.channels.map((e) => e.id).toSet(), hasLength(4));
      // Re-parsing yields the same ids.
      expect(buildM3uCatalog(M3uParser.parse(sampleM3u)).channels.map((e) => e.id), c.channels.map((e) => e.id));
      expect(c.categories.where((x) => x.kind == ContentKind.live).map((x) => x.name), ['News', 'Sports, Live', 'Kids']);
    });

    test('100k-entry playlist parses quickly', () {
      final b = StringBuffer('#EXTM3U\n');
      for (var i = 0; i < 100000; i++) {
        b
          ..write('#EXTINF:-1 tvg-id="ch$i" tvg-logo="http://img/$i.png" group-title="Group ${i % 50}",Channel $i\n')
          ..write('http://line.example/live/u/p/$i.ts\n');
      }
      final sw = Stopwatch()..start();
      final c = parseM3uCatalog(utf8.encode(b.toString()));
      sw.stop();
      expect(c.channels, hasLength(100000));
      expect(sw.elapsed, lessThan(const Duration(seconds: 5)), reason: 'took ${sw.elapsedMilliseconds} ms');
    });
  });

  group('XMLTV parser', () {
    final from = DateTime.utc(2026, 10, 3, 12);
    final to = DateTime.utc(2026, 10, 10);

    test('times with and without offsets', () {
      expect(XmltvParser.parseTime('20261003230000 +0300'), DateTime.utc(2026, 10, 3, 20));
      expect(XmltvParser.parseTime('20261003193000'), DateTime.utc(2026, 10, 3, 19, 30));
      expect(XmltvParser.parseTime('202610031930 -0130'), DateTime.utc(2026, 10, 3, 21));
      expect(XmltvParser.parseTime('20261003193000 +05:30'), DateTime.utc(2026, 10, 3, 14));
      expect(XmltvParser.parseTime('garbage'), isNull);
    });

    test('channels, entities, CDATA, first title wins, filters', () {
      final r = XmltvParser.parseString(
        sampleXmltv,
        filter: XmltvFilter(channelIds: {'meridian.uk', 'pulse1.uk'}, from: from, to: to),
      );
      expect(r.channels.map((c) => c.id), ['meridian.uk', 'pulse1.uk']);
      expect(r.channels.first.icon, 'http://img/mn.png');
      expect(r.channels.first.names, ['Meridian News']);

      final titles = r.programmes.map((p) => p.title).toList();
      expect(titles, ['Early News', 'The Evening Bulletin', 'Late Edition', 'Coastal FC vs Northern United']);
      final bulletin = r.programmes[1];
      expect(bulletin.start, DateTime.utc(2026, 10, 3, 20));
      expect(bulletin.description, 'Headlines & weather');
      expect(bulletin.category, 'News');
      expect(r.programmes[2].description, 'In <depth>.');
      // Channel ids normalised: "PULSE1.uk" matches.
      expect(r.programmes[3].channelId, 'pulse1.uk');
      expect(r.skipped, 2, reason: 'out of window + unknown channel');
    });

    test('parseFile: plain and gzip, in an isolate, with progress', () async {
      final dir = await Directory.systemTemp.createTemp('xmltv');
      addTearDown(() => dir.delete(recursive: true));
      final plain = File('${dir.path}/g.xml')..writeAsStringSync(sampleXmltv);
      final gz = File('${dir.path}/g.xml.gz')..writeAsBytesSync(gzip.encode(utf8.encode(sampleXmltv)));

      for (final f in [plain, gz]) {
        final progress = <double>[];
        final r = await XmltvParser.parseFile(f.path, filter: XmltvFilter(from: from, to: to), onProgress: progress.add);
        expect(r.programmes, hasLength(5), reason: f.path);
        expect(progress.last, 1.0);
      }
    });

    test('rejects non-XMLTV files', () async {
      final dir = await Directory.systemTemp.createTemp('xmltv');
      addTearDown(() => dir.delete(recursive: true));
      final f = File('${dir.path}/x.xml')..writeAsStringSync('{"not": "xml"}');
      await expectLater(XmltvParser.parseFile(f.path), throwsA(isA<InvalidGuideFailure>()));
    });
  });

  group('helpers', () {
    test('lenient JSON', () {
      expect(jInt('12'), 12);
      expect(jInt('7.0'), 7);
      expect(jInt(''), isNull);
      expect(jDouble('8,5'), 8.5);
      expect(jStr(' null '), isNull);
      expect(jBool('1'), isTrue);
      expect(jEpoch('0'), isNull);
      expect(jList({'0': 'a', '1': 'b'}), ['a', 'b']);
      expect(jYear('14/03/2026'), 2026);
    });

    test('server URL normalisation', () {
      expect(normalizeServerUrl('line.example.tv:8080'), 'http://line.example.tv:8080');
      expect(normalizeServerUrl('https://line.example.tv/'), 'https://line.example.tv');
      // :80 is http's default port — dropped, equivalent URL.
      expect(normalizeServerUrl('http://line.example.tv:80/player_api.php?username=a'), 'http://line.example.tv');
      expect(normalizeServerUrl('http://line.example.tv:8000/get.php'), 'http://line.example.tv:8000');
      expect(normalizeServerUrl('http://host.tv/xtream/'), 'http://host.tv/xtream');
    });

    test('Xtream M3U links are recognised', () {
      final c = XtreamCredentials.tryFromPlaylistUrl('http://line.example:8080/get.php?username=u1&password=p%40ss&type=m3u_plus&output=ts');
      expect(c?.serverUrl, 'http://line.example:8080');
      expect(c?.username, 'u1');
      expect(c?.password, 'p@ss');
      expect(XtreamCredentials.tryFromPlaylistUrl('http://cdn.example/list.m3u'), isNull);
    });

    test('credentials round-trip as JSON', () {
      final x = XtreamCredentials(serverUrl: 'line.tv:8080', username: 'u', password: 'p', epgUrl: 'http://e');
      final back = AccountCredentials.decode(x.encode()) as XtreamCredentials;
      expect((back.serverUrl, back.username, back.password, back.epgUrl), ('http://line.tv:8080', 'u', 'p', 'http://e'));
      const p = PlaylistCredentials(playlistUrl: 'http://h/list.m3u', headerEpgUrls: ['http://g']);
      final pb = AccountCredentials.decode(p.encode()) as PlaylistCredentials;
      expect(pb.playlistUrl, 'http://h/list.m3u');
      expect(pb.headerEpgUrls, ['http://g']);
      expect(pb.displayHost, 'h');
    });
  });
}

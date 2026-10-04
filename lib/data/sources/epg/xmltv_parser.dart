import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:xml/xml_events.dart';

import '../../core/failures.dart';
import '../../models/catalog.dart';

/// What to keep while parsing — applied on the fly so a 150 MB guide never
/// sits in memory, only the programmes this account can show.
class XmltvFilter {
  const XmltvFilter({this.channelIds, this.from, this.to, this.maxDescription = 600});

  /// Normalised (lower-case) channel ids to keep; null keeps all.
  final Set<String>? channelIds;

  /// Keep programmes overlapping [from, to).
  final DateTime? from;
  final DateTime? to;

  /// Descriptions are trimmed to this many characters.
  final int maxDescription;
}

class XmltvChannel {
  const XmltvChannel({required this.id, this.names = const [], this.icon});

  /// Normalised (lower-case) id.
  final String id;
  final List<String> names;
  final String? icon;
}

class XmltvResult {
  const XmltvResult({required this.channels, required this.programmes, required this.skipped});

  final List<XmltvChannel> channels;
  final List<GuideEntry> programmes;

  /// Programmes dropped by the filter or for bad timestamps.
  final int skipped;
}

/// XMLTV guide parser (streaming, event-based).
abstract final class XmltvParser {
  /// Parses an in-memory document synchronously (small guides, tests).
  static XmltvResult parseString(String xml, {XmltvFilter filter = const XmltvFilter()}) {
    final b = _Builder(filter);
    try {
      for (final event in XmlEventDecoder().convert(xml)) {
        b.add(event);
      }
    } on FormatException catch (e) {
      throw InvalidGuideFailure(e.message);
    }
    return b.result();
  }

  /// Parses an XMLTV file (plain or gzip) in a background isolate.
  /// [onProgress] receives 0…1 by bytes read.
  static Future<XmltvResult> parseFile(String path, {XmltvFilter filter = const XmltvFilter(), void Function(double progress)? onProgress}) async {
    final port = ReceivePort();
    final sub = port.listen((m) {
      if (m is double) onProgress?.call(m);
    });
    try {
      return await Isolate.run(_FileJob(path, filter, port.sendPort).run);
    } finally {
      await sub.cancel();
      port.close();
    }
  }

  /// XMLTV time: `20261003203000 +0300`, `20261003203000`, `202610032030 Z`.
  /// No offset means UTC. Returns null when unparseable.
  static DateTime? parseTime(String s) {
    final m = _time.firstMatch(s.trim());
    if (m == null) return null;
    int g(int i) => int.parse(m.group(i)!);
    var t = DateTime.utc(g(1), g(2), g(3), g(4), g(5), m.group(6) == null ? 0 : g(6));
    final tz = m.group(7);
    if (tz != null && tz != 'Z') {
      final sign = tz.startsWith('-') ? -1 : 1;
      final digits = tz.substring(1).replaceAll(':', '');
      final offset = Duration(hours: int.parse(digits.substring(0, 2)), minutes: int.parse(digits.substring(2, 4)));
      t = t.subtract(offset * sign);
    }
    return t;
  }

  static final _time = RegExp(r'^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})?\s*([+-]\d{2}:?\d{2}|Z)?');
}

/// The isolate entry for [XmltvParser.parseFile] — a sendable object whose
/// `run` tear-off captures only plain data and a SendPort.
class _FileJob {
  const _FileJob(this.path, this.filter, this.progress);

  final String path;
  final XmltvFilter filter;
  final SendPort progress;

  Future<XmltvResult> run() async {
    final file = File(path);
    final total = await file.length();
    if (total == 0) throw const InvalidGuideFailure('Empty guide');

    // gzip magic 1f 8b → decompress on the fly (.xml.gz guides are common).
    final head = await file.openRead(0, 2).fold<List<int>>([], (a, b) => a..addAll(b));
    final gz = head.length == 2 && head[0] == 0x1f && head[1] == 0x8b;

    var read = 0;
    var lastReported = -1;
    final bytes = file.openRead().map((chunk) {
      read += chunk.length;
      final pct = read * 100 ~/ total;
      if (pct != lastReported) {
        lastReported = pct;
        progress.send(pct / 100);
      }
      return chunk;
    });

    final b = _Builder(filter);
    final Stream<List<int>> raw = gz ? bytes.transform(gzip.decoder) : bytes;
    try {
      await for (final events in raw.transform(const Utf8Decoder(allowMalformed: true)).transform(XmlEventDecoder())) {
        for (final e in events) {
          b.add(e);
        }
      }
    } on FormatException catch (e) {
      throw InvalidGuideFailure(e.message);
    }
    if (!b.sawRoot) throw const InvalidGuideFailure('Not an XMLTV document');
    return b.result();
  }
}

/// Event-driven state machine over `<tv>`, `<channel>` and `<programme>`.
class _Builder {
  _Builder(this.filter)
      : _from = filter.from,
        _to = filter.to;

  final XmltvFilter filter;
  final DateTime? _from;
  final DateTime? _to;

  final channels = <XmltvChannel>[];
  final programmes = <GuideEntry>[];
  int skipped = 0;
  bool sawRoot = false;

  // current <channel>
  String? _chId;
  List<String>? _chNames;
  String? _chIcon;

  // current <programme>
  bool _inProgramme = false;
  bool _keep = false;
  String? _pChannel;
  DateTime? _pStart;
  DateTime? _pStop;
  String? _pTitle;
  String? _pDesc;
  String? _pCategory;
  String? _pImage;

  // text capture
  String? _textTarget; // 'title' | 'desc' | 'category' | 'display-name'
  final _text = StringBuffer();

  void add(XmlEvent e) {
    switch (e) {
      case XmlStartElementEvent():
        _start(e);
      case XmlEndElementEvent():
        _end(e.name);
      case XmlTextEvent(:final value):
        if (_textTarget != null) _text.write(value);
      case XmlCDATAEvent(:final value):
        if (_textTarget != null) _text.write(value);
      default:
        break;
    }
  }

  String? _attr(XmlStartElementEvent e, String name) {
    for (final a in e.attributes) {
      if (a.name == name) return a.value;
    }
    return null;
  }

  void _start(XmlStartElementEvent e) {
    switch (e.name) {
      case 'tv':
        sawRoot = true;
      case 'channel':
        _chId = _attr(e, 'id')?.trim().toLowerCase();
        _chNames = [];
        _chIcon = null;
        if (e.isSelfClosing) _end('channel');
      case 'icon' when _inProgramme:
        if (_keep) _pImage ??= _attr(e, 'src');
      case 'icon' when _chId != null:
        _chIcon ??= _attr(e, 'src');
      case 'display-name' when _chId != null:
        _beginText('display-name');
      case 'programme':
        _inProgramme = true;
        _pChannel = _attr(e, 'channel')?.trim().toLowerCase();
        final start = _attr(e, 'start');
        final stop = _attr(e, 'stop');
        _pStart = start == null ? null : XmltvParser.parseTime(start);
        _pStop = stop == null ? null : XmltvParser.parseTime(stop);
        _pTitle = _pDesc = _pCategory = _pImage = null;
        _keep = _pChannel != null &&
            _pStart != null &&
            _pStop != null &&
            (filter.channelIds == null || filter.channelIds!.contains(_pChannel)) &&
            (_from == null || _pStop!.isAfter(_from)) &&
            (_to == null || _pStart!.isBefore(_to));
        if (e.isSelfClosing) _end('programme');
      case 'title' when _inProgramme && _keep && _pTitle == null:
        _beginText('title');
      case 'desc' when _inProgramme && _keep && _pDesc == null:
        _beginText('desc');
      case 'category' when _inProgramme && _keep && _pCategory == null:
        _beginText('category');
    }
    if (e.isSelfClosing && _textTarget != null && _textTarget == e.name) _end(e.name);
  }

  void _beginText(String target) {
    _textTarget = target;
    _text.clear();
  }

  String? _takeText() {
    final s = _text.toString().trim();
    _textTarget = null;
    _text.clear();
    return s.isEmpty ? null : s;
  }

  void _end(String name) {
    switch (name) {
      case 'display-name' when _textTarget == 'display-name':
        final t = _takeText();
        if (t != null) _chNames?.add(t);
      case 'title' when _textTarget == 'title':
        _pTitle = _takeText();
      case 'desc' when _textTarget == 'desc':
        final d = _takeText();
        _pDesc = d == null || d.length <= filter.maxDescription ? d : '${d.substring(0, filter.maxDescription).trimRight()}…';
      case 'category' when _textTarget == 'category':
        _pCategory = _takeText();
      case 'channel':
        if (_chId != null && _chId!.isNotEmpty) {
          channels.add(XmltvChannel(id: _chId!, names: _chNames ?? const [], icon: _chIcon));
        }
        _chId = null;
      case 'programme':
        if (_keep && _pStop!.isAfter(_pStart!)) {
          programmes.add(GuideEntry(
            channelId: _pChannel!,
            start: _pStart!,
            stop: _pStop!,
            title: _pTitle ?? '',
            description: _pDesc,
            category: _pCategory,
            image: _pImage,
          ));
        } else {
          skipped++;
        }
        _inProgramme = false;
        _keep = false;
    }
  }

  XmltvResult result() => XmltvResult(channels: channels, programmes: programmes, skipped: skipped);
}

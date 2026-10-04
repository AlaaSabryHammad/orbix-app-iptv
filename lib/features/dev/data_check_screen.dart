import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/design/design.dart';
import '../../core/router/routes.dart';
import '../../data/data.dart';
import '../../shared/widgets/widgets.dart';

/// Dev-only on-device check of the data layer: Keystore-encrypted secrets,
/// SQLite (native library + background isolate), M3U import and XMLTV parsing
/// in isolates. Uses a throwaway local-file account and deletes it afterwards.
class DataCheckScreen extends ConsumerStatefulWidget {
  const DataCheckScreen({super.key});

  @override
  ConsumerState<DataCheckScreen> createState() => _DataCheckScreenState();
}

class _Result {
  _Result(this.name, this.ok, this.detail);

  final String name;
  final bool ok;
  final String detail;
}

class _DataCheckScreenState extends ConsumerState<DataCheckScreen> {
  final _results = <_Result>[];
  bool _running = false;

  Future<void> _step(String name, Future<String> Function() body) async {
    final sw = Stopwatch()..start();
    try {
      final detail = await body();
      _results.add(_Result(name, true, '$detail · ${sw.elapsedMilliseconds} ms'));
    } catch (e) {
      _results.add(_Result(name, false, '$e'));
    }
    if (mounted) setState(() {});
  }

  Future<void> _run() async {
    setState(() {
      _results.clear();
      _running = true;
    });
    final secrets = ref.read(secretStoreProvider);
    final accounts = ref.read(accountRepositoryProvider);
    final catalog = ref.read(catalogRepositoryProvider);
    final library = ref.read(libraryRepositoryProvider);
    final db = ref.read(databaseProvider);
    final tmp = await getTemporaryDirectory();

    await _step('Secure storage (Keystore)', () async {
      final value = 'v${Random.secure().nextInt(1 << 30)}';
      await secrets.write('selftest', value);
      final back = await secrets.read('selftest');
      await secrets.delete('selftest');
      if (back != value) throw StateError('read back $back');
      return 'write → read → delete';
    });

    Account? account;
    await _step('SQLite + M3U import (isolate)', () async {
      final file = File('${tmp.path}/selftest.m3u')..writeAsStringSync(_playlist(3000));
      account = await accounts.create(name: 'Self-test', kind: AccountKind.file, credentials: PlaylistCredentials(filePath: file.path));
      final last = await catalog.sync(account!).last;
      if (last.failure != null) throw last.failure!;
      final a = (await accounts.byId(account!.id))!;
      return '${a.liveCount} channels · ${a.movieCount} movies · ${a.seriesCount} series';
    });

    await _step('Search + favorites + progress', () async {
      final id = account!.id;
      final found = await catalog.search(id, 'channel 1234');
      await library.toggleFavorite(id, ContentKind.live, found.channels.first.id);
      await library.saveProgress(id, ProgressKind.movie, 'x', position: const Duration(minutes: 5), duration: const Duration(minutes: 90));
      final resume = await library.resumePosition(id, ProgressKind.movie, 'x');
      return '${found.channels.length} hit · resume ${resume?.inMinutes} min';
    });

    await _step('XMLTV parse (isolate, gzip)', () async {
      final f = File('${tmp.path}/selftest.xml.gz')..writeAsBytesSync(gzip.encode(_guide(200).codeUnits));
      final r = await XmltvParser.parseFile(f.path);
      await f.delete();
      return '${r.channels.length} channels · ${r.programmes.length} programmes';
    });

    await _step('Cleanup (cascade delete)', () async {
      if (account != null) await accounts.delete(account!.id);
      final left = await (db.select(db.channels)).get();
      return '${left.length} rows left · db ${(await db.sizeInBytes()) ~/ 1024} KB';
    });

    if (mounted) setState(() => _running = false);
  }

  static String _playlist(int n) {
    final b = StringBuffer('#EXTM3U\n');
    for (var i = 0; i < n; i++) {
      b
        ..write('#EXTINF:-1 tvg-id="ch$i" group-title="Group ${i % 20}",Channel $i\n')
        ..write('http://example.invalid/live/u/p/$i.ts\n');
    }
    b
      ..write('#EXTINF:-1 group-title="Movies",Some Movie (2026)\nhttp://example.invalid/movie/u/p/1.mkv\n')
      ..write('#EXTINF:-1 group-title="Shows",Some Show S01E01\nhttp://example.invalid/series/u/p/2.mkv\n');
    return b.toString();
  }

  static String _guide(int channels) {
    final b = StringBuffer('<?xml version="1.0" encoding="UTF-8"?><tv>');
    for (var c = 0; c < channels; c++) {
      b.write('<channel id="ch$c"><display-name>Channel $c</display-name></channel>');
      for (var h = 0; h < 24; h++) {
        final hh = h.toString().padLeft(2, '0');
        final h2 = ((h + 1) % 24).toString().padLeft(2, '0');
        b.write('<programme start="20261003${hh}0000 +0000" stop="2026100${h == 23 ? 4 : 3}${h2}0000 +0000" channel="ch$c"><title>Show $h</title></programme>');
      }
    }
    b.write('</tv>');
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.oxText;
    return Scaffold(
      backgroundColor: OxColors.ink0,
      appBar: AppBar(
        leading: OxIconButton(
          icon: OxIcons.back,
          semanticLabel: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => context.canPop() ? context.pop() : context.go(Routes.gallery),
        ),
        title: const Text('Data layer check'),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(OxWindowSize.of(context).gutter, 8, OxWindowSize.of(context).gutter, 40),
        children: [
          Text('Runs on this device: Keystore secrets, SQLite, M3U import and XMLTV parsing in isolates. Creates and deletes a throwaway account.',
              style: t.body),
          const SizedBox(height: 16),
          OxButton(label: _running ? 'Running…' : 'Run self-test', icon: OxIcons.play, onPressed: _running ? null : _run),
          const SizedBox(height: 20),
          OxGroup(children: [
            for (final r in _results)
              OxListRow(
                icon: r.ok ? OxIcons.check : OxIcons.alert,
                iconColor: r.ok ? OxColors.ok : OxColors.err,
                title: r.name,
                subtitle: r.detail,
              ),
          ]),
          if (_running) const Padding(padding: EdgeInsets.all(24), child: Center(child: OxOrbitLoader())),
        ],
      ),
    );
  }
}

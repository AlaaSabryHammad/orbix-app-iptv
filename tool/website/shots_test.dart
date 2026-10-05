// Renders the landing-page screenshots (website/assets/shots) from the real app
// with the demo data, at 2x:
//   flutter test tool/website/shots_test.dart --update-goldens
// then convert to WebP (see website/README.md).

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbix/core/router/app_router.dart';
import 'package:orbix/core/session/session.dart';
import 'package:orbix/data/data.dart';
import 'package:orbix/features/player/widgets/player_chrome.dart';

import '../../test/support/app_harness.dart';
import '../../test/support/fake_engine.dart';

const phone = Size(412, 892);
final shots = <(String, Size, String, Locale?)>[
  ('home', phone, '/home', null),
  ('live', phone, '/live', null),
  ('guide', phone, '/guide', null),
  ('movie', phone, '/movie/5003', null),
  ('series', phone, '/series/7001', null),
  ('home_ar', phone, '/home', const Locale('ar')),
  ('live_ar', phone, '/live', const Locale('ar')),
  ('tablet_home', const Size(1280, 800), '/home', null),
  ('tablet_live', const Size(1280, 800), '/live', null),
  ('tablet_guide', const Size(1280, 800), '/guide', null),
  ('player', const Size(915, 412), '/play/live/102', null),
  ('player_ar', const Size(915, 412), '/play/movie/5003', const Locale('ar')),
];

void main() {
  for (final (name, size, path, locale) in shots) {
    testWidgets(name, (tester) async {
      FakeEngine.reset();
      FakeEngine.pictureAsset = path.contains('live') ? 'assets/demo/b-stadium.jpg' : 'assets/demo/b-meridian.jpg';
      final h = (await tester.runAsync(() async {
        final h = await AppHarness.create();
        final id = h.container.read(activeAccountIdProvider)!;
        final lib = h.container.read(libraryRepositoryProvider);
        await h.container.read(catalogRepositoryProvider).seriesDetails(id, '7001');
        await lib.saveProgress(id, ProgressKind.episode, '700134', seriesId: '7001', position: const Duration(minutes: 33), duration: const Duration(minutes: 51));
        await lib.saveProgress(id, ProgressKind.movie, '5003', position: const Duration(minutes: 64, seconds: 48), duration: const Duration(minutes: 126));
        await lib.toggleFavorite(id, ContentKind.live, '102');
        return h;
      }))!;
      addTearDown(() => tester.runAsync(h.dispose));
      await h.pump(tester, size: size, locale: locale);
      tester.view.devicePixelRatio = 2;
      tester.view.physicalSize = size * 2;
      if (path.startsWith('/play')) {
        unawaited(h.container.read(appRouterProvider).push(path));
        await h.settle(tester);
        FakeEngine.last.emit((s) => s.copyWith(playing: false, subtitle: [locale == null ? 'Swipe up or down on the right to change volume.' : 'اسحب على اليمين لتغيير الصوت.']));
        FakeEngine.last.moveTo(const Duration(seconds: 23));
        await tester.pump();
        if (find.byType(PlayPauseButton).hitTestable().evaluate().isEmpty) {
          await tester.tapAt(const Offset(200, 300));
          await tester.pump(const Duration(milliseconds: 900));
        }
        await tester.pump(const Duration(milliseconds: 600));
      } else {
        await h.go(tester, path);
      }
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('../../website/assets/shots/$name.png'));
    });
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbix/core/router/app_router.dart';
import 'package:orbix/core/session/session.dart';
import 'package:orbix/core/settings/app_settings.dart';
import 'package:orbix/data/data.dart';
import 'package:orbix/features/player/player_screen.dart';
import 'package:orbix/features/player/widgets/channel_panel.dart';
import 'package:orbix/features/player/widgets/player_chrome.dart';

import '../../support/app_harness.dart';
import '../../support/fake_engine.dart';

const _landscape = Size(915, 412);

Future<AppHarness> _open(WidgetTester tester, String path, {Future<void> Function(AppHarness)? seed}) async {
  FakeEngine.reset();
  final h = (await tester.runAsync(() async {
    final h = await AppHarness.create();
    await seed?.call(h);
    return h;
  }))!;
  addTearDown(() => tester.runAsync(h.dispose));
  await h.pump(tester, size: _landscape);
  unawaited(h.container.read(appRouterProvider).push(path));
  await h.settle(tester);
  expect(find.byType(PlayerScreen), findsOneWidget);
  return h;
}

/// Pauses (so nothing auto-hides) and brings the controls up.
Future<void> _reveal(WidgetTester tester) async {
  FakeEngine.last.emit((s) => s.copyWith(playing: false));
  await tester.pump();
  if (find.byType(PlayPauseButton).hitTestable().evaluate().isEmpty) {
    await tester.tapAt(const Offset(200, 300));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
  }
  expect(find.byType(PlayPauseButton).hitTestable(), findsOneWidget);
}

void main() {
  testWidgets('movie: preferred audio, settings panel switches tracks and remembers the language', (tester) async {
    final h = await _open(tester, '/play/movie/5003');
    final engine = FakeEngine.last;
    expect(engine.opened.single.url, contains('5003'));
    expect(engine.opened.single.loop, isFalse);
    // Settings › Audio language starts with Arabic.
    expect(engine.calls, contains('audio ara'));

    await _reveal(tester);
    expect(find.text('Sands of Avar'), findsOneWidget);
    expect(find.text('Fit'), findsOneWidget);
    expect(find.text('480p'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Playback settings'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Playback settings'), findsOneWidget);

    await tester.tap(find.text('English').first);
    await tester.pump();
    expect(engine.calls.last, 'audio eng');
    expect(h.container.read(appSettingsProvider).audioLanguages.first, 'en');

    await tester.tap(find.text('العربية'));
    await tester.pump();
    expect(engine.calls.last, 'subtitle 4');
    expect(h.container.read(appSettingsProvider).subtitleLanguage, 'ar');

    // Aspect from the panel.
    await tester.tap(find.text('Zoom'));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Done'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Zoom'), findsOneWidget); // chip label
  });

  testWidgets('movie: resumes where it stopped and saves progress on exit', (tester) async {
    late String account;
    final h = await _open(
      tester,
      '/play/movie/5003',
      seed: (h) async {
        account = h.container.read(activeAccountIdProvider)!;
        await h.container.read(libraryRepositoryProvider).saveProgress(account, ProgressKind.movie, '5003', position: const Duration(seconds: 42), duration: const Duration(minutes: 10));
      },
    );
    final engine = FakeEngine.last;
    expect(engine.opened.single.start, const Duration(seconds: 42));

    engine.moveTo(const Duration(seconds: 50));
    await _reveal(tester);
    await tester.tap(find.bySemanticsLabel('Back').first);
    await h.settle(tester);
    expect(find.byType(PlayerScreen), findsNothing);
    expect(engine.disposed, isTrue);
    final saved = await tester.runAsync(() => h.container.read(libraryRepositoryProvider).progress(account, ProgressKind.movie, '5003'));
    expect(saved!.positionMs, 50000);
  });

  testWidgets('live: loops the stream, zaps with channel down, lists the category', (tester) async {
    await _open(tester, '/play/live/102');
    final engine = FakeEngine.last;
    expect(engine.opened.single.loop, isTrue);
    await _reveal(tester);
    expect(find.text('Pulse Sports 1'), findsOneWidget);
    expect(find.text('LIVE'), findsWidgets);

    await tester.tap(find.bySemanticsLabel('Channel down'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pump(const Duration(milliseconds: 300));
    expect(engine.opened.last.url, contains('103'));
    expect(find.text('Pulse Sports 2'), findsOneWidget);

    await _reveal(tester);
    await tester.tap(find.text('Channels'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(ChannelPanel), findsOneWidget);
    expect(find.text('Sports'), findsOneWidget);
  });

  testWidgets('episode: counts down to the next episode and plays it', (tester) async {
    await _open(tester, '/play/episode/7001/700135');
    final engine = FakeEngine.last;
    engine.emit((s) => s.copyWith(completed: true, playing: false));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('UP NEXT IN 10'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(find.textContaining('UP NEXT IN 7'), findsOneWidget);

    await tester.tap(find.text('Play now'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pump(const Duration(milliseconds: 300));
    expect(engine.opened.last.url, contains('700136'));
    expect(find.textContaining('UP NEXT'), findsNothing);
  });
}

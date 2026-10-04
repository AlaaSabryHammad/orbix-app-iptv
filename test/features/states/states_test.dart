import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbix/core/router/app_router.dart';
import 'package:orbix/core/session/session.dart';
import 'package:orbix/data/data.dart';
import 'package:orbix/features/accounts/sync_controller.dart';
import 'package:orbix/features/settings/settings_screen.dart';
import 'package:orbix/shared/widgets/widgets.dart';

import '../../support/app_harness.dart';

/// A provider that never answers in time.
class _TimeoutNetwork implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) =>
      throw DioException(requestOptions: options, type: DioExceptionType.connectionTimeout);

  @override
  void close({bool force = false}) {}
}

/// An account that was added but never synced (empty catalog), made active.
Future<Account> _emptyAccount(AppHarness h, {String server = 'http://line.down.test:8080'}) async {
  final repo = h.container.read(accountRepositoryProvider);
  final a = await repo.create(name: 'Sports Pack', kind: AccountKind.xtream, credentials: XtreamCredentials(serverUrl: server, username: 'u', password: 'p'));
  await h.container.read(sessionProvider).select(a.id);
  return a;
}

void main() {
  testWidgets('06 offline: banner + offline screen when nothing is cached; Settings stays usable', (tester) async {
    final h = (await tester.runAsync(() async {
      final h = await AppHarness.create(demoAccount: false, online: Stream.value(false));
      await _emptyAccount(h);
      return h;
    }))!;
    addTearDown(() => tester.runAsync(h.dispose));
    await h.pump(tester);
    await h.go(tester, '/home');
    expect(find.text('No connection'), findsOneWidget);
    expect(find.text('You’re offline'), findsOneWidget);
    expect(find.text('Network settings'), findsOneWidget);

    await h.go(tester, '/settings');
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('You’re offline'), findsNothing);
  });

  testWidgets('06 offline with a cached catalog: only the banner', (tester) async {
    final h = (await tester.runAsync(() => AppHarness.create(online: Stream.value(false))))!;
    addTearDown(() => tester.runAsync(h.dispose));
    await h.pump(tester);
    await h.go(tester, '/home');
    expect(find.text('No connection'), findsOneWidget);
    expect(find.text('You’re offline'), findsNothing);
  });

  testWidgets('07 server unavailable: message, automatic retry countdown, Retry now', (tester) async {
    final h = (await tester.runAsync(() async {
      final h = await AppHarness.create(demoAccount: false, network: _TimeoutNetwork());
      final a = await _emptyAccount(h);
      await h.container.read(syncControllerProvider.notifier).start(a);
      return h;
    }))!;
    addTearDown(() => tester.runAsync(h.dispose));
    await h.pump(tester);
    await h.go(tester, '/home');
    expect(find.text('Server isn’t responding'), findsOneWidget);
    expect(find.text('Retrying automatically'), findsOneWidget);
    expect(find.text('Retry now'), findsOneWidget);
  });

  testWidgets('08 expired account: status row and refresh', (tester) async {
    final h = (await tester.runAsync(() async {
      final h = await AppHarness.create();
      final id = h.container.read(activeAccountIdProvider)!;
      await h.container.read(accountRepositoryProvider).markStatus(id, AccountStatus.expired, expiresAt: DateTime(2026, 9, 30));
      return h;
    }))!;
    addTearDown(() => tester.runAsync(h.dispose));
    await h.pump(tester);
    await h.go(tester, '/home');
    expect(find.text('This account has expired'), findsOneWidget);
    expect(find.textContaining('30 Sep 2026'), findsOneWidget);
    expect(find.text('Expired'), findsOneWidget);
    expect(find.text('Refresh status'), findsOneWidget);
    expect(find.text('Use another account'), findsOneWidget);
  });

  testWidgets('10 connection failed: Connect shows the failure sheet with the technical line', (tester) async {
    final h = (await tester.runAsync(() => AppHarness.create(demoAccount: false)))!;
    addTearDown(() => tester.runAsync(h.dispose));
    await h.pump(tester);
    await h.go(tester, '/accounts/add');
    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(1), 'http://line.yourprovider.tv:8080');
    await tester.enterText(fields.at(2), 'livingroom');
    await tester.enterText(fields.at(3), 'secret');
    await tester.tap(find.text('Connect'));
    await h.settle(tester);
    expect(find.text('Couldn’t connect'), findsWidgets);
    expect(find.text('Edit details'), findsWidgets);
    expect(find.text('Retry'), findsWidgets);
  });

  testWidgets('12 favorites: hearting confirms with Undo, Undo removes it again', (tester) async {
    final h = (await tester.runAsync(AppHarness.create))!;
    addTearDown(() => tester.runAsync(h.dispose));
    await h.pump(tester);
    unawaited(h.container.read(appRouterProvider).push('/movie/5003'));
    await h.settle(tester);
    await tester.tap(find.text('Favorite').first);
    await h.settle(tester, const Duration(milliseconds: 400));
    expect(find.text('Added to favorites'), findsOneWidget);
    // Toasts live in the root overlay; without a Material their text gets
    // Flutter's yellow debug underline.
    expect(find.ancestor(of: find.byType(OxSnack), matching: find.byType(Material)), findsWidgets);
    final id = h.container.read(activeAccountIdProvider)!;
    Future<bool> isFav() async => (await h.container.read(libraryRepositoryProvider).watchFavoriteIds(id, ContentKind.movie).first).contains('5003');
    expect(await tester.runAsync(isFav), isTrue);
    await tester.tap(find.text('Undo'));
    await h.settle(tester, const Duration(milliseconds: 400));
    expect(await tester.runAsync(isFav), isFalse);
  });

  testWidgets('04 empty search: no matches, genre suggestions', (tester) async {
    final h = (await tester.runAsync(AppHarness.create))!;
    addTearDown(() => tester.runAsync(h.dispose));
    await h.pump(tester);
    await h.go(tester, '/search');
    await tester.enterText(find.byType(EditableText).first, 'zxqv');
    await h.settle(tester);
    expect(find.text('No matches for “zxqv”'), findsOneWidget);
    expect(find.text('Clear filters'), findsNothing);
    expect(find.text('Action'), findsWidgets); // a genre to try
  });
}

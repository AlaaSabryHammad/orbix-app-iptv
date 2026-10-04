import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbix/app.dart';
import 'package:orbix/core/network/connectivity.dart';
import 'package:orbix/core/router/app_router.dart';
import 'package:orbix/core/session/session.dart';
import 'package:orbix/core/settings/app_settings.dart';
import 'package:orbix/data/core/http.dart';
import 'package:orbix/data/data.dart';
import 'package:orbix/features/dev/demo/demo_server.dart';
import 'package:orbix/features/player/engine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'fake_engine.dart';

/// Runs the real app — router, providers, repositories — against the
/// in-process demo provider, an in-memory database and in-memory secrets.
class AppHarness {
  AppHarness._(this.container, this.db);

  final ProviderContainer container;
  final OrbixDatabase db;

  /// Builds the app state. With [demoAccount], adds the demo provider through
  /// the normal path (create → sync → guide) and makes it active. Call inside
  /// `tester.runAsync` (isolates and file IO need real async).
  /// [online] drives connectivity (States 06); always online by default.
  /// [network] answers non-demo requests (default: offline, like a device
  /// without network).
  static Future<AppHarness> create({bool demoAccount = true, Map<String, Object> prefs = const {}, Stream<bool>? online, HttpClientAdapter? network}) async {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.withData(prefs);
    final sp = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(allowList: AppSettingsController.keys),
    );
    final db = OrbixDatabase(NativeDatabase.memory());
    final dio = createDio()..httpClientAdapter = DemoAdapter(network ?? _NoNetwork());
    final tmp = Directory.systemTemp.createTempSync('orbix_test');
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
        databaseProvider.overrideWithValue(db),
        secretStoreProvider.overrideWithValue(MemorySecretStore()),
        dioProvider.overrideWithValue(dio),
        playerEngineFactoryProvider.overrideWithValue(FakeEngine.new),
        onlineProvider.overrideWith((ref) => online ?? Stream.value(true)),
        epgRepositoryProvider.overrideWith(
          (ref) => EpgRepository(ref.watch(databaseProvider), ref.watch(dioProvider), ref.watch(credentialStoreProvider), tempDir: () async => tmp),
        ),
      ],
    );
    final h = AppHarness._(container, db);
    if (demoAccount) await h.addDemoAccount();
    return h;
  }

  Future<Account> addDemoAccount({String name = 'Living Room'}) async {
    final repo = container.read(accountRepositoryProvider);
    final account = await repo.create(
      name: name,
      kind: AccountKind.xtream,
      credentials: XtreamCredentials(serverUrl: DemoServer.serverUrl, username: DemoServer.username, password: DemoServer.password),
    );
    await container.read(catalogRepositoryProvider).sync(account).drain<void>();
    await container.read(epgRepositoryProvider).refresh((await repo.byId(account.id))!).drain<void>();
    await container.read(appSettingsProvider.notifier).update((s) => s.copyWith(onboardingDone: true));
    await container.read(sessionProvider).select(account.id);
    return account;
  }

  /// Pumps the app at [size] and waits past the splash.
  Future<void> pump(WidgetTester tester, {Size size = const Size(412, 915), Locale? locale}) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    if (locale != null) await container.read(appSettingsProvider.notifier).update((s) => s.copyWith(localeCode: () => locale.languageCode));
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const OrbixApp()));
    await settle(tester, const Duration(seconds: 3));
  }

  /// Lets real async work (DB streams, isolates, image decoding) finish,
  /// then pumps frames — a few rounds, since each can start more work.
  Future<void> settle(WidgetTester tester, [Duration frames = const Duration(milliseconds: 800)]) async {
    for (var round = 0; round < 3; round++) {
      for (var i = 0; i < 4; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 80)));
        await tester.pump(frames ~/ 4);
      }
      await tester.runAsync(() async {
        for (final element in find.byType(Image).evaluate().toList()) {
          if (!element.mounted) continue;
          await precacheImage((element.widget as Image).image, element);
        }
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump(const Duration(milliseconds: 700));
    }
  }

  /// Navigates the app's router to [location] and settles.
  Future<void> go(WidgetTester tester, String location) async {
    container.read(appRouterProvider).go(location);
    await settle(tester, const Duration(seconds: 1));
  }

  Future<void> dispose() async {
    container.dispose();
    await db.close();
  }
}

/// Every non-demo request fails like an offline device.
class _NoNetwork implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) =>
      throw const SocketException('Network is unreachable', osError: OSError('Network is unreachable', 101));

  @override
  void close({bool force = false}) {}
}

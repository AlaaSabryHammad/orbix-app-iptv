import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/build_flavor.dart';
import 'core/design/theme.dart';
import 'core/l10n/l10n.dart';
import 'core/settings/app_settings.dart';
import 'data/core/http.dart';
import 'data/providers.dart';
import 'features/dev/debug_errors.dart';
import 'features/dev/demo/demo_server.dart';
import 'features/player/engine.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DebugErrors.install();
  configureDigits();
  MediaKit.ensureInitialized();
  unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
  SystemChrome.setSystemUIOverlayStyle(OrbixTheme.overlayStyle);
  // Loaded before the first frame so the splash can route synchronously.
  final prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(allowList: AppSettingsController.keys),
  );
  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      // The dev flavor also answers the in-process demo provider (demo.orbix.invalid).
      if (isDevFlavor)
        dioProvider.overrideWith((ref) {
          final dio = createDio()..httpClientAdapter = DemoAdapter(createDio().httpClientAdapter);
          ref.onDispose(dio.close);
          return dio;
        }),
      if (isDevFlavor) streamUrlRewriterProvider.overrideWithValue(DemoServer.rewriteStream),
    ],
    child: const OrbixApp(),
  ));
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/design/theme.dart';
import 'core/l10n/l10n.dart';
import 'core/router/app_router.dart';
import 'core/settings/app_settings.dart';
import 'features/dev/debug_errors.dart';
import 'shared/widgets/skeleton.dart';

class OrbixApp extends ConsumerWidget {
  const OrbixApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(appRouterProvider),
      locale: ref.watch(appLocaleProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      scrollBehavior: const _OrbixScrollBehavior(),
      themeMode: ThemeMode.dark,
      theme: OrbixTheme.dark(),
      darkTheme: OrbixTheme.dark(),
      // Typography depends on the resolved locale (Readex Pro + RTL rules for
      // Arabic), which is only known below MaterialApp's Localizations.
      builder: (context, child) => Theme(
        data: OrbixTheme.dark(Localizations.localeOf(context), ref.watch(appSettingsProvider.select((s) => s.theme == PlayerTheme.amoled))),
        // One shimmer clock for every skeleton in the app.
        child: OxShimmerScope(child: DebugErrorOverlay(child: child!)),
      ),
    );
  }
}

/// Lets a mouse drag scroll too (Windows): the horizontal rails have no other
/// way to move with a plain vertical wheel.
class _OrbixScrollBehavior extends MaterialScrollBehavior {
  const _OrbixScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();
}

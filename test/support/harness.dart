import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbix/core/design/design.dart';
import 'package:orbix/core/l10n/l10n.dart';
import 'package:orbix/shared/widgets/skeleton.dart';

/// Pumps [child] inside an Orbix-themed, localized MaterialApp.
Future<void> pumpOx(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
  Size size = const Size(412, 915),
  bool reduceMotion = false,
  bool scaffold = true,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  if (reduceMotion) {
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: OrbixTheme.dark(locale),
      home: OxShimmerScope(child: scaffold ? Scaffold(body: Center(child: child)) : child),
    ),
  );
}

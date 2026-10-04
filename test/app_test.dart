import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbix/core/design/design.dart';
import 'package:orbix/core/router/app_shell.dart';
import 'package:orbix/core/settings/app_settings.dart';
import 'package:orbix/features/settings/settings_screen.dart';
import 'package:orbix/shared/widgets/widgets.dart';

import 'support/app_harness.dart';

void main() {
  testWidgets('shell: floating bottom nav on phones, rail on tablets, Arabic flips direction', (tester) async {
    final h = (await tester.runAsync(AppHarness.create))!;
    addTearDown(() => tester.runAsync(h.dispose));
    await h.pump(tester);

    // Launches into Home with the floating bar; Guide lives under Live TV on phones.
    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(OxBottomNav), findsOneWidget);
    expect(find.text('Guide'), findsNothing);

    // "Profile" opens Settings; content clears the floating bar.
    await tester.tap(find.text('Profile'));
    await h.settle(tester);
    expect(find.byType(SettingsScreen), findsOneWidget);
    final inset = MediaQuery.paddingOf(tester.element(find.text('Settings').first)).bottom;
    expect(inset, greaterThanOrEqualTo(OxSize.bottomNav));

    // Same session, window grows to a 10″ tablet.
    tester.view.physicalSize = const Size(1280, 800);
    await h.settle(tester);
    expect(find.byType(OxBottomNav), findsNothing);
    expect(find.byType(OxNavRail), findsOneWidget);
    expect(find.text('Guide'), findsOneWidget);

    // Arabic: right-to-left layout with the Arabic type scale.
    await h.container.read(appSettingsProvider.notifier).update((s) => s.copyWith(localeCode: () => 'ar'));
    await h.settle(tester);
    final ctx = tester.element(find.byType(SettingsScreen));
    expect(Directionality.of(ctx), TextDirection.rtl);
    expect(Theme.of(ctx).extension<OxTokens>()!.typography, same(OxTypography.ar));
  });
}

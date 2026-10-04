import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbix/core/settings/app_settings.dart';
import 'package:orbix/features/settings/settings_screen.dart';

import '../../support/app_harness.dart';

void main() {
  testWidgets('every option sheet opens; picking Arabic flips the app to RTL', (tester) async {
    final h = (await tester.runAsync(AppHarness.create))!;
    addTearDown(() => tester.runAsync(h.dispose));
    await h.pump(tester, size: const Size(1138, 711));
    await h.go(tester, '/settings');

    // (row, an option the sheet must show)
    for (final (row, option) in [
      ('Start screen', 'Favorites'),
      ('Audio language', 'Turkish'),
      ('Subtitle settings', 'Large'),
      ('Default quality', '720p'),
      ('EPG refresh', 'Every 6 h'),
      ('Guide time shift', '+3 h'),
      ('EPG sources', 'From your provider'),
    ]) {
      await Scrollable.ensureVisible(tester.element(find.text(row)), alignment: 0.5);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text(row));
      await h.settle(tester);
      expect(tester.takeException(), isNull, reason: row);
      expect(find.text(option), findsWidgets, reason: row);
      await tester.binding.handlePopRoute(); // system back closes the sheet
      await h.settle(tester);
    }

    await Scrollable.ensureVisible(tester.element(find.text('Language')), alignment: 0.5);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Language'));
    await h.settle(tester);
    await tester.tap(find.text('العربية'));
    await h.settle(tester);
    expect(h.container.read(appSettingsProvider).localeCode, 'ar');
    expect(find.text('الإعدادات'), findsWidgets);
    expect(Directionality.of(tester.element(find.byType(SettingsScreen))), TextDirection.rtl);
  });
}

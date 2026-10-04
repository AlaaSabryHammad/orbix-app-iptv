import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbix/features/guide/guide_screen.dart';

import '../../support/app_harness.dart';

void main() {
  for (final (name, size, action) in [('phone', const Size(412, 915), 'Watch now'), ('tablet', const Size(1280, 800), 'Watch')]) {
    testWidgets('$name: tapping a programme on air opens its details', (tester) async {
      final h = (await tester.runAsync(AppHarness.create))!;
      addTearDown(() => tester.runAsync(h.dispose));
      await h.pump(tester, size: size);
      await h.go(tester, '/guide');
      expect(find.byType(GuideScreen), findsOneWidget);

      // The demo lineup puts "The Evening Bulletin" on air now on channel 101.
      final all = find.textContaining('The Evening Bulletin');
      final visible = all.evaluate().map((e) => tester.getCenter(find.byWidget(e.widget))).firstWhere((c) => c.dx > 0 && c.dx < size.width);
      await tester.tapAt(visible);
      await h.settle(tester);
      expect(find.text(action), findsOneWidget);
    });
  }
}

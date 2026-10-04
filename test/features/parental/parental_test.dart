import 'package:flutter_test/flutter_test.dart';
import 'package:orbix/core/session/session.dart';
import 'package:orbix/data/data.dart';
import 'package:orbix/features/parental/parental_screen.dart';
import 'package:orbix/features/parental/pin_entry.dart';
import 'package:orbix/features/player/player_screen.dart';
import 'package:orbix/shared/widgets/widgets.dart';

import '../../support/app_harness.dart';

void main() {
  Future<void> typePin(WidgetTester tester, AppHarness h, String pin) async {
    for (final d in pin.split('')) {
      await tester.tap(find.text(d).last);
      await tester.pump(const Duration(milliseconds: 50));
    }
    await h.settle(tester);
  }

  testWidgets('create a PIN, lock a category, unlock its movie with the PIN', (tester) async {
    final h = (await tester.runAsync(AppHarness.create))!;
    addTearDown(() => tester.runAsync(h.dispose));
    await h.pump(tester);

    // No PIN yet: the parental screen opens directly.
    await h.go(tester, '/settings/parental');
    expect(find.byType(ParentalScreen), findsOneWidget);
    expect(find.text('Protection is off'), findsOneWidget);

    // Switch PIN protection on → create + confirm.
    await tester.tap(find.byType(OxSwitch).first);
    await h.settle(tester);
    expect(find.text('Create a 4-digit PIN'), findsOneWidget);
    await typePin(tester, h, '1234');
    expect(find.text('Enter it again'), findsOneWidget);
    await typePin(tester, h, '1234');
    expect(find.text('Protection is on'), findsOneWidget);

    // Lock the category of movie 5003, then re-lock the session.
    final account = h.container.read(activeAccountIdProvider)!;
    final movie = (await tester.runAsync(() => h.container.read(catalogRepositoryProvider).movie(account, '5003')))!;
    await tester.runAsync(() => h.container.read(lockRepositoryProvider).setLocked(account, LockKind.movieCategory, movie.categoryId!, true));
    h.container.read(parentalProvider).lock();

    await h.go(tester, '/play/movie/5003');
    expect(find.byType(PinEntryView), findsOneWidget);
    expect(find.text('This content is locked'), findsOneWidget);

    await typePin(tester, h, '0000');
    expect(find.text('Wrong PIN. Try again.'), findsOneWidget);
    expect(find.byType(PlayerScreen), findsNothing);

    await typePin(tester, h, '1234');
    expect(find.byType(PlayerScreen), findsOneWidget);

    // Unlocked for the re-lock window: other locked content opens directly.
    await h.go(tester, '/settings/parental');
    expect(find.byType(ParentalScreen), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbix/core/design/design.dart';
import 'package:orbix/shared/widgets/widgets.dart';

import '../../support/harness.dart';

void main() {
  group('OxButton', () {
    testWidgets('taps, and activates from the keyboard when focused', (tester) async {
      var taps = 0;
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await pumpOx(tester, OxButton(label: 'Play', icon: OxIcons.play, focusNode: focus, onPressed: () => taps++));

      await tester.tap(find.text('Play'));
      expect(taps, 1);

      focus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(taps, 2);
    });

    testWidgets('disabled is 40% opacity and not tappable', (tester) async {
      await pumpOx(tester, const OxButton(label: 'Disabled', onPressed: null));
      final opacity = tester.widget<Opacity>(find.ancestor(of: find.text('Disabled'), matching: find.byType(Opacity)).first);
      expect(opacity.opacity, 0.4);
      expect(tester.getSemantics(find.byType(OxButton)), isSemantics(isButton: true, hasEnabledState: true, isEnabled: false));
    });

    testWidgets('sizes match the spec', (tester) async {
      await pumpOx(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OxButton(key: const Key('sm'), label: 'S', size: OxButtonSize.sm, onPressed: () {}),
            OxButton(key: const Key('md'), label: 'M', onPressed: () {}),
            OxButton(key: const Key('lg'), label: 'L', size: OxButtonSize.lg, onPressed: () {}),
          ],
        ),
      );
      expect(tester.getSize(find.byKey(const Key('sm'))).height, 38);
      expect(tester.getSize(find.byKey(const Key('md'))).height, 50);
      expect(tester.getSize(find.byKey(const Key('lg'))).height, 56);
    });

    testWidgets('press scale is skipped under reduced motion', (tester) async {
      await pumpOx(tester, OxButton(label: 'X', onPressed: () {}), reduceMotion: true);
      expect(find.descendant(of: find.byType(OxButton), matching: find.byType(AnimatedScale)), findsNothing);
    });
  });

  testWidgets('icon buttons keep a 44 dp target', (tester) async {
    await pumpOx(tester, OxIconButton(icon: OxIcons.search, semanticLabel: 'Search', onPressed: () {}));
    expect(tester.getSize(find.byType(OxIconButton)), const Size(44, 44));
    expect(find.bySemanticsLabel('Search'), findsOneWidget);
  });

  group('OxSwitch', () {
    testWidgets('toggles and mirrors the knob in RTL', (tester) async {
      var value = false;
      Widget build() => StatefulBuilder(
            builder: (context, set) => OxSwitch(value: value, onChanged: (v) => set(() => value = v), semanticLabel: 'Hw'),
          );

      await pumpOx(tester, build());
      final offX = tester.getCenter(find.byType(AnimatedAlign).last).dx;
      await tester.tap(find.byType(OxSwitch));
      await tester.pumpAndSettle();
      expect(value, isTrue);
      final knob = find.descendant(of: find.byType(AnimatedAlign), matching: find.byType(AnimatedContainer));
      final onX = tester.getCenter(knob).dx;

      await pumpOx(tester, build(), locale: const Locale('ar'));
      await tester.pumpAndSettle();
      final onXRtl = tester.getCenter(knob).dx;
      expect(onXRtl, lessThan(onX), reason: 'on = inline end = left in RTL');
      expect(offX, isNotNull);
    });
  });

  testWidgets('progress fills from the right in RTL', (tester) async {
    Future<Rect> fill(Locale l) async {
      await pumpOx(tester, const SizedBox(width: 200, child: OxProgressBar(value: 0.25)), locale: l);
      await tester.pumpAndSettle();
      return tester.getRect(find.descendant(of: find.byType(OxProgressBar), matching: find.byType(DecoratedBox)).last);
    }

    final ltr = await fill(const Locale('en'));
    final rtl = await fill(const Locale('ar'));
    final track = tester.getRect(find.byType(OxProgressBar));
    expect(ltr.left, track.left);
    expect(rtl.right, track.right);
    expect(ltr.width, closeTo(50, 0.01));
  });

  group('OxChannelLogo', () {
    test('initials follow the spec', () {
      expect(OxChannelLogo.initialsOf('Pulse Sports 1'), 'P1');
      expect(OxChannelLogo.initialsOf('Meridian News'), 'MN');
      expect(OxChannelLogo.initialsOf('Cine Prime HD'), 'CP');
      expect(OxChannelLogo.initialsOf('Kitezoo'), 'KI');
      expect(OxChannelLogo.initialsOf('بلس الرياضية 1'), 'ب1');
      expect(OxChannelLogo.initialsOf('  '), '');
    });

    test('gradient is stable per name', () {
      expect(OxChannelLogo.gradientFor('Atlas Docs'), same(OxChannelLogo.gradientFor('Atlas Docs')));
    });
  });

  test('quality badge tone', () {
    expect(OxBadge.quality('4K').tone, OxBadgeTone.uhd);
    expect(OxBadge.quality('UHD HDR').tone, OxBadgeTone.uhd);
    expect(OxBadge.quality('FHD').tone, OxBadgeTone.hd);
    expect(OxBadge.quality('SD').tone, OxBadgeTone.hd);
  });

  testWidgets('badges translate LIVE/NEW but keep technical labels', (tester) async {
    await pumpOx(
      tester,
      Builder(builder: (c) => Row(mainAxisSize: MainAxisSize.min, children: [OxBadge.live(c), OxBadge.fresh(c), OxBadge.quality('4K')])),
      locale: const Locale('ar'),
    );
    expect(find.text('مباشر'), findsOneWidget);
    expect(find.text('جديد'), findsOneWidget);
    expect(find.text('4K'), findsOneWidget);
  });

  testWidgets('channel row: semantics, favourite tap, 66 dp', (tester) async {
    var fav = 0;
    await pumpOx(
      tester,
      OxChannelRow(
        number: '102',
        name: 'Pulse Sports 1',
        quality: 'FHD',
        programme: 'Coastal FC vs Northern United',
        progress: 0.12,
        nowPlaying: true,
        onTap: () {},
        onFavoriteTap: () => fav++,
      ),
    );
    expect(tester.getSize(find.byType(OxChannelRow)).height, 66);
    expect(find.bySemanticsLabel(RegExp('102, Pulse Sports 1, Coastal FC.*Now playing')), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Add to favorites'));
    expect(fav, 1);
  });

  testWidgets('rail scrolls instead of overflowing on a phone in landscape', (tester) async {
    await pumpOx(
      tester,
      OxNavRail(
        items: [for (final i in [OxIcons.home, OxIcons.live, OxIcons.epg, OxIcons.film, OxIcons.series, OxIcons.heart]) OxNavItem(icon: i, label: i.id)],
        footer: const [OxNavItem(icon: OxIcons.settings, label: 'settings')],
        currentIndex: 6,
        onTap: (_) {},
      ),
      size: const Size(915, 412),
      scaffold: false,
    );
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(find.text('settings'), 100, scrollable: find.byType(Scrollable));
    expect(find.text('settings'), findsOneWidget);
  });

  group('OxBottomNav', () {
    final items = [
      for (final i in [OxIcons.home, OxIcons.live, OxIcons.film]) OxNavItem(icon: i, label: i.id),
    ];

    testWidgets('taps report the index', (tester) async {
      var index = 0;
      await pumpOx(tester, OxBottomNav(items: items, currentIndex: 0, onTap: (i) => index = i));
      await tester.tap(find.text('film'));
      expect(index, 2);
    });

    testWidgets('compact shows only the active label', (tester) async {
      await pumpOx(tester, OxBottomNav(items: items, currentIndex: 1, onTap: (_) {}, compact: true));
      expect(find.text('live'), findsOneWidget);
      expect(find.text('home'), findsNothing);
      expect(tester.getSize(find.byType(OxBottomNav)).height, 62);
    });

    testWidgets('auto-compact below 380 dp', (tester) async {
      await pumpOx(tester, OxBottomNav(items: items, currentIndex: 0, onTap: (_) {}), size: const Size(360, 780));
      expect(find.text('live'), findsNothing);
    });
  });

  testWidgets('text field: error message and password toggle', (tester) async {
    await pumpOx(
      tester,
      const SizedBox(
        width: 300,
        child: OxTextField(label: 'Password', initialValue: 'secret', obscure: true, status: OxFieldStatus.error, message: 'Incorrect password'),
      ),
    );
    expect(find.text('Incorrect password'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).obscureText, isTrue);
    await tester.tap(find.bySemanticsLabel('Show password'));
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).obscureText, isFalse);
  });

  testWidgets('segmented and tabs report selection', (tester) async {
    String? seg;
    int? tab;
    await pumpOx(
      tester,
      SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OxSegmented<String>(
              segments: const [OxSegment('x', 'Xtream'), OxSegment('m', 'M3U')],
              selected: 'x',
              onChanged: (v) => seg = v,
            ),
            OxTabs(labels: const ['Channels', 'Movies'], index: 0, onChanged: (i) => tab = i),
          ],
        ),
      ),
    );
    await tester.tap(find.text('M3U'));
    await tester.tap(find.text('Movies'));
    expect(seg, 'm');
    expect(tab, 1);
  });

  testWidgets('snack shows above the chrome inset, replaces, and auto-dismisses after 4 s', (tester) async {
    await pumpOx(
      tester,
      OxChromeInsets(
        bottom: 100,
        child: Builder(
          builder: (c) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(onPressed: () => showOxSnack(c, message: 'First'), child: const Text('a')),
              TextButton(onPressed: () => showOxSnack(c, message: 'Second'), child: const Text('b')),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('a'));
    await tester.pumpAndSettle();
    expect(find.text('First'), findsOneWidget);
    expect(tester.getRect(find.byType(OxSnack)).bottom, closeTo(915 - 112, 0.5));

    await tester.tap(find.text('b'));
    await tester.pumpAndSettle();
    expect(find.text('First'), findsNothing);
    expect(find.text('Second'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('Second'), findsNothing);
  });

  testWidgets('sheet and dialog return values', (tester) async {
    int? picked;
    bool? confirmed;
    await pumpOx(
      tester,
      Builder(
        builder: (c) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () async => picked = await showOxSheet<int>(
                c,
                title: 'Sort channels',
                builder: (s) => OxSheetOption(label: 'Name A–Z', onTap: () => Navigator.pop(s, 1)),
              ),
              child: const Text('sheet'),
            ),
            TextButton(
              onPressed: () async => confirmed = await showOxDialog<bool>(
                c,
                builder: (d) => OxDialog(
                  title: 'Delete?',
                  actions: [OxButton(label: 'Delete', variant: OxButtonVariant.destructive, onPressed: () => Navigator.pop(d, true))],
                ),
              ),
              child: const Text('dialog'),
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('sheet'));
    await tester.pumpAndSettle();
    expect(find.text('Sort channels'), findsOneWidget);
    await tester.tap(find.text('Name A–Z'));
    await tester.pumpAndSettle();
    expect(picked, 1);

    await tester.tap(find.text('dialog'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(confirmed, isTrue);
  });

  testWidgets('favourite button toggles and pops', (tester) async {
    var on = false;
    await pumpOx(
      tester,
      StatefulBuilder(builder: (c, set) => OxFavoriteButton(value: on, onChanged: (v) => set(() => on = v))),
    );
    await tester.tap(find.bySemanticsLabel('Add to favorites'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(on, isTrue);
    expect(find.bySemanticsLabel('Remove from favorites'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('decorative loops stop under reduced motion; loaders keep spinning', (tester) async {
    await pumpOx(
      tester,
      const Row(mainAxisSize: MainAxisSize.min, children: [OxEqualizer(), OxLiveDot(), OxOrbitLoader(), OxSkeleton(width: 40, height: 40)]),
      reduceMotion: true,
    );
    // Only the orbit loader's ticker is alive, so the tree is not settled…
    await tester.pump(const Duration(seconds: 1));
    expect(tester.hasRunningAnimations, isTrue);

    await pumpOx(tester, const Row(mainAxisSize: MainAxisSize.min, children: [OxEqualizer(), OxLiveDot()]), reduceMotion: true);
    // …while the decorative loops alone settle immediately.
    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
  });
}

import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbix/core/design/icons/ox_icons.dart';

void main() {
  final cssIds = RegExp(r'^\.i-([a-z0-9-]+)\{', multiLine: true)
      .allMatches(File('orbix-design-handoff/design/orbix.css').readAsStringSync())
      .map((m) => m.group(1)!)
      .toList();

  test('icon set matches orbix.css one-to-one, in order', () {
    expect(cssIds, hasLength(78));
    expect(OxIcons.values.map((i) => i.id).toList(), cssIds);
  });

  test('every glyph decodes to a path inside the 24×24 grid', () {
    for (final icon in OxIcons.values) {
      expect(icon.ops, isNotEmpty, reason: icon.id);
      for (final op in icon.ops) {
        final b = op.uiPath.getBounds();
        expect(b.left >= -0.01 && b.top >= -0.01 && b.right <= 24.01 && b.bottom <= 24.01, isTrue,
            reason: '${icon.id} bounds $b');
      }
    }
  });

  test('only directional glyphs mirror in RTL; media glyphs never do', () {
    expect(
      OxIcons.values.where((i) => i.mirrorInRtl).map((i) => i.id).toSet(),
      {'back', 'backspace', 'chev-l', 'chev-r'},
    );
    for (final media in [OxIcons.play, OxIcons.pause, OxIcons.rew, OxIcons.fwd, OxIcons.prev, OxIcons.next, OxIcons.volume]) {
      expect(media.mirrorInRtl, isFalse, reason: media.id);
    }
  });

  test('rew/fwd carry the "10" label instead of SVG text', () {
    expect(OxIcons.rew.label?.text, '10');
    expect(OxIcons.fwd.label?.text, '10');
  });

  Future<void> pump(WidgetTester tester, OxIcons icon, TextDirection dir) => tester.pumpWidget(
        Directionality(textDirection: dir, child: Center(child: OxIcon(icon, size: 20))),
      );

  Finder flip() => find.byWidgetPredicate((w) => w is Transform && w.transform.storage[0] == -1);

  testWidgets('OxIcon mirrors back in RTL but not play', (tester) async {
    await pump(tester, OxIcons.back, TextDirection.rtl);
    expect(flip(), findsOneWidget);
    await pump(tester, OxIcons.back, TextDirection.ltr);
    expect(flip(), findsNothing);
    await pump(tester, OxIcons.play, TextDirection.rtl);
    expect(flip(), findsNothing);
    expect(tester.getSize(find.byType(CustomPaint).last), const Size(20, 20));
  });

  testWidgets('OxIcon follows IconTheme colour and size', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: IconTheme(
          data: IconThemeData(color: Color(0xFFFF7A3D), size: 36),
          child: Center(child: OxIcon(OxIcons.heart)),
        ),
      ),
    );
    expect(tester.getSize(find.byType(CustomPaint).last), const Size(36, 36));
  });
}

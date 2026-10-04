import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbix/features/dev/gallery_screen.dart';

import '../../support/harness.dart';

/// Renders the whole component gallery at every size class in both locales.
/// Any RenderFlex overflow or build error fails the test.
void main() {
  for (final (name, size) in [
    ('small phone', const Size(360, 6400)),
    ('phone', const Size(412, 6400)),
    ('foldable', const Size(884, 4200)),
    ('tablet', const Size(1280, 2600)),
  ]) {
    for (final locale in const [Locale('en'), Locale('ar')]) {
      testWidgets('gallery renders cleanly — $name, ${locale.languageCode}', (tester) async {
        await pumpOx(tester, const GalleryScreen(), size: size, locale: locale, scaffold: false);
        await tester.pump(const Duration(seconds: 1));
        expect(tester.takeException(), isNull);
        expect(find.text('Buttons'), findsOneWidget);
        expect(find.text('Snackbars'), findsOneWidget);
      });
    }
  }
}

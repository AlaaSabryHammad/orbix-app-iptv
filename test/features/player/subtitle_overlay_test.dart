import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbix/core/settings/app_settings.dart';
import 'package:orbix/features/player/widgets/player_chrome.dart';

void main() {
  Future<void> pump(WidgetTester tester, Size box, List<String> lines, {double bottom = 20}) => tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox.fromSize(size: box, child: SubtitleOverlay(lines: lines, size: SubtitleSize.medium, style: SubtitleStyle.outline, bottom: bottom)),
        ),
      ));

  testWidgets('subtitles sit at the bottom, above the given inset', (tester) async {
    await pump(tester, const Size(800, 400), ['Hello']);
    await tester.pumpAndSettle();
    expect(tester.getBottomLeft(find.text('Hello')).dy, closeTo(380, 2));
  });

  testWidgets('Arabic lines are right-to-left', (tester) async {
    await pump(tester, const Size(800, 400), ['مرحبا بكم']);
    expect(tester.widget<Text>(find.text('مرحبا بكم')).textDirection, TextDirection.rtl);
  });

  testWidgets('a tiny picture-in-picture window clips instead of overflowing', (tester) async {
    await pump(tester, const Size(220, 60), ['A long first line of dialogue here', 'and a second one below it'], bottom: 4);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbix/core/l10n/bidi.dart';

void main() {
  test('direction from the first strong character', () {
    expect(oxDirectionOf('Meridian News'), TextDirection.ltr);
    expect(oxDirectionOf('بلس الرياضية 1'), TextDirection.rtl);
    expect(oxDirectionOf('1 MBC'), TextDirection.ltr, reason: 'digits are neutral');
    expect(oxDirectionOf('٢ الجزيرة'), TextDirection.rtl);
    expect(oxDirectionOf('Ünal TV'), TextDirection.ltr);
    expect(oxDirectionOf('Первый канал'), TextDirection.ltr);
    expect(oxDirectionOf('20:30–22:30'), isNull);
    expect(oxDirectionOf(''), isNull);
  });

  testWidgets('content text: own direction, layout-start alignment', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.rtl,
        child: Column(children: [OxContentText('The Evening Bulletin'), OxContentText('النشرة المسائية')]),
      ),
    );
    final latin = tester.widget<Text>(find.text('The Evening Bulletin'));
    expect(latin.textDirection, TextDirection.ltr);
    expect(latin.textAlign, TextAlign.right, reason: 'aligned to the RTL layout start');
    expect(tester.widget<Text>(find.text('النشرة المسائية')).textDirection, TextDirection.rtl);
  });
}

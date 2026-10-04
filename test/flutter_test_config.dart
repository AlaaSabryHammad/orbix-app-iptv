import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbix/core/l10n/l10n.dart';

/// Loads the bundled Orbix fonts before every test file, so layout tests
/// measure real Unbounded / Manrope / Readex Pro text instead of the default
/// test font (every glyph a full-em square), which overstates widths and
/// would make overflow checks meaningless.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  configureDigits();
  const families = {
    'Unbounded': ['unbounded/Unbounded-400', 'unbounded/Unbounded-500', 'unbounded/Unbounded-600', 'unbounded/Unbounded-700'],
    'Manrope': ['manrope/Manrope-400', 'manrope/Manrope-500', 'manrope/Manrope-600', 'manrope/Manrope-700', 'manrope/Manrope-800'],
    'Readex Pro': [
      'readex_pro/ReadexPro-300',
      'readex_pro/ReadexPro-400',
      'readex_pro/ReadexPro-500',
      'readex_pro/ReadexPro-600',
      'readex_pro/ReadexPro-700',
    ],
  };
  for (final e in families.entries) {
    final loader = FontLoader(e.key);
    for (final f in e.value) {
      loader.addFont(rootBundle.load('assets/fonts/$f.ttf'));
    }
    await loader.load();
  }
  await testMain();
}

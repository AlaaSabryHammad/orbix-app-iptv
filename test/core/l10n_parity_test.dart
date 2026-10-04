import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:orbix/core/l10n/l10n.dart';
import 'package:orbix/shared/format/format.dart';

Map<String, Object?> _arb(String locale) =>
    (jsonDecode(File('lib/core/l10n/app_$locale.arb').readAsStringSync()) as Map<String, Object?>)..removeWhere((k, _) => k.startsWith('@'));

/// `{name}` placeholders of an ARB message (not ICU branch bodies like `=0{…}`).
Set<String> _placeholders(String message) => RegExp(r'(?<!(?:=\d+|zero|one|two|few|many|other))\{(\w+)[},]').allMatches(message).map((m) => m.group(1)!).toSet();

void main() {
  test('every English string has an Arabic translation with the same placeholders', () {
    final en = _arb('en'), ar = _arb('ar');
    expect(ar.keys.toSet().difference(en.keys.toSet()), isEmpty, reason: 'Arabic keys missing from English');
    final missing = en.keys.where((k) => !ar.containsKey(k)).toList();
    expect(missing, isEmpty, reason: 'untranslated: $missing');
    for (final k in en.keys) {
      expect(_placeholders(ar[k]! as String), _placeholders(en[k]! as String), reason: k);
    }
  });

  test('messages with several placeholders declare them (fixes the Dart parameter order)', () {
    // Without "@key": {"placeholders": …} gen-l10n orders parameters
    // alphabetically — episodeShort(season, episode) silently became
    // episodeShort(episode, season).
    final raw = jsonDecode(File('lib/core/l10n/app_en.arb').readAsStringSync()) as Map<String, Object?>;
    for (final MapEntry(:key, :value) in _arb('en').entries) {
      if (_placeholders(value! as String).length < 2) continue;
      expect(raw['@$key'], isA<Map<String, Object?>>().having((m) => m['placeholders'], 'placeholders', isNotNull), reason: key);
    }
  });

  group('Arabic formatting', () {
    late AppLocalizations ar, en;
    setUpAll(() async {
      await initializeDateFormatting('en');
      ar = await AppLocalizations.delegate.load(const Locale('ar'));
      en = await AppLocalizations.delegate.load(const Locale('en'));
    });

    test('runtimes and time left follow the AR reference («2 س 6 د», «متبقٍ 18 دقيقة»)', () {
      expect(Fmt.runtime(ar, const Duration(hours: 2, minutes: 6)), '2 س 6 د');
      expect(Fmt.left(ar, const Duration(minutes: 18)), 'متبقٍ 18 دقيقة');
      expect(Fmt.left(ar, const Duration(hours: 1, minutes: 5)), 'متبقٍ 1 س 5 د');
      expect(Fmt.runtime(en, const Duration(hours: 1, minutes: 5)), '1h 05m');
      expect(Fmt.left(en, const Duration(minutes: 18)), '18 min left');
    });

    test('time ranges are isolated left-to-right so they never read backwards', () {
      final r = Fmt.range(DateTime(2026, 1, 1, 20, 30), DateTime(2026, 1, 1, 22, 30));
      expect(r, '\u206620:30–22:30\u2069');
      expect(ar.nowAt(r), contains('20:30–22:30'));
    });

    test('season / episode short form', () {
      expect(ar.episodeShort(3, 4), 'م3 · ح4');
      expect(en.episodeShort(3, 4), 'S3 · E4');
    });
  });
}

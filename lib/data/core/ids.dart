import 'dart:math';

final _random = Random.secure();

/// A random 128-bit id (hex) for locally created records (accounts).
String newId() => List.generate(16, (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();

/// Deterministic 64-bit FNV-1a hash (hex) — stable ids for playlist entries
/// that carry no provider id, so favorites and progress survive a re-import.
String stableId(String input) {
  var h = 0xcbf29ce484222325;
  for (final unit in input.codeUnits) {
    h ^= unit;
    h = (h * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
  }
  return h.toUnsigned(64).toRadixString(16).padLeft(16, '0');
}

final _adult = RegExp(r'adult|xxx|porn|\b18\s*\+|\+\s*18\b|for adults|للكبار|إباحي', caseSensitive: false);

/// Heuristic for "Hide 18+ titles and categories everywhere" (Parental).
bool looksAdult(String categoryName) => _adult.hasMatch(categoryName);

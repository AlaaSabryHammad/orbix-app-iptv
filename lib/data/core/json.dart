/// Lenient readers for provider JSON.
///
/// Xtream panels are inconsistent across vendors and versions: numbers arrive
/// as strings ("123", "7.5"), nulls as "" or "null", lists as maps keyed by
/// index, booleans as 0/1/"1". These helpers never throw.
library;

String? jStr(Object? v) {
  if (v == null) return null;
  final s = (v is String ? v : v.toString()).trim();
  return s.isEmpty || s == 'null' ? null : s;
}

int? jInt(Object? v) {
  if (v is int) return v;
  if (v is num) return v.isFinite ? v.toInt() : null;
  if (v is String) {
    final s = v.trim();
    return int.tryParse(s) ?? double.tryParse(s)?.toInt();
  }
  return null;
}

double? jDouble(Object? v) {
  if (v is num) return v.isFinite ? v.toDouble() : null;
  if (v is String) return double.tryParse(v.trim().replaceAll(',', '.'));
  return null;
}

bool jBool(Object? v) => v == true || v == 1 || v == '1' || (v is String && v.toLowerCase() == 'true');

/// Unix seconds → UTC; null for missing / zero / negative.
DateTime? jEpoch(Object? v) {
  final s = jInt(v);
  return s == null || s <= 0 ? null : DateTime.fromMillisecondsSinceEpoch(s * 1000, isUtc: true);
}

List<Object?> jList(Object? v) => switch (v) {
      final List<Object?> l => l,
      final Map<Object?, Object?> m => m.values.toList(),
      _ => const [],
    };

Map<String, Object?> jMap(Object? v) => v is Map ? v.map((k, val) => MapEntry('$k', val)) : const {};

/// First non-empty string of a list-or-string field (`backdrop_path`).
String? jFirstStr(Object? v) => v is List ? v.map(jStr).whereType<String>().firstOrNull : jStr(v);

/// A 4-digit year from "2026", "2026-03-14" or "14/03/2026".
int? jYear(Object? v) {
  final s = jStr(v);
  if (s == null) return null;
  final m = RegExp(r'(19|20)\d\d').firstMatch(s);
  return m == null ? null : int.parse(m.group(0)!);
}

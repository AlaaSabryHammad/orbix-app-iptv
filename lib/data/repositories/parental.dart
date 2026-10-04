import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../credentials/credential_store.dart';
import '../db/database.dart';

/// The parental PIN: stored only as a salted SHA-256 in secure storage, plus
/// an in-memory unlock window that expires after the "Re-lock after" time.
class ParentalService {
  ParentalService(this._store, this._relockMinutes, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final SecretStore _store;
  final int Function() _relockMinutes;
  final DateTime Function() _clock;
  DateTime? _unlockedUntil;

  static const _key = 'parental.pin';

  Future<bool> hasPin() async => await _store.read(_key) != null;

  Future<void> setPin(String pin) async {
    final salt = base64.encode(List.generate(16, (_) => Random.secure().nextInt(256)));
    await _store.write(_key, jsonEncode({'salt': salt, 'hash': _hash(pin, salt), 'set': _clock().toIso8601String()}));
    unlock();
  }

  Future<void> removePin() async {
    await _store.delete(_key);
    _unlockedUntil = null;
  }

  /// When the PIN was set ("4-digit PIN · set 12 Sep").
  Future<DateTime?> pinSetAt() async {
    final raw = await _store.read(_key);
    return raw == null ? null : DateTime.tryParse((jsonDecode(raw) as Map)['set'] as String? ?? '');
  }

  /// Checks [pin]; on success opens the unlock window.
  Future<bool> verify(String pin) async {
    final raw = await _store.read(_key);
    if (raw == null) return true;
    final m = (jsonDecode(raw) as Map).cast<String, Object?>();
    final ok = _hash(pin, m['salt']! as String) == m['hash'];
    if (ok) unlock();
    return ok;
  }

  bool get isUnlocked => _unlockedUntil != null && _clock().isBefore(_unlockedUntil!);

  void unlock() => _unlockedUntil = _clock().add(Duration(minutes: _relockMinutes()));

  void lock() => _unlockedUntil = null;

  static String _hash(String pin, String salt) => sha256.convert(utf8.encode('$salt:$pin')).toString();
}

/// Locked categories and channels per account.
class LockRepository {
  LockRepository(this._db);

  final OrbixDatabase _db;

  Stream<Set<(LockKind, String)>> watchLocks(String accountId) =>
      (_db.select(_db.contentLocks)..where((l) => l.accountId.equals(accountId))).watch().map((rows) => {for (final r in rows) (r.kind, r.itemId)});

  Future<void> setLocked(String accountId, LockKind kind, String itemId, bool locked) => locked
      ? _db.into(_db.contentLocks).insert(ContentLocksCompanion.insert(accountId: accountId, kind: kind, itemId: itemId), mode: InsertMode.insertOrIgnore)
      : (_db.delete(_db.contentLocks)..where((l) => l.accountId.equals(accountId) & l.kind.equalsValue(kind) & l.itemId.equals(itemId))).go();
}

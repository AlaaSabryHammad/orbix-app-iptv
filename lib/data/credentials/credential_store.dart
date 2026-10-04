import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'credentials.dart';

/// Minimal secret key-value storage — the seam that lets tests run without
/// the platform plugin.
abstract interface class SecretStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// Android Keystore-backed storage (flutter_secure_storage).
class SecureSecretStore implements SecretStore {
  SecureSecretStore([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// In-memory store for tests.
class MemorySecretStore implements SecretStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

/// Encrypted per-account credentials ("stored encrypted on this device").
class CredentialStore {
  CredentialStore(this._store);

  final SecretStore _store;
  final _cache = <String, AccountCredentials>{};

  static String _key(String accountId) => 'account.$accountId.credentials';

  Future<void> save(String accountId, AccountCredentials credentials) async {
    await _store.write(_key(accountId), credentials.encode());
    _cache[accountId] = credentials;
  }

  /// Null when missing — e.g. after the user cleared app data or the
  /// Keystore key was invalidated; the UI then asks to sign in again.
  Future<AccountCredentials?> load(String accountId) async {
    final cached = _cache[accountId];
    if (cached != null) return cached;
    final raw = await _store.read(_key(accountId));
    if (raw == null) return null;
    try {
      return _cache[accountId] = AccountCredentials.decode(raw);
    } on FormatException {
      return null;
    }
  }

  Future<void> delete(String accountId) async {
    _cache.remove(accountId);
    await _store.delete(_key(accountId));
  }
}

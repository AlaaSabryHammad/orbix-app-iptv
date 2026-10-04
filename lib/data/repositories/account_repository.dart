import 'dart:io';

import 'package:drift/drift.dart';

import '../core/ids.dart';
import '../credentials/credential_store.dart';
import '../credentials/credentials.dart';
import '../db/database.dart';
import '../sources/xtream/xtream_client.dart';

/// Saved accounts (Profiles screen) and their encrypted credentials.
class AccountRepository {
  AccountRepository(this._db, this._credentials);

  final OrbixDatabase _db;
  final CredentialStore _credentials;

  Stream<List<Account>> watchAll() => (_db.select(_db.accounts)
        ..orderBy([(a) => OrderingTerm.asc(a.sortOrder), (a) => OrderingTerm.asc(a.createdAt)]))
      .watch();

  Future<List<Account>> all() => (_db.select(_db.accounts)..orderBy([(a) => OrderingTerm.asc(a.sortOrder)])).get();

  Stream<Account?> watch(String id) => (_db.select(_db.accounts)..where((a) => a.id.equals(id))).watchSingleOrNull();

  Future<Account?> byId(String id) => (_db.select(_db.accounts)..where((a) => a.id.equals(id))).getSingleOrNull();

  /// "Open default account on launch".
  Future<Account?> defaultAccount() => (_db.select(_db.accounts)..where((a) => a.isDefault.equals(true))).getSingleOrNull();

  /// Most recently used — "Continue with Living Room".
  Future<Account?> lastUsed() => (_db.select(_db.accounts)
        ..orderBy([(a) => OrderingTerm(expression: a.lastUsedAt, mode: OrderingMode.desc, nulls: NullsOrder.last)])
        ..limit(1))
      .getSingleOrNull();

  Future<AccountCredentials?> credentials(String accountId) => _credentials.load(accountId);

  /// Saves a new account. The first account becomes the default.
  Future<Account> create({
    required String name,
    required AccountKind kind,
    required AccountCredentials credentials,
    XtreamAccountInfo? info,
    DateTime? now,
  }) async {
    final id = newId();
    final at = now ?? DateTime.now();
    await _credentials.save(id, credentials);
    try {
      await _db.transaction(() async {
        final count = await _db.accounts.count().getSingle();
        await _db.into(_db.accounts).insert(AccountsCompanion.insert(
          id: id,
          name: name.trim(),
          kind: kind,
          displayHost: Value(_displayHost(credentials)),
          status: Value(info == null ? AccountStatus.unknown : _status(info)),
          expiresAt: Value(info?.expiresAt),
          maxConnections: Value(info?.maxConnections),
          isDefault: Value(count == 0),
          sortOrder: Value(count),
          createdAt: at,
          lastUsedAt: Value(at),
        ));
      });
    } catch (_) {
      await _credentials.delete(id);
      rethrow;
    }
    return (await byId(id))!;
  }

  Future<void> rename(String id, String name) =>
      (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(AccountsCompanion(name: Value(name.trim())));

  /// Edit account: new credentials (and display host).
  Future<void> updateCredentials(String id, AccountCredentials credentials) async {
    await _credentials.save(id, credentials);
    await (_db.update(_db.accounts)..where((a) => a.id.equals(id)))
        .write(AccountsCompanion(displayHost: Value(_displayHost(credentials))));
  }

  /// Records the provider's status after a sign-in ("Refresh status").
  Future<void> updateStatus(String id, XtreamAccountInfo info) => (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(
        AccountsCompanion(status: Value(_status(info)), expiresAt: Value(info.expiresAt), maxConnections: Value(info.maxConnections)),
      );

  Future<void> markStatus(String id, AccountStatus status, {DateTime? expiresAt}) => (_db.update(_db.accounts)..where((a) => a.id.equals(id)))
      .write(AccountsCompanion(status: Value(status), expiresAt: expiresAt == null ? const Value.absent() : Value(expiresAt)));

  Future<void> setDefault(String id) => _db.transaction(() async {
        await _db.update(_db.accounts).write(const AccountsCompanion(isDefault: Value(false)));
        await (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(const AccountsCompanion(isDefault: Value(true)));
      });

  Future<void> touch(String id, {DateTime? now}) => (_db.update(_db.accounts)..where((a) => a.id.equals(id)))
      .write(AccountsCompanion(lastUsedAt: Value(now ?? DateTime.now())));

  Future<void> setGuideShift(String id, int minutes) =>
      (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(AccountsCompanion(guideShiftMinutes: Value(minutes)));

  /// Deletes the account with everything it owns: catalog, favorites,
  /// progress, guide, locks (cascade), its credentials and any imported
  /// playlist file. If it was the default, the next account becomes default.
  Future<void> delete(String id) async {
    final creds = await _credentials.load(id);
    await _db.transaction(() async {
      final wasDefault = (await byId(id))?.isDefault ?? false;
      await (_db.delete(_db.accounts)..where((a) => a.id.equals(id))).go();
      if (wasDefault) {
        final next = await (_db.select(_db.accounts)
              ..orderBy([(a) => OrderingTerm.asc(a.sortOrder)])
              ..limit(1))
            .getSingleOrNull();
        if (next != null) {
          await (_db.update(_db.accounts)..where((a) => a.id.equals(next.id))).write(const AccountsCompanion(isDefault: Value(true)));
        }
      }
    });
    await _credentials.delete(id);
    if (creds is PlaylistCredentials && creds.filePath != null) {
      final f = File(creds.filePath!);
      if (await f.exists()) await f.delete();
    }
  }

  static String? _displayHost(AccountCredentials c) => switch (c) {
        XtreamCredentials() => c.displayHost,
        PlaylistCredentials() => c.displayHost,
      };

  static AccountStatus _status(XtreamAccountInfo info) => switch (info.status.toLowerCase()) {
        'active' => AccountStatus.active,
        'expired' => AccountStatus.expired,
        'banned' || 'disabled' => AccountStatus.disabled,
        _ => AccountStatus.unknown,
      };
}

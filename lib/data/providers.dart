import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'core/http.dart';
import 'credentials/credential_store.dart';
import 'db/database.dart';
import 'repositories/account_repository.dart';
import 'repositories/catalog_repository.dart';
import 'repositories/connection_tester.dart';
import 'repositories/epg_repository.dart';
import 'repositories/library_repository.dart';
import 'repositories/parental.dart';
import 'repositories/storage_repository.dart';

part 'providers.g.dart';

/// Shared HTTP client for provider APIs, playlists and guides.
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final dio = createDio();
  ref.onDispose(dio.close);
  return dio;
}

/// Keystore-backed secret storage. Overridden with [MemorySecretStore] in tests.
@Riverpod(keepAlive: true)
SecretStore secretStore(Ref ref) => SecureSecretStore();

@Riverpod(keepAlive: true)
CredentialStore credentialStore(Ref ref) => CredentialStore(ref.watch(secretStoreProvider));

/// The app database. Overridden with an in-memory database in tests.
@Riverpod(keepAlive: true)
OrbixDatabase database(Ref ref) {
  final db = OrbixDatabase();
  ref.onDispose(db.close);
  return db;
}

@Riverpod(keepAlive: true)
AccountRepository accountRepository(Ref ref) => AccountRepository(ref.watch(databaseProvider), ref.watch(credentialStoreProvider));

@Riverpod(keepAlive: true)
CatalogRepository catalogRepository(Ref ref) =>
    CatalogRepository(ref.watch(databaseProvider), ref.watch(dioProvider), ref.watch(credentialStoreProvider));

@Riverpod(keepAlive: true)
LibraryRepository libraryRepository(Ref ref) => LibraryRepository(ref.watch(databaseProvider));

@Riverpod(keepAlive: true)
EpgRepository epgRepository(Ref ref) => EpgRepository(ref.watch(databaseProvider), ref.watch(dioProvider), ref.watch(credentialStoreProvider));

@Riverpod(keepAlive: true)
LockRepository lockRepository(Ref ref) => LockRepository(ref.watch(databaseProvider));

@Riverpod(keepAlive: true)
ConnectionTester connectionTester(Ref ref) => ConnectionTester(ref.watch(dioProvider));

/// All saved accounts (Profiles).
///
/// Hand-written: riverpod_generator runs before drift_dev, so it cannot see
/// drift-generated row types like [Account] in a provider's signature.
final accountsProvider = StreamProvider<List<Account>>((ref) => ref.watch(accountRepositoryProvider).watchAll());

/// Settings › Storage.
final storageRepositoryProvider = Provider<StorageRepository>((ref) => StorageRepository(ref.watch(databaseProvider)));

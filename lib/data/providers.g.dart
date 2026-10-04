// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Shared HTTP client for provider APIs, playlists and guides.

@ProviderFor(dio)
final dioProvider = DioProvider._();

/// Shared HTTP client for provider APIs, playlists and guides.

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Shared HTTP client for provider APIs, playlists and guides.
  DioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'74742dc027ca33c5a4af0ef6bc02ee65c54a2234';

/// Keystore-backed secret storage. Overridden with [MemorySecretStore] in tests.

@ProviderFor(secretStore)
final secretStoreProvider = SecretStoreProvider._();

/// Keystore-backed secret storage. Overridden with [MemorySecretStore] in tests.

final class SecretStoreProvider
    extends $FunctionalProvider<SecretStore, SecretStore, SecretStore>
    with $Provider<SecretStore> {
  /// Keystore-backed secret storage. Overridden with [MemorySecretStore] in tests.
  SecretStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secretStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secretStoreHash();

  @$internal
  @override
  $ProviderElement<SecretStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SecretStore create(Ref ref) {
    return secretStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SecretStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SecretStore>(value),
    );
  }
}

String _$secretStoreHash() => r'27bd0832caf2fb0780f2a77d20ec76a650137fba';

@ProviderFor(credentialStore)
final credentialStoreProvider = CredentialStoreProvider._();

final class CredentialStoreProvider
    extends
        $FunctionalProvider<CredentialStore, CredentialStore, CredentialStore>
    with $Provider<CredentialStore> {
  CredentialStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'credentialStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$credentialStoreHash();

  @$internal
  @override
  $ProviderElement<CredentialStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CredentialStore create(Ref ref) {
    return credentialStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CredentialStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CredentialStore>(value),
    );
  }
}

String _$credentialStoreHash() => r'ed5f2241fcb6f82f9d2d25a3fe949dc934994bbe';

/// The app database. Overridden with an in-memory database in tests.

@ProviderFor(database)
final databaseProvider = DatabaseProvider._();

/// The app database. Overridden with an in-memory database in tests.

final class DatabaseProvider
    extends $FunctionalProvider<OrbixDatabase, OrbixDatabase, OrbixDatabase>
    with $Provider<OrbixDatabase> {
  /// The app database. Overridden with an in-memory database in tests.
  DatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databaseHash();

  @$internal
  @override
  $ProviderElement<OrbixDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OrbixDatabase create(Ref ref) {
    return database(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrbixDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrbixDatabase>(value),
    );
  }
}

String _$databaseHash() => r'b09471815478dc4fdf1500b6953560efa21d1e7d';

@ProviderFor(accountRepository)
final accountRepositoryProvider = AccountRepositoryProvider._();

final class AccountRepositoryProvider
    extends
        $FunctionalProvider<
          AccountRepository,
          AccountRepository,
          AccountRepository
        >
    with $Provider<AccountRepository> {
  AccountRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountRepositoryHash();

  @$internal
  @override
  $ProviderElement<AccountRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AccountRepository create(Ref ref) {
    return accountRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountRepository>(value),
    );
  }
}

String _$accountRepositoryHash() => r'10ef5c268fea5a4ab329c13bc5ff30a709019368';

@ProviderFor(catalogRepository)
final catalogRepositoryProvider = CatalogRepositoryProvider._();

final class CatalogRepositoryProvider
    extends
        $FunctionalProvider<
          CatalogRepository,
          CatalogRepository,
          CatalogRepository
        >
    with $Provider<CatalogRepository> {
  CatalogRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogRepositoryHash();

  @$internal
  @override
  $ProviderElement<CatalogRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CatalogRepository create(Ref ref) {
    return catalogRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CatalogRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CatalogRepository>(value),
    );
  }
}

String _$catalogRepositoryHash() => r'9005a59bdf976edda2f12788e3ec6b79a6bab566';

@ProviderFor(libraryRepository)
final libraryRepositoryProvider = LibraryRepositoryProvider._();

final class LibraryRepositoryProvider
    extends
        $FunctionalProvider<
          LibraryRepository,
          LibraryRepository,
          LibraryRepository
        >
    with $Provider<LibraryRepository> {
  LibraryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryRepositoryHash();

  @$internal
  @override
  $ProviderElement<LibraryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LibraryRepository create(Ref ref) {
    return libraryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LibraryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LibraryRepository>(value),
    );
  }
}

String _$libraryRepositoryHash() => r'1ddd7179f010043cb595e3c5042192266b044fe1';

@ProviderFor(epgRepository)
final epgRepositoryProvider = EpgRepositoryProvider._();

final class EpgRepositoryProvider
    extends $FunctionalProvider<EpgRepository, EpgRepository, EpgRepository>
    with $Provider<EpgRepository> {
  EpgRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'epgRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$epgRepositoryHash();

  @$internal
  @override
  $ProviderElement<EpgRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EpgRepository create(Ref ref) {
    return epgRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EpgRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EpgRepository>(value),
    );
  }
}

String _$epgRepositoryHash() => r'49b6b52954f6a6d4e360c339886a661b162baa6c';

@ProviderFor(lockRepository)
final lockRepositoryProvider = LockRepositoryProvider._();

final class LockRepositoryProvider
    extends $FunctionalProvider<LockRepository, LockRepository, LockRepository>
    with $Provider<LockRepository> {
  LockRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lockRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lockRepositoryHash();

  @$internal
  @override
  $ProviderElement<LockRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LockRepository create(Ref ref) {
    return lockRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LockRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LockRepository>(value),
    );
  }
}

String _$lockRepositoryHash() => r'c9fc0fb1a5be212424571aa7bc40da44ce3a4081';

@ProviderFor(connectionTester)
final connectionTesterProvider = ConnectionTesterProvider._();

final class ConnectionTesterProvider
    extends
        $FunctionalProvider<
          ConnectionTester,
          ConnectionTester,
          ConnectionTester
        >
    with $Provider<ConnectionTester> {
  ConnectionTesterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectionTesterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectionTesterHash();

  @$internal
  @override
  $ProviderElement<ConnectionTester> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ConnectionTester create(Ref ref) {
    return connectionTester(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectionTester value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectionTester>(value),
    );
  }
}

String _$connectionTesterHash() => r'd1835d5ccdfedead5ae1c0db42bd86626d6f59d0';

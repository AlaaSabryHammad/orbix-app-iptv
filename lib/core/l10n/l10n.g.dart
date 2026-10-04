// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'l10n.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The user's language choice (Settings › Language), persisted in
/// [AppSettings]. Null = follow the system locale.

@ProviderFor(AppLocale)
final appLocaleProvider = AppLocaleProvider._();

/// The user's language choice (Settings › Language), persisted in
/// [AppSettings]. Null = follow the system locale.
final class AppLocaleProvider extends $NotifierProvider<AppLocale, Locale?> {
  /// The user's language choice (Settings › Language), persisted in
  /// [AppSettings]. Null = follow the system locale.
  AppLocaleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLocaleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLocaleHash();

  @$internal
  @override
  AppLocale create() => AppLocale();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale?>(value),
    );
  }
}

String _$appLocaleHash() => r'23e0a16aafbc93b25b99aa40e4f1e9637ad9e797';

/// The user's language choice (Settings › Language), persisted in
/// [AppSettings]. Null = follow the system locale.

abstract class _$AppLocale extends $Notifier<Locale?> {
  Locale? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Locale?, Locale?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Locale?, Locale?>,
              Locale?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

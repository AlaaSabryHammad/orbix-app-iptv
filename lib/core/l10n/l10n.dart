import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../settings/app_settings.dart';
import 'gen/app_localizations.dart';

export 'bidi.dart';
export 'gen/app_localizations.dart';

part 'l10n.g.dart';

/// Western digits in every language (spec: times, channel numbers, dates).
/// `intl` would otherwise write Arabic dates with Eastern Arabic digits.
void configureDigits() {
  for (final l in const ['ar', 'ar_SA', 'ar_EG']) {
    DateFormat.useNativeDigitsByDefaultFor(l, false);
  }
}

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// The user's language choice (Settings › Language), persisted in
/// [AppSettings]. Null = follow the system locale.
@Riverpod(keepAlive: true)
class AppLocale extends _$AppLocale {
  @override
  Locale? build() {
    final code = ref.watch(appSettingsProvider.select((AppSettings s) => s.localeCode));
    return code == null ? null : Locale(code);
  }

  void set(Locale? locale) => ref.read(appSettingsProvider.notifier).update((AppSettings s) => s.copyWith(localeCode: () => locale?.languageCode));
}

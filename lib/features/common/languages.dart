import '../../core/l10n/l10n.dart';

/// Language codes offered for audio preference, in menu order.
const audioLanguageCodes = ['ar', 'en', 'fr', 'es', 'de', 'tr'];

/// The language's name in the UI language ("Arabic").
String languageName(AppLocalizations l, String code) => switch (code) {
      'ar' => l.langArabic,
      'en' => l.langEnglish,
      'fr' => l.langFrench,
      'es' => l.langSpanish,
      'de' => l.langGerman,
      'tr' => l.langTurkish,
      _ => code,
    };

/// The language's own name ("العربية") — subtitle chips, like the design.
String languageEndonym(String code) => switch (code) {
      'ar' => 'العربية',
      'en' => 'English',
      'fr' => 'Français',
      'es' => 'Español',
      'de' => 'Deutsch',
      'tr' => 'Türkçe',
      _ => code,
    };

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum StartScreen { home, live, movies, series, favorites }

enum PlayerTheme { dark, amoled, system }

enum SubtitleSize { small, medium, large }

enum SubtitleStyle { outline, shadow, box }

/// User preferences (Settings screen) and launch state. Not secret — PINs and
/// credentials live in secure storage.
@immutable
class AppSettings {
  const AppSettings({
    this.onboardingDone = false,
    this.activeAccountId,
    this.openDefaultOnLaunch = true,
    this.localeCode,
    this.startScreen = StartScreen.home,
    this.autoplayNext = true,
    this.hardwareDecoding = true,
    this.audioLanguages = const ['ar', 'en'],
    this.defaultQuality = 'auto',
    this.subtitleSize = SubtitleSize.medium,
    this.subtitleStyle = SubtitleStyle.outline,
    this.subtitleLanguage,
    this.theme = PlayerTheme.dark,
    this.epgRefreshHours = 12,
    this.autoUpdatePlaylist = true,
    this.adultFilter = true,
    this.relockMinutes = 5,
    this.recentSearches = const [],
    this.temporaryAccountIds = const [],
  });

  /// Onboarding finished (or skipped) once.
  final bool onboardingDone;

  /// The account currently in use.
  final String? activeAccountId;

  /// Profiles › "Open default account on launch — skip this screen next time".
  final bool openDefaultOnLaunch;

  /// Null = follow the system language.
  final String? localeCode;
  final StartScreen startScreen;
  final bool autoplayNext;
  final bool hardwareDecoding;

  /// Preferred audio languages in order ("Arabic, then English").
  final List<String> audioLanguages;
  final String defaultQuality;
  final SubtitleSize subtitleSize;
  final SubtitleStyle subtitleStyle;

  /// Last subtitle language picked in the player (null = off).
  final String? subtitleLanguage;
  final PlayerTheme theme;
  final int epgRefreshHours;

  /// "On launch, at most once a day".
  final bool autoUpdatePlaylist;

  /// Parental › hide 18+ titles and categories everywhere.
  final bool adultFilter;

  /// Parental › re-lock after.
  final int relockMinutes;

  /// Search history (newest first, max 10).
  final List<String> recentSearches;

  /// Accounts added with "Save as profile" off — removed on next launch.
  final List<String> temporaryAccountIds;

  AppSettings copyWith({
    bool? onboardingDone,
    String? Function()? activeAccountId,
    bool? openDefaultOnLaunch,
    String? Function()? localeCode,
    StartScreen? startScreen,
    bool? autoplayNext,
    bool? hardwareDecoding,
    List<String>? audioLanguages,
    String? defaultQuality,
    SubtitleSize? subtitleSize,
    SubtitleStyle? subtitleStyle,
    String? Function()? subtitleLanguage,
    PlayerTheme? theme,
    int? epgRefreshHours,
    bool? autoUpdatePlaylist,
    bool? adultFilter,
    int? relockMinutes,
    List<String>? recentSearches,
    List<String>? temporaryAccountIds,
  }) =>
      AppSettings(
        onboardingDone: onboardingDone ?? this.onboardingDone,
        activeAccountId: activeAccountId == null ? this.activeAccountId : activeAccountId(),
        openDefaultOnLaunch: openDefaultOnLaunch ?? this.openDefaultOnLaunch,
        localeCode: localeCode == null ? this.localeCode : localeCode(),
        startScreen: startScreen ?? this.startScreen,
        autoplayNext: autoplayNext ?? this.autoplayNext,
        hardwareDecoding: hardwareDecoding ?? this.hardwareDecoding,
        audioLanguages: audioLanguages ?? this.audioLanguages,
        defaultQuality: defaultQuality ?? this.defaultQuality,
        subtitleSize: subtitleSize ?? this.subtitleSize,
        subtitleStyle: subtitleStyle ?? this.subtitleStyle,
        subtitleLanguage: subtitleLanguage == null ? this.subtitleLanguage : subtitleLanguage(),
        theme: theme ?? this.theme,
        epgRefreshHours: epgRefreshHours ?? this.epgRefreshHours,
        autoUpdatePlaylist: autoUpdatePlaylist ?? this.autoUpdatePlaylist,
        adultFilter: adultFilter ?? this.adultFilter,
        relockMinutes: relockMinutes ?? this.relockMinutes,
        recentSearches: recentSearches ?? this.recentSearches,
        temporaryAccountIds: temporaryAccountIds ?? this.temporaryAccountIds,
      );
}

/// Preferences backend, created before `runApp` (see main.dart) and injected
/// with a provider override so settings are available synchronously.
final sharedPreferencesProvider = Provider<SharedPreferencesWithCache>((_) => throw UnimplementedError('override in main'));

final appSettingsProvider = NotifierProvider<AppSettingsController, AppSettings>(AppSettingsController.new);

class AppSettingsController extends Notifier<AppSettings> {
  late SharedPreferencesWithCache _prefs;

  static const _k = (
    onboarding: 'onboarding_done',
    active: 'active_account',
    openDefault: 'open_default_on_launch',
    locale: 'locale',
    start: 'start_screen',
    autoplay: 'autoplay_next',
    hw: 'hardware_decoding',
    audio: 'audio_languages',
    quality: 'default_quality',
    subSize: 'subtitle_size',
    subStyle: 'subtitle_style',
    subLang: 'subtitle_language',
    theme: 'theme',
    epgHours: 'epg_refresh_hours',
    autoUpdate: 'auto_update_playlist',
    adult: 'adult_filter',
    relock: 'relock_minutes',
    searches: 'recent_searches',
    temporary: 'temporary_accounts',
  );

  /// Keys this app stores — the SharedPreferencesWithCache allow-list.
  static const keys = {
    'onboarding_done',
    'active_account',
    'open_default_on_launch',
    'locale',
    'start_screen',
    'autoplay_next',
    'hardware_decoding',
    'audio_languages',
    'default_quality',
    'subtitle_size',
    'subtitle_style',
    'subtitle_language',
    'theme',
    'epg_refresh_hours',
    'auto_update_playlist',
    'adult_filter',
    'relock_minutes',
    'recent_searches',
    'temporary_accounts',
  };

  @override
  AppSettings build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    const d = AppSettings();
    T? e<T extends Enum>(List<T> values, String? name) => values.where((v) => v.name == name).firstOrNull;
    return AppSettings(
      onboardingDone: _prefs.getBool(_k.onboarding) ?? d.onboardingDone,
      activeAccountId: _prefs.getString(_k.active),
      openDefaultOnLaunch: _prefs.getBool(_k.openDefault) ?? d.openDefaultOnLaunch,
      localeCode: _prefs.getString(_k.locale),
      startScreen: e(StartScreen.values, _prefs.getString(_k.start)) ?? d.startScreen,
      autoplayNext: _prefs.getBool(_k.autoplay) ?? d.autoplayNext,
      hardwareDecoding: _prefs.getBool(_k.hw) ?? d.hardwareDecoding,
      audioLanguages: _prefs.getStringList(_k.audio) ?? d.audioLanguages,
      defaultQuality: _prefs.getString(_k.quality) ?? d.defaultQuality,
      subtitleSize: e(SubtitleSize.values, _prefs.getString(_k.subSize)) ?? d.subtitleSize,
      subtitleStyle: e(SubtitleStyle.values, _prefs.getString(_k.subStyle)) ?? d.subtitleStyle,
      subtitleLanguage: _prefs.getString(_k.subLang),
      theme: e(PlayerTheme.values, _prefs.getString(_k.theme)) ?? d.theme,
      epgRefreshHours: _prefs.getInt(_k.epgHours) ?? d.epgRefreshHours,
      autoUpdatePlaylist: _prefs.getBool(_k.autoUpdate) ?? d.autoUpdatePlaylist,
      adultFilter: _prefs.getBool(_k.adult) ?? d.adultFilter,
      relockMinutes: _prefs.getInt(_k.relock) ?? d.relockMinutes,
      recentSearches: _prefs.getStringList(_k.searches) ?? d.recentSearches,
      temporaryAccountIds: _prefs.getStringList(_k.temporary) ?? d.temporaryAccountIds,
    );
  }

  Future<void> update(AppSettings Function(AppSettings) change) async {
    final next = change(state);
    state = next;
    final p = _prefs;
    Future<void> str(String k, String? v) => v == null ? p.remove(k) : p.setString(k, v);
    await Future.wait([
      p.setBool(_k.onboarding, next.onboardingDone),
      str(_k.active, next.activeAccountId),
      p.setBool(_k.openDefault, next.openDefaultOnLaunch),
      str(_k.locale, next.localeCode),
      p.setString(_k.start, next.startScreen.name),
      p.setBool(_k.autoplay, next.autoplayNext),
      p.setBool(_k.hw, next.hardwareDecoding),
      p.setStringList(_k.audio, next.audioLanguages),
      p.setString(_k.quality, next.defaultQuality),
      p.setString(_k.subSize, next.subtitleSize.name),
      p.setString(_k.subStyle, next.subtitleStyle.name),
      str(_k.subLang, next.subtitleLanguage),
      p.setString(_k.theme, next.theme.name),
      p.setInt(_k.epgHours, next.epgRefreshHours),
      p.setBool(_k.autoUpdate, next.autoUpdatePlaylist),
      p.setBool(_k.adult, next.adultFilter),
      p.setInt(_k.relock, next.relockMinutes),
      p.setStringList(_k.searches, next.recentSearches),
      p.setStringList(_k.temporary, next.temporaryAccountIds),
    ]);
  }

  Future<void> addRecentSearch(String q) {
    final t = q.trim();
    if (t.isEmpty) return Future.value();
    return update((s) => s.copyWith(recentSearches: [t, ...s.recentSearches.where((x) => x.toLowerCase() != t.toLowerCase())].take(10).toList()));
  }
}

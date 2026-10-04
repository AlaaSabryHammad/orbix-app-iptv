import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/design/design.dart';
import '../../core/l10n/l10n.dart';
import '../../core/router/routes.dart';
import '../../core/session/session.dart';
import '../../core/settings/app_settings.dart';
import '../../data/data.dart';
import '../../shared/format/format.dart';
import '../../shared/widgets/widgets.dart';
import '../accounts/account_avatar.dart';
import '../accounts/sync_controller.dart';
import '../common/languages.dart';
import '../live/live_providers.dart';
import '../parental/parental_screen.dart';

// Local reads: a failure won't fix itself, so no automatic retry.
Duration? _noRetry(int _, Object _) => null;

final _storageProvider = FutureProvider.autoDispose<StorageUsage>((ref) => ref.watch(storageRepositoryProvider).usage(), retry: _noRetry);

final _versionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
}, retry: _noRetry);

final _epgSourcesProvider = FutureProvider.autoDispose<({List<String> all, String? mine})>((ref) async {
  final id = ref.watch(activeAccountIdProvider) ?? '';
  final creds = await ref.watch(accountRepositoryProvider).credentials(id);
  return (all: await ref.watch(epgRepositoryProvider).sources(id), mine: creds?.epgUrl);
});

/// 22 Settings.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _searching = false;
  String _query = '';

  AppSettingsController get _settings => ref.read(appSettingsProvider.notifier);

  Future<T?> _pick<T>(String title, List<(T, String)> options, T current, {OxIcons? icon}) => showOxSheet<T>(
    context,
    title: title,
    // The sheet route already makes its body flexible.
    builder: (s) => SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [for (final (v, label) in options) OxSheetOption(label: label, icon: icon, selected: v == current, onTap: () => Navigator.pop(s, v))],
      ),
    ),
  );

  Future<void> _language() async {
    final l = context.l10n;
    final current = ref.read(appSettingsProvider).localeCode ?? '';
    final v = await _pick<String>(l.language, [('', l.languageSystem), ('en', 'English'), ('ar', 'العربية')], current, icon: OxIcons.translate);
    if (v != null) await _settings.update((s) => s.copyWith(localeCode: () => v.isEmpty ? null : v));
  }

  String _startLabel(AppLocalizations l, StartScreen s) => switch (s) {
    StartScreen.home => l.navHome,
    StartScreen.live => l.navLive,
    StartScreen.movies => l.navMovies,
    StartScreen.series => l.navSeries,
    StartScreen.favorites => l.navFavorites,
  };

  Future<void> _startScreen() async {
    final l = context.l10n;
    final v = await _pick(l.startScreen, [for (final s in StartScreen.values) (s, _startLabel(l, s))], ref.read(appSettingsProvider).startScreen);
    if (v != null) await _settings.update((s) => s.copyWith(startScreen: v));
  }

  Future<void> _quality() async {
    final l = context.l10n;
    final v = await _pick(l.defaultQuality, [
      ('auto', l.qualityAuto),
      ('2160', '4K · 2160p'),
      ('1080', '1080p'),
      ('720', '720p'),
      ('480', '480p'),
    ], ref.read(appSettingsProvider).defaultQuality);
    if (v != null) await _settings.update((s) => s.copyWith(defaultQuality: v));
  }

  Future<void> _audio() async {
    final l = context.l10n;
    final result = await showOxSheet<List<String>>(
      context,
      title: l.audioLanguage,
      builder: (s) {
        final chosen = [...ref.read(appSettingsProvider).audioLanguages];
        return StatefulBuilder(
          builder: (context, set) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                child: Text(l.audioLanguageHint, style: context.oxText.caption),
              ),
              for (final code in audioLanguageCodes)
                OxListRow(
                  title: languageName(l, code),
                  trailing: chosen.contains(code)
                      ? Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(color: OxColors.ember, shape: BoxShape.circle),
                          child: Text(
                            '${chosen.indexOf(code) + 1}',
                            style: OxTypography.en.caption.copyWith(fontWeight: FontWeight.w800, color: OxColors.emberInk),
                          ),
                        )
                      : null,
                  onTap: () => set(() => chosen.contains(code) ? chosen.remove(code) : chosen.add(code)),
                ),
              const SizedBox(height: 10),
              OxButton(label: l.actionDone, expand: true, onPressed: () => Navigator.pop(s, chosen)),
            ],
          ),
        );
      },
    );
    if (result != null) await _settings.update((s) => s.copyWith(audioLanguages: result));
  }

  Future<void> _subtitles() async {
    final l = context.l10n;
    await showOxSheet<void>(
      context,
      title: l.subtitleSettings,
      builder: (s) => Consumer(
        builder: (context, ref, _) {
          final st = ref.watch(appSettingsProvider);
          final t = context.oxText;
          final size = switch (st.subtitleSize) {
            SubtitleSize.small => 15.0,
            SubtitleSize.medium => 19.0,
            SubtitleSize.large => 24.0,
          };
          final base = t.title.copyWith(fontSize: size, color: const Color(0xFFFFFFFF), height: 1.3);
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              // Preview over a backdrop.
              Container(
                height: 120,
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3A2A4E), Color(0xFF7A4A2A)]),
                ),
                child: _SubtitleSample(text: languageName(l, st.audioLanguages.firstOrNull ?? 'en'), style: base, kind: st.subtitleStyle),
              ),
              Text(l.subtitleSize, style: t.caption),
              OxSegmented<SubtitleSize>(
                segments: [
                  OxSegment(SubtitleSize.small, l.sizeSmall),
                  OxSegment(SubtitleSize.medium, l.sizeMedium),
                  OxSegment(SubtitleSize.large, l.sizeLarge),
                ],
                selected: st.subtitleSize,
                onChanged: (v) => _settings.update((s) => s.copyWith(subtitleSize: v)),
              ),
              Text(l.subtitleStyle, style: t.caption),
              OxSegmented<SubtitleStyle>(
                segments: [
                  OxSegment(SubtitleStyle.outline, _cap(l.styleOutline)),
                  OxSegment(SubtitleStyle.shadow, _cap(l.styleShadow)),
                  OxSegment(SubtitleStyle.box, _cap(l.styleBox)),
                ],
                selected: st.subtitleStyle,
                onChanged: (v) => _settings.update((s) => s.copyWith(subtitleStyle: v)),
              ),
              const SizedBox(height: 4),
              OxButton(label: l.actionDone, expand: true, onPressed: () => Navigator.pop(s)),
            ],
          );
        },
      ),
    );
  }

  static String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Future<void> _epgSources(Account account) async {
    final l = context.l10n;
    final info = await ref.read(_epgSourcesProvider.future);
    if (!mounted) return;
    final url = await showOxSheet<String>(
      context,
      title: l.epgSources,
      builder: (_) => _EpgSourcesSheet(sources: info.all, mine: info.mine, redact: _redact),
    );
    if (url == null || url == (info.mine ?? '')) return;
    final repo = ref.read(accountRepositoryProvider);
    final creds = await repo.credentials(account.id);
    if (creds == null) return;
    await repo.updateCredentials(account.id, creds.withEpgUrl(url.isEmpty ? null : url));
    ref.invalidate(_epgSourcesProvider);
    unawaited(ref.read(syncControllerProvider.notifier).refreshGuide(account.id));
  }

  /// Host and path only — guide URLs often carry the username and password.
  static String _redact(String url) {
    final u = Uri.tryParse(url);
    return u == null ? url : '${u.host}${u.hasPort ? ':${u.port}' : ''}${u.path}';
  }

  Future<void> _epgRefresh(Account account) async {
    final l = context.l10n;
    final current = ref.read(appSettingsProvider).epgRefreshHours;
    final v = await showOxSheet<int>(
      context,
      title: l.epgRefresh,
      builder: (s) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final h in const [6, 12, 24, 48])
            OxSheetOption(label: l.everyHours(h), icon: OxIcons.clock, selected: h == current, onTap: () => Navigator.pop(s, h)),
          const SizedBox(height: 10),
          OxButton(label: l.refreshGuide, icon: OxIcons.refresh, variant: OxButtonVariant.tonal, expand: true, onPressed: () => Navigator.pop(s, -1)),
        ],
      ),
    );
    if (v == null) return;
    if (v == -1) {
      unawaited(ref.read(syncControllerProvider.notifier).refreshGuide(account.id));
    } else {
      await _settings.update((s) => s.copyWith(epgRefreshHours: v));
    }
  }

  Future<void> _guideShift(Account account) async {
    final l = context.l10n;
    final v = await _pick(l.guideShift, [for (var h = -12; h <= 12; h++) (h * 60, l.shiftHours(_signed(h)))], account.guideShiftMinutes, icon: OxIcons.clock);
    if (v != null) await ref.read(accountRepositoryProvider).setGuideShift(account.id, v);
  }

  String _updated(AppLocalizations l, DateTime? at) {
    if (at == null) return l.neverUpdated;
    final local = at.toLocal(), now = DateTime.now();
    if (local.year == now.year && local.month == now.month && local.day == now.day) return l.lastUpdatedToday(Fmt.clock(local));
    return l.lastUpdated('${Fmt.relative(context, local)}, ${Fmt.clock(local)}');
  }

  static String _signed(int h) => h >= 0 ? '+$h' : '−${-h}';

  Future<void> _clearCache() async {
    final l = context.l10n;
    final ok = await showOxDialog<bool>(
      context,
      builder: (d) => OxDialog(
        icon: OxIcons.trash,
        tone: OxDialogTone.danger,
        title: l.clearCacheTitle,
        message: l.clearCacheBody,
        actions: [
          OxButton(label: l.actionCancel, variant: OxButtonVariant.ghost, size: OxButtonSize.sm, onPressed: () => Navigator.pop(d, false)),
          OxButton(label: l.clearCache, variant: OxButtonVariant.destructive, size: OxButtonSize.sm, onPressed: () => Navigator.pop(d, true)),
        ],
      ),
    );
    if (ok != true) return;
    final storage = ref.read(storageRepositoryProvider);
    Future<int?> total() async {
      try {
        return (await storage.usage()).total;
      } on Object {
        return null;
      }
    }

    final before = await total();
    PaintingBinding.instance.imageCache.clear();
    await storage.clear();
    final after = await total();
    ref.invalidate(_storageProvider);
    final id = ref.read(activeAccountIdProvider);
    if (id != null) unawaited(ref.read(syncControllerProvider.notifier).refreshGuide(id));
    if (!mounted) return;
    // States 12: "Cache cleared · 248 MB freed".
    final freed = before != null && after != null && before > after ? before - after : null;
    showOxSnack(
      context,
      tone: OxSnackTone.success,
      message: freed == null ? l.cacheCleared : l.cacheClearedFreed(Fmt.bytes(freed)),
      icon: OxIcons.check,
      iconColor: OxColors.ok,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.oxText;
    final pad = MediaQuery.paddingOf(context);
    final st = ref.watch(appSettingsProvider);
    final account = ref.watch(activeAccountProvider).value;
    final accounts = ref.watch(accountsProvider).value ?? const [];
    final sync = account == null ? null : ref.watch(syncControllerProvider.select((m) => m[account.id]));
    final syncing = sync != null && (!sync.catalogDone || !sync.guideDone) && sync.guideFailure == null && sync.catalog.failure == null;
    final pin = ref.watch(pinInfoProvider).value;
    final locks = ref.watch(locksProvider).value ?? const {};
    final storage = ref.watch(_storageProvider).value;
    final sources = ref.watch(_epgSourcesProvider).value;
    final version = ref.watch(_versionProvider).value ?? '';

    void set(AppSettings Function(AppSettings) f) => unawaited(_settings.update(f));

    final lockedCategories = locks.where((k) => k.$1 != LockKind.channel).length;
    final themeLabel = Row(
      spacing: 14,
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: OxColors.ink4, borderRadius: BorderRadius.circular(12)),
          child: const OxIcon(OxIcons.palette, size: OxIconSize.sm),
        ),
        Text(l.theme, style: t.title.copyWith(fontSize: 14.5)),
      ],
    );

    // (section, [(search text, row)]) — the search filters rows by title.
    final sections = <(String, List<(String, Widget)>)>[
      (
        l.sectionGeneral,
        [
          (
            l.language,
            OxListRow(
              icon: OxIcons.translate,
              title: l.language,
              value: switch (st.localeCode) {
                'en' => 'English',
                'ar' => 'العربية',
                _ => l.languageSystem,
              },
              chevron: true,
              onTap: _language,
            ),
          ),
          (l.startScreen, OxListRow(icon: OxIcons.home, title: l.startScreen, value: _startLabel(l, st.startScreen), chevron: true, onTap: _startScreen)),
          (
            l.autoplayNext,
            OxListRow(
              icon: OxIcons.autoplay,
              title: l.autoplayNext,
              subtitle: l.autoplayNextHint,
              trailing: OxSwitch(
                value: st.autoplayNext,
                semanticLabel: l.autoplayNext,
                onChanged: (v) => set((s) => s.copyWith(autoplayNext: v)),
              ),
            ),
          ),
        ],
      ),
      (
        l.sectionPlayback,
        [
          (l.preferredPlayer, OxListRow(icon: OxIcons.play, title: l.preferredPlayer, value: l.orbixPlayer)),
          (
            l.hardwareDecoding,
            OxListRow(
              icon: OxIcons.cpu,
              title: l.hardwareDecoding,
              subtitle: l.hardwareDecodingHint,
              trailing: OxSwitch(
                value: st.hardwareDecoding,
                semanticLabel: l.hardwareDecoding,
                onChanged: (v) => set((s) => s.copyWith(hardwareDecoding: v)),
              ),
            ),
          ),
          (
            l.audioLanguage,
            OxListRow(
              icon: OxIcons.audio,
              title: l.audioLanguage,
              value: switch (st.audioLanguages) {
                [] => l.qualityAuto,
                [final a] => languageName(l, a),
                [final a, final b, ...] => l.audioLanguagesValue(languageName(l, a), languageName(l, b)),
              },
              chevron: true,
              onTap: _audio,
            ),
          ),
          (
            l.subtitleSettings,
            OxListRow(
              icon: OxIcons.cc,
              title: l.subtitleSettings,
              value:
                  '${switch (st.subtitleSize) {
                    SubtitleSize.small => l.sizeSmall,
                    SubtitleSize.medium => l.sizeMedium,
                    SubtitleSize.large => l.sizeLarge,
                  }} · '
                  '${switch (st.subtitleStyle) {
                    SubtitleStyle.outline => l.styleOutline,
                    SubtitleStyle.shadow => l.styleShadow,
                    SubtitleStyle.box => l.styleBox,
                  }}',
              chevron: true,
              onTap: _subtitles,
            ),
          ),
          (
            l.defaultQuality,
            OxListRow(
              icon: OxIcons.hd,
              title: l.defaultQuality,
              value: st.defaultQuality == 'auto' ? l.qualityAuto : '${st.defaultQuality}p',
              chevron: true,
              onTap: _quality,
            ),
          ),
        ],
      ),
      (
        l.sectionAppearance,
        [
          (
            l.theme,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  themeLabel,
                  OxSegmented<PlayerTheme>(
                    segments: [
                      OxSegment(PlayerTheme.dark, l.themeDark, icon: OxIcons.moon),
                      OxSegment(PlayerTheme.amoled, l.themeAmoled),
                      OxSegment(PlayerTheme.system, l.themeSystem),
                    ],
                    selected: st.theme,
                    onChanged: (v) => set((s) => s.copyWith(theme: v)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      if (account != null)
        (
          l.sectionGuide,
          [
            (
              l.epgSources,
              OxListRow(
                icon: OxIcons.epg,
                title: l.epgSources,
                value: sources == null ? null : (sources.all.isEmpty ? l.epgSourcesNone : l.epgSourcesValue(sources.mine == null ? 0 : 1)),
                chevron: true,
                onTap: () => _epgSources(account),
              ),
            ),
            (
              l.epgRefresh,
              OxListRow(
                icon: OxIcons.refresh,
                title: l.epgRefresh,
                subtitle: _updated(l, account.guideUpdatedAt),
                value: l.everyHours(st.epgRefreshHours),
                chevron: true,
                onTap: () => _epgRefresh(account),
              ),
            ),
            (
              l.guideShift,
              OxListRow(
                icon: OxIcons.clock,
                title: l.guideShift,
                value: l.shiftHours(_signed(account.guideShiftMinutes ~/ 60)),
                chevron: true,
                onTap: () => _guideShift(account),
              ),
            ),
          ],
        ),
      (
        l.sectionPlaylist,
        [
          (
            l.autoUpdatePlaylist,
            OxListRow(
              icon: OxIcons.playlist,
              title: l.autoUpdatePlaylist,
              subtitle: l.autoUpdatePlaylistHint,
              trailing: OxSwitch(
                value: st.autoUpdatePlaylist,
                semanticLabel: l.autoUpdatePlaylist,
                onChanged: (v) => set((s) => s.copyWith(autoUpdatePlaylist: v)),
              ),
            ),
          ),
        ],
      ),
      (
        l.sectionSecurity,
        [
          (
            l.parentalControls,
            OxListRow(
              icon: OxIcons.shield,
              iconColor: OxColors.warn,
              iconBackground: const Color(0x24FFC65C),
              title: l.parentalControls,
              subtitle: pin == null ? null : (pin.hasPin ? l.parentalSummaryOn(lockedCategories) : l.parentalSummaryOff),
              chevron: true,
              onTap: () => context.push(Routes.parental),
            ),
          ),
          (
            l.manageAccounts,
            OxListRow(icon: OxIcons.server, title: l.manageAccounts, value: '${accounts.length}', chevron: true, onTap: () => context.push(Routes.accounts)),
          ),
        ],
      ),
      (l.sectionStorage, [(l.cache, _StorageCard(usage: storage, onClear: _clearCache))]),
      (
        l.sectionAbout,
        [
          (l.version, OxListRow(icon: OxIcons.info, title: l.version, value: version)),
          (l.legalNotice, OxListRow(icon: OxIcons.file, title: l.legalNotice, subtitle: l.legalNoticeBody)),
        ],
      ),
    ];

    final q = _query.trim().toLowerCase();
    final visible = [
      for (final (title, rows) in sections)
        if (q.isEmpty || title.toLowerCase().contains(q))
          (title, rows)
        else if (rows.any((r) => r.$1.toLowerCase().contains(q)))
          (title, rows.where((r) => r.$1.toLowerCase().contains(q)).toList()),
    ];

    final children = <Widget>[
      if (account != null && q.isEmpty)
        _AccountCard(
          account: account,
          syncing: syncing,
          onSwitch: () => context.push(Routes.accounts),
          onRefresh: syncing ? null : () => ref.read(syncControllerProvider.notifier).start(account),
        ),
      for (final (title, rows) in visible)
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
              child: Text(t.overlineText(title), style: t.overline),
            ),
            OxGroup(children: [for (final r in rows) r.$2]),
          ],
        ),
      if (visible.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Text(
            l.noSettingsMatch(_query.trim()),
            textAlign: TextAlign.center,
            style: t.body.copyWith(color: OxColors.text3),
          ),
        ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          const OxAmbient(size: Size(300, 200), left: 60, top: 60, color: OxColors.ember, opacity: 0.14),
          CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsetsDirectional.fromSTEB(20, pad.top + 16, 12, 0),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640 + 8),
                      child: SizedBox(
                        height: 48,
                        child: AnimatedSwitcher(
                          duration: OxMotion.base,
                          child: _searching
                              ? Row(
                                  key: const ValueKey('search'),
                                  spacing: 8,
                                  children: [
                                    Expanded(
                                      child: OxSearchField(hint: l.searchSettings, autofocus: true, onChanged: (v) => setState(() => _query = v)),
                                    ),
                                    OxIconButton(
                                      icon: OxIcons.close,
                                      semanticLabel: l.actionCancel,
                                      onPressed: () => setState(() {
                                        _searching = false;
                                        _query = '';
                                      }),
                                    ),
                                  ],
                                )
                              : Row(
                                  key: const ValueKey('title'),
                                  children: [
                                    Expanded(child: Text(l.settingsTitle, style: t.h1.copyWith(fontSize: 28))),
                                    OxIconButton(icon: OxIcons.search, semanticLabel: l.searchSettings, onPressed: () => setState(() => _searching = true)),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, pad.bottom + 24),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 22, children: children),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.account, required this.syncing, required this.onSwitch, required this.onRefresh});

  final Account account;
  final bool syncing;
  final VoidCallback onSwitch;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.oxText;
    final kind = switch (account.kind) {
      AccountKind.xtream => l.accountKindXtream,
      AccountKind.m3u => l.accountKindM3u,
      AccountKind.file => l.accountKindFile,
    };
    return OxGlass(
      borderRadius: BorderRadius.circular(24),
      shadows: OxShadows.e1,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Row(
            spacing: 14,
            children: [
              AccountAvatar(account: account, size: 56),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 8,
                      children: [
                        Flexible(child: OxContentText(account.name, style: t.title.copyWith(fontSize: 16))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0x245BD69B), borderRadius: BorderRadius.circular(6)),
                          child: Text(
                            l.activeBadge,
                            style: OxTypography.en.caption.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              height: 1.2,
                              color: OxColors.ok,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text([kind, if (account.expiresAt != null) l.expiresOn(Fmt.date(context, account.expiresAt!))].join(' · '), style: t.caption),
                    Text(l.catalogCounts(Fmt.count(account.liveCount), Fmt.count(account.movieCount), Fmt.count(account.seriesCount)), style: t.caption),
                  ],
                ),
              ),
            ],
          ),
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: OxButton(
                  label: l.switchAccount,
                  icon: OxIcons.user,
                  variant: OxButtonVariant.tonal,
                  size: OxButtonSize.sm,
                  expand: true,
                  onPressed: onSwitch,
                ),
              ),
              Expanded(
                child: OxButton(
                  label: syncing ? l.refreshingLists : l.refreshLists,
                  icon: OxIcons.refresh,
                  variant: OxButtonVariant.tonal,
                  size: OxButtonSize.sm,
                  expand: true,
                  onPressed: onRefresh,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StorageCard extends StatelessWidget {
  const _StorageCard({required this.usage, required this.onClear});

  final StorageUsage? usage;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.oxText;
    final u = usage;
    final total = u == null || u.total == 0 ? 1 : u.total;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            spacing: 14,
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: OxColors.ink4, borderRadius: BorderRadius.circular(12)),
                child: const OxIcon(OxIcons.database, size: OxIconSize.sm),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.cache, style: t.title.copyWith(fontSize: 14.5)),
                    if (u != null) Text(l.cacheBreakdown(Fmt.bytes(u.artwork), Fmt.bytes(u.guide), Fmt.bytes(u.lists)), style: t.caption),
                  ],
                ),
              ),
              if (u != null) Text(Fmt.bytes(u.total), style: OxTypography.en.time.copyWith(fontSize: 13, color: OxColors.text1)),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 6,
              color: const Color(0x14FFFFFF),
              child: u == null
                  ? null
                  : Row(
                      spacing: 2,
                      children: [
                        for (final (bytes, color) in [(u.artwork, OxColors.ember), (u.guide, OxColors.halo), (u.lists, OxColors.text1)])
                          if (bytes > 0)
                            Expanded(
                              flex: (bytes * 1000 ~/ total).clamp(1, 1000),
                              child: ColoredBox(color: color),
                            ),
                        // The rest of the bar stays empty: the device has more room.
                        Expanded(flex: (1000 * 0.4).round(), child: const SizedBox()),
                      ],
                    ),
            ),
          ),
          OxButton(label: l.clearCache, icon: OxIcons.trash, variant: OxButtonVariant.danger, size: OxButtonSize.sm, onPressed: onClear),
        ],
      ),
    );
  }
}

class _SubtitleSample extends StatelessWidget {
  const _SubtitleSample({required this.text, required this.style, required this.kind});

  final String text;
  final TextStyle style;
  final SubtitleStyle kind;

  @override
  Widget build(BuildContext context) {
    final label = '♪ $text ♪';
    return switch (kind) {
      SubtitleStyle.box => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        color: const Color(0xB3000000),
        child: Text(label, style: style),
      ),
      SubtitleStyle.shadow => Text(
        label,
        style: style.copyWith(
          shadows: const [Shadow(color: Color(0xE6000000), blurRadius: 6, offset: Offset(0, 2))],
        ),
      ),
      SubtitleStyle.outline => Stack(
        children: [
          Text(
            label,
            style: style.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3
                ..color = const Color(0xFF000000),
              color: null,
            ),
          ),
          Text(label, style: style),
        ],
      ),
    };
  }
}

/// Settings › EPG sources: the guide URLs in use and the user's own URL.
/// Owns its text controller, so it outlives the sheet's closing animation.
class _EpgSourcesSheet extends StatefulWidget {
  const _EpgSourcesSheet({required this.sources, required this.mine, required this.redact});

  final List<String> sources;
  final String? mine;
  final String Function(String) redact;

  @override
  State<_EpgSourcesSheet> createState() => _EpgSourcesSheetState();
}

class _EpgSourcesSheetState extends State<_EpgSourcesSheet> {
  late final _controller = TextEditingController(text: widget.mine ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        OxGroup(
          children: [
            if (widget.sources.isEmpty) OxListRow(title: l.epgSourcesNone, icon: OxIcons.epg),
            for (final u in widget.sources)
              OxListRow(
                icon: u == widget.mine ? OxIcons.user : OxIcons.server,
                title: u == widget.mine ? l.yourGuide : l.providerGuide,
                subtitle: widget.redact(u),
              ),
          ],
        ),
        OxTextField(controller: _controller, label: l.fieldEpgUrlXmltv, hint: 'https://…/epg.xml', ltr: true, keyboardType: TextInputType.url),
        OxButton(label: l.actionSave, expand: true, onPressed: () => Navigator.pop(context, _controller.text.trim())),
      ],
    );
  }
}

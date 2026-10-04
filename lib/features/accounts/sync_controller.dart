import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings/app_settings.dart';
import '../../data/data.dart';

/// One account's background refresh: catalog first, then the guide.
class AccountSync {
  const AccountSync({this.catalog = const SyncProgress(), this.guide, this.guideFailure, this.guideDays, this.newChannels});

  final SyncProgress catalog;
  final GuideProgress? guide;
  final OrbixFailure? guideFailure;

  /// Days of guide data once imported ("7 days").
  final int? guideDays;

  /// Channels added by this refresh ("Playlist updated · 12 new channels");
  /// null on an account's first sync.
  final int? newChannels;

  bool get catalogDone => catalog.finished;
  bool get guideDone => guide?.fraction == 1 || guideFailure != null;

  AccountSync copyWith({SyncProgress? catalog, GuideProgress? guide, OrbixFailure? guideFailure, int? guideDays, int? newChannels}) => AccountSync(
        catalog: catalog ?? this.catalog,
        guide: guide ?? this.guide,
        guideFailure: guideFailure ?? this.guideFailure,
        guideDays: guideDays ?? this.guideDays,
        newChannels: newChannels ?? this.newChannels,
      );
}

/// Running / finished syncs by account id. Lives as long as the app, so a
/// sync continues after leaving the setup screen ("Watch Live TV now").
final syncControllerProvider = NotifierProvider<SyncController, Map<String, AccountSync>>(SyncController.new);

class SyncController extends Notifier<Map<String, AccountSync>> {
  final _running = <String>{};

  @override
  Map<String, AccountSync> build() => const {};

  bool isRunning(String accountId) => _running.contains(accountId);

  void _set(String id, AccountSync s) => state = {...state, id: s};

  /// Starts (or joins) a refresh of [account]. [prefetched] skips the M3U
  /// download right after a connection test.
  Future<void> start(Account account, {CatalogSnapshot? prefetched}) async {
    if (!_running.add(account.id)) return;
    var s = const AccountSync();
    _set(account.id, s);
    try {
      await for (final p in ref.read(catalogRepositoryProvider).sync(account, prefetched: prefetched)) {
        s = s.copyWith(catalog: p);
        _set(account.id, s);
      }
      if (s.catalog.failure != null) return;
      if (account.lastSyncedAt != null) {
        final after = await ref.read(accountRepositoryProvider).byId(account.id);
        if (after != null) _set(account.id, s = s.copyWith(newChannels: after.liveCount - account.liveCount));
      }
      await _refreshGuide(account.id, () => s, (n) => _set(account.id, s = n));
    } finally {
      _running.remove(account.id);
    }
  }

  /// Guide only (Settings › EPG refresh, or the periodic refresh).
  Future<void> refreshGuide(String accountId) async {
    if (!_running.add('$accountId:guide')) return;
    var s = state[accountId] ?? const AccountSync(catalog: SyncProgress());
    try {
      await _refreshGuide(accountId, () => s, (n) => _set(accountId, s = n));
    } finally {
      _running.remove('$accountId:guide');
    }
  }

  Future<void> _refreshGuide(String accountId, AccountSync Function() get, void Function(AccountSync) set) async {
    final account = await ref.read(accountRepositoryProvider).byId(accountId);
    if (account == null) return;
    final epg = ref.read(epgRepositoryProvider);
    try {
      await for (final g in epg.refresh(account)) {
        set(get().copyWith(guide: g));
      }
      final span = await epg.coverage(accountId);
      final days = span == null ? 0 : (span.$2.difference(DateTime.now()).inHours / 24).ceil().clamp(0, 14);
      set(get().copyWith(guideDays: days));
    } on OrbixFailure catch (f) {
      set(get().copyWith(guideFailure: f));
    }
  }

  /// Back online after a sync failed offline: try again on our own
  /// ("Orbix reconnects on its own as soon as you're back").
  Future<void> retryAfterReconnect(Account account) async {
    final failure = state[account.id]?.catalog.failure;
    if (failure is OfflineFailure || (failure != null && account.liveCount + account.movieCount + account.seriesCount == 0)) {
      await start(account);
    }
  }

  /// "Auto-update playlist — on launch, at most once a day" and the guide
  /// every N hours. Call when an account becomes active.
  Future<void> refreshIfStale(Account account) async {
    final settings = ref.read(appSettingsProvider);
    final now = DateTime.now();
    final catalogStale = account.lastSyncedAt == null || (settings.autoUpdatePlaylist && now.difference(account.lastSyncedAt!) > const Duration(hours: 24));
    if (catalogStale) return start(account);
    final guideStale = account.guideUpdatedAt == null || now.difference(account.guideUpdatedAt!) > Duration(hours: settings.epgRefreshHours);
    if (guideStale) return refreshGuide(account.id);
  }
}

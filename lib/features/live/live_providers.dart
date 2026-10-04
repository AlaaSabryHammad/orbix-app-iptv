import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/design.dart';
import '../../core/session/session.dart';
import '../../data/data.dart';
import '../common/providers.dart';

/// Special category keys next to real category ids.
abstract final class LiveKey {
  static const all = '__all';
  static const favorites = '__fav';
  static const locked = '__locked';
}

String _account(Ref ref) => ref.watch(activeAccountIdProvider) ?? '';

/// Parental locks for the active account.
final locksProvider = StreamProvider<Set<(LockKind, String)>>((ref) => ref.watch(lockRepositoryProvider).watchLocks(_account(ref)));

bool isChannelLocked(Channel c, Set<(LockKind, String)> locks) =>
    locks.contains((LockKind.channel, c.id)) || (c.categoryId != null && locks.contains((LockKind.liveCategory, c.categoryId!)));

/// Channels for a category key (all / favorites / locked / category id).
final liveChannelsProvider = StreamProvider.autoDispose.family<List<Channel>, String>((ref, key) {
  final id = _account(ref);
  final hidden = ref.watch(hiddenCategoriesProvider(ContentKind.live)).value ?? const {};
  final catalog = ref.watch(catalogRepositoryProvider);
  switch (key) {
    case LiveKey.favorites:
      return ref.watch(libraryRepositoryProvider).watchFavoriteChannels(id);
    case LiveKey.locked:
      final locks = ref.watch(locksProvider).value ?? const {};
      return catalog.watchChannels(id).map((all) => all.where((c) => isChannelLocked(c, locks)).toList());
    case LiveKey.all:
      return catalog.watchChannels(id, excludeCategoryIds: hidden);
    default:
      return catalog.watchChannels(id, categoryId: key);
  }
});

/// Now / next for a category's channels (first 600), refreshed by the clock.
final liveNowNextProvider = FutureProvider.autoDispose.family<Map<String, NowNext>, String>((ref, key) async {
  final now = ref.watch(clockProvider).value ?? DateTime.now();
  final channels = await ref.watch(liveChannelsProvider(key).future);
  return ref.read(epgRepositoryProvider).nowNext(_account(ref), channels.take(600).map(EpgRepository.guideIdOf), at: now);
});

/// Category chips / aside entries with counts.
class LiveCategory {
  const LiveCategory(this.key, this.name, this.icon, this.count);

  final String key;
  final String name;
  final OxIcons icon;
  final int count;
}

final liveCategoryCountsProvider = StreamProvider.autoDispose<Map<String, int>>((ref) {
  return ref.watch(catalogRepositoryProvider).watchCategoryCounts(_account(ref), ContentKind.live);
});

/// A glyph for a category, from its name (playlists don't say).
OxIcons iconForCategory(String name) {
  final n = name.toLowerCase();
  bool any(List<String> words) => words.any(n.contains);
  if (any(['news', 'أخبار', 'اخبار'])) return OxIcons.globe;
  if (any(['sport', 'رياض', 'football', 'soccer'])) return OxIcons.trending;
  if (any(['kid', 'child', 'cartoon', 'أطفال', 'اطفال'])) return OxIcons.sun;
  if (any(['music', 'موسيق', 'radio'])) return OxIcons.audio;
  if (any(['movie', 'cinema', 'film', 'doc', 'أفلام', 'وثائق'])) return OxIcons.film;
  if (any(['world', 'international', 'دولي'])) return OxIcons.globe;
  return OxIcons.series;
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/session/session.dart';
import '../../core/settings/app_settings.dart';
import '../../data/data.dart';

/// Ticks every 30 s — drives "live now" progress and now/next rollover.
final clockProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(seconds: 30), (_) => DateTime.now());
});

String _account(Ref ref) => ref.watch(activeAccountIdProvider) ?? '';

/// Category ids hidden by Parental › adult filter.
final hiddenCategoriesProvider = StreamProvider.autoDispose.family<Set<String>, ContentKind>((ref, kind) {
  final adult = ref.watch(appSettingsProvider.select((s) => s.adultFilter));
  if (!adult) return Stream.value(const {});
  return ref
      .watch(catalogRepositoryProvider)
      .watchCategories(_account(ref), kind)
      .map((cats) => {for (final c in cats.where((c) => c.isAdult)) c.id});
});

/// Movie details are fetched once per title and kept for the session.
final movieDetailsProvider = FutureProvider.family<MovieDetails?, String>((ref, movieId) async {
  return ref.watch(catalogRepositoryProvider).movieDetails(_account(ref), movieId);
});

final seriesDetailsProvider = FutureProvider.family<SeriesDetails?, String>((ref, seriesId) async {
  return ref.watch(catalogRepositoryProvider).seriesDetails(_account(ref), seriesId);
});

final continueWatchingProvider = StreamProvider.autoDispose<List<ContinueItem>>((ref) {
  return ref.watch(libraryRepositoryProvider).watchContinueWatching(_account(ref));
});

final recentMoviesProvider = StreamProvider.autoDispose<List<Movie>>((ref) {
  return ref.watch(catalogRepositoryProvider).watchMovies(_account(ref), sort: MovieSort.recentlyAdded, limit: 20);
});

final popularMoviesProvider = StreamProvider.autoDispose<List<Movie>>((ref) {
  return ref.watch(catalogRepositoryProvider).watchMovies(_account(ref), sort: MovieSort.rating, limit: 20);
});

final popularSeriesProvider = StreamProvider.autoDispose<List<Show>>((ref) {
  return ref.watch(catalogRepositoryProvider).watchSeries(_account(ref), sort: MovieSort.rating, limit: 20);
});

final recentSeriesProvider = StreamProvider.autoDispose<List<Show>>((ref) {
  return ref.watch(catalogRepositoryProvider).watchSeries(_account(ref), sort: MovieSort.recentlyAdded, limit: 20);
});

final finishedMoviesProvider = StreamProvider.autoDispose<List<Movie>>((ref) {
  return ref.watch(libraryRepositoryProvider).watchRecentlyFinishedMovies(_account(ref));
});

final favoriteChannelsProvider = StreamProvider.autoDispose<List<Channel>>((ref) {
  return ref.watch(libraryRepositoryProvider).watchFavoriteChannels(_account(ref));
});

final favoriteMoviesProvider = StreamProvider.autoDispose<List<Movie>>((ref) {
  return ref.watch(libraryRepositoryProvider).watchFavoriteMovies(_account(ref));
});

final favoriteSeriesProvider = StreamProvider.autoDispose<List<Show>>((ref) {
  return ref.watch(libraryRepositoryProvider).watchFavoriteSeries(_account(ref));
});

final favoriteIdsProvider = StreamProvider.autoDispose.family<Set<String>, ContentKind>((ref, kind) {
  return ref.watch(libraryRepositoryProvider).watchFavoriteIds(_account(ref), kind);
});

final recentChannelsProvider = StreamProvider.autoDispose<List<Channel>>((ref) {
  return ref.watch(libraryRepositoryProvider).watchRecentChannels(_account(ref));
});

/// A channel with what it's airing.
class LiveItem {
  const LiveItem(this.channel, this.nowNext);

  final Channel channel;
  final NowNext? nowNext;
}

/// "Live now": favorites first, then recently watched, then the top of the
/// list — with now/next, refreshed by [clockProvider].
final liveNowProvider = FutureProvider.autoDispose<List<LiveItem>>((ref) async {
  final now = ref.watch(clockProvider).value ?? DateTime.now();
  final id = _account(ref);
  final favorites = await ref.watch(favoriteChannelsProvider.future);
  final recent = await ref.watch(recentChannelsProvider.future);
  final hidden = await ref.watch(hiddenCategoriesProvider(ContentKind.live).future);
  final all = await ref.read(catalogRepositoryProvider).watchChannels(id, excludeCategoryIds: hidden).first;
  final picked = <String, Channel>{};
  for (final c in [...favorites, ...recent, ...all]) {
    if (hidden.contains(c.categoryId)) continue;
    picked.putIfAbsent(c.id, () => c);
    if (picked.length >= 8) break;
  }
  final nn = await ref.read(epgRepositoryProvider).nowNext(id, picked.values.map(EpgRepository.guideIdOf), at: now);
  return [for (final c in picked.values) LiveItem(c, nn[EpgRepository.guideIdOf(c)])];
});

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';

/// Navigation helpers so screens don't build paths by hand.
extension OrbixNav on BuildContext {
  void openMovie(String id) => push(Routes.movieDetails(id));
  void openSeries(String id) => push(Routes.seriesDetails(id));
  void openSearch() => push(Routes.search);

  /// Players arrive in Phase 5; until then these open a placeholder.
  void playChannel(String channelId) => push(Routes.playLive(channelId));
  void playMovie(String movieId) => push(Routes.playMovie(movieId));
  void playEpisode(String seriesId, String episodeId) => push(Routes.playEpisode(seriesId, episodeId));
}

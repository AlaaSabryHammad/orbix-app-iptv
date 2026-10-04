import 'package:flutter/widgets.dart';

import '../design/icons/ox_icons.dart';
import '../l10n/l10n.dart';
import '../settings/app_settings.dart';

abstract final class Routes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const accounts = '/accounts';
  static const addAccount = '/accounts/add';

  /// Edit an existing account.
  static String editAccount(String id) => '$addAccount?edit=$id';

  /// After connecting: sync progress, then "You're all set".
  static String accountSetup(String id) => '/accounts/setup/$id';

  static const search = '/search';
  static String movieDetails(String id) => '/movie/$id';
  static String seriesDetails(String id) => '/series/$id';
  static String playLive(String channelId) => '/play/live/$channelId';
  static String playMovie(String movieId) => '/play/movie/$movieId';
  static String playEpisode(String seriesId, String episodeId) => '/play/episode/$seriesId/$episodeId';
  static const parental = '/settings/parental';
  static const pin = '/pin';

  static const home = '/home';
  static const live = '/live';
  static const guide = '/guide';
  static const movies = '/movies';
  static const series = '/series';
  static const favorites = '/favorites';
  static const settings = '/settings';

  /// Settings › Start screen.
  static String start(StartScreen s) => switch (s) {
        StartScreen.home => home,
        StartScreen.live => live,
        StartScreen.movies => movies,
        StartScreen.series => series,
        StartScreen.favorites => favorites,
      };

  static const foundations = '/dev/foundations';
  static const gallery = '/dev/gallery';
  static const dataCheck = '/dev/data';
}

/// Top-level destinations — one shell branch each, in rail order.
///
/// Phone bottom nav (<600dp): Home · Live TV · Movies · Series · Favorites ·
/// Profile (= settings). Rail (≥600dp) adds Guide and labels settings as such.
enum AppDestination {
  home(Routes.home, OxIcons.home),
  live(Routes.live, OxIcons.live),
  guide(Routes.guide, OxIcons.epg, onPhone: false),
  movies(Routes.movies, OxIcons.film),
  series(Routes.series, OxIcons.series),
  favorites(Routes.favorites, OxIcons.heart),
  settings(Routes.settings, OxIcons.settings, phoneIcon: OxIcons.user);

  const AppDestination(this.path, this.icon, {this.onPhone = true, this.phoneIcon});

  final String path;
  final OxIcons icon;
  final bool onPhone;
  final OxIcons? phoneIcon;

  static final phone = values.where((d) => d.onPhone).toList(growable: false);

  String label(BuildContext context, {required bool rail}) {
    final l = context.l10n;
    return switch (this) {
      home => l.navHome,
      live => l.navLive,
      guide => l.navGuide,
      movies => l.navMovies,
      series => l.navSeries,
      favorites => l.navFavorites,
      settings => rail ? l.navSettings : l.navProfile,
    };
  }
}

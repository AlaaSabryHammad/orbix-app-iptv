import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/accounts/account_setup_screen.dart';
import '../../features/accounts/add_account_screen.dart';
import '../../features/accounts/profiles_screen.dart';
import '../../features/dev/data_check_screen.dart';
import '../../features/dev/foundations_preview_screen.dart';
import '../../features/dev/gallery_screen.dart';
import '../../features/favorites/favorites_screen.dart';
import '../../features/guide/guide_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/live/live_screen.dart';
import '../../features/movies/movie_details_screen.dart';
import '../../features/movies/movies_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/splash_screen.dart';
import '../../features/parental/parental_screen.dart';
import '../../features/parental/pin_entry.dart';
import '../../features/player/playback_controller.dart';
import '../../features/player/player_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/series/series_details_screen.dart';
import '../../features/series/series_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../settings/app_settings.dart';
import 'app_shell.dart';
import 'routes.dart';

part 'app_router.g.dart';

/// Routes that need an active account.
bool _needsAccount(String path) =>
    AppDestination.values.any((d) => path.startsWith(d.path)) ||
    path.startsWith('/movie/') ||
    path.startsWith('/series/') ||
    path.startsWith(Routes.search) ||
    path.startsWith('/play/');

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: Routes.splash,
    redirect: (context, state) {
      final active = ref.read(appSettingsProvider).activeAccountId;
      if (active == null && _needsAccount(state.matchedLocation)) return Routes.accounts;
      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: Routes.welcome, builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: Routes.accounts, builder: (context, state) => const ProfilesScreen()),
      GoRoute(
        path: Routes.addAccount,
        builder: (context, state) => AddAccountScreen(editId: state.uri.queryParameters['edit']),
      ),
      GoRoute(
        path: '/accounts/setup/:id',
        builder: (context, state) => AccountSetupScreen(accountId: state.pathParameters['id']!),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          for (final d in AppDestination.values)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: d.path,
                  builder: (context, state) => switch (d) {
                    AppDestination.home => const HomeScreen(),
                    AppDestination.live => const LiveScreen(),
                    AppDestination.guide => const GuideScreen(),
                    AppDestination.movies => const MoviesScreen(),
                    AppDestination.series => const SeriesScreen(),
                    AppDestination.favorites => const FavoritesScreen(),
                    AppDestination.settings => const SettingsScreen(),
                  },
                ),
              ],
            ),
        ],
      ),
      GoRoute(path: Routes.search, builder: (context, state) => const SearchScreen()),
      GoRoute(path: '/movie/:id', builder: (context, state) => MovieDetailsScreen(movieId: state.pathParameters['id']!)),
      GoRoute(path: '/series/:id', builder: (context, state) => SeriesDetailsScreen(seriesId: state.pathParameters['id']!)),
      GoRoute(
        path: '/play/:kind/:id',
        builder: (context, state) {
          final (kind, id) = (state.pathParameters['kind']!, state.pathParameters['id']!);
          return PinGate(
            target: kind == 'live' ? ChannelTarget(id) : MovieTarget(id),
            child: PlayerScreen(target: PlayTarget(kind == 'live' ? PlayKind.live : PlayKind.movie, id)),
          );
        },
      ),
      GoRoute(
        path: '/play/episode/:series/:id',
        builder: (context, state) => PinGate(
          target: SeriesTarget(state.pathParameters['series']!),
          child: PlayerScreen(target: PlayTarget(PlayKind.episode, state.pathParameters['id']!, seriesId: state.pathParameters['series'])),
        ),
      ),
      GoRoute(path: Routes.parental, builder: (context, state) => const PinGate(target: SettingsTarget(), child: ParentalScreen())),
      GoRoute(
        path: Routes.pin,
        builder: (context, state) => PinEntryScreen(
          mode: PinMode.values.asNameMap()[state.uri.queryParameters['mode']] ?? PinMode.verify,
          next: state.uri.queryParameters['next'],
        ),
      ),
      GoRoute(path: Routes.foundations, builder: (context, state) => const FoundationsPreviewScreen()),
      GoRoute(path: Routes.gallery, builder: (context, state) => const GalleryScreen()),
      GoRoute(path: Routes.dataCheck, builder: (context, state) => const DataCheckScreen()),
    ],
  );
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Orbix';

  @override
  String get navHome => 'Home';

  @override
  String get navLive => 'Live TV';

  @override
  String get navGuide => 'Guide';

  @override
  String get navMovies => 'Movies';

  @override
  String get navSeries => 'Series';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navProfile => 'Profile';

  @override
  String get navSettings => 'Settings';

  @override
  String get devFoundations => 'Design foundations';

  @override
  String get devGallery => 'Component gallery';

  @override
  String get badgeLive => 'LIVE';

  @override
  String get badgeNew => 'NEW';

  @override
  String get badgePin => 'PIN';

  @override
  String get a11yLoading => 'Loading';

  @override
  String get a11yNowPlaying => 'Now playing';

  @override
  String get a11yLocked => 'Locked';

  @override
  String get a11yAddFavorite => 'Add to favorites';

  @override
  String get a11yRemoveFavorite => 'Remove from favorites';

  @override
  String get a11yShowPassword => 'Show password';

  @override
  String get a11yHidePassword => 'Hide password';

  @override
  String get a11yClear => 'Clear';

  @override
  String get a11yVoiceSearch => 'Voice search';

  @override
  String get a11yDismiss => 'Dismiss';

  @override
  String get splashTagline => 'Every stream you own, in one orbit.';

  @override
  String get splashLoading => 'Loading your library';

  @override
  String get playerOnlyNotice =>
      'Orbix is a media player. It does not include channels or content.';

  @override
  String get actionSkip => 'Skip';

  @override
  String get actionNext => 'Next';

  @override
  String get actionBack => 'Back';

  @override
  String get actionGetStarted => 'Get started';

  @override
  String onboardingStep(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get onboarding1Title => 'Connect your own IPTV service';

  @override
  String get onboarding1Body =>
      'Sign in with Xtream Codes, an M3U link or a playlist file. Orbix plays what your provider gives you — it never supplies content itself.';

  @override
  String get onboarding2Title => 'Live TV, movies and series together';

  @override
  String get onboarding2Body =>
      'Flip channels with a full TV guide, then jump into films and box sets. Everything from your playlist, organized and fast.';

  @override
  String get onboarding3Title => 'Keep favorites. Resume to the second.';

  @override
  String get onboarding3Body =>
      'Heart any channel, movie or series. Progress is saved on this device, so every title opens exactly where you stopped.';

  @override
  String get onboardingXtreamCard => 'Xtream Codes';

  @override
  String get onboardingOnline => 'ONLINE';

  @override
  String get onboardingM3uChip => 'M3U playlist';

  @override
  String get onboardingEpgChip => 'EPG guide';

  @override
  String get onboardingFileChip => 'Local .m3u file';

  @override
  String get onboardingCardCaption => 'Living Room · 1,284 channels';

  @override
  String get onboardingResume => 'Resume S3 · E4 “Ash on the Avenue”';

  @override
  String get onboardingMinLeft => '18 min left';

  @override
  String get onboardingFavorites => 'favorites';

  @override
  String get addAccountTitle => 'Add IPTV account';

  @override
  String get addAccountIntro =>
      'Use a service you are authorized to access. Orbix doesn’t sell or provide channels.';

  @override
  String savedProfiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saved profiles',
      one: '1 saved profile',
    );
    return '$_temp0';
  }

  @override
  String get sourceXtream => 'Xtream';

  @override
  String get sourceM3u => 'M3U';

  @override
  String get sourceFile => 'File';

  @override
  String get fieldAccountName => 'Account name';

  @override
  String get fieldServerUrl => 'Server URL';

  @override
  String get fieldUsername => 'Username';

  @override
  String get fieldPassword => 'Password';

  @override
  String get fieldPlaylistName => 'Playlist name';

  @override
  String get fieldM3uUrl => 'M3U playlist URL';

  @override
  String get fieldEpgUrlXmltv => 'EPG URL (XMLTV)';

  @override
  String get epgOptionalTitle => 'EPG URL';

  @override
  String get epgOptionalTag => '· optional';

  @override
  String get epgOptionalHint => 'Uses your provider’s guide when empty';

  @override
  String get saveProfileEncrypted =>
      'Save as profile · stored encrypted on this device';

  @override
  String get actionTest => 'Test';

  @override
  String get actionConnect => 'Connect';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionEditDetails => 'Edit details';

  @override
  String get actionTryAgain => 'Try again';

  @override
  String get or => 'or';

  @override
  String get chooseLocalFile => 'Choose a local file';

  @override
  String get chooseLocalFileHint => '.m3u or .m3u8 from this device';

  @override
  String get testingConnection => 'Testing connection…';

  @override
  String get testingHint => 'Usually takes under 10 seconds';

  @override
  String get testPassed => 'Connection works';

  @override
  String get testPassedHint => 'Everything checks out — tap Connect to save.';

  @override
  String get testFailed => 'Couldn’t connect';

  @override
  String get stepReach => 'Server reachable';

  @override
  String get stepSignIn => 'Signed in';

  @override
  String get stepDownload => 'Playlist downloaded';

  @override
  String get stepRead => 'Reading channels & VOD';

  @override
  String get stepGuide => 'Guide data (EPG)';

  @override
  String get stepWaiting => 'Waiting';

  @override
  String get stepSkipped => 'Not provided';

  @override
  String get stepGuideBroken => 'Unavailable';

  @override
  String get requiredField => 'Required';

  @override
  String get invalidUrl => 'Enter a valid URL';

  @override
  String get useDemoProvider => 'Use demo provider (debug)';

  @override
  String get errorOffline => 'You’re offline';

  @override
  String get errorOfflineBody =>
      'Check Wi‑Fi or mobile data. Orbix reconnects on its own as soon as you’re back.';

  @override
  String get errorHostNotFound =>
      'We couldn’t find this server. Check the URL and port.';

  @override
  String get errorRefused =>
      'The server refused the connection. Check the port.';

  @override
  String get errorTimeout => 'Server isn’t responding';

  @override
  String errorTimeoutBody(String host) {
    return '$host didn’t answer within 10 seconds. This is usually temporary on the provider’s side.';
  }

  @override
  String errorServer(int code) {
    return 'The provider’s server has a problem (error $code). Try again later.';
  }

  @override
  String errorAccessDenied(int code) {
    return 'The provider refused access (error $code). Your IP or app may be blocked.';
  }

  @override
  String get errorCredentials =>
      'Username or password is incorrect. Check the details from your provider and try again.';

  @override
  String get errorExpired => 'This account has expired';

  @override
  String errorExpiredBody(String name, String date) {
    return 'Your provider reports that “$name” ended on $date. Renew it with your provider, then refresh here.';
  }

  @override
  String get errorExpiredShort => 'This subscription has expired.';

  @override
  String errorDisabled(String status) {
    return 'The provider has disabled this account ($status).';
  }

  @override
  String get errorNotIptv => 'This address doesn’t look like an IPTV server.';

  @override
  String get errorPlaylist => 'This isn’t a valid M3U playlist.';

  @override
  String get errorGuide => 'The guide couldn’t be read.';

  @override
  String get errorTls => 'Secure connection failed (certificate problem).';

  @override
  String get errorUnknown => 'Something went wrong. Please try again.';

  @override
  String get passwordsCaseSensitive => 'Passwords are case-sensitive';

  @override
  String get loadingPlaylist => 'Loading your playlist';

  @override
  String get loadingPlaylistBody =>
      'Live TV is ready first — movies and series keep loading in the background.';

  @override
  String get sectionChannels => 'Channels';

  @override
  String get sectionMovies => 'Movies';

  @override
  String get sectionSeries => 'Series';

  @override
  String get watchLiveNow => 'Watch Live TV now';

  @override
  String get allSetTitle => 'You’re all set';

  @override
  String allSetBody(String name) {
    return '“$name” is connected and saved on this device.';
  }

  @override
  String get statLive => 'Live channels';

  @override
  String get statMovies => 'Movies';

  @override
  String get statSeries => 'Series';

  @override
  String get statGuide => 'TV guide';

  @override
  String guideDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get startWatching => 'Start watching';

  @override
  String get profilesTitle => 'Choose an account';

  @override
  String get profilesSubtitle => 'Your IPTV profiles on this device';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionDone => 'Done';

  @override
  String get addAccount => 'Add account';

  @override
  String get addAccountTypes => 'Xtream · M3U';

  @override
  String get editAccount => 'Edit account';

  @override
  String get setAsDefault => 'Set as default';

  @override
  String get actionDelete => 'Delete';

  @override
  String get openDefaultOnLaunch => 'Open default account on launch';

  @override
  String get openDefaultOnLaunchHint => 'Skip this screen next time';

  @override
  String continueWith(String name) {
    return 'Continue with $name';
  }

  @override
  String expiresOn(String date) {
    return 'expires $date';
  }

  @override
  String deleteAccountTitle(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get deleteAccountBody =>
      'This removes the account, its favorites and watch progress from this device. Your subscription with the provider isn’t affected.';

  @override
  String get accountDeleted => 'Account deleted';

  @override
  String get actionUndo => 'Undo';

  @override
  String get lastUsedNever => 'Not opened yet';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count h ago';
  }

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get kindXtream => 'XTREAM';

  @override
  String get kindM3u => 'M3U';

  @override
  String get kindFile => 'FILE';

  @override
  String get actionPlay => 'Play';

  @override
  String get actionResume => 'Resume';

  @override
  String get actionMoreInfo => 'More info';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionSeeAll => 'See all';

  @override
  String get actionAll => 'All';

  @override
  String get switchAccount => 'Switch account';

  @override
  String get homeContinue => 'Continue watching';

  @override
  String get homeLiveNow => 'Live now';

  @override
  String get homeAllChannels => 'All channels';

  @override
  String get homeRecentlyAdded => 'Recently added';

  @override
  String get homePopularMovies => 'Popular movies';

  @override
  String get homePopularSeries => 'Popular series';

  @override
  String get homeRecommended => 'Recommended for you';

  @override
  String get homeRecentlyWatched => 'Recently watched';

  @override
  String get homeFavorites => 'Your favorites';

  @override
  String get homeManage => 'Manage';

  @override
  String becauseYouWatched(String title) {
    return 'Because you watched $title';
  }

  @override
  String get topPicksTonight => 'Top picks for tonight';

  @override
  String get watched => 'Watched';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get searchHint => 'Channels, movies, series';

  @override
  String get searchHintLong => 'Search channels, movies, series';

  @override
  String seasonsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seasons',
      one: '1 season',
    );
    return '$_temp0';
  }

  @override
  String get homeEmptyTitle => 'Your library is loading';

  @override
  String get homeEmptyBody =>
      'Channels, movies and series appear here as soon as your playlist is ready.';

  @override
  String get moviesTitle => 'Movies';

  @override
  String get seriesTitle => 'Series';

  @override
  String get trending => 'Trending';

  @override
  String get topRated => 'Top rated';

  @override
  String get recommended => 'Recommended';

  @override
  String get popular => 'Popular';

  @override
  String get genres => 'Genres';

  @override
  String get featuredBadge => 'FEATURED';

  @override
  String get featuredSeries => 'Featured series';

  @override
  String get actionDetails => 'Details';

  @override
  String resumeEpisode(int season, int episode) {
    return 'Resume S$season · E$episode';
  }

  @override
  String seriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count series',
      one: '1 series',
    );
    return '$_temp0';
  }

  @override
  String moviesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count movies',
      one: '1 movie',
    );
    return '$_temp0';
  }

  @override
  String get gridView => 'Grid view';

  @override
  String get listView => 'List view';

  @override
  String get actionFilter => 'Filter';

  @override
  String get sortTitle => 'Sort by';

  @override
  String get sortPlaylist => 'Playlist order';

  @override
  String get sortRecent => 'Recently watched';

  @override
  String get sortRating => 'Top rated';

  @override
  String get sortName => 'Name A–Z';

  @override
  String get emptyCategoryTitle => 'Nothing here yet';

  @override
  String get emptyCategoryBody => 'This category is empty in your playlist.';

  @override
  String resumeAt(String time) {
    return 'Resume · $time';
  }

  @override
  String get trailer => 'Trailer';

  @override
  String get favorited => 'Favorited';

  @override
  String get favorite => 'Favorite';

  @override
  String get share => 'Share';

  @override
  String get markWatched => 'Watched';

  @override
  String get markUnwatched => 'Mark unwatched';

  @override
  String get director => 'Director';

  @override
  String get castLabel => 'Cast';

  @override
  String get released => 'Released';

  @override
  String get cast => 'Cast';

  @override
  String get relatedMovies => 'Related movies';

  @override
  String get moreLikeThis => 'More like this';

  @override
  String get moreActions => 'More';

  @override
  String shareText(String title) {
    return '$title — I’m watching it on Orbix';
  }

  @override
  String seasonN(int n) {
    return 'Season $n';
  }

  @override
  String get episodesTitle => 'Episodes';

  @override
  String get upNext => 'Up next';

  @override
  String get continueWatchingShort => 'Continue watching';

  @override
  String episodeN(int n) {
    return 'Episode $n';
  }

  @override
  String minutesShort(int count) {
    return '$count min';
  }

  @override
  String playEpisode(int season, int episode) {
    return 'Play S$season · E$episode';
  }

  @override
  String episodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodes',
      one: '1 episode',
    );
    return '$_temp0';
  }

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get clearAll => 'Clear all';

  @override
  String get trendingSearches => 'Popular right now';

  @override
  String get browse => 'Browse';

  @override
  String get browseLive => 'Live channels';

  @override
  String get browseMovies => 'Movies';

  @override
  String get browseSeries => 'Series';

  @override
  String get browseFavorites => 'Favorites';

  @override
  String get filterMovies => 'Movies';

  @override
  String get filterSeries => 'Series';

  @override
  String get filterChannels => 'Channels';

  @override
  String get filterGenre => 'Genre';

  @override
  String get filterYear => 'Year';

  @override
  String allCount(int count) {
    return 'All · $count';
  }

  @override
  String typeCount(String type, int count) {
    return '$type · $count';
  }

  @override
  String get kindMovie => 'Movie';

  @override
  String get kindSeries => 'Series';

  @override
  String get liveNowLabel => 'Live now';

  @override
  String get searchChannels => 'Channels';

  @override
  String get searchTitles => 'Movies & series';

  @override
  String noResultsTitle(String query) {
    return 'No matches for “$query”';
  }

  @override
  String get noResultsBody =>
      'Check the spelling, or remove the filters to search everything.';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get listening => 'Listening…';

  @override
  String get voiceHint => 'Try “Pulse Sports 1” or “Comedy series”';

  @override
  String get tapToStop => 'Tap to stop';

  @override
  String get voiceUnavailable => 'Voice search isn’t available on this device.';

  @override
  String get voiceNoPermission =>
      'Microphone access is needed for voice search.';

  @override
  String get anyYear => 'Any year';

  @override
  String get anyGenre => 'Any genre';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get dragToReorder => 'Drag to reorder · tap − to remove';

  @override
  String get removeFavorite => 'Remove from favorites';

  @override
  String removedFromFavorites(String name) {
    return '$name removed from favorites';
  }

  @override
  String get noFavoritesTitle => 'Nothing saved yet';

  @override
  String get noFavoritesBody =>
      'Tap the heart on any channel, movie or series and it will wait for you here.';

  @override
  String get browseLiveTv => 'Browse Live TV';

  @override
  String endsAt(String time) {
    return 'ends $time';
  }

  @override
  String get liveTitle => 'Live TV';

  @override
  String get guide => 'Guide';

  @override
  String get allChannels => 'All channels';

  @override
  String get favoritesCategory => 'Favorites';

  @override
  String get lockedCategory => 'Locked';

  @override
  String nowAt(String range) {
    return 'Now · $range';
  }

  @override
  String nextAt(String time) {
    return 'Next · $time';
  }

  @override
  String channelNumber(String number) {
    return 'Channel $number';
  }

  @override
  String get lockedByParental => 'Locked by parental control';

  @override
  String get noGuideData => 'No guide data';

  @override
  String filterCategory(String name) {
    return 'Filter $name';
  }

  @override
  String get sortChannels => 'Sort channels';

  @override
  String get sortNumber => 'Channel number';

  @override
  String get sortFavoritesFirst => 'Favorites first';

  @override
  String get actionFullscreen => 'Full screen';

  @override
  String get actionMute => 'Mute';

  @override
  String get actionPip => 'Picture-in-picture';

  @override
  String get scheduleLater => 'Later';

  @override
  String get scheduleNow => 'Now';

  @override
  String get scheduleNext => 'Next';

  @override
  String get scheduleEnded => 'Ended';

  @override
  String get noChannelsTitle => 'No channels here';

  @override
  String get noChannelsBody =>
      'This category has no channels in your playlist.';

  @override
  String get tvGuideTitle => 'TV Guide';

  @override
  String get pickDate => 'Pick date';

  @override
  String get filterCategories => 'Filter categories';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get yesterdayShort => 'Yesterday';

  @override
  String get nowButton => 'Now';

  @override
  String get watchNow => 'Watch now';

  @override
  String get watch => 'Watch';

  @override
  String get onNow => 'ON NOW';

  @override
  String minLeft(int count) {
    return '$count min left';
  }

  @override
  String updatingPercent(int percent) {
    return 'Updating $percent%';
  }

  @override
  String get guideEmptyTitle => 'No guide data yet';

  @override
  String get guideEmptyBody =>
      'Your provider hasn’t sent a TV guide for these channels. Refresh, or add an EPG URL to the account.';

  @override
  String get refreshGuide => 'Refresh guide';

  @override
  String get allCategories => 'All categories';

  @override
  String categoriesSummary(String first, int more) {
    return '$first +$more';
  }

  @override
  String guideSources(int count, String days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sources',
      one: '1 source',
    );
    return 'Guide data from $_temp0 · $days';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get searchSettings => 'Search settings';

  @override
  String get activeBadge => 'ACTIVE';

  @override
  String catalogCounts(String channels, String movies, String series) {
    return '$channels channels · $movies movies · $series series';
  }

  @override
  String get refreshLists => 'Refresh lists';

  @override
  String get refreshingLists => 'Refreshing lists…';

  @override
  String get sectionGeneral => 'General';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get startScreen => 'Start screen';

  @override
  String get autoplayNext => 'Auto-play next episode';

  @override
  String get autoplayNextHint => 'Starts after a 10 s countdown';

  @override
  String get sectionPlayback => 'Playback & player';

  @override
  String get preferredPlayer => 'Preferred player';

  @override
  String get orbixPlayer => 'Orbix Player';

  @override
  String get hardwareDecoding => 'Hardware decoding';

  @override
  String get hardwareDecodingHint => 'Smoother 4K, lower battery use';

  @override
  String get audioLanguage => 'Audio language';

  @override
  String get audioLanguageHint => 'Tap in order of preference';

  @override
  String audioLanguagesValue(String first, String second) {
    return '$first, then $second';
  }

  @override
  String get subtitleSettings => 'Subtitle settings';

  @override
  String get subtitleSize => 'Size';

  @override
  String get subtitleStyle => 'Style';

  @override
  String get sizeSmall => 'Small';

  @override
  String get sizeMedium => 'Medium';

  @override
  String get sizeLarge => 'Large';

  @override
  String get styleOutline => 'outline';

  @override
  String get styleShadow => 'shadow';

  @override
  String get styleBox => 'box';

  @override
  String get defaultQuality => 'Default quality';

  @override
  String get qualityAuto => 'Auto';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeAmoled => 'AMOLED black';

  @override
  String get themeSystem => 'System';

  @override
  String get sectionGuide => 'TV guide (EPG)';

  @override
  String get epgSources => 'EPG sources';

  @override
  String epgSourcesValue(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Provider + $count',
      zero: 'Provider',
    );
    return '$_temp0';
  }

  @override
  String get epgSourcesNone => 'None';

  @override
  String get providerGuide => 'From your provider';

  @override
  String get yourGuide => 'Your EPG URL';

  @override
  String get epgRefresh => 'EPG refresh';

  @override
  String lastUpdated(Object when) {
    return 'Last updated $when';
  }

  @override
  String get neverUpdated => 'Not downloaded yet';

  @override
  String everyHours(num hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'Every $hours h',
      one: 'Every hour',
    );
    return '$_temp0';
  }

  @override
  String get guideShift => 'Guide time shift';

  @override
  String shiftHours(Object value) {
    return '$value h';
  }

  @override
  String get sectionPlaylist => 'Playlist';

  @override
  String get autoUpdatePlaylist => 'Auto-update playlist';

  @override
  String get autoUpdatePlaylistHint => 'On launch, at most once a day';

  @override
  String get sectionSecurity => 'Security & accounts';

  @override
  String get parentalControls => 'Parental controls';

  @override
  String parentalSummaryOn(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'PIN on · $count categories locked',
      one: 'PIN on · 1 category locked',
      zero: 'PIN on',
    );
    return '$_temp0';
  }

  @override
  String get parentalSummaryOff => 'Off — set a PIN to lock content';

  @override
  String get manageAccounts => 'Manage IPTV accounts';

  @override
  String get sectionStorage => 'Storage';

  @override
  String get cache => 'Cache';

  @override
  String cacheBreakdown(String artwork, String guide, String lists) {
    return 'Artwork $artwork · Guide $guide · Lists $lists';
  }

  @override
  String get clearCache => 'Clear cache';

  @override
  String get clearCacheTitle => 'Clear cache?';

  @override
  String get clearCacheBody =>
      'Artwork and the TV guide are downloaded again when needed. Accounts, favorites and progress are kept.';

  @override
  String get cacheCleared => 'Cache cleared';

  @override
  String get sectionAbout => 'About';

  @override
  String get version => 'Version';

  @override
  String get legalNotice => 'Legal notice';

  @override
  String get legalNoticeBody =>
      'Orbix is a media player only. It does not provide, host or sell channels, movies or series. Use it only with services you are authorized to access.';

  @override
  String noSettingsMatch(Object query) {
    return 'No settings match “$query”';
  }

  @override
  String get actionSave => 'Save';

  @override
  String get langArabic => 'Arabic';

  @override
  String get langEnglish => 'English';

  @override
  String get langFrench => 'French';

  @override
  String get langSpanish => 'Spanish';

  @override
  String get langGerman => 'German';

  @override
  String get langTurkish => 'Turkish';

  @override
  String get parentalTitle => 'Parental controls';

  @override
  String get protectionOn => 'Protection is on';

  @override
  String get protectionOnBody =>
      'PIN needed for locked categories, channels and these settings.';

  @override
  String get protectionOff => 'Protection is off';

  @override
  String get protectionOffBody =>
      'Turn on PIN protection to lock categories and channels.';

  @override
  String get pinProtection => 'PIN protection';

  @override
  String pinSetOn(Object date) {
    return '4-digit PIN · set $date';
  }

  @override
  String get pinNotSet => 'No PIN set';

  @override
  String get changePin => 'Change PIN';

  @override
  String get adultProtection => 'Adult content protection';

  @override
  String get adultProtectionHint => 'Hide 18+ titles and categories everywhere';

  @override
  String get relockAfter => 'Re-lock after';

  @override
  String minutesN(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String get lockedCategories => 'Locked categories';

  @override
  String lockedOfTotal(int locked, int total) {
    return '$locked of $total';
  }

  @override
  String get lockLocked => 'Locked';

  @override
  String get lockOpen => 'Open';

  @override
  String get toggleLock => 'Toggle lock';

  @override
  String channelsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count channels',
      one: '1 channel',
    );
    return '$_temp0';
  }

  @override
  String hiddenSuffix(Object count) {
    return '$count · hidden';
  }

  @override
  String get lockedChannels => 'Locked channels';

  @override
  String get actionAdd => 'Add';

  @override
  String get noLockedChannels => 'No locked channels yet';

  @override
  String get unlockChannel => 'Unlock channel';

  @override
  String get lockChannelTitle => 'Lock a channel';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get createPin => 'Create a 4-digit PIN';

  @override
  String get confirmPin => 'Enter it again';

  @override
  String get newPin => 'Enter a new PIN';

  @override
  String isLocked(Object name) {
    return '$name is locked';
  }

  @override
  String get contentLocked => 'This content is locked';

  @override
  String get parentalLocked => 'Parental settings are locked';

  @override
  String get wrongPin => 'Wrong PIN. Try again.';

  @override
  String get pinsDontMatch => 'PINs didn\'t match. Start again.';

  @override
  String tryAgainIn(Object seconds) {
    return 'Too many tries. Wait $seconds s.';
  }

  @override
  String get forgotPin => 'Forgot PIN?';

  @override
  String get forgotPinHint => 'Reset it with your IPTV account password';

  @override
  String pinDigitsEntered(Object count) {
    return '$count of 4 digits entered';
  }

  @override
  String get a11yDelete => 'Delete';

  @override
  String get pinSaved => 'PIN saved';

  @override
  String get pinRemoved => 'PIN protection turned off';

  @override
  String get resetPinTitle => 'Reset PIN';

  @override
  String resetPinBody(Object account) {
    return 'Enter the password of “$account” to turn PIN protection off.';
  }

  @override
  String get resetPinNoPassword =>
      'This account has no password. Remove and add the account again to reset the PIN.';

  @override
  String get actionReset => 'Reset';

  @override
  String get wrongPassword => 'That password doesn\'t match.';

  @override
  String lastUpdatedToday(Object time) {
    return 'Last updated today, $time';
  }

  @override
  String get accountKindXtream => 'Xtream Codes';

  @override
  String get accountKindM3u => 'M3U playlist';

  @override
  String get accountKindFile => 'Playlist file';

  @override
  String get a11ySubtitles => 'Subtitles';

  @override
  String get a11yAudioTrack => 'Audio track';

  @override
  String get a11yPlaybackSettings => 'Playback settings';

  @override
  String get a11yLockControls => 'Lock controls';

  @override
  String get a11yUnlockControls => 'Unlock controls';

  @override
  String get a11yPrevEpisode => 'Previous episode';

  @override
  String get a11yNextEpisode => 'Next episode';

  @override
  String get a11yBack10 => 'Back 10 seconds';

  @override
  String get a11yForward10 => 'Forward 10 seconds';

  @override
  String get a11yPause => 'Pause';

  @override
  String get a11yPlay => 'Play';

  @override
  String get a11yRotate => 'Rotate screen';

  @override
  String get a11yExitPlayer => 'Exit full screen';

  @override
  String get a11yEnterFullscreen => 'Full screen';

  @override
  String get a11yChannelUp => 'Channel up';

  @override
  String get a11yChannelDown => 'Channel down';

  @override
  String get a11yCloseChannels => 'Close channel list';

  @override
  String get a11yBrightness => 'Brightness';

  @override
  String get a11yVolume => 'Volume';

  @override
  String get a11ySeek => 'Seek';

  @override
  String get aspectFit => 'Fit';

  @override
  String get aspectFill => 'Fill';

  @override
  String get aspectZoom => 'Zoom';

  @override
  String get aspect169 => '16:9';

  @override
  String get subtitlesOff => 'Off';

  @override
  String get playbackSettings => 'Playback settings';

  @override
  String get audioTrackTitle => 'Audio track';

  @override
  String get subtitlesTitle => 'Subtitles';

  @override
  String get sizeAndStyle => 'Size & style';

  @override
  String get playbackSpeed => 'Playback speed';

  @override
  String get videoQuality => 'Video quality';

  @override
  String get aspectRatio => 'Aspect ratio';

  @override
  String qualityNow(Object quality) {
    return '$quality NOW';
  }

  @override
  String pausedAt(Object time) {
    return 'Paused · $time';
  }

  @override
  String playingAt(Object time) {
    return 'Playing · $time';
  }

  @override
  String get changesApply =>
      'Changes apply instantly. Your audio and subtitle languages and subtitle style are remembered.';

  @override
  String get audioMono => 'Mono';

  @override
  String get audioStereo => 'Stereo';

  @override
  String audioSurround(Object layout) {
    return '$layout Surround';
  }

  @override
  String trackN(Object n) {
    return 'Track $n';
  }

  @override
  String get channelsChip => 'Channels';

  @override
  String upNextIn(Object seconds) {
    return 'Up next in $seconds';
  }

  @override
  String get playNow => 'Play now';

  @override
  String episodeShort(int season, int episode) {
    return 'S$season · E$episode';
  }

  @override
  String get playbackFailedTitle => 'Can\'t play this stream';

  @override
  String get playbackFailedBody =>
      'The provider didn\'t send a playable stream. It may be offline, busy or not allowed on this connection.';

  @override
  String seekBackLabel(Object seconds) {
    return '−$seconds s';
  }

  @override
  String seekForwardLabel(Object seconds) {
    return '+$seconds s';
  }

  @override
  String get pipUnavailable =>
      'Picture-in-picture isn\'t available on this device';

  @override
  String get goLive => 'LIVE';

  @override
  String get behindLive => 'Back to live';

  @override
  String durationHours(Object hours) {
    return '${hours}h';
  }

  @override
  String durationHoursMinutes(int hours, String minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String timeLeft(Object time) {
    return '$time left';
  }

  @override
  String get offlineBanner => 'No connection';

  @override
  String get networkSettings => 'Network settings';

  @override
  String get retryingAutomatically => 'Retrying automatically';

  @override
  String get retryNow => 'Retry now';

  @override
  String get statusLabel => 'Status';

  @override
  String get statusExpired => 'Expired';

  @override
  String get statusDisabled => 'Disabled';

  @override
  String get refreshStatus => 'Refresh status';

  @override
  String get useAnotherAccount => 'Use another account';

  @override
  String get signInFailedTitle => 'Sign-in no longer works';

  @override
  String noResultsFiltered(Object filter) {
    return 'Check the spelling, or remove the $filter filter to search everything.';
  }

  @override
  String get addedToFavorites => 'Added to favorites';

  @override
  String playlistUpdated(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Playlist updated · $count new channels',
      one: 'Playlist updated · 1 new channel',
    );
    return '$_temp0';
  }

  @override
  String get streamUnavailable => 'Stream unavailable';

  @override
  String cacheClearedFreed(Object size) {
    return 'Cache cleared · $size freed';
  }

  @override
  String get reconnectingStream => 'Reconnecting to stream…';

  @override
  String get controlsLockedTap => 'Controls locked · tap to unlock';
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Orbix'**
  String get appTitle;

  /// Bottom nav / rail
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navLive.
  ///
  /// In en, this message translates to:
  /// **'Live TV'**
  String get navLive;

  /// Rail only (≥600dp)
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get navGuide;

  /// No description provided for @navMovies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get navMovies;

  /// No description provided for @navSeries.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get navSeries;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// Bottom nav — opens Settings
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Rail only (≥600dp)
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Dev-only preview screen title
  ///
  /// In en, this message translates to:
  /// **'Design foundations'**
  String get devFoundations;

  /// Dev-only gallery screen title
  ///
  /// In en, this message translates to:
  /// **'Component gallery'**
  String get devGallery;

  /// Live badge; AR from HomeAR/LiveTVAR
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get badgeLive;

  /// New-content badge; AR from HomeAR
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get badgeNew;

  /// Parental-lock badge. AR not in reference screens — needs review
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get badgePin;

  /// Screen-reader labels (a11y*). AR versions not in reference screens — need review
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get a11yLoading;

  /// No description provided for @a11yNowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now playing'**
  String get a11yNowPlaying;

  /// No description provided for @a11yLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get a11yLocked;

  /// No description provided for @a11yAddFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get a11yAddFavorite;

  /// No description provided for @a11yRemoveFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get a11yRemoveFavorite;

  /// No description provided for @a11yShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get a11yShowPassword;

  /// No description provided for @a11yHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get a11yHidePassword;

  /// No description provided for @a11yClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get a11yClear;

  /// No description provided for @a11yVoiceSearch.
  ///
  /// In en, this message translates to:
  /// **'Voice search'**
  String get a11yVoiceSearch;

  /// No description provided for @a11yDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get a11yDismiss;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Every stream you own, in one orbit.'**
  String get splashTagline;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading your library'**
  String get splashLoading;

  /// No description provided for @playerOnlyNotice.
  ///
  /// In en, this message translates to:
  /// **'Orbix is a media player. It does not include channels or content.'**
  String get playerOnlyNotice;

  /// No description provided for @actionSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get actionSkip;

  /// No description provided for @actionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get actionNext;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @actionGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get actionGetStarted;

  /// No description provided for @onboardingStep.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String onboardingStep(int step, int total);

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Connect your own IPTV service'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Body.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Xtream Codes, an M3U link or a playlist file. Orbix plays what your provider gives you — it never supplies content itself.'**
  String get onboarding1Body;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Live TV, movies and series together'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Body.
  ///
  /// In en, this message translates to:
  /// **'Flip channels with a full TV guide, then jump into films and box sets. Everything from your playlist, organized and fast.'**
  String get onboarding2Body;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'Keep favorites. Resume to the second.'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Body.
  ///
  /// In en, this message translates to:
  /// **'Heart any channel, movie or series. Progress is saved on this device, so every title opens exactly where you stopped.'**
  String get onboarding3Body;

  /// No description provided for @onboardingXtreamCard.
  ///
  /// In en, this message translates to:
  /// **'Xtream Codes'**
  String get onboardingXtreamCard;

  /// No description provided for @onboardingOnline.
  ///
  /// In en, this message translates to:
  /// **'ONLINE'**
  String get onboardingOnline;

  /// No description provided for @onboardingM3uChip.
  ///
  /// In en, this message translates to:
  /// **'M3U playlist'**
  String get onboardingM3uChip;

  /// No description provided for @onboardingEpgChip.
  ///
  /// In en, this message translates to:
  /// **'EPG guide'**
  String get onboardingEpgChip;

  /// No description provided for @onboardingFileChip.
  ///
  /// In en, this message translates to:
  /// **'Local .m3u file'**
  String get onboardingFileChip;

  /// No description provided for @onboardingCardCaption.
  ///
  /// In en, this message translates to:
  /// **'Living Room · 1,284 channels'**
  String get onboardingCardCaption;

  /// No description provided for @onboardingResume.
  ///
  /// In en, this message translates to:
  /// **'Resume S3 · E4 “Ash on the Avenue”'**
  String get onboardingResume;

  /// No description provided for @onboardingMinLeft.
  ///
  /// In en, this message translates to:
  /// **'18 min left'**
  String get onboardingMinLeft;

  /// No description provided for @onboardingFavorites.
  ///
  /// In en, this message translates to:
  /// **'favorites'**
  String get onboardingFavorites;

  /// No description provided for @addAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Add IPTV account'**
  String get addAccountTitle;

  /// No description provided for @addAccountIntro.
  ///
  /// In en, this message translates to:
  /// **'Use a service you are authorized to access. Orbix doesn’t sell or provide channels.'**
  String get addAccountIntro;

  /// No description provided for @savedProfiles.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 saved profile} other{{count} saved profiles}}'**
  String savedProfiles(int count);

  /// No description provided for @sourceXtream.
  ///
  /// In en, this message translates to:
  /// **'Xtream'**
  String get sourceXtream;

  /// No description provided for @sourceM3u.
  ///
  /// In en, this message translates to:
  /// **'M3U'**
  String get sourceM3u;

  /// No description provided for @sourceFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get sourceFile;

  /// No description provided for @fieldAccountName.
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get fieldAccountName;

  /// No description provided for @fieldServerUrl.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get fieldServerUrl;

  /// No description provided for @fieldUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get fieldUsername;

  /// No description provided for @fieldPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get fieldPassword;

  /// No description provided for @fieldPlaylistName.
  ///
  /// In en, this message translates to:
  /// **'Playlist name'**
  String get fieldPlaylistName;

  /// No description provided for @fieldM3uUrl.
  ///
  /// In en, this message translates to:
  /// **'M3U playlist URL'**
  String get fieldM3uUrl;

  /// No description provided for @fieldEpgUrlXmltv.
  ///
  /// In en, this message translates to:
  /// **'EPG URL (XMLTV)'**
  String get fieldEpgUrlXmltv;

  /// No description provided for @epgOptionalTitle.
  ///
  /// In en, this message translates to:
  /// **'EPG URL'**
  String get epgOptionalTitle;

  /// No description provided for @epgOptionalTag.
  ///
  /// In en, this message translates to:
  /// **'· optional'**
  String get epgOptionalTag;

  /// No description provided for @epgOptionalHint.
  ///
  /// In en, this message translates to:
  /// **'Uses your provider’s guide when empty'**
  String get epgOptionalHint;

  /// No description provided for @saveProfileEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Save as profile · stored encrypted on this device'**
  String get saveProfileEncrypted;

  /// No description provided for @actionTest.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get actionTest;

  /// No description provided for @actionConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get actionConnect;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionEditDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit details'**
  String get actionEditDetails;

  /// No description provided for @actionTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionTryAgain;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @chooseLocalFile.
  ///
  /// In en, this message translates to:
  /// **'Choose a local file'**
  String get chooseLocalFile;

  /// No description provided for @chooseLocalFileHint.
  ///
  /// In en, this message translates to:
  /// **'.m3u or .m3u8 from this device'**
  String get chooseLocalFileHint;

  /// No description provided for @testingConnection.
  ///
  /// In en, this message translates to:
  /// **'Testing connection…'**
  String get testingConnection;

  /// No description provided for @testingHint.
  ///
  /// In en, this message translates to:
  /// **'Usually takes under 10 seconds'**
  String get testingHint;

  /// No description provided for @testPassed.
  ///
  /// In en, this message translates to:
  /// **'Connection works'**
  String get testPassed;

  /// No description provided for @testPassedHint.
  ///
  /// In en, this message translates to:
  /// **'Everything checks out — tap Connect to save.'**
  String get testPassedHint;

  /// No description provided for @testFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t connect'**
  String get testFailed;

  /// No description provided for @stepReach.
  ///
  /// In en, this message translates to:
  /// **'Server reachable'**
  String get stepReach;

  /// No description provided for @stepSignIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get stepSignIn;

  /// No description provided for @stepDownload.
  ///
  /// In en, this message translates to:
  /// **'Playlist downloaded'**
  String get stepDownload;

  /// No description provided for @stepRead.
  ///
  /// In en, this message translates to:
  /// **'Reading channels & VOD'**
  String get stepRead;

  /// No description provided for @stepGuide.
  ///
  /// In en, this message translates to:
  /// **'Guide data (EPG)'**
  String get stepGuide;

  /// No description provided for @stepWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get stepWaiting;

  /// No description provided for @stepSkipped.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get stepSkipped;

  /// No description provided for @stepGuideBroken.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get stepGuideBroken;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @invalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid URL'**
  String get invalidUrl;

  /// No description provided for @useDemoProvider.
  ///
  /// In en, this message translates to:
  /// **'Use demo provider (debug)'**
  String get useDemoProvider;

  /// No description provided for @errorOffline.
  ///
  /// In en, this message translates to:
  /// **'You’re offline'**
  String get errorOffline;

  /// No description provided for @errorOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'Check Wi‑Fi or mobile data. Orbix reconnects on its own as soon as you’re back.'**
  String get errorOfflineBody;

  /// No description provided for @errorHostNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t find this server. Check the URL and port.'**
  String get errorHostNotFound;

  /// No description provided for @errorRefused.
  ///
  /// In en, this message translates to:
  /// **'The server refused the connection. Check the port.'**
  String get errorRefused;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Server isn’t responding'**
  String get errorTimeout;

  /// No description provided for @errorTimeoutBody.
  ///
  /// In en, this message translates to:
  /// **'{host} didn’t answer within 10 seconds. This is usually temporary on the provider’s side.'**
  String errorTimeoutBody(String host);

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'The provider’s server has a problem (error {code}). Try again later.'**
  String errorServer(int code);

  /// No description provided for @errorAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'The provider refused access (error {code}). Your IP or app may be blocked.'**
  String errorAccessDenied(int code);

  /// No description provided for @errorCredentials.
  ///
  /// In en, this message translates to:
  /// **'Username or password is incorrect. Check the details from your provider and try again.'**
  String get errorCredentials;

  /// No description provided for @errorExpired.
  ///
  /// In en, this message translates to:
  /// **'This account has expired'**
  String get errorExpired;

  /// No description provided for @errorExpiredBody.
  ///
  /// In en, this message translates to:
  /// **'Your provider reports that “{name}” ended on {date}. Renew it with your provider, then refresh here.'**
  String errorExpiredBody(String name, String date);

  /// No description provided for @errorExpiredShort.
  ///
  /// In en, this message translates to:
  /// **'This subscription has expired.'**
  String get errorExpiredShort;

  /// No description provided for @errorDisabled.
  ///
  /// In en, this message translates to:
  /// **'The provider has disabled this account ({status}).'**
  String errorDisabled(String status);

  /// No description provided for @errorNotIptv.
  ///
  /// In en, this message translates to:
  /// **'This address doesn’t look like an IPTV server.'**
  String get errorNotIptv;

  /// No description provided for @errorPlaylist.
  ///
  /// In en, this message translates to:
  /// **'This isn’t a valid M3U playlist.'**
  String get errorPlaylist;

  /// No description provided for @errorGuide.
  ///
  /// In en, this message translates to:
  /// **'The guide couldn’t be read.'**
  String get errorGuide;

  /// No description provided for @errorTls.
  ///
  /// In en, this message translates to:
  /// **'Secure connection failed (certificate problem).'**
  String get errorTls;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorUnknown;

  /// No description provided for @passwordsCaseSensitive.
  ///
  /// In en, this message translates to:
  /// **'Passwords are case-sensitive'**
  String get passwordsCaseSensitive;

  /// No description provided for @loadingPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Loading your playlist'**
  String get loadingPlaylist;

  /// No description provided for @loadingPlaylistBody.
  ///
  /// In en, this message translates to:
  /// **'Live TV is ready first — movies and series keep loading in the background.'**
  String get loadingPlaylistBody;

  /// No description provided for @sectionChannels.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get sectionChannels;

  /// No description provided for @sectionMovies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get sectionMovies;

  /// No description provided for @sectionSeries.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get sectionSeries;

  /// No description provided for @watchLiveNow.
  ///
  /// In en, this message translates to:
  /// **'Watch Live TV now'**
  String get watchLiveNow;

  /// No description provided for @allSetTitle.
  ///
  /// In en, this message translates to:
  /// **'You’re all set'**
  String get allSetTitle;

  /// No description provided for @allSetBody.
  ///
  /// In en, this message translates to:
  /// **'“{name}” is connected and saved on this device.'**
  String allSetBody(String name);

  /// No description provided for @statLive.
  ///
  /// In en, this message translates to:
  /// **'Live channels'**
  String get statLive;

  /// No description provided for @statMovies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get statMovies;

  /// No description provided for @statSeries.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get statSeries;

  /// No description provided for @statGuide.
  ///
  /// In en, this message translates to:
  /// **'TV guide'**
  String get statGuide;

  /// No description provided for @guideDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String guideDays(int count);

  /// No description provided for @startWatching.
  ///
  /// In en, this message translates to:
  /// **'Start watching'**
  String get startWatching;

  /// No description provided for @profilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose an account'**
  String get profilesTitle;

  /// No description provided for @profilesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your IPTV profiles on this device'**
  String get profilesSubtitle;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @addAccount.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get addAccount;

  /// No description provided for @addAccountTypes.
  ///
  /// In en, this message translates to:
  /// **'Xtream · M3U'**
  String get addAccountTypes;

  /// No description provided for @editAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit account'**
  String get editAccount;

  /// No description provided for @setAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as default'**
  String get setAsDefault;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @openDefaultOnLaunch.
  ///
  /// In en, this message translates to:
  /// **'Open default account on launch'**
  String get openDefaultOnLaunch;

  /// No description provided for @openDefaultOnLaunchHint.
  ///
  /// In en, this message translates to:
  /// **'Skip this screen next time'**
  String get openDefaultOnLaunchHint;

  /// No description provided for @continueWith.
  ///
  /// In en, this message translates to:
  /// **'Continue with {name}'**
  String continueWith(String name);

  /// No description provided for @expiresOn.
  ///
  /// In en, this message translates to:
  /// **'expires {date}'**
  String expiresOn(String date);

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String deleteAccountTitle(String name);

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the account, its favorites and watch progress from this device. Your subscription with the provider isn’t affected.'**
  String get deleteAccountBody;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get accountDeleted;

  /// No description provided for @actionUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actionUndo;

  /// No description provided for @lastUsedNever.
  ///
  /// In en, this message translates to:
  /// **'Not opened yet'**
  String get lastUsedNever;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} h ago'**
  String hoursAgo(int count);

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// No description provided for @kindXtream.
  ///
  /// In en, this message translates to:
  /// **'XTREAM'**
  String get kindXtream;

  /// No description provided for @kindM3u.
  ///
  /// In en, this message translates to:
  /// **'M3U'**
  String get kindM3u;

  /// No description provided for @kindFile.
  ///
  /// In en, this message translates to:
  /// **'FILE'**
  String get kindFile;

  /// No description provided for @actionPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get actionPlay;

  /// No description provided for @actionResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get actionResume;

  /// No description provided for @actionMoreInfo.
  ///
  /// In en, this message translates to:
  /// **'More info'**
  String get actionMoreInfo;

  /// No description provided for @actionSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get actionSearch;

  /// No description provided for @actionSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get actionSeeAll;

  /// No description provided for @actionAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get actionAll;

  /// No description provided for @switchAccount.
  ///
  /// In en, this message translates to:
  /// **'Switch account'**
  String get switchAccount;

  /// No description provided for @homeContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue watching'**
  String get homeContinue;

  /// No description provided for @homeLiveNow.
  ///
  /// In en, this message translates to:
  /// **'Live now'**
  String get homeLiveNow;

  /// No description provided for @homeAllChannels.
  ///
  /// In en, this message translates to:
  /// **'All channels'**
  String get homeAllChannels;

  /// No description provided for @homeRecentlyAdded.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get homeRecentlyAdded;

  /// No description provided for @homePopularMovies.
  ///
  /// In en, this message translates to:
  /// **'Popular movies'**
  String get homePopularMovies;

  /// No description provided for @homePopularSeries.
  ///
  /// In en, this message translates to:
  /// **'Popular series'**
  String get homePopularSeries;

  /// No description provided for @homeRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get homeRecommended;

  /// No description provided for @homeRecentlyWatched.
  ///
  /// In en, this message translates to:
  /// **'Recently watched'**
  String get homeRecentlyWatched;

  /// No description provided for @homeFavorites.
  ///
  /// In en, this message translates to:
  /// **'Your favorites'**
  String get homeFavorites;

  /// No description provided for @homeManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get homeManage;

  /// No description provided for @becauseYouWatched.
  ///
  /// In en, this message translates to:
  /// **'Because you watched {title}'**
  String becauseYouWatched(String title);

  /// No description provided for @topPicksTonight.
  ///
  /// In en, this message translates to:
  /// **'Top picks for tonight'**
  String get topPicksTonight;

  /// No description provided for @watched.
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get watched;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Channels, movies, series'**
  String get searchHint;

  /// No description provided for @searchHintLong.
  ///
  /// In en, this message translates to:
  /// **'Search channels, movies, series'**
  String get searchHintLong;

  /// No description provided for @seasonsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 season} other{{count} seasons}}'**
  String seasonsCount(int count);

  /// No description provided for @homeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your library is loading'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Channels, movies and series appear here as soon as your playlist is ready.'**
  String get homeEmptyBody;

  /// No description provided for @moviesTitle.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get moviesTitle;

  /// No description provided for @seriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get seriesTitle;

  /// No description provided for @trending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get trending;

  /// No description provided for @topRated.
  ///
  /// In en, this message translates to:
  /// **'Top rated'**
  String get topRated;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @genres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get genres;

  /// No description provided for @featuredBadge.
  ///
  /// In en, this message translates to:
  /// **'FEATURED'**
  String get featuredBadge;

  /// No description provided for @featuredSeries.
  ///
  /// In en, this message translates to:
  /// **'Featured series'**
  String get featuredSeries;

  /// No description provided for @actionDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get actionDetails;

  /// No description provided for @resumeEpisode.
  ///
  /// In en, this message translates to:
  /// **'Resume S{season} · E{episode}'**
  String resumeEpisode(int season, int episode);

  /// No description provided for @seriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 series} other{{count} series}}'**
  String seriesCount(int count);

  /// No description provided for @moviesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 movie} other{{count} movies}}'**
  String moviesCount(int count);

  /// No description provided for @gridView.
  ///
  /// In en, this message translates to:
  /// **'Grid view'**
  String get gridView;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List view'**
  String get listView;

  /// No description provided for @actionFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get actionFilter;

  /// No description provided for @sortTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortTitle;

  /// No description provided for @sortPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Playlist order'**
  String get sortPlaylist;

  /// No description provided for @sortRecent.
  ///
  /// In en, this message translates to:
  /// **'Recently watched'**
  String get sortRecent;

  /// No description provided for @sortRating.
  ///
  /// In en, this message translates to:
  /// **'Top rated'**
  String get sortRating;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name A–Z'**
  String get sortName;

  /// No description provided for @emptyCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyCategoryTitle;

  /// No description provided for @emptyCategoryBody.
  ///
  /// In en, this message translates to:
  /// **'This category is empty in your playlist.'**
  String get emptyCategoryBody;

  /// No description provided for @resumeAt.
  ///
  /// In en, this message translates to:
  /// **'Resume · {time}'**
  String resumeAt(String time);

  /// No description provided for @trailer.
  ///
  /// In en, this message translates to:
  /// **'Trailer'**
  String get trailer;

  /// No description provided for @favorited.
  ///
  /// In en, this message translates to:
  /// **'Favorited'**
  String get favorited;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @markWatched.
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get markWatched;

  /// No description provided for @markUnwatched.
  ///
  /// In en, this message translates to:
  /// **'Mark unwatched'**
  String get markUnwatched;

  /// No description provided for @director.
  ///
  /// In en, this message translates to:
  /// **'Director'**
  String get director;

  /// No description provided for @castLabel.
  ///
  /// In en, this message translates to:
  /// **'Cast'**
  String get castLabel;

  /// No description provided for @released.
  ///
  /// In en, this message translates to:
  /// **'Released'**
  String get released;

  /// No description provided for @cast.
  ///
  /// In en, this message translates to:
  /// **'Cast'**
  String get cast;

  /// No description provided for @relatedMovies.
  ///
  /// In en, this message translates to:
  /// **'Related movies'**
  String get relatedMovies;

  /// No description provided for @moreLikeThis.
  ///
  /// In en, this message translates to:
  /// **'More like this'**
  String get moreLikeThis;

  /// No description provided for @moreActions.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreActions;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'{title} — I’m watching it on Orbix'**
  String shareText(String title);

  /// No description provided for @seasonN.
  ///
  /// In en, this message translates to:
  /// **'Season {n}'**
  String seasonN(int n);

  /// No description provided for @episodesTitle.
  ///
  /// In en, this message translates to:
  /// **'Episodes'**
  String get episodesTitle;

  /// No description provided for @upNext.
  ///
  /// In en, this message translates to:
  /// **'Up next'**
  String get upNext;

  /// No description provided for @continueWatchingShort.
  ///
  /// In en, this message translates to:
  /// **'Continue watching'**
  String get continueWatchingShort;

  /// No description provided for @episodeN.
  ///
  /// In en, this message translates to:
  /// **'Episode {n}'**
  String episodeN(int n);

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minutesShort(int count);

  /// No description provided for @playEpisode.
  ///
  /// In en, this message translates to:
  /// **'Play S{season} · E{episode}'**
  String playEpisode(int season, int episode);

  /// No description provided for @episodesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 episode} other{{count} episodes}}'**
  String episodesCount(int count);

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @trendingSearches.
  ///
  /// In en, this message translates to:
  /// **'Popular right now'**
  String get trendingSearches;

  /// No description provided for @browse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browse;

  /// No description provided for @browseLive.
  ///
  /// In en, this message translates to:
  /// **'Live channels'**
  String get browseLive;

  /// No description provided for @browseMovies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get browseMovies;

  /// No description provided for @browseSeries.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get browseSeries;

  /// No description provided for @browseFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get browseFavorites;

  /// No description provided for @filterMovies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get filterMovies;

  /// No description provided for @filterSeries.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get filterSeries;

  /// No description provided for @filterChannels.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get filterChannels;

  /// No description provided for @filterGenre.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get filterGenre;

  /// No description provided for @filterYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get filterYear;

  /// No description provided for @allCount.
  ///
  /// In en, this message translates to:
  /// **'All · {count}'**
  String allCount(int count);

  /// No description provided for @typeCount.
  ///
  /// In en, this message translates to:
  /// **'{type} · {count}'**
  String typeCount(String type, int count);

  /// No description provided for @kindMovie.
  ///
  /// In en, this message translates to:
  /// **'Movie'**
  String get kindMovie;

  /// No description provided for @kindSeries.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get kindSeries;

  /// No description provided for @liveNowLabel.
  ///
  /// In en, this message translates to:
  /// **'Live now'**
  String get liveNowLabel;

  /// No description provided for @searchChannels.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get searchChannels;

  /// No description provided for @searchTitles.
  ///
  /// In en, this message translates to:
  /// **'Movies & series'**
  String get searchTitles;

  /// No description provided for @noResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches for “{query}”'**
  String noResultsTitle(String query);

  /// No description provided for @noResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Check the spelling, or remove the filters to search everything.'**
  String get noResultsBody;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get listening;

  /// No description provided for @voiceHint.
  ///
  /// In en, this message translates to:
  /// **'Try “Pulse Sports 1” or “Comedy series”'**
  String get voiceHint;

  /// No description provided for @tapToStop.
  ///
  /// In en, this message translates to:
  /// **'Tap to stop'**
  String get tapToStop;

  /// No description provided for @voiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Voice search isn’t available on this device.'**
  String get voiceUnavailable;

  /// No description provided for @voiceNoPermission.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is needed for voice search.'**
  String get voiceNoPermission;

  /// No description provided for @anyYear.
  ///
  /// In en, this message translates to:
  /// **'Any year'**
  String get anyYear;

  /// No description provided for @anyGenre.
  ///
  /// In en, this message translates to:
  /// **'Any genre'**
  String get anyGenre;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @dragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder · tap − to remove'**
  String get dragToReorder;

  /// No description provided for @removeFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFavorite;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'{name} removed from favorites'**
  String removedFromFavorites(String name);

  /// No description provided for @noFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet'**
  String get noFavoritesTitle;

  /// No description provided for @noFavoritesBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on any channel, movie or series and it will wait for you here.'**
  String get noFavoritesBody;

  /// No description provided for @browseLiveTv.
  ///
  /// In en, this message translates to:
  /// **'Browse Live TV'**
  String get browseLiveTv;

  /// No description provided for @endsAt.
  ///
  /// In en, this message translates to:
  /// **'ends {time}'**
  String endsAt(String time);

  /// No description provided for @liveTitle.
  ///
  /// In en, this message translates to:
  /// **'Live TV'**
  String get liveTitle;

  /// No description provided for @guide.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get guide;

  /// No description provided for @allChannels.
  ///
  /// In en, this message translates to:
  /// **'All channels'**
  String get allChannels;

  /// No description provided for @favoritesCategory.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesCategory;

  /// No description provided for @lockedCategory.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get lockedCategory;

  /// No description provided for @nowAt.
  ///
  /// In en, this message translates to:
  /// **'Now · {range}'**
  String nowAt(String range);

  /// No description provided for @nextAt.
  ///
  /// In en, this message translates to:
  /// **'Next · {time}'**
  String nextAt(String time);

  /// No description provided for @channelNumber.
  ///
  /// In en, this message translates to:
  /// **'Channel {number}'**
  String channelNumber(String number);

  /// No description provided for @lockedByParental.
  ///
  /// In en, this message translates to:
  /// **'Locked by parental control'**
  String get lockedByParental;

  /// No description provided for @noGuideData.
  ///
  /// In en, this message translates to:
  /// **'No guide data'**
  String get noGuideData;

  /// No description provided for @filterCategory.
  ///
  /// In en, this message translates to:
  /// **'Filter {name}'**
  String filterCategory(String name);

  /// No description provided for @sortChannels.
  ///
  /// In en, this message translates to:
  /// **'Sort channels'**
  String get sortChannels;

  /// No description provided for @sortNumber.
  ///
  /// In en, this message translates to:
  /// **'Channel number'**
  String get sortNumber;

  /// No description provided for @sortFavoritesFirst.
  ///
  /// In en, this message translates to:
  /// **'Favorites first'**
  String get sortFavoritesFirst;

  /// No description provided for @actionFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Full screen'**
  String get actionFullscreen;

  /// No description provided for @actionMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get actionMute;

  /// No description provided for @actionPip.
  ///
  /// In en, this message translates to:
  /// **'Picture-in-picture'**
  String get actionPip;

  /// No description provided for @scheduleLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get scheduleLater;

  /// No description provided for @scheduleNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get scheduleNow;

  /// No description provided for @scheduleNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get scheduleNext;

  /// No description provided for @scheduleEnded.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get scheduleEnded;

  /// No description provided for @noChannelsTitle.
  ///
  /// In en, this message translates to:
  /// **'No channels here'**
  String get noChannelsTitle;

  /// No description provided for @noChannelsBody.
  ///
  /// In en, this message translates to:
  /// **'This category has no channels in your playlist.'**
  String get noChannelsBody;

  /// No description provided for @tvGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'TV Guide'**
  String get tvGuideTitle;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick date'**
  String get pickDate;

  /// No description provided for @filterCategories.
  ///
  /// In en, this message translates to:
  /// **'Filter categories'**
  String get filterCategories;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @yesterdayShort.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterdayShort;

  /// No description provided for @nowButton.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get nowButton;

  /// No description provided for @watchNow.
  ///
  /// In en, this message translates to:
  /// **'Watch now'**
  String get watchNow;

  /// No description provided for @watch.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get watch;

  /// No description provided for @onNow.
  ///
  /// In en, this message translates to:
  /// **'ON NOW'**
  String get onNow;

  /// No description provided for @minLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} min left'**
  String minLeft(int count);

  /// No description provided for @updatingPercent.
  ///
  /// In en, this message translates to:
  /// **'Updating {percent}%'**
  String updatingPercent(int percent);

  /// No description provided for @guideEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No guide data yet'**
  String get guideEmptyTitle;

  /// No description provided for @guideEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Your provider hasn’t sent a TV guide for these channels. Refresh, or add an EPG URL to the account.'**
  String get guideEmptyBody;

  /// No description provided for @refreshGuide.
  ///
  /// In en, this message translates to:
  /// **'Refresh guide'**
  String get refreshGuide;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @categoriesSummary.
  ///
  /// In en, this message translates to:
  /// **'{first} +{more}'**
  String categoriesSummary(String first, int more);

  /// No description provided for @guideSources.
  ///
  /// In en, this message translates to:
  /// **'Guide data from {count, plural, =1{1 source} other{{count} sources}} · {days}'**
  String guideSources(int count, String days);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @searchSettings.
  ///
  /// In en, this message translates to:
  /// **'Search settings'**
  String get searchSettings;

  /// No description provided for @activeBadge.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get activeBadge;

  /// No description provided for @catalogCounts.
  ///
  /// In en, this message translates to:
  /// **'{channels} channels · {movies} movies · {series} series'**
  String catalogCounts(String channels, String movies, String series);

  /// No description provided for @refreshLists.
  ///
  /// In en, this message translates to:
  /// **'Refresh lists'**
  String get refreshLists;

  /// No description provided for @refreshingLists.
  ///
  /// In en, this message translates to:
  /// **'Refreshing lists…'**
  String get refreshingLists;

  /// No description provided for @sectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get sectionGeneral;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @startScreen.
  ///
  /// In en, this message translates to:
  /// **'Start screen'**
  String get startScreen;

  /// No description provided for @autoplayNext.
  ///
  /// In en, this message translates to:
  /// **'Auto-play next episode'**
  String get autoplayNext;

  /// No description provided for @autoplayNextHint.
  ///
  /// In en, this message translates to:
  /// **'Starts after a 10 s countdown'**
  String get autoplayNextHint;

  /// No description provided for @sectionPlayback.
  ///
  /// In en, this message translates to:
  /// **'Playback & player'**
  String get sectionPlayback;

  /// No description provided for @preferredPlayer.
  ///
  /// In en, this message translates to:
  /// **'Preferred player'**
  String get preferredPlayer;

  /// No description provided for @orbixPlayer.
  ///
  /// In en, this message translates to:
  /// **'Orbix Player'**
  String get orbixPlayer;

  /// No description provided for @hardwareDecoding.
  ///
  /// In en, this message translates to:
  /// **'Hardware decoding'**
  String get hardwareDecoding;

  /// No description provided for @hardwareDecodingHint.
  ///
  /// In en, this message translates to:
  /// **'Smoother 4K, lower battery use'**
  String get hardwareDecodingHint;

  /// No description provided for @audioLanguage.
  ///
  /// In en, this message translates to:
  /// **'Audio language'**
  String get audioLanguage;

  /// No description provided for @audioLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'Tap in order of preference'**
  String get audioLanguageHint;

  /// No description provided for @audioLanguagesValue.
  ///
  /// In en, this message translates to:
  /// **'{first}, then {second}'**
  String audioLanguagesValue(String first, String second);

  /// No description provided for @subtitleSettings.
  ///
  /// In en, this message translates to:
  /// **'Subtitle settings'**
  String get subtitleSettings;

  /// No description provided for @subtitleSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get subtitleSize;

  /// No description provided for @subtitleStyle.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get subtitleStyle;

  /// No description provided for @sizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get sizeSmall;

  /// No description provided for @sizeMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get sizeMedium;

  /// No description provided for @sizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get sizeLarge;

  /// No description provided for @styleOutline.
  ///
  /// In en, this message translates to:
  /// **'outline'**
  String get styleOutline;

  /// No description provided for @styleShadow.
  ///
  /// In en, this message translates to:
  /// **'shadow'**
  String get styleShadow;

  /// No description provided for @styleBox.
  ///
  /// In en, this message translates to:
  /// **'box'**
  String get styleBox;

  /// No description provided for @defaultQuality.
  ///
  /// In en, this message translates to:
  /// **'Default quality'**
  String get defaultQuality;

  /// No description provided for @qualityAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get qualityAuto;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeAmoled.
  ///
  /// In en, this message translates to:
  /// **'AMOLED black'**
  String get themeAmoled;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @sectionGuide.
  ///
  /// In en, this message translates to:
  /// **'TV guide (EPG)'**
  String get sectionGuide;

  /// No description provided for @epgSources.
  ///
  /// In en, this message translates to:
  /// **'EPG sources'**
  String get epgSources;

  /// No description provided for @epgSourcesValue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Provider} other{Provider + {count}}}'**
  String epgSourcesValue(num count);

  /// No description provided for @epgSourcesNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get epgSourcesNone;

  /// No description provided for @providerGuide.
  ///
  /// In en, this message translates to:
  /// **'From your provider'**
  String get providerGuide;

  /// No description provided for @yourGuide.
  ///
  /// In en, this message translates to:
  /// **'Your EPG URL'**
  String get yourGuide;

  /// No description provided for @epgRefresh.
  ///
  /// In en, this message translates to:
  /// **'EPG refresh'**
  String get epgRefresh;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated {when}'**
  String lastUpdated(Object when);

  /// No description provided for @neverUpdated.
  ///
  /// In en, this message translates to:
  /// **'Not downloaded yet'**
  String get neverUpdated;

  /// No description provided for @everyHours.
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, =1{Every hour} other{Every {hours} h}}'**
  String everyHours(num hours);

  /// No description provided for @guideShift.
  ///
  /// In en, this message translates to:
  /// **'Guide time shift'**
  String get guideShift;

  /// No description provided for @shiftHours.
  ///
  /// In en, this message translates to:
  /// **'{value} h'**
  String shiftHours(Object value);

  /// No description provided for @sectionPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get sectionPlaylist;

  /// No description provided for @autoUpdatePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Auto-update playlist'**
  String get autoUpdatePlaylist;

  /// No description provided for @autoUpdatePlaylistHint.
  ///
  /// In en, this message translates to:
  /// **'On launch, at most once a day'**
  String get autoUpdatePlaylistHint;

  /// No description provided for @sectionSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security & accounts'**
  String get sectionSecurity;

  /// No description provided for @parentalControls.
  ///
  /// In en, this message translates to:
  /// **'Parental controls'**
  String get parentalControls;

  /// No description provided for @parentalSummaryOn.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{PIN on} =1{PIN on · 1 category locked} other{PIN on · {count} categories locked}}'**
  String parentalSummaryOn(num count);

  /// No description provided for @parentalSummaryOff.
  ///
  /// In en, this message translates to:
  /// **'Off — set a PIN to lock content'**
  String get parentalSummaryOff;

  /// No description provided for @manageAccounts.
  ///
  /// In en, this message translates to:
  /// **'Manage IPTV accounts'**
  String get manageAccounts;

  /// No description provided for @sectionStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get sectionStorage;

  /// No description provided for @cache.
  ///
  /// In en, this message translates to:
  /// **'Cache'**
  String get cache;

  /// No description provided for @cacheBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Artwork {artwork} · Guide {guide} · Lists {lists}'**
  String cacheBreakdown(String artwork, String guide, String lists);

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get clearCache;

  /// No description provided for @clearCacheTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear cache?'**
  String get clearCacheTitle;

  /// No description provided for @clearCacheBody.
  ///
  /// In en, this message translates to:
  /// **'Artwork and the TV guide are downloaded again when needed. Accounts, favorites and progress are kept.'**
  String get clearCacheBody;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared'**
  String get cacheCleared;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get sectionAbout;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @legalNotice.
  ///
  /// In en, this message translates to:
  /// **'Legal notice'**
  String get legalNotice;

  /// No description provided for @legalNoticeBody.
  ///
  /// In en, this message translates to:
  /// **'Orbix is a media player only. It does not provide, host or sell channels, movies or series. Use it only with services you are authorized to access.'**
  String get legalNoticeBody;

  /// No description provided for @noSettingsMatch.
  ///
  /// In en, this message translates to:
  /// **'No settings match “{query}”'**
  String noSettingsMatch(Object query);

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @langArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get langArabic;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get langFrench;

  /// No description provided for @langSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get langSpanish;

  /// No description provided for @langGerman.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get langGerman;

  /// No description provided for @langTurkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get langTurkish;

  /// No description provided for @parentalTitle.
  ///
  /// In en, this message translates to:
  /// **'Parental controls'**
  String get parentalTitle;

  /// No description provided for @protectionOn.
  ///
  /// In en, this message translates to:
  /// **'Protection is on'**
  String get protectionOn;

  /// No description provided for @protectionOnBody.
  ///
  /// In en, this message translates to:
  /// **'PIN needed for locked categories, channels and these settings.'**
  String get protectionOnBody;

  /// No description provided for @protectionOff.
  ///
  /// In en, this message translates to:
  /// **'Protection is off'**
  String get protectionOff;

  /// No description provided for @protectionOffBody.
  ///
  /// In en, this message translates to:
  /// **'Turn on PIN protection to lock categories and channels.'**
  String get protectionOffBody;

  /// No description provided for @pinProtection.
  ///
  /// In en, this message translates to:
  /// **'PIN protection'**
  String get pinProtection;

  /// No description provided for @pinSetOn.
  ///
  /// In en, this message translates to:
  /// **'4-digit PIN · set {date}'**
  String pinSetOn(Object date);

  /// No description provided for @pinNotSet.
  ///
  /// In en, this message translates to:
  /// **'No PIN set'**
  String get pinNotSet;

  /// No description provided for @changePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// No description provided for @adultProtection.
  ///
  /// In en, this message translates to:
  /// **'Adult content protection'**
  String get adultProtection;

  /// No description provided for @adultProtectionHint.
  ///
  /// In en, this message translates to:
  /// **'Hide 18+ titles and categories everywhere'**
  String get adultProtectionHint;

  /// No description provided for @relockAfter.
  ///
  /// In en, this message translates to:
  /// **'Re-lock after'**
  String get relockAfter;

  /// No description provided for @minutesN.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute} other{{count} minutes}}'**
  String minutesN(num count);

  /// No description provided for @lockedCategories.
  ///
  /// In en, this message translates to:
  /// **'Locked categories'**
  String get lockedCategories;

  /// No description provided for @lockedOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{locked} of {total}'**
  String lockedOfTotal(int locked, int total);

  /// No description provided for @lockLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get lockLocked;

  /// No description provided for @lockOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get lockOpen;

  /// No description provided for @toggleLock.
  ///
  /// In en, this message translates to:
  /// **'Toggle lock'**
  String get toggleLock;

  /// No description provided for @channelsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 channel} other{{count} channels}}'**
  String channelsCount(num count);

  /// No description provided for @hiddenSuffix.
  ///
  /// In en, this message translates to:
  /// **'{count} · hidden'**
  String hiddenSuffix(Object count);

  /// No description provided for @lockedChannels.
  ///
  /// In en, this message translates to:
  /// **'Locked channels'**
  String get lockedChannels;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @noLockedChannels.
  ///
  /// In en, this message translates to:
  /// **'No locked channels yet'**
  String get noLockedChannels;

  /// No description provided for @unlockChannel.
  ///
  /// In en, this message translates to:
  /// **'Unlock channel'**
  String get unlockChannel;

  /// No description provided for @lockChannelTitle.
  ///
  /// In en, this message translates to:
  /// **'Lock a channel'**
  String get lockChannelTitle;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPin;

  /// No description provided for @createPin.
  ///
  /// In en, this message translates to:
  /// **'Create a 4-digit PIN'**
  String get createPin;

  /// No description provided for @confirmPin.
  ///
  /// In en, this message translates to:
  /// **'Enter it again'**
  String get confirmPin;

  /// No description provided for @newPin.
  ///
  /// In en, this message translates to:
  /// **'Enter a new PIN'**
  String get newPin;

  /// No description provided for @isLocked.
  ///
  /// In en, this message translates to:
  /// **'{name} is locked'**
  String isLocked(Object name);

  /// No description provided for @contentLocked.
  ///
  /// In en, this message translates to:
  /// **'This content is locked'**
  String get contentLocked;

  /// No description provided for @parentalLocked.
  ///
  /// In en, this message translates to:
  /// **'Parental settings are locked'**
  String get parentalLocked;

  /// No description provided for @wrongPin.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN. Try again.'**
  String get wrongPin;

  /// No description provided for @pinsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'PINs didn\'t match. Start again.'**
  String get pinsDontMatch;

  /// No description provided for @tryAgainIn.
  ///
  /// In en, this message translates to:
  /// **'Too many tries. Wait {seconds} s.'**
  String tryAgainIn(Object seconds);

  /// No description provided for @forgotPin.
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN?'**
  String get forgotPin;

  /// No description provided for @forgotPinHint.
  ///
  /// In en, this message translates to:
  /// **'Reset it with your IPTV account password'**
  String get forgotPinHint;

  /// No description provided for @pinDigitsEntered.
  ///
  /// In en, this message translates to:
  /// **'{count} of 4 digits entered'**
  String pinDigitsEntered(Object count);

  /// No description provided for @a11yDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get a11yDelete;

  /// No description provided for @pinSaved.
  ///
  /// In en, this message translates to:
  /// **'PIN saved'**
  String get pinSaved;

  /// No description provided for @pinRemoved.
  ///
  /// In en, this message translates to:
  /// **'PIN protection turned off'**
  String get pinRemoved;

  /// No description provided for @resetPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset PIN'**
  String get resetPinTitle;

  /// No description provided for @resetPinBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the password of “{account}” to turn PIN protection off.'**
  String resetPinBody(Object account);

  /// No description provided for @resetPinNoPassword.
  ///
  /// In en, this message translates to:
  /// **'This account has no password. Remove and add the account again to reset the PIN.'**
  String get resetPinNoPassword;

  /// No description provided for @actionReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get actionReset;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'That password doesn\'t match.'**
  String get wrongPassword;

  /// No description provided for @lastUpdatedToday.
  ///
  /// In en, this message translates to:
  /// **'Last updated today, {time}'**
  String lastUpdatedToday(Object time);

  /// No description provided for @accountKindXtream.
  ///
  /// In en, this message translates to:
  /// **'Xtream Codes'**
  String get accountKindXtream;

  /// No description provided for @accountKindM3u.
  ///
  /// In en, this message translates to:
  /// **'M3U playlist'**
  String get accountKindM3u;

  /// No description provided for @accountKindFile.
  ///
  /// In en, this message translates to:
  /// **'Playlist file'**
  String get accountKindFile;

  /// No description provided for @a11ySubtitles.
  ///
  /// In en, this message translates to:
  /// **'Subtitles'**
  String get a11ySubtitles;

  /// No description provided for @a11yAudioTrack.
  ///
  /// In en, this message translates to:
  /// **'Audio track'**
  String get a11yAudioTrack;

  /// No description provided for @a11yPlaybackSettings.
  ///
  /// In en, this message translates to:
  /// **'Playback settings'**
  String get a11yPlaybackSettings;

  /// No description provided for @a11yLockControls.
  ///
  /// In en, this message translates to:
  /// **'Lock controls'**
  String get a11yLockControls;

  /// No description provided for @a11yUnlockControls.
  ///
  /// In en, this message translates to:
  /// **'Unlock controls'**
  String get a11yUnlockControls;

  /// No description provided for @a11yPrevEpisode.
  ///
  /// In en, this message translates to:
  /// **'Previous episode'**
  String get a11yPrevEpisode;

  /// No description provided for @a11yNextEpisode.
  ///
  /// In en, this message translates to:
  /// **'Next episode'**
  String get a11yNextEpisode;

  /// No description provided for @a11yBack10.
  ///
  /// In en, this message translates to:
  /// **'Back 10 seconds'**
  String get a11yBack10;

  /// No description provided for @a11yForward10.
  ///
  /// In en, this message translates to:
  /// **'Forward 10 seconds'**
  String get a11yForward10;

  /// No description provided for @a11yPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get a11yPause;

  /// No description provided for @a11yPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get a11yPlay;

  /// No description provided for @a11yRotate.
  ///
  /// In en, this message translates to:
  /// **'Rotate screen'**
  String get a11yRotate;

  /// No description provided for @a11yExitPlayer.
  ///
  /// In en, this message translates to:
  /// **'Exit full screen'**
  String get a11yExitPlayer;

  /// No description provided for @a11yChannelUp.
  ///
  /// In en, this message translates to:
  /// **'Channel up'**
  String get a11yChannelUp;

  /// No description provided for @a11yChannelDown.
  ///
  /// In en, this message translates to:
  /// **'Channel down'**
  String get a11yChannelDown;

  /// No description provided for @a11yCloseChannels.
  ///
  /// In en, this message translates to:
  /// **'Close channel list'**
  String get a11yCloseChannels;

  /// No description provided for @a11yBrightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get a11yBrightness;

  /// No description provided for @a11yVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get a11yVolume;

  /// No description provided for @a11ySeek.
  ///
  /// In en, this message translates to:
  /// **'Seek'**
  String get a11ySeek;

  /// No description provided for @aspectFit.
  ///
  /// In en, this message translates to:
  /// **'Fit'**
  String get aspectFit;

  /// No description provided for @aspectFill.
  ///
  /// In en, this message translates to:
  /// **'Fill'**
  String get aspectFill;

  /// No description provided for @aspectZoom.
  ///
  /// In en, this message translates to:
  /// **'Zoom'**
  String get aspectZoom;

  /// No description provided for @aspect169.
  ///
  /// In en, this message translates to:
  /// **'16:9'**
  String get aspect169;

  /// No description provided for @subtitlesOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get subtitlesOff;

  /// No description provided for @playbackSettings.
  ///
  /// In en, this message translates to:
  /// **'Playback settings'**
  String get playbackSettings;

  /// No description provided for @audioTrackTitle.
  ///
  /// In en, this message translates to:
  /// **'Audio track'**
  String get audioTrackTitle;

  /// No description provided for @subtitlesTitle.
  ///
  /// In en, this message translates to:
  /// **'Subtitles'**
  String get subtitlesTitle;

  /// No description provided for @sizeAndStyle.
  ///
  /// In en, this message translates to:
  /// **'Size & style'**
  String get sizeAndStyle;

  /// No description provided for @playbackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Playback speed'**
  String get playbackSpeed;

  /// No description provided for @videoQuality.
  ///
  /// In en, this message translates to:
  /// **'Video quality'**
  String get videoQuality;

  /// No description provided for @aspectRatio.
  ///
  /// In en, this message translates to:
  /// **'Aspect ratio'**
  String get aspectRatio;

  /// No description provided for @qualityNow.
  ///
  /// In en, this message translates to:
  /// **'{quality} NOW'**
  String qualityNow(Object quality);

  /// No description provided for @pausedAt.
  ///
  /// In en, this message translates to:
  /// **'Paused · {time}'**
  String pausedAt(Object time);

  /// No description provided for @playingAt.
  ///
  /// In en, this message translates to:
  /// **'Playing · {time}'**
  String playingAt(Object time);

  /// No description provided for @changesApply.
  ///
  /// In en, this message translates to:
  /// **'Changes apply instantly. Your audio and subtitle languages and subtitle style are remembered.'**
  String get changesApply;

  /// No description provided for @audioMono.
  ///
  /// In en, this message translates to:
  /// **'Mono'**
  String get audioMono;

  /// No description provided for @audioStereo.
  ///
  /// In en, this message translates to:
  /// **'Stereo'**
  String get audioStereo;

  /// No description provided for @audioSurround.
  ///
  /// In en, this message translates to:
  /// **'{layout} Surround'**
  String audioSurround(Object layout);

  /// No description provided for @trackN.
  ///
  /// In en, this message translates to:
  /// **'Track {n}'**
  String trackN(Object n);

  /// No description provided for @channelsChip.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get channelsChip;

  /// No description provided for @upNextIn.
  ///
  /// In en, this message translates to:
  /// **'Up next in {seconds}'**
  String upNextIn(Object seconds);

  /// No description provided for @playNow.
  ///
  /// In en, this message translates to:
  /// **'Play now'**
  String get playNow;

  /// No description provided for @episodeShort.
  ///
  /// In en, this message translates to:
  /// **'S{season} · E{episode}'**
  String episodeShort(int season, int episode);

  /// No description provided for @playbackFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Can\'t play this stream'**
  String get playbackFailedTitle;

  /// No description provided for @playbackFailedBody.
  ///
  /// In en, this message translates to:
  /// **'The provider didn\'t send a playable stream. It may be offline, busy or not allowed on this connection.'**
  String get playbackFailedBody;

  /// No description provided for @seekBackLabel.
  ///
  /// In en, this message translates to:
  /// **'−{seconds} s'**
  String seekBackLabel(Object seconds);

  /// No description provided for @seekForwardLabel.
  ///
  /// In en, this message translates to:
  /// **'+{seconds} s'**
  String seekForwardLabel(Object seconds);

  /// No description provided for @pipUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Picture-in-picture isn\'t available on this device'**
  String get pipUnavailable;

  /// No description provided for @goLive.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get goLive;

  /// No description provided for @behindLive.
  ///
  /// In en, this message translates to:
  /// **'Back to live'**
  String get behindLive;

  /// No description provided for @durationHours.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String durationHours(Object hours);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHoursMinutes(int hours, String minutes);

  /// No description provided for @timeLeft.
  ///
  /// In en, this message translates to:
  /// **'{time} left'**
  String timeLeft(Object time);

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get offlineBanner;

  /// No description provided for @networkSettings.
  ///
  /// In en, this message translates to:
  /// **'Network settings'**
  String get networkSettings;

  /// No description provided for @retryingAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Retrying automatically'**
  String get retryingAutomatically;

  /// No description provided for @retryNow.
  ///
  /// In en, this message translates to:
  /// **'Retry now'**
  String get retryNow;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @statusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get statusExpired;

  /// No description provided for @statusDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get statusDisabled;

  /// No description provided for @refreshStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh status'**
  String get refreshStatus;

  /// No description provided for @useAnotherAccount.
  ///
  /// In en, this message translates to:
  /// **'Use another account'**
  String get useAnotherAccount;

  /// No description provided for @signInFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign-in no longer works'**
  String get signInFailedTitle;

  /// No description provided for @noResultsFiltered.
  ///
  /// In en, this message translates to:
  /// **'Check the spelling, or remove the {filter} filter to search everything.'**
  String noResultsFiltered(Object filter);

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get addedToFavorites;

  /// No description provided for @playlistUpdated.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Playlist updated · 1 new channel} other{Playlist updated · {count} new channels}}'**
  String playlistUpdated(num count);

  /// No description provided for @streamUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Stream unavailable'**
  String get streamUnavailable;

  /// No description provided for @cacheClearedFreed.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared · {size} freed'**
  String cacheClearedFreed(Object size);

  /// No description provided for @reconnectingStream.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting to stream…'**
  String get reconnectingStream;

  /// No description provided for @controlsLockedTap.
  ///
  /// In en, this message translates to:
  /// **'Controls locked · tap to unlock'**
  String get controlsLockedTap;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

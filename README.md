# Orbix

Cinematic IPTV **player** for Android phones, foldables and tablets (Flutter).
Orbix never provides content — users connect their own Xtream Codes / M3U / EPG sources.

Design spec: [`orbix-design-handoff/`](orbix-design-handoff/README.md) (35 HTML screens, `orbix.css`).

## Setup

```bash
flutter pub get
dart run build_runner build   # Riverpod + Drift codegen (*.g.dart)
flutter gen-l10n              # also runs automatically on build
flutter run                   # dev flavor (the default): includes the demo provider
```

Android 9+ (`minSdk 28`).

**Flavors.** `dev` (default) installs as `app.orbix.player.dev` ("Orbix Dev") and bundles
the demo provider with `assets/demo/` (a pubspec asset flavor). `prod` is the store app,
`app.orbix.player`, with neither. Gradle refuses to build `dev` in release mode, so a
plain `flutter build … --release` fails on purpose.

```bash
flutter build appbundle --release --flavor prod   # Play Store upload
flutter build apk --release --flavor prod         # sideloadable APK
```

**Release signing.** `android/key.properties` (git-ignored) points at the upload
keystore, kept outside the repo. Without it, release builds fall back to the debug key
and can't be uploaded. Back up the keystore and its password: Play updates must be
signed with the same key (or enrol in Play App Signing).

## Layout

```
lib/
  main.dart, app.dart        bootstrap (media_kit, edge-to-edge), MaterialApp.router
  core/design/               design system foundation — import design.dart
    tokens.dart              OxColors, OxRadius, OxSpace, OxSize, OxText, OxMotion, OxShadows
    typography.dart          OxTypography.en / .ar (Readex Pro + RTL rules)
    theme.dart               OrbixTheme.dark(locale), OxTokens extension, context.oxText
    icons/                   OxIcons (78, generated) + OxIcon widget
    motion.dart              reduce-motion helpers, page transition
    breakpoints.dart         OxWindowSize, oxVerticalHinge
  core/router/               go_router, StatefulShellRoute, AppDestination
  core/l10n/                 ARB files (en, ar), AppLocale provider
  shared/widgets/            component library (Components.dc.html) — import widgets.dart
  data/                      data layer — import data.dart
    core/                    failures (→ designed error states), lenient JSON, ids, Dio, isolates
    credentials/             AccountCredentials + CredentialStore (Keystore-encrypted)
    sources/xtream/          Xtream Codes client (player_api.php, URLs, short EPG)
    sources/m3u/             M3U parser + classifier, playlist downloader / file import
    sources/epg/             streaming XMLTV parser (isolate, gzip, filtered)
    db/                      Drift schema (accounts, catalog, favorites, progress, EPG, locks)
    repositories/            accounts, catalog sync + queries, library, EPG, parental, storage
    providers.dart           Riverpod wiring
  core/settings/, session/   AppSettings (prefs), active account, launch target, parental PIN
  features/                  one folder per screen group (README screen map):
    onboarding/ accounts/    splash, welcome, add account + sync, profiles
    home/ live/ guide/       home, Live TV (3-pane on tablets), TV guide (EPG)
    movies/ series/ search/  browse + details, search + voice
    favorites/ settings/     favorites (reorder), settings
    parental/                parental controls, PIN entry, PinGate
    player/                  PlayerEngine (media_kit / fake), PlaybackController, player
                             screen (VOD + live), settings & channel panels, live preview
    common/                  shared providers, tiles, navigation helpers
    dev/                     Foundations preview, component gallery, /dev/data, demo provider
tool/extract_icons.dart      regenerates icons from orbix.css
tool/launcher_icon/          renders the Android launcher icons from OxLogoMark
                             (`flutter test tool/launcher_icon/render_test.dart`)
```

**Demo provider (dev flavor only).** `features/dev/demo/` serves a fake Xtream server
(`demo.orbix.invalid`, demo/demo) with guide data anchored to "now" and the design
artwork. Add it from Add account › "Use demo provider". Tests use it through
`test/support/app_harness.dart`, which runs the real app with in-memory storage.
Onboarding illustrations live in `assets/onboarding/` so they ship in `prod`.

**Player.** The screen talks to a `PlayerEngine` (`features/player/engine.dart`):
`MediaKitEngine` in the app, `test/support/fake_engine.dart` in widget tests
(libmpv isn't available there). `PlaybackController` resolves the stream, resumes,
saves progress every 15 s and on exit, applies Settings (hardware decoding, audio
language order, remembered subtitle language, default quality), zaps channels and
runs the up-next countdown. Subtitles are drawn by Orbix, not media_kit, so each line
gets its own text direction (Arabic reads right-to-left) and the Settings size and style.
PiP and window brightness go through `MainActivity.kt` (`player_window.dart`).
- No `BackdropFilter` over video: re-blurring a frame that changes every 1/30 s
  stalls input and timers on mid-range tablets. Use `VideoGlass` (solid
  translucent fill) for overlays on the player.
- The dev flavor maps demo-provider streams to `assets/demo/demo_{vod,live}.mkv`
  (two audio tracks, English + Arabic subtitles) via `streamUrlRewriterProvider`.
- Debug builds draw Flutter errors on screen (`features/dev/debug_errors.dart`):
  some devices keep almost nothing in logcat.

**System states** (States.dc.html) all use `OxStateView` (emblem in a dashed orbit,
one sentence, one primary action). Where they live:
- 01 Home skeleton — `home_screen.dart` (`_homeLoadingProvider`).
- 02 / 11 playlist loading and success — `account_setup_screen.dart`.
- 03 guide updating badge + "Guide data from N sources" toast — `guide_screen.dart`.
- 04 empty search, 05 no favorites — their screens.
- 06–08 offline / server down / expired, disabled or rejected account —
  `features/common/account_problem.dart`, shown over the tabs by `AppShell`
  (Settings stays reachable). Connectivity: `core/network/connectivity.dart`
  (`onlineProvider`, overridable in tests). Offline or server-down only block when
  there is no cached catalog.
- 09 inline credential errors, 10 "Couldn't connect" sheet — `add_account_screen.dart`.
- 12 toasts — `showOxSnack` (root overlay, wrapped in a Material); favorites go
  through `toggleFavoriteWithFeedback`; player pills in `player_screen.dart`.

**Parental locks.** Locked categories / channels only apply once a PIN is set. Every
player route is wrapped in `PinGate`, so playback asks for the PIN wherever it starts;
`/settings/parental` is gated the same way. A correct PIN unlocks for the
"Re-lock after" window.

## Conventions

- **Tokens, not literals.** Colours, radii, spacing, durations come from `core/design`.
  Values that only exist in a component rule of `orbix.css` are added to `tokens.dart`
  under "Added from orbix.css".
- **Text styles** come from `context.oxText` (locale-aware), never from `OxText` directly
  in screens — Arabic swaps family, weights and line heights.
- **Icons**: `OxIcon(OxIcons.play)`. Directional glyphs (back, chevrons, backspace) mirror
  in RTL; media glyphs never do. After changing `orbix.css`:
  `dart run tool/extract_icons.dart`.
- **Strings** go in `lib/core/l10n/app_en.arb` + `app_ar.arb` from the start. A message
  with two or more placeholders needs `"@key": {"placeholders": …}` (gen-l10n otherwise
  orders the Dart parameters alphabetically); `test/core/l10n_parity_test.dart` checks
  this and en/ar parity. Arabic wording follows the `*AR` reference screens.
- **RTL**: layouts mirror, but the player transport row and seek bar, the PIN keypad
  and the EPG time grid stay left-to-right; media icons never mirror. Time ranges come
  from `Fmt.range` (LTR isolate); plots use `OxContentText.paragraph`. Digits are
  Western in every language (`configureDigits()`).
- **Playlist text** (channel names, programme / movie titles) renders with `OxContentText`:
  its own direction (a Latin title in the Arabic UI ellipsizes at its end), aligned to the
  layout start. Times, channel numbers, URLs: `textDirection: TextDirection.ltr`.
- **Interaction**: build controls on `OxPressable` (press scale, hover/focus, D-pad/Enter,
  disabled opacity, semantics) and show focus with `oxFocusRing`.
- **Floating nav**: inside the shell, bottom `MediaQuery.padding` already includes the
  bottom nav — let scroll views use it; toasts (`showOxSnack`) rise above it.
- **Motion** respects the system "Remove animations" setting (`context.reduceMotion`).
- Generated files: `*.g.dart` (build_runner), `lib/core/l10n/gen/` (gen-l10n),
  `ox_icons.data.dart` (extract_icons — not `.g.dart`, build_runner would delete it).

**Data layer rules**
- Secrets (passwords, playlist / guide URLs — they embed credentials) live only in
  `CredentialStore`; the database stores a display host. Backups are disabled in the manifest
  (Keystore-bound secrets can't be restored elsewhere).
- Heavy work (JSON lists, M3U, XMLTV) runs in isolates via `runInBackground` — never a closure
  `Isolate.run(() => …)` inside an async method. The database runs on its own isolate.
- Every network/parse error becomes an `OrbixFailure` subtype matching a designed state.
- Drift returns local `DateTime`s; compare instants (`isAfter`, `isAtSameMomentAs`).
- `/dev/data` runs an on-device self-test (Keystore, SQLite, M3U + XMLTV isolates).

Tests load the bundled fonts globally (`test/flutter_test_config.dart`), so layout tests
measure real text; `test/features/dev/gallery_test.dart` renders every component at four
widths in EN and AR and fails on any overflow.

Fonts (Unbounded, Manrope, Readex Pro) are bundled under `assets/fonts/` — SIL OFL 1.1.

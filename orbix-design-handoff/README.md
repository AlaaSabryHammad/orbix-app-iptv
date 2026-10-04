# Orbix — Design handoff (Android IPTV player)

> **عربي:** حط الفولدر ده جوه مشروعك، وافتح Claude Code، وانسخ البرومبت الموجود في `PROMPT.md`.

Orbix is an **IPTV player only**. It never provides, hosts or sells content — users connect their own Xtream Codes / M3U / EPG sources.

## What's in this folder

| Path | What it is |
|---|---|
| `design/screens/*.dc.html` | 35 screens. Static HTML + inline styles. Repeated data lives in the `<script type="text/x-dc">` block at the bottom of each file (`renderVals()` returns the demo data; `<sc-for list="{{x}}">` = a list, `<sc-if>` = a condition, `{{a.b}}` = a value). Treat them as **visual specs**, not code to port 1:1. |
| `design/orbix.css` | The design system: tokens in `:root`, typography classes, every component class, all icons (as SVG data URIs, `.i-*`), all keyframe animations. |
| `design/canvas.json` | Screen list, titles and sizes (phone 412×915 dp, landscape player 915×412, tablet 1280×800, foldable 884×1104, small phone 360×780). |
| `design/assets/` | Demo artwork: `p-*` posters (2:3), `b-*` backdrops (16:9), `e-*` episode thumbs, `c-*` cast. Demo only — the real app loads artwork from the user's playlist. |
| `flutter/orbix_tokens.dart` | The tokens already converted to Dart. |

## Screen map

| # | File | Screen | Notes |
|---|---|---|---|
| — | Foundations | Colors, type (EN + AR), spacing, radii, elevation, icons, motion, breakpoints | Source of truth for tokens |
| — | Components | Buttons, chips, badges, inputs, posters, channel rows, loaders, skeletons, nav bar/rail, dialog, sheet, snackbars | Build these as widgets first |
| — | States | Skeleton, playlist loading, EPG loading, empty search, no favorites, offline, server down, expired, wrong credentials, connection failed, success, toasts | |
| 01 | Main | Splash | Animated logo; auto-route to onboarding (first run) or last account |
| 02–04 | Onboarding1–3 | Onboarding | Skip → AddAccount |
| 05 | AddAccount | Add account · Xtream | Fields: name, server URL, username, password; optional EPG; Test / Connect |
| 06 | AddAccountM3U | Add account · M3U + live connection test | M3U URL, EPG URL, local file picker; step-by-step test progress |
| 07 | Profiles | Choose account | Grid of saved accounts, long-press menu (Edit / Set default / Delete), "Continue with …" one-tap resume |
| 08 | Home | Home | Hero + rails: Continue watching, Live now, Recently added, Popular movies, Popular series, Recommended, Recently watched, Favorites |
| 09 | Movies | Movies | Genre chips, featured carousel, trending, top rated (list), recently added (grid), recommended; grid/list toggle |
| 10 | MovieDetails | Movie details | Backdrop, poster, badges, resume, trailer/favorite/share/watched, cast, related, recommended, more like this |
| 11 | Series | Series | Featured, continue watching, popular, recently added, genres |
| 12 | SeriesDetails | Series details | Season selector, episodes with watched progress |
| 13–15 | Search, SearchResults, SearchVoice | Search | History, trending, filters, instant suggestions, voice sheet |
| 16 | Favorites | Favorites | Tabs Channels/Movies/Series, drag-to-reorder, remove + undo snackbar |
| 17 | LiveTV | Live TV (phone) | Preview player, now/next, category chips, channel list with now-playing indicator, locked channel |
| 18 | EPG | TV guide (phone) | Date selector, timeline (2.4 dp/min), current-time line, program sheet |
| 19 | PlayerVOD | Player · movie | All controls; brightness/volume gesture pills; scrub preview |
| 20 | PlayerLive | Player · live | Channel up/down, channel list panel, now/next, Guide |
| 21 | PlayerSettings | Player · tracks | Audio track, subtitles, speed, quality, aspect ratio |
| 22 | Settings | Settings | General, playback, appearance, EPG, playlist, security, storage, about |
| 23–24 | Parental, PinEntry | Parental control | PIN, adult filter, locked categories/channels, keypad |
| 25–27 | HomeAR, LiveTVAR, MovieDetailsAR | Arabic RTL | Mirroring reference |
| 28–30 | TabletHome, TabletLive, TabletEPG | 10″ tablet | Navigation rail; 3-pane Live TV; full guide (5 dp/min) |
| 31 | FoldableSeries | Foldable | Two panes split at the hinge |
| 32 | CompactHome | Small phone | Icon-only nav (label on active item) |

## Navigation

```
Splash → (first run) Onboarding 1→2→3 → AddAccount ⇄ AddAccountM3U → Profiles → Home
Splash → (returning user, default account set) → Home directly
Bottom nav (phone <600dp): Home · Live TV · Movies · Series · Favorites · Profile(Settings)
Nav rail (≥600dp): Home · Live TV · Guide · Movies · Series · Favorites · … Settings
Home hero Play → PlayerVOD;  More info → MovieDetails
Live TV row → PlayerLive;  Guide → EPG;  EPG block → PlayerLive
Locked item → PinEntry → content
```

## Design tokens (from `orbix.css :root`)

- **Ink (backgrounds):** 0 `#050507` · 1 `#08080B` (app bg) · 2 `#101015` (surface) · 3 `#17171E` (raised/inputs) · 4 `#20202A` (tonal) · 5 `#2C2C38` (pressed/selected)
- **Text:** 1 `#F5F1EB` · 2 `#B4B0BA` · 3 `#8E8A97`
- **Ember (primary):** `#FF7A3D`, hi `#FF9663`, text on ember `#1C0C04` (7.3:1), soft `rgba(255,122,61,.16)`
- **Halo (info/quality/time):** `#7CC4FF` · **Live badge:** `#C93F0E` (white text 5.0:1) · Success `#5BD69B` · Caution `#FFC65C` · Error `#FF6B6B`
- **Radii:** 6 / 10 / 14 / 20 / 28 / pill
- **Spacing:** 4-pt grid; phone gutter 20, tablet gutter 32
- **Fonts:** Unbounded 600 (display, titles on posters, numbers/times), Manrope 500–800 (UI), Readex Pro (all Arabic text)
- **Type scale:** hero 34–42 · display 28 · h1 22 · h2 18/800 · title 15/700 · body 14/500 · caption 11.5/600 · overline 11/800 +16% tracking (no tracking/uppercase in Arabic)
- **Motion:** fast 140ms · base 240ms · slow 420ms; ease-out `cubic-bezier(.2,.8,.2,1)`; spring `cubic-bezier(.34,1.56,.64,1)`

## Behaviour rules

- Min touch target 44 dp. Bottom nav floats 12 dp from the edges with a glass (blur 22) background.
- Active nav item = ember pill behind the icon + a small glowing ember dot above it.
- Posters: 2:3, radius 14, lift 4 dp + scale 1.03 on focus/hover, scale .97 on press.
- Progress bars: 3 dp, ember fill; in RTL they fill from the right.
- **RTL:** mirror layout, back arrows and chevrons; **never** mirror play/pause/seek/volume icons. Arabic uses Readex Pro with +15–25% line height and Western digits for times and channel numbers.
- Breakpoints: <600 dp bottom nav · 600–839 nav rail + two panes · ≥840 rail + three-pane Live TV.
- Respect the system "Remove animations" setting (fade-only fallback).
- Playback progress is stored locally per account and per item (resume to the second).

## Suggested Flutter stack

- State: Riverpod · Routing: go_router (ShellRoute for nav bar/rail)
- Player: `media_kit` (HLS/TS/live, tracks, subtitles, speed) — PiP via Android PictureInPicture
- Storage: Drift or Isar (accounts, favorites, progress, EPG cache) + `flutter_secure_storage` for credentials
- Networking: Dio. Xtream: `player_api.php?username=&password=&action=get_live_categories|get_live_streams|get_vod_streams|get_series|get_series_info|get_short_epg`. M3U: parse `#EXTINF` (tvg-id, tvg-logo, group-title). EPG: XMLTV parsing in an isolate.
- Images: `cached_network_image` with fade-in · Skeletons: custom shimmer matching `.sk`

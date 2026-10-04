# Prompt for Claude Code

انسخ النص اللي تحت ده والصقه في Claude Code بعد ما تحط الفولدر جوه المشروع.

---

Read `orbix-design-handoff/README.md` first, then the design files in `orbix-design-handoff/design/`
(35 screens as HTML specs, `orbix.css` = the design system, `assets/` = demo artwork).

We are building **Orbix**, an Android IPTV *player* (phones, foldables, tablets) in **Flutter**.
It never provides content; users add their own Xtream Codes / M3U / EPG sources.

Work in phases and stop for my review after each one:

1. **Foundation** — create the Flutter project structure (Riverpod, go_router, media_kit, Drift,
   flutter_secure_storage, Dio, cached_network_image). Use `flutter/orbix_tokens.dart` as the token
   source and build `OrbixTheme` (dark only), the 3 font families, and an icon set that matches the
   `.i-*` icons in orbix.css.
2. **Components** — implement every component in `Components.dc.html` as reusable widgets
   (buttons, icon buttons, chips, badges, poster card, thumb card, channel row/tile, inputs, search,
   switch, segmented, tabs, bottom nav, nav rail, dialog, bottom sheet, snackbar, skeletons, loaders)
   plus a widget gallery screen to preview them.
3. **Data layer** — Xtream API client, M3U parser, XMLTV EPG parser (in an isolate), local DB for
   accounts / favorites / watch progress / EPG cache, encrypted credentials.
4. **Screens** — build them in the order of the README screen map, matching spacing, sizes and
   colors from the HTML exactly. Adaptive layout: bottom nav <600dp, nav rail ≥600dp,
   two-pane on foldables, three-pane Live TV on tablets.
5. **Player** — PlayerVOD, PlayerLive, PlayerSettings with media_kit: tracks, subtitles, speed,
   quality, aspect ratio, lock, PiP, gestures, auto-hide controls, channel up/down.
6. **Arabic RTL** — full l10n (en, ar) using the *AR screens as reference. Do not mirror media icons.
7. **States** — every state in `States.dc.html`.

Start with phase 1 and show me the plan and folder structure before writing code.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/design.dart';
import '../../core/l10n/l10n.dart';
import '../../core/router/routes.dart';
import '../../core/session/session.dart';
import '../../core/settings/app_settings.dart';
import '../../data/data.dart';
import '../../shared/format/format.dart';
import '../../shared/widgets/widgets.dart';
import '../common/favorites.dart';
import '../common/providers.dart';
import '../live/live_providers.dart';
import 'engine.dart';
import 'playback_controller.dart';
import 'player_window.dart';
import 'widgets/channel_panel.dart';
import 'widgets/player_chrome.dart';
import 'widgets/scrub_bar.dart';
import 'widgets/settings_panel.dart';

enum _Panel { none, settings, channels }

enum _Drag { scrub, brightness, volume }

/// 19 PlayerVOD (movies, episodes) and 20 PlayerLive, with 21 PlayerSettings.
class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key, required this.target});

  final PlayTarget target;

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  late final PlaybackController _c;
  final _focus = FocusNode();

  bool _controls = true;
  Timer? _hideTimer;
  bool _locked = false;
  bool _lockHint = false;
  Timer? _lockHintTimer;
  _Panel _panel = _Panel.none;
  bool _resumeAfterPanel = false;
  AspectMode _aspect = AspectMode.fit;
  bool _portrait = false;
  bool _pip = false;
  bool? _autoPip;

  // Gestures.
  Offset? _gestureStart;
  _Drag? _drag;
  double _level = 0;
  double _levelStart = 0;
  Duration _scrubStart = Duration.zero;
  Duration? _scrubTo;
  bool _pinching = false;
  double _pinchScale = 1;
  Timer? _levelTimer;
  double _brightness = 0.5;
  (bool forward, int seconds)? _seek;
  Timer? _seekTimer;

  bool get _isPhone => MediaQuery.sizeOf(context).shortestSide < 600;

  @override
  void initState() {
    super.initState();
    _c = PlaybackController(ProviderScope.containerOf(context, listen: false), widget.target);
    _c.engine.state.addListener(_onEngine);
    PlayerWindow.inPip.addListener(_onPip);
    unawaited(PlayerWindow.enterImmersive());
    unawaited(PlayerWindow.brightness().then((b) => _brightness = b));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_isPhone) unawaited(PlayerWindow.setOrientations(PlayerWindow.landscape));
      _focus.requestFocus();
      _bump();
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _lockHintTimer?.cancel();
    _levelTimer?.cancel();
    _seekTimer?.cancel();
    _c.engine.state.removeListener(_onEngine);
    PlayerWindow.inPip.removeListener(_onPip);
    unawaited(PlayerWindow.setAutoPip(false));
    unawaited(PlayerWindow.setBrightness(null));
    unawaited(PlayerWindow.setOrientations(PlayerWindow.any));
    unawaited(PlayerWindow.exitImmersive());
    unawaited(_c.dispose());
    _focus.dispose();
    super.dispose();
  }

  void _onEngine() {
    final s = _c.engine.state.value;
    if (_autoPip != s.playing) {
      _autoPip = s.playing;
      unawaited(PlayerWindow.setAutoPip(s.playing, width: s.width, height: s.height));
    }
    if (s.playing && _controls && _hideTimer == null) _bump();
    // Once a picture has played, later buffering is a stall → "Reconnecting".
    final target = _c.item.value?.target;
    if (target != _playedTarget && s.playing && !s.buffering && s.width != null) setState(() => _playedTarget = target);
  }

  /// The item that has played at least once (for the reconnecting pill).
  PlayTarget? _playedTarget;

  void _onPip() => setState(() {
        _pip = PlayerWindow.inPip.value;
        // The PiP window is tiny: no panels, no chrome.
        if (_pip) _panel = _Panel.none;
      });

  /// Shows the controls and (re)starts the auto-hide timer.
  void _bump() {
    _hideTimer?.cancel();
    _hideTimer = null;
    if (!_controls) setState(() => _controls = true);
    if (!mounted || _panel != _Panel.none) return;
    _hideTimer = Timer(const Duration(seconds: 4), () {
      _hideTimer = null;
      if (mounted && _c.engine.state.value.playing && _panel == _Panel.none && _drag == null) setState(() => _controls = false);
    });
  }

  void _toggleControls() {
    if (_controls) {
      _hideTimer?.cancel();
      _hideTimer = null;
      setState(() => _controls = false);
    } else {
      _bump();
    }
  }

  void _showLockHint() {
    setState(() => _lockHint = true);
    _lockHintTimer?.cancel();
    _lockHintTimer = Timer(const Duration(seconds: 3), () => mounted ? setState(() => _lockHint = false) : null);
  }

  void _setLocked(bool v) {
    setState(() {
      _locked = v;
      _lockHint = v;
      _panel = _Panel.none;
    });
    if (v) {
      _showLockHint();
    } else {
      _bump();
    }
  }

  void _openPanel(_Panel p) {
    final playing = _c.engine.state.value.playing;
    final live = _c.item.value?.isLive ?? false;
    if (p == _Panel.settings && !live && playing) {
      _resumeAfterPanel = true;
      unawaited(_c.engine.pause());
    }
    _hideTimer?.cancel();
    _hideTimer = null;
    setState(() {
      _panel = p;
      _controls = true;
    });
  }

  void _closePanel() {
    if (_resumeAfterPanel) unawaited(_c.engine.play());
    _resumeAfterPanel = false;
    setState(() => _panel = _Panel.none);
    _bump();
  }

  void _seekBy(bool forward) {
    unawaited(_c.seekBy(Duration(seconds: forward ? 10 : -10)));
    final prev = _seek;
    setState(() => _seek = (forward, prev != null && prev.$1 == forward ? prev.$2 + 10 : 10));
    _seekTimer?.cancel();
    _seekTimer = Timer(const Duration(milliseconds: 800), () => mounted ? setState(() => _seek = null) : null);
  }

  Future<void> _zap(Channel c) async {
    final locks = ref.read(locksProvider).value ?? const {};
    final parental = ref.read(parentalProvider);
    if (isChannelLocked(c, locks) && await parental.hasPin() && !parental.isUnlocked) {
      if (!mounted) return;
      final ok = await context.push<bool>(Routes.pin);
      if (ok != true) return;
    }
    await _c.load(PlayTarget(PlayKind.live, c.id));
    _bump();
  }

  Future<void> _zapAdjacent(bool next) async {
    final c = await _c.adjacentChannel(next: next);
    if (c != null) await _zap(c);
  }

  Future<void> _enterPip() async {
    final s = _c.engine.state.value;
    final ok = await PlayerWindow.enterPip(width: s.width, height: s.height);
    if (!ok && mounted) showOxSnack(context, message: context.l10n.pipUnavailable, icon: OxIcons.pip);
  }

  void _rotate() {
    setState(() => _portrait = !_portrait);
    unawaited(PlayerWindow.setOrientations(_portrait ? PlayerWindow.portrait : PlayerWindow.landscape));
  }

  void _exit() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.home);
    }
  }

  // Gestures ------------------------------------------------------------------

  void _onTapUp() => _locked ? _showLockHint() : _toggleControls();

  void _onDoubleTap(TapDownDetails d, Size size) {
    if (_locked) return;
    final x = d.localPosition.dx / size.width;
    final live = _c.item.value?.isLive ?? false;
    if (x < 1 / 3) {
      _seekBy(false);
    } else if (x > 2 / 3) {
      if (!live || _c.behindLive) _seekBy(true);
    } else {
      unawaited(_c.togglePlay());
      _bump();
    }
  }

  void _onScaleStart(ScaleStartDetails d) {
    if (_locked || _panel != _Panel.none) return;
    _gestureStart = d.localFocalPoint;
    _pinching = d.pointerCount > 1;
    _pinchScale = 1;
    _drag = null;
  }

  void _onScaleUpdate(ScaleUpdateDetails d, Size size) {
    final start = _gestureStart;
    if (start == null) return;
    if (d.pointerCount > 1 || _pinching) {
      _pinching = true;
      _pinchScale = d.scale;
      return;
    }
    final delta = d.localFocalPoint - start;
    if (_drag == null) {
      if (delta.distance < 14) return;
      final live = _c.item.value?.isLive ?? false;
      final s = _c.engine.state.value;
      if (delta.dx.abs() > delta.dy.abs()) {
        if (live || s.duration <= Duration.zero) return;
        _drag = _Drag.scrub;
        _scrubStart = _c.engine.position.value;
      } else {
        _drag = start.dx < size.width / 2 ? _Drag.brightness : _Drag.volume;
        _levelStart = _drag == _Drag.brightness ? _brightness : s.volume / 100;
      }
      _levelTimer?.cancel();
      _hideTimer?.cancel();
      _hideTimer = null;
    }
    switch (_drag!) {
      case _Drag.scrub:
        final total = _c.engine.state.value.duration;
        final span = total < const Duration(minutes: 5) ? total : const Duration(minutes: 5);
        final ms = _scrubStart.inMilliseconds + (delta.dx / size.width * span.inMilliseconds).round();
        setState(() {
          _controls = true;
          _scrubTo = Duration(milliseconds: ms.clamp(0, total.inMilliseconds));
        });
      case _Drag.brightness:
      case _Drag.volume:
        final v = (_levelStart - delta.dy / (size.height * 0.75)).clamp(0.0, 1.0);
        setState(() => _level = v);
        if (_drag == _Drag.brightness) {
          _brightness = v;
          unawaited(PlayerWindow.setBrightness(v));
        } else {
          unawaited(_c.engine.setVolume(v * 100));
        }
    }
  }

  void _onScaleEnd(ScaleEndDetails d) {
    if (_pinching) {
      if (_pinchScale > 1.08) setState(() => _aspect = AspectMode.zoom);
      if (_pinchScale < 0.92) setState(() => _aspect = AspectMode.fit);
    }
    if (_drag == _Drag.scrub && _scrubTo != null) unawaited(_c.engine.seek(_scrubTo!));
    final wasLevel = _drag == _Drag.brightness || _drag == _Drag.volume;
    setState(() {
      _scrubTo = null;
      if (!wasLevel) _drag = null;
    });
    if (wasLevel) {
      _levelTimer = Timer(const Duration(milliseconds: 700), () => mounted ? setState(() => _drag = null) : null);
    }
    _gestureStart = null;
    _pinching = false;
    if (_controls) _bump();
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent e) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) return KeyEventResult.ignored;
    final live = _c.item.value?.isLive ?? false;
    final k = e.logicalKey;
    if (_locked) {
      _showLockHint();
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.space || k == LogicalKeyboardKey.mediaPlayPause || k == LogicalKeyboardKey.keyK) {
      unawaited(_c.togglePlay());
      _bump();
      return KeyEventResult.handled;
    }
    if (!_controls && (k == LogicalKeyboardKey.arrowLeft || k == LogicalKeyboardKey.arrowRight)) {
      _seekBy(k == LogicalKeyboardKey.arrowRight);
      return KeyEventResult.handled;
    }
    if (live && !_controls && (k == LogicalKeyboardKey.arrowUp || k == LogicalKeyboardKey.channelUp || k == LogicalKeyboardKey.pageUp)) {
      unawaited(_zapAdjacent(false));
      return KeyEventResult.handled;
    }
    if (live && !_controls && (k == LogicalKeyboardKey.arrowDown || k == LogicalKeyboardKey.channelDown || k == LogicalKeyboardKey.pageDown)) {
      unawaited(_zapAdjacent(true));
      return KeyEventResult.handled;
    }
    // Any other key (D-pad centre…) reveals the controls first.
    if (!_controls) {
      _bump();
      return KeyEventResult.handled;
    }
    _bump();
    return KeyEventResult.ignored;
  }

  // Build ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final settings = ref.watch(appSettingsProvider.select((s) => (s.subtitleSize, s.subtitleStyle)));
    final pad = MediaQuery.paddingOf(context);

    return PopScope(
      canPop: _panel == _Panel.none && !_locked,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_locked) {
          _showLockHint();
        } else {
          _closePanel();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF000000),
        body: Focus(
          focusNode: _focus,
          onKeyEvent: _onKey,
          child: LayoutBuilder(
            builder: (context, box) {
              final size = box.biggest;
              return ValueListenableBuilder(
                valueListenable: _c.item,
                builder: (context, item, _) {
                  final live = item?.isLive ?? widget.target.kind == PlayKind.live;
                  final chrome = _controls && !_locked && !_pip && _panel != _Panel.settings;
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // Picture (artwork until the first frame).
                      ValueListenableBuilder(
                        valueListenable: _c.engine.state,
                        builder: (context, s, _) => Stack(
                          fit: StackFit.expand,
                          children: [
                            if (s.width == null && item?.artwork != null)
                              Opacity(opacity: 0.45, child: OxImage(item!.artwork, fit: BoxFit.cover)),
                            _c.engine.video(fit: _aspect.fit, aspectRatio: _aspect.ratio),
                          ],
                        ),
                      ),
                      // Gesture surface.
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _onTapUp,
                        onDoubleTapDown: (d) => _onDoubleTap(d, size),
                        onDoubleTap: () {},
                        onScaleStart: _onScaleStart,
                        onScaleUpdate: (d) => _onScaleUpdate(d, size),
                        onScaleEnd: _onScaleEnd,
                      ),
                      // Buffering.
                      ValueListenableBuilder(
                        valueListenable: _c.engine.state,
                        builder: (context, s, _) => IgnorePointer(
                          child: Center(
                            child: AnimatedOpacity(
                              duration: OxMotion.base,
                              opacity: s.buffering && _c.failure.value == null && !(chrome && !live) ? 1 : 0,
                              child: const OxSpinner(size: 44, strokeWidth: 3, color: OxColors.text1),
                            ),
                          ),
                        ),
                      ),
                      // Chrome.
                      if (!_pip)
                        IgnorePointer(
                          ignoring: !chrome,
                          child: AnimatedOpacity(
                            duration: OxMotion.base,
                            opacity: chrome ? 1 : 0,
                            child: item == null
                                ? _loadingChrome(l, pad)
                                : live
                                    ? _liveChrome(context, item, size, pad)
                                    : _vodChrome(context, item, size, pad),
                          ),
                        ),
                      // Subtitles.
                      IgnorePointer(
                        child: ValueListenableBuilder(
                          valueListenable: _c.engine.state,
                          builder: (context, s, _) => SubtitleOverlay(
                            // Live chrome fills short screens; settings cover the picture.
                            lines: _panel == _Panel.settings || (live && chrome && size.height < 500) ? const [] : s.subtitle,
                            size: settings.$1,
                            style: settings.$2,
                            bottom: _pip ? 6 : (chrome ? (live ? 190 : 118) : 28) + pad.bottom,
                            end: _pip ? 0 : (_panel == _Panel.channels ? 320 : 0) + pad.right,
                            side: _pip ? 6 : 24,
                          ),
                        ),
                      ),
                      // Brightness / volume.
                      if (_drag == _Drag.brightness || _drag == _Drag.volume)
                        Positioned(
                          left: _drag == _Drag.brightness ? 24 + pad.left : null,
                          right: _drag == _Drag.volume ? 24 + pad.right : null,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: _drag == _Drag.brightness
                                ? LevelPill(icon: OxIcons.sun, value: _level, color: OxColors.text1, label: l.a11yBrightness)
                                : LevelPill(icon: OxIcons.volume, value: _level, color: OxColors.ember, label: l.a11yVolume),
                          ),
                        ),
                      // Double-tap seek.
                      if (_seek != null)
                        Positioned(
                          left: _seek!.$1 ? null : size.width * 0.12,
                          right: _seek!.$1 ? size.width * 0.12 : null,
                          top: 0,
                          bottom: 0,
                          child: Center(child: IgnorePointer(child: SeekBadge(forward: _seek!.$1, seconds: _seek!.$2))),
                        ),
                      // States 12 pills: a stalled stream, and locked controls.
                      Positioned(
                        top: 16 + pad.top,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: ValueListenableBuilder(
                            valueListenable: _c.engine.state,
                            builder: (context, s, _) {
                              final reconnecting = !_pip && s.buffering && _playedTarget != null && _playedTarget == item?.target && _c.failure.value == null;
                              if (_locked && _lockHint && !_pip) {
                                return _Pill(
                                  icon: const OxIcon(OxIcons.lock, size: OxIconSize.sm, color: OxColors.text1),
                                  label: l.controlsLockedTap,
                                  semanticLabel: l.a11yUnlockControls,
                                  onTap: () => _setLocked(false),
                                );
                              }
                              if (reconnecting && !chrome) {
                                return _Pill(
                                  icon: const OxOrbitLoader(size: 16),
                                  label: l.reconnectingStream,
                                  color: const Color(0x1F7CC4FF),
                                  foreground: OxColors.halo,
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      // Panels.
                      if (!_pip && _panel == _Panel.settings) ..._settingsPanel(context, size, pad),
                      if (!_pip && _panel == _Panel.channels && item?.channel != null)
                        PositionedDirectional(
                          end: 12 + pad.right,
                          top: 12 + pad.top,
                          bottom: 12 + pad.bottom,
                          width: 300,
                          child: ChannelPanel(
                            current: item!.channel!,
                            categoryName: item.categoryName,
                            onSelect: _zap,
                            onClose: _closePanel,
                          ),
                        ),
                      // Up next.
                      if (!_pip) _upNextCard(context, item, pad),
                      // Failure.
                      ValueListenableBuilder(
                        valueListenable: _c.failure,
                        builder: (context, f, _) => f == null ? const SizedBox.shrink() : _failure(context, f, item, pad),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _scrims({bool sideScrim = false}) => IgnorePointer(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xB8000000), Color(0x1A000000), Color(0x1A000000), Color(0xE0000000)],
                  stops: [0, 0.3, 0.58, 1],
                ),
              ),
            ),
            if (sideScrim)
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.centerEnd,
                    end: AlignmentDirectional.centerStart,
                    colors: [Color(0x8C000000), Color(0x00000000)],
                    stops: [0, 0.4],
                  ),
                ),
              ),
          ],
        ),
      );

  Widget _loadingChrome(AppLocalizations l, EdgeInsets pad) => Stack(
        children: [
          _scrims(),
          PositionedDirectional(
            start: 20 + pad.left,
            top: 16 + pad.top,
            child: PlayerIconButton(icon: OxIcons.back, semanticLabel: l.actionBack, onPressed: _exit),
          ),
        ],
      );

  /// Caption under the title: "Sci-Fi · 2026 · 4K · English 5.1".
  InlineSpan _vodCaption(BuildContext context, NowPlaying item, EngineState s) {
    final l = context.l10n;
    final q = qualityLabel(s.height);
    final audio = realTracks(s.tracks.audio).where((a) => a.id == s.track.audio.id).firstOrNull;
    final parts = <String>[
      if (item.episode != null) '${l.episodeShort(item.episode!.season, item.episode!.episode)} · ${item.episode!.title}',
      if (item.episode == null && item.genre != null) item.genre!.split(RegExp(r'[,/]')).first.trim(),
      if (item.episode == null && item.year != null) '${item.year}',
    ];
    return TextSpan(
      children: [
        TextSpan(text: parts.join(' · ')),
        if (q != null) ...[
          TextSpan(text: parts.isEmpty ? '' : ' · '),
          TextSpan(text: q, style: const TextStyle(color: OxColors.halo)),
        ],
        if (audio != null) TextSpan(text: ' · ${trackName(l, audio, 0)}'),
      ],
    );
  }

  Widget _vodChrome(BuildContext context, NowPlaying item, Size size, EdgeInsets pad) {
    final l = context.l10n;
    final t = context.oxText;
    final ep = item.target.kind == PlayKind.episode;
    final compact = size.width < 600;
    return ValueListenableBuilder(
      valueListenable: _c.engine.state,
      builder: (context, s, _) => Stack(
        children: [
          _scrims(),
          // Top bar.
          PositionedDirectional(
            start: 20 + pad.left,
            end: 20 + pad.right,
            top: 16 + pad.top,
            child: Row(
              spacing: 6,
              children: [
                PlayerIconButton(icon: OxIcons.back, semanticLabel: l.actionBack, onPressed: _exit),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OxContentText(item.title, style: t.title.copyWith(fontSize: 16, color: OxColors.text1)),
                      Text.rich(_vodCaption(context, item, s), maxLines: 1, overflow: TextOverflow.ellipsis, style: t.caption.copyWith(color: OxColors.text2)),
                    ],
                  ),
                ),
                PlayerIconButton(icon: OxIcons.pip, semanticLabel: l.actionPip, onPressed: _enterPip),
                if (!compact) PlayerIconButton(icon: OxIcons.cc, semanticLabel: l.a11ySubtitles, onPressed: () => _openPanel(_Panel.settings)),
                if (!compact) PlayerIconButton(icon: OxIcons.audio, semanticLabel: l.a11yAudioTrack, onPressed: () => _openPanel(_Panel.settings)),
                PlayerIconButton(icon: OxIcons.settings, semanticLabel: l.a11yPlaybackSettings, onPressed: () => _openPanel(_Panel.settings)),
                const SizedBox(width: 6),
                PlayerIconButton(icon: OxIcons.lock, semanticLabel: l.a11yLockControls, glass: true, size: 40, onPressed: () => _setLocked(true)),
              ],
            ),
          ),
          // Transport.
          Align(
            alignment: const Alignment(0, -0.12),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: compact ? 18 : 30,
                children: [
                  if (ep) PlayerIconButton(icon: OxIcons.prev, semanticLabel: l.a11yPrevEpisode, size: 52, opacity: 0.85, onPressed: item.previous == null ? null : _c.playPreviousEpisode),
                  PlayerIconButton(icon: OxIcons.rew, semanticLabel: l.a11yBack10, size: 56, iconSize: OxIconSize.lg, onPressed: () => _seekBy(false)),
                  PlayPauseButton(playing: s.playing, onPressed: () {
                    unawaited(_c.togglePlay());
                    _bump();
                  }),
                  PlayerIconButton(icon: OxIcons.fwd, semanticLabel: l.a11yForward10, size: 56, iconSize: OxIconSize.lg, onPressed: () => _seekBy(true)),
                  if (ep) PlayerIconButton(icon: OxIcons.next, semanticLabel: l.a11yNextEpisode, size: 52, opacity: 0.85, onPressed: item.next == null ? null : _c.playNextEpisode),
                ],
              ),
            ),
          ),
          // Seek bar + chips.
          Positioned(
            left: 28 + pad.left,
            right: 28 + pad.right,
            bottom: 18 + pad.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                ValueListenableBuilder(
                  valueListenable: _c.engine.position,
                  builder: (context, p, _) => ScrubBar(
                    position: p,
                    duration: s.duration,
                    buffered: s.buffer,
                    scrubbing: _scrubTo,
                    onSeek: (d) {
                      unawaited(_c.engine.seek(d));
                      _bump();
                    },
                    onScrubStart: () {
                      _hideTimer?.cancel();
                      _hideTimer = null;
                    },
                    onScrubEnd: _bump,
                  ),
                ),
                Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(spacing: 8, children: _chips(context, s, live: false)),
                      ),
                    ),
                    if (_isPhone) PlayerIconButton(icon: OxIcons.rotate, semanticLabel: l.a11yRotate, size: 40, onPressed: _rotate),
                    PlayerIconButton(icon: OxIcons.fullscreen, semanticLabel: l.a11yExitPlayer, size: 40, onPressed: _exit),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _chips(BuildContext context, EngineState s, {required bool live}) {
    final l = context.l10n;
    final subs = realTracks(s.tracks.subtitle);
    final sub = subs.indexed.where((e) => e.$2.id == s.track.subtitle.id).firstOrNull;
    return [
      PlayerChip(
        label: _aspect.label(l),
        icon: OxIcons.aspect,
        onTap: () {
          setState(() => _aspect = AspectMode.values[(_aspect.index + 1) % AspectMode.values.length]);
          _bump();
        },
      ),
      if (!live)
        PlayerChip(
          // Isolated LTR: in Arabic a leading digit would push × to the wrong side.
          label: '\u2066${s.rate == s.rate.roundToDouble() ? s.rate.toStringAsFixed(1) : s.rate}×\u2069',
          icon: OxIcons.speed,
          onTap: () {
            final i = playbackSpeeds.indexOf(s.rate);
            unawaited(_c.engine.setRate(playbackSpeeds[(i + 1) % playbackSpeeds.length]));
            _bump();
          },
        ),
      PlayerChip(label: qualityLabel(s.height) ?? l.qualityAuto, icon: OxIcons.hd, onTap: () => _openPanel(_Panel.settings)),
      if (subs.isNotEmpty)
        PlayerChip(
          label: sub == null ? l.subtitlesOff : trackName(l, sub.$2, sub.$1, endonym: true),
          icon: OxIcons.cc,
          onTap: () => _openPanel(_Panel.settings),
        ),
    ];
  }

  Widget _liveChrome(BuildContext context, NowPlaying item, Size size, EdgeInsets pad) {
    final l = context.l10n;
    final t = context.oxText;
    final c = item.channel!;
    final panelOpen = _panel == _Panel.channels;
    final endInset = (panelOpen ? 330.0 : 20.0) + pad.right;
    final now = item.guide?.now;
    final next = item.guide?.next;
    final fav = (ref.watch(favoriteIdsProvider(ContentKind.live)).value ?? const {}).contains(c.id);
    final clock = ref.watch(clockProvider).value ?? DateTime.now();
    return ValueListenableBuilder(
      valueListenable: _c.engine.state,
      builder: (context, s, _) {
        final q = qualityLabel(s.height);
        return Stack(
          children: [
            _scrims(sideScrim: panelOpen),
            // Top bar.
            PositionedDirectional(
              start: 20 + pad.left,
              end: endInset,
              top: 16 + pad.top,
              child: Row(
                spacing: 10,
                children: [
                  PlayerIconButton(icon: OxIcons.back, semanticLabel: l.actionBack, onPressed: _exit),
                  OxChannelLogo(name: c.name, logoUrl: c.logo, size: 40),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: 8,
                          children: [
                            Flexible(child: OxContentText(c.name, style: t.title.copyWith(fontSize: 15, color: OxColors.text1))),
                            OxBadge.live(context, dense: true),
                            if (q != null) OxBadge.quality(q == '1080p' ? 'FHD' : q, dense: true),
                          ],
                        ),
                        Text(
                          [if (c.number != null) l.channelNumber('${c.number}'), ?item.categoryName].join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.caption.copyWith(color: OxColors.text2),
                        ),
                      ],
                    ),
                  ),
                  PlayerIconButton(icon: OxIcons.pip, semanticLabel: l.actionPip, size: 40, onPressed: _enterPip),
                  PlayerIconButton(icon: OxIcons.cc, semanticLabel: l.a11yPlaybackSettings, size: 40, onPressed: () => _openPanel(_Panel.settings)),
                  PlayerIconButton(icon: OxIcons.lock, semanticLabel: l.a11yLockControls, glass: true, size: 40, onPressed: () => _setLocked(true)),
                ],
              ),
            ),
            // Channel up / down.
            PositionedDirectional(
              start: 24 + pad.left,
              top: 0,
              bottom: 0,
              child: Center(
                child: VideoGlass(
                  borderRadius: BorderRadius.circular(26),
                  child: SizedBox(
                    width: 52,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PlayerIconButton(icon: OxIcons.chevU, semanticLabel: l.a11yChannelUp, onPressed: () => _zapAdjacent(false)),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Text('${c.number ?? '–'}', style: OxTypography.en.time.copyWith(fontSize: 12, color: OxColors.text1)),
                          ),
                          PlayerIconButton(icon: OxIcons.chevD, semanticLabel: l.a11yChannelDown, onPressed: () => _zapAdjacent(true)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Transport (pause buffers; rewind within the cache).
            PositionedDirectional(
              start: 0,
              end: endInset - 20,
              top: 0,
              bottom: 0,
              child: Center(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 26,
                    children: [
                      PlayerIconButton(icon: OxIcons.rew, semanticLabel: l.a11yBack10, size: 52, iconSize: OxIconSize.lg, onPressed: () => _seekBy(false)),
                      PlayPauseButton(playing: s.playing, onPressed: () {
                        unawaited(_c.togglePlay());
                        _bump();
                      }),
                      ValueListenableBuilder(
                        valueListenable: _c.engine.position,
                        builder: (context, _, _) => PlayerIconButton(
                          icon: OxIcons.fwd,
                          semanticLabel: l.a11yForward10,
                          size: 52,
                          iconSize: OxIconSize.lg,
                          onPressed: _c.behindLive ? () => _seekBy(true) : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Now / next, programme progress, chips.
            PositionedDirectional(
              start: 28 + pad.left,
              end: endInset + 8,
              bottom: 18 + pad.bottom,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: 16,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            if (now != null) ...[
                              Text(
                                t.overlineText(l.nowAt(Fmt.range(now.start, now.stop))),
                                style: t.overline.copyWith(color: OxColors.emberHi, fontSize: t.isArabic ? 12 : 10),
                              ),
                              OxContentText(now.title, style: t.title.copyWith(fontSize: 17, color: OxColors.text1)),
                            ] else
                              Text(l.noGuideData, style: t.title.copyWith(fontSize: 15, color: OxColors.text2)),
                            if (next != null) OxContentText('${l.nextAt(Fmt.clock(next.start))} · ${next.title}', style: t.caption.copyWith(color: OxColors.text2)),
                          ],
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: _c.engine.position,
                        builder: (context, _, _) {
                          final behind = _c.behindLive;
                          return OxPressable(
                            onTap: () {
                              if (behind) unawaited(_c.goLive());
                            },
                            semanticLabel: behind ? l.behindLive : l.goLive,
                            child: Container(
                              height: 32,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: behind ? const Color(0x24FFFFFF) : OxColors.live,
                                borderRadius: BorderRadius.circular(OxRadius.pill),
                                border: behind ? Border.all(color: const Color(0x40FFFFFF)) : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 6,
                                children: [
                                  OxLiveDot(color: behind ? OxColors.text3 : const Color(0xFFFFFFFF)),
                                  Text(behind ? l.behindLive : l.goLive, style: t.small.copyWith(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFFFFFFFF))),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  if (now != null)
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        spacing: 12,
                        children: [
                          Text(Fmt.clock(now.start), style: OxTypography.en.time.copyWith(fontSize: 11, color: OxColors.text1)),
                          Expanded(child: _ProgrammeBar(value: NowNext(now, null).progressAt(clock))),
                          Text(Fmt.clock(now.stop), style: OxTypography.en.time.copyWith(fontSize: 11, color: OxColors.text2)),
                        ],
                      ),
                    ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 8,
                      children: [
                        PlayerChip(label: l.guide, icon: OxIcons.epg, onTap: () => context.go(Routes.guide)),
                        PlayerChip(
                          label: l.channelsChip,
                          icon: OxIcons.list,
                          selected: panelOpen,
                          onTap: () => panelOpen ? _closePanel() : _openPanel(_Panel.channels),
                        ),
                        ..._chips(context, s, live: true).take(1),
                        PlayerChip(
                          label: l.favorite,
                          icon: fav ? OxIcons.heartFill : OxIcons.heart,
                          iconColor: fav ? OxColors.ember : null,
                          onTap: () => toggleFavoriteWithFeedback(context, ref, ContentKind.live, c.id),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _settingsPanel(BuildContext context, Size size, EdgeInsets pad) {
    final l = context.l10n;
    final t = context.oxText;
    final width = size.width >= 760 ? 600.0 : size.width;
    return [
      Positioned.fill(child: GestureDetector(onTap: _closePanel, child: const ColoredBox(color: Color(0x99000000)))),
      if (size.width - width >= 260)
        PositionedDirectional(
          start: 26 + pad.left,
          top: 22 + pad.top,
          bottom: 22 + pad.bottom,
          width: size.width - width - 52,
          child: IgnorePointer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ValueListenableBuilder(
                  valueListenable: _c.engine.position,
                  builder: (context, p, _) {
                    final playing = _c.engine.state.value.playing;
                    final live = _c.item.value?.isLive ?? false;
                    return Row(
                      spacing: 8,
                      children: [
                        OxIcon(playing ? OxIcons.play : OxIcons.pause, size: OxIconSize.md, color: OxColors.text1),
                        Flexible(
                          child: Text(
                            live ? (_c.item.value?.title ?? '') : (playing ? l.playingAt(Fmt.position(p)) : l.pausedAt(Fmt.position(p))),
                            style: t.title.copyWith(color: OxColors.text1),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Text(l.changesApply, style: t.caption.copyWith(color: OxColors.text2)),
              ],
            ),
          ),
        ),
      PositionedDirectional(
        end: 0,
        top: 0,
        bottom: 0,
        width: width,
        child: Container(
          padding: EdgeInsetsDirectional.fromSTEB(20, 18 + pad.top, 20 + pad.right, 18 + pad.bottom),
          decoration: BoxDecoration(
            color: OxColors.sheet,
            borderRadius: width < size.width ? const BorderRadiusDirectional.horizontal(start: Radius.circular(28)).resolve(Directionality.of(context)) : null,
            border: const BorderDirectional(start: BorderSide(color: Color(0x1FFFFFFF))),
          ),
          child: PlayerSettingsPanel(
            controller: _c,
            aspect: _aspect,
            onAspect: (a) => setState(() => _aspect = a),
            onClose: _closePanel,
          ),
        ),
      ),
    ];
  }

  Widget _upNextCard(BuildContext context, NowPlaying? item, EdgeInsets pad) {
    return ValueListenableBuilder(
      valueListenable: _c.upNext,
      builder: (context, left, _) {
        final next = item?.next;
        if (left == null || next == null) return const SizedBox.shrink();
        final l = context.l10n;
        final t = context.oxText;
        return PositionedDirectional(
          end: 24 + pad.right,
          bottom: 24 + pad.bottom,
          width: 340,
          child: VideoGlass(
            borderRadius: BorderRadius.circular(20),
            shadows: OxShadows.e2,
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10,
              children: [
                Row(
                  spacing: 12,
                  children: [
                    SizedBox(width: 120, child: OxThumb(image: next.still ?? item!.artwork, radius: 10, progress: (10 - left) / 10)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          Text(t.overlineText(l.upNextIn(left)), style: t.overline.copyWith(color: OxColors.emberHi)),
                          OxContentText(next.title, maxLines: 2, style: t.title.copyWith(fontSize: 14)),
                          Text(l.episodeShort(next.season, next.episode), style: t.caption),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: 8,
                  children: [
                    Expanded(child: OxButton(label: l.playNow, icon: OxIcons.play, size: OxButtonSize.sm, expand: true, onPressed: _c.playNextEpisode)),
                    OxButton(label: l.actionCancel, variant: OxButtonVariant.ghost, size: OxButtonSize.sm, onPressed: _c.cancelUpNext),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _failure(BuildContext context, Object f, NowPlaying? item, EdgeInsets pad) {
    final l = context.l10n;
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Color(0xF0000000)),
        if (item?.artwork != null) Opacity(opacity: 0.18, child: OxImage(item!.artwork, fit: BoxFit.cover)),
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: OxStateView(
                emblem: const OxStateEmblem(icon: OxIcons.alert, background: OxColors.errSoft, foreground: OxColors.err),
                title: l.playbackFailedTitle,
                message: f is OrbixFailure ? describeFailure(context, f) : l.playbackFailedBody,
                detail: f is OrbixFailure ? failureDetail(f) : f.toString(),
                actions: [
                  OxButton(label: l.actionRetry, icon: OxIcons.refresh, onPressed: _c.retry),
                  OxButton(label: l.actionBack, variant: OxButtonVariant.tonal, onPressed: _exit),
                ],
              ),
            ),
          ),
        ),
        PositionedDirectional(
          start: 20 + pad.left,
          top: 16 + pad.top,
          child: PlayerIconButton(icon: OxIcons.back, semanticLabel: l.actionBack, onPressed: _exit),
        ),
      ],
    );
  }
}

/// Rounded status pill over the video (States 12).
class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, this.onTap, this.semanticLabel, this.color = const Color(0x1FFFFFFF), this.foreground = OxColors.text1});

  final Widget icon;
  final String label;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(OxRadius.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [icon, Text(label, style: context.oxText.small.copyWith(fontSize: 12.5, fontWeight: FontWeight.w800, color: foreground))],
      ),
    );
    if (onTap == null) return Semantics(liveRegion: true, child: pill);
    return OxPressable(onTap: onTap, semanticLabel: semanticLabel ?? label, child: pill);
  }
}

class _ProgrammeBar extends StatelessWidget {
  const _ProgrammeBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, c) => SizedBox(
          height: 14,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              Container(height: 4, decoration: BoxDecoration(color: const Color(0x33FFFFFF), borderRadius: BorderRadius.circular(4))),
              Container(width: c.maxWidth * value.clamp(0, 1), height: 4, decoration: BoxDecoration(color: OxColors.ember, borderRadius: BorderRadius.circular(4))),
              Positioned(
                left: c.maxWidth * value.clamp(0, 1) - 7,
                child: Container(width: 14, height: 14, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFFFFFF))),
              ),
            ],
          ),
        ),
      );
}

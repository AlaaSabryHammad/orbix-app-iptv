import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/design.dart';
import '../../core/l10n/l10n.dart';
import '../../core/session/session.dart';
import '../../core/settings/app_settings.dart';
import '../../data/data.dart';
import '../../shared/widgets/widgets.dart';
import '../live/live_providers.dart';
import 'engine.dart';

/// Live TV's inline preview: plays [channel] muted (unless [muted] is
/// false) over the artwork, pauses while another screen covers it, and
/// stays dark for locked channels.
class LivePreviewVideo extends ConsumerStatefulWidget {
  const LivePreviewVideo({super.key, required this.channel, this.muted = true});

  final Channel channel;
  final bool muted;

  @override
  ConsumerState<LivePreviewVideo> createState() => _LivePreviewVideoState();
}

class _LivePreviewVideoState extends ConsumerState<LivePreviewVideo> {
  PlayerEngine? _engine;
  ValueListenable<TickerModeData>? _ticker;
  int _load = 0;

  /// The load whose failure was already reported (one toast per channel).
  int _reported = -1;

  /// States 12: "Stream unavailable · Retry".
  void _failed() {
    if (!mounted || _reported == _load) return;
    _reported = _load;
    final l = context.l10n;
    showOxSnack(
      context,
      tone: OxSnackTone.error,
      message: l.streamUnavailable,
      icon: OxIcons.alert,
      actionLabel: l.actionRetry,
      onAction: () => unawaited(_open()),
    );
  }

  void _onEngine() {
    if (_engine?.state.value.error != null) _failed();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final t = TickerMode.getValuesNotifier(context);
    if (t != _ticker) {
      _ticker?.removeListener(_onVisibility);
      _ticker = t..addListener(_onVisibility);
    }
    if (_engine == null) unawaited(_open());
  }

  @override
  void didUpdateWidget(LivePreviewVideo old) {
    super.didUpdateWidget(old);
    if (old.channel.id != widget.channel.id) unawaited(_open());
    if (old.muted != widget.muted) unawaited(_engine?.setVolume(widget.muted ? 0 : 100));
  }

  /// Covered by the full-screen player or another tab: stop decoding.
  void _onVisibility() {
    final e = _engine;
    if (e == null) return;
    unawaited(_ticker!.value.enabled ? e.play() : e.pause());
  }

  Future<void> _open() async {
    final id = ++_load;
    final account = ref.read(activeAccountIdProvider) ?? '';
    final locks = ref.read(locksProvider).value ?? const {};
    final parental = ref.read(parentalProvider);
    if (isChannelLocked(widget.channel, locks) && await parental.hasPin() && !parental.isUnlocked) {
      await _close();
      return;
    }
    try {
      final stream = await ref.read(catalogRepositoryProvider).channelStream(account, widget.channel);
      if (!mounted || id != _load) return;
      final engine = _engine ??= ref.read(playerEngineFactoryProvider)(hardwareDecoding: ref.read(appSettingsProvider).hardwareDecoding)
        ..state.addListener(_onEngine);
      await engine.setVolume(widget.muted ? 0 : 100);
      await engine.open(ref.read(streamUrlRewriterProvider)(stream.url), headers: stream.headers, loop: true);
      if (!(_ticker?.value.enabled ?? true)) await engine.pause();
      if (mounted) setState(() {});
    } on Object {
      // The artwork stays underneath.
      if (id == _load) _failed();
    }
  }

  Future<void> _close() async {
    final e = _engine;
    _engine = null;
    e?.state.removeListener(_onEngine);
    if (mounted) setState(() {});
    await e?.dispose();
  }

  @override
  void dispose() {
    _ticker?.removeListener(_onVisibility);
    _load++;
    _engine?.state.removeListener(_onEngine);
    unawaited(_engine?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = _engine;
    if (e == null) return const SizedBox.shrink();
    return ValueListenableBuilder(
      valueListenable: e.state,
      builder: (context, s, child) => AnimatedOpacity(duration: OxMotion.slow, opacity: s.width != null && s.error == null ? 1 : 0, child: child),
      child: IgnorePointer(child: e.video(fit: BoxFit.cover)),
    );
  }
}

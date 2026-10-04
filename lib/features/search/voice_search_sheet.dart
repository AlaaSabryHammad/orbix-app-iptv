import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/design/design.dart';
import '../../core/l10n/l10n.dart';
import '../../shared/widgets/widgets.dart';

/// 15 Voice search sheet. Returns the recognised text, or null.
Future<String?> showVoiceSearch(BuildContext context) => showOxSheet<String>(context, builder: (_) => const _VoiceSheet());

class _VoiceSheet extends StatefulWidget {
  const _VoiceSheet();

  @override
  State<_VoiceSheet> createState() => _VoiceSheetState();
}

class _VoiceSheetState extends State<_VoiceSheet> {
  final _speech = SpeechToText();
  String _words = '';
  String? _error;
  String? _localeName;
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  Future<void> _start() async {
    final l = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    bool ok;
    try {
      ok = await _speech.initialize(
        onError: (e) => mounted ? setState(() => _error = e.permanent ? l.voiceUnavailable : null) : null,
        onStatus: (s) {
          if (!mounted) return;
          setState(() => _listening = _speech.isListening);
          if (s == 'done' && _words.isNotEmpty) _finish();
        },
      );
    } catch (_) {
      ok = false;
    }
    if (!mounted) return;
    if (!ok) {
      setState(() => _error = l.voiceNoPermission);
      return;
    }
    final locales = await _speech.locales();
    final preferred = locales.where((x) => x.localeId.toLowerCase().startsWith(lang)).firstOrNull ?? await _speech.systemLocale();
    setState(() => _localeName = preferred?.name);
    await _speech.listen(
      onResult: _onResult,
      listenOptions: SpeechListenOptions(listenMode: ListenMode.search, partialResults: true, pauseFor: const Duration(seconds: 3), localeId: preferred?.localeId),
    );
    if (mounted) setState(() => _listening = true);
  }

  void _onResult(SpeechRecognitionResult r) {
    if (!mounted) return;
    setState(() => _words = r.recognizedWords);
    if (r.finalResult && _words.isNotEmpty) _finish();
  }

  bool _done = false;

  void _finish() {
    if (_done) return;
    _done = true;
    unawaited(_speech.stop());
    Navigator.pop(context, _words.trim().isEmpty ? null : _words.trim());
  }

  @override
  void dispose() {
    unawaited(_speech.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.oxText;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (_localeName != null) OxChip(label: _localeName!, icon: OxIcons.globe, small: true),
              const Spacer(),
              OxIconButton(icon: OxIcons.close, semanticLabel: l.a11yDismiss, onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 30),
          _Orb(active: _listening && _error == null),
          const SizedBox(height: 34),
          Text(t.overlineText(_error == null ? l.listening : l.voiceUnavailable), style: t.overline.copyWith(color: OxColors.emberHi)),
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            child: Text(
              _error ?? (_words.isEmpty ? '…' : '“$_words”'),
              textAlign: TextAlign.center,
              style: t.h1.copyWith(fontSize: _error == null ? 24 : 16, height: 1.25, color: _error == null ? null : OxColors.text2),
            ),
          ),
          const SizedBox(height: 12),
          if (_error == null) Text(l.voiceHint, textAlign: TextAlign.center, style: t.body),
          const SizedBox(height: 32),
          OxButton(label: l.tapToStop, variant: OxButtonVariant.tonal, expand: true, onPressed: _finish),
        ],
      ),
    );
  }
}

/// The listening orb: ember sphere with three expanding rings and a
/// bouncing 5-bar level meter.
class _Orb extends StatefulWidget {
  const _Orb({required this.active});

  final bool active;

  @override
  State<_Orb> createState() => _OrbState();
}

class _OrbState extends State<_Orb> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.reduceMotion ? _c.stop() : _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 200,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              if (widget.active)
                for (final delay in const [0.0, 0.32, 0.64])
                  Builder(builder: (context) {
                    final p = (t + 1 - delay) % 1;
                    return Opacity(
                      opacity: 0.9 * (1 - p),
                      child: Transform.scale(
                        scale: 0.6 + 1.2 * p * 0.5,
                        child: Container(decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0x80FF7A3D), width: 1.5))),
                      ),
                    );
                  }),
              Container(
                width: 132,
                height: 132,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(center: Alignment(-0.3, -0.4), colors: [Color(0xFFFFB085), OxColors.ember, Color(0xFFB43A12)], stops: [0, 0.45, 1]),
                  boxShadow: [BoxShadow(color: Color(0x8CFF7A3D), blurRadius: 60)],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 5,
                children: [
                  for (final (i, h) in const [(0, 22.0), (1, 40.0), (2, 48.0), (3, 34.0), (4, 18.0)])
                    Container(
                      width: 6,
                      height: widget.active ? h * (0.35 + 0.65 * (0.5 + 0.5 * math.sin((t * 2.75 - i * 0.19) * 2 * math.pi))) : h * 0.5,
                      decoration: BoxDecoration(color: OxColors.emberInk, borderRadius: BorderRadius.circular(4)),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

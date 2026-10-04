import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/design.dart';
import '../../core/l10n/l10n.dart';
import '../../core/session/session.dart';
import '../../data/data.dart';
import '../../shared/widgets/widgets.dart';
import '../live/live_providers.dart';

/// What the keypad is for.
enum PinMode {
  /// Unlock locked content or settings.
  verify,

  /// Set a first PIN (enter + confirm).
  create,

  /// Replace the PIN (already unlocked: new + confirm).
  change,
}

/// 24 PinEntry — full-screen keypad. [subject] names what is locked.
class PinEntryView extends ConsumerStatefulWidget {
  const PinEntryView({super.key, required this.mode, required this.onDone, this.subject, this.channel});

  final PinMode mode;

  /// Called with true when unlocked / saved, false when closed.
  final ValueChanged<bool> onDone;
  final String? subject;
  final Channel? channel;

  @override
  ConsumerState<PinEntryView> createState() => _PinEntryViewState();
}

class _PinEntryViewState extends ConsumerState<PinEntryView> with TickerProviderStateMixin {
  static const _length = 4;
  static const _maxTries = 5;

  String _digits = '';
  String? _first;
  String? _error;
  bool _busy = false;
  int _tries = 0;
  DateTime? _blockedUntil;
  Timer? _ticker;
  final _focus = FocusNode();
  late final _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  late final _ring = AnimationController(vsync: this, duration: const Duration(seconds: 2));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focus.requestFocus();
      if (!context.reduceMotion) unawaited(_ring.repeat());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _focus.dispose();
    _shake.dispose();
    _ring.dispose();
    super.dispose();
  }

  bool get _blocked => _blockedUntil != null && DateTime.now().isBefore(_blockedUntil!);

  String _title(AppLocalizations l) => switch (widget.mode) {
    PinMode.verify => l.enterPin,
    PinMode.create || PinMode.change => _first == null ? (widget.mode == PinMode.create ? l.createPin : l.newPin) : l.confirmPin,
  };

  void _type(String d) {
    if (_busy || _blocked || _digits.length >= _length) return;
    unawaited(HapticFeedback.selectionClick());
    setState(() {
      _digits += d;
      _error = null;
    });
    if (_digits.length == _length) unawaited(_submit());
  }

  void _delete() {
    if (_busy || _digits.isEmpty) return;
    setState(() => _digits = _digits.substring(0, _digits.length - 1));
  }

  Future<void> _fail(String message) async {
    unawaited(HapticFeedback.heavyImpact());
    setState(() => _error = message);
    await _shake.forward(from: 0);
    if (mounted) setState(() => _digits = '');
  }

  Future<void> _submit() async {
    final l = context.l10n;
    final parental = ref.read(parentalProvider);
    final pin = _digits;
    setState(() => _busy = true);
    try {
      if (widget.mode == PinMode.verify) {
        if (await parental.verify(pin)) return widget.onDone(true);
        _tries++;
        if (_tries >= _maxTries) {
          _tries = 0;
          _blockedUntil = DateTime.now().add(const Duration(seconds: 30));
          _ticker?.cancel();
          _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
            if (!mounted) return;
            if (!_blocked) t.cancel();
            setState(() {});
          });
        }
        await _fail(l.wrongPin);
      } else if (_first == null) {
        await Future<void>.delayed(const Duration(milliseconds: 160));
        setState(() {
          _first = pin;
          _digits = '';
        });
      } else if (_first == pin) {
        await parental.setPin(pin);
        if (mounted) showOxSnack(context, message: l.pinSaved, icon: OxIcons.check, iconColor: OxColors.ok);
        widget.onDone(true);
      } else {
        _first = null;
        await _fail(l.pinsDontMatch);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// "Forgot PIN?" — the active account's password turns protection off.
  Future<void> _forgot() async {
    final l = context.l10n;
    final account = ref.read(activeAccountProvider).value;
    final creds = account == null ? null : await ref.read(accountRepositoryProvider).credentials(account.id);
    if (!mounted) return;
    final password = creds is XtreamCredentials ? creds.password : null;
    final ok = await showOxDialog<bool>(
      context,
      builder: (_) => _ResetPinDialog(accountName: account?.name ?? '', password: password),
    );
    if (ok != true || !mounted) return;
    await ref.read(parentalProvider).removePin();
    if (!mounted) return;
    showOxSnack(context, message: l.pinRemoved, icon: OxIcons.unlock);
    widget.onDone(true);
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final ch = e.character;
    if (ch != null && RegExp(r'^[0-9]$').hasMatch(ch)) {
      _type(ch);
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.backspace) {
      _delete();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.oxText;
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final wide = size.width > size.height && size.height < 640;
    final remaining = _blocked ? _blockedUntil!.difference(DateTime.now()).inSeconds + 1 : 0;
    final message = _blocked ? l.tryAgainIn(remaining) : _error;

    final emblem = SizedBox(
      width: 84,
      height: 84,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _ring,
            builder: (context, _) => Transform.scale(
              scale: 1 + _ring.value * 0.35,
              child: Opacity(
                opacity: (1 - _ring.value) * 0.9,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0x80FF7A3D), width: 2),
                  ),
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x24FF7A3D),
              border: Border.all(color: OxColors.ember, width: 1.5),
              boxShadow: const [BoxShadow(color: Color(0x59FF7A3D), blurRadius: 40)],
            ),
            child: const OxIcon(OxIcons.lock, size: OxIconSize.xl, color: OxColors.ember),
          ),
        ],
      ),
    );

    final subject = widget.channel != null || widget.subject != null
        ? OxGlass(
            lite: true,
            borderRadius: BorderRadius.circular(OxRadius.pill),
            padding: EdgeInsetsDirectional.fromSTEB(widget.channel != null ? 6 : 14, 5, 14, 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                if (widget.channel != null) OxChannelLogo(name: widget.channel!.name, logoUrl: widget.channel!.logo, size: 24),
                Flexible(
                  child: Text(
                    widget.channel != null ? l.isLocked(widget.channel!.name) : widget.subject!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.small.copyWith(fontWeight: FontWeight.w700, fontSize: 13, color: OxColors.text1),
                  ),
                ),
              ],
            ),
          )
        : null;

    final head = Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        emblem,
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(_title(l), textAlign: TextAlign.center, style: t.h1.copyWith(fontSize: 24)),
        ),
        ?subject,
      ],
    );

    final dots = AnimatedBuilder(
      animation: _shake,
      builder: (context, child) => Transform.translate(offset: Offset(math.sin(_shake.value * math.pi * 6) * 10 * (1 - _shake.value), 0), child: child),
      child: Semantics(
        liveRegion: true,
        label: l.pinDigitsEntered(_digits.length),
        child: ExcludeSemantics(
          child: Row(
            textDirection: TextDirection.ltr,
            mainAxisSize: MainAxisSize.min,
            spacing: 22,
            children: [
              for (var i = 0; i < _length; i++)
                AnimatedContainer(
                  duration: OxMotion.fast,
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _digits.length ? (_error != null ? OxColors.err : OxColors.ember) : null,
                    border: i < _digits.length ? null : Border.all(color: i == _digits.length ? OxColors.text1 : const Color(0x4DFFFFFF), width: 2),
                    boxShadow: i < _digits.length ? const [BoxShadow(color: Color(0xCCFF7A3D), blurRadius: 12)] : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    final status = SizedBox(
      height: 22,
      child: AnimatedSwitcher(
        duration: OxMotion.fast,
        child: message == null
            ? const SizedBox.shrink()
            : Text(
                message,
                key: ValueKey(message),
                textAlign: TextAlign.center,
                style: t.small.copyWith(color: OxColors.errText, fontWeight: FontWeight.w700),
              ),
      ),
    );

    Widget key(String d) => _Key(label: d, onTap: () => _type(d), enabled: !_blocked);
    // Number pads keep 1-2-3 left to right in every language (and the
    // digit dots fill the same way).
    final keypad = Directionality(
      textDirection: TextDirection.ltr,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 14,
          children: [
            for (final row in const [
              ['1', '2', '3'],
              ['4', '5', '6'],
              ['7', '8', '9'],
            ])
              Row(spacing: 18, children: [for (final d in row) Expanded(child: key(d))]),
            Row(
              spacing: 18,
              children: [
                const Expanded(child: SizedBox()),
                Expanded(child: key('0')),
                Expanded(
                  child: _Key(icon: OxIcons.backspace, semanticLabel: l.a11yDelete, onTap: _delete, plain: true, enabled: _digits.isNotEmpty),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    final forgot = widget.mode == PinMode.verify
        ? Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 2,
            children: [
              TextButton(
                onPressed: _forgot,
                style: TextButton.styleFrom(
                  foregroundColor: OxColors.emberHi,
                  textStyle: t.small.copyWith(fontWeight: FontWeight.w800),
                ),
                child: Text(l.forgotPin),
              ),
              Text(l.forgotPinHint, textAlign: TextAlign.center, style: t.caption),
            ],
          )
        : const SizedBox.shrink();

    final body = wide
        ? Row(
            children: [
              Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, spacing: 20, children: [head, dots, status, forgot]),
              ),
              Expanded(child: Center(child: keypad)),
            ],
          )
        : Column(
            children: [
              const Spacer(flex: 2),
              head,
              const Spacer(),
              dots,
              const SizedBox(height: 10),
              status,
              const Spacer(),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 36), child: keypad),
              const Spacer(),
              forgot,
              const SizedBox(height: 24),
            ],
          );

    return Focus(
      focusNode: _focus,
      onKeyEvent: _onKey,
      child: Material(
        color: const Color(0xFF050507),
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(center: Alignment(0, -0.4), radius: 0.9, colors: [Color(0x1FFF7A3D), Color(0x99050507)], stops: [0, 0.7]),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(padding: EdgeInsets.fromLTRB(24, pad.top + 56, 24, pad.bottom + 12), child: body),
            ),
            PositionedDirectional(
              top: pad.top + 8,
              start: 10,
              child: OxIconButton(icon: OxIcons.close, semanticLabel: l.actionCancel, onPressed: () => widget.onDone(false)),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Forgot PIN?" — the account password turns protection off. Owns its
/// text controller, so it outlives the dialog's closing animation.
class _ResetPinDialog extends StatefulWidget {
  const _ResetPinDialog({required this.accountName, required this.password});

  final String accountName;

  /// Null: the account has no password (M3U), so only an explanation.
  final String? password;

  @override
  State<_ResetPinDialog> createState() => _ResetPinDialogState();
}

class _ResetPinDialogState extends State<_ResetPinDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text == widget.password) {
      Navigator.pop(context, true);
    } else {
      setState(() => _error = context.l10n.wrongPassword);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final password = widget.password;
    return OxDialog(
      icon: OxIcons.key,
      title: l.resetPinTitle,
      message: password == null ? l.resetPinNoPassword : l.resetPinBody(widget.accountName),
      content: password == null
          ? null
          : OxTextField(
              controller: _controller,
              label: l.fieldPassword,
              obscure: true,
              autofocus: true,
              status: _error == null ? OxFieldStatus.none : OxFieldStatus.error,
              message: _error,
              ltr: true,
              onSubmitted: (_) => _submit(),
            ),
      actions: [
        OxButton(label: l.actionCancel, variant: OxButtonVariant.ghost, size: OxButtonSize.sm, onPressed: () => Navigator.pop(context, false)),
        if (password != null) OxButton(label: l.actionReset, variant: OxButtonVariant.destructive, size: OxButtonSize.sm, onPressed: _submit),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({this.label, this.icon, this.semanticLabel, required this.onTap, this.plain = false, this.enabled = true});

  final String? label;
  final OxIcons? icon;
  final String? semanticLabel;
  final VoidCallback onTap;
  final bool plain;
  final bool enabled;

  @override
  Widget build(BuildContext context) => OxPressable.builder(
    onTap: enabled ? onTap : null,
    semanticLabel: semanticLabel ?? label,
    pressedScale: 0.94,
    builder: (context, s) => AnimatedContainer(
      duration: OxMotion.fast,
      height: 66,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: plain ? null : (s.pressed ? const Color(0x33FF7A3D) : const Color(0x0FFFFFFF)),
        borderRadius: BorderRadius.circular(22),
        border: plain ? null : Border.all(color: const Color(0x1AFFFFFF)),
        boxShadow: s.focused ? oxFocusRing : null,
      ),
      child: icon != null
          ? OxIcon(icon!, size: OxIconSize.lg, color: enabled ? OxColors.text1 : OxColors.text3)
          : Text(
              label!,
              style: OxTypography.en.h1.copyWith(fontSize: 24, fontWeight: FontWeight.w500, color: enabled ? OxColors.text1 : OxColors.text3),
            ),
    ),
  );
}

/// `/pin?mode=create|change&next=/path` — pops `true` on success, or
/// replaces itself with `next`.
class PinEntryScreen extends StatelessWidget {
  const PinEntryScreen({super.key, this.mode = PinMode.verify, this.next});

  final PinMode mode;
  final String? next;

  @override
  Widget build(BuildContext context) => PinEntryView(
    mode: mode,
    onDone: (ok) {
      if (ok && next != null) {
        context.pushReplacement(next!);
      } else {
        context.pop(ok);
      }
    },
  );
}

/// What a route is about to show, for the parental lock check.
sealed class GateTarget {
  const GateTarget();
}

class ChannelTarget extends GateTarget {
  const ChannelTarget(this.id);
  final String id;
}

class MovieTarget extends GateTarget {
  const MovieTarget(this.id);
  final String id;
}

class SeriesTarget extends GateTarget {
  const SeriesTarget(this.id);
  final String id;
}

/// The parental settings themselves.
class SettingsTarget extends GateTarget {
  const SettingsTarget();
}

/// Null = open; otherwise what to show on the keypad.
typedef _Lock = ({Channel? channel});

Future<_Lock?> _resolveLock(WidgetRef ref, GateTarget target) async {
  final parental = ref.read(parentalProvider);
  if (!await parental.hasPin() || parental.isUnlocked) return null;
  final account = ref.read(activeAccountIdProvider) ?? '';
  final catalog = ref.read(catalogRepositoryProvider);
  final locks = await ref.read(lockRepositoryProvider).watchLocks(account).first;
  switch (target) {
    case SettingsTarget():
      return (channel: null);
    case ChannelTarget(:final id):
      final c = await catalog.channel(account, id);
      return c != null && isChannelLocked(c, locks) ? (channel: c) : null;
    case MovieTarget(:final id):
      final m = await catalog.movie(account, id);
      return m?.categoryId != null && locks.contains((LockKind.movieCategory, m!.categoryId!)) ? (channel: null) : null;
    case SeriesTarget(:final id):
      final s = await catalog.watchShow(account, id).first;
      return s?.categoryId != null && locks.contains((LockKind.seriesCategory, s!.categoryId!)) ? (channel: null) : null;
  }
}

/// Shows [child] only once locked content has been unlocked with the PIN;
/// closing the keypad leaves the route.
class PinGate extends ConsumerStatefulWidget {
  const PinGate({super.key, required this.target, required this.child});

  final GateTarget target;
  final Widget child;

  @override
  ConsumerState<PinGate> createState() => _PinGateState();
}

class _PinGateState extends ConsumerState<PinGate> {
  late final Future<_Lock?> _lock = _resolveLock(ref, widget.target);
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    if (_open) return widget.child;
    return FutureBuilder<_Lock?>(
      future: _lock,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) return const ColoredBox(color: OxColors.ink0);
        if (snap.data == null) return widget.child;
        final l = context.l10n;
        return PinEntryView(
          mode: PinMode.verify,
          channel: snap.data!.channel,
          subject: widget.target is SettingsTarget ? l.parentalLocked : l.contentLocked,
          onDone: (ok) => ok ? setState(() => _open = true) : context.pop(),
        );
      },
    );
  }
}

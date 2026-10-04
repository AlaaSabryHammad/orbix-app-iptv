import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../core/design/design.dart';
import '../../core/l10n/l10n.dart';
import 'navigation.dart';
import 'pressable.dart';

/// `.scrim-full` — rgba(4,4,6,.62) + blur 6, faded by [animation].
class _BlurScrim extends StatelessWidget {
  const _BlurScrim({required this.animation, required this.onTap});

  final Animation<double> animation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final t = animation.value;
          // Blur costs a full-screen pass; skip it once fully transparent.
          if (t == 0) return const SizedBox.expand();
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3 * t, sigmaY: 3 * t),
            child: ColoredBox(color: OxColors.scrim.withValues(alpha: OxColors.scrim.a * t), child: const SizedBox.expand()),
          );
        },
      ),
    );
  }
}

// --- Dialog -----------------------------------------------------------------

enum OxDialogTone { neutral, danger, ember }

/// `.dialog` (C8) — radius 28, Ink #15151C, icon tile, h2 title, body, actions.
class OxDialog extends StatelessWidget {
  const OxDialog({super.key, required this.title, this.message, this.icon, this.tone = OxDialogTone.neutral, this.actions = const [], this.content});

  final String title;
  final String? message;
  final OxIcons? icon;
  final OxDialogTone tone;

  /// Usually two `OxButton(size: sm)`: ghost "Cancel" + the action.
  final List<Widget> actions;

  /// Extra content below the message (e.g. a PIN field).
  final Widget? content;

  @override
  Widget build(BuildContext context) {
    final type = context.oxText;
    final (Color iconBg, Color iconFg) = switch (tone) {
      OxDialogTone.danger => (const Color(0x1FFF6B6B), OxColors.errText),
      OxDialogTone.ember => (OxColors.emberSoft, OxColors.ember),
      OxDialogTone.neutral => (OxColors.ink4, OxColors.text1),
    };
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Container(
        padding: const EdgeInsets.all(OxSpace.s24),
        decoration: BoxDecoration(
          color: OxColors.dialog,
          borderRadius: BorderRadius.circular(OxRadius.xl),
          border: Border.all(color: OxColors.line2),
          boxShadow: OxShadows.dialog,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 14,
          children: [
            if (icon != null)
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(16)),
                child: OxIcon(icon!, color: iconFg),
              ),
            Semantics(header: true, child: Text(title, style: type.h2)),
            if (message != null) Text(message!, style: type.body.copyWith(fontSize: 13.5)),
            ?content,
            if (actions.isNotEmpty)
              // Side by side, end-aligned; stacked when they don't fit.
              OverflowBar(
                alignment: MainAxisAlignment.end,
                overflowAlignment: OverflowBarAlignment.end,
                spacing: 8,
                overflowSpacing: 8,
                children: actions,
              ),
          ],
        ),
      ),
    );
  }
}

/// Shows a dialog over the blurred scrim: fade + scale .96 → 1 (240 ms),
/// fade only under reduced motion.
Future<T?> showOxDialog<T>(BuildContext context, {required WidgetBuilder builder, bool barrierDismissible = true}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: false, // the scrim handles taps itself
    barrierColor: const Color(0x00000000),
    transitionDuration: OxMotion.base,
    pageBuilder: (context, animation, _) => const SizedBox.shrink(),
    transitionBuilder: (dialogContext, animation, _, _) {
      final curved = CurvedAnimation(parent: animation, curve: OxMotion.easeOut);
      final reduce = dialogContext.reduceMotion;
      return Stack(
        children: [
          _BlurScrim(animation: curved, onTap: barrierDismissible ? () => Navigator.of(dialogContext).maybePop() : null),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(OxSpace.s24),
                child: FadeTransition(
                  opacity: curved,
                  child: reduce
                      ? Builder(builder: builder)
                      : ScaleTransition(scale: Tween(begin: 0.96, end: 1.0).animate(curved), child: Builder(builder: builder)),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

// --- Bottom sheet -------------------------------------------------------------

/// Shows an Orbix bottom sheet (C9): rises 40 dp + fades in over 420 ms on a
/// blurred scrim; drag the handle area down (or fling) to dismiss.
Future<T?> showOxSheet<T>(BuildContext context, {required WidgetBuilder builder, String? title}) {
  // Root navigator: the sheet is modal over the whole app, including the nav
  // rail and the floating bottom nav (a tab's own navigator would leave them
  // on top of / beside the sheet).
  return Navigator.of(context, rootNavigator: true).push(_OxSheetRoute<T>(builder: builder, title: title, label: context.l10n.a11yDismiss));
}

class _OxSheetRoute<T> extends PopupRoute<T> {
  _OxSheetRoute({required this.builder, this.title, required this.label});

  final WidgetBuilder builder;
  final String? title;
  final String label;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => label;

  @override
  Duration get transitionDuration => OxMotion.slow;

  @override
  Duration get reverseTransitionDuration => OxMotion.base;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return _SheetFrame(route: this, title: title, child: Builder(builder: builder));
  }
}

class _SheetFrame extends StatefulWidget {
  const _SheetFrame({required this.route, required this.child, this.title});

  final _OxSheetRoute<dynamic> route;
  final Widget child;
  final String? title;

  @override
  State<_SheetFrame> createState() => _SheetFrameState();
}

class _SheetFrameState extends State<_SheetFrame> {
  double _drag = 0;
  final _key = GlobalKey();

  void _onDragUpdate(DragUpdateDetails d) => setState(() => _drag = (_drag + d.delta.dy).clamp(0, double.infinity));

  void _onDragEnd(DragEndDetails d) {
    final h = _key.currentContext?.size?.height ?? 400;
    if (_drag > h * 0.3 || d.velocity.pixelsPerSecond.dy > 700) {
      Navigator.of(context).pop();
    } else {
      setState(() => _drag = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = context.oxText;
    final animation = CurvedAnimation(parent: widget.route.animation!, curve: OxMotion.easeOut);
    final reduce = context.reduceMotion;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final maxH = MediaQuery.sizeOf(context).height * 0.9;

    final sheet = Container(
      key: _key,
      constraints: BoxConstraints(maxHeight: maxH, maxWidth: 640),
      decoration: const BoxDecoration(
        color: OxColors.sheet,
        borderRadius: BorderRadius.vertical(top: Radius.circular(OxRadius.xl)),
        border: Border(top: BorderSide(color: OxColors.line2)),
        boxShadow: OxShadows.sheet,
      ),
      padding: EdgeInsets.fromLTRB(8, 0, 8, 12 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: _onDragUpdate,
            onVerticalDragEnd: _onDragEnd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 10, bottom: 6),
                    decoration: BoxDecoration(color: const Color(0x38FFFFFF), borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                if (widget.title != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                    child: Semantics(header: true, child: Text(widget.title!, style: type.h2)),
                  ),
              ],
            ),
          ),
          Flexible(child: widget.child),
        ],
      ),
    );

    return Stack(
      children: [
        _BlurScrim(animation: animation, onTap: () => Navigator.of(context).maybePop()),
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) => Opacity(
              opacity: animation.value,
              child: Transform.translate(
                offset: Offset(0, (reduce ? 0 : 40 * (1 - animation.value)) + _drag),
                child: child,
              ),
            ),
            child: Material(type: MaterialType.transparency, child: sheet),
          ),
        ),
      ],
    );
  }
}

/// A selectable row inside a sheet (C9 "Sort channels").
class OxSheetOption extends StatelessWidget {
  const OxSheetOption({super.key, required this.label, this.icon, this.selected = false, this.onTap});

  final String label;
  final OxIcons? icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final type = context.oxText;
    final fg = selected ? OxColors.ember : OxColors.text1;
    return OxPressable.builder(
      onTap: onTap,
      selected: selected,
      pressedScale: 0.985,
      builder: (context, s) => AnimatedContainer(
        duration: OxMotion.base,
        constraints: const BoxConstraints(minHeight: 50),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0x1AFF7A3D) : (s.highlighted ? OxColors.glassLite : const Color(0x00000000)),
          borderRadius: BorderRadius.circular(14),
          boxShadow: s.focused ? oxFocusRing : null,
        ),
        child: Row(
          spacing: 14,
          children: [
            if (icon != null) OxIcon(icon!, size: OxIconSize.sm, color: fg),
            Expanded(child: Text(label, style: type.title.copyWith(fontSize: 14))),
            if (selected) const OxIcon(OxIcons.check, size: OxIconSize.sm, color: OxColors.ember),
          ],
        ),
      ),
    );
  }
}

// --- Snackbar ---------------------------------------------------------------

enum OxSnackTone {
  /// Warm-white card, ink text (default feedback: "Added to favorites").
  neutral,

  /// Dark card, halo glyph ("Guide data from 2 sources").
  info,

  /// Deep green ("Account connected").
  success,

  /// Deep red ("Stream unavailable").
  error,
}

/// `.snack` (C10) — 52 dp min, radius 16, glyph + message + optional action.
class OxSnack extends StatelessWidget {
  const OxSnack({super.key, required this.message, this.tone = OxSnackTone.neutral, this.icon, this.iconColor, this.actionLabel, this.onAction});

  final String message;
  final OxSnackTone tone;
  final OxIcons? icon;
  final Color? iconColor;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final type = context.oxText;
    final (Color bg, Color fg, Color? border, Color glyph, Color action) = switch (tone) {
      OxSnackTone.neutral => (OxColors.snack, OxColors.snackInk, null, OxColors.live, OxColors.snackAction),
      OxSnackTone.info => (const Color(0xFF1C1C24), OxColors.text1, const Color(0x1AFFFFFF), OxColors.halo, OxColors.emberHi),
      OxSnackTone.success => (const Color(0xFF10261B), const Color(0xFFCFF5E2), const Color(0x595BD69B), OxColors.ok, OxColors.ok),
      OxSnackTone.error => (const Color(0xFF2A1414), const Color(0xFFFFD6D6), const Color(0x59FF6B6B), OxColors.errText, const Color(0xFFFFB4A0)),
    };

    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: EdgeInsetsDirectional.fromSTEB(16, 10, actionLabel == null ? 16 : 10, 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: border == null ? null : Border.all(color: border),
          boxShadow: OxShadows.snack,
        ),
        child: Row(
          spacing: 12,
          children: [
            if (icon != null) OxIcon(icon!, size: OxIconSize.md, color: iconColor ?? glyph),
            Expanded(
              child: Text(message, style: type.title.copyWith(fontSize: 13.5, height: 1.35, color: fg)),
            ),
            if (actionLabel != null)
              OxPressable(
                onTap: onAction,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Center(
                      widthFactor: 1,
                      child: Text(actionLabel!, style: type.title.copyWith(fontSize: 13.5, fontWeight: FontWeight.w800, color: action)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Shows an [OxSnack] above the bottom nav (C10: 4 s, above nav). A new snack
/// replaces the current one; tapping the action dismisses it.
void showOxSnack(
  BuildContext context, {
  required String message,
  OxSnackTone tone = OxSnackTone.neutral,
  OxIcons? icon,
  Color? iconColor,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 4),
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  final bottom = OxChromeInsets.bottomOf(context);
  final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
  _SnackHost.current?.dismiss();
  late final _SnackHost host;
  final entry = OverlayEntry(
    builder: (_) => _SnackView(
      host: host,
      bottom: (bottom > 0 ? bottom : safeBottom) + 12,
      // The root overlay has no Material above it: without this, text gets
      // Flutter's yellow "missing Material" underline.
      child: Material(
        type: MaterialType.transparency,
        child: OxSnack(
          message: message,
          tone: tone,
          icon: icon,
          iconColor: iconColor,
          actionLabel: actionLabel,
          onAction: onAction == null
              ? null
              : () {
                  host.dismiss();
                  onAction();
                },
        ),
      ),
    ),
  );
  host = _SnackHost(entry, duration);
  overlay.insert(entry);
}

class _SnackHost {
  _SnackHost(this.entry, Duration duration) {
    current = this;
    _timer = Timer(duration, dismiss);
  }

  static _SnackHost? current;

  final OverlayEntry entry;
  late final Timer _timer;
  final ValueNotifier<bool> visible = ValueNotifier(true);
  bool _gone = false;

  void dismiss() {
    if (_gone) return;
    _timer.cancel();
    visible.value = false;
    if (identical(current, this)) current = null;
  }

  void remove() {
    if (_gone) return;
    _gone = true;
    entry.remove();
    visible.dispose();
  }
}

class _SnackView extends StatefulWidget {
  const _SnackView({required this.host, required this.bottom, required this.child});

  final _SnackHost host;
  final double bottom;
  final Widget child;

  @override
  State<_SnackView> createState() => _SnackViewState();
}

class _SnackViewState extends State<_SnackView> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: OxMotion.base, reverseDuration: OxMotion.fast)..forward();

  @override
  void initState() {
    super.initState();
    widget.host.visible.addListener(_onVisible);
  }

  void _onVisible() {
    if (!widget.host.visible.value) _c.reverse().whenComplete(widget.host.remove);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _c, curve: OxMotion.easeOut);
    final reduce = context.reduceMotion;
    return Positioned(
      left: 14,
      right: 14,
      bottom: widget.bottom,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: AnimatedBuilder(
              animation: curved,
              builder: (context, child) => Opacity(
                opacity: curved.value,
                child: Transform.translate(offset: Offset(0, reduce ? 0 : 14 * (1 - curved.value)), child: child),
              ),
              child: Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.down,
                onDismissed: (_) {
                  widget.host.dismiss();
                  widget.host.remove();
                },
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

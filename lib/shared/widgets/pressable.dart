import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/design/design.dart';

/// Interaction state handed to [OxPressable.builder].
@immutable
class OxInteraction {
  const OxInteraction({this.pressed = false, this.hovered = false, this.focused = false, this.enabled = true});

  final bool pressed;
  final bool hovered;

  /// Keyboard / D-pad focus highlight (not merely primary focus).
  final bool focused;
  final bool enabled;

  bool get highlighted => hovered || focused;
}

/// The shared interaction primitive for every Orbix control.
///
/// * press → scale .97 (`.btn:active`, 140 ms ease-out); skipped under
///   reduced motion,
/// * hover / keyboard focus reported to [builder] so each component styles
///   its own highlight (e.g. `.btn-primary:hover` → Ember Hi),
/// * Enter / Space / D-pad centre activate,
/// * disabled (no [onTap] and no [onLongPress]) → 40 % opacity (`.btn[disabled]`).
class OxPressable extends StatefulWidget {
  const OxPressable({
    super.key,
    required Widget this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.97,
    this.semanticLabel,
    this.isButton = true,
    this.selected,
    this.toggled,
    this.focusNode,
    this.autofocus = false,
    this.dimWhenDisabled = true,
    this.behavior = HitTestBehavior.opaque,
  }) : builder = null;

  const OxPressable.builder({
    super.key,
    required Widget Function(BuildContext context, OxInteraction state) this.builder,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.97,
    this.semanticLabel,
    this.isButton = true,
    this.selected,
    this.toggled,
    this.focusNode,
    this.autofocus = false,
    this.dimWhenDisabled = true,
    this.behavior = HitTestBehavior.opaque,
  }) : child = null;

  final Widget? child;
  final Widget Function(BuildContext context, OxInteraction state)? builder;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// 1.0 disables the press scale (e.g. list rows that only tint).
  final double pressedScale;
  final String? semanticLabel;
  final bool isButton;
  final bool? selected;
  final bool? toggled;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool dimWhenDisabled;
  final HitTestBehavior behavior;

  @override
  State<OxPressable> createState() => _OxPressableState();
}

class _OxPressableState extends State<OxPressable> {
  bool _pressed = false;
  bool _hovered = false;
  bool _focused = false;

  bool get _enabled => widget.onTap != null || widget.onLongPress != null;

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  late final Map<Type, Action<Intent>> _actions = {
    ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => widget.onTap?.call()),
    ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(onInvoke: (_) => widget.onTap?.call()),
  };

  static const _shortcuts = <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.select): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.gameButtonA): ActivateIntent(),
  };

  @override
  Widget build(BuildContext context) {
    final enabled = _enabled;
    final state = OxInteraction(
      pressed: _pressed && enabled,
      hovered: _hovered && enabled,
      focused: _focused && enabled,
      enabled: enabled,
    );

    Widget content = widget.builder?.call(context, state) ?? widget.child!;

    if (widget.pressedScale != 1 && !context.reduceMotion) {
      content = AnimatedScale(
        scale: state.pressed ? widget.pressedScale : 1,
        duration: OxMotion.fast,
        curve: OxMotion.easeOut,
        child: content,
      );
    }

    if (!enabled && widget.dimWhenDisabled) {
      content = Opacity(opacity: 0.4, child: content);
    }

    return Semantics(
      button: widget.isButton,
      enabled: enabled,
      selected: widget.selected,
      toggled: widget.toggled,
      label: widget.semanticLabel,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: FocusableActionDetector(
        enabled: enabled,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        actions: _actions,
        shortcuts: _shortcuts,
        mouseCursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        child: GestureDetector(
          behavior: widget.behavior,
          excludeFromSemantics: true,
          onTapDown: enabled ? (_) => _setPressed(true) : null,
          onTapUp: enabled ? (_) => _setPressed(false) : null,
          onTapCancel: enabled ? () => _setPressed(false) : null,
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: content,
        ),
      ),
    );
  }
}

/// The Orbix focus ring — `0 0 0 3px ink-1, 0 0 0 5px text-1` (Components
/// C1 "Focused"). Flutter paints shadows in list order, so the outer ring
/// comes first.
const oxFocusRing = <BoxShadow>[
  BoxShadow(color: OxColors.text1, spreadRadius: 5),
  BoxShadow(color: OxColors.ink1, spreadRadius: 3),
];

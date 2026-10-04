import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/design/design.dart';
import '../../core/l10n/l10n.dart';
import 'buttons.dart';

enum OxFieldStatus { none, valid, error }

/// The inner TextField draws nothing itself — the Orbix box around it does.
/// (`InputDecoration.collapsed` only clears `border`, so the theme's
/// enabled/focused borders and fill would still paint.)
InputDecoration _bare({String? hint, TextStyle? hintStyle, TextDirection? hintDirection}) => InputDecoration(
      isCollapsed: true,
      filled: false,
      contentPadding: EdgeInsets.zero,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      hintText: hint,
      hintStyle: hintStyle,
      hintTextDirection: hintDirection,
    );

/// `.field` + `.input` — labelled 54 dp text field.
///
/// Focus: ember border + 4 dp Ember Soft ring, leading icon turns ember.
/// [OxFieldStatus.valid]: green border + check. [OxFieldStatus.error]: red
/// border + ring and [message] in red. Server URLs, usernames and passwords
/// should set [ltr] so they stay left-to-right in Arabic.
class OxTextField extends StatefulWidget {
  const OxTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.leadingIcon,
    this.trailing,
    this.status = OxFieldStatus.none,
    this.message,
    this.obscure = false,
    this.ltr = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? initialValue;
  final OxIcons? leadingIcon;
  final Widget? trailing;
  final OxFieldStatus status;

  /// Hint below the field (`.hint`); red when [status] is error.
  final String? message;

  /// Password field with a show/hide toggle.
  final bool obscure;
  final bool ltr;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<OxTextField> createState() => _OxTextFieldState();
}

class _OxTextFieldState extends State<OxTextField> {
  late final FocusNode _focus = widget.focusNode ?? FocusNode();
  late final TextEditingController _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
  late bool _hidden = widget.obscure;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  void _onFocus() => setState(() {});

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    if (widget.focusNode == null) _focus.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type = context.oxText;
    final focused = _focus.hasFocus;
    final error = widget.status == OxFieldStatus.error;
    final valid = widget.status == OxFieldStatus.valid;

    final borderColor = error
        ? const Color(0xB3FF6B6B)
        : focused
            ? OxColors.ember
            : valid
                ? OxColors.okBorder
                : OxColors.line2;
    final ring = error
        ? const Color(0x1FFF6B6B)
        : focused
            ? OxColors.emberSoft
            : null;

    final trailing = widget.trailing ??
        (widget.obscure
            ? OxIconButton(
                icon: _hidden ? OxIcons.eye : OxIcons.eyeOff,
                semanticLabel: _hidden ? context.l10n.a11yShowPassword : context.l10n.a11yHidePassword,
                onPressed: () => setState(() => _hidden = !_hidden),
                dimension: 40,
                iconSize: OxIconSize.sm,
                color: OxColors.text3,
              )
            : valid
                ? const OxIcon(OxIcons.check, size: OxIconSize.sm, color: OxColors.ok)
                : null);

    final field = AnimatedContainer(
      duration: OxMotion.fast,
      height: OxSize.input,
      padding: EdgeInsetsDirectional.only(start: 16, end: trailing is OxIconButton ? 6 : 16),
      decoration: BoxDecoration(
        color: OxColors.ink3,
        borderRadius: BorderRadius.circular(OxRadius.md),
        border: Border.all(color: borderColor),
        boxShadow: ring == null ? null : [BoxShadow(color: ring, spreadRadius: 4)],
      ),
      child: Row(
        spacing: 10,
        children: [
          if (widget.leadingIcon != null)
            OxIcon(widget.leadingIcon!, size: OxIconSize.sm, color: focused ? OxColors.ember : OxColors.text3),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              autofocus: widget.autofocus,
              enabled: widget.enabled,
              obscureText: _hidden,
              enableSuggestions: !widget.obscure,
              autocorrect: !widget.obscure && !widget.ltr,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              autofillHints: widget.autofillHints,
              inputFormatters: widget.inputFormatters,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              textDirection: widget.ltr ? TextDirection.ltr : null,
              style: type.title.copyWith(fontWeight: FontWeight.w600, color: OxColors.text1),
              cursorColor: OxColors.ember,
              decoration: _bare(
                hint: widget.hint,
                hintStyle: type.title.copyWith(fontWeight: FontWeight.w500, color: OxColors.text3),
                hintDirection: widget.ltr ? TextDirection.ltr : null,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );

    return Semantics(
      label: widget.label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 7,
        children: [
          if (widget.label != null)
            ExcludeSemantics(
              child: Text(widget.label!, style: type.small.copyWith(fontWeight: FontWeight.w700, color: OxColors.text2)),
            ),
          field,
          if (widget.message != null)
            Text(
              widget.message!,
              style: type.small.copyWith(fontSize: 12, color: error ? OxColors.errText : OxColors.text3),
            ),
        ],
      ),
    );
  }
}

/// `.search` — 50 dp pill. Shows a clear button once there is text,
/// otherwise the voice-search mic (when [onVoice] is set).
class OxSearchField extends StatefulWidget {
  const OxSearchField({
    super.key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onVoice,
    this.focusNode,
    this.autofocus = false,
    this.readOnly = false,
    this.onTap,
  });

  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onVoice;
  final FocusNode? focusNode;
  final bool autofocus;

  /// A tappable entry point that opens the search screen.
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  State<OxSearchField> createState() => _OxSearchFieldState();
}

class _OxSearchFieldState extends State<OxSearchField> {
  late final TextEditingController _controller = widget.controller ?? TextEditingController();
  late final FocusNode _focus = widget.focusNode ?? FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_changed);
    _focus.addListener(_changed);
  }

  void _changed() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_changed);
    _focus.removeListener(_changed);
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type = context.oxText;
    final l = context.l10n;
    final hasText = _controller.text.isNotEmpty;
    final focused = _focus.hasFocus && !widget.readOnly;

    return AnimatedContainer(
      duration: OxMotion.fast,
      height: OxSize.search,
      padding: const EdgeInsetsDirectional.only(start: 16, end: 7),
      decoration: BoxDecoration(
        color: OxColors.ink3,
        borderRadius: BorderRadius.circular(OxRadius.pill),
        border: Border.all(color: focused ? OxColors.ember : OxColors.line2),
        boxShadow: focused ? const [BoxShadow(color: OxColors.emberSoft, spreadRadius: 4)] : null,
      ),
      child: Row(
        spacing: 10,
        children: [
          OxIcon(OxIcons.search, size: OxIconSize.sm, color: focused ? OxColors.text1 : OxColors.text3),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              autofocus: widget.autofocus,
              readOnly: widget.readOnly,
              onTap: widget.onTap,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              textInputAction: TextInputAction.search,
              style: type.title.copyWith(fontWeight: FontWeight.w600, color: OxColors.text1),
              cursorColor: OxColors.ember,
              decoration: _bare(
                hint: widget.hint,
                hintStyle: type.title.copyWith(fontWeight: FontWeight.w600, color: OxColors.text3),
              ),
            ),
          ),
          if (hasText && !widget.readOnly)
            OxIconButton(
              icon: OxIcons.close,
              semanticLabel: l.a11yClear,
              onPressed: () {
                _controller.clear();
                widget.onChanged?.call('');
              },
              dimension: 36,
              round: true,
              iconSize: OxIconSize.sm,
              color: OxColors.text2,
            )
          else if (widget.onVoice != null)
            OxIconButton(
              icon: OxIcons.mic,
              semanticLabel: l.a11yVoiceSearch,
              onPressed: widget.onVoice,
              variant: OxIconButtonVariant.soft,
              dimension: 36,
              round: true,
            ),
        ],
      ),
    );
  }
}

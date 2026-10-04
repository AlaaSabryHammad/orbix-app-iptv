import 'package:flutter/material.dart';

import '../../core/design/design.dart';
import 'glass.dart';
import 'pressable.dart';

enum OxButtonVariant {
  /// Ember fill, ink text, ember glow — the one main action per view.
  primary,

  /// Warm-white fill ("Continue").
  light,

  /// Frosted, for use over artwork ("More info").
  glass,

  /// Ink 4 fill ("Test").
  tonal,

  /// Text only ("Skip", "Cancel").
  ghost,

  /// Soft red ("Delete" in lists).
  danger,

  /// Solid red — confirming a destructive dialog.
  destructive,
}

enum OxButtonSize { sm, md, lg }

/// `.btn` — 38 / 50 / 56 dp, radius 12 / 14 / 16, Manrope 800.
class OxButton extends StatelessWidget {
  const OxButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = OxButtonVariant.primary,
    this.size = OxButtonSize.md,
    this.icon,
    this.trailingIcon,
    this.expand = false,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final OxButtonVariant variant;
  final OxButtonSize size;
  final OxIcons? icon;
  final OxIcons? trailingIcon;

  /// `.btn-block` — fill the available width.
  final bool expand;
  final String? semanticLabel;
  final FocusNode? focusNode;
  final bool autofocus;

  static const _destructiveInk = Color(0xFF2A0606);
  static const _primaryPressed = Color(0xFFE86A30);

  ({double height, double padX, double radius, double gap, double font, double icon}) get _metrics => switch (size) {
        OxButtonSize.sm => (height: OxSize.buttonSm, padX: 16, radius: 12, gap: 8, font: 13.5, icon: OxIconSize.sm),
        OxButtonSize.md => (height: OxSize.buttonMd, padX: 22, radius: OxRadius.md, gap: 10, font: 15, icon: OxIconSize.md),
        OxButtonSize.lg => (height: OxSize.buttonLg, padX: 28, radius: 16, gap: 10, font: 16, icon: OxIconSize.md),
      };

  @override
  Widget build(BuildContext context) {
    final m = _metrics;
    final type = context.oxText;
    final radius = BorderRadius.circular(m.radius);

    return OxPressable.builder(
      onTap: onPressed,
      semanticLabel: semanticLabel,
      focusNode: focusNode,
      autofocus: autofocus,
      builder: (context, s) {
        final (Color bg, Color fg) = switch (variant) {
          OxButtonVariant.primary => (
              s.pressed ? _primaryPressed : (s.highlighted ? OxColors.emberHi : OxColors.ember),
              OxColors.emberInk,
            ),
          OxButtonVariant.light => (OxColors.text1, OxColors.onLight),
          OxButtonVariant.glass => (const Color(0x1AFFFFFF), OxColors.text1),
          OxButtonVariant.tonal => (s.pressed ? OxColors.ink5 : OxColors.ink4, OxColors.text1),
          OxButtonVariant.ghost => (s.highlighted || s.pressed ? OxColors.glassLite : const Color(0x00000000), OxColors.text1),
          OxButtonVariant.danger => (OxColors.errSoft, OxColors.errText),
          OxButtonVariant.destructive => (OxColors.err, _destructiveInk),
        };

        final textStyle = type.title.copyWith(
          fontSize: m.font,
          fontWeight: FontWeight.w800,
          height: 1.2,
          color: fg,
          letterSpacing: type.isArabic ? 0 : m.font * 0.005,
        );

        Widget content = Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: m.gap,
          children: [
            if (icon != null) OxIcon(icon!, size: m.icon, color: fg),
            Flexible(child: Text(label, style: textStyle, maxLines: 1, overflow: TextOverflow.ellipsis)),
            if (trailingIcon != null) OxIcon(trailingIcon!, size: m.icon, color: fg),
          ],
        );

        content = AnimatedContainer(
          duration: OxMotion.base,
          curve: OxMotion.easeOut,
          height: m.height,
          padding: EdgeInsets.symmetric(horizontal: m.padX),
          decoration: BoxDecoration(
            color: variant == OxButtonVariant.glass ? null : bg,
            borderRadius: radius,
            boxShadow: [
              if (s.focused) ...oxFocusRing,
              if (variant == OxButtonVariant.primary && s.enabled) ...OxShadows.emberGlow,
            ],
          ),
          // `inset 0 1px 0 rgba(255,255,255,.3)` top highlight on primary.
          foregroundDecoration: variant == OxButtonVariant.primary
              ? BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: const [Color(0x4DFFFFFF), Color(0x00FFFFFF)],
                    stops: [0, 1.5 / m.height],
                  ),
                )
              : null,
          child: content,
        );

        if (variant == OxButtonVariant.glass) {
          content = OxGlass(
            lite: true,
            borderRadius: radius,
            color: bg,
            borderColor: const Color(0x24FFFFFF),
            shadows: s.focused ? oxFocusRing : null,
            child: content,
          );
        }

        return expand ? SizedBox(width: double.infinity, child: content) : content;
      },
    );
  }
}

enum OxIconButtonVariant {
  /// `.ibtn` — transparent, white 8 % on hover.
  plain,

  /// `.ibtn-tonal` — Ink 4.
  tonal,

  /// `.ibtn-glass` — frosted, over artwork.
  glass,

  /// Ember fill with ink glyph (hero / player play).
  accent,

  /// White 14 % + 25 % border — large player controls over video.
  scrim,

  /// Ember Soft fill with ember glyph (mic in search).
  soft,
}

enum OxIconButtonSize {
  /// 44 dp, radius 14, 24 glyph.
  md,

  /// 56 dp, radius 18, 28 glyph.
  lg,

  /// 76 dp, round, 36 glyph.
  xl,
}

/// `.ibtn` — 44 dp minimum touch target. [semanticLabel] is required because
/// there is no visible text.
class OxIconButton extends StatelessWidget {
  const OxIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.variant = OxIconButtonVariant.plain,
    this.size = OxIconButtonSize.md,
    this.round = false,
    this.color,
    this.dimension,
    this.iconSize,
    this.tooltip = false,
  });

  final OxIcons icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final OxIconButtonVariant variant;
  final OxIconButtonSize size;

  /// `.ibtn-round`. [OxIconButtonSize.xl] is always round.
  final bool round;

  /// Glyph colour override (e.g. ember heart).
  final Color? color;

  /// Box size override (top bar uses 40, search mic 36).
  final double? dimension;
  final double? iconSize;

  /// Show [semanticLabel] as a long-press tooltip.
  final bool tooltip;

  @override
  Widget build(BuildContext context) {
    final (double box, double radius, double glyph) = switch (size) {
      OxIconButtonSize.md => (OxSize.iconButton, 14.0, OxIconSize.base),
      OxIconButtonSize.lg => (OxSize.iconButtonLg, 18.0, OxIconSize.lg),
      OxIconButtonSize.xl => (OxSize.iconButtonXl, OxSize.iconButtonXl / 2, OxIconSize.xl),
    };
    final d = dimension ?? box;
    final g = iconSize ?? (dimension != null && dimension! < box ? OxIconSize.md : glyph);
    final shape = round || size == OxIconButtonSize.xl ? BorderRadius.circular(d / 2) : BorderRadius.circular(radius);

    Widget button = OxPressable.builder(
      onTap: onPressed,
      semanticLabel: semanticLabel,
      pressedScale: 0.94,
      builder: (context, s) {
        final (Color bg, Color fg, Color? border) = switch (variant) {
          OxIconButtonVariant.plain => (s.highlighted || s.pressed ? OxColors.glassLite : const Color(0x00000000), OxColors.text1, null),
          OxIconButtonVariant.tonal => (s.pressed ? OxColors.ink5 : OxColors.ink4, OxColors.text1, null),
          OxIconButtonVariant.glass => (const Color(0x1AFFFFFF), OxColors.text1, OxColors.glassLiteBorder),
          OxIconButtonVariant.accent => (s.highlighted ? OxColors.emberHi : OxColors.ember, OxColors.emberInk, null),
          OxIconButtonVariant.scrim => (const Color(0x24FFFFFF), OxColors.text1, const Color(0x40FFFFFF)),
          OxIconButtonVariant.soft => (OxColors.emberSoft, OxColors.ember, null),
        };

        // Play glyphs are optically centred 3 dp toward the end (CSS margin-left: 3px).
        final nudge = icon == OxIcons.play && variant != OxIconButtonVariant.plain ? g * 3 / 28 : 0.0;

        final glyphWidget = Padding(
          padding: EdgeInsets.only(left: nudge),
          child: OxIcon(icon, size: g, color: color ?? fg),
        );

        Widget body = AnimatedContainer(
          duration: OxMotion.fast,
          width: d,
          height: d,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: variant == OxIconButtonVariant.glass ? null : bg,
            borderRadius: shape,
            border: border == null || variant == OxIconButtonVariant.glass ? null : Border.all(color: border),
            boxShadow: s.focused ? oxFocusRing : null,
          ),
          child: glyphWidget,
        );
        if (variant == OxIconButtonVariant.glass) {
          body = OxGlass(lite: true, borderRadius: shape, color: bg, borderColor: border, child: body);
        }
        return body;
      },
    );

    if (tooltip) button = Tooltip(message: semanticLabel, child: button);
    return button;
  }
}

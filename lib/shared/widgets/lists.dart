import 'package:flutter/material.dart';

import '../../core/design/design.dart';
import 'pressable.dart';

/// `.group` — Ink 2 card (radius 20) holding [OxListRow]s with hairlines
/// between them (Settings).
class OxGroup extends StatelessWidget {
  const OxGroup({super.key, required this.children, this.padding});

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (final c in children) {
      if (rows.isNotEmpty) rows.add(const Divider());
      rows.add(c);
    }
    return Container(
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: OxColors.ink2,
        borderRadius: BorderRadius.circular(OxRadius.lg),
        border: Border.all(color: OxColors.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
    );
  }
}

/// `.row` — 60 dp settings/list row: icon tile, title + caption, value,
/// trailing control. [chevron] adds the (RTL-mirrored) disclosure arrow.
class OxListRow extends StatelessWidget {
  const OxListRow({
    super.key,
    required this.title,
    this.icon,
    this.iconColor,
    this.iconBackground,
    this.leading,
    this.subtitle,
    this.value,
    this.trailing,
    this.chevron = false,
    this.onTap,
    this.destructive = false,
  });

  final String title;
  final OxIcons? icon;
  final Color? iconColor;

  /// Icon box fill (default Ink 4; e.g. amber for Parental controls).
  final Color? iconBackground;

  /// Replaces the icon box (e.g. a channel logo).
  final Widget? leading;
  final String? subtitle;
  final String? value;
  final Widget? trailing;
  final bool chevron;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final type = context.oxText;
    final titleColor = destructive ? OxColors.errText : OxColors.text1;

    Widget row(OxInteraction s) => AnimatedContainer(
          duration: OxMotion.fast,
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: s.pressed || s.highlighted ? OxColors.glassLite.withValues(alpha: 0.04) : const Color(0x00000000),
          child: LayoutBuilder(
            builder: (context, c) => Row(
              spacing: 14,
              children: [
                ?leading,
                if (icon != null && leading == null)
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: destructive ? OxColors.errSoft : (iconBackground ?? OxColors.ink4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: OxIcon(icon!, size: OxIconSize.sm, color: iconColor ?? titleColor),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: type.title.copyWith(color: titleColor)),
                      if (subtitle != null) Text(subtitle!, style: type.caption),
                    ],
                  ),
                ),
                if (value != null)
                  ConstrainedBox(
                    // Values keep their natural width, up to half the row.
                    constraints: BoxConstraints(maxWidth: c.maxWidth * 0.5),
                    child: Text(
                      value!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: type.small.copyWith(fontSize: 13, fontWeight: FontWeight.w700, color: OxColors.text3),
                    ),
                  ),
                ?trailing,
                if (chevron) const OxIcon(OxIcons.chevR, size: OxIconSize.sm, color: OxColors.text3),
              ],
            ),
          ),
        );

    if (onTap == null) {
      return Semantics(container: true, child: row(const OxInteraction(enabled: false)));
    }
    return OxPressable.builder(
      onTap: onTap,
      pressedScale: 1,
      builder: (context, s) => DecoratedBox(
        decoration: BoxDecoration(boxShadow: s.focused ? oxFocusRing : null),
        child: row(s),
      ),
    );
  }
}

/// `.rail-head` — section title with an optional "See all ›" action.
class OxSectionHeader extends StatelessWidget {
  const OxSectionHeader({
    super.key,
    required this.title,
    this.leading,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.symmetric(horizontal: OxSpace.phoneGutter),
  });

  final String title;

  /// e.g. [OxLiveDot] before "Live now".
  final Widget? leading;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final type = context.oxText;
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Row(
                spacing: 10,
                children: [
                  ?leading,
                  Flexible(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: type.h2)),
                ],
              ),
            ),
          ),
          if (actionLabel != null)
            OxPressable(
              onTap: onAction,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: [
                    Text(actionLabel!, style: type.small.copyWith(fontWeight: FontWeight.w700, color: OxColors.text2)),
                    const OxIcon(OxIcons.chevR, size: OxIconSize.xs, color: OxColors.text2),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// `.rail` — horizontally scrolling row of cards, 12 dp apart, inset by the
/// gutter. Lazily built.
class OxRail extends StatelessWidget {
  const OxRail({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.height,
    this.spacing = OxSpace.s12,
    this.padding = const EdgeInsets.symmetric(horizontal: OxSpace.phoneGutter),
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double height;
  final double spacing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        clipBehavior: Clip.none,
        itemCount: itemCount,
        separatorBuilder: (_, _) => SizedBox(width: spacing),
        itemBuilder: itemBuilder,
      ),
    );
  }
}

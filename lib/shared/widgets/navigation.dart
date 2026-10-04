import 'package:flutter/material.dart';

import '../../core/design/design.dart';
import 'brand.dart';
import 'glass.dart';
import 'pressable.dart';

/// A destination in [OxBottomNav] / [OxNavRail].
@immutable
class OxNavItem {
  const OxNavItem({required this.icon, required this.label});

  final OxIcons icon;
  final String label;
}

/// `.bnav` — the floating glass bottom bar (<600 dp).
///
/// Active item: Ember Soft pill + ember glyph + a glowing 4 dp ember dot
/// above. Below 380 dp it switches to the compact small-phone variant
/// (CompactHome spec): 62 dp tall, label shown on the active item only.
///
/// This is the bar itself; [AppShell]-style hosts place it with [marginOf]
/// and reserve [occupiedHeight] at the bottom of scrolling content.
class OxBottomNav extends StatelessWidget {
  const OxBottomNav({super.key, required this.items, required this.currentIndex, required this.onTap, this.compact});

  final List<OxNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Null = automatic (window narrower than 380 dp).
  final bool? compact;

  static const compactBelow = 380.0;

  static bool isCompact(BuildContext context) => MediaQuery.sizeOf(context).width < compactBelow;

  static double barHeight(bool compact) => compact ? 62 : OxSize.bottomNav;

  /// Floating inset: 12 / 14 dp (10 / 10 compact). With gesture navigation
  /// the bar sits over the handle area like the spec; with 3-button
  /// navigation it rises above the buttons.
  static EdgeInsets marginOf(BuildContext context, {bool? compact}) {
    final c = compact ?? isCompact(context);
    final inset = MediaQuery.viewPaddingOf(context).bottom;
    final base = c ? 10.0 : 14.0;
    final bottom = inset > 32 ? inset + 8 : base;
    return EdgeInsets.fromLTRB(c ? 10 : 12, 0, c ? 10 : 12, bottom);
  }

  /// Space the bar covers at the bottom of the screen.
  static double occupiedHeight(BuildContext context) {
    final c = isCompact(context);
    return barHeight(c) + marginOf(context, compact: c).bottom;
  }

  @override
  Widget build(BuildContext context) {
    final c = compact ?? isCompact(context);
    return OxGlass(
      borderRadius: BorderRadius.circular(c ? 22 : 24),
      shadows: OxShadows.bottomNav,
      child: SizedBox(
        height: barHeight(c),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _BottomNavButton(item: items[i], active: i == currentIndex, compact: c, onTap: () => onTap(i)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavButton extends StatelessWidget {
  const _BottomNavButton({required this.item, required this.active, required this.compact, required this.onTap});

  final OxNavItem item;
  final bool active;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final type = context.oxText;
    final showLabel = !compact || active;
    final pillW = compact && active ? 48.0 : 52.0;
    final pillH = compact && active ? 28.0 : 30.0;

    return OxPressable.builder(
      onTap: onTap,
      selected: active,
      semanticLabel: item.label,
      pressedScale: 0.94,
      builder: (context, s) => ExcludeSemantics(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(padding: EdgeInsets.only(top: compact ? 0 : 2)),
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                AnimatedContainer(
                  duration: OxMotion.base,
                  curve: OxMotion.easeOut,
                  width: pillW,
                  height: pillH,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active ? OxColors.emberSoft : (s.highlighted ? OxColors.glassLite : const Color(0x00000000)),
                    borderRadius: BorderRadius.circular(pillH / 2),
                    boxShadow: s.focused ? oxFocusRing : null,
                  ),
                  child: OxIcon(
                    item.icon,
                    size: compact ? OxIconSize.md : OxIconSize.base,
                    color: active ? OxColors.ember : OxColors.text3,
                  ),
                ),
                // The orbit dot: 4 dp, 9 dp above the pill, ember glow.
                Positioned(
                  top: -9,
                  child: AnimatedOpacity(
                    duration: OxMotion.base,
                    opacity: active ? 1 : 0,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: OxColors.ember,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Color(0xB3FF7A3D), blurRadius: 10, spreadRadius: 2)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (showLabel) SizedBox(height: compact ? 3 : 4),
            if (showLabel)
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: type.caption.copyWith(
                  fontSize: compact ? 10 : (type.isArabic ? 11 : 10.5),
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: active ? OxColors.text1 : OxColors.text3,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// `.rail-nav` — 96 dp navigation rail (≥600 dp) on Ink 0 with a hairline at
/// the inline end. [footer] items sit at the bottom (Settings); indices run
/// across [items] then [footer].
class OxNavRail extends StatelessWidget {
  const OxNavRail({
    super.key,
    required this.items,
    this.footer = const [],
    required this.currentIndex,
    required this.onTap,
    this.leading = const OxLogoMark(size: 34),
  });

  final List<OxNavItem> items;
  final List<OxNavItem> footer;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final dir = Directionality.of(context);
    final startInset = dir == TextDirection.ltr ? pad.left : pad.right;

    Widget button(int i, OxNavItem item) =>
        _RailButton(item: item, active: i == currentIndex, onTap: () => onTap(i));

    return Container(
      width: OxSize.navRail + startInset,
      padding: EdgeInsetsDirectional.only(start: startInset),
      decoration: const BoxDecoration(
        color: OxColors.ink0,
        border: BorderDirectional(end: BorderSide(color: OxColors.line)),
      ),
      // Footer pinned to the bottom when everything fits; on short windows
      // (a phone in landscape) the whole rail scrolls instead of overflowing.
      child: LayoutBuilder(
        builder: (context, c) => SingleChildScrollView(
          padding: EdgeInsets.only(top: 24 + pad.top, bottom: 24 + pad.bottom),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: (c.maxHeight - 48 - pad.vertical).clamp(0, double.infinity)),
            child: IntrinsicHeight(
              child: Column(
                spacing: 6,
                children: [
                  if (leading != null) Padding(padding: const EdgeInsets.only(bottom: 22 - 6), child: leading),
                  for (var i = 0; i < items.length; i++) button(i, items[i]),
                  const Spacer(),
                  for (var i = 0; i < footer.length; i++) button(items.length + i, footer[i]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({required this.item, required this.active, required this.onTap});

  final OxNavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final type = context.oxText;
    return OxPressable.builder(
      onTap: onTap,
      selected: active,
      semanticLabel: item.label,
      pressedScale: 0.94,
      builder: (context, s) => ExcludeSemantics(
        child: Container(
          width: 80,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: s.focused ? oxFocusRing : null,
            color: s.focused ? OxColors.ink0 : null,
          ),
          child: Column(
            spacing: 5,
            children: [
              AnimatedContainer(
                duration: OxMotion.base,
                curve: OxMotion.easeOut,
                width: 56,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? OxColors.emberSoft : (s.hovered ? OxColors.glassLite : const Color(0x00000000)),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: OxIcon(item.icon, color: active ? OxColors.ember : OxColors.text3),
              ),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: type.caption.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: active ? OxColors.text1 : OxColors.text3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// `.topbar` — 58 dp bar under the status bar: brand (or [leading]) at the
/// start, icon actions at the end. [scrim] fades Ink 1 down over artwork.
class OxTopBar extends StatelessWidget {
  const OxTopBar({super.key, this.leading = const OxBrandLockup(), this.actions = const [], this.scrim = false});

  final Widget? leading;
  final List<Widget> actions;
  final bool scrim;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      height: 58 + top,
      padding: EdgeInsetsDirectional.only(start: 20, end: 12, top: top),
      decoration: scrim
          ? const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xD908080B), Color(0x0008080B)],
              ),
            )
          : null,
      child: Row(
        spacing: 2,
        children: [
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: leading),
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

/// Bottom space reserved by floating chrome (the bottom nav), read by
/// [showOxSnack] so toasts rise above the bar. Provided by the app shell.
class OxChromeInsets extends InheritedWidget {
  const OxChromeInsets({super.key, required this.bottom, required super.child});

  final double bottom;

  static double bottomOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<OxChromeInsets>()?.bottom ?? 0;

  @override
  bool updateShouldNotify(OxChromeInsets old) => old.bottom != bottom;
}

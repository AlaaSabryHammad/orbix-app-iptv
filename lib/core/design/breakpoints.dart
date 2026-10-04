import 'dart:ui' show DisplayFeatureType;

import 'package:flutter/widgets.dart';

import 'tokens.dart';

/// Window size classes (Foundations §05).
///
/// * compact  <600 dp — phones, folded screens: floating bottom nav.
/// * medium   600–839 — foldables, 7″ tablets: nav rail, two panes.
/// * expanded ≥840    — 10″ tablets: nav rail, three-pane Live TV.
enum OxWindowSize {
  compact,
  medium,
  expanded;

  static OxWindowSize fromWidth(double width) => width >= OxBreakpoints.expanded
      ? expanded
      : width >= OxBreakpoints.medium
          ? medium
          : compact;

  static OxWindowSize of(BuildContext context) => fromWidth(MediaQuery.sizeOf(context).width);

  bool get hasNavRail => this != compact;

  /// Default horizontal page inset. Individual panes may use their own
  /// (the foldable panes use 24–28 in the HTML specs).
  double get gutter => this == compact ? OxSpace.phoneGutter : OxSpace.tabletGutter;
}

/// The vertical hinge or fold of an unfolded book-style device, in logical
/// pixels — two-pane layouts split here. Null on regular screens.
///
/// An unfolded inner display can be ≥840 dp wide (the 884 dp foldable spec),
/// so two-pane is decided by this, not by [OxWindowSize] alone.
Rect? oxVerticalHinge(BuildContext context) {
  for (final f in MediaQuery.displayFeaturesOf(context)) {
    final isSeam = f.type == DisplayFeatureType.hinge || f.type == DisplayFeatureType.fold;
    if (isSeam && f.bounds.height > f.bounds.width) return f.bounds;
  }
  return null;
}

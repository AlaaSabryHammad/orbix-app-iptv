import 'package:flutter/widgets.dart';

import '../../core/design/design.dart';
import 'pressable.dart';

enum OxChipTone {
  /// Ink 3 fill; warm white when [OxChip.selected].
  neutral,

  /// Ember Soft — an applied filter you can remove ("2026 ×").
  ember,
}

/// `.chip` — 36 dp (30 dp [small]) pill filter.
class OxChip extends StatelessWidget {
  const OxChip({
    super.key,
    required this.label,
    this.onTap,
    this.selected = false,
    this.tone = OxChipTone.neutral,
    this.small = false,
    this.icon,
    this.trailingIcon,
    this.count,
  });

  final String label;
  final VoidCallback? onTap;
  final bool selected;
  final OxChipTone tone;
  final bool small;
  final OxIcons? icon;
  final OxIcons? trailingIcon;

  /// Secondary number at 60 % opacity ("Sports 142").
  final String? count;

  @override
  Widget build(BuildContext context) {
    final type = context.oxText;
    final ember = tone == OxChipTone.ember;
    final (Color bg, Color fg, Color border) = selected
        ? (OxColors.text1, OxColors.onChipOn, const Color(0x00000000))
        : ember
            ? (OxColors.emberSoft, OxColors.emberHi, const Color(0x4DFF7A3D))
            : (OxColors.ink3, OxColors.text2, OxColors.line);

    final style = type.title.copyWith(fontSize: small ? 12 : 13, fontWeight: FontWeight.w700, height: 1.2, color: fg);

    return OxPressable.builder(
      onTap: onTap,
      selected: selected,
      dimWhenDisabled: false,
      builder: (context, s) => AnimatedContainer(
        duration: OxMotion.base,
        curve: OxMotion.easeOut,
        height: small ? OxSize.chipSm : OxSize.chip,
        padding: EdgeInsets.symmetric(horizontal: small ? 12 : 15),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(OxRadius.pill),
          border: Border.all(color: border),
          boxShadow: s.focused ? oxFocusRing : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            if (icon != null) OxIcon(icon!, size: OxIconSize.xs, color: fg),
            Text(label, style: style),
            if (count != null) Opacity(opacity: 0.6, child: Text(count!, style: style)),
            if (trailingIcon != null) OxIcon(trailingIcon!, size: OxIconSize.xs, color: fg),
          ],
        ),
      ),
    );
  }
}

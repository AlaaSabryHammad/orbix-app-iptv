import 'package:flutter/widgets.dart';

/// Direction of [text] from its first strong character (Unicode bidi P2),
/// or null when it has none (numbers, punctuation).
TextDirection? oxDirectionOf(String text) {
  for (final r in text.runes) {
    if (_isRtl(r)) return TextDirection.rtl;
    if (_isLtr(r)) return TextDirection.ltr;
  }
  return null;
}

bool _isRtl(int r) =>
    (r >= 0x0590 && r <= 0x08FF) || // Hebrew, Arabic, Syriac, Thaana, NKo, Arabic ext.
    (r >= 0xFB1D && r <= 0xFDFF) || // Hebrew + Arabic presentation forms A
    (r >= 0xFE70 && r <= 0xFEFF); // Arabic presentation forms B

bool _isLtr(int r) =>
    (r >= 0x41 && r <= 0x5A) ||
    (r >= 0x61 && r <= 0x7A) ||
    (r >= 0xC0 && r <= 0x24F && r != 0xD7 && r != 0xF7) || // Latin-1 + extended letters
    (r >= 0x370 && r <= 0x52F) || // Greek, Cyrillic
    (r >= 0x1E00 && r <= 0x1FFF) || // Latin / Greek extended
    (r >= 0x3040 && r <= 0x9FFF) || // Kana, CJK
    (r >= 0xAC00 && r <= 0xD7AF); // Hangul

/// Text that comes from the user's playlist (channel names, programme and
/// movie titles). It is laid out in its own direction — so a Latin title in
/// the Arabic UI ellipsizes at its end — but aligned to the layout's start
/// edge like the surrounding UI.
class OxContentText extends StatelessWidget {
  const OxContentText(
    this.text, {
    super.key,
    this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.align,
  }) : paragraph = false;

  /// Descriptions and plots: many lines, laid out and aligned in the text's
  /// own direction — an English plot in the Arabic UI reads left-aligned,
  /// with its full stop and ellipsis at the end where they belong.
  const OxContentText.paragraph(this.text, {super.key, this.style, this.maxLines, this.overflow = TextOverflow.ellipsis})
      : align = null,
        paragraph = true;

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow overflow;

  /// Defaults to the layout's start edge.
  final TextAlign? align;
  final bool paragraph;

  @override
  Widget build(BuildContext context) {
    final layout = Directionality.of(context);
    final dir = oxDirectionOf(text) ?? layout;
    if (paragraph) return Text(text, style: style, maxLines: maxLines, overflow: maxLines == null ? null : overflow, textDirection: dir, textAlign: TextAlign.start);
    final start = layout == TextDirection.rtl ? TextAlign.right : TextAlign.left;
    final end = layout == TextDirection.rtl ? TextAlign.left : TextAlign.right;
    final textAlign = switch (align) {
      null || TextAlign.start => start,
      TextAlign.end => end,
      final a => a,
    };
    return Text(text, style: style, maxLines: maxLines, overflow: overflow, textDirection: dir, textAlign: textAlign);
  }
}

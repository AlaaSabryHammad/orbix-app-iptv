import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'motion.dart';
import 'tokens.dart';
import 'typography.dart';

/// Orbix theme — dark only.
///
/// Material roles are mapped onto the Ink/Ember/Halo tokens so stock widgets
/// (text selection, scrollbars, progress, raw TextFields…) look on-brand, but
/// Orbix screens are built from `shared/widgets` components that read
/// [OxTokens.of] / [OxTypography] directly.
abstract final class OrbixTheme {
  static final _cache = <(OxTypography, bool), ThemeData>{};

  /// The theme for [locale]'s script (EN or AR typography). Memoised.
  /// [amoled] (Settings › Theme › AMOLED black) paints screens pure black.
  static ThemeData dark([Locale locale = const Locale('en'), bool amoled = false]) {
    final type = OxTypography.forLocale(locale);
    return _cache.putIfAbsent((type, amoled), () {
      final base = _build(type);
      return amoled ? base.copyWith(scaffoldBackgroundColor: const Color(0xFF000000), canvasColor: const Color(0xFF000000)) : base;
    });
  }

  static ThemeData _build(OxTypography type) {

    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: OxColors.ember,
      onPrimary: OxColors.emberInk,
      primaryContainer: OxColors.emberSoft,
      onPrimaryContainer: OxColors.emberHi,
      secondary: OxColors.halo,
      onSecondary: OxColors.ink0,
      secondaryContainer: OxColors.haloSoft,
      onSecondaryContainer: OxColors.halo,
      tertiary: OxColors.ok,
      onTertiary: OxColors.ink0,
      error: OxColors.err,
      onError: OxColors.ink0,
      errorContainer: OxColors.errSoft,
      onErrorContainer: OxColors.errText,
      surface: OxColors.ink1,
      onSurface: OxColors.text1,
      onSurfaceVariant: OxColors.text2,
      surfaceDim: OxColors.ink0,
      surfaceBright: OxColors.ink5,
      surfaceContainerLowest: OxColors.ink0,
      surfaceContainerLow: OxColors.ink2,
      surfaceContainer: OxColors.ink3,
      surfaceContainerHigh: OxColors.ink4,
      surfaceContainerHighest: OxColors.ink5,
      outline: OxColors.line2,
      outlineVariant: OxColors.line,
      shadow: Color(0xFF000000),
      scrim: OxColors.scrim,
      inverseSurface: OxColors.snack,
      onInverseSurface: OxColors.snackInk,
      inversePrimary: OxColors.snackAction,
      surfaceTint: Color(0x00000000),
    );

    final textTheme = TextTheme(
      displayLarge: type.hero,
      displayMedium: type.display,
      headlineSmall: type.h1,
      titleLarge: type.h2,
      titleMedium: type.title,
      titleSmall: type.title.copyWith(fontSize: 14),
      bodyLarge: type.body.copyWith(color: OxColors.text1),
      bodyMedium: type.body,
      bodySmall: type.small,
      labelLarge: type.title.copyWith(fontWeight: FontWeight.w800), // .btn
      labelMedium: type.small,
      labelSmall: type.caption,
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(OxRadius.md),
      borderSide: const BorderSide(color: OxColors.line2),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      textTheme: textTheme,
      fontFamily: type.body.fontFamily,
      fontFamilyFallback: type.body.fontFamilyFallback,
      scaffoldBackgroundColor: OxColors.ink1,
      canvasColor: OxColors.ink1,
      // Orbix feedback is scale-on-press (.btn:active, .poster:active), not ink.
      splashFactory: NoSplash.splashFactory,
      splashColor: const Color(0x00000000),
      highlightColor: const Color(0x00000000),
      hoverColor: OxColors.glassLite, // .ibtn:hover rgba(255,255,255,.08)
      focusColor: OxColors.emberSoft,
      iconTheme: const IconThemeData(color: OxColors.text1, size: OxIconSize.base),
      dividerTheme: const DividerThemeData(color: OxColors.line, thickness: 1, space: 1),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: OxColors.ember,
        selectionColor: OxColors.emberSoft,
        selectionHandleColor: OxColors.ember,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: OxColors.ember,
        linearTrackColor: OxColors.progressTrack,
        linearMinHeight: OxSize.progress,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: OxColors.ink3,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        hintStyle: type.title.copyWith(color: OxColors.text3, fontWeight: FontWeight.w500),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(borderSide: const BorderSide(color: OxColors.ember)),
        errorBorder: inputBorder.copyWith(borderSide: const BorderSide(color: Color(0xB3FF6B6B))),
        focusedErrorBorder: inputBorder.copyWith(borderSide: const BorderSide(color: Color(0xB3FF6B6B))),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: OxColors.snack,
        contentTextStyle: type.title.copyWith(fontSize: 13.5, color: OxColors.snackInk),
        actionTextColor: OxColors.snackAction,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: OxColors.sheet,
        modalBackgroundColor: OxColors.sheet,
        modalBarrierColor: OxColors.scrim,
        dragHandleColor: Color(0x38FFFFFF), // .sheet .handle 22%
        dragHandleSize: Size(40, 4),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(OxRadius.xl)),
          side: BorderSide(color: OxColors.line2),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: OxColors.dialog,
        barrierColor: OxColors.scrim,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OxRadius.xl),
          side: const BorderSide(color: OxColors.line2),
        ),
        titleTextStyle: type.h2,
        contentTextStyle: type.body,
      ),
      scrollbarTheme: const ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(OxColors.line2),
        radius: Radius.circular(OxRadius.pill),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0x00000000),
        foregroundColor: OxColors.text1,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: type.h1,
        systemOverlayStyle: overlayStyle,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {TargetPlatform.android: OxPageTransitionsBuilder()},
      ),
      extensions: [OxTokens(typography: type)],
    );
  }

  /// Edge-to-edge, transparent bars, light icons — set on app start and by
  /// any AppBar.
  static const overlayStyle = SystemUiOverlayStyle(
    statusBarColor: Color(0x00000000),
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Color(0x00000000),
    systemNavigationBarDividerColor: Color(0x00000000),
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarContrastEnforced: false,
  );
}

/// Theme-carried design values that depend on locale. Colours, sizes and
/// motion are locale-independent consts — use [OxColors] etc. directly.
@immutable
class OxTokens extends ThemeExtension<OxTokens> {
  const OxTokens({required this.typography});

  final OxTypography typography;

  static OxTokens of(BuildContext context) => Theme.of(context).extension<OxTokens>()!;

  @override
  OxTokens copyWith({OxTypography? typography}) => OxTokens(typography: typography ?? this.typography);

  @override
  OxTokens lerp(OxTokens? other, double t) => t < 0.5 || other == null ? this : other;
}

extension OxThemeContext on BuildContext {
  /// The locale-aware type scale: `context.oxText.h1`.
  OxTypography get oxText => OxTokens.of(this).typography;
}

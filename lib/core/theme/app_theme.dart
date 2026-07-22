import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography (06_DESIGN_SYSTEM.md §2): Inter for UI text, **JetBrains Mono for
/// every numeric value** so amounts are always scannable. Weights 400/500/600 —
/// no bold, keeping the calm financial tone. The font families fall back to the
/// platform default until the TTFs are bundled as assets.
abstract final class AppFonts {
  static const ui = 'Inter';
  static const mono = 'JetBrainsMono';
}

/// The monospace text style used for all figures (amounts, weights, dates in
/// ledgers). Callers set size/color/weight; family + tabular feel stay constant.
const kMonoFamilyFallback = <String>['monospace'];

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light, AppColors.light);
  static ThemeData dark() => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors c) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: c.canvas,
      canvasColor: c.canvas,
      colorScheme: base.colorScheme.copyWith(
        brightness: brightness,
        primary: c.primary,
        surface: c.card,
        error: c.semanticDown,
      ),
      extensions: [c],
      textTheme: _textTheme(base.textTheme, c),
      dividerColor: c.hairline,
      appBarTheme: AppBarTheme(
        backgroundColor: c.canvas,
        foregroundColor: c.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.ui,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: c.ink,
        ),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, AppColors c) {
    TextStyle ui(double size, FontWeight w, Color color) => TextStyle(
          fontFamily: AppFonts.ui,
          fontSize: size,
          fontWeight: w,
          color: color,
          height: 1.25,
        );
    return base.copyWith(
      headlineMedium: ui(28, FontWeight.w600, c.ink),
      titleLarge: ui(20, FontWeight.w600, c.ink),
      titleMedium: ui(16, FontWeight.w600, c.ink),
      bodyLarge: ui(15, FontWeight.w400, c.body),
      bodyMedium: ui(14, FontWeight.w400, c.body),
      labelLarge: ui(14, FontWeight.w500, c.ink),
      labelSmall: ui(11, FontWeight.w500, c.muted),
    );
  }
}

/// A monospace [TextStyle] for figures. Use everywhere a number is shown.
TextStyle monoStyle({
  required double size,
  FontWeight weight = FontWeight.w500,
  required Color color,
  double? letterSpacing,
}) =>
    TextStyle(
      fontFamily: AppFonts.mono,
      fontFamilyFallback: kMonoFamilyFallback,
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

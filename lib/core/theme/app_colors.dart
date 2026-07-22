import 'package:flutter/material.dart';

/// The validated design-system palette (06_DESIGN_SYSTEM.md §1). Coinbase Blue
/// (`#0052ff`) is the ONLY accent; semantic green/red are reserved strictly for
/// financial polarity (receivable/profit vs payable/loss), never decoration.
///
/// Exposed as a [ThemeExtension] so widgets read tokens via
/// `Theme.of(context).extension<AppColors>()!` and both themes stay in sync.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color canvas;
  final Color card;
  final Color surfaceSoft;
  final Color surfaceStrong;

  /// Always-dark net-worth card (identical in both themes — it anchors the most
  /// important number with the highest contrast).
  final Color surfaceDark;
  final Color surfaceDarkElevated;

  final Color ink;
  final Color body;
  final Color muted;
  final Color hairline;
  final Color hairlineSoft;

  final Color primary;
  final Color onDarkSoft;

  final Color semanticUp; // receivable, profit
  final Color semanticDown; // payable, loss

  const AppColors({
    required this.canvas,
    required this.card,
    required this.surfaceSoft,
    required this.surfaceStrong,
    required this.surfaceDark,
    required this.surfaceDarkElevated,
    required this.ink,
    required this.body,
    required this.muted,
    required this.hairline,
    required this.hairlineSoft,
    required this.primary,
    required this.onDarkSoft,
    required this.semanticUp,
    required this.semanticDown,
  });

  static const _blue = Color(0xFF0052FF);

  static const light = AppColors(
    canvas: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    surfaceSoft: Color(0xFFF5F6F8),
    surfaceStrong: Color(0xFFEEF0F3),
    surfaceDark: Color(0xFF0A0B0D),
    surfaceDarkElevated: Color(0xFF1A1C1F),
    ink: Color(0xFF0A0B0D),
    body: Color(0xFF5B616E),
    muted: Color(0xFF7C828A),
    hairline: Color(0xFFDEE1E6),
    hairlineSoft: Color(0xFFECEEF1),
    primary: _blue,
    onDarkSoft: Color(0xFFA8ACB3),
    semanticUp: Color(0xFF089981),
    semanticDown: Color(0xFFE5484D),
  );

  static const dark = AppColors(
    canvas: Color(0xFF0A0B0D),
    card: Color(0xFF15171A),
    surfaceSoft: Color(0xFF1A1C1F),
    surfaceStrong: Color(0xFF23262B),
    surfaceDark: Color(0xFF0A0B0D),
    surfaceDarkElevated: Color(0xFF23262B),
    ink: Color(0xFFF5F6F8),
    body: Color(0xFFB4B9C2),
    muted: Color(0xFF8B919B),
    hairline: Color(0xFF2A2D33),
    hairlineSoft: Color(0xFF212429),
    primary: _blue,
    onDarkSoft: Color(0xFFA8ACB3),
    semanticUp: Color(0xFF26C0A0),
    semanticDown: Color(0xFFF06A6F),
  );

  @override
  AppColors copyWith({
    Color? canvas,
    Color? card,
    Color? surfaceSoft,
    Color? surfaceStrong,
    Color? surfaceDark,
    Color? surfaceDarkElevated,
    Color? ink,
    Color? body,
    Color? muted,
    Color? hairline,
    Color? hairlineSoft,
    Color? primary,
    Color? onDarkSoft,
    Color? semanticUp,
    Color? semanticDown,
  }) {
    return AppColors(
      canvas: canvas ?? this.canvas,
      card: card ?? this.card,
      surfaceSoft: surfaceSoft ?? this.surfaceSoft,
      surfaceStrong: surfaceStrong ?? this.surfaceStrong,
      surfaceDark: surfaceDark ?? this.surfaceDark,
      surfaceDarkElevated: surfaceDarkElevated ?? this.surfaceDarkElevated,
      ink: ink ?? this.ink,
      body: body ?? this.body,
      muted: muted ?? this.muted,
      hairline: hairline ?? this.hairline,
      hairlineSoft: hairlineSoft ?? this.hairlineSoft,
      primary: primary ?? this.primary,
      onDarkSoft: onDarkSoft ?? this.onDarkSoft,
      semanticUp: semanticUp ?? this.semanticUp,
      semanticDown: semanticDown ?? this.semanticDown,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      card: Color.lerp(card, other.card, t)!,
      surfaceSoft: Color.lerp(surfaceSoft, other.surfaceSoft, t)!,
      surfaceStrong: Color.lerp(surfaceStrong, other.surfaceStrong, t)!,
      surfaceDark: Color.lerp(surfaceDark, other.surfaceDark, t)!,
      surfaceDarkElevated:
          Color.lerp(surfaceDarkElevated, other.surfaceDarkElevated, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      body: Color.lerp(body, other.body, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      hairlineSoft: Color.lerp(hairlineSoft, other.hairlineSoft, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onDarkSoft: Color.lerp(onDarkSoft, other.onDarkSoft, t)!,
      semanticUp: Color.lerp(semanticUp, other.semanticUp, t)!,
      semanticDown: Color.lerp(semanticDown, other.semanticDown, t)!,
    );
  }
}

/// Shape tokens (06_DESIGN_SYSTEM.md §3).
abstract final class AppRadius {
  static const pill = 9999.0;
  static const card = 24.0;
  static const secondary = 18.0;
}

extension AppColorsX on BuildContext {
  AppColors get c => Theme.of(this).extension<AppColors>()!;
}

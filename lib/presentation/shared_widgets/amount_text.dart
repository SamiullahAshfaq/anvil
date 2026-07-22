import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money.dart';

/// How a monetary figure is coloured. Semantic colours are reserved strictly for
/// financial polarity (06_DESIGN_SYSTEM.md §1) — never decoration.
enum AmountTone {
  neutral,
  receivable, // owed to us / profit → green
  payable, // we owe / loss → red
  onDark, // white-ish, for the always-dark net-worth card
}

/// A Paisa amount rendered in JetBrains Mono. This is the single widget every
/// screen uses to show money, so figures are always scannable and consistent.
class AmountText extends StatelessWidget {
  final int paisa;
  final double size;
  final FontWeight weight;
  final AmountTone tone;
  final bool showSymbol;

  const AmountText(
    this.paisa, {
    super.key,
    this.size = 15,
    this.weight = FontWeight.w500,
    this.tone = AmountTone.neutral,
    this.showSymbol = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final color = switch (tone) {
      AmountTone.neutral => c.ink,
      AmountTone.receivable => c.semanticUp,
      AmountTone.payable => c.semanticDown,
      AmountTone.onDark => Colors.white,
    };
    return Text(
      paisa.toRupeeString(showSymbol: showSymbol),
      style: monoStyle(size: size, weight: weight, color: color),
    );
  }
}

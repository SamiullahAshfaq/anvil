import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/local/tables.dart';

String partyTypeLabel(PartyTypeDb t) => switch (t) {
      PartyTypeDb.supplier => 'Supplier',
      PartyTypeDb.buyer => 'Buyer',
      PartyTypeDb.both => 'Supplier & Buyer',
    };

/// A round initial-avatar for a party (pill/circle per design system).
class PartyAvatar extends StatelessWidget {
  final String name;
  final double size;
  const PartyAvatar(this.name, {super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: c.surfaceStrong, shape: BoxShape.circle),
      child: Text(initial,
          style: TextStyle(
              color: c.ink, fontWeight: FontWeight.w600, fontSize: size * 0.4)),
    );
  }
}

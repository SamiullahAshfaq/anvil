import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// The standard content card: flat, 1px hairline, no drop shadow (06_DESIGN_
/// SYSTEM.md §3). Radius defaults to the primary 24px; pass [radius] for the
/// smaller secondary cards.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = AppRadius.card,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: c.hairline),
    );
    return Material(
      color: color ?? c.card,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// A small section label above a card or group.
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

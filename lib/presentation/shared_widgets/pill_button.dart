import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Pill-shaped action button (06_DESIGN_SYSTEM.md §3). [primary] is filled with
/// Coinbase Blue; otherwise a hairline-bordered neutral pill. [danger] tints the
/// label with the payable/loss semantic — used only on destructive confirms.
class PillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final bool danger;
  final bool busy;
  final IconData? icon;

  const PillButton(
    this.label, {
    super.key,
    this.onPressed,
    this.primary = true,
    this.danger = false,
    this.busy = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final fg = primary
        ? Colors.white
        : danger
            ? c.semanticDown
            : c.ink;
    final bg = primary ? (danger ? c.semanticDown : c.primary) : c.surfaceStrong;
    final enabled = onPressed != null && !busy;
    return Material(
      color: enabled ? bg : bg.withValues(alpha: 0.5),
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (busy)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                )
              else if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
              ],
              if (!busy)
                Text(label,
                    style: TextStyle(
                        color: fg,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}

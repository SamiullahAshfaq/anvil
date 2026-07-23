import 'package:flutter/material.dart';

import '../../app/cash_read_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_format.dart';
import '../shared_widgets/amount_text.dart';
import '../shared_widgets/app_card.dart';

IconData cashEntryIcon(CashEntryKind kind) => switch (kind) {
      CashEntryKind.transferIn => Icons.south_west,
      CashEntryKind.transferOut => Icons.swap_horiz,
      CashEntryKind.saleReceipt => Icons.south_west,
      CashEntryKind.purchaseAdvance => Icons.north_east,
      CashEntryKind.expense => Icons.north_east,
      CashEntryKind.paymentReceived => Icons.south_west,
      CashEntryKind.paymentPaid => Icons.north_east,
      CashEntryKind.reversal => Icons.undo,
      CashEntryKind.opening => Icons.flag_outlined,
      CashEntryKind.other => Icons.circle_outlined,
    };

/// One row of a cash ledger (Roznamcha or a pool ledger). Money-in is green,
/// money-out red (semantic polarity only, 06_DESIGN_SYSTEM.md §1). [trailing]
/// can carry a pool chip; [onTap] drills to the source (nothing is a dead end).
class CashEntryTile extends StatelessWidget {
  final CashLedgerEntry entry;
  final bool showPool;
  final VoidCallback? onTap;
  const CashEntryTile({
    super.key,
    required this.entry,
    this.showPool = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final isReversal = entry.kind == CashEntryKind.reversal;
    final tone = isReversal
        ? AmountTone.neutral
        : entry.isIn
            ? AmountTone.receivable
            : AmountTone.payable;
    final subtitleParts = <String>[
      formatDate(entry.date),
      if (showPool) poolLabel(entry.pool),
      if (entry.subtitle != null && entry.subtitle!.isNotEmpty) entry.subtitle!,
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        radius: AppRadius.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        onTap: onTap,
        child: Row(
          children: [
            Icon(cashEntryIcon(entry.kind),
                size: 18, color: isReversal ? c.semanticDown : c.muted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.title,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(subtitleParts.join('  ·  '),
                      style: TextStyle(color: c.muted, fontSize: 12)),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(entry.isIn ? '+' : '−',
                    style: TextStyle(
                        color: tone == AmountTone.receivable
                            ? c.semanticUp
                            : tone == AmountTone.payable
                                ? c.semanticDown
                                : c.muted,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 2),
                AmountText(entry.amountPaisa,
                    size: 15, tone: tone, showSymbol: false),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

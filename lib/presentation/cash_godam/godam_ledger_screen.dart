import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/cash_read_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_format.dart';
import '../../core/utils/money.dart';
import '../../domain/entities/cash_movement.dart';
import '../bills/bill_detail_screen.dart';
import '../shared_widgets/amount_text.dart';
import '../shared_widgets/pill_button.dart';
import 'cash_entry_tile.dart';

/// Godam ledger (01_PRD.md §4.4): fundings-in and spends-out with running
/// balance. Tapping a spend answers "where did this money come from" in one tap
/// via the dynamic FIFO trace (03_RULES.md §1.21) — the two-tap success bar in
/// 04_PHASES.md Phase-3 exit criteria.
class GodamLedgerScreen extends ConsumerWidget {
  const GodamLedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(godamLedgerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Godam ledger')),
      body: view.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (v) {
          if (v.fundings.isEmpty && v.spends.isEmpty) {
            return _empty(context);
          }
          final fundingByMovementId = {
            for (final f in v.fundings) f.movement.id: f
          };
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _BalanceCard(paisa: v.balancePaisa),
              const SizedBox(height: 20),
              if (v.spends.isNotEmpty) ...[
                Text('Spends', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 8),
                for (final s in v.spends)
                  CashEntryTile(
                    entry: s.entry,
                    onTap: () => _showTrace(
                        context, s.trace, s.entry, fundingByMovementId),
                  ),
                const SizedBox(height: 16),
              ],
              if (v.fundings.isNotEmpty) ...[
                Text('Fundings in',
                    style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 8),
                for (final f in v.fundings) CashEntryTile(entry: f),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _empty(BuildContext context) {
    final c = context.c;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warehouse_outlined, size: 48, color: c.muted),
            const SizedBox(height: 16),
            Text('Godam is empty',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('Transfer cash from Home or Bank to fund Godam purchases.',
                textAlign: TextAlign.center,
                style: TextStyle(color: c.muted)),
          ],
        ),
      ),
    );
  }

  void _showTrace(
    BuildContext context,
    SpendTrace trace,
    CashLedgerEntry spend,
    Map<String, CashLedgerEntry> fundingByMovementId,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _TraceSheet(
        trace: trace,
        spend: spend,
        fundingByMovementId: fundingByMovementId,
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final int paisa;
  const _BalanceCard({required this.paisa});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surfaceDark,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Godam balance', style: monoStyle(size: 12, color: c.onDarkSoft)),
          const SizedBox(height: 8),
          AmountText(paisa,
              size: 28,
              weight: FontWeight.w600,
              tone: paisa < 0 ? AmountTone.payable : AmountTone.onDark),
        ],
      ),
    );
  }
}

class _TraceSheet extends StatelessWidget {
  final SpendTrace trace;
  final CashLedgerEntry spend;
  final Map<String, CashLedgerEntry> fundingByMovementId;
  const _TraceSheet({
    required this.trace,
    required this.spend,
    required this.fundingByMovementId,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: c.hairline),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Where this money came from',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('${spend.title}  ',
                      style: TextStyle(color: c.muted, fontSize: 13)),
                  AmountText(trace.spendAmountPaisa, size: 13),
                ],
              ),
              const SizedBox(height: 16),
              if (trace.sources.isEmpty)
                Text('No funding transfer found — this spend drew Godam negative.',
                    style: TextStyle(color: c.muted))
              else
                for (final s in trace.sources)
                  _sourceRow(context, s),
              if (trace.unfundedPaisa > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 15, color: c.semanticDown),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                          'Unfunded ${trace.unfundedPaisa.toRupeeString()} — Godam went negative here.',
                          style: TextStyle(color: c.semanticDown, fontSize: 12)),
                    ),
                  ],
                ),
              ],
              if (spend.billId != null) ...[
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: PillButton(
                    'View bill',
                    primary: false,
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              BillDetailScreen(billId: spend.billId!)));
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _sourceRow(BuildContext context, FundingSource s) {
    final c = context.c;
    final funding = fundingByMovementId[s.transferMovementId];
    final from = funding?.subtitle ?? 'Transfer';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(Icons.south_west, size: 16, color: c.muted),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(from, style: TextStyle(color: c.ink, fontSize: 14)),
                Text(formatDate(s.transferDate),
                    style: TextStyle(color: c.muted, fontSize: 12)),
              ],
            ),
          ),
          AmountText(s.amountConsumedPaisa, size: 14),
        ],
      ),
    );
  }
}

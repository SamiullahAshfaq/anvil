import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/read_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_format.dart';
import '../../data/local/tables.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../bills/bill_detail_screen.dart';
import '../shared_widgets/amount_text.dart';
import '../shared_widgets/app_card.dart';

/// Drill-down for a single P&L period — reached from the profit card or a tapped
/// chart bar (03_RULES.md §1.14: every dashboard number is traceable to source).
/// Shows the period's revenue − COGS − expenses breakdown and lists the exact
/// sale/expense bills that compose it, each tappable to its receipt.
class PeriodDetailScreen extends ConsumerWidget {
  final PeriodKey periodKey;
  const PeriodDetailScreen({super.key, required this.periodKey});

  String _title(PeriodScope scope, int year, int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    if (scope == PeriodScope.quarter) {
      return 'Q${((month - 1) ~/ 3) + 1} $year';
    }
    return '${months[month - 1]} $year';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(periodDetailProvider(periodKey));
    final bills = ref.watch(billsListProvider);
    return Scaffold(
      appBar: AppBar(
          title: Text(
              _title(periodKey.scope, periodKey.year, periodKey.month))),
      body: summary.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (s) {
          final contributing = bills.maybeWhen(
            data: (list) => list
                .where((it) =>
                    !it.bill.isOpening &&
                    (it.bill.type == BillTypeDb.sale ||
                        it.bill.type == BillTypeDb.expense) &&
                    !it.bill.date.isBefore(s.periodStart) &&
                    it.bill.date.isBefore(s.periodEnd))
                .toList(growable: false),
            orElse: () => const <BillListItem>[],
          );
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              _PnlCard(summary: s),
              const SizedBox(height: 20),
              const SectionLabel('WHAT MADE THIS PERIOD'),
              if (contributing.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('No sales or expenses in this period.',
                      style: TextStyle(color: context.c.muted)),
                )
              else
                for (final it in contributing) _BillRow(item: it),
            ],
          );
        },
      ),
    );
  }
}

class _PnlCard extends StatelessWidget {
  final DashboardSummary summary;
  const _PnlCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final profit = summary.periodProfitPaisa;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Profit', style: Theme.of(context).textTheme.titleMedium),
              AmountText(profit,
                  size: 24,
                  weight: FontWeight.w600,
                  tone: profit >= 0 ? AmountTone.receivable : AmountTone.payable),
            ],
          ),
          const SizedBox(height: 14),
          _Line('Revenue', summary.periodRevenuePaisa),
          _Line('Cost of goods sold', -summary.periodCogsPaisa),
          _Line('Expenses', -summary.periodExpensePaisa),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final int paisa;
  const _Line(this.label, this.paisa);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          AmountText(paisa, size: 14),
        ],
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  final BillListItem item;
  const _BillRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final isSale = item.bill.type == BillTypeDb.sale;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        radius: 18,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => BillDetailScreen(billId: item.bill.id))),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSale ? (item.partyName ?? 'Sale') : 'Expense',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(formatDate(item.bill.date),
                      style: TextStyle(color: c.muted, fontSize: 12)),
                ],
              ),
            ),
            AmountText(item.bill.totalAmountPaisa,
                size: 15,
                tone: isSale ? AmountTone.receivable : AmountTone.payable),
          ],
        ),
      ),
    );
  }
}

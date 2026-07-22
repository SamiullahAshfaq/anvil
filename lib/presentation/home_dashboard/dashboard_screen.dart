import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/tables.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../shared_widgets/amount_text.dart';
import '../shared_widgets/app_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: RefreshIndicator(
        onRefresh: () async => bumpLedger(ref),
        child: summary.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorState(message: '$e'),
          data: (s) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _NetWorthCard(summary: s),
              const SizedBox(height: 20),
              const SectionLabel('CASH ON HAND'),
              const _PoolChips(),
              const SizedBox(height: 20),
              const SectionLabel('THIS MONTH'),
              _ProfitCard(summary: s),
              const SizedBox(height: 20),
              const SectionLabel('WHO OWES WHOM'),
              _ReceivablePayableCard(summary: s),
              const SizedBox(height: 20),
              const SectionLabel('IN PLAIN TERMS'),
              _PlainTermsCard(summary: s),
            ],
          ),
        ),
      ),
    );
  }
}

/// The always-dark hero card anchoring net worth (06_DESIGN_SYSTEM.md §3).
class _NetWorthCard extends StatelessWidget {
  final DashboardSummary summary;
  const _NetWorthCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: c.surfaceDark,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Net worth',
              style: monoStyle(size: 12, color: c.onDarkSoft)
                  .copyWith(letterSpacing: 0.5)),
          const SizedBox(height: 8),
          AmountText(summary.netWorthPaisa,
              size: 34, weight: FontWeight.w600, tone: AmountTone.onDark),
          const SizedBox(height: 20),
          Row(
            children: [
              _DarkChip(
                  label: 'Cash', paisa: summary.cashOnHandPaisa),
              const SizedBox(width: 10),
              _DarkChip(
                  label: 'Stock', paisa: summary.stockValueAtCostPaisa),
            ],
          ),
        ],
      ),
    );
  }
}

class _DarkChip extends StatelessWidget {
  final String label;
  final int paisa;
  const _DarkChip({required this.label, required this.paisa});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: c.surfaceDarkElevated,
          borderRadius: BorderRadius.circular(AppRadius.secondary),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: monoStyle(size: 11, color: c.onDarkSoft)),
            const SizedBox(height: 4),
            AmountText(paisa,
                size: 16, tone: AmountTone.onDark, showSymbol: false),
          ],
        ),
      ),
    );
  }
}

class _PoolChips extends ConsumerWidget {
  const _PoolChips();

  String _label(PoolNameDb n) => switch (n) {
        PoolNameDb.home => 'Home',
        PoolNameDb.bank => 'Bank',
        PoolNameDb.godam => 'Godam',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pools = ref.watch(poolBalancesProvider);
    final c = context.c;
    return pools.when(
      loading: () => const SizedBox(
          height: 64, child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Text('$e', style: TextStyle(color: c.semanticDown)),
      data: (list) => Row(
        children: [
          for (final p in list) ...[
            Expanded(
              child: AppCard(
                radius: AppRadius.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_label(p.name),
                        style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 6),
                    AmountText(p.balancePaisa,
                        size: 14,
                        showSymbol: false,
                        tone: p.balancePaisa < 0
                            ? AmountTone.payable
                            : AmountTone.neutral),
                  ],
                ),
              ),
            ),
            if (p.name != list.last.name) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _ProfitCard extends StatelessWidget {
  final DashboardSummary summary;
  const _ProfitCard({required this.summary});

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
                  size: 22,
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

class _ReceivablePayableCard extends StatelessWidget {
  final DashboardSummary summary;
  const _ReceivablePayableCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    // Receivable and payable are ALWAYS two separate numbers, never netted
    // (01_PRD.md §4.1).
    return Row(
      children: [
        Expanded(
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('They owe us',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                AmountText(summary.receivablePaisa,
                    size: 20,
                    weight: FontWeight.w600,
                    tone: AmountTone.receivable),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('We owe', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                AmountText(summary.payablePaisa,
                    size: 20,
                    weight: FontWeight.w600,
                    tone: AmountTone.payable),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PlainTermsCard extends StatelessWidget {
  final DashboardSummary summary;
  const _PlainTermsCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final lines = <String>[];
    final best = summary.bestMarginCategory;
    if (best != null && best.revenuePaisa > 0) {
      lines.add('Best margin this month: ${best.name}.');
    }
    final worst = summary.worstMarginCategory;
    if (worst != null && worst.categoryId != best?.categoryId) {
      lines.add('Watch the margin on ${worst.name}.');
    }
    if (summary.biggestExpenseLabel != null) {
      lines.add('Biggest expense: ${summary.biggestExpenseLabel}.');
    }
    if (summary.largestReceivablePartyName != null) {
      lines.add(
          '${summary.largestReceivablePartyName} owes the most right now.');
    }
    if (lines.isEmpty) lines.add('No activity yet this month.');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.surfaceSoft,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final l in lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('•  $l',
                  style: Theme.of(context).textTheme.bodyLarge),
            ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Couldn\'t load the dashboard.\n$message',
          textAlign: TextAlign.center,
          style: TextStyle(color: context.c.muted),
        ),
      ),
    );
  }
}

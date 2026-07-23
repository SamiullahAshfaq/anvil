import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/tables.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../bills/bill_detail_screen.dart';
import '../cash_godam/cash_screen.dart';
import '../parties/party_detail_screen.dart';
import '../shared_widgets/amount_text.dart';
import '../shared_widgets/app_card.dart';
import '../shared_widgets/form_fields.dart';
import '../stock/stock_ledger_screen.dart';
import '../stock/stock_screen.dart';
import 'period_detail_screen.dart';
import 'profit_chart.dart';
import 'receivables_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    final scope = ref.watch(dashboardScopeProvider);
    final scopeWord = scope == PeriodScope.quarter ? 'QUARTER' : 'MONTH';
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
              Row(
                children: [
                  Expanded(child: SectionLabel('THIS $scopeWord')),
                  SizedBox(
                    width: 168,
                    child: SegmentedPills<PeriodScope>(
                      values: PeriodScope.values,
                      selected: scope,
                      labelOf: (p) =>
                          p == PeriodScope.quarter ? 'Quarter' : 'Month',
                      onSelect: (p) =>
                          ref.read(dashboardScopeProvider.notifier).state = p,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _ProfitCard(summary: s),
              const SizedBox(height: 12),
              const _ProfitChartCard(),
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

/// The always-dark hero card anchoring net worth (06_DESIGN_SYSTEM.md §3). Its
/// two chips drill into where that value lives — Cash → Cash & Godam, Stock →
/// Stock (03_RULES.md §1.14).
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
                label: 'Cash',
                paisa: summary.cashOnHandPaisa,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const CashScreen())),
              ),
              const SizedBox(width: 10),
              _DarkChip(
                label: 'Stock',
                paisa: summary.stockValueAtCostPaisa,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const StockScreen())),
              ),
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
  final VoidCallback? onTap;
  const _DarkChip({required this.label, required this.paisa, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Expanded(
      child: Material(
        color: c.surfaceDarkElevated,
        borderRadius: BorderRadius.circular(AppRadius.secondary),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(label, style: monoStyle(size: 11, color: c.onDarkSoft)),
                    if (onTap != null) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right, size: 13, color: c.onDarkSoft),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                AmountText(paisa,
                    size: 16, tone: AmountTone.onDark, showSymbol: false),
              ],
            ),
          ),
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
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CashScreen())),
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

/// Period P&L summary; tap to open the full period drill-down (contributing
/// sale/expense bills).
class _ProfitCard extends StatelessWidget {
  final DashboardSummary summary;
  const _ProfitCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final profit = summary.periodProfitPaisa;
    return AppCard(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PeriodDetailScreen(
          periodKey: (
            year: summary.periodStart.year,
            month: summary.periodStart.month,
            scope: summary.scope,
          ),
        ),
      )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text('Profit', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 18, color: context.c.muted),
                ],
              ),
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

class _ProfitChartCard extends ConsumerWidget {
  const _ProfitChartCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(profitSeriesProvider);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profit trend',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Tap a bar to open that period',
              style: TextStyle(color: context.c.muted, fontSize: 12)),
          const SizedBox(height: 16),
          series.when(
            loading: () => const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SizedBox(height: 120, child: Center(child: Text('$e'))),
            data: (list) => ProfitChart(
              series: list,
              onBarTap: (p) => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => PeriodDetailScreen(
                  periodKey: (year: p.year, month: p.month, scope: _scope(ref)),
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }

  PeriodScope _scope(WidgetRef ref) => ref.read(dashboardScopeProvider);
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
    // (01_PRD.md §4.1). Each tile drills into that side's parties, top-first.
    return Row(
      children: [
        Expanded(
          child: AppCard(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const ReceivablesScreen(initialTab: 0))),
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
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const ReceivablesScreen(initialTab: 1))),
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

/// Plain-language takeaways (01_PRD.md §4.6). Each line that has a source record
/// is tappable to it — best/worst margin → that category's stock ledger, biggest
/// expense → its bill, largest receivable → that party.
class _PlainTermsCard extends StatelessWidget {
  final DashboardSummary summary;
  const _PlainTermsCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final lines = <({String text, VoidCallback? onTap})>[];

    final best = summary.bestMarginCategory;
    if (best != null && best.revenuePaisa > 0) {
      lines.add((
        text: 'Best margin this ${_scopeWord(summary.scope)}: ${best.name}.',
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => StockLedgerScreen(
                categoryId: best.categoryId, categoryName: best.name))),
      ));
    }
    final worst = summary.worstMarginCategory;
    if (worst != null && worst.categoryId != best?.categoryId) {
      lines.add((
        text: 'Watch the margin on ${worst.name}.',
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => StockLedgerScreen(
                categoryId: worst.categoryId, categoryName: worst.name))),
      ));
    }
    if (summary.biggestExpenseLabel != null) {
      lines.add((
        text: 'Biggest expense: ${summary.biggestExpenseLabel}.',
        onTap: summary.biggestExpenseBillId == null
            ? null
            : () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    BillDetailScreen(billId: summary.biggestExpenseBillId!))),
      ));
    }
    if (summary.largestReceivablePartyName != null) {
      lines.add((
        text: '${summary.largestReceivablePartyName} owes the most right now.',
        onTap: summary.largestReceivablePartyId == null
            ? null
            : () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => PartyDetailScreen(
                    partyId: summary.largestReceivablePartyId!))),
      ));
    }
    if (lines.isEmpty) {
      lines.add((text: 'No activity yet this ${_scopeWord(summary.scope)}.', onTap: null));
    }

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
            InkWell(
              onTap: l.onTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('•  ${l.text}',
                          style: Theme.of(context).textTheme.bodyLarge),
                    ),
                    if (l.onTap != null)
                      Icon(Icons.chevron_right, size: 16, color: c.muted),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _scopeWord(PeriodScope s) =>
      s == PeriodScope.quarter ? 'quarter' : 'month';
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

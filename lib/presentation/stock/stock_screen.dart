import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/read_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money.dart';
import '../../core/utils/weight.dart';
import '../../domain/use_cases/use_case_result.dart';
import '../../security/access_mode.dart';
import '../shared_widgets/amount_text.dart';
import '../shared_widgets/app_card.dart';
import '../shared_widgets/calm_sheet.dart';
import '../shared_widgets/form_fields.dart';
import '../shared_widgets/pill_button.dart';
import 'stock_ledger_screen.dart';
import 'write_off_sheet.dart';

class StockScreen extends ConsumerWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stock = ref.watch(stockPositionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Stock')),
      body: stock.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) {
          final totalValue =
              list.fold<int>(0, (s, i) => s + i.position.totalCostBasisPaisa);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _TotalValueCard(totalValuePaisa: totalValue),
              const SizedBox(height: 20),
              for (final item in list) _StockCard(item: item),
            ],
          );
        },
      ),
    );
  }
}

class _TotalValueCard extends StatelessWidget {
  final int totalValuePaisa;
  const _TotalValueCard({required this.totalValuePaisa});

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
          Text('Total stock value at cost',
              style: monoStyle(size: 12, color: c.onDarkSoft)),
          const SizedBox(height: 8),
          AmountText(totalValuePaisa,
              size: 30, weight: FontWeight.w600, tone: AmountTone.onDark),
        ],
      ),
    );
  }
}

class _StockCard extends ConsumerWidget {
  final StockCardItem item;
  const _StockCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final isView = ref.watch(accessModeProvider) == AccessMode.view;
    final pos = item.position;
    final qty = pos.quantityGrams;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AppCard(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => StockLedgerScreen(
                categoryId: item.category.id,
                categoryName: item.category.name))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.category.name,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(qty.toKgString(),
                        style: monoStyle(
                            size: 18,
                            weight: FontWeight.w600,
                            color: qty < 0 ? c.semanticDown : c.ink)),
                    Text(qty.toTonString(),
                        style: monoStyle(size: 11, color: c.muted)),
                  ],
                ),
              ],
            ),
            Divider(height: 24, color: c.hairlineSoft),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Avg cost / kg',
                    value: qty > 0
                        ? pos.avgCostPaisaPerKg.toRupeeString()
                        : '—',
                  ),
                ),
                Expanded(
                  child: _MetricTile(
                    label: 'Avg cost / ton',
                    value: qty > 0
                        ? (pos.avgCostPaisaPerKg * 1000).toRupeeString()
                        : '—',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _explainRate(context, item),
              borderRadius: BorderRadius.circular(AppRadius.secondary),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: c.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.secondary),
                ),
                child: Row(
                  children: [
                    Icon(Icons.sell_outlined, size: 18, color: c.primary),
                    const SizedBox(width: 10),
                    Text('Recommended rate',
                        style: TextStyle(
                            color: c.primary, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text(
                        qty > 0
                            ? '${item.rate.recommendedRatePaisaPerKg.toRupeeString()}/kg'
                            : 'set a rate',
                        style: monoStyle(
                            size: 14,
                            weight: FontWeight.w600,
                            color: c.primary)),
                    Icon(Icons.info_outline, size: 15, color: c.primary),
                  ],
                ),
              ),
            ),
            if (!isView) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => _editMargin(context, ref, item),
                    icon: const Icon(Icons.percent, size: 16),
                    label: Text('Margin ${item.category.targetMarginPct}%'),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => showWriteOffSheet(context, ref,
                        item.category.id, item.category.name),
                    icon: const Icon(Icons.remove_circle_outline, size: 16),
                    label: const Text('Write off'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _explainRate(BuildContext context, StockCardItem item) {
    final r = item.rate;
    if (item.position.quantityGrams <= 0) {
      showCalmConfirm(context,
          title: 'No recommended rate yet',
          message:
              'There\'s no positive stock to cost against. Record a purchase to establish an average cost, and the recommended rate will appear.',
          confirmLabel: 'Got it',
          cancelLabel: 'Close');
      return;
    }
    showCalmConfirm(
      context,
      title: 'How this rate is worked out',
      message: 'Average cost:  ${r.avgCostPaisaPerKg.toRupeeString()}/kg\n'
          '+ ${r.marginPct}% margin:  ${r.marginAmountPaisaPerKg.toRupeeString()}/kg\n'
          '= Recommended:  ${r.recommendedRatePaisaPerKg.toRupeeString()}/kg\n\n'
          'Guidance only — quote what you like.',
      confirmLabel: 'Got it',
      cancelLabel: 'Close',
    );
  }

  Future<void> _editMargin(
      BuildContext context, WidgetRef ref, StockCardItem item) async {
    final controller =
        TextEditingController(text: item.category.targetMarginPct.toString());
    final saved = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ctx.c.card,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: ctx.c.hairline),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Target margin for ${item.category.name}',
                    style: Theme.of(ctx).textTheme.titleMedium),
                const SizedBox(height: 16),
                AppTextField(
                    controller: controller,
                    label: 'MARGIN %',
                    numeric: true,
                    autofocus: true),
                const SizedBox(height: 20),
                PillButton('Save',
                    onPressed: () => Navigator.of(ctx).pop(true)),
              ],
            ),
          ),
        ),
      ),
    );
    if (saved != true) return;
    final pct = int.tryParse(controller.text.trim());
    if (pct == null || pct < 0) return;
    final result =
        await ref.read(manageStockProvider).setTargetMargin(item.category.id, pct);
    if (result is Success && context.mounted) {
      bumpLedger(ref);
    }
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  const _MetricTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 4),
        Text(value, style: monoStyle(size: 15, color: c.ink)),
      ],
    );
  }
}

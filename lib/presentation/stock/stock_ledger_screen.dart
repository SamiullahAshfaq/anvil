import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/read_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_format.dart';
import '../../core/utils/money.dart';
import '../../core/utils/weight.dart';
import '../../data/local/database.dart';
import '../../data/local/tables.dart';
import '../shared_widgets/app_card.dart';

/// The "show your work" stock ledger: every line that moved this category's
/// quantity, chronological, with a running balance (01_PRD.md §4.3). Can be
/// filtered by sub-category tag — but the running balance always reflects the
/// parent category as a whole, never the filtered subset (§1.16).
class StockLedgerScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String categoryName;
  const StockLedgerScreen(
      {super.key, required this.categoryId, required this.categoryName});

  @override
  ConsumerState<StockLedgerScreen> createState() => _StockLedgerScreenState();
}

class _StockLedgerScreenState extends ConsumerState<StockLedgerScreen> {
  String? _tagFilter;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final ledger = ref.watch(stockLedgerProvider(widget.categoryId));
    return Scaffold(
      appBar: AppBar(title: Text('${widget.categoryName} ledger')),
      body: ledger.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (rows) {
          if (rows.isEmpty) {
            return Center(
                child: Text('No stock movements yet.',
                    style: TextStyle(color: c.muted)));
          }
          final tags = <String>{
            for (final r in rows)
              if (r.line.subCategoryLabel != null) r.line.subCategoryLabel!
          };
          final visible = _tagFilter == null
              ? rows
              : rows
                  .where((r) => r.line.subCategoryLabel == _tagFilter)
                  .toList();
          return Column(
            children: [
              if (tags.isNotEmpty)
                SizedBox(
                  height: 52,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    children: [
                      _tagChip('All', _tagFilter == null,
                          () => setState(() => _tagFilter = null)),
                      for (final t in tags)
                        _tagChip(t, _tagFilter == t,
                            () => setState(() => _tagFilter = t)),
                    ],
                  ),
                ),
              if (_tagFilter != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(
                      'Showing "$_tagFilter" entries — running balance still reflects the whole category.',
                      style: TextStyle(color: c.muted, fontSize: 12)),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  itemCount: visible.length,
                  itemBuilder: (_, i) => _LedgerRow(
                      line: visible[i].line,
                      bill: visible[i].bill,
                      runningGrams: visible[i].runningGrams),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _tagChip(String label, bool selected, VoidCallback onTap) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        backgroundColor: c.surfaceStrong,
        selectedColor: c.primary.withValues(alpha: 0.15),
        side: BorderSide(color: c.hairline),
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  final BillLineItem line;
  final Bill bill;
  final int runningGrams;
  const _LedgerRow(
      {required this.line, required this.bill, required this.runningGrams});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final isPurchase = bill.type == BillTypeDb.purchase;
    final signed =
        '${isPurchase ? '+' : '−'}${line.weightGrams.toKgString()}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        radius: AppRadius.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(isPurchase ? Icons.south_west : Icons.north_east,
                size: 18, color: c.muted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      bill.isOpening
                          ? 'Opening'
                          : isPurchase
                              ? 'Purchase'
                              : 'Sale',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                      '${formatDate(bill.date)} · ${line.ratePaisaPerKg.toRupeeString()}/kg'
                      '${line.subCategoryLabel != null ? ' · ${line.subCategoryLabel}' : ''}',
                      style: TextStyle(color: c.muted, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(signed,
                    style: monoStyle(
                        size: 14,
                        color: isPurchase ? c.semanticUp : c.ink)),
                Text('bal ${runningGrams.toKgString()}',
                    style: monoStyle(size: 11, color: c.muted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

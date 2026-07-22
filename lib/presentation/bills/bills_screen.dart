import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/read_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_format.dart';
import '../../data/local/tables.dart';
import '../../security/access_mode.dart';
import '../shared_widgets/amount_text.dart';
import '../shared_widgets/app_card.dart';
import 'bill_detail_screen.dart';
import 'new_bill_screen.dart';

enum _Filter { all, pending, purchases, sales, expenses }

final _billsFilterProvider = StateProvider<_Filter>((ref) => _Filter.all);

class BillsScreen extends ConsumerWidget {
  const BillsScreen({super.key});

  bool _matches(_Filter f, BillListItem item) => switch (f) {
        _Filter.all => true,
        _Filter.pending => billIsPending(item),
        _Filter.purchases => item.bill.type == BillTypeDb.purchase,
        _Filter.sales => item.bill.type == BillTypeDb.sale,
        _Filter.expenses => item.bill.type == BillTypeDb.expense,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bills = ref.watch(billsListProvider);
    final filter = ref.watch(_billsFilterProvider);
    final isView = ref.watch(accessModeProvider) == AccessMode.view;
    return Scaffold(
      appBar: AppBar(title: const Text('Bills')),
      floatingActionButton: isView
          ? null
          : FloatingActionButton.extended(
              onPressed: () => openNewBill(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('New bill'),
            ),
      body: Column(
        children: [
          _FilterBar(current: filter),
          Expanded(
            child: bills.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (list) {
                final filtered =
                    list.where((b) => _matches(filter, b)).toList();
                if (filtered.isEmpty) {
                  return _Empty(filter: filter);
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _BillRow(item: filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  final _Filter current;
  const _FilterBar({required this.current});

  String _label(_Filter f) => switch (f) {
        _Filter.all => 'All',
        _Filter.pending => 'Pending',
        _Filter.purchases => 'Purchases',
        _Filter.sales => 'Sales',
        _Filter.expenses => 'Expenses',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          for (final f in _Filter.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_label(f)),
                selected: f == current,
                onSelected: (_) =>
                    ref.read(_billsFilterProvider.notifier).state = f,
                backgroundColor: c.surfaceStrong,
                selectedColor: c.primary.withValues(alpha: 0.15),
                side: BorderSide(color: c.hairline),
                labelStyle: TextStyle(
                    color: f == current ? c.primary : c.body,
                    fontWeight: FontWeight.w500),
              ),
            ),
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
    final b = item.bill;
    final pending = billIsPending(item);
    final isSale = b.type == BillTypeDb.sale;
    final icon = switch (b.type) {
      BillTypeDb.purchase => Icons.south_west,
      BillTypeDb.sale => Icons.north_east,
      BillTypeDb.expense => Icons.receipt_long_outlined,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        radius: AppRadius.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => BillDetailScreen(billId: b.id))),
        child: Row(
          children: [
            Icon(icon, size: 18, color: c.muted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(billTypeTitle(b),
                          style: Theme.of(context).textTheme.titleMedium),
                      if (pending) ...[
                        const SizedBox(width: 8),
                        _PendingTag(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                      '${item.partyName ?? 'No party'} · ${formatDate(b.date)}',
                      style: TextStyle(color: c.muted, fontSize: 12)),
                ],
              ),
            ),
            AmountText(b.totalAmountPaisa,
                size: 15,
                tone: b.type == BillTypeDb.expense
                    ? AmountTone.payable
                    : isSale
                        ? AmountTone.receivable
                        : AmountTone.neutral),
          ],
        ),
      ),
    );
  }
}

class _PendingTag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: c.surfaceStrong,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text('Pending',
          style: TextStyle(
              color: c.body, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

class _Empty extends StatelessWidget {
  final _Filter filter;
  const _Empty({required this.filter});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 48, color: c.muted),
            const SizedBox(height: 16),
            Text(
                filter == _Filter.all
                    ? 'No bills yet'
                    : 'Nothing here',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
                filter == _Filter.pending
                    ? 'No outstanding purchases or sales — all settled.'
                    : 'Tap New bill to record a purchase, sale, or expense.',
                textAlign: TextAlign.center,
                style: TextStyle(color: c.muted)),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/providers.dart';
import '../../app/read_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_format.dart';
import '../../core/utils/money.dart';
import '../../core/utils/weight.dart';
import '../../data/local/database.dart';
import '../../data/local/tables.dart';
import '../../security/access_mode.dart';
import '../shared_widgets/amount_text.dart';
import '../shared_widgets/app_card.dart';
import '../shared_widgets/calm_sheet.dart';
import '../shared_widgets/use_case_runner.dart';

/// Bill detail + branded receipt. Doubles as the post-save confirmation
/// ([justCreated]) and the share surface (01_PRD.md §4.2, §4.8).
class BillDetailScreen extends ConsumerWidget {
  final String billId;
  final bool justCreated;
  const BillDetailScreen(
      {super.key, required this.billId, this.justCreated = false});

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await showCalmConfirm(context,
        title: 'Move this bill to Trash?',
        message:
            'Stock and cash effects are reversed and it can be restored within 30 days.',
        confirmLabel: 'Move to Trash',
        danger: true);
    if (!ok || !context.mounted) return;
    final done = await confirmAndRun(context,
        action: ({confirmed = false}) =>
            ref.read(trashServiceProvider).softDeleteBill(billId));
    if (done && context.mounted) {
      bumpLedger(ref);
      showCalmInfo(context, 'Bill moved to Trash.');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(billViewProvider(billId));
    final isView = ref.watch(accessModeProvider) == AccessMode.view;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill'),
        actions: [
          view.maybeWhen(
            data: (v) => Row(children: [
              IconButton(
                icon: const Icon(Icons.ios_share),
                onPressed: () => _share(context, v),
              ),
              if (!isView)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _delete(context, ref),
                ),
            ]),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: view.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (v) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            if (justCreated) _SavedBanner(),
            if (justCreated) const SizedBox(height: 12),
            ReceiptCard(view: v),
          ],
        ),
      ),
    );
  }

  Future<void> _share(BuildContext context, BillView v) async {
    try {
      final bytes = await ScreenshotController().captureFromWidget(
        MediaQuery(
          data: MediaQuery.of(context),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Theme(
              data: Theme.of(context),
              child: Container(
                width: 380,
                color: context.c.canvas,
                padding: const EdgeInsets.all(16),
                child: ReceiptCard(view: v, forShare: true),
              ),
            ),
          ),
        ),
        pixelRatio: 3,
        context: context,
        delay: const Duration(milliseconds: 20),
      );
      final dir = await getTemporaryDirectory();
      final file = File(p.join(dir.path, 'receipt_${v.bill.id}.png'));
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path)],
        text: 'Godam Ledger receipt',
      ));
    } catch (e) {
      if (context.mounted) showCalmError(context, e);
    }
  }
}

String billTypeTitle(Bill b) => b.isOpening
    ? 'Opening balance'
    : switch (b.type) {
        BillTypeDb.purchase => 'Purchase',
        BillTypeDb.sale => 'Sale',
        BillTypeDb.expense => 'Expense',
      };

class ReceiptCard extends StatelessWidget {
  final BillView view;
  final bool forShare;
  const ReceiptCard({super.key, required this.view, this.forShare = false});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final b = view.bill;
    final outstanding = b.totalAmountPaisa - view.allocatedPaisa;
    final isTrade = b.type != BillTypeDb.expense;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    color: c.primary, borderRadius: BorderRadius.circular(8)),
              ),
              const SizedBox(width: 10),
              Text('Godam Ledger',
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Text(billTypeTitle(b),
                  style: TextStyle(
                      color: c.muted, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          Text(formatDateTime(b.date),
              style: TextStyle(color: c.muted, fontSize: 12)),
          Divider(height: 28, color: c.hairlineSoft),
          if (view.partyName != null)
            _kv(context, isTrade
                ? (b.type == BillTypeDb.sale ? 'Buyer' : 'Supplier')
                : 'Paid to', view.partyName!),
          if (view.expenseCategoryName != null)
            _kv(context, 'Category', view.expenseCategoryName!),
          const SizedBox(height: 8),
          if (isTrade) ...[
            for (final l in view.lines) _lineRow(context, l),
            Divider(height: 24, color: c.hairlineSoft),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: Theme.of(context).textTheme.titleMedium),
              AmountText(b.totalAmountPaisa,
                  size: 20, weight: FontWeight.w600),
            ],
          ),
          if (isTrade && !b.isOpening) ...[
            const SizedBox(height: 8),
            _kvAmount(context, 'Settled', view.allocatedPaisa,
                tone: AmountTone.neutral),
            _kvAmount(
                context,
                b.type == BillTypeDb.sale ? 'To collect' : 'To pay',
                outstanding,
                tone: outstanding > 0
                    ? (b.type == BillTypeDb.sale
                        ? AmountTone.receivable
                        : AmountTone.payable)
                    : AmountTone.neutral),
          ],
          if (b.note != null && b.note!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(b.note!, style: TextStyle(color: c.body)),
          ],
        ],
      ),
    );
  }

  Widget _lineRow(BuildContext context, BillLineItem l) {
    final c = context.c;
    final catName = view.categoryNames[l.parentCategoryId] ?? 'Item';
    final label = l.subCategoryLabel == null
        ? catName
        : '$catName · ${l.subCategoryLabel}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: c.ink)),
                Text(
                    '${l.weightGrams.toKgString()} @ ${l.ratePaisaPerKg.toRupeeString()}/kg',
                    style: TextStyle(color: c.muted, fontSize: 12)),
              ],
            ),
          ),
          AmountText(l.lineTotalPaisa, size: 14),
        ],
      ),
    );
  }

  Widget _kv(BuildContext context, String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: TextStyle(color: context.c.muted)),
            Text(v,
                style: TextStyle(
                    color: context.c.ink, fontWeight: FontWeight.w500)),
          ],
        ),
      );

  Widget _kvAmount(BuildContext context, String k, int paisa,
          {required AmountTone tone}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: TextStyle(color: context.c.muted)),
            AmountText(paisa, size: 14, tone: tone),
          ],
        ),
      );
}

class _SavedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: c.semanticUp.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.secondary),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: c.semanticUp, size: 20),
          const SizedBox(width: 10),
          Text('Saved. Everything updated.',
              style: TextStyle(color: c.ink, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

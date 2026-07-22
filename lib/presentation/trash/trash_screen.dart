import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/read_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_format.dart';
import '../shared_widgets/app_card.dart';
import '../shared_widgets/calm_sheet.dart';
import '../shared_widgets/use_case_runner.dart';

/// Trash: every delete is recoverable for 30 days, then auto-purged
/// (01_PRD.md §4.8, 03_RULES.md §1.11). Restoring a bill replays the ledger so
/// stock/cash return exactly.
class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  Future<void> _restore(
      BuildContext context, WidgetRef ref, TrashItem item) async {
    final isBill = item.record.entityType == 'bill';
    final done = await confirmAndRun(context, action: ({confirmed = false}) {
      final trash = ref.read(trashServiceProvider);
      return isBill
          ? trash.restoreBill(item.record.entityId)
          : trash.restoreParty(item.record.entityId);
    });
    if (done && context.mounted) {
      bumpLedger(ref);
      showCalmInfo(context, '${item.title} restored.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trash = ref.watch(trashViewProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Trash')),
      body: trash.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) {
          if (list.isEmpty) return _Empty();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text('Deleted items are kept for 30 days.',
                    style: TextStyle(color: context.c.muted)),
              ),
              for (final item in list) _TrashRow(item: item, onRestore: () => _restore(context, ref, item)),
            ],
          );
        },
      ),
    );
  }
}

class _TrashRow extends StatelessWidget {
  final TrashItem item;
  final VoidCallback onRestore;
  const _TrashRow({required this.item, required this.onRestore});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final days = daysUntil(item.record.purgeAt);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        radius: AppRadius.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(
                item.record.entityType == 'party'
                    ? Icons.person_outline
                    : Icons.receipt_long_outlined,
                size: 18,
                color: c.muted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                      '${item.subtitle} · deleted ${formatDate(item.record.deletedAt)} · $days days left',
                      style: TextStyle(color: c.muted, fontSize: 12)),
                ],
              ),
            ),
            TextButton(onPressed: onRestore, child: const Text('Restore')),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_outline, size: 48, color: c.muted),
          const SizedBox(height: 16),
          Text('Trash is empty',
              style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

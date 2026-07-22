import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/read_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/party_ledger.dart';
import '../../security/access_mode.dart';
import '../shared_widgets/amount_text.dart';
import '../shared_widgets/app_card.dart';
import 'new_party_sheet.dart';
import 'party_common.dart';
import 'party_detail_screen.dart';

class PartiesScreen extends ConsumerWidget {
  const PartiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parties = ref.watch(partiesListProvider);
    final isView = ref.watch(accessModeProvider) == AccessMode.view;
    return Scaffold(
      appBar: AppBar(title: const Text('Parties')),
      floatingActionButton: isView
          ? null
          : FloatingActionButton.extended(
              onPressed: () => showNewPartySheet(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('New party'),
            ),
      body: parties.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) {
          if (list.isEmpty) {
            return _Empty();
          }
          final totalRecv =
              list.fold<int>(0, (s, p) => s + p.balance.receivablePaisa);
          final totalPay =
              list.fold<int>(0, (s, p) => s + p.balance.payablePaisa);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _TotalCard(
                        label: 'They owe us',
                        paisa: totalRecv,
                        tone: AmountTone.receivable),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TotalCard(
                        label: 'We owe',
                        paisa: totalPay,
                        tone: AmountTone.payable),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              for (final p in list) _PartyRow(item: p),
            ],
          );
        },
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final String label;
  final int paisa;
  final AmountTone tone;
  const _TotalCard(
      {required this.label, required this.paisa, required this.tone});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          AmountText(paisa, size: 19, weight: FontWeight.w600, tone: tone),
        ],
      ),
    );
  }
}

class _PartyRow extends StatelessWidget {
  final PartyListItem item;
  const _PartyRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final b = item.balance;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        radius: AppRadius.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => PartyDetailScreen(partyId: item.party.id))),
        child: Row(
          children: [
            PartyAvatar(item.party.name),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.party.name,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(partyTypeLabel(item.party.type),
                      style: TextStyle(color: c.muted, fontSize: 12)),
                ],
              ),
            ),
            _BalanceLabel(b),
          ],
        ),
      ),
    );
  }
}

/// Receivable and payable are shown as two distinct lines, never netted
/// (01_PRD.md §4.1).
class _BalanceLabel extends StatelessWidget {
  final PartyBalance b;
  const _BalanceLabel(this.b);

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final recv = b.receivablePaisa;
    final pay = b.payablePaisa;
    if (recv == 0 && pay == 0) {
      return Text('Settled', style: TextStyle(color: c.muted, fontSize: 13));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (recv > 0)
          AmountText(recv, size: 14, tone: AmountTone.receivable),
        if (pay > 0) AmountText(pay, size: 14, tone: AmountTone.payable),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 48, color: c.muted),
            const SizedBox(height: 16),
            Text('No parties yet',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('Add a supplier or buyer to start tracking who owes whom.',
                textAlign: TextAlign.center,
                style: TextStyle(color: c.muted)),
          ],
        ),
      ),
    );
  }
}

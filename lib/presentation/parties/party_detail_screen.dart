import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/read_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_format.dart';
import '../../data/local/database.dart';
import '../../data/local/tables.dart';
import '../../domain/entities/party_ledger.dart';
import '../../security/access_mode.dart';
import '../bills/new_bill_screen.dart';
import '../shared_widgets/amount_text.dart';
import '../shared_widgets/app_card.dart';
import '../shared_widgets/calm_sheet.dart';
import '../shared_widgets/use_case_runner.dart';
import 'new_party_sheet.dart';

class PartyDetailScreen extends ConsumerWidget {
  final String partyId;
  const PartyDetailScreen({super.key, required this.partyId});

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await showCalmConfirm(context,
        title: 'Move this party to Trash?',
        message:
            'It can be restored within 30 days. Parties with open bills or payments can\'t be deleted.',
        confirmLabel: 'Move to Trash',
        danger: true);
    if (!ok || !context.mounted) return;
    final ok2 = await confirmAndRun(context,
        action: ({confirmed = false}) =>
            ref.read(trashServiceProvider).softDeleteParty(partyId));
    if (ok2 && context.mounted) {
      bumpLedger(ref);
      showCalmInfo(context, 'Party moved to Trash.');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(partyDetailProvider(partyId));
    final isView = ref.watch(accessModeProvider) == AccessMode.view;
    return detail.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (d) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(d.party.name),
            actions: [
              if (!isView)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => showEditPartySheet(context, ref, d.party),
                ),
              if (!isView)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _delete(context, ref),
                ),
            ],
            bottom: const TabBar(tabs: [
              Tab(text: 'Settlement'),
              Tab(text: 'History'),
            ]),
          ),
          floatingActionButton: isView
              ? null
              : FloatingActionButton.extended(
                  onPressed: () =>
                      openNewBill(context, ref, partyId: partyId),
                  icon: const Icon(Icons.add),
                  label: const Text('New bill'),
                ),
          body: Column(
            children: [
              _BalanceHeader(balance: d.balance, party: d.party),
              Expanded(
                child: TabBarView(children: [
                  _SettlementTab(detail: d),
                  _HistoryTab(detail: d),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceHeader extends StatelessWidget {
  final PartyBalance balance;
  final Party party;
  const _BalanceHeader({required this.balance, required this.party});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _StatBox(
                label: 'They owe us',
                paisa: balance.receivablePaisa,
                tone: AmountTone.receivable),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatBox(
                label: 'We owe',
                paisa: balance.payablePaisa,
                tone: AmountTone.payable),
          ),
          if (balance.advanceReceivedPaisa > 0 ||
              balance.advancePaidPaisa > 0) ...[
            const SizedBox(width: 10),
            Expanded(
              child: _StatBox(
                label: balance.advanceReceivedPaisa > 0
                    ? 'Advance in'
                    : 'Advance out',
                paisa: balance.advanceReceivedPaisa > 0
                    ? balance.advanceReceivedPaisa
                    : balance.advancePaidPaisa,
                tone: AmountTone.neutral,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final int paisa;
  final AmountTone tone;
  const _StatBox(
      {required this.label, required this.paisa, required this.tone});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: AppRadius.secondary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 6),
          AmountText(paisa, size: 16, weight: FontWeight.w600, tone: tone),
        ],
      ),
    );
  }
}

/// A unified, chronological view of every bill and payment for the party
/// (01_PRD.md §4.1 settlement history) — receivable and payable never netted.
class _SettlementTab extends StatelessWidget {
  final PartyDetail detail;
  const _SettlementTab({required this.detail});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final events = <_Event>[];
    for (final b in detail.bills) {
      events.add(_Event.bill(b));
    }
    for (final p in detail.payments) {
      events.add(_Event.payment(p.payment));
    }
    events.sort((a, b) => b.date.compareTo(a.date));
    if (events.isEmpty) {
      return Center(
        child: Text('Nothing recorded for this party yet.',
            style: TextStyle(color: c.muted)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: events.length,
      itemBuilder: (_, i) => events[i].tile(context),
    );
  }
}

class _HistoryTab extends StatelessWidget {
  final PartyDetail detail;
  const _HistoryTab({required this.detail});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    if (detail.bills.isEmpty) {
      return Center(
          child: Text('No bills yet.', style: TextStyle(color: c.muted)));
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [for (final b in detail.bills) _Event.bill(b).tile(context)],
    );
  }
}

class _Event {
  final DateTime date;
  final Widget Function(BuildContext) tile;
  _Event(this.date, this.tile);

  factory _Event.bill(Bill b) {
    final isSale = b.type == BillTypeDb.sale;
    final label = b.isOpening
        ? 'Opening balance'
        : b.type == BillTypeDb.sale
            ? 'Sale'
            : b.type == BillTypeDb.purchase
                ? 'Purchase'
                : 'Expense';
    return _Event(b.date, (context) {
      final c = context.c;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: AppCard(
          radius: AppRadius.secondary,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(isSale ? Icons.north_east : Icons.south_west,
                  size: 18, color: c.muted),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(formatDate(b.date),
                        style: TextStyle(color: c.muted, fontSize: 12)),
                  ],
                ),
              ),
              AmountText(b.totalAmountPaisa,
                  size: 15,
                  tone: isSale
                      ? AmountTone.receivable
                      : AmountTone.payable),
            ],
          ),
        ),
      );
    });
  }

  factory _Event.payment(Payment p) {
    final received = p.direction == PaymentDirectionDb.received;
    return _Event(p.date, (context) {
      final c = context.c;
      final label = p.reversed
          ? 'Payment reversed'
          : received
              ? 'Payment received'
              : 'Payment made';
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: AppCard(
          radius: AppRadius.secondary,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.payments_outlined,
                  size: 18,
                  color: p.reversed ? c.semanticDown : c.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                        '${formatDate(p.date)}${p.isAdvance ? ' · advance' : ''}',
                        style: TextStyle(color: c.muted, fontSize: 12)),
                  ],
                ),
              ),
              AmountText(p.amountPaisa,
                  size: 15,
                  tone: p.reversed
                      ? AmountTone.neutral
                      : received
                          ? AmountTone.receivable
                          : AmountTone.payable),
            ],
          ),
        ),
      );
    });
  }
}

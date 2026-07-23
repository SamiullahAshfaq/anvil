import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/read_providers.dart';
import '../../core/theme/app_colors.dart';
import '../parties/party_detail_screen.dart';
import '../shared_widgets/amount_text.dart';
import '../shared_widgets/app_card.dart';

/// Drill-down behind the dashboard's receivable/payable cards (01_PRD.md §4.6:
/// "top parties by balance"). Two tabs, because receivable and payable are never
/// netted (05_MEMORY.md) — a party can appear in both. Each row opens that
/// party's detail. Reuses the derived [partiesListProvider], so figures always
/// match the dashboard totals.
class ReceivablesScreen extends ConsumerWidget {
  /// 0 → "They owe us" (receivable), 1 → "We owe" (payable).
  final int initialTab;
  const ReceivablesScreen({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parties = ref.watch(partiesListProvider);
    return DefaultTabController(
      length: 2,
      initialIndex: initialTab,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Who owes whom'),
          bottom: const TabBar(
            tabs: [Tab(text: 'They owe us'), Tab(text: 'We owe')],
          ),
        ),
        body: parties.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (list) => TabBarView(
            children: [
              _PartyBalanceList(
                items: [
                  for (final it in list)
                    if (it.balance.receivablePaisa > 0)
                      (name: it.party.name, id: it.party.id, paisa: it.balance.receivablePaisa)
                ]..sort((a, b) => b.paisa.compareTo(a.paisa)),
                tone: AmountTone.receivable,
                emptyLabel: 'Nobody owes you right now.',
              ),
              _PartyBalanceList(
                items: [
                  for (final it in list)
                    if (it.balance.payablePaisa > 0)
                      (name: it.party.name, id: it.party.id, paisa: it.balance.payablePaisa)
                ]..sort((a, b) => b.paisa.compareTo(a.paisa)),
                tone: AmountTone.payable,
                emptyLabel: 'You owe nobody right now.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PartyBalanceList extends StatelessWidget {
  final List<({String name, String id, int paisa})> items;
  final AmountTone tone;
  final String emptyLabel;
  const _PartyBalanceList(
      {required this.items, required this.tone, required this.emptyLabel});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
          child: Text(emptyLabel, style: TextStyle(color: context.c.muted)));
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        for (final it in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              radius: 18,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => PartyDetailScreen(partyId: it.id))),
              child: Row(
                children: [
                  Expanded(
                    child: Text(it.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  AmountText(it.paisa, size: 16, weight: FontWeight.w600, tone: tone),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

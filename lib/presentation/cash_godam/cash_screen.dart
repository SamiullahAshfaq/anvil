import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/cash_read_providers.dart';
import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money.dart';
import '../../data/local/tables.dart';
import '../../security/access_mode.dart';
import '../shared_widgets/amount_text.dart';
import '../shared_widgets/app_card.dart';
import 'godam_ledger_screen.dart';
import 'roznamcha_screen.dart';
import 'transfer_sheet.dart';

/// Cash & Godam home (01_PRD.md §4.4): the three pool balances, total cash on
/// hand (the reconciliation figure), and entry points to the transfer flow, the
/// Godam FIFO ledger, and the full Roznamcha.
class CashScreen extends ConsumerWidget {
  const CashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recon = ref.watch(reconciliationProvider);
    final isView = ref.watch(accessModeProvider) == AccessMode.view;
    return Scaffold(
      appBar: AppBar(title: const Text('Cash & Godam')),
      floatingActionButton: isView
          ? null
          : FloatingActionButton.extended(
              onPressed: () => showTransferToGodamSheet(context, ref),
              icon: const Icon(Icons.swap_horiz),
              label: const Text('To Godam'),
            ),
      body: recon.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (r) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            _TotalCashCard(pools: r.pools, totalPaisa: r.totalCashPaisa),
            const SizedBox(height: 20),
            for (final p in r.pools) _PoolCard(name: p.name, paisa: p.balancePaisa),
            const SizedBox(height: 8),
            _NavTile(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Godam ledger',
              subtitle: 'Fundings in, spends out — trace any spend to its source',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const GodamLedgerScreen())),
            ),
            _NavTile(
              icon: Icons.receipt_long_outlined,
              title: 'Cash flow ledger (Roznamcha)',
              subtitle: 'Every movement, day by day, filterable',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const RoznamchaScreen())),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalCashCard extends StatelessWidget {
  final List<({PoolNameDb name, int balancePaisa})> pools;
  final int totalPaisa;
  const _TotalCashCard({required this.pools, required this.totalPaisa});

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
          Text('Total cash on hand',
              style: monoStyle(size: 12, color: c.onDarkSoft)),
          const SizedBox(height: 8),
          AmountText(totalPaisa,
              size: 30, weight: FontWeight.w600, tone: AmountTone.onDark),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in pools)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: c.surfaceDarkElevated,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${poolLabel(p.name)}  ',
                          style: monoStyle(size: 12, color: c.onDarkSoft)),
                      Text(p.balancePaisa.toRupeeString(showSymbol: false),
                          style: monoStyle(
                              size: 12,
                              weight: FontWeight.w600,
                              color: p.balancePaisa < 0
                                  ? c.semanticDown
                                  : Colors.white)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PoolCard extends StatelessWidget {
  final PoolNameDb name;
  final int paisa;
  const _PoolCard({required this.name, required this.paisa});

  IconData get _icon => switch (name) {
        PoolNameDb.home => Icons.home_outlined,
        PoolNameDb.bank => Icons.account_balance_outlined,
        PoolNameDb.godam => Icons.warehouse_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        radius: AppRadius.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: c.surfaceStrong, shape: BoxShape.circle),
              child: Icon(_icon, size: 20, color: c.ink),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(poolLabel(name),
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            AmountText(paisa,
                size: 17,
                weight: FontWeight.w600,
                tone: paisa < 0 ? AmountTone.payable : AmountTone.neutral),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _NavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        radius: AppRadius.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 20, color: c.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(color: c.muted, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: c.muted),
          ],
        ),
      ),
    );
  }
}

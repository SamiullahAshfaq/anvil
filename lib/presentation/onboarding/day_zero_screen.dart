import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/money.dart';
import '../../core/utils/weight.dart';
import '../../data/local/tables.dart';
import '../../domain/use_cases/run_day_zero_migration.dart';
import '../bills/category_picker.dart';
import '../parties/new_party_sheet.dart';
import '../shared_widgets/app_card.dart';
import '../shared_widgets/calm_sheet.dart';
import '../shared_widgets/form_fields.dart';
import '../shared_widgets/pill_button.dart';
import '../shared_widgets/use_case_runner.dart';

/// Day-0 Migration wizard (01_PRD.md §4.1, 03_RULES.md §1.26): the owner injects
/// the already-running business's starting position — opening party dues, cash
/// pool balances, and stock baselines — as genuine dated ledger entries, not raw
/// editable balance fields. Runs once.
class DayZeroScreen extends ConsumerStatefulWidget {
  const DayZeroScreen({super.key});

  @override
  ConsumerState<DayZeroScreen> createState() => _DayZeroScreenState();
}

class _PartyDue {
  String? partyId;
  String? partyName;
  OpeningDirection direction = OpeningDirection.theyOweUs;
  final amount = TextEditingController();
  void dispose() => amount.dispose();
}

class _StockBaseline {
  String? catId;
  String? catName;
  final qty = TextEditingController();
  final rate = TextEditingController();
  void dispose() {
    qty.dispose();
    rate.dispose();
  }
}

class _DayZeroScreenState extends ConsumerState<DayZeroScreen> {
  final _home = TextEditingController();
  final _bank = TextEditingController();
  final _godam = TextEditingController();
  final List<_PartyDue> _dues = [];
  final List<_StockBaseline> _stock = [];
  bool _busy = false;

  @override
  void dispose() {
    _home.dispose();
    _bank.dispose();
    _godam.dispose();
    for (final d in _dues) {
      d.dispose();
    }
    for (final s in _stock) {
      s.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final cashOpenings = <CashOpening>[];
    void addCash(PoolNameDb pool, TextEditingController c) {
      final v = rupeeStringToPaisa(c.text);
      if (v != null && v > 0) {
        cashOpenings.add(CashOpening(pool: pool, amountPaisa: v));
      }
    }

    addCash(PoolNameDb.home, _home);
    addCash(PoolNameDb.bank, _bank);
    addCash(PoolNameDb.godam, _godam);

    final partyOpenings = <PartyOpening>[];
    for (final d in _dues) {
      final v = rupeeStringToPaisa(d.amount.text);
      if (d.partyId != null && v != null && v > 0) {
        partyOpenings.add(PartyOpening(
            partyId: d.partyId!, direction: d.direction, amountPaisa: v));
      }
    }

    final stockOpenings = <StockOpening>[];
    for (final s in _stock) {
      final g = kgStringToGrams(s.qty.text);
      final r = rupeeStringToPaisa(s.rate.text);
      if (s.catId != null && g != null && g > 0 && r != null && r >= 0) {
        stockOpenings.add(StockOpening(
            parentCategoryId: s.catId!, quantityGrams: g, ratePaisaPerKg: r));
      }
    }

    if (cashOpenings.isEmpty &&
        partyOpenings.isEmpty &&
        stockOpenings.isEmpty) {
      showCalmError(
          context, Exception('Add at least one opening figure, or go back.'));
      return;
    }

    setState(() => _busy = true);
    final id = await runWithConfirm<String>(context,
        action: ({confirmed = false}) =>
            ref.read(runDayZeroMigrationProvider).call(DayZeroInput(
                  date: DateTime.now(),
                  cashOpenings: cashOpenings,
                  partyOpenings: partyOpenings,
                  stockOpenings: stockOpenings,
                  note: 'First-run opening position',
                )));
    if (!mounted) return;
    setState(() => _busy = false);
    if (id != null) {
      bumpLedger(ref);
      showCalmInfo(context, 'Opening position recorded.');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      appBar: AppBar(title: const Text('Opening position')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          Text(
              'Enter where the business stands today. These become real dated ledger entries — you can only do this once.',
              style: TextStyle(color: c.muted)),
          const SizedBox(height: 20),
          _sectionLabel('CASH ON HAND'),
          AppTextField(
              controller: _home, label: 'HOME (RS)', numeric: true, prefix: 'Rs '),
          const SizedBox(height: 12),
          AppTextField(
              controller: _bank, label: 'BANK (RS)', numeric: true, prefix: 'Rs '),
          const SizedBox(height: 12),
          AppTextField(
              controller: _godam,
              label: 'GODAM (RS)',
              numeric: true,
              prefix: 'Rs '),
          const SizedBox(height: 24),
          _sectionLabel('PARTY OPENING DUES'),
          for (var i = 0; i < _dues.length; i++) _dueCard(i),
          _addButton('Add party due',
              () => setState(() => _dues.add(_PartyDue()))),
          const SizedBox(height: 24),
          _sectionLabel('STOCK BASELINES'),
          for (var i = 0; i < _stock.length; i++) _stockCard(i),
          _addButton('Add stock baseline',
              () => setState(() => _stock.add(_StockBaseline()))),
          const SizedBox(height: 28),
          PillButton('Save opening position',
              busy: _busy, onPressed: _busy ? null : _save),
        ],
      ),
    );
  }

  Widget _sectionLabel(String t) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Text(t, style: Theme.of(context).textTheme.labelSmall),
      );

  Widget _addButton(String label, VoidCallback onTap) => Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.add, size: 18),
            label: Text(label)),
      );

  Widget _dueCard(int i) {
    final d = _dues[i];
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        radius: AppRadius.secondary,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _pickerBox(
                    d.partyName ?? 'Choose party',
                    d.partyName == null,
                    () async {
                      final id = await showPartyPicker(context, ref);
                      if (id != null) {
                        final db = ref.read(appDatabaseProvider);
                        final p = await (db.select(db.parties)
                              ..where((t) => t.id.equals(id)))
                            .getSingleOrNull();
                        setState(() {
                          d.partyId = id;
                          d.partyName = p?.name;
                        });
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 18, color: c.muted),
                  onPressed: () => setState(() => _dues.removeAt(i).dispose()),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SegmentedPills<OpeningDirection>(
              values: OpeningDirection.values,
              selected: d.direction,
              labelOf: (v) =>
                  v == OpeningDirection.theyOweUs ? 'They owe us' : 'We owe them',
              onSelect: (v) => setState(() => d.direction = v),
            ),
            const SizedBox(height: 10),
            AppTextField(
                controller: d.amount,
                label: 'AMOUNT (RS)',
                numeric: true,
                prefix: 'Rs '),
          ],
        ),
      ),
    );
  }

  Widget _stockCard(int i) {
    final s = _stock[i];
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        radius: AppRadius.secondary,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _pickerBox(
                    s.catName ?? 'Choose category',
                    s.catName == null,
                    () async {
                      final picked = await showCategoryPicker(context);
                      if (picked != null) {
                        setState(() {
                          s.catId = picked.id;
                          s.catName = picked.name;
                        });
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 18, color: c.muted),
                  onPressed: () => setState(() => _stock.removeAt(i).dispose()),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                      controller: s.qty, label: 'QTY (KG)', numeric: true),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppTextField(
                      controller: s.rate,
                      label: 'COST (RS/KG)',
                      numeric: true,
                      prefix: 'Rs '),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pickerBox(String label, bool muted, VoidCallback onTap) {
    final c = context.c;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.secondary),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: c.surfaceSoft,
          borderRadius: BorderRadius.circular(AppRadius.secondary),
          border: Border.all(color: c.hairline),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: muted ? c.muted : c.ink,
                      fontWeight: FontWeight.w500)),
            ),
            Icon(Icons.expand_more, size: 18, color: c.muted),
          ],
        ),
      ),
    );
  }
}

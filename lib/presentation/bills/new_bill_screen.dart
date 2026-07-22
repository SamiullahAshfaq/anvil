import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/read_providers.dart';
import '../../core/errors/app_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_format.dart';
import '../../core/utils/money.dart';
import '../../core/utils/rounding.dart';
import '../../core/utils/weight.dart';
import '../../data/local/tables.dart';
import '../../domain/use_cases/record_expense.dart';
import '../../domain/use_cases/record_purchase.dart';
import '../../domain/use_cases/record_sale.dart';
import '../shared_widgets/amount_text.dart';
import '../shared_widgets/app_card.dart';
import '../shared_widgets/calm_sheet.dart';
import '../shared_widgets/form_fields.dart';
import '../shared_widgets/pill_button.dart';
import '../shared_widgets/use_case_runner.dart';
import '../parties/new_party_sheet.dart';
import 'bill_detail_screen.dart';
import 'category_picker.dart';

/// Opens the single New Bill entry surface (01_PRD.md §4.2). One flow with a type
/// switch — not three modules — because the owner thinks "what just happened",
/// not "which screen".
void openNewBill(BuildContext context, WidgetRef ref,
    {BillTypeDb type = BillTypeDb.purchase, String? partyId}) {
  Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => NewBillScreen(initialType: type, initialPartyId: partyId)));
}

class NewBillScreen extends ConsumerStatefulWidget {
  final BillTypeDb initialType;
  final String? initialPartyId;
  const NewBillScreen(
      {super.key, this.initialType = BillTypeDb.purchase, this.initialPartyId});

  @override
  ConsumerState<NewBillScreen> createState() => _NewBillScreenState();
}

class _LineDraft {
  String? catId;
  String? catName;
  final sub = TextEditingController();
  final weight = TextEditingController();
  final rate = TextEditingController();
  void dispose() {
    sub.dispose();
    weight.dispose();
    rate.dispose();
  }
}

class _NewBillScreenState extends ConsumerState<NewBillScreen> {
  late BillTypeDb _type = widget.initialType;
  late String? _partyId = widget.initialPartyId;
  String? _partyName;
  DateTime _date = DateTime.now();
  RateModeDb _rateMode = RateModeDb.perBill;
  final _billRate = TextEditingController();
  final List<_LineDraft> _lines = [_LineDraft()];

  // Payment (purchase advance / sale receipt).
  final _payAmount = TextEditingController();
  String? _poolId;

  // Expense-specific.
  bool _expensePayeeIsParty = false;
  String? _expenseCategoryId;

  final _note = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (_partyId != null) _resolvePartyName();
  }

  Future<void> _resolvePartyName() async {
    final db = ref.read(appDatabaseProvider);
    final p = await (db.select(db.parties)..where((t) => t.id.equals(_partyId!)))
        .getSingleOrNull();
    if (mounted) setState(() => _partyName = p?.name);
  }

  @override
  void dispose() {
    _billRate.dispose();
    _payAmount.dispose();
    _note.dispose();
    for (final l in _lines) {
      l.dispose();
    }
    super.dispose();
  }

  bool get _isExpense => _type == BillTypeDb.expense;

  int _lineTotal(_LineDraft l) {
    final g = kgStringToGrams(l.weight.text) ?? 0;
    final r = _rateMode == RateModeDb.perBill
        ? (rupeeStringToPaisa(_billRate.text) ?? 0)
        : (rupeeStringToPaisa(l.rate.text) ?? 0);
    if (g <= 0 || r < 0) return 0;
    return moneyForWeight(weightGrams: g, ratePaisaPerKg: r);
  }

  int get _billTotal =>
      _lines.fold<int>(0, (s, l) => s + _lineTotal(l));

  // ---- Save -----------------------------------------------------------------

  Future<void> _save() async {
    try {
      if (_isExpense) {
        await _saveExpense();
      } else {
        await _savePurchaseOrSale();
      }
    } on Object catch (e) {
      if (mounted) showCalmError(context, e);
    }
  }

  ({List<PurchaseLineInput> purchase, List<SaleLineInput> sale})? _buildLines() {
    final purchase = <PurchaseLineInput>[];
    final sale = <SaleLineInput>[];
    for (final l in _lines) {
      if (l.catId == null) continue;
      final g = kgStringToGrams(l.weight.text);
      if (g == null || g <= 0) {
        showCalmError(context, const ValidationException('Enter a weight for every line.'));
        return null;
      }
      final rate = _rateMode == RateModeDb.perLine
          ? rupeeStringToPaisa(l.rate.text)
          : rupeeStringToPaisa(_billRate.text);
      if (rate == null || rate < 0) {
        showCalmError(context, const ValidationException('Enter a rate.'));
        return null;
      }
      final sub = l.sub.text.trim().isEmpty ? null : l.sub.text.trim();
      purchase.add(PurchaseLineInput(
          parentCategoryId: l.catId!,
          subCategoryLabel: sub,
          weightGrams: g,
          ratePaisaPerKg: rate));
      sale.add(SaleLineInput(
          parentCategoryId: l.catId!,
          subCategoryLabel: sub,
          weightGrams: g,
          ratePaisaPerKg: rate));
    }
    if (purchase.isEmpty) {
      showCalmError(context, const ValidationException('Add at least one line item.'));
      return null;
    }
    return (purchase: purchase, sale: sale);
  }

  Future<void> _savePurchaseOrSale() async {
    if (_partyId == null) {
      showCalmError(context, const ValidationException('Choose a party first.'));
      return;
    }
    final billRate =
        _rateMode == RateModeDb.perBill ? rupeeStringToPaisa(_billRate.text) : null;
    if (_rateMode == RateModeDb.perBill && (billRate == null || billRate < 0)) {
      showCalmError(context, const ValidationException('Enter the bill rate.'));
      return;
    }
    final lines = _buildLines();
    if (lines == null) return;

    final payAmount = rupeeStringToPaisa(_payAmount.text) ?? 0;
    if (payAmount > 0 && _poolId == null) {
      showCalmError(context, const ValidationException('Choose a cash pool for the payment.'));
      return;
    }

    setState(() => _busy = true);
    final note = _note.text.trim().isEmpty ? null : _note.text.trim();
    String? billId;
    if (_type == BillTypeDb.purchase) {
      billId = await runWithConfirm<String>(context,
          action: ({confirmed = false}) =>
              ref.read(recordPurchaseProvider).call(
                    RecordPurchaseInput(
                      partyId: _partyId!,
                      date: _date,
                      rateMode: _rateMode,
                      billLevelRatePaisaPerKg: billRate,
                      lines: lines.purchase,
                      note: note,
                      advancePaisa: payAmount,
                      advancePoolId: payAmount > 0 ? _poolId : null,
                    ),
                    confirmed: confirmed,
                  ));
    } else {
      billId = await runWithConfirm<String>(context,
          action: ({confirmed = false}) => ref.read(recordSaleProvider).call(
                RecordSaleInput(
                  partyId: _partyId!,
                  date: _date,
                  rateMode: _rateMode,
                  billLevelRatePaisaPerKg: billRate,
                  lines: lines.sale,
                  note: note,
                  amountReceivedPaisa: payAmount,
                  receivedPoolId: payAmount > 0 ? _poolId : null,
                ),
                confirmed: confirmed,
              ));
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (billId != null) _onSaved(billId);
  }

  Future<void> _saveExpense() async {
    final amount = rupeeStringToPaisa(_payAmount.text);
    if (amount == null || amount <= 0) {
      showCalmError(context, const ValidationException('Enter the expense amount.'));
      return;
    }
    if (_poolId == null) {
      showCalmError(context, const ValidationException('Choose a cash pool.'));
      return;
    }
    if (_expensePayeeIsParty && _partyId == null) {
      showCalmError(context, const ValidationException('Choose a party.'));
      return;
    }
    if (!_expensePayeeIsParty && _expenseCategoryId == null) {
      showCalmError(context, const ValidationException('Choose an expense category.'));
      return;
    }
    setState(() => _busy = true);
    final billId = await runWithConfirm<String>(context,
        action: ({confirmed = false}) => ref.read(recordExpenseProvider).call(
              RecordExpenseInput(
                date: _date,
                amountPaisa: amount,
                poolId: _poolId!,
                partyId: _expensePayeeIsParty ? _partyId : null,
                expenseCategoryId:
                    _expensePayeeIsParty ? null : _expenseCategoryId,
                note: _note.text.trim().isEmpty ? null : _note.text.trim(),
              ),
              confirmed: confirmed,
            ));
    if (!mounted) return;
    setState(() => _busy = false);
    if (billId != null) _onSaved(billId);
  }

  void _onSaved(String billId) {
    bumpLedger(ref);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => BillDetailScreen(billId: billId, justCreated: true)));
  }

  // ---- Build ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New bill')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          SegmentedPills<BillTypeDb>(
            values: BillTypeDb.values,
            selected: _type,
            labelOf: (t) => switch (t) {
              BillTypeDb.purchase => 'Purchase',
              BillTypeDb.sale => 'Sale',
              BillTypeDb.expense => 'Expense',
            },
            onSelect: (t) => setState(() => _type = t),
          ),
          const SizedBox(height: 20),
          _dateRow(),
          const SizedBox(height: 16),
          if (_isExpense) ..._expenseFields() else ..._tradeFields(),
          const SizedBox(height: 16),
          AppTextField(controller: _note, label: 'NOTE (OPTIONAL)'),
          const SizedBox(height: 24),
          _totalBar(),
          const SizedBox(height: 16),
          PillButton(
            _isExpense ? 'Save expense' : 'Save bill',
            busy: _busy,
            onPressed: _busy ? null : _save,
          ),
        ],
      ),
    );
  }

  Widget _dateRow() {
    final c = context.c;
    return AppCard(
      radius: AppRadius.secondary,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _date,
          firstDate: DateTime(2015),
          lastDate: DateTime.now().add(const Duration(days: 1)),
        );
        if (picked != null) setState(() => _date = picked);
      },
      child: Row(
        children: [
          Icon(Icons.event_outlined, size: 18, color: c.muted),
          const SizedBox(width: 12),
          Text('Date', style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(formatDate(_date),
              style: TextStyle(color: c.ink, fontWeight: FontWeight.w500)),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right, size: 18, color: c.muted),
        ],
      ),
    );
  }

  List<Widget> _tradeFields() {
    return [
      _partyPickerTile(label: _type == BillTypeDb.purchase ? 'SUPPLIER' : 'BUYER'),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Rate mode', style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
      const SizedBox(height: 6),
      SegmentedPills<RateModeDb>(
        values: RateModeDb.values,
        selected: _rateMode,
        labelOf: (m) =>
            m == RateModeDb.perBill ? 'One rate for bill' : 'Rate per line',
        onSelect: (m) => setState(() => _rateMode = m),
      ),
      const SizedBox(height: 16),
      if (_rateMode == RateModeDb.perBill) ...[
        AppTextField(
            controller: _billRate,
            label: 'BILL RATE (RS / KG)',
            numeric: true,
            prefix: 'Rs ',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 16),
      ],
      Text('LINE ITEMS', style: Theme.of(context).textTheme.labelSmall),
      const SizedBox(height: 8),
      for (var i = 0; i < _lines.length; i++) _lineCard(i),
      const SizedBox(height: 4),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => setState(() => _lines.add(_LineDraft())),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add line'),
        ),
      ),
      const SizedBox(height: 12),
      _paymentSection(
          label: _type == BillTypeDb.purchase
              ? 'ADVANCE PAID (OPTIONAL)'
              : 'RECEIVED NOW (OPTIONAL)'),
    ];
  }

  Widget _lineCard(int i) {
    final c = context.c;
    final l = _lines[i];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        radius: AppRadius.secondary,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showCategoryPicker(context);
                      if (picked != null) {
                        setState(() {
                          l.catId = picked.id;
                          l.catName = picked.name;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: c.surfaceSoft,
                        borderRadius: BorderRadius.circular(AppRadius.secondary),
                        border: Border.all(color: c.hairline),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(l.catName ?? 'Choose category',
                                style: TextStyle(
                                    color: l.catName == null ? c.muted : c.ink,
                                    fontWeight: FontWeight.w500)),
                          ),
                          Icon(Icons.expand_more, size: 18, color: c.muted),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_lines.length > 1)
                  IconButton(
                    icon: Icon(Icons.close, size: 18, color: c.muted),
                    onPressed: () => setState(() {
                      _lines.removeAt(i).dispose();
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: l.sub,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Sub-category tag (optional, e.g. Pipes)',
                filled: true,
                fillColor: c.surfaceSoft,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.secondary),
                  borderSide: BorderSide(color: c.hairline),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                      controller: l.weight,
                      label: 'WEIGHT (KG)',
                      numeric: true,
                      onChanged: (_) => setState(() {})),
                ),
                if (_rateMode == RateModeDb.perLine) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppTextField(
                        controller: l.rate,
                        label: 'RATE (RS/KG)',
                        numeric: true,
                        prefix: 'Rs ',
                        onChanged: (_) => setState(() {})),
                  ),
                ],
              ],
            ),
            if (_lineTotal(l) > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Line: ', style: TextStyle(color: c.muted, fontSize: 12)),
                    AmountText(_lineTotal(l), size: 13),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _expenseFields() {
    return [
      Text('PAID TO', style: Theme.of(context).textTheme.labelSmall),
      const SizedBox(height: 6),
      SegmentedPills<bool>(
        values: const [false, true],
        selected: _expensePayeeIsParty,
        labelOf: (v) => v ? 'A party' : 'A category',
        onSelect: (v) => setState(() => _expensePayeeIsParty = v),
      ),
      const SizedBox(height: 16),
      if (_expensePayeeIsParty)
        _partyPickerTile(label: 'PARTY')
      else
        _expenseCategoryTile(),
      const SizedBox(height: 16),
      AppTextField(
          controller: _payAmount,
          label: 'AMOUNT (RS)',
          numeric: true,
          prefix: 'Rs ',
          onChanged: (_) => setState(() {})),
      const SizedBox(height: 16),
      _poolPicker(),
    ];
  }

  Widget _expenseCategoryTile() {
    final c = context.c;
    final cats = ref.watch(expenseCategoriesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text('CATEGORY',
              style: Theme.of(context).textTheme.labelSmall),
        ),
        cats.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('$e'),
          data: (list) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final e in list)
                ChoiceChip(
                  label: Text(e.name),
                  selected: _expenseCategoryId == e.id,
                  onSelected: (_) => setState(() {
                    _expenseCategoryId = e.id;
                  }),
                  backgroundColor: c.surfaceStrong,
                  selectedColor: c.primary.withValues(alpha: 0.15),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _partyPickerTile({required String label}) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(label, style: Theme.of(context).textTheme.labelSmall),
        ),
        AppCard(
          radius: AppRadius.secondary,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          onTap: () async {
            final id = await showPartyPicker(context, ref);
            if (id != null) {
              _partyId = id;
              await _resolvePartyName();
            }
          },
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 18, color: c.muted),
              const SizedBox(width: 12),
              Expanded(
                child: Text(_partyName ?? 'Choose party',
                    style: TextStyle(
                        color: _partyName == null ? c.muted : c.ink,
                        fontWeight: FontWeight.w500)),
              ),
              Icon(Icons.chevron_right, size: 18, color: c.muted),
            ],
          ),
        ),
      ],
    );
  }

  Widget _paymentSection({required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
            controller: _payAmount,
            label: label,
            numeric: true,
            prefix: 'Rs ',
            onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        if ((rupeeStringToPaisa(_payAmount.text) ?? 0) > 0) _poolPicker(),
      ],
    );
  }

  Widget _poolPicker() {
    final pools = ref.watch(cashPoolsProvider);
    return pools.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text('$e'),
      data: (list) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 6),
              child: Text('CASH POOL',
                  style: Theme.of(context).textTheme.labelSmall),
            ),
            SegmentedPills<String>(
              values: list.map((p) => p.id).toList(),
              selected: _poolId ?? list.first.id,
              labelOf: (id) {
                final p = list.firstWhere((e) => e.id == id);
                return _poolLabel(p.name);
              },
              onSelect: (id) => setState(() => _poolId = id),
            ),
          ],
        );
      },
    );
  }

  String _poolLabel(PoolNameDb n) => switch (n) {
        PoolNameDb.home => 'Home',
        PoolNameDb.bank => 'Bank',
        PoolNameDb.godam => 'Godam',
      };

  Widget _totalBar() {
    final c = context.c;
    final total = _isExpense
        ? (rupeeStringToPaisa(_payAmount.text) ?? 0)
        : _billTotal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: c.surfaceSoft,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_isExpense ? 'Expense total' : 'Bill total',
              style: Theme.of(context).textTheme.titleMedium),
          AmountText(total, size: 20, weight: FontWeight.w600),
        ],
      ),
    );
  }
}

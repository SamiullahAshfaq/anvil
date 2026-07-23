import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/cash_read_providers.dart';
import '../../app/providers.dart';
import '../../app/read_providers.dart';
import '../../core/errors/app_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_format.dart';
import '../../core/utils/money.dart';
import '../../data/local/tables.dart';
import '../../domain/use_cases/record_payment.dart';
import '../shared_widgets/amount_text.dart';
import '../shared_widgets/app_card.dart';
import '../shared_widgets/calm_sheet.dart';
import '../shared_widgets/form_fields.dart';
import '../shared_widgets/pill_button.dart';
import '../shared_widgets/use_case_runner.dart';

/// Opens the standalone payment-recording flow for a party (01_PRD.md §4.2/§4.1).
/// Manual many-to-many allocation against open bills; any remainder is an
/// advance. A `paid` payment surfaces the overdraft warning via [runWithConfirm].
void openNewPayment(BuildContext context, WidgetRef ref,
    {required String partyId, PaymentDirectionDb? direction}) {
  Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => NewPaymentScreen(
          partyId: partyId,
          initialDirection: direction ?? PaymentDirectionDb.received)));
}

class NewPaymentScreen extends ConsumerStatefulWidget {
  final String partyId;
  final PaymentDirectionDb initialDirection;
  const NewPaymentScreen({
    super.key,
    required this.partyId,
    this.initialDirection = PaymentDirectionDb.received,
  });

  @override
  ConsumerState<NewPaymentScreen> createState() => _NewPaymentScreenState();
}

class _NewPaymentScreenState extends ConsumerState<NewPaymentScreen> {
  late PaymentDirectionDb _direction = widget.initialDirection;
  final _amount = TextEditingController();
  String? _poolId;
  DateTime _date = DateTime.now();
  bool _busy = false;

  /// Manual allocation amounts keyed by bill id (text controllers).
  final Map<String, TextEditingController> _alloc = {};

  @override
  void dispose() {
    _amount.dispose();
    for (final c in _alloc.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String billId) =>
      _alloc.putIfAbsent(billId, () => TextEditingController());

  int get _amountPaisa => rupeeStringToPaisa(_amount.text) ?? 0;

  int get _allocatedPaisa {
    var sum = 0;
    for (final entry in _alloc.entries) {
      sum += rupeeStringToPaisa(entry.value.text) ?? 0;
    }
    return sum;
  }

  Future<void> _save() async {
    final amount = rupeeStringToPaisa(_amount.text);
    if (amount == null || amount <= 0) {
      showCalmError(context, const ValidationException('Enter the payment amount.'));
      return;
    }
    if (_poolId == null) {
      showCalmError(context, const ValidationException('Choose a cash pool.'));
      return;
    }
    final allocations = <AllocationInput>[];
    for (final entry in _alloc.entries) {
      final a = rupeeStringToPaisa(entry.value.text) ?? 0;
      if (a > 0) allocations.add(AllocationInput(billId: entry.key, amountPaisa: a));
    }
    if (_allocatedPaisa > amount) {
      showCalmError(context,
          const ValidationException('Allocations exceed the payment amount.'));
      return;
    }

    setState(() => _busy = true);
    final id = await runWithConfirm<String>(context,
        action: ({confirmed = false}) => ref.read(recordPaymentProvider).call(
              RecordPaymentInput(
                partyId: widget.partyId,
                amountPaisa: amount,
                direction: _direction,
                poolId: _poolId!,
                date: _date,
                allocations: allocations,
              ),
              confirmed: confirmed,
            ));
    if (!mounted) return;
    setState(() => _busy = false);
    if (id != null) {
      bumpLedger(ref);
      showCalmInfo(context, 'Payment recorded.');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final open = ref.watch(openBillsForPartyProvider(widget.partyId));
    // Received payments settle sale bills; paid payments settle purchase bills.
    final wantKind = _direction == PaymentDirectionDb.received
        ? BillTypeDb.sale
        : BillTypeDb.purchase;
    return Scaffold(
      appBar: AppBar(title: const Text('Record payment')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          SegmentedPills<PaymentDirectionDb>(
            values: PaymentDirectionDb.values,
            selected: _direction,
            labelOf: (d) =>
                d == PaymentDirectionDb.received ? 'Received' : 'Paid',
            onSelect: (d) => setState(() => _direction = d),
          ),
          const SizedBox(height: 20),
          AppTextField(
            controller: _amount,
            label: 'AMOUNT (RS)',
            numeric: true,
            prefix: 'Rs ',
            autofocus: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          _poolPicker(),
          const SizedBox(height: 16),
          _dateRow(),
          const SizedBox(height: 20),
          open.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('$e'),
            data: (bills) {
              final targets =
                  bills.where((b) => b.bill.type == wantKind).toList();
              return _allocationSection(targets);
            },
          ),
          const SizedBox(height: 24),
          PillButton(
            'Record payment',
            busy: _busy,
            onPressed: _busy ? null : _save,
          ),
        ],
      ),
    );
  }

  Widget _allocationSection(List<OpenBill> targets) {
    final c = context.c;
    final advance = _amountPaisa - _allocatedPaisa;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('ALLOCATE TO BILLS (OPTIONAL)',
                style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
        const SizedBox(height: 8),
        if (targets.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
                _direction == PaymentDirectionDb.received
                    ? 'No open sale bills — this will be recorded as an advance.'
                    : 'No open purchase bills — this will be recorded as an advance.',
                style: TextStyle(color: c.muted, fontSize: 13)),
          )
        else
          for (final b in targets) _billAllocRow(b),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: c.surfaceSoft,
            borderRadius: BorderRadius.circular(AppRadius.secondary),
          ),
          child: Row(
            children: [
              Text('Allocated', style: TextStyle(color: c.muted)),
              const Spacer(),
              AmountText(_allocatedPaisa, size: 14),
              Text('  of  ', style: TextStyle(color: c.muted)),
              AmountText(_amountPaisa, size: 14),
            ],
          ),
        ),
        if (advance > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 15, color: c.muted),
                const SizedBox(width: 8),
                Text('Unallocated becomes an advance: ',
                    style: TextStyle(color: c.muted, fontSize: 12)),
                AmountText(advance, size: 12),
              ],
            ),
          ),
      ],
    );
  }

  Widget _billAllocRow(OpenBill b) {
    final c = context.c;
    final controller = _controllerFor(b.bill.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        radius: AppRadius.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                      '${b.bill.type == BillTypeDb.sale ? 'Sale' : 'Purchase'} · ${formatDate(b.bill.date)}',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                InkWell(
                  onTap: () {
                    // Convenience only — never silently auto-fill (03_RULES.md §5):
                    // caps at the payment's remaining, user still confirms Save.
                    final remaining = _amountPaisa - _allocatedPaisa +
                        (rupeeStringToPaisa(controller.text) ?? 0);
                    final fill = remaining < b.outstandingPaisa
                        ? remaining
                        : b.outstandingPaisa;
                    controller.text =
                        fill <= 0 ? '' : fill.toRupeeString(showSymbol: false);
                    setState(() {});
                  },
                  child: Row(
                    children: [
                      Text('Due ', style: TextStyle(color: c.muted, fontSize: 12)),
                      AmountText(b.outstandingPaisa, size: 13),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: controller,
              label: 'ALLOCATE (RS)',
              numeric: true,
              prefix: 'Rs ',
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
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
              labelOf: (id) => poolLabel(list.firstWhere((e) => e.id == id).name),
              onSelect: (id) => setState(() => _poolId = id),
            ),
          ],
        );
      },
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
}

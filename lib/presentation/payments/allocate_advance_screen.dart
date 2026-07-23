import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/cash_read_providers.dart';
import '../../app/providers.dart';
import '../../core/errors/app_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_format.dart';
import '../../core/utils/money.dart';
import '../../data/local/tables.dart';
import '../../domain/use_cases/record_payment.dart' show AllocationInput;
import '../shared_widgets/amount_text.dart';
import '../shared_widgets/app_card.dart';
import '../shared_widgets/calm_sheet.dart';
import '../shared_widgets/form_fields.dart';
import '../shared_widgets/pill_button.dart';
import '../shared_widgets/use_case_runner.dart';

/// Allocates an EXISTING advance payment against open bills (01_PRD.md §4.2).
/// This inserts PaymentAllocation rows ONLY — never a new CashMovement, because
/// the cash already moved when the advance was recorded (03_RULES.md §1.20).
class AllocateAdvanceScreen extends ConsumerWidget {
  final String partyId;
  const AllocateAdvanceScreen({super.key, required this.partyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final advances = ref.watch(partyAdvancesProvider(partyId));
    final c = context.c;
    return Scaffold(
      appBar: AppBar(title: const Text('Allocate advance')),
      body: advances.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text('No unallocated advances for this party.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: c.muted)),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              Text('Pick an advance to place against open bills.',
                  style: TextStyle(color: c.muted)),
              const SizedBox(height: 12),
              for (final a in list) _AdvanceCard(partyId: partyId, advance: a),
            ],
          );
        },
      ),
    );
  }
}

class _AdvanceCard extends StatelessWidget {
  final String partyId;
  final PartyAdvance advance;
  const _AdvanceCard({required this.partyId, required this.advance});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final received = advance.payment.direction == PaymentDirectionDb.received;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        radius: AppRadius.secondary,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) =>
                _AllocateOneScreen(partyId: partyId, advance: advance))),
        child: Row(
          children: [
            Icon(Icons.savings_outlined, size: 20, color: c.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(received ? 'Advance received' : 'Advance paid',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(formatDate(advance.payment.date),
                      style: TextStyle(color: c.muted, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AmountText(advance.unallocatedPaisa,
                    size: 15, weight: FontWeight.w600),
                Text('unallocated',
                    style: TextStyle(color: c.muted, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AllocateOneScreen extends ConsumerStatefulWidget {
  final String partyId;
  final PartyAdvance advance;
  const _AllocateOneScreen({required this.partyId, required this.advance});

  @override
  ConsumerState<_AllocateOneScreen> createState() => _AllocateOneScreenState();
}

class _AllocateOneScreenState extends ConsumerState<_AllocateOneScreen> {
  final Map<String, TextEditingController> _alloc = {};
  bool _busy = false;

  @override
  void dispose() {
    for (final c in _alloc.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String billId) =>
      _alloc.putIfAbsent(billId, () => TextEditingController());

  int get _allocatedPaisa {
    var sum = 0;
    for (final entry in _alloc.entries) {
      sum += rupeeStringToPaisa(entry.value.text) ?? 0;
    }
    return sum;
  }

  Future<void> _save() async {
    final allocations = <AllocationInput>[];
    for (final entry in _alloc.entries) {
      final a = rupeeStringToPaisa(entry.value.text) ?? 0;
      if (a > 0) allocations.add(AllocationInput(billId: entry.key, amountPaisa: a));
    }
    if (allocations.isEmpty) {
      showCalmError(context, const ValidationException('Allocate to at least one bill.'));
      return;
    }
    if (_allocatedPaisa > widget.advance.unallocatedPaisa) {
      showCalmError(context,
          const ValidationException('Allocation exceeds this advance.'));
      return;
    }
    setState(() => _busy = true);
    final ok = await confirmAndRun(context,
        action: ({confirmed = false}) => ref.read(allocatePaymentProvider).call(
              paymentId: widget.advance.payment.id,
              allocations: allocations,
            ));
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      bumpLedger(ref);
      showCalmInfo(context, 'Advance allocated.');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final received =
        widget.advance.payment.direction == PaymentDirectionDb.received;
    final wantKind = received ? BillTypeDb.sale : BillTypeDb.purchase;
    final open = ref.watch(openBillsForPartyProvider(widget.partyId));
    final c = context.c;
    return Scaffold(
      appBar: AppBar(title: const Text('Allocate advance')),
      body: open.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (bills) {
          final targets = bills.where((b) => b.bill.type == wantKind).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: c.surfaceSoft,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Row(
                  children: [
                    Text('Advance to place',
                        style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    AmountText(widget.advance.unallocatedPaisa,
                        size: 18, weight: FontWeight.w600),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (targets.isEmpty)
                Text('No open ${received ? 'sale' : 'purchase'} bills to allocate against.',
                    style: TextStyle(color: c.muted))
              else
                for (final b in targets) _billRow(b),
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
                    AmountText(widget.advance.unallocatedPaisa, size: 14),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PillButton('Allocate',
                  busy: _busy,
                  onPressed: (_busy || targets.isEmpty) ? null : _save),
            ],
          );
        },
      ),
    );
  }

  Widget _billRow(OpenBill b) {
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
                    final remaining = widget.advance.unallocatedPaisa -
                        _allocatedPaisa +
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
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/errors/app_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_format.dart';
import '../../core/utils/money.dart';
import '../../data/local/tables.dart';
import '../shared_widgets/calm_sheet.dart';
import '../shared_widgets/form_fields.dart';
import '../shared_widgets/pill_button.dart';
import '../shared_widgets/use_case_runner.dart';

/// Opens the "Transfer to Godam" flow (01_PRD.md §4.4). Money moves from Home or
/// Bank into Godam as two paired movements; the overdraft soft-warning is
/// surfaced via the shared [runWithConfirm] round-trip (03_RULES.md §1.25).
Future<bool> showTransferToGodamSheet(BuildContext context, WidgetRef ref) async {
  final done = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _TransferSheet(),
  );
  return done ?? false;
}

class _TransferSheet extends ConsumerStatefulWidget {
  const _TransferSheet();

  @override
  ConsumerState<_TransferSheet> createState() => _TransferSheetState();
}

class _TransferSheetState extends ConsumerState<_TransferSheet> {
  final _amount = TextEditingController();
  PoolNameDb _from = PoolNameDb.home;
  DateTime _date = DateTime.now();
  bool _busy = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = rupeeStringToPaisa(_amount.text);
    if (amount == null || amount <= 0) {
      showCalmError(context, const ValidationException('Enter an amount to transfer.'));
      return;
    }
    setState(() => _busy = true);
    final id = await runWithConfirm<String>(context,
        action: ({confirmed = false}) => ref.read(transferToGodamProvider).call(
              from: _from,
              amountPaisa: amount,
              date: _date,
              confirmed: confirmed,
            ));
    if (!mounted) return;
    setState(() => _busy = false);
    if (id != null) {
      bumpLedger(ref);
      showCalmInfo(context, 'Moved to Godam.');
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: c.hairline),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Transfer to Godam',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('Earmark Home or Bank cash to fund Godam purchases.',
                  style: TextStyle(color: c.muted, fontSize: 13)),
              const SizedBox(height: 18),
              Text('FROM', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 6),
              SegmentedPills<PoolNameDb>(
                values: const [PoolNameDb.home, PoolNameDb.bank],
                selected: _from,
                labelOf: (n) => n == PoolNameDb.home ? 'Home' : 'Bank',
                onSelect: (n) => setState(() => _from = n),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _amount,
                label: 'AMOUNT (RS)',
                numeric: true,
                prefix: 'Rs ',
                autofocus: true,
              ),
              const SizedBox(height: 14),
              InkWell(
                borderRadius: BorderRadius.circular(AppRadius.secondary),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2015),
                    lastDate: DateTime.now().add(const Duration(days: 1)),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: c.surfaceSoft,
                    borderRadius: BorderRadius.circular(AppRadius.secondary),
                    border: Border.all(color: c.hairline),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event_outlined, size: 18, color: c.muted),
                      const SizedBox(width: 12),
                      Text('Date',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const Spacer(),
                      Text(formatDate(_date),
                          style: TextStyle(
                              color: c.ink, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: PillButton('Transfer',
                    busy: _busy, onPressed: _busy ? null : _submit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

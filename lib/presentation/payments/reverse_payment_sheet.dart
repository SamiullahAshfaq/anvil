import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/errors/app_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local/database.dart';
import '../shared_widgets/amount_text.dart';
import '../shared_widgets/calm_sheet.dart';
import '../shared_widgets/form_fields.dart';
import '../shared_widgets/pill_button.dart';
import '../shared_widgets/use_case_runner.dart';

/// Reverses a bounced/failed payment (01_PRD.md §4.8, 03_RULES.md §1.24) —
/// non-destructive: the bills it settled reopen, an offsetting cash movement is
/// posted, a permanent ledger note is written, and the payment is flagged
/// `reversed` (never deleted). Returns true if it was reversed.
Future<bool> showReversePaymentSheet(
    BuildContext context, WidgetRef ref, Payment payment) async {
  final done = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _ReverseSheet(payment: payment),
  );
  return done ?? false;
}

class _ReverseSheet extends ConsumerStatefulWidget {
  final Payment payment;
  const _ReverseSheet({required this.payment});

  @override
  ConsumerState<_ReverseSheet> createState() => _ReverseSheetState();
}

class _ReverseSheetState extends ConsumerState<_ReverseSheet> {
  final _reason = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_reason.text.trim().isEmpty) {
      showCalmError(context, const ValidationException('A reversal needs a reason.'));
      return;
    }
    setState(() => _busy = true);
    final ok = await confirmAndRun(context,
        action: ({confirmed = false}) => ref.read(reversePaymentProvider).call(
              paymentId: widget.payment.id,
              reason: _reason.text.trim(),
            ));
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      bumpLedger(ref);
      showCalmInfo(context, 'Payment reversed. Affected bills have reopened.');
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
              Text('Reverse this payment?',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text('Amount  ', style: TextStyle(color: c.muted)),
                  AmountText(widget.payment.amountPaisa,
                      size: 15, weight: FontWeight.w600),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                  'The bills this settled will reopen and the cash leaves the pool it went into. The original record is kept, flagged as reversed.',
                  style: TextStyle(color: c.body, height: 1.4, fontSize: 13)),
              const SizedBox(height: 16),
              AppTextField(
                controller: _reason,
                label: 'REASON (e.g. cheque bounced)',
                autofocus: true,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: PillButton('Cancel',
                        primary: false,
                        onPressed: () => Navigator.of(context).pop(false)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PillButton('Reverse',
                        danger: true,
                        busy: _busy,
                        onPressed: _busy ? null : _submit),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

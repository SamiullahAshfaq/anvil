import 'package:drift/drift.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/ids.dart';
import '../../data/local/database.dart';
import '../../data/local/tables.dart';
import '../../security/access_mode.dart';
import '../services/cash_overdraft_service.dart';
import 'overdraft_guard.dart';
import 'use_case_result.dart';

/// One allocation of this new payment against a bill.
class AllocationInput {
  final String billId;
  final int amountPaisa;
  const AllocationInput({required this.billId, required this.amountPaisa});
}

class RecordPaymentInput {
  final String partyId;
  final int amountPaisa;
  final PaymentDirectionDb direction;
  final String poolId;
  final DateTime date;

  /// Optional manual allocations against open bills. Any remainder becomes an
  /// unallocated advance balance (manual allocation only — no auto-FIFO).
  final List<AllocationInput> allocations;
  final String? note;

  const RecordPaymentInput({
    required this.partyId,
    required this.amountPaisa,
    required this.direction,
    required this.poolId,
    required this.date,
    this.allocations = const [],
    this.note,
  });
}

/// Records a NEW payment: moves cash (one movement) and inserts any manual
/// allocations. Cash direction follows payment direction — `received` money comes
/// IN to the pool, `paid` money goes OUT. Overdraft warning applies only to
/// outgoing (paid) payments.
class RecordPayment {
  final AppDatabase db;
  final AccessController access;
  final CashOverdraftService overdraft;

  const RecordPayment({
    required this.db,
    required this.access,
    this.overdraft = const CashOverdraftService(),
  });

  Future<UseCaseResult<String>> call(
    RecordPaymentInput input, {
    bool confirmed = false,
  }) async {
    access.ensureCanMutate();
    if (input.amountPaisa <= 0) {
      throw const ValidationException('Payment amount must be positive.');
    }
    final allocated =
        input.allocations.fold<int>(0, (s, a) => s + a.amountPaisa);
    if (allocated > input.amountPaisa) {
      throw const ValidationException(
          'Allocations exceed the payment amount.');
    }

    if (input.direction == PaymentDirectionDb.paid && !confirmed) {
      final warning = await overdraftWarningIfAny(db, overdraft,
          poolId: input.poolId, withdrawalPaisa: input.amountPaisa);
      if (warning != null) return NeedsConfirmation([warning]);
    }

    try {
      final paymentId = await db.transaction(() async {
        final paymentId = newId();
        final isAdvance = allocated < input.amountPaisa;
        await db.into(db.payments).insert(PaymentsCompanion.insert(
              id: paymentId,
              partyId: input.partyId,
              amountPaisa: input.amountPaisa,
              direction: input.direction,
              poolId: input.poolId,
              date: input.date,
              isAdvance: Value(isAdvance),
            ));
        await db.into(db.cashMovements).insert(CashMovementsCompanion.insert(
              id: newId(),
              poolId: input.poolId,
              direction: input.direction == PaymentDirectionDb.received
                  ? CashDirectionDb.moneyIn
                  : CashDirectionDb.moneyOut,
              amountPaisa: input.amountPaisa,
              date: input.date,
              relatedPaymentId: Value(paymentId),
            ));
        for (final a in input.allocations) {
          await db
              .into(db.paymentAllocations)
              .insert(PaymentAllocationsCompanion.insert(
                id: newId(),
                paymentId: paymentId,
                billId: a.billId,
                amountAllocatedPaisa: a.amountPaisa,
              ));
        }
        return paymentId;
      });
      return Success(paymentId);
    } on AppException {
      rethrow;
    } catch (e) {
      throw TransactionFailedException(
          'Something didn\'t save — nothing was changed, try again.', e);
    }
  }
}

import 'package:drift/drift.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/ids.dart';
import '../../data/local/database.dart';
import '../../data/local/tables.dart';
import '../../security/access_mode.dart';
import 'use_case_result.dart';

/// Reverses a payment that later failed (bounced cheque / failed transfer) —
/// **non-destructively** (03_RULES.md §1.24, §2.16). In one transaction:
///  1. Remove the payment's `PaymentAllocation` rows, so the bills it settled
///     return to their prior open balance (balances are derived).
///  2. Post an offsetting `CashMovement` in the opposite direction, so the pool
///     balance reverts (money leaves a pool it was received into, and vice versa).
///  3. Write a permanent timestamped `UpdateHistory` note on the party record.
///  4. Flag the original `Payment` as `reversed` — it is NEVER deleted.
class ReversePayment {
  final AppDatabase db;
  final AccessController access;

  const ReversePayment({required this.db, required this.access});

  Future<UseCaseResult<void>> call({
    required String paymentId,
    required String reason,
  }) async {
    access.ensureCanMutate();
    if (reason.trim().isEmpty) {
      throw const ValidationException('A reversal needs a reason.');
    }

    try {
      await db.transaction(() async {
        final payment = await (db.select(db.payments)
              ..where((t) => t.id.equals(paymentId)))
            .getSingle();
        if (payment.reversed) {
          throw const ValidationException('This payment is already reversed.');
        }
        final now = DateTime.now();

        // 1. Bills reopen: derived balances recompute once allocations are gone.
        await (db.delete(db.paymentAllocations)
              ..where((t) => t.paymentId.equals(paymentId)))
            .go();

        // 2. Offsetting cash movement (opposite direction reverts the pool).
        await db.into(db.cashMovements).insert(CashMovementsCompanion.insert(
              id: newId(),
              poolId: payment.poolId,
              direction: payment.direction == PaymentDirectionDb.received
                  ? CashDirectionDb.moneyOut
                  : CashDirectionDb.moneyIn,
              amountPaisa: payment.amountPaisa,
              date: now,
              relatedPaymentId: Value(paymentId),
            ));

        // 3. Permanent ledger note on the party.
        await db.into(db.updateHistories).insert(UpdateHistoriesCompanion.insert(
              id: newId(),
              entityType: 'Party',
              entityId: payment.partyId,
              fieldChanged: 'paymentReversed',
              oldValue: Value(paymentId),
              newValue: Value(reason.trim()),
              changedAt: now,
            ));

        // 4. Flag (never delete) the original payment.
        await (db.update(db.payments)..where((t) => t.id.equals(paymentId)))
            .write(PaymentsCompanion(
          reversed: const Value(true),
          reversedAt: Value(now),
          reversalReason: Value(reason.trim()),
        ));
      });
      return const Success(null);
    } on AppException {
      rethrow;
    } catch (e) {
      throw TransactionFailedException(
          'Something didn\'t save — nothing was changed, try again.', e);
    }
  }
}

import 'package:drift/drift.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/ids.dart';
import '../../data/local/database.dart';
import '../../security/access_mode.dart';
import 'record_payment.dart' show AllocationInput;
import 'use_case_result.dart';

/// Allocates the **unallocated advance balance** of an EXISTING payment against
/// one or more bills.
///
/// CRITICAL (03_RULES.md §1.20, §2.17): this inserts `PaymentAllocation` rows
/// **only** — it must NEVER create a new `CashMovement`. The cash already moved
/// when the original advance payment was recorded; a second movement here would
/// double-count cash. There is a regression test for exactly this.
class AllocatePayment {
  final AppDatabase db;
  final AccessController access;

  const AllocatePayment({required this.db, required this.access});

  Future<UseCaseResult<void>> call({
    required String paymentId,
    required List<AllocationInput> allocations,
  }) async {
    access.ensureCanMutate();
    if (allocations.isEmpty) {
      throw const ValidationException('No allocations provided.');
    }

    try {
      await db.transaction(() async {
        final payment = await (db.select(db.payments)
              ..where((t) => t.id.equals(paymentId)))
            .getSingle();
        if (payment.reversed) {
          throw const ValidationException(
              'This payment was reversed and cannot be allocated.');
        }

        final existing = await (db.select(db.paymentAllocations)
              ..where((t) => t.paymentId.equals(paymentId)))
            .get();
        final alreadyAllocated =
            existing.fold<int>(0, (s, a) => s + a.amountAllocatedPaisa);
        final requested =
            allocations.fold<int>(0, (s, a) => s + a.amountPaisa);
        if (alreadyAllocated + requested > payment.amountPaisa) {
          throw const ValidationException(
              'Allocation exceeds the payment\'s unallocated balance.');
        }

        for (final a in allocations) {
          // PaymentAllocation ONLY — no CashMovement (cash already moved).
          await db
              .into(db.paymentAllocations)
              .insert(PaymentAllocationsCompanion.insert(
                id: newId(),
                paymentId: paymentId,
                billId: a.billId,
                amountAllocatedPaisa: a.amountPaisa,
              ));
        }

        // The payment is no longer a pure advance if fully allocated now.
        if (alreadyAllocated + requested == payment.amountPaisa) {
          await (db.update(db.payments)
                ..where((t) => t.id.equals(paymentId)))
              .write(const PaymentsCompanion(isAdvance: Value(false)));
        }
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

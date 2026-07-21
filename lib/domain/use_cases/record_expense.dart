import 'package:drift/drift.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/ids.dart';
import '../../data/local/database.dart';
import '../../data/local/tables.dart';
import '../../security/access_mode.dart';
import '../services/cash_overdraft_service.dart';
import 'overdraft_guard.dart';
import 'use_case_result.dart';

class RecordExpenseInput {
  final DateTime date;
  final int amountPaisa;
  final String poolId;

  /// Exactly one of these identifies the payee: an existing party (owner drawing,
  /// a person) OR a free-standing expense category (Salaries/Food/…). Either way
  /// this feeds the P&L as a cost line and never touches stock or party balances.
  final String? partyId;
  final String? expenseCategoryId;

  final String? photoPath;
  final String? note;

  const RecordExpenseInput({
    required this.date,
    required this.amountPaisa,
    required this.poolId,
    this.partyId,
    this.expenseCategoryId,
    this.photoPath,
    this.note,
  });
}

/// Records an expense as ONE transaction: an expense bill + a cash-out movement.
/// Does not touch stock (03_RULES.md; 01_PRD.md §4.2). Overdraft is a soft
/// warning surfaced before any write.
class RecordExpense {
  final AppDatabase db;
  final AccessController access;
  final CashOverdraftService overdraft;

  const RecordExpense({
    required this.db,
    required this.access,
    this.overdraft = const CashOverdraftService(),
  });

  Future<UseCaseResult<String>> call(
    RecordExpenseInput input, {
    bool confirmed = false,
  }) async {
    access.ensureCanMutate();
    if (input.amountPaisa <= 0) {
      throw const ValidationException('Expense amount must be positive.');
    }
    if ((input.partyId == null) == (input.expenseCategoryId == null)) {
      throw const ValidationException(
          'An expense needs exactly one payee: a party or an expense category.');
    }

    if (!confirmed) {
      final warning = await overdraftWarningIfAny(db, overdraft,
          poolId: input.poolId, withdrawalPaisa: input.amountPaisa);
      if (warning != null) return NeedsConfirmation([warning]);
    }

    try {
      final billId = await db.transaction(() async {
        final billId = newId();
        final now = DateTime.now();
        await db.into(db.bills).insert(BillsCompanion.insert(
              id: billId,
              type: BillTypeDb.expense,
              partyId: Value(input.partyId),
              expenseCategoryId: Value(input.expenseCategoryId),
              date: input.date,
              photoPath: Value(input.photoPath),
              rateMode: RateModeDb.perBill,
              totalAmountPaisa: input.amountPaisa,
              note: Value(input.note),
              createdAt: now,
              updatedAt: now,
            ));
        await db.into(db.cashMovements).insert(CashMovementsCompanion.insert(
              id: newId(),
              poolId: input.poolId,
              direction: CashDirectionDb.moneyOut,
              amountPaisa: input.amountPaisa,
              date: input.date,
              relatedBillId: Value(billId),
            ));
        return billId;
      });
      return Success(billId);
    } on AppException {
      rethrow;
    } catch (e) {
      throw TransactionFailedException(
          'Something didn\'t save — nothing was changed, try again.', e);
    }
  }
}

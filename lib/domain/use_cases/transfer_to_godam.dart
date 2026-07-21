import 'package:drift/drift.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/ids.dart';
import '../../data/local/database.dart';
import '../../data/local/queries.dart';
import '../../data/local/tables.dart';
import '../../security/access_mode.dart';
import '../services/cash_overdraft_service.dart';
import 'overdraft_guard.dart';
import 'use_case_result.dart';

/// Moves cash into Godam from Home or Bank. A transfer is TWO `CashMovement`
/// rows sharing a `transferId` and cross-referencing via `pairedMovementId`: one
/// OUT of the source pool, one IN to Godam (02_ARCHITECTURE.md §6). Godam spend
/// traceability is later computed dynamically from these IN rows, FIFO.
class TransferToGodam {
  final AppDatabase db;
  final AccessController access;
  final CashOverdraftService overdraft;

  const TransferToGodam({
    required this.db,
    required this.access,
    this.overdraft = const CashOverdraftService(),
  });

  Future<UseCaseResult<String>> call({
    required PoolNameDb from,
    required int amountPaisa,
    required DateTime date,
    bool confirmed = false,
  }) async {
    access.ensureCanMutate();
    if (amountPaisa <= 0) {
      throw const ValidationException('Transfer amount must be positive.');
    }
    if (from == PoolNameDb.godam) {
      throw const ValidationException('Transfer must come from Home or Bank.');
    }

    final source = await db.poolByName(from);
    final godam = await db.poolByName(PoolNameDb.godam);

    if (!confirmed) {
      final warning = await overdraftWarningIfAny(db, overdraft,
          poolId: source.id, withdrawalPaisa: amountPaisa);
      if (warning != null) return NeedsConfirmation([warning]);
    }

    try {
      final transferId = await db.transaction(() async {
        final transferId = newId();
        final outId = newId();
        final inId = newId();

        await db.into(db.cashMovements).insert(CashMovementsCompanion.insert(
              id: outId,
              poolId: source.id,
              direction: CashDirectionDb.moneyOut,
              amountPaisa: amountPaisa,
              date: date,
              transferId: Value(transferId),
              pairedMovementId: Value(inId),
            ));
        await db.into(db.cashMovements).insert(CashMovementsCompanion.insert(
              id: inId,
              poolId: godam.id,
              direction: CashDirectionDb.moneyIn,
              amountPaisa: amountPaisa,
              date: date,
              transferId: Value(transferId),
              pairedMovementId: Value(outId),
            ));
        return transferId;
      });
      return Success(transferId);
    } on AppException {
      rethrow;
    } catch (e) {
      throw TransactionFailedException(
          'Something didn\'t save — nothing was changed, try again.', e);
    }
  }
}

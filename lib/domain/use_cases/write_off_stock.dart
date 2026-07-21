import 'package:drift/drift.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/ids.dart';
import '../../data/local/database.dart';
import '../../data/local/mappers.dart';
import '../../data/local/queries.dart';
import '../../data/local/tables.dart';
import '../../security/access_mode.dart';
import '../services/stock_costing_service.dart';
import 'use_case_result.dart';

/// Reduces a parent category's physical quantity without a sale — sorting loss,
/// moisture, discarded dross (03_RULES.md §1.23). Two modes:
///  - [WriteOffMode.absorbIntoRemaining]: quantity drops, total cost preserved,
///    so avg/unit rises. No P&L or cash impact.
///  - [WriteOffMode.expenseWastage]: quantity drops, avg untouched, and the
///    removed value is posted as a non-cash Wastage expense (recorded on the
///    StockWriteOff row against the reserved "Wastage" expense category).
///
/// Never touches revenue, party balances, or cash.
class WriteOffStock {
  final AppDatabase db;
  final AccessController access;
  final StockCostingService costing;

  const WriteOffStock({
    required this.db,
    required this.access,
    this.costing = const StockCostingService(),
  });

  Future<UseCaseResult<String>> call({
    required String parentCategoryId,
    required int weightGrams,
    required WriteOffMode mode,
    String? note,
    DateTime? date,
  }) async {
    access.ensureCanMutate();
    if (weightGrams <= 0) {
      throw const ValidationException('Write-off weight must be positive.');
    }

    try {
      final writeOffId = await db.transaction(() async {
        final cat = await (db.select(db.stockCategories)
              ..where((t) => t.id.equals(parentCategoryId)))
            .getSingle();

        final result = costing.applyWriteOff(
          cat.toStockPosition(),
          weightGrams: weightGrams,
          mode: mode,
        );

        await (db.update(db.stockCategories)
              ..where((t) => t.id.equals(parentCategoryId)))
            .write(StockCategoriesCompanion(
          quantityGrams: Value(result.position.quantityGrams),
          totalCostBasisPaisa: Value(result.position.totalCostBasisPaisa),
        ));

        String? wastageCategoryId;
        if (mode == WriteOffMode.expenseWastage) {
          final wastage = await db.expenseCategoryByName('Wastage');
          wastageCategoryId = wastage?.id;
        }

        final id = newId();
        await db.into(db.stockWriteOffs).insert(StockWriteOffsCompanion.insert(
              id: id,
              parentCategoryId: parentCategoryId,
              weightGrams: weightGrams,
              mode: mode == WriteOffMode.absorbIntoRemaining
                  ? WriteOffModeDb.absorbIntoRemaining
                  : WriteOffModeDb.expenseWastage,
              relatedExpenseCategoryId: Value(wastageCategoryId),
              expensePaisa: Value(result.expensePaisa),
              note: Value(note),
              date: date ?? DateTime.now(),
            ));
        return id;
      });
      return Success(writeOffId);
    } on AppException {
      rethrow;
    } catch (e) {
      throw TransactionFailedException(
          'Something didn\'t save — nothing was changed, try again.', e);
    }
  }
}

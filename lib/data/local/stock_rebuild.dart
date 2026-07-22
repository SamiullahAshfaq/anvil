import 'package:drift/drift.dart';

import '../../domain/entities/stock_position.dart';
import '../../domain/services/stock_costing_service.dart';
import 'database.dart';
import 'tables.dart';

/// One stock-affecting event in a category's history, used to rebuild the stored
/// running quantity/cost from scratch.
class _StockEvent {
  final DateTime when;
  final int seq; // tiebreaker for same-instant ordering
  final StockPosition Function(StockPosition, StockCostingService) apply;
  _StockEvent(this.when, this.seq, this.apply);
}

/// Rebuilds a parent category's stored `quantityGrams` + `totalCostBasisPaisa`
/// by replaying every surviving (non-deleted) purchase line, sale line, and
/// write-off through the pure [StockCostingService], in chronological order.
///
/// This is how a soft-delete or restore of a stock-affecting bill stays exact:
/// rather than approximate an inverse of the moving-average math (which is not
/// cleanly invertible across a zero/negative-reset crossing), we recompute the
/// stored total from the ledger that remains. Cheap for a single-owner business
/// and always self-consistent (03_RULES.md §1.4/§1.16). Must be called inside a
/// `db.transaction` so its write joins the surrounding atomic operation.
extension StockRebuild on AppDatabase {
  Future<void> rebuildCategoryStock(
    String parentCategoryId, {
    StockCostingService costing = const StockCostingService(),
  }) async {
    final events = <_StockEvent>[];

    final lineRows = await (select(billLineItems).join([
      innerJoin(bills, bills.id.equalsExp(billLineItems.billId)),
    ])
          ..where(billLineItems.parentCategoryId.equals(parentCategoryId) &
              bills.deletedAt.isNull()))
        .get();
    for (final r in lineRows) {
      final line = r.readTable(billLineItems);
      final bill = r.readTable(bills);
      if (bill.type == BillTypeDb.purchase) {
        events.add(_StockEvent(
          bill.date,
          bill.createdAt.microsecondsSinceEpoch,
          (pos, c) => c
              .applyPurchase(pos,
                  weightGrams: line.weightGrams, ratePaisaPerKg: line.ratePaisaPerKg)
              .position,
        ));
      } else if (bill.type == BillTypeDb.sale) {
        events.add(_StockEvent(
          bill.date,
          bill.createdAt.microsecondsSinceEpoch,
          (pos, c) =>
              c.applySale(pos, weightGrams: line.weightGrams).position,
        ));
      }
    }

    final woRows = await (select(stockWriteOffs)
          ..where((t) =>
              t.parentCategoryId.equals(parentCategoryId) & t.deletedAt.isNull()))
        .get();
    for (final w in woRows) {
      final mode = w.mode == WriteOffModeDb.absorbIntoRemaining
          ? WriteOffMode.absorbIntoRemaining
          : WriteOffMode.expenseWastage;
      events.add(_StockEvent(
        w.date,
        w.date.microsecondsSinceEpoch,
        (pos, c) =>
            c.applyWriteOff(pos, weightGrams: w.weightGrams, mode: mode).position,
      ));
    }

    events.sort((a, b) {
      final c = a.when.compareTo(b.when);
      return c != 0 ? c : a.seq.compareTo(b.seq);
    });

    var pos = const StockPosition.empty();
    for (final e in events) {
      pos = e.apply(pos, costing);
    }

    await (update(stockCategories)..where((t) => t.id.equals(parentCategoryId)))
        .write(StockCategoriesCompanion(
      quantityGrams: Value(pos.quantityGrams),
      totalCostBasisPaisa: Value(pos.totalCostBasisPaisa),
    ));
  }
}

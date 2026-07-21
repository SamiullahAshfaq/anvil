import 'package:drift/drift.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/ids.dart';
import '../../data/local/database.dart';
import '../../data/local/mappers.dart';
import '../../data/local/tables.dart';
import '../../security/access_mode.dart';
import '../services/stock_costing_service.dart';
import 'use_case_result.dart';

enum OpeningDirection { theyOweUs, weOweThem }

/// A party's opening due. Recorded as a genuine dated opening bill (a receivable
/// becomes a sale bill; a payable becomes a purchase bill) — never a raw editable
/// balance field (03_RULES.md §1.26). These carry no line items, so they seed the
/// party balance without touching stock.
class PartyOpening {
  final String partyId;
  final OpeningDirection direction;
  final int amountPaisa;
  const PartyOpening({
    required this.partyId,
    required this.direction,
    required this.amountPaisa,
  });
}

/// Starting cash in a pool, recorded as a dated opening cash movement.
class CashOpening {
  final PoolNameDb pool;
  final int amountPaisa;
  const CashOpening({required this.pool, required this.amountPaisa});
}

/// Baseline stock for a parent category, recorded as a dated opening purchase
/// (party-less) so it flows through the moving-average reset path and appears in
/// the stock ledger — never a raw editable qty/cost field.
class StockOpening {
  final String parentCategoryId;
  final int quantityGrams;
  final int ratePaisaPerKg;
  const StockOpening({
    required this.parentCategoryId,
    required this.quantityGrams,
    required this.ratePaisaPerKg,
  });
}

class DayZeroInput {
  final DateTime date;
  final List<PartyOpening> partyOpenings;
  final List<CashOpening> cashOpenings;
  final List<StockOpening> stockOpenings;
  final String? note;
  const DayZeroInput({
    required this.date,
    this.partyOpenings = const [],
    this.cashOpenings = const [],
    this.stockOpenings = const [],
    this.note,
  });
}

/// Onboards an already-running business by compressing its pre-app history into
/// one dated starting point — opening party dues, cash positions, and stock
/// baselines, all as genuine immutable ledger entries so the derived-balance
/// model holds from day one (01_PRD.md §4.1, 03_RULES.md §1.26). Runs once.
class RunDayZeroMigration {
  final AppDatabase db;
  final AccessController access;
  final StockCostingService costing;

  const RunDayZeroMigration({
    required this.db,
    required this.access,
    this.costing = const StockCostingService(),
  });

  Future<UseCaseResult<String>> call(DayZeroInput input) async {
    access.ensureCanMutate();

    try {
      final migrationId = await db.transaction(() async {
        final existing = await db.select(db.dayZeroMigrations).get();
        if (existing.isNotEmpty) {
          throw const ValidationException(
              'Day-0 migration has already been performed.');
        }

        final migrationId = newId();
        await db
            .into(db.dayZeroMigrations)
            .insert(DayZeroMigrationsCompanion.insert(
              id: migrationId,
              performedAt: input.date,
              note: Value(input.note),
            ));

        final now = DateTime.now();

        // Party opening dues → dated opening bills (no line items → no stock).
        for (final o in input.partyOpenings) {
          if (o.amountPaisa <= 0) continue;
          await db.into(db.bills).insert(BillsCompanion.insert(
                id: newId(),
                type: o.direction == OpeningDirection.theyOweUs
                    ? BillTypeDb.sale
                    : BillTypeDb.purchase,
                partyId: Value(o.partyId),
                date: input.date,
                rateMode: RateModeDb.perBill,
                totalAmountPaisa: o.amountPaisa,
                isOpening: const Value(true),
                note: const Value('Opening Balance'),
                createdAt: now,
                updatedAt: now,
              ));
        }

        // Cash openings → dated opening in-movements.
        for (final o in input.cashOpenings) {
          if (o.amountPaisa <= 0) continue;
          final pool = await (db.select(db.cashPools)
                ..where((t) => t.name.equals(o.pool.name)))
              .getSingle();
          await db.into(db.cashMovements).insert(CashMovementsCompanion.insert(
                id: newId(),
                poolId: pool.id,
                direction: CashDirectionDb.moneyIn,
                amountPaisa: o.amountPaisa,
                date: input.date,
              ));
        }

        // Stock openings → dated party-less opening purchase bills + line items,
        // seeding qty/cost through the moving-average reset path.
        for (final o in input.stockOpenings) {
          if (o.quantityGrams <= 0) continue;
          final cat = await (db.select(db.stockCategories)
                ..where((t) => t.id.equals(o.parentCategoryId)))
              .getSingle();
          final result = costing.applyPurchase(
            cat.toStockPosition(),
            weightGrams: o.quantityGrams,
            ratePaisaPerKg: o.ratePaisaPerKg,
          );
          await (db.update(db.stockCategories)
                ..where((t) => t.id.equals(cat.id)))
              .write(StockCategoriesCompanion(
            quantityGrams: Value(result.position.quantityGrams),
            totalCostBasisPaisa: Value(result.position.totalCostBasisPaisa),
          ));

          final billId = newId();
          await db.into(db.bills).insert(BillsCompanion.insert(
                id: billId,
                type: BillTypeDb.purchase,
                date: input.date,
                rateMode: RateModeDb.perBill,
                totalAmountPaisa: result.lineTotalPaisa,
                isOpening: const Value(true),
                note: const Value('Opening Stock'),
                createdAt: now,
                updatedAt: now,
              ));
          await db.into(db.billLineItems).insert(BillLineItemsCompanion.insert(
                id: newId(),
                billId: billId,
                parentCategoryId: o.parentCategoryId,
                weightGrams: o.quantityGrams,
                ratePaisaPerKg: o.ratePaisaPerKg,
                lineTotalPaisa: result.lineTotalPaisa,
              ));
        }

        return migrationId;
      });
      return Success(migrationId);
    } on AppException {
      rethrow;
    } catch (e) {
      throw TransactionFailedException(
          'Something didn\'t save — nothing was changed, try again.', e);
    }
  }
}

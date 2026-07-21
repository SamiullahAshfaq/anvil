import 'package:drift/drift.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/ids.dart';
import '../../core/utils/rounding.dart';
import '../../data/local/database.dart';
import '../../data/local/mappers.dart';
import '../../data/local/tables.dart';
import '../../security/access_mode.dart';
import '../entities/stock_position.dart';
import '../services/stock_costing_service.dart';
import 'use_case_result.dart';

class SaleLineInput {
  final String parentCategoryId;
  final String? subCategoryLabel;
  final int weightGrams;
  final int ratePaisaPerKg;
  const SaleLineInput({
    required this.parentCategoryId,
    this.subCategoryLabel,
    required this.weightGrams,
    this.ratePaisaPerKg = 0,
  });
}

class RecordSaleInput {
  final String partyId;
  final DateTime date;
  final RateModeDb rateMode;
  final int? billLevelRatePaisaPerKg;
  final List<SaleLineInput> lines;
  final String? photoPath;
  final String? note;

  /// Optional payment received at time of sale, into [receivedPoolId].
  final int amountReceivedPaisa;
  final String? receivedPoolId;

  const RecordSaleInput({
    required this.partyId,
    required this.date,
    required this.rateMode,
    this.billLevelRatePaisaPerKg,
    required this.lines,
    this.photoPath,
    this.note,
    this.amountReceivedPaisa = 0,
    this.receivedPoolId,
  });
}

/// Records a sale as ONE atomic transaction: stock decreases at the current
/// moving-average cost (captured as COGS on each line for profit), the bill is
/// written, and any payment received posts a cash movement + allocation. A sale
/// that would take stock negative is a **soft warning**, never a hard block
/// (03_RULES.md §1.6) — surfaced via [NeedsConfirmation] before any write.
class RecordSale {
  final AppDatabase db;
  final AccessController access;
  final StockCostingService costing;

  const RecordSale({
    required this.db,
    required this.access,
    this.costing = const StockCostingService(),
  });

  int _rateFor(SaleLineInput line, RecordSaleInput input) {
    if (input.rateMode == RateModeDb.perBill) {
      final r = input.billLevelRatePaisaPerKg;
      if (r == null) {
        throw const ValidationException(
            'Per-bill rate mode requires a bill-level rate.');
      }
      return r;
    }
    return line.ratePaisaPerKg;
  }

  Future<UseCaseResult<String>> call(
    RecordSaleInput input, {
    bool confirmed = false,
  }) async {
    access.ensureCanMutate();
    if (input.lines.isEmpty) {
      throw const ValidationException('A sale needs at least one line item.');
    }
    if (input.amountReceivedPaisa > 0 && input.receivedPoolId == null) {
      throw const ValidationException('Choose a cash pool for the payment.');
    }

    // Pre-commit soft-warning scan: simulate the cumulative effect on each parent
    // category (multiple lines can hit the same category) without writing.
    if (!confirmed) {
      final sim = <String, StockPosition>{};
      final names = <String, String>{};
      final warnings = <UseCaseWarning>[];
      for (final line in input.lines) {
        final cat = await (db.select(db.stockCategories)
              ..where((t) => t.id.equals(line.parentCategoryId)))
            .getSingle();
        names[cat.id] = cat.name;
        final current = sim[cat.id] ?? cat.toStockPosition();
        final result = costing.applySale(current, weightGrams: line.weightGrams);
        sim[cat.id] = result.position;
      }
      sim.forEach((catId, pos) {
        if (pos.quantityGrams < 0) {
          warnings.add(NegativeStockWarning(
            parentCategoryId: catId,
            categoryName: names[catId] ?? '',
            resultingQuantityGrams: pos.quantityGrams,
          ));
        }
      });
      if (warnings.isNotEmpty) return NeedsConfirmation(warnings);
    }

    try {
      final billId = await db.transaction(() async {
        final billId = newId();
        var billTotal = 0;
        final lineCompanions = <BillLineItemsCompanion>[];

        // 1. Apply stock math (COGS at moving-avg) and stage line items.
        for (final line in input.lines) {
          final rate = _rateFor(line, input);
          final cat = await (db.select(db.stockCategories)
                ..where((t) => t.id.equals(line.parentCategoryId)))
              .getSingle();

          final result = costing.applySale(
            cat.toStockPosition(),
            weightGrams: line.weightGrams,
          );
          final lineTotal =
              moneyForWeight(weightGrams: line.weightGrams, ratePaisaPerKg: rate);
          billTotal += lineTotal;

          await (db.update(db.stockCategories)
                ..where((t) => t.id.equals(cat.id)))
              .write(StockCategoriesCompanion(
            quantityGrams: Value(result.position.quantityGrams),
            totalCostBasisPaisa: Value(result.position.totalCostBasisPaisa),
          ));

          lineCompanions.add(BillLineItemsCompanion.insert(
            id: newId(),
            billId: billId,
            parentCategoryId: line.parentCategoryId,
            subCategoryLabel: Value(line.subCategoryLabel),
            weightGrams: line.weightGrams,
            ratePaisaPerKg: rate,
            lineTotalPaisa: lineTotal,
            cogsPaisa: Value(result.cogsPaisa),
          ));
        }

        // 2. Insert the bill, then its line items (FK on billId).
        final now = DateTime.now();
        await db.into(db.bills).insert(BillsCompanion.insert(
              id: billId,
              type: BillTypeDb.sale,
              partyId: Value(input.partyId),
              date: input.date,
              photoPath: Value(input.photoPath),
              rateMode: input.rateMode,
              billLevelRatePaisaPerKg: Value(input.billLevelRatePaisaPerKg),
              totalAmountPaisa: billTotal,
              note: Value(input.note),
              createdAt: now,
              updatedAt: now,
            ));
        await db.batch((b) => b.insertAll(db.billLineItems, lineCompanions));

        if (input.amountReceivedPaisa > 0) {
          final paymentId = newId();
          await db.into(db.payments).insert(PaymentsCompanion.insert(
                id: paymentId,
                partyId: input.partyId,
                amountPaisa: input.amountReceivedPaisa,
                direction: PaymentDirectionDb.received,
                poolId: input.receivedPoolId!,
                date: input.date,
              ));
          await db.into(db.cashMovements).insert(CashMovementsCompanion.insert(
                id: newId(),
                poolId: input.receivedPoolId!,
                direction: CashDirectionDb.moneyIn,
                amountPaisa: input.amountReceivedPaisa,
                date: input.date,
                relatedBillId: Value(billId),
                relatedPaymentId: Value(paymentId),
              ));
          await db
              .into(db.paymentAllocations)
              .insert(PaymentAllocationsCompanion.insert(
                id: newId(),
                paymentId: paymentId,
                billId: billId,
                amountAllocatedPaisa: input.amountReceivedPaisa,
              ));
        }

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

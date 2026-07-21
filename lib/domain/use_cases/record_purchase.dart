import 'package:drift/drift.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/ids.dart';
import '../../data/local/database.dart';
import '../../data/local/mappers.dart';
import '../../data/local/tables.dart';
import '../../security/access_mode.dart';
import '../services/cash_overdraft_service.dart';
import '../services/stock_costing_service.dart';
import 'overdraft_guard.dart';
import 'use_case_result.dart';

/// One purchase line. In per-bill rate mode [ratePaisaPerKg] is ignored and the
/// bill-level rate is used instead. [subCategoryLabel] is a descriptive tag only.
class PurchaseLineInput {
  final String parentCategoryId;
  final String? subCategoryLabel;
  final int weightGrams;
  final int ratePaisaPerKg;
  const PurchaseLineInput({
    required this.parentCategoryId,
    this.subCategoryLabel,
    required this.weightGrams,
    this.ratePaisaPerKg = 0,
  });
}

class RecordPurchaseInput {
  final String partyId;
  final DateTime date;
  final RateModeDb rateMode;
  final int? billLevelRatePaisaPerKg;
  final List<PurchaseLineInput> lines;
  final String? photoPath;
  final String? note;

  /// Optional advance paid at time of bill, drawn from [advancePoolId].
  final int advancePaisa;
  final String? advancePoolId;

  const RecordPurchaseInput({
    required this.partyId,
    required this.date,
    required this.rateMode,
    this.billLevelRatePaisaPerKg,
    required this.lines,
    this.photoPath,
    this.note,
    this.advancePaisa = 0,
    this.advancePoolId,
  });
}

/// Records a purchase as ONE atomic transaction touching stock, the bill, and
/// (if an advance is paid) cash + payment — the canonical "one domain call → one
/// DB transaction" pattern (02_ARCHITECTURE.md §3). Stock math goes through
/// [StockCostingService]; party payable is derived from the bill, never stored.
class RecordPurchase {
  final AppDatabase db;
  final AccessController access;
  final StockCostingService costing;
  final CashOverdraftService overdraft;

  const RecordPurchase({
    required this.db,
    required this.access,
    this.costing = const StockCostingService(),
    this.overdraft = const CashOverdraftService(),
  });

  int _rateFor(PurchaseLineInput line, RecordPurchaseInput input) {
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

  /// Returns [Success] with the new bill id, or [NeedsConfirmation] (no writes)
  /// if paying the advance would overdraw the pool and [confirmed] is false.
  Future<UseCaseResult<String>> call(
    RecordPurchaseInput input, {
    bool confirmed = false,
  }) async {
    access.ensureCanMutate();
    if (input.lines.isEmpty) {
      throw const ValidationException('A purchase needs at least one line item.');
    }
    if (input.advancePaisa > 0 && input.advancePoolId == null) {
      throw const ValidationException('Choose a cash pool for the advance.');
    }

    // Pre-commit overdraft check (advance withdrawal), before touching anything.
    if (input.advancePaisa > 0 && !confirmed) {
      final warning = await overdraftWarningIfAny(db, overdraft,
          poolId: input.advancePoolId!, withdrawalPaisa: input.advancePaisa);
      if (warning != null) return NeedsConfirmation([warning]);
    }

    try {
      final billId = await db.transaction(() async {
        final billId = newId();
        var billTotal = 0;
        final lineCompanions = <BillLineItemsCompanion>[];

        // 1. Apply stock math and stage line items (bill must be inserted before
        //    its line items — FK on billId).
        for (final line in input.lines) {
          final rate = _rateFor(line, input);
          final cat = await (db.select(db.stockCategories)
                ..where((t) => t.id.equals(line.parentCategoryId)))
              .getSingle();

          final result = costing.applyPurchase(
            cat.toStockPosition(),
            weightGrams: line.weightGrams,
            ratePaisaPerKg: rate,
          );
          billTotal += result.lineTotalPaisa;

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
            lineTotalPaisa: result.lineTotalPaisa,
          ));
        }

        // 2. Insert the bill, then its line items.
        final now = DateTime.now();
        await db.into(db.bills).insert(BillsCompanion.insert(
              id: billId,
              type: BillTypeDb.purchase,
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

        // Advance paid: cash leaves the pool, a payment is recorded and allocated
        // to this bill (reducing derived payable).
        if (input.advancePaisa > 0) {
          final paymentId = newId();
          await db.into(db.payments).insert(PaymentsCompanion.insert(
                id: paymentId,
                partyId: input.partyId,
                amountPaisa: input.advancePaisa,
                direction: PaymentDirectionDb.paid,
                poolId: input.advancePoolId!,
                date: input.date,
                isAdvance: const Value(true),
              ));
          await db.into(db.cashMovements).insert(CashMovementsCompanion.insert(
                id: newId(),
                poolId: input.advancePoolId!,
                direction: CashDirectionDb.moneyOut,
                amountPaisa: input.advancePaisa,
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
                amountAllocatedPaisa: input.advancePaisa,
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

import '../../core/utils/rounding.dart';
import '../entities/stock_position.dart';

/// Whether a stock write-off absorbs its cost into the remaining stock (raising
/// the per-unit average) or is expensed on the P&L at the current average.
enum WriteOffMode { absorbIntoRemaining, expenseWastage }

/// Result of applying a purchase to a [StockPosition].
class PurchaseResult {
  final StockPosition position;

  /// Money value of this purchase line, Paisa (what feeds the party payable).
  final int lineTotalPaisa;

  /// True when the zero/negative-stock reset rule fired instead of the blended
  /// moving-average formula.
  final bool resetApplied;

  const PurchaseResult({
    required this.position,
    required this.lineTotalPaisa,
    required this.resetApplied,
  });
}

/// Result of applying a sale to a [StockPosition].
class SaleResult {
  final StockPosition position;

  /// Cost of goods sold for this line at the *current* moving-average cost,
  /// Paisa. This is COGS for profit; the sale rate (revenue) lives on the bill.
  final int cogsPaisa;

  /// Quantity the parent category will hold after this sale (grams). Negative
  /// means the sale oversold — surfaced by the caller as a calm soft warning,
  /// never a hard block (03_RULES.md §1.6).
  final int resultingQuantityGrams;

  bool get wouldGoNegative => resultingQuantityGrams < 0;

  const SaleResult({
    required this.position,
    required this.cogsPaisa,
    required this.resultingQuantityGrams,
  });
}

/// Result of applying a stock write-off.
class WriteOffResult {
  final StockPosition position;
  final WriteOffMode mode;

  /// For [WriteOffMode.expenseWastage]: the Paisa amount to post as a Wastage
  /// expense on the P&L. Zero for [WriteOffMode.absorbIntoRemaining] (no P&L hit).
  final int expensePaisa;

  const WriteOffResult({
    required this.position,
    required this.mode,
    required this.expensePaisa,
  });
}

/// The heart of the app's correctness. Pure functions — no DB, no UI, no
/// floating point — implementing moving-weighted-average inventory costing
/// exactly as specified in 01_PRD.md §3 and 03_RULES.md §1.4/§1.16.
///
/// Invariants proven by [StockCostingService]'s unit tests:
///  1. A **sale never changes the average cost of what remains** — cost is
///     removed strictly in proportion to weight.
///  2. A **purchase into empty-or-negative stock resets** the average to that
///     purchase's rate; the blended formula is never applied across a zero or
///     negative crossing.
///  3. All arithmetic is integer Paisa/Grams — zero drift over long sequences.
class StockCostingService {
  const StockCostingService();

  /// Applies a purchase line. Rate is Paisa per **kg** (see [moneyForWeight]).
  ///
  /// Normal case (stock in hand):
  ///   newTotalCost = oldTotalCost + lineTotal ; newQty = oldQty + weight
  ///   → the weighted average of the combined stock, exactly.
  ///
  /// Reset case (oldQty <= 0): the average is reset to this purchase's rate, so
  ///   newTotalCost = newQty × rate. Blending across the crossing is forbidden —
  ///   it produces a distorted (or, past a negative, nonsensical) basis.
  PurchaseResult applyPurchase(
    StockPosition current, {
    required int weightGrams,
    required int ratePaisaPerKg,
  }) {
    if (weightGrams <= 0) {
      throw ArgumentError('Purchase weight must be positive: $weightGrams g');
    }
    if (ratePaisaPerKg < 0) {
      throw ArgumentError('Purchase rate cannot be negative: $ratePaisaPerKg');
    }

    final lineTotal = moneyForWeight(
      weightGrams: weightGrams,
      ratePaisaPerKg: ratePaisaPerKg,
    );
    final newQty = current.quantityGrams + weightGrams;

    if (current.isEmptyOrNegative) {
      // ZERO/NEGATIVE-STOCK RESET — do NOT blend across this boundary.
      // Average of remaining is this purchase's rate; cost basis follows qty.
      final resetCost = moneyForWeight(
        weightGrams: newQty,
        ratePaisaPerKg: ratePaisaPerKg,
      );
      return PurchaseResult(
        position: StockPosition(
          quantityGrams: newQty,
          totalCostBasisPaisa: resetCost,
        ),
        lineTotalPaisa: lineTotal,
        resetApplied: true,
      );
    }

    return PurchaseResult(
      position: StockPosition(
        quantityGrams: newQty,
        totalCostBasisPaisa: current.totalCostBasisPaisa + lineTotal,
      ),
      lineTotalPaisa: lineTotal,
      resetApplied: false,
    );
  }

  /// Applies a sale line, returning COGS at the current moving-average cost.
  ///
  /// Cost is removed in proportion to weight, which leaves the average cost of
  /// the remaining stock unchanged (proven in tests). Overselling is allowed:
  /// the resulting quantity may be negative and the caller surfaces a soft
  /// warning — this is never blocked here.
  SaleResult applySale(
    StockPosition current, {
    required int weightGrams,
  }) {
    if (weightGrams <= 0) {
      throw ArgumentError('Sale weight must be positive: $weightGrams g');
    }

    final newQty = current.quantityGrams - weightGrams;

    // No positive cost basis to draw COGS from (empty/negative stock): COGS is 0
    // until a purchase re-establishes a basis (which will reset the average).
    if (current.quantityGrams <= 0) {
      return SaleResult(
        position: current.copyWith(quantityGrams: newQty),
        cogsPaisa: 0,
        resultingQuantityGrams: newQty,
      );
    }

    // Proportional cost removal keeps avg-of-remaining invariant.
    final cogs = divRound(
      weightGrams * current.totalCostBasisPaisa,
      current.quantityGrams,
    );
    return SaleResult(
      position: StockPosition(
        quantityGrams: newQty,
        totalCostBasisPaisa: current.totalCostBasisPaisa - cogs,
      ),
      cogsPaisa: cogs,
      resultingQuantityGrams: newQty,
    );
  }

  /// Applies a physical write-off (sorting loss, moisture, discarded dross).
  ///
  /// [WriteOffMode.absorbIntoRemaining]: quantity drops, **total cost basis is
  /// preserved** — so the average cost per unit of what remains rises. No P&L hit.
  ///
  /// [WriteOffMode.expenseWastage]: quantity drops and cost is removed in
  /// proportion (avg of remaining untouched, like a sale), with the removed
  /// value posted as a Wastage expense.
  WriteOffResult applyWriteOff(
    StockPosition current, {
    required int weightGrams,
    required WriteOffMode mode,
  }) {
    if (weightGrams <= 0) {
      throw ArgumentError('Write-off weight must be positive: $weightGrams g');
    }

    final newQty = current.quantityGrams - weightGrams;

    switch (mode) {
      case WriteOffMode.absorbIntoRemaining:
        // Preserve total cost across a smaller quantity → avg/unit rises.
        return WriteOffResult(
          position: current.copyWith(quantityGrams: newQty),
          mode: mode,
          expensePaisa: 0,
        );
      case WriteOffMode.expenseWastage:
        final expense = current.quantityGrams <= 0
            ? 0
            : divRound(
                weightGrams * current.totalCostBasisPaisa,
                current.quantityGrams,
              );
        return WriteOffResult(
          position: StockPosition(
            quantityGrams: newQty,
            totalCostBasisPaisa: current.totalCostBasisPaisa - expense,
          ),
          mode: mode,
          expensePaisa: expense,
        );
    }
  }
}

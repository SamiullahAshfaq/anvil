import '../../core/utils/rounding.dart';

/// Immutable cost-basis snapshot of a **parent** stock category.
///
/// This is the source of truth for stock costing. It stores two integers:
///  - [quantityGrams]      — grams currently in hand (may go negative on a
///                            soft-allowed oversell).
///  - [totalCostBasisPaisa] — total cost basis (Paisa) of the currently-held
///                            stock — i.e. Σ of what was paid for what's still
///                            unsold.
///
/// **Why store total cost, not an avg-cost-per-gram column?** A per-gram (or
/// even per-kg) average would not be integer-representable in general, and the
/// spec forbids `double` anywhere in the domain (03_RULES.md §2.14). Holding
/// `quantity` + `totalCost` as integers keeps the moving average *exact*: a sale
/// removes cost strictly in proportion to weight, so the average of what remains
/// is provably unchanged (see [StockCostingService]). The avg-cost figure the UI
/// shows is *derived* on read via [avgCostPaisaPerKg] — never persisted, exactly
/// as the "derive, don't store" invariant requires.
///
/// Sub-categories never have their own StockPosition — costing is locked at the
/// parent category (03_RULES.md §1.16).
class StockPosition {
  final int quantityGrams;
  final int totalCostBasisPaisa;

  const StockPosition({
    required this.quantityGrams,
    required this.totalCostBasisPaisa,
  });

  const StockPosition.empty()
      : quantityGrams = 0,
        totalCostBasisPaisa = 0;

  /// True when there is no positive stock to cost against — the state in which
  /// the next purchase must *reset* the average rather than blend.
  bool get isEmptyOrNegative => quantityGrams <= 0;

  /// Derived moving-average cost, Paisa per **kilogram**, rounded. Display/guidance
  /// only — never stored. Returns 0 when there is no positive stock (no defined
  /// average against zero/negative quantity).
  int get avgCostPaisaPerKg {
    if (quantityGrams <= 0) return 0;
    // totalCost is per current grams; scale to per-kg: totalCost/qty * 1000.
    return divRound(totalCostBasisPaisa * 1000, quantityGrams);
  }

  StockPosition copyWith({int? quantityGrams, int? totalCostBasisPaisa}) {
    return StockPosition(
      quantityGrams: quantityGrams ?? this.quantityGrams,
      totalCostBasisPaisa: totalCostBasisPaisa ?? this.totalCostBasisPaisa,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is StockPosition &&
      other.quantityGrams == quantityGrams &&
      other.totalCostBasisPaisa == totalCostBasisPaisa;

  @override
  int get hashCode => Object.hash(quantityGrams, totalCostBasisPaisa);

  @override
  String toString() =>
      'StockPosition(qty=${quantityGrams}g, cost=${totalCostBasisPaisa}p, '
      'avg=${avgCostPaisaPerKg}p/kg)';
}

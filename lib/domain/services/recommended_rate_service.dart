import '../../core/utils/rounding.dart';
import '../entities/stock_position.dart';

/// A recommended selling rate with the pieces needed to *explain* it. The PRD
/// calls this "the single most business-critical number in the app" and requires
/// it be tappable to show its calculation (01_PRD.md §4.3, 03_RULES.md §1.14) —
/// so this carries the inputs, not just the answer.
class RecommendedRate {
  final int avgCostPaisaPerKg;
  final int marginPct;
  final int recommendedRatePaisaPerKg;

  /// The margin amount added on top of cost, Paisa per kg (for the explanation).
  int get marginAmountPaisaPerKg => recommendedRatePaisaPerKg - avgCostPaisaPerKg;

  const RecommendedRate({
    required this.avgCostPaisaPerKg,
    required this.marginPct,
    required this.recommendedRatePaisaPerKg,
  });
}

/// Recommended selling rate = current moving-average cost + a per-category target
/// margin %. Guidance only, never enforced. Default margin is a visible, editable
/// per-category setting (03_RULES.md §5) — this service takes it explicitly rather
/// than hardcoding, so the UI stays the source of that setting.
class RecommendedRateService {
  const RecommendedRateService();

  /// [marginPct] is a whole-number percent (e.g. 5 for 5%).
  RecommendedRate forPosition(StockPosition position, {required int marginPct}) {
    return forAvgCost(position.avgCostPaisaPerKg, marginPct: marginPct);
  }

  RecommendedRate forAvgCost(int avgCostPaisaPerKg, {required int marginPct}) {
    if (marginPct < 0) {
      throw ArgumentError('Margin cannot be negative: $marginPct');
    }
    final recommended =
        avgCostPaisaPerKg + divRound(avgCostPaisaPerKg * marginPct, 100);
    return RecommendedRate(
      avgCostPaisaPerKg: avgCostPaisaPerKg,
      marginPct: marginPct,
      recommendedRatePaisaPerKg: recommended,
    );
  }
}

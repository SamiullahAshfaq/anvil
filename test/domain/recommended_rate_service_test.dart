import 'package:flutter_test/flutter_test.dart';
import 'package:anvil/domain/entities/stock_position.dart';
import 'package:anvil/domain/services/recommended_rate_service.dart';

void main() {
  const svc = RecommendedRateService();

  test('recommended rate = avg cost + target margin %, explainable', () {
    // Avg cost Rs 50/kg (5000 paisa), 5% target margin.
    final r = svc.forAvgCost(5000, marginPct: 5);
    expect(r.recommendedRatePaisaPerKg, 5250); // Rs 52.50/kg
    expect(r.marginAmountPaisaPerKg, 250, reason: 'exposes the +Rs 2.50 for the "why"');
  });

  test('derives avg cost from a stock position', () {
    final pos = const StockPosition(
        quantityGrams: 100000, totalCostBasisPaisa: 500000); // Rs 50/kg
    final r = svc.forPosition(pos, marginPct: 10);
    expect(r.avgCostPaisaPerKg, 5000);
    expect(r.recommendedRatePaisaPerKg, 5500); // Rs 55/kg
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:anvil/domain/entities/stock_position.dart';
import 'package:anvil/domain/services/stock_costing_service.dart';

/// Tests are named for the exact 01_PRD.md §3 / 04_PHASES.md Phase-1 scenarios
/// they verify. This is the "correctness is the product" surface — if these are
/// wrong, no UI polish matters (03_RULES.md §1.1).
void main() {
  const svc = StockCostingService();

  // Rates are Paisa per kg: Rs 50/kg = 5000. Weights are grams: 100 kg = 100000.

  group('moving-average purchase', () {
    test('first purchase into empty stock sets avg to that rate (reset)', () {
      // Buy 100 kg @ Rs 50/kg.
      final r = svc.applyPurchase(const StockPosition.empty(),
          weightGrams: 100000, ratePaisaPerKg: 5000);
      expect(r.resetApplied, isTrue, reason: 'empty stock → reset, not blend');
      expect(r.position.quantityGrams, 100000);
      expect(r.position.totalCostBasisPaisa, 500000); // Rs 5,000
      expect(r.position.avgCostPaisaPerKg, 5000);
      expect(r.lineTotalPaisa, 500000);
    });

    test('second purchase blends to a correct weighted average', () {
      // Hold 100 kg @ Rs 50, buy 50 kg @ Rs 60/kg.
      final start = const StockPosition(
          quantityGrams: 100000, totalCostBasisPaisa: 500000);
      final r = svc.applyPurchase(start,
          weightGrams: 50000, ratePaisaPerKg: 6000);
      expect(r.resetApplied, isFalse);
      expect(r.position.quantityGrams, 150000);
      expect(r.position.totalCostBasisPaisa, 800000); // 500000 + 300000
      // (5000*100 + 6000*50)/150 = 5333.33 → Rs 53.33/kg
      expect(r.position.avgCostPaisaPerKg, 5333);
    });
  });

  group('sale never changes the average cost of what remains', () {
    test('partial sale reduces qty and cost proportionally, avg unchanged', () {
      final start = const StockPosition(
          quantityGrams: 150000, totalCostBasisPaisa: 800000);
      final avgBefore = start.avgCostPaisaPerKg;
      final r = svc.applySale(start, weightGrams: 30000); // sell 30 kg
      expect(r.cogsPaisa, 160000); // 30000 * 800000 / 150000
      expect(r.position.quantityGrams, 120000);
      expect(r.position.totalCostBasisPaisa, 640000);
      expect(r.position.avgCostPaisaPerKg, avgBefore,
          reason: 'a sale must not move the average of remaining stock');
    });
  });

  group('zero/negative-stock reset rule (the critical formula)', () {
    test('purchase → sell-to-zero → purchase-again resets, does not blend', () {
      // Purchase 100 kg @ Rs 50.
      var pos = svc
          .applyPurchase(const StockPosition.empty(),
              weightGrams: 100000, ratePaisaPerKg: 5000)
          .position;
      // Sell all 100 kg → quantity 0, cost basis 0.
      final sale = svc.applySale(pos, weightGrams: 100000);
      expect(sale.position.quantityGrams, 0);
      expect(sale.position.totalCostBasisPaisa, 0);
      pos = sale.position;

      // Purchase again 80 kg @ Rs 70/kg — must RESET to 7000, not blend with 5000.
      final r = svc.applyPurchase(pos,
          weightGrams: 80000, ratePaisaPerKg: 7000);
      expect(r.resetApplied, isTrue);
      expect(r.position.quantityGrams, 80000);
      expect(r.position.avgCostPaisaPerKg, 7000);
    });

    test('oversell to negative, then purchase resets across the crossing', () {
      // Hold 80 kg @ Rs 70.
      var pos = const StockPosition(
          quantityGrams: 80000, totalCostBasisPaisa: 560000);
      // Oversell 100 kg → -20 kg (soft-allowed, never blocked).
      final sale = svc.applySale(pos, weightGrams: 100000);
      expect(sale.wouldGoNegative, isTrue);
      expect(sale.resultingQuantityGrams, -20000);
      pos = sale.position;

      // Buy 50 kg @ Rs 40/kg → net qty +30 kg, avg RESET to 4000 (never blended
      // across a negative — that would be mathematically nonsensical).
      final r = svc.applyPurchase(pos,
          weightGrams: 50000, ratePaisaPerKg: 4000);
      expect(r.resetApplied, isTrue);
      expect(r.position.quantityGrams, 30000);
      expect(r.position.avgCostPaisaPerKg, 4000);
    });
  });

  group('parent-level costing: sub-category tags never fragment stock', () {
    test('100 kg scrap split across tags folds into ONE parent position', () {
      // "Scrap - Pipes" 60 kg and untagged "Scrap" 40 kg, both @ Rs 50/kg,
      // apply to the SAME parent position — tags are not passed to costing.
      var pos = const StockPosition.empty();
      pos = svc
          .applyPurchase(pos, weightGrams: 60000, ratePaisaPerKg: 5000)
          .position; // tagged "Pipes"
      pos = svc
          .applyPurchase(pos, weightGrams: 40000, ratePaisaPerKg: 5000)
          .position; // untagged
      expect(pos.quantityGrams, 100000, reason: 'one parent bucket, not two');
      expect(pos.avgCostPaisaPerKg, 5000);

      // An UNTAGGED sale draws from the same parent — it must not show the parent
      // going negative while a "Pipes" silo sits full (the exact original bug).
      final sale = svc.applySale(pos, weightGrams: 70000);
      expect(sale.resultingQuantityGrams, 30000);
      expect(sale.wouldGoNegative, isFalse);
    });
  });

  group('stock write-off / wastage (both modes)', () {
    final start = const StockPosition(
        quantityGrams: 100000, totalCostBasisPaisa: 500000); // Rs 50/kg

    test('absorbIntoRemaining preserves total cost, raises avg, no P&L hit', () {
      final r = svc.applyWriteOff(start,
          weightGrams: 30000, mode: WriteOffMode.absorbIntoRemaining);
      expect(r.expensePaisa, 0);
      expect(r.position.quantityGrams, 70000);
      expect(r.position.totalCostBasisPaisa, 500000, reason: 'cost preserved');
      // 500000 / 70 kg → Rs 71.43/kg (avg rose from Rs 50).
      expect(r.position.avgCostPaisaPerKg, 7143);
    });

    test('expenseWastage drops qty, keeps avg, posts expense at avg cost', () {
      final r = svc.applyWriteOff(start,
          weightGrams: 30000, mode: WriteOffMode.expenseWastage);
      expect(r.expensePaisa, 150000); // 30 kg @ Rs 50/kg
      expect(r.position.quantityGrams, 70000);
      expect(r.position.totalCostBasisPaisa, 350000);
      expect(r.position.avgCostPaisaPerKg, 5000, reason: 'avg untouched');
    });
  });

  group('integer arithmetic has zero drift over long sequences', () {
    test('50 purchases then one full sale returns cost basis to exactly 0', () {
      var pos = const StockPosition.empty();
      for (var i = 0; i < 50; i++) {
        // Varying weights and rates, none divisible nicely.
        pos = svc
            .applyPurchase(pos,
                weightGrams: 1234 + i * 37, ratePaisaPerKg: 4999 + i * 13)
            .position;
      }
      expect(pos.quantityGrams, greaterThan(0));
      // Sell the entire quantity → COGS == total cost, remainder exactly 0.
      final sale = svc.applySale(pos, weightGrams: pos.quantityGrams);
      expect(sale.position.quantityGrams, 0);
      expect(sale.position.totalCostBasisPaisa, 0,
          reason: 'no floating-point-style drift is possible with integers');
      expect(sale.cogsPaisa, pos.totalCostBasisPaisa);
    });
  });
}

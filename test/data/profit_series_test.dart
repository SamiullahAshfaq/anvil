import 'package:flutter_test/flutter_test.dart';

import 'package:anvil/core/utils/ids.dart';
import 'package:anvil/data/local/database.dart';
import 'package:anvil/data/local/queries.dart';
import 'package:anvil/data/local/tables.dart';
import 'package:anvil/domain/entities/dashboard_summary.dart';
import 'package:anvil/domain/use_cases/compute_dashboard_summary.dart';
import 'package:anvil/domain/use_cases/record_expense.dart';
import 'package:anvil/domain/use_cases/record_sale.dart';
import 'package:anvil/domain/use_cases/run_day_zero_migration.dart';
import 'package:anvil/security/access_mode.dart';

import '../sqlite_loader.dart';

/// Phase-4 analytics: the quarterly scope and the profit bar-chart series are
/// the SAME period P&L math as the month view, just re-bucketed. Hand-trace two
/// months and confirm each bucket, the quarter total, and the drill-down ids.
void main() {
  late AppDatabase db;
  late AccessController access;

  setUpAll(overrideSqliteForTests);
  setUp(() async {
    db = AppDatabase.memory();
    access = AccessController();
    await db.customStatement('SELECT 1;');
  });
  tearDown(() async => db.close());

  Future<String> poolId(PoolNameDb n) async => (await db.poolByName(n)).id;
  Future<String> catId(String name) async =>
      (await (db.select(db.stockCategories)..where((t) => t.name.equals(name)))
              .getSingle())
          .id;
  Future<String> makeParty(String name) async {
    final id = newId();
    await db.into(db.parties).insert(PartiesCompanion.insert(
        id: id, name: name, type: PartyTypeDb.both, createdAt: DateTime.now()));
    return id;
  }

  test('quarterly scope + profit series bucket the same P&L math', () async {
    final buyer = await makeParty('Buyer');
    final scrap = await catId('Scrap');

    // Opening 200 kg Scrap @ Rs 40/kg + cash, dated 1 Jul.
    await RunDayZeroMigration(db: db, access: access).call(DayZeroInput(
      date: DateTime(2026, 7, 1),
      cashOpenings: const [CashOpening(pool: PoolNameDb.home, amountPaisa: 5000000)],
      stockOpenings: [
        StockOpening(
            parentCategoryId: scrap, quantityGrams: 200000, ratePaisaPerKg: 4000),
      ],
    ));

    // July: sell 40 kg @ Rs 60/kg → revenue 2,400, COGS 1,600 (profit 800).
    await RecordSale(db: db, access: access).call(RecordSaleInput(
      partyId: buyer,
      date: DateTime(2026, 7, 10),
      rateMode: RateModeDb.perBill,
      billLevelRatePaisaPerKg: 6000,
      lines: [SaleLineInput(parentCategoryId: scrap, weightGrams: 40000)],
    ));

    // August: sell 30 kg @ Rs 50/kg → revenue 1,500, COGS 1,200; +Rs 200 expense.
    await RecordSale(db: db, access: access).call(RecordSaleInput(
      partyId: buyer,
      date: DateTime(2026, 8, 12),
      rateMode: RateModeDb.perBill,
      billLevelRatePaisaPerKg: 5000,
      lines: [SaleLineInput(parentCategoryId: scrap, weightGrams: 30000)],
    ));
    final salaries = (await db.expenseCategoryByName('Salaries'))!.id;
    await RecordExpense(db: db, access: access).call(
      RecordExpenseInput(
        date: DateTime(2026, 8, 20),
        amountPaisa: 20000, // Rs 200
        poolId: await poolId(PoolNameDb.home),
        expenseCategoryId: salaries,
      ),
      confirmed: true,
    );

    final uc = ComputeDashboardSummary(db);

    // --- Quarterly scope: Q3 (Jul–Sep) sums both months ---
    final q3 = await uc.call(year: 2026, month: 8, scope: PeriodScope.quarter);
    expect(q3.scope, PeriodScope.quarter);
    expect(q3.periodStart, DateTime(2026, 7));
    expect(q3.periodEnd, DateTime(2026, 10));
    expect(q3.periodRevenuePaisa, 390000); // 2,400 + 1,500
    expect(q3.periodCogsPaisa, 280000); // 1,600 + 1,200
    expect(q3.periodExpensePaisa, 20000); // Rs 200
    expect(q3.periodProfitPaisa, 90000); // Rs 900

    // Drill-down ids are populated for the takeaways.
    expect(q3.biggestExpenseBillId, isNotNull);
    expect(q3.largestReceivablePartyId, isNotNull);
    expect(q3.largestReceivablePartyName, 'Buyer');

    // --- Profit series (monthly, anchored 15 Sep) → Jul, Aug, Sep oldest-first ---
    final series =
        await uc.profitSeries(count: 3, anchor: DateTime(2026, 9, 15));
    expect(series.map((p) => p.label).toList(), ['Jul', 'Aug', 'Sep']);
    expect(series[0].profitPaisa, 80000); // July: 800
    expect(series[1].profitPaisa, 10000); // Aug: 300 − 200 = 100
    expect(series[2].profitPaisa, 0); // Sep: no activity

    // --- Profit series (quarterly, anchored 15 Sep) → one Q3 bar of Rs 900 ---
    final qSeries = await uc.profitSeries(
        scope: PeriodScope.quarter, count: 1, anchor: DateTime(2026, 9, 15));
    expect(qSeries.single.label, 'Q3');
    expect(qSeries.single.profitPaisa, 90000);
  });
}

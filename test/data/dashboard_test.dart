import 'package:flutter_test/flutter_test.dart';

import 'package:anvil/core/utils/ids.dart';
import 'package:anvil/data/local/database.dart';
import 'package:anvil/data/local/queries.dart';
import 'package:anvil/data/local/tables.dart';
import 'package:anvil/domain/use_cases/compute_dashboard_summary.dart';
import 'package:anvil/domain/use_cases/record_expense.dart';
import 'package:anvil/domain/use_cases/record_sale.dart';
import 'package:anvil/domain/use_cases/run_day_zero_migration.dart';
import 'package:anvil/domain/use_cases/use_case_result.dart';
import 'package:anvil/security/access_mode.dart';

import '../sqlite_loader.dart';

/// Phase-4 style validation: hand-trace a real opening position + a month of
/// business through the ledger and confirm the Dashboard's numbers match — the
/// actual bar (04_PHASES.md), not "tests pass".
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

  test('day-0 migration seeds standing balances, then dashboard tracks a month',
      () async {
    final partyA = await makeParty('A (owes us)');
    final partyB = await makeParty('B (we owe)');
    final scrap = await catId('Scrap');

    // --- Day-0: opening position of an already-running business ---
    final mig = await RunDayZeroMigration(db: db, access: access).call(DayZeroInput(
      date: DateTime(2026, 7, 1),
      partyOpenings: [
        PartyOpening(
            partyId: partyA,
            direction: OpeningDirection.theyOweUs,
            amountPaisa: 500000), // Rs 5,000 receivable
        PartyOpening(
            partyId: partyB,
            direction: OpeningDirection.weOweThem,
            amountPaisa: 300000), // Rs 3,000 payable
      ],
      cashOpenings: const [
        CashOpening(pool: PoolNameDb.home, amountPaisa: 5000000), // Rs 50,000
        CashOpening(pool: PoolNameDb.bank, amountPaisa: 2000000), // Rs 20,000
      ],
      stockOpenings: [
        StockOpening(
            parentCategoryId: scrap,
            quantityGrams: 100000, // 100 kg
            ratePaisaPerKg: 4000), // Rs 40/kg → Rs 4,000
      ],
    ));
    expect(mig, isA<Success<String>>());

    // Second run is refused.
    expect(
      () => RunDayZeroMigration(db: db, access: access)
          .call(DayZeroInput(date: DateTime(2026, 7, 1))),
      throwsA(isA<Object>()),
    );

    // Opening position: net worth = 70,000 cash + 5,000 recv − 3,000 pay
    //                             + 4,000 stock = Rs 76,000.
    final opening = await ComputeDashboardSummary(db).call(year: 2026, month: 6);
    expect(opening.cashOnHandPaisa, 7000000);
    expect(opening.receivablePaisa, 500000);
    expect(opening.payablePaisa, 300000);
    expect(opening.stockValueAtCostPaisa, 400000);
    expect(opening.netWorthPaisa, 7600000);
    expect(opening.periodProfitPaisa, 0, reason: 'June had no activity');

    // --- A month of business (July) ---
    // Sell 40 kg Scrap @ Rs 60/kg to A, receive Rs 1,000 into Bank.
    await RecordSale(db: db, access: access).call(RecordSaleInput(
      partyId: partyA,
      date: DateTime(2026, 7, 10),
      rateMode: RateModeDb.perBill,
      billLevelRatePaisaPerKg: 6000,
      lines: [SaleLineInput(parentCategoryId: scrap, weightGrams: 40000)],
      amountReceivedPaisa: 100000,
      receivedPoolId: await poolId(PoolNameDb.bank),
    ));
    // Pay Rs 500 salaries from Bank.
    final salaries = (await db.expenseCategoryByName('Salaries'))!.id;
    await RecordExpense(db: db, access: access).call(
      RecordExpenseInput(
        date: DateTime(2026, 7, 15),
        amountPaisa: 50000,
        poolId: await poolId(PoolNameDb.bank),
        expenseCategoryId: salaries,
      ),
      confirmed: true,
    );

    // --- July dashboard ---
    final july = await ComputeDashboardSummary(db).call(year: 2026, month: 7);

    // Period P&L: revenue 2,400 − COGS 1,600 − expense 500 = Rs 300 profit.
    expect(july.periodRevenuePaisa, 240000);
    expect(july.periodCogsPaisa, 160000);
    expect(july.periodExpensePaisa, 50000);
    expect(july.periodProfitPaisa, 30000);

    // Position now: cash 70,500 · recv 6,400 · pay 3,000 · stock 2,400.
    expect(july.cashOnHandPaisa, 7050000);
    expect(july.receivablePaisa, 640000);
    expect(july.payablePaisa, 300000);
    expect(july.stockValueAtCostPaisa, 240000);

    // THE cross-check: net worth grew by exactly the period profit (Rs 300).
    expect(july.netWorthPaisa, 7630000);
    expect(july.netWorthPaisa - opening.netWorthPaisa, july.periodProfitPaisa);

    // Plain-language takeaway.
    expect(july.biggestExpenseLabel, 'Salaries');
    expect(july.biggestExpensePaisa, 50000);
    expect(july.bestMarginCategory?.name, 'Scrap');
    expect(july.bestMarginCategory?.profitPaisa, 80000); // 2,400 − 1,600
    expect(july.largestReceivablePartyName, 'A (owes us)');
    expect(july.largestReceivablePaisa, 640000);
  });
}

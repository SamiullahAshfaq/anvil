import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anvil/app/providers.dart';
import 'package:anvil/core/theme/app_theme.dart';
import 'package:anvil/core/utils/ids.dart';
import 'package:anvil/data/local/database.dart';
import 'package:anvil/data/local/queries.dart';
import 'package:anvil/data/local/tables.dart';
import 'package:anvil/domain/use_cases/record_sale.dart';
import 'package:anvil/domain/use_cases/run_day_zero_migration.dart';
import 'package:anvil/presentation/home_dashboard/dashboard_screen.dart';
import 'package:anvil/security/access_mode.dart';

import '../sqlite_loader.dart';

/// A critical-flow widget smoke test (04_PHASES.md §1.15): the Dashboard renders
/// real derived figures from an in-memory ledger.
void main() {
  setUpAll(overrideSqliteForTests);

  testWidgets('dashboard shows net worth and month profit from the ledger',
      (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await db.customStatement('SELECT 1;');
    final access = AccessController();

    // Seed an opening position + a sale so the screen has real numbers.
    final scrap =
        (await (db.select(db.stockCategories)..where((t) => t.name.equals('Scrap')))
                .getSingle())
            .id;
    final buyer = newId();
    await db.into(db.parties).insert(PartiesCompanion.insert(
        id: buyer, name: 'Buyer', type: PartyTypeDb.both, createdAt: DateTime.now()));

    await RunDayZeroMigration(db: db, access: access).call(DayZeroInput(
      date: DateTime(DateTime.now().year, DateTime.now().month, 1),
      cashOpenings: const [CashOpening(pool: PoolNameDb.home, amountPaisa: 5000000)],
      stockOpenings: [
        StockOpening(
            parentCategoryId: scrap, quantityGrams: 100000, ratePaisaPerKg: 4000),
      ],
    ));
    await RecordSale(db: db, access: access).call(RecordSaleInput(
      partyId: buyer,
      date: DateTime.now(),
      rateMode: RateModeDb.perBill,
      billLevelRatePaisaPerKg: 6000,
      lines: [SaleLineInput(parentCategoryId: scrap, weightGrams: 40000)],
    ));

    await tester.pumpWidget(ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(theme: AppTheme.light(), home: const DashboardScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Net worth'), findsOneWidget);
    // Cash Rs 50,000 + receivable Rs 2,400 + stock-at-cost Rs 2,400 (100 kg − 40 kg
    // sold at Rs 40/kg avg) = Rs 54,800 net worth.
    expect(find.text('Rs 54,800.00'), findsOneWidget);
    // Profit Rs 800 (revenue 2,400 − COGS 1,600) shown this month.
    expect(find.text('Rs 800.00'), findsWidgets);

    // Scroll down to confirm receivable/payable render as two separate figures.
    await tester.scrollUntilVisible(find.text('They owe us'), 200);
    expect(find.text('They owe us'), findsOneWidget);
    expect(find.text('We owe'), findsOneWidget);
    // Home pool chip reflects the Rs 50,000 opening cash.
    expect(await db.poolBalancePaisa((await db.poolByName(PoolNameDb.home)).id),
        5000000);
  });

  testWidgets('profit chart + month/quarter scope toggle render and switch',
      (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await db.customStatement('SELECT 1;');
    final access = AccessController();

    final scrap =
        (await (db.select(db.stockCategories)..where((t) => t.name.equals('Scrap')))
                .getSingle())
            .id;
    final buyer = newId();
    await db.into(db.parties).insert(PartiesCompanion.insert(
        id: buyer, name: 'Buyer', type: PartyTypeDb.both, createdAt: DateTime.now()));

    final now = DateTime.now();
    await RunDayZeroMigration(db: db, access: access).call(DayZeroInput(
      date: DateTime(now.year, now.month, 1),
      stockOpenings: [
        StockOpening(
            parentCategoryId: scrap, quantityGrams: 100000, ratePaisaPerKg: 4000),
      ],
    ));
    await RecordSale(db: db, access: access).call(RecordSaleInput(
      partyId: buyer,
      date: now,
      rateMode: RateModeDb.perBill,
      billLevelRatePaisaPerKg: 6000,
      lines: [SaleLineInput(parentCategoryId: scrap, weightGrams: 40000)],
    ));

    await tester.pumpWidget(ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(theme: AppTheme.light(), home: const DashboardScreen()),
    ));
    await tester.pumpAndSettle();

    // The trend chart card and the scope toggle are present, scoped to month.
    await tester.scrollUntilVisible(find.text('Profit trend'), 200);
    expect(find.text('Profit trend'), findsOneWidget);
    expect(find.text('THIS MONTH'), findsOneWidget);

    // Switching to Quarter re-labels the period section (same position figures).
    await tester.tap(find.text('Quarter'));
    await tester.pumpAndSettle();
    expect(find.text('THIS QUARTER'), findsOneWidget);
  });
}

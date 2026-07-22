import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anvil/core/errors/app_exception.dart';
import 'package:anvil/core/utils/ids.dart';
import 'package:anvil/data/local/database.dart';
import 'package:anvil/data/local/queries.dart';
import 'package:anvil/data/local/read_queries.dart';
import 'package:anvil/data/local/tables.dart';
import 'package:anvil/domain/use_cases/manage_trash.dart';
import 'package:anvil/domain/use_cases/record_purchase.dart';
import 'package:anvil/domain/use_cases/record_sale.dart';
import 'package:anvil/domain/use_cases/use_case_result.dart';
import 'package:anvil/security/access_mode.dart';

import '../sqlite_loader.dart';

/// Deleting/restoring a stock-affecting bill must keep the moving-average totals
/// exact by replaying the surviving ledger (03_RULES.md §1.4). These tests trace
/// the numbers by hand.
void main() {
  late AppDatabase db;
  late AccessController access;
  late TrashService trash;

  setUpAll(overrideSqliteForTests);

  setUp(() async {
    db = AppDatabase.memory();
    access = AccessController();
    trash = TrashService(db: db, access: access);
    await db.customStatement('SELECT 1;');
  });
  tearDown(() async => db.close());

  Future<String> scrapId() async =>
      (await (db.select(db.stockCategories)..where((t) => t.name.equals('Scrap')))
              .getSingle())
          .id;

  Future<StockCategory> scrap() async {
    final id = await scrapId();
    return (db.select(db.stockCategories)..where((t) => t.id.equals(id)))
        .getSingle();
  }

  Future<String> makeParty() async {
    final id = newId();
    await db.into(db.parties).insert(PartiesCompanion.insert(
        id: id, name: 'Supplier', type: PartyTypeDb.both, createdAt: DateTime.now()));
    return id;
  }

  test('deleting a mid-history purchase replays stock to the exact remainder',
      () async {
    final cat = await scrapId();
    final party = await makeParty();
    final purchase = RecordPurchase(db: db, access: access);

    // P1: 100 kg @ Rs 40/kg.
    await purchase.call(RecordPurchaseInput(
      partyId: party,
      date: DateTime(2026, 1, 1),
      rateMode: RateModeDb.perBill,
      billLevelRatePaisaPerKg: 4000,
      lines: [PurchaseLineInput(parentCategoryId: cat, weightGrams: 100000)],
    ));
    // P2: 100 kg @ Rs 60/kg → blended avg Rs 50/kg over 200 kg.
    final p2 = await purchase.call(RecordPurchaseInput(
      partyId: party,
      date: DateTime(2026, 1, 2),
      rateMode: RateModeDb.perBill,
      billLevelRatePaisaPerKg: 6000,
      lines: [PurchaseLineInput(parentCategoryId: cat, weightGrams: 100000)],
    ));
    // S1: sell 50 kg at avg Rs 50 → COGS 2,50,000; leaves 150 kg @ 7,50,000.
    await RecordSale(db: db, access: access).call(RecordSaleInput(
      partyId: party,
      date: DateTime(2026, 1, 3),
      rateMode: RateModeDb.perBill,
      billLevelRatePaisaPerKg: 8000,
      lines: [SaleLineInput(parentCategoryId: cat, weightGrams: 50000)],
    ));

    var s = await scrap();
    expect(s.quantityGrams, 150000);
    expect(s.totalCostBasisPaisa, 750000);

    // Delete P2 and replay: only P1 (100 kg @ 40) then S1 (50 kg) survive →
    // 50 kg remaining at Rs 40/kg = 2,00,000.
    final p2Id = (p2 as Success<String>).value;
    await trash.softDeleteBill(p2Id);
    s = await scrap();
    expect(s.quantityGrams, 50000);
    expect(s.totalCostBasisPaisa, 200000);

    // Payable dropped by P2's Rs 6,00,000 (derived, no P2 row now).
    final bal = await db.partyBalance(party);
    expect(bal.payablePaisa, 400000); // P1 600 - ... P1 total 4,00,000 unpaid

    // Restore P2 → back to the exact original remainder.
    await trash.restoreBill(p2Id);
    s = await scrap();
    expect(s.quantityGrams, 150000);
    expect(s.totalCostBasisPaisa, 750000);
  });

  test('deleting an expense bill unwinds its cash movement, restorable',
      () async {
    final home =
        (await (db.select(db.cashPools)..where((t) => t.name.equals('home')))
                .getSingle())
            .id;
    // Seed opening cash so the pool has a balance.
    await db.into(db.cashMovements).insert(CashMovementsCompanion.insert(
        id: newId(),
        poolId: home,
        direction: CashDirectionDb.moneyIn,
        amountPaisa: 1000000,
        date: DateTime(2026, 1, 1)));

    final billId = newId();
    await db.into(db.bills).insert(BillsCompanion.insert(
          id: billId,
          type: BillTypeDb.expense,
          date: DateTime(2026, 1, 2),
          rateMode: RateModeDb.perBill,
          totalAmountPaisa: 150000,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
    await db.into(db.cashMovements).insert(CashMovementsCompanion.insert(
        id: newId(),
        poolId: home,
        direction: CashDirectionDb.moneyOut,
        amountPaisa: 150000,
        date: DateTime(2026, 1, 2),
        relatedBillId: Value(billId)));

    expect(await db.poolBalancePaisa(home), 850000);
    await trash.softDeleteBill(billId);
    expect(await db.poolBalancePaisa(home), 1000000); // cash-out reversed
    await trash.restoreBill(billId);
    expect(await db.poolBalancePaisa(home), 850000);
  });

  test('a party with open bills cannot be deleted (calm guard)', () async {
    final cat = await scrapId();
    final party = await makeParty();
    await RecordPurchase(db: db, access: access).call(RecordPurchaseInput(
      partyId: party,
      date: DateTime(2026, 1, 1),
      rateMode: RateModeDb.perBill,
      billLevelRatePaisaPerKg: 4000,
      lines: [PurchaseLineInput(parentCategoryId: cat, weightGrams: 10000)],
    ));
    expect(() => trash.softDeleteParty(party),
        throwsA(isA<ValidationException>()));
  });

  test('View-only mode blocks a soft delete at the use-case layer', () async {
    final billId = newId();
    await db.into(db.bills).insert(BillsCompanion.insert(
          id: billId,
          type: BillTypeDb.expense,
          date: DateTime(2026, 1, 2),
          rateMode: RateModeDb.perBill,
          totalAmountPaisa: 1000,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
    final viewTrash = TrashService(
        db: db, access: AccessController(AccessMode.view));
    expect(() => viewTrash.softDeleteBill(billId),
        throwsA(isA<UnauthorizedException>()));
  });
}

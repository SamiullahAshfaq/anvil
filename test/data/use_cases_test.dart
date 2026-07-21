import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anvil/core/errors/app_exception.dart';
import 'package:anvil/core/utils/ids.dart';
import 'package:anvil/data/local/database.dart';
import 'package:anvil/data/local/tables.dart';
import 'package:anvil/domain/entities/party_ledger.dart';
import 'package:anvil/domain/services/ledger_service.dart';
import 'package:anvil/domain/use_cases/record_purchase.dart';
import 'package:anvil/domain/use_cases/record_sale.dart';
import 'package:anvil/domain/use_cases/use_case_result.dart';
import 'package:anvil/security/access_mode.dart';

import '../sqlite_loader.dart';

/// Integration tests against an in-memory Drift DB. They verify the whole
/// "one use-case → one transaction touching N tables" pattern end to end
/// (04_PHASES.md §1–2 critical flows), not just the isolated math.
void main() {
  late AppDatabase db;
  late AccessController access;

  setUpAll(overrideSqliteForTests);

  setUp(() async {
    db = AppDatabase.memory();
    access = AccessController();
    await db.customStatement('SELECT 1;'); // triggers onCreate + seeding
  });

  tearDown(() async => db.close());

  Future<String> catId(String name) async =>
      (await (db.select(db.stockCategories)..where((t) => t.name.equals(name)))
              .getSingle())
          .id;

  Future<String> poolId(PoolNameDb name) async =>
      (await (db.select(db.cashPools)..where((t) => t.name.equals(name.name)))
              .getSingle())
          .id;

  Future<StockCategory> cat(String id) =>
      (db.select(db.stockCategories)..where((t) => t.id.equals(id))).getSingle();

  Future<String> makeParty(String name) async {
    final id = newId();
    await db.into(db.parties).insert(PartiesCompanion.insert(
        id: id, name: name, type: PartyTypeDb.both, createdAt: DateTime.now()));
    return id;
  }

  Future<int> poolBalance(PoolNameDb name) async {
    final id = await poolId(name);
    final rows =
        await (db.select(db.cashMovements)..where((t) => t.poolId.equals(id)))
            .get();
    return rows.fold<int>(
        0,
        (s, m) => s +
            (m.direction == CashDirectionDb.moneyIn
                ? m.amountPaisa
                : -m.amountPaisa));
  }

  RecordPurchaseInput purchase(String party, String category, int grams,
          {required int ratePaisaPerKg,
          int advance = 0,
          String? advancePool}) =>
      RecordPurchaseInput(
        partyId: party,
        date: DateTime(2026, 7, 21),
        rateMode: RateModeDb.perBill,
        billLevelRatePaisaPerKg: ratePaisaPerKg,
        lines: [PurchaseLineInput(parentCategoryId: category, weightGrams: grams)],
        advancePaisa: advance,
        advancePoolId: advancePool,
      );

  test('seeding creates 3 pools, 3 stock categories, 6 expense categories',
      () async {
    expect((await db.select(db.cashPools).get()).length, 3);
    expect((await db.select(db.stockCategories).get()).length, 3);
    expect((await db.select(db.expenseCategories).get()).length, 6);
  });

  test('purchase updates stock + writes bill atomically; payable is derived',
      () async {
    final party = await makeParty('Ali Scrap');
    final scrap = await catId('Scrap');

    final res = await RecordPurchase(db: db, access: access)
        .call(purchase(party, scrap, 100000, ratePaisaPerKg: 5000));
    expect(res, isA<Success<String>>());

    final c = await cat(scrap);
    expect(c.quantityGrams, 100000);
    expect(c.totalCostBasisPaisa, 500000); // Rs 5,000

    final balance = await derivePartyBalance(db, party);
    expect(balance.payablePaisa, 500000, reason: 'derived from the bill');
    expect(balance.receivablePaisa, 0);
  });

  test('advance paid on a purchase moves cash and reduces derived payable',
      () async {
    final party = await makeParty('Ali Scrap');
    final scrap = await catId('Scrap');

    // Home starts empty, so paying an advance overdraws it — confirmed through
    // (the overdraft is a soft warning, surfaced then allowed, never blocked).
    await RecordPurchase(db: db, access: access).call(
        purchase(party, scrap, 100000,
            ratePaisaPerKg: 5000,
            advance: 200000, // Rs 2,000 advance
            advancePool: await poolId(PoolNameDb.home)),
        confirmed: true);

    expect(await poolBalance(PoolNameDb.home), -200000,
        reason: 'cash left Home (overdraft is visible, not blocked here)');
    final balance = await derivePartyBalance(db, party);
    expect(balance.payablePaisa, 300000, reason: 'Rs 5,000 − Rs 2,000 advance');
    // Exactly one cash movement — no double-count.
    expect((await db.select(db.cashMovements).get()).length, 1);
  });

  test('sale draws stock at moving-avg COGS and records revenue + payment',
      () async {
    final party = await makeParty('Bilal Traders');
    final scrap = await catId('Scrap');

    // Seed 100 kg @ Rs 50/kg.
    await RecordPurchase(db: db, access: access)
        .call(purchase(party, scrap, 100000, ratePaisaPerKg: 5000));

    // Sell 40 kg @ Rs 60/kg, receive Rs 1,000 into Bank.
    final res = await RecordSale(db: db, access: access).call(RecordSaleInput(
      partyId: party,
      date: DateTime(2026, 7, 22),
      rateMode: RateModeDb.perBill,
      billLevelRatePaisaPerKg: 6000,
      lines: [SaleLineInput(parentCategoryId: scrap, weightGrams: 40000)],
      amountReceivedPaisa: 100000,
      receivedPoolId: await poolId(PoolNameDb.bank),
    ));
    expect(res, isA<Success<String>>());
    final saleBillId = (res as Success<String>).value;

    final c = await cat(scrap);
    expect(c.quantityGrams, 60000, reason: '100 kg − 40 kg');
    expect(c.totalCostBasisPaisa, 300000, reason: 'COGS Rs 2,000 removed');

    final line = await (db.select(db.billLineItems)
          ..where((t) => t.billId.equals(saleBillId)))
        .getSingle();
    expect(line.lineTotalPaisa, 240000, reason: 'Rs 2,400 revenue (40 kg @ Rs 60)');
    expect(line.cogsPaisa, 200000, reason: 'COGS 40 kg @ Rs 50/kg avg = Rs 2,000');

    expect(await poolBalance(PoolNameDb.bank), 100000);

    final balance = await derivePartyBalance(db, party);
    expect(balance.receivablePaisa, 140000, reason: 'Rs 2,400 − Rs 1,000 received');
  });

  test('overselling returns NeedsConfirmation and writes nothing; confirm proceeds',
      () async {
    final party = await makeParty('Empty Co');
    final scrap = await catId('Scrap');

    final input = RecordSaleInput(
      partyId: party,
      date: DateTime(2026, 7, 22),
      rateMode: RateModeDb.perBill,
      billLevelRatePaisaPerKg: 6000,
      lines: [SaleLineInput(parentCategoryId: scrap, weightGrams: 12000)],
    );

    final res = await RecordSale(db: db, access: access).call(input);
    expect(res, isA<NeedsConfirmation<String>>());
    final w = (res as NeedsConfirmation<String>).warnings.single;
    expect(w, isA<NegativeStockWarning>());
    expect((w as NegativeStockWarning).resultingQuantityGrams, -12000);
    expect(await db.select(db.bills).get(), isEmpty, reason: 'no writes');
    expect((await cat(scrap)).quantityGrams, 0);

    // Confirm → proceeds, stock goes negative (never hard-blocked).
    final res2 = await RecordSale(db: db, access: access).call(input, confirmed: true);
    expect(res2, isA<Success<String>>());
    expect((await cat(scrap)).quantityGrams, -12000);
  });

  test('View-only mode blocks a mutating use-case at the domain layer', () async {
    final party = await makeParty('Read Only');
    final scrap = await catId('Scrap');
    access.mode = AccessMode.view;

    expect(
      () => RecordPurchase(db: db, access: access)
          .call(purchase(party, scrap, 100000, ratePaisaPerKg: 5000)),
      throwsA(isA<UnauthorizedException>()),
    );
    expect(await db.select(db.bills).get(), isEmpty);
  });
}

/// Rebuilds a party's balance from persisted rows via [LedgerService] — mirrors
/// what a PartyRepository will do, exercised here end to end.
Future<PartyBalance> derivePartyBalance(AppDatabase db, String partyId) async {
  final billRows = await (db.select(db.bills)
        ..where((t) => t.partyId.equals(partyId) & t.deletedAt.isNull()))
      .get();
  final bills = [
    for (final b in billRows)
      if (b.type == BillTypeDb.purchase)
        PartyBill(id: b.id, kind: PartyBillKind.purchase, totalPaisa: b.totalAmountPaisa)
      else if (b.type == BillTypeDb.sale)
        PartyBill(id: b.id, kind: PartyBillKind.sale, totalPaisa: b.totalAmountPaisa),
  ];

  final payRows = await (db.select(db.payments)
        ..where((t) => t.partyId.equals(partyId) & t.deletedAt.isNull()))
      .get();
  final payments = <PartyPayment>[];
  for (final p in payRows) {
    final allocs = await (db.select(db.paymentAllocations)
          ..where((t) => t.paymentId.equals(p.id)))
        .get();
    payments.add(PartyPayment(
      id: p.id,
      direction: p.direction == PaymentDirectionDb.received
          ? PaymentDirection.received
          : PaymentDirection.paid,
      amountPaisa: p.amountPaisa,
      reversed: p.reversed,
      allocations: [
        for (final a in allocs)
          PaymentAllocationView(billId: a.billId, amountPaisa: a.amountAllocatedPaisa)
      ],
    ));
  }
  return const LedgerService().deriveBalance(bills: bills, payments: payments);
}

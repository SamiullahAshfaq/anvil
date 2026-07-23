import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anvil/app/cash_read_providers.dart';
import 'package:anvil/app/providers.dart';
import 'package:anvil/core/utils/ids.dart';
import 'package:anvil/core/utils/rounding.dart';
import 'package:anvil/data/local/database.dart';
import 'package:anvil/data/local/queries.dart';
import 'package:anvil/data/local/tables.dart';
import 'package:anvil/domain/use_cases/record_purchase.dart';
import 'package:anvil/domain/use_cases/record_sale.dart';
import 'package:anvil/domain/use_cases/reverse_payment.dart';
import 'package:anvil/domain/use_cases/transfer_to_godam.dart';
import 'package:anvil/domain/use_cases/use_case_result.dart';
import 'package:anvil/security/access_mode.dart';

import '../sqlite_loader.dart';

/// Phase-3 read-layer tests: the Cash & Godam / Payments screens are UI over the
/// existing use-cases, so the correctness that matters here is that the read
/// models resolve movements, the Godam FIFO trace, open bills, and a bounced
/// payment exactly (04_PHASES.md Phase-3 exit criteria).
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

  ProviderContainer container() {
    final c = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)]);
    addTearDown(c.dispose);
    return c;
  }

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

  test('Godam FIFO trace resolves a spend to its two funding transfers',
      () async {
    final godam = await poolId(PoolNameDb.godam);
    final transfer = TransferToGodam(db: db, access: access);
    // Two fundings into Godam: Rs 1,000 (Home) then Rs 500 (Bank).
    // Home/Bank start empty, so these transfers overdraw and need confirming.
    await transfer.call(
        from: PoolNameDb.home,
        amountPaisa: 100000,
        date: DateTime(2026, 7, 1),
        confirmed: true);
    await transfer.call(
        from: PoolNameDb.bank,
        amountPaisa: 50000,
        date: DateTime(2026, 7, 2),
        confirmed: true);

    // A purchase paying Rs 1,200 out of Godam — spans both funding lots.
    final supplier = await makeParty('Zubair');
    final scrap = await catId('Scrap');
    final res = await RecordPurchase(db: db, access: access).call(
      RecordPurchaseInput(
        partyId: supplier,
        date: DateTime(2026, 7, 3),
        rateMode: RateModeDb.perLine,
        lines: [
          PurchaseLineInput(
              parentCategoryId: scrap,
              weightGrams: 100000,
              ratePaisaPerKg: 80000),
        ],
        advancePaisa: 120000,
        advancePoolId: godam,
      ),
    );
    expect(res, isA<Success<String>>());

    final view = await container().read(godamLedgerProvider.future);
    expect(view.balancePaisa, 30000); // 150,000 in − 120,000 out
    expect(view.fundings.length, 2);
    expect(view.spends.length, 1);

    final spend = view.spends.single;
    expect(spend.entry.kind, CashEntryKind.purchaseAdvance);
    expect(spend.entry.billId, isNotNull); // drill-down to the bill
    expect(spend.trace.sources.length, 2); // funded by BOTH transfers
    expect(spend.trace.sources[0].amountConsumedPaisa, 100000); // Home lot first
    expect(spend.trace.sources[1].amountConsumedPaisa, 20000); // then Bank lot
    expect(spend.trace.unfundedPaisa, 0);

    // Home is the oldest lot, so the first source names the Home transfer.
    final homeFunding =
        view.fundings.firstWhere((f) => f.subtitle == 'From Home');
    expect(spend.trace.sources.first.transferMovementId, homeFunding.movement.id);

    // Reconciliation: Home 1000−0=..., all pools sum to total cash on hand.
    final recon = await container().read(reconciliationProvider.future);
    final total = recon.pools.fold<int>(0, (s, p) => s + p.balancePaisa);
    expect(recon.totalCashPaisa, total);
    final homeBal =
        recon.pools.firstWhere((p) => p.name == PoolNameDb.home).balancePaisa;
    expect(homeBal, -100000); // only the outbound transfer touched Home
  });

  test('bounced payment: reversing a sale receipt reopens the bill in the read model',
      () async {
    final buyer = await makeParty('Imran');
    final scrap = await catId('Scrap');
    final home = await poolId(PoolNameDb.home);

    // Seed stock so the sale needs no negative-stock confirmation.
    await RecordPurchase(db: db, access: access).call(RecordPurchaseInput(
      partyId: await makeParty('SupplierCo'),
      date: DateTime(2026, 7, 1),
      rateMode: RateModeDb.perLine,
      lines: [
        PurchaseLineInput(
            parentCategoryId: scrap, weightGrams: 200000, ratePaisaPerKg: 60000),
      ],
    ));

    // Sale of Rs 10,000, fully received into Home (allocated to the bill).
    final saleTotal = moneyForWeight(weightGrams: 100000, ratePaisaPerKg: 100000);
    final saleRes = await RecordSale(db: db, access: access).call(RecordSaleInput(
      partyId: buyer,
      date: DateTime(2026, 7, 5),
      rateMode: RateModeDb.perLine,
      lines: [
        SaleLineInput(
            parentCategoryId: scrap, weightGrams: 100000, ratePaisaPerKg: 100000),
      ],
      amountReceivedPaisa: saleTotal,
      receivedPoolId: home,
    ));
    expect(saleRes, isA<Success<String>>());

    // Fully settled: no open bills for the buyer.
    final openBefore =
        await container().read(openBillsForPartyProvider(buyer).future);
    expect(openBefore, isEmpty);

    // The receipt shows up as money-in on the Roznamcha.
    final ledger = await container().read(cashLedgerProvider.future);
    expect(
        ledger.any((e) => e.kind == CashEntryKind.saleReceipt && e.isIn), isTrue);

    // The cheque bounces — reverse the payment.
    final payment = (await (db.select(db.payments)
              ..where((t) => t.partyId.equals(buyer)))
            .get())
        .single;
    final revRes = await ReversePayment(db: db, access: access)
        .call(paymentId: payment.id, reason: 'Cheque bounced');
    expect(revRes, isA<Success<void>>());

    // The bill has reopened with its full amount outstanding.
    final openAfter =
        await container().read(openBillsForPartyProvider(buyer).future);
    expect(openAfter.length, 1);
    expect(openAfter.single.outstandingPaisa, saleTotal);

    // The Roznamcha now carries a reversal entry (money leaving the pool).
    final ledgerAfter = await container().read(cashLedgerProvider.future);
    expect(
        ledgerAfter.any((e) => e.kind == CashEntryKind.reversal && !e.isIn),
        isTrue);
  });
}

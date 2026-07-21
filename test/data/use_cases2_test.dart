import 'package:flutter_test/flutter_test.dart';

import 'package:anvil/core/utils/ids.dart';
import 'package:anvil/data/local/database.dart';
import 'package:anvil/data/local/queries.dart';
import 'package:anvil/data/local/tables.dart';
import 'package:anvil/domain/entities/cash_movement.dart';
import 'package:anvil/domain/services/cash_trace_service.dart';
import 'package:anvil/domain/services/stock_costing_service.dart';
import 'package:anvil/domain/use_cases/allocate_payment.dart';
import 'package:anvil/domain/use_cases/record_expense.dart';
import 'package:anvil/domain/use_cases/record_payment.dart';
import 'package:anvil/domain/use_cases/record_purchase.dart';
import 'package:anvil/domain/use_cases/record_sale.dart';
import 'package:anvil/domain/use_cases/reverse_payment.dart';
import 'package:anvil/domain/use_cases/transfer_to_godam.dart';
import 'package:anvil/domain/use_cases/use_case_result.dart';
import 'package:anvil/domain/use_cases/write_off_stock.dart';
import 'package:anvil/security/access_mode.dart';

import '../sqlite_loader.dart';

/// Integration tests for the money-movement, wastage, and reversal use-cases —
/// the Phase-1/Phase-3 critical flows (04_PHASES.md). Every one asserts the whole
/// transaction, not isolated math.
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
  Future<String> expenseCatId(String name) async =>
      (await db.expenseCategoryByName(name))!.id;

  Future<String> makeParty(String name) async {
    final id = newId();
    await db.into(db.parties).insert(PartiesCompanion.insert(
        id: id, name: name, type: PartyTypeDb.both, createdAt: DateTime.now()));
    return id;
  }

  Future<StockCategory> cat(String id) =>
      (db.select(db.stockCategories)..where((t) => t.id.equals(id))).getSingle();

  Future<int> countCashMovements() async =>
      (await db.select(db.cashMovements).get()).length;

  test('expense moves cash out and does not touch stock or party balance',
      () async {
    final res = await RecordExpense(db: db, access: access).call(
      RecordExpenseInput(
        date: DateTime(2026, 7, 21),
        amountPaisa: 500000, // Rs 5,000
        poolId: await poolId(PoolNameDb.bank),
        expenseCategoryId: await expenseCatId('Salaries'),
      ),
      confirmed: true, // Bank empty → overdraft allowed through
    );
    expect(res, isA<Success<String>>());
    expect(await db.poolBalancePaisa(await poolId(PoolNameDb.bank)), -500000);
    // No stock rows changed.
    for (final c in await db.select(db.stockCategories).get()) {
      expect(c.quantityGrams, 0);
    }
  });

  test('transfer to Godam creates paired IN/OUT movements sharing a transferId',
      () async {
    // Seed Home with Rs 30,000 via an advance-return? Simplest: use confirmed to
    // allow the source to go through, then assert the pairing.
    final res = await TransferToGodam(db: db, access: access).call(
      from: PoolNameDb.home,
      amountPaisa: 2000000, // Rs 20,000
      date: DateTime(2026, 7, 21),
      confirmed: true,
    );
    expect(res, isA<Success<String>>());

    final moves = await db.select(db.cashMovements).get();
    expect(moves.length, 2);
    expect(moves.map((m) => m.transferId).toSet().length, 1,
        reason: 'both halves share one transferId');
    final out = moves.firstWhere((m) => m.direction == CashDirectionDb.moneyOut);
    final inn = moves.firstWhere((m) => m.direction == CashDirectionDb.moneyIn);
    expect(out.pairedMovementId, inn.id);
    expect(inn.pairedMovementId, out.id);
    expect(await db.poolBalancePaisa(await poolId(PoolNameDb.home)), -2000000);
    expect(await db.poolBalancePaisa(await poolId(PoolNameDb.godam)), 2000000);
  });

  test('Godam spend traces to two funding transfers via the dynamic FIFO service',
      () async {
    // Two transfers into Godam, then an expense paid from Godam.
    await TransferToGodam(db: db, access: access).call(
        from: PoolNameDb.home,
        amountPaisa: 1000000,
        date: DateTime(2026, 7, 1),
        confirmed: true);
    await TransferToGodam(db: db, access: access).call(
        from: PoolNameDb.bank,
        amountPaisa: 1500000,
        date: DateTime(2026, 7, 2),
        confirmed: true);
    final spend = await RecordExpense(db: db, access: access).call(
      RecordExpenseInput(
        date: DateTime(2026, 7, 3),
        amountPaisa: 2000000, // Rs 20,000 spend from Godam
        poolId: await poolId(PoolNameDb.godam),
        expenseCategoryId: await expenseCatId('Other'),
      ),
      confirmed: true,
    );
    expect(spend, isA<Success<String>>());

    // Feed Godam movements into the trace service (mirrors the ledger screen).
    final godam = await poolId(PoolNameDb.godam);
    final rows = await (db.select(db.cashMovements)
          ..where((t) => t.poolId.equals(godam)))
        .get();
    final views = [
      for (final m in rows)
        CashMovementView(
          id: m.id,
          direction: m.direction == CashDirectionDb.moneyIn
              ? CashDirection.moneyIn
              : CashDirection.moneyOut,
          amountPaisa: m.amountPaisa,
          date: m.date,
          relatedBillId: m.relatedBillId,
        ),
    ];
    final traces = const CashTraceService().traceAllSpends(views);
    final spendTrace = traces.single;
    expect(spendTrace.sources.length, 2, reason: 'funded by both transfers');
    expect(spendTrace.sources[0].amountConsumedPaisa, 1000000);
    expect(spendTrace.sources[1].amountConsumedPaisa, 1000000);
    expect(spendTrace.unfundedPaisa, 0);
  });

  test('allocating an existing advance to a bill creates NO new CashMovement '
      '(critical double-count guard, 03_RULES.md §1.20)', () async {
    final party = await makeParty('Advance Co');
    final scrap = await catId('Scrap');

    // Buyer pays Rs 10,000 in advance (unallocated) into Bank.
    final payRes = await RecordPayment(db: db, access: access).call(
      RecordPaymentInput(
        partyId: party,
        amountPaisa: 1000000,
        direction: PaymentDirectionDb.received,
        poolId: await poolId(PoolNameDb.bank),
        date: DateTime(2026, 7, 1),
      ),
    );
    final paymentId = (payRes as Success<String>).value;
    expect(await countCashMovements(), 1, reason: 'one movement for the advance');

    // Later, a sale bill is created (100 kg first purchased so stock exists).
    await RecordPurchase(db: db, access: access).call(RecordPurchaseInput(
      partyId: party,
      date: DateTime(2026, 7, 2),
      rateMode: RateModeDb.perBill,
      billLevelRatePaisaPerKg: 5000,
      lines: [PurchaseLineInput(parentCategoryId: scrap, weightGrams: 100000)],
    ));
    final saleRes = await RecordSale(db: db, access: access).call(RecordSaleInput(
      partyId: party,
      date: DateTime(2026, 7, 3),
      rateMode: RateModeDb.perBill,
      billLevelRatePaisaPerKg: 6000,
      lines: [SaleLineInput(parentCategoryId: scrap, weightGrams: 10000)],
    ));
    final saleBillId = (saleRes as Success<String>).value;

    // Allocate the existing advance to the sale bill.
    final before = await countCashMovements();
    final allocRes = await AllocatePayment(db: db, access: access).call(
      paymentId: paymentId,
      allocations: [AllocationInput(billId: saleBillId, amountPaisa: 600000)],
    );
    expect(allocRes, isA<Success<void>>());
    expect(await countCashMovements(), before,
        reason: 'allocation must NOT create a second CashMovement');
    // Exactly one allocation row now exists for this payment.
    final allocs = await (db.select(db.paymentAllocations)
          ..where((t) => t.paymentId.equals(paymentId)))
        .get();
    expect(allocs.single.amountAllocatedPaisa, 600000);
  });

  test('payment reversal reopens the bill, offsets cash, keeps the record', () async {
    final party = await makeParty('Bounce Co');
    final bank = await poolId(PoolNameDb.bank);

    // A received payment fully allocated to a (stand-in) sale bill.
    final scrap = await catId('Scrap');
    await RecordPurchase(db: db, access: access).call(RecordPurchaseInput(
      partyId: party,
      date: DateTime(2026, 7, 1),
      rateMode: RateModeDb.perBill,
      billLevelRatePaisaPerKg: 5000,
      lines: [PurchaseLineInput(parentCategoryId: scrap, weightGrams: 100000)],
    ));
    final saleRes = await RecordSale(db: db, access: access).call(RecordSaleInput(
      partyId: party,
      date: DateTime(2026, 7, 2),
      rateMode: RateModeDb.perBill,
      billLevelRatePaisaPerKg: 6000,
      lines: [SaleLineInput(parentCategoryId: scrap, weightGrams: 10000)],
    ));
    final saleBillId = (saleRes as Success<String>).value;

    final payRes = await RecordPayment(db: db, access: access).call(RecordPaymentInput(
      partyId: party,
      amountPaisa: 600000, // Rs 6,000 = full sale value
      direction: PaymentDirectionDb.received,
      poolId: bank,
      date: DateTime(2026, 7, 3),
      allocations: [AllocationInput(billId: saleBillId, amountPaisa: 600000)],
    ));
    final paymentId = (payRes as Success<String>).value;
    expect(await db.poolBalancePaisa(bank), 600000);

    // Reverse it (bounced cheque).
    final rev = await ReversePayment(db: db, access: access)
        .call(paymentId: paymentId, reason: 'Cheque bounced');
    expect(rev, isA<Success<void>>());

    // Cash reverted, allocations removed, payment flagged not deleted, note logged.
    expect(await db.poolBalancePaisa(bank), 0, reason: 'offsetting movement');
    expect(
        await (db.select(db.paymentAllocations)
              ..where((t) => t.paymentId.equals(paymentId)))
            .get(),
        isEmpty,
        reason: 'bill reopened');
    final payment = await (db.select(db.payments)
          ..where((t) => t.id.equals(paymentId)))
        .getSingle();
    expect(payment.reversed, isTrue);
    expect(payment.reversalReason, 'Cheque bounced');
    final notes = await (db.select(db.updateHistories)
          ..where((t) => t.entityId.equals(party)))
        .get();
    expect(notes.single.newValue, 'Cheque bounced');
  });

  test('write-off absorb raises avg cost; expense mode posts a Wastage expense',
      () async {
    final party = await makeParty('Waste Co');
    final scrap = await catId('Scrap');
    // 100 kg @ Rs 50/kg.
    await RecordPurchase(db: db, access: access).call(RecordPurchaseInput(
      partyId: party,
      date: DateTime(2026, 7, 1),
      rateMode: RateModeDb.perBill,
      billLevelRatePaisaPerKg: 5000,
      lines: [PurchaseLineInput(parentCategoryId: scrap, weightGrams: 100000)],
    ));

    // Absorb 30 kg: qty 70, cost preserved 500000, avg rises.
    await WriteOffStock(db: db, access: access).call(
      parentCategoryId: scrap,
      weightGrams: 30000,
      mode: WriteOffMode.absorbIntoRemaining,
    );
    var c = await cat(scrap);
    expect(c.quantityGrams, 70000);
    expect(c.totalCostBasisPaisa, 500000);

    // Expense-wastage 20 kg at current avg (500000/70kg): removes value + logs it.
    final res = await WriteOffStock(db: db, access: access).call(
      parentCategoryId: scrap,
      weightGrams: 20000,
      mode: WriteOffMode.expenseWastage,
    );
    final writeOffId = (res as Success<String>).value;
    c = await cat(scrap);
    expect(c.quantityGrams, 50000);
    final wo = await (db.select(db.stockWriteOffs)
          ..where((t) => t.id.equals(writeOffId)))
        .getSingle();
    expect(wo.mode, WriteOffModeDb.expenseWastage);
    expect(wo.expensePaisa, greaterThan(0));
    expect(wo.relatedExpenseCategoryId, await expenseCatId('Wastage'));
  });
}

import 'package:drift/drift.dart';

import '../../domain/entities/party_ledger.dart';
import '../../domain/services/ledger_service.dart';
import 'database.dart';
import 'tables.dart';

/// Read-only projections used by the presentation layer. All derived numbers
/// (party balances, bill paid-status) are computed here from ledger rows via the
/// pure [LedgerService] — never read from a stored column (03_RULES.md §1.3).
extension ReadQueries on AppDatabase {
  Future<List<Party>> activeParties() => (select(parties)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm(expression: t.name)]))
      .get();

  Future<Party> partyById(String id) =>
      (select(parties)..where((t) => t.id.equals(id))).getSingle();

  Future<List<Bill>> activeBills() =>
      (select(bills)..where((t) => t.deletedAt.isNull())).get();

  Future<List<Bill>> activeBillsForParty(String partyId) => (select(bills)
        ..where((t) => t.partyId.equals(partyId) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
      .get();

  Future<List<Payment>> activePaymentsForParty(String partyId) => (select(payments)
        ..where((t) => t.partyId.equals(partyId) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
      .get();

  Future<List<PaymentAllocation>> allocationsForPayment(String paymentId) =>
      (select(paymentAllocations)..where((t) => t.paymentId.equals(paymentId)))
          .get();

  Future<List<BillLineItem>> lineItemsForBill(String billId) =>
      (select(billLineItems)..where((t) => t.billId.equals(billId))).get();

  Future<List<StockCategory>> parentCategories() => (select(stockCategories)
        ..where((t) => t.parentCategoryId.isNull() & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm(expression: t.name)]))
      .get();

  Future<List<ExpenseCategory>> activeExpenseCategories() =>
      (select(expenseCategories)..where((t) => t.deletedAt.isNull())).get();

  /// Every non-deleted line item touching [parentCategoryId], with its parent
  /// bill, ordered chronologically — the "show your work" stock ledger
  /// (01_PRD.md §4.3).
  Future<List<({BillLineItem line, Bill bill})>> stockLedger(
      String parentCategoryId) async {
    final rows = await (select(billLineItems).join([
      innerJoin(bills, bills.id.equalsExp(billLineItems.billId)),
    ])
          ..where(billLineItems.parentCategoryId.equals(parentCategoryId) &
              bills.deletedAt.isNull())
          ..orderBy([OrderingTerm(expression: bills.date)]))
        .get();
    return rows
        .map((r) => (line: r.readTable(billLineItems), bill: r.readTable(bills)))
        .toList(growable: false);
  }

  /// Non-reversed allocated paisa per bill id, for pending/paid status.
  Future<Map<String, int>> allocatedByBill() async {
    final activePayments = await (select(payments)
          ..where((t) => t.deletedAt.isNull() & t.reversed.equals(false)))
        .get();
    final activeIds = activePayments.map((p) => p.id).toSet();
    final allocs = await select(paymentAllocations).get();
    final map = <String, int>{};
    for (final a in allocs) {
      if (!activeIds.contains(a.paymentId)) continue;
      map[a.billId] = (map[a.billId] ?? 0) + a.amountAllocatedPaisa;
    }
    return map;
  }

  PartyPayment _toPartyPayment(Payment p, List<PaymentAllocation> allocs) =>
      PartyPayment(
        id: p.id,
        direction: p.direction == PaymentDirectionDb.received
            ? PaymentDirection.received
            : PaymentDirection.paid,
        amountPaisa: p.amountPaisa,
        reversed: p.reversed,
        allocations: allocs
            .map((a) =>
                PaymentAllocationView(billId: a.billId, amountPaisa: a.amountAllocatedPaisa))
            .toList(growable: false),
      );

  PartyBill? _toPartyBill(Bill b) {
    switch (b.type) {
      case BillTypeDb.sale:
        return PartyBill(
            id: b.id, kind: PartyBillKind.sale, totalPaisa: b.totalAmountPaisa);
      case BillTypeDb.purchase:
        return PartyBill(
            id: b.id, kind: PartyBillKind.purchase, totalPaisa: b.totalAmountPaisa);
      case BillTypeDb.expense:
        return null;
    }
  }

  /// Derived receivable/payable/advance for every active party, keyed by id.
  Future<Map<String, PartyBalance>> allPartyBalances() async {
    final billRows = await activeBills();
    final paymentRows =
        await (select(payments)..where((t) => t.deletedAt.isNull())).get();
    final allocRows = await select(paymentAllocations).get();

    final allocByPayment = <String, List<PaymentAllocation>>{};
    for (final a in allocRows) {
      allocByPayment.putIfAbsent(a.paymentId, () => []).add(a);
    }
    final billsByParty = <String, List<PartyBill>>{};
    for (final b in billRows) {
      if (b.partyId == null) continue;
      final pb = _toPartyBill(b);
      if (pb == null) continue;
      billsByParty.putIfAbsent(b.partyId!, () => []).add(pb);
    }
    final paymentsByParty = <String, List<PartyPayment>>{};
    for (final p in paymentRows) {
      paymentsByParty
          .putIfAbsent(p.partyId, () => [])
          .add(_toPartyPayment(p, allocByPayment[p.id] ?? const []));
    }

    const ledger = LedgerService();
    final result = <String, PartyBalance>{};
    for (final party in await activeParties()) {
      result[party.id] = ledger.deriveBalance(
        bills: billsByParty[party.id] ?? const [],
        payments: paymentsByParty[party.id] ?? const [],
      );
    }
    return result;
  }

  /// Derived balance for a single party (party detail).
  Future<PartyBalance> partyBalance(String partyId) async {
    final billRows = await activeBillsForParty(partyId);
    final paymentRows = await activePaymentsForParty(partyId);
    final projBills = <PartyBill>[];
    for (final b in billRows) {
      final pb = _toPartyBill(b);
      if (pb != null) projBills.add(pb);
    }
    final projPayments = <PartyPayment>[];
    for (final p in paymentRows) {
      projPayments.add(_toPartyPayment(p, await allocationsForPayment(p.id)));
    }
    return const LedgerService()
        .deriveBalance(bills: projBills, payments: projPayments);
  }

  Future<List<TrashRecord>> allTrashRecords() => (select(trashRecords)
        ..orderBy(
            [(t) => OrderingTerm(expression: t.deletedAt, mode: OrderingMode.desc)]))
      .get();
}

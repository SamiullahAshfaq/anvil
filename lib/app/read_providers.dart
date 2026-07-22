import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/database.dart';
import '../data/local/mappers.dart';
import '../data/local/read_queries.dart';
import '../data/local/tables.dart';
import '../domain/entities/party_ledger.dart';
import '../domain/entities/stock_position.dart';
import '../domain/services/recommended_rate_service.dart';
import '../domain/use_cases/manage_trash.dart';
import 'providers.dart';

// --- View-model records -----------------------------------------------------

typedef PartyListItem = ({Party party, PartyBalance balance});
typedef StockCardItem = ({
  StockCategory category,
  StockPosition position,
  RecommendedRate rate,
});
typedef BillListItem = ({Bill bill, String? partyName, int allocatedPaisa});
typedef PartyDetail = ({
  Party party,
  PartyBalance balance,
  List<Bill> bills,
  List<PartyPaymentRow> payments,
});

/// A payment plus its allocations, for the party settlement timeline.
class PartyPaymentRow {
  final Payment payment;
  final List<PaymentAllocation> allocations;
  const PartyPaymentRow(this.payment, this.allocations);
}

// --- Cash pools -------------------------------------------------------------

/// The three seeded cash pools (id + name), for pool pickers.
final cashPoolsProvider = FutureProvider<List<CashPool>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  return db.select(db.cashPools).get();
});

// --- Trash service ----------------------------------------------------------

final trashServiceProvider = Provider<TrashService>((ref) => TrashService(
    db: ref.watch(appDatabaseProvider),
    access: ref.watch(accessControllerProvider)));

// --- Parties ----------------------------------------------------------------

final partiesListProvider =
    FutureProvider.autoDispose<List<PartyListItem>>((ref) async {
  ref.watch(ledgerRevisionProvider);
  final db = ref.watch(appDatabaseProvider);
  final parties = await db.activeParties();
  final balances = await db.allPartyBalances();
  return [
    for (final p in parties)
      (
        party: p,
        balance: balances[p.id] ??
            const PartyBalance(
                receivablePaisa: 0,
                payablePaisa: 0,
                advanceReceivedPaisa: 0,
                advancePaidPaisa: 0)
      )
  ];
});

final partyDetailProvider =
    FutureProvider.autoDispose.family<PartyDetail, String>((ref, partyId) async {
  ref.watch(ledgerRevisionProvider);
  final db = ref.watch(appDatabaseProvider);
  final party = await db.partyById(partyId);
  final bills = await db.activeBillsForParty(partyId);
  final payments = await db.activePaymentsForParty(partyId);
  final rows = <PartyPaymentRow>[];
  for (final p in payments) {
    rows.add(PartyPaymentRow(p, await db.allocationsForPayment(p.id)));
  }
  final balance = await db.partyBalance(partyId);
  return (party: party, balance: balance, bills: bills, payments: rows);
});

// --- Stock ------------------------------------------------------------------

final stockPositionsProvider =
    FutureProvider.autoDispose<List<StockCardItem>>((ref) async {
  ref.watch(ledgerRevisionProvider);
  final db = ref.watch(appDatabaseProvider);
  const rateService = RecommendedRateService();
  final cats = await db.parentCategories();
  return [
    for (final c in cats)
      (
        category: c,
        position: c.toStockPosition(),
        rate: rateService.forPosition(c.toStockPosition(),
            marginPct: c.targetMarginPct),
      )
  ];
});

/// Chronological stock ledger for one parent category (the "show your work"
/// drill-down), with a running quantity balance computed here for display.
final stockLedgerProvider = FutureProvider.autoDispose
    .family<List<({BillLineItem line, Bill bill, int runningGrams})>, String>(
        (ref, categoryId) async {
  ref.watch(ledgerRevisionProvider);
  final db = ref.watch(appDatabaseProvider);
  final rows = await db.stockLedger(categoryId);
  var running = 0;
  final out = <({BillLineItem line, Bill bill, int runningGrams})>[];
  for (final r in rows) {
    running += r.bill.type == BillTypeDb.purchase
        ? r.line.weightGrams
        : -r.line.weightGrams;
    out.add((line: r.line, bill: r.bill, runningGrams: running));
  }
  return out.reversed.toList(growable: false); // newest first for display
});

// --- Bills ------------------------------------------------------------------

final billsListProvider =
    FutureProvider.autoDispose<List<BillListItem>>((ref) async {
  ref.watch(ledgerRevisionProvider);
  final db = ref.watch(appDatabaseProvider);
  final bills = await db.activeBills();
  final parties = {for (final p in await db.activeParties()) p.id: p.name};
  final allocated = await db.allocatedByBill();
  final items = [
    for (final b in bills)
      (
        bill: b,
        partyName: b.partyId == null ? null : parties[b.partyId],
        allocatedPaisa: allocated[b.id] ?? 0,
      )
  ];
  items.sort((a, b) => b.bill.date.compareTo(a.bill.date));
  return items;
});

/// True when a purchase/sale bill is not fully settled (03_RULES.md §4.2 pending
/// filter). Expense bills are never "pending".
bool billIsPending(BillListItem item) =>
    item.bill.type != BillTypeDb.expense &&
    !item.bill.isOpening &&
    item.allocatedPaisa < item.bill.totalAmountPaisa;

final billLineItemsProvider = FutureProvider.autoDispose
    .family<List<BillLineItem>, String>((ref, billId) async {
  ref.watch(ledgerRevisionProvider);
  final db = ref.watch(appDatabaseProvider);
  return db.lineItemsForBill(billId);
});

typedef BillView = ({
  Bill bill,
  String? partyName,
  String? expenseCategoryName,
  List<BillLineItem> lines,
  Map<String, String> categoryNames,
  int allocatedPaisa,
});

/// Full detail for one bill (the receipt view).
final billViewProvider =
    FutureProvider.autoDispose.family<BillView, String>((ref, billId) async {
  ref.watch(ledgerRevisionProvider);
  final db = ref.watch(appDatabaseProvider);
  final bill =
      await (db.select(db.bills)..where((t) => t.id.equals(billId))).getSingle();
  String? partyName;
  if (bill.partyId != null) {
    partyName = (await db.partyById(bill.partyId!)).name;
  }
  String? expenseCategoryName;
  if (bill.expenseCategoryId != null) {
    expenseCategoryName = (await (db.select(db.expenseCategories)
              ..where((t) => t.id.equals(bill.expenseCategoryId!)))
            .getSingleOrNull())
        ?.name;
  }
  final lines = await db.lineItemsForBill(billId);
  final allocated = (await db.allocatedByBill())[billId] ?? 0;
  final categoryNames = <String, String>{};
  for (final catId in lines.map((l) => l.parentCategoryId).toSet()) {
    final cat = await (db.select(db.stockCategories)
          ..where((t) => t.id.equals(catId)))
        .getSingleOrNull();
    if (cat != null) categoryNames[catId] = cat.name;
  }
  return (
    bill: bill,
    partyName: partyName,
    expenseCategoryName: expenseCategoryName,
    lines: lines,
    categoryNames: categoryNames,
    allocatedPaisa: allocated,
  );
});

// --- Expense categories -----------------------------------------------------

final expenseCategoriesProvider =
    FutureProvider.autoDispose<List<ExpenseCategory>>((ref) async {
  ref.watch(ledgerRevisionProvider);
  return ref.watch(appDatabaseProvider).activeExpenseCategories();
});

// --- Trash ------------------------------------------------------------------

final trashListProvider =
    FutureProvider.autoDispose<List<TrashRecord>>((ref) async {
  ref.watch(ledgerRevisionProvider);
  return ref.watch(appDatabaseProvider).allTrashRecords();
});

typedef TrashItem = ({TrashRecord record, String title, String subtitle});

/// Trash records resolved to display labels (the soft-deleted entity's name /
/// type), with days-until-purge computed at render time.
final trashViewProvider =
    FutureProvider.autoDispose<List<TrashItem>>((ref) async {
  ref.watch(ledgerRevisionProvider);
  final db = ref.watch(appDatabaseProvider);
  final records = await db.allTrashRecords();
  final out = <TrashItem>[];
  for (final r in records) {
    String title = r.entityType;
    String subtitle = '';
    if (r.entityType == 'party') {
      final p = await (db.select(db.parties)..where((t) => t.id.equals(r.entityId)))
          .getSingleOrNull();
      title = p?.name ?? 'Party';
      subtitle = 'Party';
    } else if (r.entityType == 'bill') {
      final b = await (db.select(db.bills)..where((t) => t.id.equals(r.entityId)))
          .getSingleOrNull();
      title = b == null
          ? 'Bill'
          : switch (b.type) {
              BillTypeDb.purchase => 'Purchase',
              BillTypeDb.sale => 'Sale',
              BillTypeDb.expense => 'Expense',
            };
      subtitle = 'Bill';
    }
    out.add((record: r, title: title, subtitle: subtitle));
  }
  return out;
});

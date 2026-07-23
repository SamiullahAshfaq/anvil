import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/cash_read_queries.dart';
import '../data/local/database.dart';
import '../data/local/queries.dart';
import '../data/local/read_queries.dart';
import '../data/local/tables.dart';
import '../domain/entities/cash_movement.dart';
import '../domain/services/cash_trace_service.dart';
import 'providers.dart';

// --- View models ------------------------------------------------------------

/// What caused a cash movement, for a plain-language label + drill-down target.
enum CashEntryKind {
  transferIn,
  transferOut,
  saleReceipt,
  purchaseAdvance,
  expense,
  paymentReceived,
  paymentPaid,
  reversal,
  opening,
  other,
}

/// One resolved row of the Roznamcha / a pool ledger: the movement plus the
/// human label and where tapping it drills to (nothing is a dead-end number,
/// 01_PRD.md §4.5).
class CashLedgerEntry {
  final CashMovement movement;
  final PoolNameDb pool;
  final CashEntryKind kind;
  final String title;
  final String? subtitle;
  final String? partyId;
  final String? billId;
  final String? paymentId;
  final String? expenseCategoryId;

  const CashLedgerEntry({
    required this.movement,
    required this.pool,
    required this.kind,
    required this.title,
    this.subtitle,
    this.partyId,
    this.billId,
    this.paymentId,
    this.expenseCategoryId,
  });

  bool get isIn => movement.direction == CashDirectionDb.moneyIn;
  DateTime get date => movement.date;
  int get amountPaisa => movement.amountPaisa;
}

String poolLabel(PoolNameDb n) => switch (n) {
      PoolNameDb.home => 'Home',
      PoolNameDb.bank => 'Bank',
      PoolNameDb.godam => 'Godam',
    };

// --- Resolution -------------------------------------------------------------

/// Resolves raw [CashMovement] rows into labelled [CashLedgerEntry]s using batch
/// lookups (one pass, no N+1). Shared by the Roznamcha and Godam-ledger providers.
class _CashResolver {
  final Map<String, PoolNameDb> poolName;
  final Map<String, CashMovement> byId;
  final Map<String, Party> parties;
  final Map<String, Bill> bills;
  final Map<String, Payment> payments;
  final Map<String, String> expenseCatName;

  _CashResolver({
    required this.poolName,
    required this.byId,
    required this.parties,
    required this.bills,
    required this.payments,
    required this.expenseCatName,
  });

  CashLedgerEntry resolve(CashMovement m) {
    final pool = poolName[m.poolId] ?? PoolNameDb.home;
    final isIn = m.direction == CashDirectionDb.moneyIn;

    // 1. Transfer half (Home/Bank -> Godam), identified by transferId + paired.
    if (m.transferId != null) {
      final paired =
          m.pairedMovementId == null ? null : byId[m.pairedMovementId];
      final otherPool = paired == null ? null : poolName[paired.poolId];
      if (isIn) {
        return CashLedgerEntry(
          movement: m,
          pool: pool,
          kind: CashEntryKind.transferIn,
          title: 'Transfer in',
          subtitle: otherPool == null ? null : 'From ${poolLabel(otherPool)}',
        );
      }
      return CashLedgerEntry(
        movement: m,
        pool: pool,
        kind: CashEntryKind.transferOut,
        title: 'Transfer to Godam',
        subtitle: 'From ${poolLabel(pool)}',
      );
    }

    // 2. Bill-driven movement (sale receipt / purchase advance / expense).
    if (m.relatedBillId != null) {
      final bill = bills[m.relatedBillId];
      final partyName =
          bill?.partyId == null ? null : parties[bill!.partyId]?.name;
      if (bill != null) {
        switch (bill.type) {
          case BillTypeDb.sale:
            return CashLedgerEntry(
              movement: m,
              pool: pool,
              kind: CashEntryKind.saleReceipt,
              title: 'Sale receipt',
              subtitle: partyName,
              partyId: bill.partyId,
              billId: bill.id,
            );
          case BillTypeDb.purchase:
            return CashLedgerEntry(
              movement: m,
              pool: pool,
              kind: CashEntryKind.purchaseAdvance,
              title: 'Purchase payment',
              subtitle: partyName,
              partyId: bill.partyId,
              billId: bill.id,
            );
          case BillTypeDb.expense:
            final label = bill.expenseCategoryId == null
                ? partyName
                : expenseCatName[bill.expenseCategoryId];
            return CashLedgerEntry(
              movement: m,
              pool: pool,
              kind: CashEntryKind.expense,
              title: 'Expense',
              subtitle: label,
              partyId: bill.partyId,
              billId: bill.id,
              expenseCategoryId: bill.expenseCategoryId,
            );
        }
      }
    }

    // 3. Payment-driven movement (standalone payment or its reversal).
    if (m.relatedPaymentId != null) {
      final payment = payments[m.relatedPaymentId];
      final partyName =
          payment == null ? null : parties[payment.partyId]?.name;
      if (payment != null) {
        final originalDirIn = payment.direction == PaymentDirectionDb.received;
        // The reversal movement runs opposite to the payment's own direction.
        final isReversal = isIn != originalDirIn;
        if (isReversal) {
          return CashLedgerEntry(
            movement: m,
            pool: pool,
            kind: CashEntryKind.reversal,
            title: 'Payment reversed',
            subtitle: partyName,
            partyId: payment.partyId,
            paymentId: payment.id,
          );
        }
        return CashLedgerEntry(
          movement: m,
          pool: pool,
          kind: originalDirIn
              ? CashEntryKind.paymentReceived
              : CashEntryKind.paymentPaid,
          title: originalDirIn ? 'Payment received' : 'Payment made',
          subtitle: partyName,
          partyId: payment.partyId,
          paymentId: payment.id,
        );
      }
    }

    // 4. Unattributed inbound movement = a Day-0 opening cash position.
    return CashLedgerEntry(
      movement: m,
      pool: pool,
      kind: isIn ? CashEntryKind.opening : CashEntryKind.other,
      title: isIn ? 'Opening cash' : 'Cash out',
    );
  }
}

Future<_CashResolver> _buildResolver(AppDatabase db,
    {required List<CashMovement> forPaired}) async {
  final pools = await db.allPools();
  final parties = await db.select(db.parties).get();
  final bills = await db.select(db.bills).get();
  final paymentsRows = await db.select(db.payments).get();
  final expenseCats = await db.select(db.expenseCategories).get();
  return _CashResolver(
    poolName: {for (final p in pools) p.id: p.name},
    byId: {for (final m in forPaired) m.id: m},
    parties: {for (final p in parties) p.id: p},
    bills: {for (final b in bills) b.id: b},
    payments: {for (final p in paymentsRows) p.id: p},
    expenseCatName: {for (final e in expenseCats) e.id: e.name},
  );
}

// --- Roznamcha (all pools) --------------------------------------------------

/// Every cash movement across Home/Bank/Godam, resolved and newest-first — the
/// Cash Flow Ledger source (01_PRD.md §4.5). Filtering happens in the screen.
final cashLedgerProvider =
    FutureProvider.autoDispose<List<CashLedgerEntry>>((ref) async {
  ref.watch(ledgerRevisionProvider);
  final db = ref.watch(appDatabaseProvider);
  final movements = await db.activeCashMovements(); // already newest-first
  final resolver = await _buildResolver(db, forPaired: movements);
  return [for (final m in movements) resolver.resolve(m)];
});

// --- Godam ledger + FIFO spend trace ----------------------------------------

typedef GodamSpendRow = ({CashLedgerEntry entry, SpendTrace trace});

class GodamLedgerView {
  final int balancePaisa;
  final List<CashLedgerEntry> fundings; // inbound transfers, newest first
  final List<GodamSpendRow> spends; // outbound spends w/ FIFO trace, newest first
  const GodamLedgerView({
    required this.balancePaisa,
    required this.fundings,
    required this.spends,
  });
}

/// Godam fundings-in + spends-out with each spend's dynamic FIFO trace
/// (01_PRD.md §4.4; 03_RULES.md §1.21). The trace is computed at read time over
/// the movement rows, never stored.
final godamLedgerProvider =
    FutureProvider.autoDispose<GodamLedgerView>((ref) async {
  ref.watch(ledgerRevisionProvider);
  final db = ref.watch(appDatabaseProvider);
  final godam = await db.poolByName(PoolNameDb.godam);
  final chrono = await db.movementsForPool(godam.id); // oldest first
  // Resolve against ALL movements so a transfer's paired (source-pool) half is
  // found when naming "From Home / Bank" on an inbound funding.
  final resolver = await _buildResolver(db, forPaired: await db.activeCashMovements());

  const trace = CashTraceService();
  final views = [
    for (final m in chrono)
      CashMovementView(
        id: m.id,
        direction: m.direction == CashDirectionDb.moneyIn
            ? CashDirection.moneyIn
            : CashDirection.moneyOut,
        amountPaisa: m.amountPaisa,
        date: m.date,
        sequence: m.sequence,
        transferId: m.transferId,
        relatedBillId: m.relatedBillId,
      )
  ];
  final traces = {
    for (final t in trace.traceAllSpends(views)) t.spendMovementId: t
  };

  final fundings = <CashLedgerEntry>[];
  final spends = <GodamSpendRow>[];
  for (final m in chrono) {
    final entry = resolver.resolve(m);
    if (m.direction == CashDirectionDb.moneyIn) {
      fundings.add(entry);
    } else {
      spends.add((entry: entry, trace: traces[m.id]!));
    }
  }
  return GodamLedgerView(
    balancePaisa: trace.poolBalance(views),
    fundings: fundings.reversed.toList(growable: false),
    spends: spends.reversed.toList(growable: false),
  );
});

// --- Payment allocation: open bills for a party -----------------------------

/// A bill of [partyId] with an outstanding (unpaid/uncollected) balance, plus
/// how much is already allocated to it — the allocation targets for a payment.
typedef OpenBill = ({Bill bill, int allocatedPaisa, int outstandingPaisa});

/// Open (not fully settled) purchase/sale bills for a party, oldest first.
final openBillsForPartyProvider = FutureProvider.autoDispose
    .family<List<OpenBill>, String>((ref, partyId) async {
  ref.watch(ledgerRevisionProvider);
  final db = ref.watch(appDatabaseProvider);
  final bills = await db.activeBillsForParty(partyId);
  final allocated = await db.allocatedByBill();
  final out = <OpenBill>[];
  for (final b in bills) {
    if (b.type == BillTypeDb.expense) continue;
    final alloc = allocated[b.id] ?? 0;
    final outstanding = b.totalAmountPaisa - alloc;
    if (outstanding > 0) {
      out.add((bill: b, allocatedPaisa: alloc, outstandingPaisa: outstanding));
    }
  }
  out.sort((a, b) => a.bill.date.compareTo(b.bill.date)); // oldest first
  return out;
});

/// An existing payment with an unallocated advance balance still to place.
typedef PartyAdvance = ({Payment payment, int unallocatedPaisa});

/// Payments for a party carrying an unallocated advance (03_RULES.md §1.20 — a
/// later allocation inserts a PaymentAllocation only, never a new CashMovement).
final partyAdvancesProvider = FutureProvider.autoDispose
    .family<List<PartyAdvance>, String>((ref, partyId) async {
  ref.watch(ledgerRevisionProvider);
  final db = ref.watch(appDatabaseProvider);
  final ps = await db.activePaymentsForParty(partyId);
  final out = <PartyAdvance>[];
  for (final p in ps) {
    if (p.reversed) continue;
    final allocs = await db.allocationsForPayment(p.id);
    final alloc = allocs.fold<int>(0, (s, a) => s + a.amountAllocatedPaisa);
    final unalloc = p.amountPaisa - alloc;
    if (unalloc > 0) out.add((payment: p, unallocatedPaisa: unalloc));
  }
  return out;
});

// --- Reconciliation ---------------------------------------------------------

class ReconciliationView {
  final List<({PoolNameDb name, int balancePaisa})> pools;
  final int totalCashPaisa;
  const ReconciliationView({required this.pools, required this.totalCashPaisa});
}

/// Home + Bank + Godam balances and their sum = total cash on hand, so the
/// figure the Dashboard's net worth uses for cash is auditable here (01_PRD.md
/// §4.4 reconciliation).
final reconciliationProvider =
    FutureProvider.autoDispose<ReconciliationView>((ref) async {
  ref.watch(ledgerRevisionProvider);
  final db = ref.watch(appDatabaseProvider);
  final pools = <({PoolNameDb name, int balancePaisa})>[];
  var total = 0;
  for (final name in PoolNameDb.values) {
    final pool = await db.poolByName(name);
    final bal = await db.poolBalancePaisa(pool.id);
    pools.add((name: name, balancePaisa: bal));
    total += bal;
  }
  return ReconciliationView(pools: pools, totalCashPaisa: total);
});

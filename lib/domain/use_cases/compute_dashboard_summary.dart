import 'package:drift/drift.dart';

import '../../data/local/database.dart';
import '../../data/local/tables.dart';
import '../entities/dashboard_summary.dart';

/// Computes the Dashboard from the ledger (01_PRD.md §4.6). Read-only — allowed
/// in View mode, so it does NOT call `ensureCanMutate`. Every figure is derived
/// from source rows, never a stored aggregate. The period P&L excludes Day-0
/// opening bills (pre-app history, not sales/purchases of the month).
class ComputeDashboardSummary {
  final AppDatabase db;
  const ComputeDashboardSummary(this.db);

  /// [year]/[month] anchor the P&L period; [scope] widens it to the containing
  /// quarter when [PeriodScope.quarter]. Defaults to the current calendar month
  /// in the device's local timezone (03_RULES.md §5). The position figures (net
  /// worth, receivable/payable, stock) are always "as of now" — only the P&L is
  /// period-scoped.
  Future<DashboardSummary> call(
      {int? year, int? month, PeriodScope scope = PeriodScope.month}) async {
    final now = DateTime.now();
    final y = year ?? now.year;
    final m = month ?? now.month;
    final (periodStart, periodEnd) = periodBounds(scope, y, m);

    final bills = await (db.select(db.bills)
          ..where((t) => t.deletedAt.isNull()))
        .get();
    final lineItems = await db.select(db.billLineItems).get();
    final payments = await (db.select(db.payments)
          ..where((t) => t.deletedAt.isNull() & t.reversed.equals(false)))
        .get();
    final allocations = await db.select(db.paymentAllocations).get();
    final categories = await (db.select(db.stockCategories)
          ..where((t) => t.parentCategoryId.isNull() & t.deletedAt.isNull()))
        .get();
    final movements = await (db.select(db.cashMovements)
          ..where((t) => t.deletedAt.isNull()))
        .get();
    final writeOffs = await (db.select(db.stockWriteOffs)
          ..where((t) => t.deletedAt.isNull()))
        .get();
    final parties = await db.select(db.parties).get();
    final expenseCats = await db.select(db.expenseCategories).get();

    final partyName = {for (final p in parties) p.id: p.name};
    final catName = {for (final c in categories) c.id: c.name};
    final expenseCatName = {for (final e in expenseCats) e.id: e.name};

    // --- Position ---
    final cashOnHand = movements.fold<int>(
        0,
        (s, mv) => s +
            (mv.direction == CashDirectionDb.moneyIn
                ? mv.amountPaisa
                : -mv.amountPaisa));

    // Allocation sums per bill, split by payment direction (non-reversed only).
    final paymentDir = {for (final p in payments) p.id: p.direction};
    final receivedByBill = <String, int>{};
    final paidByBill = <String, int>{};
    for (final a in allocations) {
      final dir = paymentDir[a.paymentId];
      if (dir == null) continue; // payment reversed/deleted → ignore
      final target =
          dir == PaymentDirectionDb.received ? receivedByBill : paidByBill;
      target[a.billId] = (target[a.billId] ?? 0) + a.amountAllocatedPaisa;
    }

    var receivable = 0;
    var payable = 0;
    final receivableByParty = <String, int>{};
    for (final b in bills) {
      if (b.partyId == null) continue; // party-less opening stock bill
      if (b.type == BillTypeDb.sale) {
        final out = b.totalAmountPaisa - (receivedByBill[b.id] ?? 0);
        if (out > 0) {
          receivable += out;
          receivableByParty[b.partyId!] =
              (receivableByParty[b.partyId!] ?? 0) + out;
        }
      } else if (b.type == BillTypeDb.purchase) {
        final out = b.totalAmountPaisa - (paidByBill[b.id] ?? 0);
        if (out > 0) payable += out;
      }
    }

    final stockValue =
        categories.fold<int>(0, (s, c) => s + c.totalCostBasisPaisa);

    // --- Period P&L (opening bills excluded) ---
    bool inPeriod(DateTime d) =>
        !d.isBefore(periodStart) && d.isBefore(periodEnd);

    final periodSaleBillIds = <String>{};
    var revenue = 0;
    var cashExpense = 0;
    var biggestExpense = 0;
    String? biggestExpenseLabel;
    String? biggestExpenseBillId;
    for (final b in bills) {
      if (b.isOpening || !inPeriod(b.date)) continue;
      switch (b.type) {
        case BillTypeDb.sale:
          revenue += b.totalAmountPaisa;
          periodSaleBillIds.add(b.id);
        case BillTypeDb.expense:
          cashExpense += b.totalAmountPaisa;
          if (b.totalAmountPaisa > biggestExpense) {
            biggestExpense = b.totalAmountPaisa;
            biggestExpenseBillId = b.id;
            biggestExpenseLabel = b.expenseCategoryId != null
                ? expenseCatName[b.expenseCategoryId]
                : (b.partyId != null ? partyName[b.partyId] : null);
          }
        case BillTypeDb.purchase:
          break; // purchases affect stock/cash, not P&L directly
      }
    }

    // COGS + per-category margins from the period's sale line items.
    var cogs = 0;
    final marginRevenue = <String, int>{};
    final marginCogs = <String, int>{};
    for (final li in lineItems) {
      if (!periodSaleBillIds.contains(li.billId)) continue;
      final lineCogs = li.cogsPaisa ?? 0;
      cogs += lineCogs;
      marginRevenue[li.parentCategoryId] =
          (marginRevenue[li.parentCategoryId] ?? 0) + li.lineTotalPaisa;
      marginCogs[li.parentCategoryId] =
          (marginCogs[li.parentCategoryId] ?? 0) + lineCogs;
    }

    // Non-cash wastage expense in the period.
    var wastageExpense = 0;
    for (final w in writeOffs) {
      if (w.mode == WriteOffModeDb.expenseWastage && inPeriod(w.date)) {
        wastageExpense += w.expensePaisa;
      }
    }

    // Best/worst margin category.
    CategoryMargin? best;
    CategoryMargin? worst;
    for (final catId in {...marginRevenue.keys, ...marginCogs.keys}) {
      final cm = CategoryMargin(
        categoryId: catId,
        name: catName[catId] ?? '',
        revenuePaisa: marginRevenue[catId] ?? 0,
        cogsPaisa: marginCogs[catId] ?? 0,
      );
      if (best == null || cm.profitPaisa > best.profitPaisa) best = cm;
      if (worst == null || cm.profitPaisa < worst.profitPaisa) worst = cm;
    }

    // Largest outstanding receivable party.
    var largestReceivable = 0;
    String? largestReceivableParty;
    String? largestReceivablePartyId;
    receivableByParty.forEach((pid, amt) {
      if (amt > largestReceivable) {
        largestReceivable = amt;
        largestReceivableParty = partyName[pid];
        largestReceivablePartyId = pid;
      }
    });

    return DashboardSummary(
      cashOnHandPaisa: cashOnHand,
      receivablePaisa: receivable,
      payablePaisa: payable,
      stockValueAtCostPaisa: stockValue,
      scope: scope,
      periodStart: periodStart,
      periodEnd: periodEnd,
      periodRevenuePaisa: revenue,
      periodCogsPaisa: cogs,
      periodExpensePaisa: cashExpense + wastageExpense,
      bestMarginCategory: best,
      worstMarginCategory: worst,
      biggestExpensePaisa: biggestExpense,
      biggestExpenseLabel: biggestExpenseLabel,
      biggestExpenseBillId: biggestExpenseBillId,
      largestReceivablePaisa: largestReceivable,
      largestReceivablePartyName: largestReceivableParty,
      largestReceivablePartyId: largestReceivablePartyId,
    );
  }

  /// The [start, end) bounds for a P&L period anchored on [year]/[month].
  /// Month scope → that calendar month; quarter scope → the calendar quarter
  /// containing that month (Jan–Mar, Apr–Jun, Jul–Sep, Oct–Dec).
  static (DateTime, DateTime) periodBounds(PeriodScope scope, int year, int month) {
    if (scope == PeriodScope.quarter) {
      final qStartMonth = ((month - 1) ~/ 3) * 3 + 1;
      return (DateTime(year, qStartMonth), DateTime(year, qStartMonth + 3));
    }
    return (DateTime(year, month), DateTime(year, month + 1));
  }

  static const _monthAbbr = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// The last [count] periods up to and including the one containing [anchor]
  /// (default now), oldest first — the series behind the profit bar chart
  /// (01_PRD.md §4.6). Profit per period = revenue − COGS − (cash + wastage
  /// expenses), Day-0 opening bills excluded, identical to [call]'s P&L math.
  Future<List<PeriodProfit>> profitSeries({
    PeriodScope scope = PeriodScope.month,
    int count = 6,
    DateTime? anchor,
  }) async {
    final now = anchor ?? DateTime.now();

    // Build the ordered list of period anchors (oldest → newest).
    final anchors = <(int, int)>[];
    if (scope == PeriodScope.quarter) {
      var y = now.year;
      var qStart = ((now.month - 1) ~/ 3) * 3 + 1;
      for (var i = 0; i < count; i++) {
        anchors.add((y, qStart));
        qStart -= 3;
        if (qStart < 1) {
          qStart += 12;
          y -= 1;
        }
      }
    } else {
      var y = now.year;
      var mo = now.month;
      for (var i = 0; i < count; i++) {
        anchors.add((y, mo));
        mo -= 1;
        if (mo < 1) {
          mo += 12;
          y -= 1;
        }
      }
    }
    anchors.sort((a, b) => a.$1 != b.$1 ? a.$1 - b.$1 : a.$2 - b.$2);

    // Load once, bucket the sale/expense/wastage rows across all periods.
    final bills = await (db.select(db.bills)
          ..where((t) => t.deletedAt.isNull()))
        .get();
    final lineItems = await db.select(db.billLineItems).get();
    final writeOffs = await (db.select(db.stockWriteOffs)
          ..where((t) => t.deletedAt.isNull()))
        .get();

    // A sale bill's id → COGS from its line items (period-independent).
    final cogsByBill = <String, int>{};
    for (final li in lineItems) {
      cogsByBill[li.billId] = (cogsByBill[li.billId] ?? 0) + (li.cogsPaisa ?? 0);
    }

    final out = <PeriodProfit>[];
    for (final (y, m) in anchors) {
      final (start, end) = periodBounds(scope, y, m);
      bool inPeriod(DateTime d) => !d.isBefore(start) && d.isBefore(end);

      var revenue = 0;
      var cogs = 0;
      var expense = 0;
      for (final b in bills) {
        if (b.isOpening || !inPeriod(b.date)) continue;
        switch (b.type) {
          case BillTypeDb.sale:
            revenue += b.totalAmountPaisa;
            cogs += cogsByBill[b.id] ?? 0;
          case BillTypeDb.expense:
            expense += b.totalAmountPaisa;
          case BillTypeDb.purchase:
            break;
        }
      }
      for (final w in writeOffs) {
        if (w.mode == WriteOffModeDb.expenseWastage && inPeriod(w.date)) {
          expense += w.expensePaisa;
        }
      }

      final label = scope == PeriodScope.quarter
          ? 'Q${((m - 1) ~/ 3) + 1}'
          : _monthAbbr[m - 1];
      out.add(PeriodProfit(
        label: label,
        start: start,
        end: end,
        year: y,
        month: m,
        revenuePaisa: revenue,
        cogsPaisa: cogs,
        expensePaisa: expense,
      ));
    }
    return out;
  }
}

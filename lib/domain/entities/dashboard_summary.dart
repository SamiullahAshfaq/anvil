/// How the dashboard P&L period is scoped (03_RULES.md §5 — calendar month by
/// local timezone; quarterly is a thin wrapper over the same math).
enum PeriodScope { month, quarter }

/// One period's profit line, for the monthly/quarterly bar chart (01_PRD.md §4.6).
/// Every figure is derived from the ledger; profit = revenue − COGS − expenses,
/// with opening (Day-0) bills excluded, exactly as [DashboardSummary].
class PeriodProfit {
  /// Short axis label, e.g. `Jul` (month) or `Q3` (quarter).
  final String label;

  /// Period bounds — [start] inclusive, [end] exclusive — so the UI can drill
  /// into exactly this window.
  final DateTime start;
  final DateTime end;
  final int year;

  /// The month number this period is anchored on (its first month), so a tapped
  /// bar can re-request the same window from [ComputeDashboardSummary].
  final int month;

  final int revenuePaisa;
  final int cogsPaisa;
  final int expensePaisa;

  int get profitPaisa => revenuePaisa - cogsPaisa - expensePaisa;

  const PeriodProfit({
    required this.label,
    required this.start,
    required this.end,
    required this.year,
    required this.month,
    required this.revenuePaisa,
    required this.cogsPaisa,
    required this.expensePaisa,
  });
}

/// Per-category profit for a reporting period, used for the "best/worst margin"
/// plain-language takeaway.
class CategoryMargin {
  final String categoryId;
  final String name;
  final int revenuePaisa;
  final int cogsPaisa;
  int get profitPaisa => revenuePaisa - cogsPaisa;
  const CategoryMargin({
    required this.categoryId,
    required this.name,
    required this.revenuePaisa,
    required this.cogsPaisa,
  });
}

/// Everything the Dashboard shows, computed from the ledger (01_PRD.md §4.6).
/// Every figure here is derived and drillable to source records — no stored
/// aggregates. Money is Paisa.
class DashboardSummary {
  // --- Position (as of now) ---
  final int cashOnHandPaisa; // Home + Bank + Godam
  final int receivablePaisa;
  final int payablePaisa;
  final int stockValueAtCostPaisa;
  int get netWorthPaisa =>
      cashOnHandPaisa + receivablePaisa - payablePaisa + stockValueAtCostPaisa;

  // --- Period P&L (the scoped month/quarter, opening bills excluded) ---
  final PeriodScope scope;
  final DateTime periodStart; // inclusive
  final DateTime periodEnd; // exclusive
  final int periodRevenuePaisa;
  final int periodCogsPaisa;
  final int periodExpensePaisa; // cash expenses + non-cash wastage
  int get periodProfitPaisa =>
      periodRevenuePaisa - periodCogsPaisa - periodExpensePaisa;

  // --- Plain-language takeaway (each carries the id of its source record so the
  //     dashboard can drill down to it — 03_RULES.md §1.14) ---
  final CategoryMargin? bestMarginCategory;
  final CategoryMargin? worstMarginCategory;
  final int biggestExpensePaisa;
  final String? biggestExpenseLabel;
  final String? biggestExpenseBillId;
  final int largestReceivablePaisa;
  final String? largestReceivablePartyName;
  final String? largestReceivablePartyId;

  const DashboardSummary({
    required this.cashOnHandPaisa,
    required this.receivablePaisa,
    required this.payablePaisa,
    required this.stockValueAtCostPaisa,
    required this.scope,
    required this.periodStart,
    required this.periodEnd,
    required this.periodRevenuePaisa,
    required this.periodCogsPaisa,
    required this.periodExpensePaisa,
    this.bestMarginCategory,
    this.worstMarginCategory,
    this.biggestExpensePaisa = 0,
    this.biggestExpenseLabel,
    this.biggestExpenseBillId,
    this.largestReceivablePaisa = 0,
    this.largestReceivablePartyName,
    this.largestReceivablePartyId,
  });
}

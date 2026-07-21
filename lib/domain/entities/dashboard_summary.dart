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
  final int periodRevenuePaisa;
  final int periodCogsPaisa;
  final int periodExpensePaisa; // cash expenses + non-cash wastage
  int get periodProfitPaisa =>
      periodRevenuePaisa - periodCogsPaisa - periodExpensePaisa;

  // --- Plain-language takeaway ---
  final CategoryMargin? bestMarginCategory;
  final CategoryMargin? worstMarginCategory;
  final int biggestExpensePaisa;
  final String? biggestExpenseLabel;
  final int largestReceivablePaisa;
  final String? largestReceivablePartyName;

  const DashboardSummary({
    required this.cashOnHandPaisa,
    required this.receivablePaisa,
    required this.payablePaisa,
    required this.stockValueAtCostPaisa,
    required this.periodRevenuePaisa,
    required this.periodCogsPaisa,
    required this.periodExpensePaisa,
    this.bestMarginCategory,
    this.worstMarginCategory,
    this.biggestExpensePaisa = 0,
    this.biggestExpenseLabel,
    this.largestReceivablePaisa = 0,
    this.largestReceivablePartyName,
  });
}

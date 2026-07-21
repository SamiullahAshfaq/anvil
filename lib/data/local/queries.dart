import 'package:drift/drift.dart';

import 'database.dart';
import 'tables.dart';

/// Shared read helpers used across use-cases, so derived values (pool balances,
/// lookups) are computed one consistent way. Balances are always summed from
/// movement rows — never a stored column (03_RULES.md §1.3).
extension CashQueries on AppDatabase {
  /// Running balance of a pool = Σ in − Σ out over its non-deleted movements.
  Future<int> poolBalancePaisa(String poolId) async {
    final rows = await (select(cashMovements)
          ..where((t) => t.poolId.equals(poolId) & t.deletedAt.isNull()))
        .get();
    return rows.fold<int>(
      0,
      (s, m) => s +
          (m.direction == CashDirectionDb.moneyIn
              ? m.amountPaisa
              : -m.amountPaisa),
    );
  }

  Future<CashPool> poolByName(PoolNameDb name) => (select(cashPools)
        ..where((t) => t.name.equals(name.name)))
      .getSingle();

  Future<ExpenseCategory?> expenseCategoryByName(String name) =>
      (select(expenseCategories)..where((t) => t.name.equals(name)))
          .getSingleOrNull();
}

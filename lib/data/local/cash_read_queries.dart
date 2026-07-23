import 'package:drift/drift.dart';

import 'database.dart';

/// Read-only projections for the Cash & Godam / Payments screens (Phase 3 UI over
/// the existing use-cases). Every balance is summed from movement rows — never a
/// stored column (03_RULES.md §1.3). The Godam FIFO trace is computed at read
/// time by [CashTraceService] over these rows, never a stored allocation table.
extension CashReadQueries on AppDatabase {
  /// Every non-deleted cash movement across all pools, newest first — the source
  /// for the Roznamcha (01_PRD.md §4.5).
  Future<List<CashMovement>> activeCashMovements() => (select(cashMovements)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([
          (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
          (t) => OrderingTerm(expression: t.sequence, mode: OrderingMode.desc),
        ]))
      .get();

  /// Non-deleted movements for one pool, chronological (oldest first) — the order
  /// the FIFO trace consumes (03_RULES.md §1.21).
  Future<List<CashMovement>> movementsForPool(String poolId) =>
      (select(cashMovements)
            ..where((t) => t.poolId.equals(poolId) & t.deletedAt.isNull())
            ..orderBy([
              (t) => OrderingTerm(expression: t.date),
              (t) => OrderingTerm(expression: t.sequence),
            ]))
          .get();

  Future<CashMovement?> cashMovementById(String id) =>
      (select(cashMovements)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<Bill?> billById(String id) =>
      (select(bills)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<Payment?> paymentById(String id) =>
      (select(payments)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<CashPool>> allPools() => select(cashPools).get();
}

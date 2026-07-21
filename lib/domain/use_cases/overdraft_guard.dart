import '../../data/local/database.dart';
import '../../data/local/queries.dart';
import '../services/cash_overdraft_service.dart';
import 'use_case_result.dart';

/// Shared pre-commit overdraft check used by every use-case that withdraws from a
/// cash pool (purchase advance, expense, Godam transfer, paid payment). Returns
/// an [OverdraftWarning] when the withdrawal would take the pool negative, else
/// null — the caller surfaces it via [NeedsConfirmation] (03_RULES.md §1.25).
Future<OverdraftWarning?> overdraftWarningIfAny(
  AppDatabase db,
  CashOverdraftService overdraft, {
  required String poolId,
  required int withdrawalPaisa,
}) async {
  final check = overdraft.check(
    currentBalancePaisa: await db.poolBalancePaisa(poolId),
    withdrawalPaisa: withdrawalPaisa,
  );
  if (!check.needsConfirmation) return null;
  final pool =
      await (db.select(db.cashPools)..where((t) => t.id.equals(poolId)))
          .getSingle();
  return OverdraftWarning(
    poolId: poolId,
    poolName: pool.name.name,
    resultingBalancePaisa: check.resultingBalancePaisa,
  );
}

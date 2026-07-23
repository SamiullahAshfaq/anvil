import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/database.dart';
import '../data/local/queries.dart';
import '../data/local/tables.dart';
import '../domain/entities/dashboard_summary.dart';
import '../domain/use_cases/allocate_payment.dart';
import '../domain/use_cases/compute_dashboard_summary.dart';
import '../domain/use_cases/manage_party.dart';
import '../domain/use_cases/manage_stock.dart';
import '../domain/use_cases/record_expense.dart';
import '../domain/use_cases/record_payment.dart';
import '../domain/use_cases/record_purchase.dart';
import '../domain/use_cases/record_sale.dart';
import '../domain/use_cases/reverse_payment.dart';
import '../domain/use_cases/run_day_zero_migration.dart';
import '../domain/use_cases/transfer_to_godam.dart';
import '../domain/use_cases/write_off_stock.dart';
import '../security/access_mode.dart';
import '../security/pin_service.dart';

/// The open [AppDatabase]. Overridden in `main.dart` with the real file-backed
/// database, and in tests with `AppDatabase.memory()`.
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('appDatabaseProvider must be overridden'),
);

/// PIN/secure-storage gateway. Overridden in tests with an in-memory fake.
final pinServiceProvider =
    Provider<PinService>((ref) => SecurePinService());

/// Whether first-run onboarding (business name + PINs) has been completed.
/// Invalidate after onboarding to re-read.
final setupCompleteProvider =
    FutureProvider<bool>((ref) => ref.watch(pinServiceProvider).isSetupComplete());

/// Whether the current session has been unlocked with a PIN. Set false to lock.
final sessionUnlockedProvider = StateProvider<bool>((ref) => false);

/// The current Admin/View access mode. Flipping this rebuilds
/// [accessControllerProvider] and every use-case that depends on it, so a
/// View-only session genuinely cannot mutate even if a button is left visible
/// (the real boundary is `ensureCanMutate` in the use-case — 03_RULES.md §1.22).
final accessModeProvider = StateProvider<AccessMode>((ref) => AccessMode.admin);

/// Current Admin/View access controller, derived from [accessModeProvider].
final accessControllerProvider = Provider<AccessController>(
    (ref) => AccessController(ref.watch(accessModeProvider)));

// --- Use-case providers (each reads the db + access controller) -------------

RecordPurchase _purchase(Ref ref) => RecordPurchase(
    db: ref.watch(appDatabaseProvider), access: ref.watch(accessControllerProvider));
final recordPurchaseProvider = Provider<RecordPurchase>(_purchase);

final recordSaleProvider = Provider<RecordSale>((ref) => RecordSale(
    db: ref.watch(appDatabaseProvider),
    access: ref.watch(accessControllerProvider)));

final recordExpenseProvider = Provider<RecordExpense>((ref) => RecordExpense(
    db: ref.watch(appDatabaseProvider),
    access: ref.watch(accessControllerProvider)));

final recordPaymentProvider = Provider<RecordPayment>((ref) => RecordPayment(
    db: ref.watch(appDatabaseProvider),
    access: ref.watch(accessControllerProvider)));

final allocatePaymentProvider = Provider<AllocatePayment>((ref) => AllocatePayment(
    db: ref.watch(appDatabaseProvider),
    access: ref.watch(accessControllerProvider)));

final reversePaymentProvider = Provider<ReversePayment>((ref) => ReversePayment(
    db: ref.watch(appDatabaseProvider),
    access: ref.watch(accessControllerProvider)));

final transferToGodamProvider = Provider<TransferToGodam>((ref) => TransferToGodam(
    db: ref.watch(appDatabaseProvider),
    access: ref.watch(accessControllerProvider)));

final writeOffStockProvider = Provider<WriteOffStock>((ref) => WriteOffStock(
    db: ref.watch(appDatabaseProvider),
    access: ref.watch(accessControllerProvider)));

final runDayZeroMigrationProvider = Provider<RunDayZeroMigration>((ref) =>
    RunDayZeroMigration(
        db: ref.watch(appDatabaseProvider),
        access: ref.watch(accessControllerProvider)));

final managePartyProvider = Provider<ManageParty>((ref) => ManageParty(
    db: ref.watch(appDatabaseProvider),
    access: ref.watch(accessControllerProvider)));

final manageStockProvider = Provider<ManageStock>((ref) => ManageStock(
    db: ref.watch(appDatabaseProvider),
    access: ref.watch(accessControllerProvider)));

// --- Read models ------------------------------------------------------------

/// A monotonically-changing token; bump it (via [ledgerRefreshProvider.notifier])
/// after any mutation to re-run derived read providers. Drift streams can replace
/// this later, but this keeps derived numbers correct without staleness now.
final ledgerRevisionProvider = StateProvider<int>((ref) => 0);

/// Whether the dashboard P&L is scoped to the month or the quarter (01_PRD.md
/// §4.6). Only the P&L/chart react to this — position figures are always "now".
final dashboardScopeProvider =
    StateProvider<PeriodScope>((ref) => PeriodScope.month);

/// The dashboard summary for the current period (month or quarter per
/// [dashboardScopeProvider]). Recomputes whenever the ledger revision bumps.
final dashboardSummaryProvider =
    FutureProvider.autoDispose<DashboardSummary>((ref) async {
  ref.watch(ledgerRevisionProvider);
  final scope = ref.watch(dashboardScopeProvider);
  final db = ref.watch(appDatabaseProvider);
  return ComputeDashboardSummary(db).call(scope: scope);
});

/// The trailing profit series (last 6 periods) behind the bar chart, in the
/// current scope. Recomputes on ledger-revision bumps and scope changes.
final profitSeriesProvider =
    FutureProvider.autoDispose<List<PeriodProfit>>((ref) async {
  ref.watch(ledgerRevisionProvider);
  final scope = ref.watch(dashboardScopeProvider);
  final db = ref.watch(appDatabaseProvider);
  return ComputeDashboardSummary(db).profitSeries(scope: scope, count: 6);
});

/// Identifies one drill-down period (a tapped bar or the current period card).
typedef PeriodKey = ({int year, int month, PeriodScope scope});

/// Full summary for a specific period, so tapping a chart bar or the profit card
/// opens that exact month/quarter. Recomputes on ledger-revision bumps.
final periodDetailProvider = FutureProvider.autoDispose
    .family<DashboardSummary, PeriodKey>((ref, key) async {
  ref.watch(ledgerRevisionProvider);
  final db = ref.watch(appDatabaseProvider);
  return ComputeDashboardSummary(db)
      .call(year: key.year, month: key.month, scope: key.scope);
});

/// Per-pool balances (Home/Bank/Godam), derived from cash movements. Recomputes
/// on ledger revision bumps.
final poolBalancesProvider =
    FutureProvider.autoDispose<List<({PoolNameDb name, int balancePaisa})>>(
        (ref) async {
  ref.watch(ledgerRevisionProvider);
  final db = ref.watch(appDatabaseProvider);
  final result = <({PoolNameDb name, int balancePaisa})>[];
  for (final name in PoolNameDb.values) {
    final pool = await db.poolByName(name);
    result.add((name: name, balancePaisa: await db.poolBalancePaisa(pool.id)));
  }
  return result;
});

/// Call after any successful mutation so derived read providers refresh.
void bumpLedger(WidgetRef ref) {
  ref.read(ledgerRevisionProvider.notifier).update((v) => v + 1);
}

/// Non-widget variant (e.g. from a Notifier) — takes a [Ref].
void bumpLedgerRef(Ref ref) {
  ref.read(ledgerRevisionProvider.notifier).update((v) => v + 1);
}

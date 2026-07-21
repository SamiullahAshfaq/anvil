import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:uuid/uuid.dart';

import 'tables.dart';

part 'database.g.dart';

const _uuid = Uuid();

@DriftDatabase(tables: [
  Parties,
  StockCategories,
  ExpenseCategories,
  Bills,
  BillLineItems,
  Payments,
  PaymentAllocations,
  CashPools,
  CashMovements,
  StockWriteOffs,
  UpdateHistories,
  TrashRecords,
  DayZeroMigrations,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// In-memory database for tests — no file, no vaulting.
  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedDefaults();
        },
        onUpgrade: (m, from, to) async {
          // Pre-migration vaulting runs in the connection opener *before* the
          // database is opened for upgrade (see connection.dart / DbVault), so
          // by the time this executes a timestamped copy of the pre-upgrade file
          // already exists and can be restored on failure. Future migration
          // steps go here, guarded by from/to.
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Seeds the fixed-but-extendable defaults: the three cash pools, the three
  /// seed stock categories, and the seed expense categories (incl. the reserved
  /// "Wastage" category). These are seeds, not a ceiling (03_RULES.md §2.9).
  Future<void> _seedDefaults() async {
    final now = DateTime.now();
    await batch((b) {
      b.insertAll(cashPools, [
        for (final p in PoolNameDb.values)
          CashPoolsCompanion.insert(id: _uuid.v4(), name: p),
      ]);
      b.insertAll(stockCategories, [
        for (final name in const ['Bura', 'Degi Bura', 'Scrap'])
          StockCategoriesCompanion.insert(
            id: _uuid.v4(),
            name: name,
            createdAt: now,
          ),
      ]);
      b.insertAll(expenseCategories, [
        for (final name in const [
          'Salaries',
          'Food',
          'Electricity',
          'Rent',
          'Wastage',
          'Other',
        ])
          ExpenseCategoriesCompanion.insert(id: _uuid.v4(), name: name),
      ]);
    });
  }
}

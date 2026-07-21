/// Drift table definitions. Global schema rules (02_ARCHITECTURE.md §6):
///  - Every PK/FK is a **UUIDv4 string**, generated client-side. Never an
///    auto-increment integer.
///  - All currency is integer **Paisa**; all weight integer **Grams**; all rates
///    integer **Paisa per kg**. No `double`/`float` columns anywhere.
///  - Balances/quantities that could be derived are either derived on read or
///    maintained *only* inside a use-case transaction — never user-editable.
///
/// Persistence enums are kept local to the data layer; use-cases map them to/from
/// domain enums at the boundary.
library;

import 'package:drift/drift.dart';

enum PartyTypeDb { supplier, buyer, both }

enum BillTypeDb { purchase, sale, expense }

enum RateModeDb { perBill, perLine }

enum PaymentDirectionDb { received, paid }

enum CashDirectionDb { moneyIn, moneyOut }

enum WriteOffModeDb { absorbIntoRemaining, expenseWastage }

enum PoolNameDb { home, bank, godam }

class Parties extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => textEnum<PartyTypeDb>()();
  TextColumn get phone => text().nullable()();

  /// Onboarding dues are recorded as real dated OpeningBalance bills, not here —
  /// this stays for reference only and is never treated as an authoritative
  /// balance (03_RULES.md §1.26). Balances are always derived.
  IntColumn get openingBalancePaisa => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Parent-category rows (parentCategoryId = null) are the ONLY rows that carry
/// quantity/cost. Sub-categories are free-text tags on [BillLineItems] and never
/// get a row here (03_RULES.md §1.16).
///
/// Deviation from 02_ARCHITECTURE.md §6, deliberately: we store
/// `totalCostBasisPaisa` (integer) rather than an `avgCostPaisaPerGram` column,
/// because a per-gram average is not integer-representable for common rates and
/// the spec forbids floats. avgCost is derived on read (see StockPosition).
class StockCategories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  TextColumn get parentCategoryId =>
      text().nullable().references(StockCategories, #id)();
  IntColumn get quantityGrams => integer().withDefault(const Constant(0))();
  IntColumn get totalCostBasisPaisa =>
      integer().withDefault(const Constant(0))();

  /// Whole-number target margin % for the recommended selling rate. Editable.
  IntColumn get targetMarginPct => integer().withDefault(const Constant(5))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ExpenseCategories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Bills extends Table {
  TextColumn get id => text()();
  TextColumn get type => textEnum<BillTypeDb>()();
  TextColumn get partyId => text().nullable().references(Parties, #id)();
  TextColumn get expenseCategoryId =>
      text().nullable().references(ExpenseCategories, #id)();
  DateTimeColumn get date => dateTime()();
  TextColumn get photoPath => text().nullable()(); // local-only, never synced
  TextColumn get rateMode => textEnum<RateModeDb>()();
  IntColumn get billLevelRatePaisaPerKg => integer().nullable()();
  IntColumn get totalAmountPaisa => integer()();

  /// True for Day-0 opening bills. They seed standing receivable/payable and
  /// stock, but must be excluded from period P&L (they are pre-app history, not
  /// sales/purchases of any reporting month).
  BoolColumn get isOpening => boolean().withDefault(const Constant(false))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class BillLineItems extends Table {
  TextColumn get id => text()();
  TextColumn get billId => text().references(Bills, #id)();
  TextColumn get parentCategoryId => text().references(StockCategories, #id)();

  /// Descriptive tag only — filtering/reporting. Never a separate stock ledger.
  TextColumn get subCategoryLabel => text().nullable()();
  IntColumn get weightGrams => integer()();
  IntColumn get ratePaisaPerKg => integer()();
  IntColumn get lineTotalPaisa => integer()();

  /// COGS at the moving-average cost at the moment of a SALE line, for profit.
  /// Null on purchase lines.
  IntColumn get cogsPaisa => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get partyId => text().references(Parties, #id)();
  IntColumn get amountPaisa => integer()();
  TextColumn get direction => textEnum<PaymentDirectionDb>()();
  TextColumn get poolId => text().references(CashPools, #id)();
  DateTimeColumn get date => dateTime()();
  BoolColumn get isAdvance => boolean().withDefault(const Constant(false))();

  /// Reversed (bounced/failed) payments are flagged, NEVER deleted
  /// (03_RULES.md §1.24).
  BoolColumn get reversed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get reversedAt => dateTime().nullable()();
  TextColumn get reversalReason => text().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Manual many-to-many allocation of a payment against bills. Allocating an
/// existing advance to a new bill inserts a row HERE ONLY — never a second
/// CashMovement (03_RULES.md §1.20; the cash already moved).
class PaymentAllocations extends Table {
  TextColumn get id => text()();
  TextColumn get paymentId => text().references(Payments, #id)();
  TextColumn get billId => text().references(Bills, #id)();
  IntColumn get amountAllocatedPaisa => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class CashPools extends Table {
  TextColumn get id => text()();
  TextColumn get name => textEnum<PoolNameDb>()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Pool balance is ALWAYS derived by summing these rows — never a stored column.
/// A Home→Godam transfer is one OUT (home) + one IN (godam) sharing [transferId]
/// and cross-referencing via [pairedMovementId]. Godam FIFO trace is computed
/// dynamically at read time from these rows (03_RULES.md §1.21).
class CashMovements extends Table {
  TextColumn get id => text()();
  TextColumn get poolId => text().references(CashPools, #id)();
  TextColumn get direction => textEnum<CashDirectionDb>()();
  IntColumn get amountPaisa => integer()();
  DateTimeColumn get date => dateTime()();

  /// Tiebreaker for same-instant ordering, so FIFO consumption is deterministic.
  IntColumn get sequence => integer().withDefault(const Constant(0))();
  TextColumn get transferId => text().nullable()();
  TextColumn get pairedMovementId => text().nullable()();
  TextColumn get relatedBillId => text().nullable().references(Bills, #id)();
  TextColumn get relatedPaymentId =>
      text().nullable().references(Payments, #id)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class StockWriteOffs extends Table {
  TextColumn get id => text()();
  TextColumn get parentCategoryId => text().references(StockCategories, #id)();
  IntColumn get weightGrams => integer()();
  TextColumn get mode => textEnum<WriteOffModeDb>()();
  TextColumn get relatedExpenseCategoryId =>
      text().nullable().references(ExpenseCategories, #id)();

  /// For expenseWastage mode: the Paisa expensed to the P&L (weight × avg cost).
  IntColumn get expensePaisa => integer().withDefault(const Constant(0))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class UpdateHistories extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get fieldChanged => text()();
  TextColumn get oldValue => text().nullable()();
  TextColumn get newValue => text().nullable()();
  DateTimeColumn get changedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class TrashRecords extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  DateTimeColumn get deletedAt => dateTime()();
  DateTimeColumn get purgeAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class DayZeroMigrations extends Table {
  TextColumn get id => text()();
  DateTimeColumn get performedAt => dateTime()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

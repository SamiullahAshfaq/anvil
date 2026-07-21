# Architecture

## 1. App Flow (User-Level)

```
Launch
  └─▶ PIN unlock (Admin or View) ── first run: Onboarding (business name, Admin PIN, optional View PIN)
        └─▶ Home / Dashboard
              ├─▶ Drawer: Dashboard · Parties · Bills · Stock · Cash & Godam
              │           · Expenses · Trash · Backup & Sync · Settings (theme) · Lock
              │
              ├─▶ Parties ──▶ Party Detail ──▶ [Bill history | Payment history | New Payment | New Bill (prefilled party)]
              │
              ├─▶ Bills ──▶ New Bill (type switch: Purchase / Sale / Expense)
              │                 └─▶ Save ──▶ Receipt view ──▶ Share (WhatsApp/native)
              │
              ├─▶ Stock ──▶ Category Detail ──▶ Stock Ledger (chronological, running balance)
              │
              ├─▶ Cash & Godam ──▶ Transfer to Godam ──▶ Godam Ledger ──▶ Spend Trace (tap a spend → source transfer)
              │
              ├─▶ Trash ──▶ Restore / Auto-purge countdown
              │
              └─▶ Backup & Sync ──▶ Manual backup / Pairing / Last synced status
```

**Key flow principle**: "New Bill" is ONE entry point with a type switch, not three separate flows the user has to choose between before they've even started. This mirrors how the owner actually thinks ("something just happened, let me log it").

## 2. Architecture Pattern

**Layered, offline-first, single source of truth locally.**

```
┌─────────────────────────────────────────────┐
│  Presentation (Flutter widgets)              │  ← screens, stateless where possible
├─────────────────────────────────────────────┤
│  State Management (Riverpod)                 │  ← providers per feature, no business logic here
├─────────────────────────────────────────────┤
│  Domain / Use Cases (plain Dart)             │  ← "recordPurchase()", "allocatePayment()" etc.
│  ★ ALL financial correctness logic lives here │     — atomic, transactional, testable in isolation
├─────────────────────────────────────────────┤
│  Repository layer                            │  ← abstracts local DB + sync, one repo per aggregate
├─────────────────────────────────────────────┤
│  Local DB (Drift/SQLite) ── Sync (Supabase)  │  ← local is truth; Supabase is backup mirror only
└─────────────────────────────────────────────┘
```

**Why this shape fixes the original failure**: the first build put "trigger→Dart port invariants" logic somewhere ad hoc (likely scattered in repositories or UI callbacks). Business rules — moving-average cost recalculation, party balance derivation, Godam FIFO trace — must live in ONE domain layer, called by use-cases, covered by unit tests that don't touch the UI or DB at all (pure logic tests on in-memory fixtures). This is the single biggest change from the current codebase.

## 3. Data Flow for a Purchase Bill (concrete example, because this is where correctness lives)

```
User submits Purchase Bill (party, line items[], optional advance payment)
        │
        ▼
domain.recordPurchase(bill)
        │
        ├─▶ 1. Insert Bill + BillLineItems (immutable once saved; edits create a new version + history entry)
        ├─▶ 2. For each line item (subCategory is a descriptive tag only — cost/qty math is always at parent category):
        │        └─▶ stockService.applyPurchase(parentCategory, subCategoryTag, weightGrams, rateInPaisaPerUnit)
        │                → if oldQty <= 0: newAvgCost = rate  (ZERO/NEGATIVE STOCK RESET — do not blend across this boundary)
        │                → else: newAvgCost = ((oldQty × oldAvgCost) + (weight × rate)) / (oldQty + weight)
        │                → update StockCategory.quantityGrams += weightGrams, avgCostPaisa = newAvgCost
        │                → all arithmetic in integer grams / integer paisa, no floating point
        ├─▶ 3. ledgerService.postPartyEntry(party, type=PAYABLE, amount=billTotal)
        ├─▶ 4. if advancePaid > 0:
        │        └─▶ cashService.withdraw(pool, advancePaid) 
        │        └─▶ ledgerService.postPayment(party, advancePaid, allocatedBillId=this bill)
        └─▶ 5. All of 1–4 run inside a SINGLE DB transaction. Any failure rolls back everything.
```

This same "one domain call → one DB transaction touching N tables" pattern applies to Sale, Expense, Payment, Godam Transfer, **Stock Write-Off/Wastage**, and **Payment Reversal**. **No screen should ever write directly to more than one table without going through a domain use-case.**

**Stock Write-Off (wastage) flow**: `stockService.applyWriteOff(parentCategory, weightGrams, mode)` — if `mode = absorbIntoRemaining`, quantity decreases and avgCost is recalculated so total value is preserved across the smaller quantity (`newAvgCost = (oldQty × oldAvgCost) / (oldQty − writeOffQty)`); if `mode = expenseWastage`, quantity decreases, avgCost is untouched, and a Wastage expense line is posted to the P&L for `writeOffQty × oldAvgCost`. Either way this never touches revenue or party balances.

**Payment Reversal flow**: `paymentService.reversePayment(paymentId, reason)` — inside one transaction: (1) delete/zero the `PaymentAllocation` rows tied to that payment (bills return to their prior open balance, derived automatically since balances are computed, not stored), (2) insert a new offsetting `CashMovement` reversing the pool balance, (3) write a permanent `UpdateHistory`/ledger note on the party record with the reason and timestamp, (4) the original `Payment` row is never deleted — it's marked `reversed = true, reversedAt, reversalReason`, remaining fully visible in history.

**Cash overdraft check**: any use-case that withdraws from a `CashPool` (Sale advance, Purchase payment, Expense, Godam spend) computes the resulting pool balance *before* committing. If it would go negative, the use-case returns a `needsConfirmation` result (see Rules doc — this is a warning, never a blocking exception) so the UI can show the calm overdraft prompt with "Record Transfer Now" / "Continue Anyway."

## 4. Folder Structure

```
lib/
├── main.dart
├── app.dart                          # MaterialApp, theme, routing root
│
├── core/
│   ├── theme/                        # light/dark ThemeData, typography (Inter + JetBrains Mono)
│   ├── constants/                    # default categories, PIN length, trash retention days
│   ├── errors/                       # AppException hierarchy, calm-error mapping to user copy
│   └── utils/                        # date helpers, currency/weight formatters (kg↔ton)
│
├── data/
│   ├── local/
│   │   ├── database.dart             # Drift database definition
│   │   ├── tables/                   # one file per table (see architecture §6)
│   │   └── daos/                     # one DAO per aggregate (PartyDao, BillDao, StockDao, CashDao...)
│   ├── sync/
│   │   ├── supabase_client.dart
│   │   ├── sync_service.dart         # push/pull, conflict = last-write-wins on record-level timestamp
│   │   └── sync_payload_mapper.dart  # strips photo paths before upload
│   └── repositories/
│       ├── party_repository.dart
│       ├── bill_repository.dart
│       ├── stock_repository.dart
│       ├── cash_repository.dart
│       ├── payment_repository.dart
│       └── trash_repository.dart
│
├── domain/
│   ├── entities/                     # pure Dart models, no Drift/DB annotations
│   ├── use_cases/
│   │   ├── record_purchase.dart
│   │   ├── record_sale.dart
│   │   ├── record_expense.dart
│   │   ├── allocate_payment.dart
│   │   ├── reverse_payment.dart          # bounced cheque / failed transfer flow
│   │   ├── transfer_to_godam.dart
│   │   ├── write_off_stock.dart          # wastage/shrinkage, absorb-or-expense modes
│   │   ├── restore_from_trash.dart
│   │   ├── run_day_zero_migration.dart   # onboarding: opening balances/cash/stock as real ledger entries
│   │   └── compute_dashboard_summary.dart
│   └── services/
│       ├── stock_costing_service.dart    # moving-average math incl. zero-stock reset rule, isolated & heavily unit-tested
│       ├── ledger_service.dart           # party balance derivation
│       ├── cash_trace_service.dart       # dynamic FIFO Godam funding trace, sorted chronologically at query time
│       ├── cash_overdraft_service.dart   # pre-commit negative-balance check → needsConfirmation result
│       └── recommended_rate_service.dart
│
├── presentation/
│   ├── onboarding/
│   ├── home_dashboard/
│   ├── parties/
│   ├── bills/                        # new_bill_screen.dart with type switch, receipt_screen.dart
│   ├── stock/
│   ├── cash_godam/
│   ├── trash/
│   ├── backup_sync/
│   └── shared_widgets/               # pill_button, calm_error_banner, amount_text, hairline_divider
│
├── sharing/
│   ├── receipt_image_generator.dart  # renders bill → branded PNG
│   └── summary_generator.dart        # day/week/month digest → image or text
│
└── security/
    ├── pin_service.dart              # hashed PIN storage (local, e.g. flutter_secure_storage)
    └── access_mode.dart              # Admin vs View mode — see enforcement rule below

  -- ENFORCEMENT RULE: Admin-vs-View gating must be checked inside every mutating use-case
  -- function itself (domain layer), throwing UnauthorizedException if the current mode is
  -- View-only. Hiding/disabling buttons in the UI is necessary for good UX but is NOT the
  -- security boundary — it's advisory only. The real boundary is: a use-case that writes
  -- data checks access_mode.dart's current state before doing anything, every time, so a
  -- future screen that forgets to hide a button can never actually mutate data in View mode.

test/
├── domain/                           # pure logic tests — the majority of test investment
│   ├── stock_costing_service_test.dart
│   ├── ledger_service_test.dart
│   └── cash_trace_service_test.dart
├── data/                             # DAO + repository tests against in-memory Drift DB
└── widget/                           # key flow smoke tests (new bill, dashboard render)
```

## 5. Tech Stack

| Layer | Choice | Why |
|---|---|---|
| Framework | Flutter (Dart) | Matches existing build; single codebase, good offline story, APK target confirmed |
| Local DB | **Drift** (SQLite) | Type-safe, transactional, reactive streams for UI — critical for "balance always derived, never stale" |
| State mgmt | **Riverpod** | Testable providers, clean DI for repositories/use-cases without a service locator mess |
| Backup/Sync | **Supabase** (Postgres + Storage metadata only, no photo upload) | Already chosen in original brief; used strictly as backup mirror, not live sync target |
| Local secure storage | `flutter_secure_storage` | PIN hash storage |
| Charts | `fl_chart` | Accessible color config is achievable and it's lightweight vs alternatives |
| Image/receipt generation | `screenshot` or custom `CustomPainter` → PNG | For branded shareable receipts |
| Sharing | `share_plus` | Native share sheet → WhatsApp etc. |
| PDF (optional, if month-summary-as-PDF wanted later) | `pdf` package | v2 candidate, not required for v1 |
| Testing | `flutter_test`, `mocktail` | Domain-layer tests are the priority, not widget-test coverage percentage |
| CI | GitHub Actions | Already present in original — keep: analyze → test → build APK |

## 6. Core Schema (conceptual — not exhaustive DDL)

**Global schema rules, applying to every table below:**
- **All primary keys and foreign keys are UUIDv4 strings**, not auto-incrementing integers. This is mandatory because Supabase restores, device re-pairing, and any future multi-device migration can collide or reorder auto-increment IDs; UUIDs generated client-side are collision-safe by construction.
- **All currency fields are stored as integers in Paisa** (e.g. Rs. 50,000.50 → `5000050`). **All weight fields are stored as integers in Grams** (e.g. 2.5 tons → `2500000`). No `double`/`float` currency or weight fields anywhere in the schema. The UI layer converts to Rupees/kg/ton only at the point of display, using integer division/formatting helpers in `core/utils/` — never storing or persisting the converted decimal.
- **Bill edits are in-place, transactional updates** — not new immutable row versions. An edit to a `Bill` or `BillLineItem` updates the existing row inside a transaction and **mandatorily** writes a corresponding `UpdateHistory` row (old value → new value, per changed field) in the same transaction. Immutability of *history* is achieved via the `UpdateHistory` log, not by forking rows.

```
Party(id UUID, name, type[supplier|buyer|both], phone, openingBalancePaisa, createdAt, deletedAt)

StockCategory(id UUID, name, isCustom, parentCategoryId UUID?, quantityGrams, avgCostPaisaPerGram, targetMarginPct)
  -- quantityGrams/avgCostPaisaPerGram exist ONLY at parent-category rows (parentCategoryId = null).
  -- Rows with a parentCategoryId set are informational metadata only if pre-registered — but
  -- in practice most sub-category tags are free-text on BillLineItem.subCategoryLabel and never
  -- need a StockCategory row of their own. Costing math NEVER reads/writes a child row's own qty/cost.
  -- avgCost = MOVING AVERAGE of unsold stock only. Sales reduce quantityGrams, using avgCost as COGS,
  -- and never modify avgCost. On purchase, if quantityGrams <= 0 before this purchase, avgCost is
  -- RESET to this purchase's rate (no blended average across a zero/negative crossing).

Bill(id UUID, type[purchase|sale|expense], partyId UUID?, expenseCategoryId UUID?, date, photoPath?,
     rateMode[perBill|perLine], billLevelRatePaisaPerGram?, totalAmountPaisa,
     createdAt, updatedAt, deletedAt)
  -- edited in-place; every field change logged to UpdateHistory in the same transaction

BillLineItem(id UUID, billId UUID, parentCategoryId UUID, subCategoryLabel TEXT?,
             weightGrams, ratePaisaPerGram, lineTotalPaisa)
  -- subCategoryLabel is a plain descriptive tag, used for filtering/reporting only;
  -- it never carries its own stock quantity or cost

Payment(id UUID, partyId UUID, amountPaisa, direction[received|paid], poolId UUID, date,
        isAdvance BOOLEAN, reversed BOOLEAN DEFAULT false, reversedAt?, reversalReason?, deletedAt)
  -- reversed payments are never deleted — flagged in place, fully visible in history

PaymentAllocation(id UUID, paymentId UUID, billId UUID, amountAllocatedPaisa)
  -- many-to-many join; manual allocation only (no auto-FIFO).
  -- Allocating an EXISTING advance-payment balance to a new bill inserts a PaymentAllocation
  -- row ONLY — it must NEVER also create a new CashMovement, since the cash already moved
  -- when the original advance Payment was recorded. Double-counting cash here is a critical bug class.

CashPool(id UUID, name[home|bank|godam])
  -- balance is ALWAYS derived by summing CashMovement rows for this pool — never a stored/authoritative column

CashMovement(id UUID, poolId UUID, direction[in|out], amountPaisa, transferId UUID?,
             pairedMovementId UUID?, relatedBillId UUID?, relatedPaymentId UUID?, date)
  -- a Home→Godam transfer = one OUT movement (home) + one IN movement (godam),
  -- both sharing the same transferId and cross-referenced via pairedMovementId.
  -- Godam spend traceability (cash_trace_service.dart) is computed DYNAMICALLY at query time:
  -- sort this pool's incoming transfer movements chronologically, walk outgoing spend movements
  -- oldest-transfer-first, consuming balance — this is a read-time calculation over CashMovement,
  -- NOT a separately maintained/stored allocation table, so it can never drift out of sync.

ExpenseCategory(id UUID, name, isCustom)
  -- includes a reserved "Wastage" category for stock write-offs logged in expenseWastage mode

StockWriteOff(id UUID, parentCategoryId UUID, weightGrams, mode[absorbIntoRemaining|expenseWastage],
              relatedExpenseCategoryId UUID?, note?, date, deletedAt)
  -- absorbIntoRemaining: no cash/expense impact, StockCategory.avgCostPaisaPerGram recalculated
  -- expenseWastage: quantity drops, avgCost untouched, and a synthetic expense of
  --   (weightGrams × avgCostPaisaPerGram at time of write-off) is posted to P&L

UpdateHistory(id UUID, entityType, entityId UUID, fieldChanged, oldValue, newValue, changedAt)

TrashRecord(id UUID, entityType, entityId UUID, deletedAt, purgeAt)

DayZeroMigration(id UUID, performedAt, note?)
  -- marker record for onboarding; the actual opening values are real dated entries:
  -- an opening Bill (or dedicated OpeningBalance bill type) per party, an opening CashMovement
  -- per pool, and an opening StockWriteOff-style seed entry (or a dedicated opening purchase)
  -- per stock category — never a raw editable "starting balance" field on Party/CashPool/StockCategory
```

**Non-negotiable invariant**: `Party` balance, `CashPool` balance, and `StockCategory` quantity/cost totals are **never** directly editable fields in the UI — they are either computed on read from the movement/ledger tables, or updated exclusively inside a use-case transaction. If a future screen needs a "quick balance edit," that's a smell — it means an opening-balance or adjustment *entry* is missing (see `DayZeroMigration` / `StockWriteOff`), not that the derived field should become writable.

## 7. Migration Safety

Because local SQLite/Drift is the **primary source of truth** (Supabase is backup-only), a corrupted or failed schema migration on a future app update is a total-data-loss risk with no live remote fallback to lean on. Mandatory safeguard:

**Pre-Migration Vaulting**: before Drift executes any `onUpgrade` schema migration step, the app automatically copies the current database file (e.g. `db.sqlite`) to a timestamped vault file (e.g. `db_vault_pre_upgrade_<version>_<timestamp>.sqlite`) in local app storage. If the migration throws or is detected as incomplete, the app restores from the vault file and surfaces a calm message rather than proceeding on a partially-migrated schema. Keep at minimum the most recent vault; consider retaining the last 2–3 across app versions given local storage is cheap relative to the cost of losing a live business's ledger.

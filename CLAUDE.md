# CLAUDE.md — Anvil / Godam Ledger

Offline-first ledger + cost-accounting Flutter app for a scrap/raw-material
trading business. **The financial core is the product** — if the numbers are
wrong, the app has failed regardless of how it looks.

## Read first (the spec is authoritative, not this file)
- `01_PRD.md` — what the app is, feature by feature.
- `02_ARCHITECTURE.md` — layers, schema (§6), data-flow-per-use-case (§3).
- `03_RULES.md` — the guardrails; **read before writing any use-case**.
- `04_PHASES.md` — build order; correctness gates progression, not screen count.
- `05_MEMORY.md` — confirmed business decisions (do not re-litigate).
- `06_DESIGN_SYSTEM.md` + `Godam Ledger.dc.html` — the actual UI reference.

## Non-negotiable invariants (mirror of 05_MEMORY.md)
- **Integer money/weight only.** Currency = integer **Paisa**, weight = integer
  **Grams**, rates = integer **Paisa per kg**. No `double`/`float` in the domain
  or DB — convert to display units only at the UI boundary (`core/utils/`).
- **Derive, don't store.** Party balances, cash pool balances, stock qty/cost are
  computed from ledger/movement rows — never directly-editable fields.
- **One business event = one use-case = one DB transaction.** No screen writes to
  two tables directly.
- **Moving-average costing at the parent category only.** Sub-category labels are
  descriptive tags — they never carry their own quantity or cost. On purchase into
  empty/negative stock, avgCost **resets** to the new rate (never blend across a
  zero/negative crossing).
- **UUIDv4 keys** everywhere, client-generated.
- Domain logic lives in `lib/domain/` and is unit-tested with plain fixtures,
  independent of UI and DB, **before** any screen.

## Current state (Phase 0–4 done) — 57 tests passing
Run `flutter test` (all green) and `flutter analyze lib test` (clean).
SDK note: the Flutter install path and version are **machine-specific** — this
repo has been worked on from more than one machine, and the SDK path/version
under §Commands below reflects whichever machine last confirmed it. Always
verify locally (`which flutter`, `flutter --version`) rather than assuming the
documented path is current for the machine you're on.

**Phase 4 — Dashboard & Analytics, DONE (built over Phase-1 `compute_dashboard_summary`):**
- Use-case: `compute_dashboard_summary.dart` gained a `scope` param (month/quarter
  via static `periodBounds`), a `profitSeries({scope, count, anchor})` bucketer
  (loads bills/line-items/write-offs once; profit = revenue − COGS − (cash +
  wastage expense), Day-0 opening bills excluded — same math as the month view),
  and two drill-down ids on the result. `DashboardSummary` (entity) now carries
  `scope`/`periodStart`/`periodEnd`, `biggestExpenseBillId`,
  `largestReceivablePartyId`, plus the new `PeriodScope` enum + `PeriodProfit`.
- Providers (`app/providers.dart`): `dashboardScopeProvider` (StateProvider),
  `profitSeriesProvider`, `periodDetailProvider.family<DashboardSummary, PeriodKey>`
  (`PeriodKey = ({int year, int month, PeriodScope scope})`); `dashboardSummary
  Provider` watches the scope. All recompute on `ledgerRevisionProvider`.
- Screens (`presentation/home_dashboard/`): `profit_chart.dart` (`ProfitChart` —
  `fl_chart 1.2.0` `BarChart`; blue-profit / red-loss bars WITH text value labels
  + tooltip so colour is never the sole channel; tap a bar → period drill-down),
  `period_detail_screen.dart` (a period's revenue/COGS/expense + the sale/expense
  bills that compose it, each → Bill Detail), `receivables_screen.dart` (two
  never-netted tabs, parties top-first → Party Detail). `dashboard_screen.dart`
  rebuilt: Month/Quarter `SegmentedPills`, the chart card, and every figure made
  tappable (net-worth Cash/Stock chips → Cash/Stock, profit → period detail,
  receivable/payable → receivables, plain-terms → stock ledger / bill / party).
- `fl_chart 1.x` API notes: `getTooltipColor` (not `tooltipBgColor`),
  `SideTitleWidget(meta:…, child:…)`, `getTitlesWidget: (value, meta) => …`.
- Tests: `test/data/profit_series_test.dart` (two months → per-month bars, the Q3
  quarterly total, and the drill-down ids), plus a chart/scope-toggle case added
  to `test/widget/dashboard_screen_test.dart`.
- Deferred to Phase 5: Supabase backup/sync, in-place bill *field* editing,
  summary-image share, and a formal light/dark chart contrast re-check.

**Phase 3 — Cash & Godam + Payments UI, DONE (built over the Phase-1 use-cases):**
- Read layer: `data/local/cash_read_queries.dart` + `app/cash_read_providers.dart`
  — resolves `CashMovement` rows into labelled `CashLedgerEntry`s, computes the
  Godam FIFO spend-trace at read time (`CashTraceService`), and exposes
  open-bills-per-party, unallocated-advances, and reconciliation; all recompute on
  `ledgerRevisionProvider`.
- Screens (`presentation/cash_godam/`): `cash_screen` (total-cash card + pool cards
  + reconciliation), `transfer_sheet` (Home/Bank→Godam, overdraft round-trip),
  `godam_ledger_screen` (spend → "where this came from" FIFO sheet + View bill),
  `roznamcha_screen` (day-grouped, per-day net + running balance, filters:
  pool/direction/party/expense-category/date-range), `cash_entry_tile` (shared).
- Screens (`presentation/payments/`): `new_payment_screen` (standalone payment +
  manual allocation against open bills of the matching kind; remainder = advance),
  `allocate_advance_screen` (place an existing advance via `AllocatePayment` —
  PaymentAllocation only, no duplicate CashMovement), `reverse_payment_sheet`
  (non-destructive bounce flow, from the Party Detail settlement timeline).
- Wiring: "Cash & Godam" drawer destination; Party Detail overflow menu (Record
  payment / Allocate advance / Edit / Trash) and tap-to-reverse on payment rows.
- Tests: `test/data/cash_read_test.dart` (Godam spend traced to two funding
  transfers oldest-first + reconciliation; bounced-cheque reopens the bill in the
  read model). Also fixed a pre-existing Flutter-3.44 `ListTile`-in-`Container`
  assertion by wrapping the party/category picker lists in a transparent `Material`.
- (The fl_chart profit chart + dashboard drill-downs were completed in Phase 4;
  still deferred to Phase 5: in-place bill *field* editing, Supabase backup/sync.)

**Phase 2 — daily-use UI, DONE (built on the Phase-1 domain core):**
- Auth/gate: `security/pin_service.dart` (Admin + optional View PIN, deterministic
  salted-FNV hash in `flutter_secure_storage`; `InMemoryPinService` for tests),
  `app/app.dart` `_AppRoot` (onboarding → PIN lock → shell), `accessModeProvider` +
  `sessionUnlockedProvider`. View-mode both hides mutating controls AND is enforced
  in every use-case (`ensureCanMutate`).
- Read layer: `data/local/read_queries.dart` + `app/read_providers.dart` — party
  balances (via `LedgerService`), stock positions/recommended rate, bills w/
  paid-status + `billIsPending`, party detail, bill view, trash view, cash pools.
  All recompute on `ledgerRevisionProvider`; nothing stored.
- New use-cases: `manage_party.dart` (create + edit→`UpdateHistory`),
  `manage_stock.dart` (inline custom category + target margin), `manage_trash.dart`
  (soft-delete + restore, Bills/Parties). **`data/local/stock_rebuild.dart`** —
  `rebuildCategoryStock` replays the surviving ledger (purchase/sale lines +
  write-offs, chronological) to keep stored qty/cost exact across a delete/restore
  (never an approximate inverse of the moving-average).
- Screens (`presentation/`): `onboarding/` (onboarding_screen, pin_screen, pin_pad,
  day_zero_screen), `parties/` (parties_screen, party_detail_screen w/ Settlement +
  History tabs, new_party_sheet w/ picker + edit), `bills/` (new_bill_screen —
  one surface, 3 types, rate toggle, inline sub-category, category_picker;
  bills_screen w/ Pending filter; bill_detail_screen w/ image receipt share),
  `stock/` (stock_screen, stock_ledger_screen w/ sub-tag filter, write_off_sheet),
  `trash/trash_screen.dart`.
- Shared widgets: `pill_button`, `calm_sheet` (showCalmConfirm/showWarningsSheet/
  showCalmError/showCalmInfo), `form_fields` (AppTextField, SegmentedPills),
  `use_case_runner` (`runWithConfirm`/`confirmAndRun` drive the `NeedsConfirmation`
  round-trip), `core/errors/error_copy.dart` (single calm-copy map),
  `core/utils/date_format.dart`.
- Tests added: `test/data/trash_test.dart` (hand-traced delete/restore stock
  rebuild + party-guard + View-mode block), `test/widget/new_bill_flow_test.dart`.
- Deferred to Phase 3: standalone payment-recording + manual-allocation UI,
  Payment-Reversal UI, Cash & Godam + Roznamcha screens, in-place bill *field*
  editing (a mistaken bill is corrected via Trash + re-enter today).

**Phase 2 — earlier UI foundation + Dashboard:**
- `lib/core/theme/` — `app_colors.dart` (`AppColors` ThemeExtension, light/dark
  tokens; Coinbase Blue only accent; `AppRadius`; `context.c` accessor),
  `app_theme.dart` (Inter UI / JetBrains Mono figures via `monoStyle`; fonts fall
  back until TTFs are bundled).
- `lib/app/providers.dart` — Riverpod DI: `appDatabaseProvider` (overridden in
  main / tests), `accessControllerProvider`, one provider per use-case,
  `dashboardSummaryProvider` + `poolBalancesProvider` (FutureProvider.autoDispose,
  recompute on `ledgerRevisionProvider` bump — call `bumpLedger(ref)` after any
  mutation). Drift streams can replace the revision token later.
- `lib/app/app.dart` (`GodamLedgerApp`), `app_shell.dart` (drawer nav; only
  Dashboard built, rest are placeholders), `main.dart` (ProviderScope +
  `openAppDatabase` via path_provider).
- `lib/presentation/shared_widgets/` — `AmountText` (mono, semantic tone),
  `AppCard`/`SectionLabel`.
- `lib/presentation/home_dashboard/dashboard_screen.dart` — always-dark net-worth
  card, cash-pool chips, profit card, separate receivable/payable, plain-terms.
- `test/widget/dashboard_screen_test.dart` — renders real derived figures.
- **NOTE**: fonts Inter/JetBrainsMono are named but TTFs not yet bundled (falls
  back to platform). Onboarding/PIN + Day-0 wizard UI not built — app opens
  straight to the shell for now.


**Phase 0 — schema lock + vaulting (done):**
- `lib/data/local/tables.dart` — all 13 tables, UUID PKs, integer Paisa/Grams,
  per-kg rates. StockCategory stores `quantityGrams` + `totalCostBasisPaisa`
  (deviation from the doc's `avgCostPaisaPerGram` — see below).
- `lib/data/local/database.dart` — `AppDatabase` (+ `.memory()` for tests),
  seeds 3 pools / 3 stock cats / 6 expense cats, `PRAGMA foreign_keys=ON`.
  Codegen: `dart run build_runner build` (regenerate after table changes).
- `lib/data/local/connection.dart` — `DbVault` (copy/restore/prune) +
  `openAppDatabase(file)` that vaults before a pending migration and restores on
  failure. Tested at `test/data/vault_test.dart`.

**Phase 1 — use-cases wiring services into transactions (all core done):**
Each use-case is ONE `db.transaction` touching N tables; all math goes through
the pure services; soft warnings return `NeedsConfirmation` (no writes) until
`confirmed: true`; `access.ensureCanMutate()` runs first (View-mode boundary).
- `record_purchase.dart`, `record_sale.dart` — stock + bill + optional cash.
  Insert the **bill before its line items** (FK on billId).
- `record_expense.dart` — expense bill + cash-out; never touches stock.
- `record_payment.dart` — new payment: one cash movement + manual allocations.
- `allocate_payment.dart` — allocate an EXISTING advance to bills; inserts
  `PaymentAllocation` rows ONLY, **never** a second CashMovement (§1.20 guard).
- `reverse_payment.dart` — non-destructive: drop allocations (bills reopen),
  offsetting cash movement, `UpdateHistory` note, flag `reversed` (never delete).
- `transfer_to_godam.dart` — two paired movements (OUT source + IN godam) sharing
  a `transferId`, cross-linked via `pairedMovementId`.
- `write_off_stock.dart` — absorb (cost preserved, avg rises) vs expenseWastage
  (value removed + logged against reserved "Wastage" category).
- `run_day_zero_migration.dart` — onboards a running business: opening party dues
  (dated opening bills, `isOpening=true`, no line items), cash positions (opening
  in-movements), stock baselines (party-less opening purchase via the reset path).
  Runs once. Bills carry an `isOpening` flag so period P&L can exclude them.
- `compute_dashboard_summary.dart` — READ-ONLY (no `ensureCanMutate`; View mode
  can view). Net worth = cash + receivable − payable + stock-at-cost; period P&L
  = revenue − COGS − (cash expenses + wastage), opening bills excluded; best/worst
  margin, biggest expense, largest receivable. Entity: `dashboard_summary.dart`.
- `overdraft_guard.dart` / `data/local/queries.dart` — shared pool-balance +
  overdraft-warning helpers used by every withdrawing use-case.
- `use_case_result.dart` — `Success`/`NeedsConfirmation` + warning types.
- `lib/security/access_mode.dart`, `lib/core/errors/app_exception.dart`.
- Tests: `test/data/use_cases_test.dart` (purchase/sale/oversell/view-mode),
  `test/data/use_cases2_test.dart` (expense, godam transfer + FIFO trace,
  advance-no-double-count, reversal, wastage), `test/data/dashboard_test.dart`
  (hand-traced day-0 + a month; net worth grows by exactly the period profit).
  47 tests total, all green.
- `test/sqlite_loader.dart` — points the host test VM at `libsqlite3.so.0`
  (needed for `flutter test`; on-device `sqlite3_flutter_libs` handles it).

### The domain core (Phase 1, done earlier):
- `lib/core/utils/rounding.dart` — `divRound` (half-away-from-zero), `moneyForWeight`.
- `lib/core/utils/money.dart`, `weight.dart` — display formatting/parsing only.
- `lib/domain/entities/` — `StockPosition`, `party_ledger`, `cash_movement` (pure).
- `lib/domain/services/`:
  - `stock_costing_service.dart` — moving average, zero/negative reset, write-off
    (absorb vs expense). **The most correctness-critical file.**
  - `ledger_service.dart` — party balance derivation, receivable/payable kept
    separate, reversal-aware.
  - `cash_trace_service.dart` — dynamic Godam FIFO spend trace (read-time, no
    stored allocation table).
  - `cash_overdraft_service.dart` — pre-commit negative-balance `needsConfirmation`.
  - `recommended_rate_service.dart` — avg cost + margin %, explainable.
- `test/domain/` — 30 tests named for the exact PRD scenarios they verify.

### Key modeling decision (ASSUMPTION, documented)
`StockPosition` stores `quantityGrams` + `totalCostBasisPaisa` (both int).
avgCost is **derived** (`avgCostPaisaPerKg`), never persisted — a per-gram/per-kg
avg column would not be integer-exact for common rates (Rs 55/kg = 5.5 paisa/g).
This keeps the moving-average invariant exact: a sale removes cost strictly in
proportion to weight, so the average of what remains is provably unchanged.

## Not yet built (Phase 1 domain/use-case layer is COMPLETE)
- Repository layer (use-cases currently talk to `AppDatabase` directly inside a
  transaction; thin repos can wrap later without changing the invariant).
- Riverpod providers/DI. All UI (presentation/ — Phase 2+), Supabase sync
  (Phase 5), PIN/security storage, receipt/summary sharing.
- `compute_dashboard_summary` now covers monthly AND quarterly scope (Phase 4).
- Forced-migration failure drill (schemaVersion bump + throwing onUpgrade).
- Soft-delete/Trash repository mixin + UpdateHistory on in-place bill edits
  (schema is ready — `deletedAt`, `TrashRecord`, `UpdateHistory` tables exist).

## Commands
```
export PATH="<flutter-sdk>/bin:$PATH"   # SDK path is machine-specific, not on PATH by default
flutter test test/domain/       # run domain unit tests (the actual bar)
flutter analyze lib test
```
Confirmed SDK locations seen so far (varies by machine — check yours, don't assume):
- `/home/sami/Android/flutter` — Flutter 3.41.1 / Dart 3.11.0, Android SDK at `/home/sami/Android/Sdk`.
- `/home/samiullah/Android/flutter` — Flutter 3.44.7.

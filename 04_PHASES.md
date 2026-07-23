# Implementation Phases

Ordering principle: **correctness of the financial core before UI breadth, and domain-layer tests before screens.** Each phase should end with something genuinely verifiable against a real numeric example from the owner's actual business, not just "tests green."

> **Implementation status (as of 2026-07-23)** — 55 tests green, `flutter analyze lib test` clean.
> - **Phase 0 — ✅ DONE** (except CI wiring + the deliberate forced-migration-failure drill).
> - **Phase 1 — ✅ DONE.** All services + all use-cases + dashboard summary built and unit/integration-tested, including a hand-traced day-0-plus-a-month scenario where net worth grows by exactly the period profit.
> - **Phase 2 — ✅ DONE (daily-use core usable end-to-end).** Onboarding + PIN lock + View-mode + Day-0 wizard, Parties (list/detail/settlement/edit-with-UpdateHistory), New Bill (Purchase/Sale/Expense, per-bill/per-line rate, inline sub-category + custom parent category, soft stock/overdraft warnings), Bills list + Pending filter, Bill detail + branded-image receipt share, Stock (cards, recommended-rate explainer, ledger drill-down + sub-tag filter, write-off), and Trash (soft-delete + restore, ledger-replay stock rebuild). Deferred to their own phases: standalone Payment recording + manual allocation UI, Payment Reversal UI, and in-place bill *field* editing (all Phase 3 / later — bills carry inline payments today, and a mistaken bill is corrected via Trash+re-enter). Fonts still fall back until TTFs are bundled.
> - **Phase 3 — ✅ DONE (2026-07-23).** Cash & Godam screen + reconciliation, Transfer-to-Godam, Godam FIFO ledger with two-tap spend-trace, Roznamcha (filterable, day-grouped), standalone Payment recording + manual allocation, Allocate-existing-advance, and the Payment-Reversal/bounce flow — all UI over the Phase-1 use-cases, plus the `cash_read_providers` derived read layer. 55 tests green (added `cash_read_test.dart`); this session's machine ran a newer Flutter SDK than previously recorded (see `CLAUDE.md` §Commands) which surfaced a pre-existing `ListTile`-in-`Container` assertion in the party/category pickers, fixed for good regardless of SDK version.
> - **Phases 4–6 — ⬜ NOT STARTED** (Phase 4 dashboard math already partially done from Phase 1).
>
> See `05_MEMORY.md` Update Log for the running detail and the documented schema deviations.

## Phase 0 — Foundation & Schema Lock — ✅ DONE (CI + forced-migration drill outstanding)
**Goal**: Nothing built on top of a shaky schema.
- Review `06_DESIGN_SYSTEM.md` and the validated HTML prototype (`Godam_Ledger_dc.html`) alongside this schema — confirm every data field the design references (e.g. net worth, cash pool chips, party balance colors) has a clear source in the schema below before writing use-case code.
- Finalize schema per Architecture doc §6 (Party, StockCategory, Bill, BillLineItem, Payment, PaymentAllocation, CashPool, CashMovement, ExpenseCategory, StockWriteOff, UpdateHistory, TrashRecord, DayZeroMigration) — **UUIDv4 keys throughout, integer Paisa/Grams for all currency/weight fields, no `double`/`float` anywhere in the schema.**
- Set up Drift tables + migrations, including the **pre-migration vaulting mechanism** (copy DB file before any `onUpgrade` runs) built and tested from the very first migration, not retrofitted later.
- Set up Riverpod provider scaffolding, folder structure per Architecture doc §4.
- Set up CI (analyze → test → build) reusing existing GitHub Actions config.
- **Exit criteria**: schema reviewed against every scenario in PRD §3 (multi-line-item bill, moving average with zero-stock reset, parent-vs-subcategory costing, many-to-many payment, Godam FIFO, wastage write-off, payment reversal, cash overdraft) and confirmed each is representable — on paper/in a design doc — before writing use-case code. A deliberate migration-failure drill (force an `onUpgrade` to throw) confirms the vault-and-restore path actually works before Phase 1 starts.

## Phase 1 — Domain Core (the part that must be correct) — ✅ DONE
**Goal**: The financial logic exists and is proven correct in isolation, with zero UI.
- `stock_costing_service.dart`: moving-average purchase/sale logic, **including the zero/negative-stock reset rule** and strict parent-category-only quantity/cost (sub-category tags never carry their own ledger).
- `ledger_service.dart`: party balance derivation from bills + payment allocations, including reversed-payment handling.
- `cash_trace_service.dart`: Godam transfer-in / spend-out **dynamic** FIFO trace computed at query time from `CashMovement` rows.
- `cash_overdraft_service.dart`: pre-commit negative-balance check returning a `needsConfirmation` result.
- `recommended_rate_service.dart`: avg cost + margin.
- Use-cases: `record_purchase`, `record_sale`, `record_expense`, `allocate_payment`, `reverse_payment`, `transfer_to_godam`, `write_off_stock`, `run_day_zero_migration`.
- **Tests**: unit tests covering the exact worked examples in the PRD (100kg scrap split into sub-categories, confirming sub-category tags don't fragment the parent's stock; a purchase-then-sell-to-zero-then-purchase-again sequence verifying the reset rule fires correctly; a payment split across 2 bills; an advance-allocation-to-new-bill confirmed to NOT create a duplicate CashMovement; a Godam spend traced to 2 separate transfers-in via the dynamic FIFO calc; a wastage write-off in both absorb and expense modes; a full payment reversal restoring a bill to open status without deleting the original payment row; a cash withdrawal that triggers the overdraft warning).
- **Exit criteria**: hand-trace one full real day of business (owner provides real numbers from his manual register) through these use-cases and get matching numbers. This is the actual bar — not "tests pass," but "matches what the owner would have written by hand." All integer-storage (Paisa/Grams) arithmetic double-checked for a zero-drift result across a long sequence of operations (e.g. 50 simulated bills) to confirm no floating-point-style drift is possible.

## Phase 2 — Parties, Billing, Stock Screens — ✅ DONE
**Goal**: Daily-use core is usable end-to-end.
*(Built this session: onboarding/PIN + View-mode gate + Day-0 wizard, Parties (list/detail/settlement/edit), New Bill (all three types, rate toggle, inline sub-category + custom category, soft warnings), Bills list + Pending filter, bill detail + image receipt share, Stock (cards/recommended-rate/ledger/write-off), Trash (soft-delete + restore via ledger replay). Party edit is wired to UpdateHistory. Deferred: standalone payment/allocation UI + reversal UI (Phase 3), in-place bill field editing.)*
- Onboarding (business name, Admin PIN, optional View PIN) **plus the Day-0 Migration flow**: guided entry of opening party balances, starting cash pool positions, and baseline stock qty/cost as real dated ledger entries — this is required before the app is usable for an already-running business, not a nice-to-have added later.
- Party list + detail (balance, history).
- New Bill flow: type switch (Purchase/Sale/Expense), multi-line items, inline custom sub-category creation (tag-only, confirmed non-fragmenting), per-bill/per-line rate toggle, photo capture, soft stock-warning on sale.
- Stock screen: per-category cards (qty, avgCost per kg/ton), sub-category breakdown (filter view, not separate ledger), stock ledger drill-down, **Stock Write-Off/Wastage entry action** (absorb or expense mode).
- **Settlement history tab** on Party Detail — unified chronological view of advances, bills, and payments for that party, with receivable and payable always shown as two distinct numbers, never netted.
- **Pending bills filter** on the Bills list screen.
- In-place bill editing wired to `UpdateHistory` logging from the first edit screen built — not retrofitted.
- Receipt generation + share (single bill).
- Trash (soft-delete + restore) wired in from day one for Bills/Parties, not bolted on later.
- Access-mode enforcement (`UnauthorizedException` at the use-case layer) verified from the first mutating screen — confirm a View-PIN session genuinely cannot mutate data even if a button were mistakenly left visible.
- **Exit criteria**: owner can log a real day's purchases and sales in the app, side-by-side with his manual register, and every number matches — including onboarding his actual current opening position via Day-0 Migration rather than starting from zero.

## Phase 3 — Cash & Godam, Payments — ✅ DONE
**Goal**: Money movement is fully tracked and traceable.
*(Note: the underlying use-cases — transfer_to_godam, payment recording/allocation, reversal, and the dynamic Godam FIFO trace — were already built and tested in Phase 1. This phase is the UI over them, plus the cash read-model layer.)*
- Cash pool screens (Home/Bank/Godam balances) — `presentation/cash_godam/cash_screen.dart` (dark total-cash card + pool cards + reconciliation figure).
- Transfer-to-Godam flow — `cash_godam/transfer_sheet.dart` (source pool, amount, date; overdraft round-trip via `runWithConfirm`).
- **Cash overdraft soft-warning** wired into every withdrawal path: bill payment/expense (New Bill), standalone payment (`paid`), and Godam transfer — all via the shared `NeedsConfirmation` → `showWarningsSheet` round-trip.
- Payment recording + manual allocation UI — `presentation/payments/new_payment_screen.dart` (direction, amount, pool, allocate against open bills of the matching kind; remainder = advance). Allocating an existing advance — `payments/allocate_advance_screen.dart` — goes through `AllocatePayment` (PaymentAllocation only, **no duplicate CashMovement**, regression-tested in Phase 1 + exercised by the read-model test).
- **Payment Reversal / Bounce flow** — `payments/reverse_payment_sheet.dart`, opened by tapping a payment in the Party Detail settlement timeline; reopens bills + logs the note, never deletes.
- Godam ledger with dynamic FIFO spend-trace — `cash_godam/godam_ledger_screen.dart`; tapping a spend opens a "where this money came from" sheet naming the funding transfer(s) and offering "View bill".
- **Cash Flow Ledger (Roznamcha) screen** — `cash_godam/roznamcha_screen.dart`: day-wise grouping with per-day net + running end-of-day balance, filterable by pool, direction, party, expense category, and date range (all/today/week/month); every row drills to its source bill/party.
- Cash reconciliation view — `reconciliationProvider` (three pools + total = cash on hand), surfaced on the Cash screen.
- Read layer: `data/local/cash_read_queries.dart` + `app/cash_read_providers.dart` (resolves movements to labelled `CashLedgerEntry`s, Godam FIFO trace, open bills / advances per party, reconciliation) — all derived, recomputed on `ledgerRevision`.
- **Exit criteria met**: a Godam spend's funding is answerable in two taps (open Godam ledger → tap the spend), proven by `test/data/cash_read_test.dart` (a spend traced to its two funding transfers, oldest-first); a bounced-cheque scenario is run end-to-end and the bill reopens with full outstanding + a reversal entry on the Roznamcha and a note on the party ledger.

## Phase 4 — Dashboard & Analytics — 🚧 PARTIAL
**Goal**: Month-end trust — the app replaces the manual register for decision-making.
*(Done early: net-worth + monthly P&L computation (`compute_dashboard_summary`) and a first Dashboard screen showing them. Remaining: the fl_chart profit chart, quarterly scope, and drill-down from each number to its source.)*
- Net worth calculation.
- Monthly/quarterly profit chart (`fl_chart`, accessible colors).
- Receivables/payables summary.
- Plain-language "what was good/bad this month" summary.
- Drill-down from any dashboard number to its source records.
- **Exit criteria**: run the dashboard against a past month the owner already closed manually, and the profit number matches (or the discrepancy is explainable and traced to a specific missing/miscategorized entry — which itself validates the audit-trail design).

## Phase 5 — Offline Sync, Backup, Sharing Polish, Theming — ⬜ NOT STARTED
**Goal**: Production-ready daily driver.
- Supabase backup/restore (push on connectivity, manual "backup now," device-pairing restore flow).
- Confirm photo paths are excluded from sync payload (test this explicitly).
- Day/week/month/custom-range summary sharing.
- Light/dark/system theme finalization, accessibility pass on all chart colors and error states.
- Full calm-error-copy review across every flow (batch review against Rules doc §4).
- Full regression pass on Trash (30-day purge timing) and Update History across all entity types.
- **Migration vault regression test**: simulate an app update that ships a schema migration, confirm the pre-migration vault file is created, then force the migration to fail and confirm automatic restore from vault leaves the business's data fully intact.
- **Exit criteria**: airplane-mode test — full day of realistic use with zero connectivity, then reconnect and confirm clean backup sync; fresh-install-and-restore test on a second device; migration-failure drill passes without data loss.

## Phase 6 — Real-World Pilot — ⬜ NOT STARTED
**Goal**: Validate against actual business use, not synthetic tests.
- Owner uses the app exclusively (no manual register) for an agreed trial period (suggest 1–2 weeks).
- Daily diff against manual register in parallel during week 1 only, to catch discrepancies fast.
- Fix list prioritized by: (1) anything that produces a wrong number, (2) anything that blocks daily entry speed, (3) polish.
- **Exit criteria**: owner drops the manual register voluntarily because he trusts the app more.

---

**Note on sequencing discipline**: Do not start Phase 2 UI work until Phase 1's domain tests are passing against hand-traced real numbers. The original build's core failure was almost certainly a Phase-ordering problem — UI and "feature checklist completeness" were prioritized over provable financial correctness. This time, correctness gates progression, not test count or screen count.

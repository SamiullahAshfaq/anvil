# Project Memory
*Read this file at the start of every new session on this project. It exists so context isn't re-derived or re-guessed each time — it should be updated as decisions are made, not just at the start.*

## What This Project Is
A single-user, offline-first mobile app (Flutter) for a scrap/raw-material trading business (Bura, Degi Bura, Scrap + custom sub-categories). It replaces a manual paper register with a connected ledger: Parties, Billing (Purchase/Sale/Expense), Stock (moving-average costing), Cash & Godam (cash-state tracking with FIFO traceability), and a Dashboard. Full detail lives in `01_PRD.md`.

**One-line test for any new idea**: does it make the numbers more correct/trustworthy, or is it decoration? Correctness ships first.

## Why This Project Exists (history)
A first version was built via "vibe coding" with Claude. It reported "complete" (37 tests, clean build, APK produced) but the owner found it didn't reflect real business logic — likely because Parties/Bills/Stock/Cash were built as independent CRUD modules instead of one connected ledger, and core costing math (average purchase rate) was probably wrong or oversimplified (lifetime average instead of moving average of remaining stock). This rebuild starts from a proper PRD + architecture instead of feature-by-feature vibe coding.

## Confirmed Business Decisions (do not re-litigate these without a new explicit conversation)

| Question | Confirmed Answer |
|---|---|
| Rate mode on multi-line bills | Both supported — user chooses per-bill: one rate for whole bill, OR separate rate per line item |
| Average purchase rate calculation | **Moving weighted average of currently unsold stock only** — NOT lifetime average of all purchases ever. Sales reduce quantity but never change avgCost; only new purchases do. |
| Payment-to-bill relationship | Many-to-many: one payment can cover multiple bills, one bill can be paid via multiple partial payments over time |
| Payment allocation method | **Manual only** — user picks which bill(s) a payment settles. No auto-FIFO allocation. |
| Godam concept | A **cash-state pool** (Home/Bank/Godam), NOT a separate physical stock location. Single Godam only. |
| Stock validation on sale | **Soft warning only** if a sale would take stock negative — never hard-blocked (selling ahead of physical receipt is normal in this business) |
| Godam cash traceability | FIFO — every Godam spend must be traceable back to which Home/Bank transfer(s) funded it |
| Multi-device / concurrency | **Single-device-primary.** Supabase sync is backup/restore only, not real-time multi-user collaboration. |
| Access control | Admin PIN (full control) + optional View-only PIN. No usernames, no complex RBAC — deliberately minimal. |
| Bill photos | Local device storage only, **never** uploaded to Supabase or anywhere else, under any circumstance |
| Deletion model | Soft-delete everything → Trash, 30-day recovery window, then auto-purge |
| Edit tracking | Every edit to Party/Bill/Payment is an **in-place transactional update**, mandatorily paired with an `UpdateHistory` row in the same transaction — not a new-row-version scheme. Viewable per-record on demand (not shown inline by default). |
| Zero/negative stock crossing | On purchase, if quantity was ≤ 0, `avgCost` **resets** to the new purchase's rate — the moving-average formula is never blended across a zero/negative crossing |
| Sub-categories | Pure descriptive **tags** on a bill line item — never their own inventory ledger. Quantity/avgCost/stock-warnings live only at the parent category. |
| Physical shrinkage/wastage | Dedicated Stock Write-Off use-case, two modes: absorb into remaining stock's cost basis, or log as a Wastage expense on the P&L |
| Currency & weight storage | Integer **Paisa** for currency, integer **Grams** for weight, everywhere in the DB and domain layer — zero `double`/`float`. Convert to display units only at the UI boundary. |
| Primary/foreign keys | **UUIDv4** throughout, generated client-side — never auto-increment integers |
| Advance-to-bill allocation | Creates a `PaymentAllocation` row **only** — never a duplicate `CashMovement` (cash already moved when the advance was first recorded) |
| Godam FIFO trace | Computed **dynamically** at read time from `CashMovement` rows sorted chronologically — not a separately stored/maintained allocation table |
| Access control enforcement | Checked inside the **use-case layer itself** (`UnauthorizedException` in View mode) — UI hiding buttons is a nicety, not the security boundary |
| Cash pool overdraft | Soft warning only ("Record Transfer Now" / "Continue Anyway") if a withdrawal would take Home/Bank/Godam negative — never a hard block |
| Bounced/reversed payments | Non-destructive **Payment Reversal** flow — reopens affected bills, logs an offsetting cash movement + permanent ledger note, original payment row flagged `reversed`, never deleted |
| Onboarding an existing business | **Day-0 Migration** — opening party balances, starting cash positions, and baseline stock qty/cost entered as real dated ledger entries at first-run setup, not raw editable starting-balance fields |
| Schema migration safety | **Pre-migration vaulting** — local DB file is copied before any Drift `onUpgrade` runs; automatic restore-from-vault on migration failure |
| Party balance display | **Receivable and payable shown as two separate numbers, always** — never silently netted into one figure. A party can simultaneously owe you from a standing debt AND be owed money for an in-progress purchase; both must stay visible (this was explicitly worked through with a real numeric example: party owes 5,00,000 standing debt, separately gets paid 25k advance + 75k for a 1,00,000 stock purchase — the 5,00,000 does not change from the stock transaction). |
| Cash Flow Ledger (Roznamcha) | A dedicated day-wise, filterable (pool/direction/party/expense-category/date-range) view of all cash movements across Home+Bank+Godam combined — distinct from the Godam-specific FIFO trace screen |
| Settlement history | A unified per-party timeline tab combining advances, bills, and payments chronologically |

## Non-Negotiable Technical Invariants
- Party balances, cash pool balances, and stock totals are **derived**, never directly editable fields.
- Every multi-table business event (a Sale touching Stock + Party + Cash) is ONE domain use-case call inside ONE DB transaction. No partial-write states.
- Moving-average formula: `newAvgCost = ((oldQty × oldAvgCost) + (newWeight × newRate)) / (oldQty + newWeight)` — applied on purchase only, **except when `oldQty <= 0`, in which case `avgCost` resets directly to the new rate**.
- Stock quantity/cost math happens **only at the parent category** — sub-category labels never carry their own ledger.
- All currency = integer Paisa, all weight = integer Grams. No floating point for money or weight, anywhere.
- All primary/foreign keys = UUIDv4, client-generated.
- Domain/service layer (`domain/services/`, `domain/use_cases/`) is where all business logic lives, tested independently of UI and DB, before any screen is built.
- A pre-migration vault of the local DB file is mandatory before any schema `onUpgrade` runs.

## Stack Decisions (see `02_ARCHITECTURE.md` for full detail — don't re-derive)
Flutter · Drift (SQLite) · Riverpod · Supabase (backup/restore only) · `fl_chart` · `share_plus` · `flutter_secure_storage` for PIN. Do not introduce alternative state-management/DB/backend libraries without updating the architecture doc explicitly.

## Design System (see `06_DESIGN_SYSTEM.md`)
Two design inputs exist — they are NOT equivalent:
- `DESIGN.md` = Coinbase's **marketing website** style guide (hero bands, pricing tiers, 80px headlines). **Do not use this as the app design spec** — it documents a content site, not an app.
- `Godam_Ledger_dc.html` = a real, screen-accurate interactive prototype (Android frame, light/dark, Dashboard/Parties/Bills/Stock/Cash/Trash/Backup/PIN/etc.) built by Claude Design. **This is the actual UI reference.**
Validated tokens: Coinbase Blue (`#0052ff`) as the single accent color, Inter for text, JetBrains Mono for all numbers, pill shapes for interactive elements, 24px radius for primary cards, 1px hairlines, no drop shadows, semantic green/red reserved strictly for receivable/payable and profit/loss polarity.
Known gaps in the prototype (as of 2026-07-21) needing a follow-up Claude Design pass: New Bill entry form, Stock Write-Off screen, cash overdraft warning sheet, Day-0 Migration onboarding wizard, payment allocation UI, Cash Flow Ledger (roznamcha) with filters, Settlement History tab, empty states, error/validation states, chart accessibility re-check.

## Explicitly Out of Scope for v1
Multi-device real-time sync, multi-currency, barcode/QR scanning, GST/tax filing, multi-Godam physical warehouse tracking, automated payment allocation, push notifications, multi-language UI. (These may become v2 conversations later — don't build toward them speculatively now.)

## Definition of Done (the actual bar, not test-count)
Not "tests pass" or "builds clean" — the bar is: **hand-trace a real day/month from the owner's manual register through the app and get matching numbers.** See `04_PHASES.md` exit criteria per phase — each phase has a real-numbers validation step, not just a green CI badge.

## Current Implementation Status (2026-07-22)
- **Phase 0 ✅ DONE** — Drift schema (13 tables, UUIDv4, integer Paisa/Grams),
  `AppDatabase` + seeding (3 pools / 3 stock cats / 6 expense cats incl. Wastage),
  `DbVault` pre-migration copy/restore/prune. Outstanding: CI, forced-migration drill.
- **Phase 1 ✅ DONE** — all 5 services (stock costing w/ zero-reset, ledger, cash
  trace FIFO, overdraft, recommended rate) + all use-cases (purchase, sale, expense,
  payment, allocate-advance [no-dup-CashMovement], reversal, godam transfer,
  write-off, day-0 migration, dashboard summary). 47 tests, incl. hand-traced
  day-0-plus-a-month where net worth grows by exactly the period profit.
- **Phase 2 ✅ DONE (daily-use core usable end-to-end)** — 53 tests green.
  Onboarding + PIN lock + **View-mode session** + Day-0 wizard; Parties
  (list/detail/**settlement timeline**/edit-with-`UpdateHistory`); **New Bill**
  (Purchase/Sale/Expense switch, per-bill/per-line rate toggle, inline sub-category
  tag + inline custom parent category, soft negative-stock/overdraft confirmation
  round-trip); Bills list + **Pending filter**; bill detail + **branded-image
  receipt share** (`screenshot`+`share_plus`); Stock (cards, recommended-rate
  explainer, ledger drill-down + sub-tag filter, **write-off** absorb/expense);
  **Trash** soft-delete + restore. New correctness primitive: deleting/restoring a
  stock-affecting bill **rebuilds the category's stored qty/cost by replaying the
  surviving ledger** (`data/local/stock_rebuild.dart`) — never an approximate
  inverse; proven by hand-traced tests. Deferred to Phase 3: standalone
  payment-recording + manual-allocation UI, Payment-Reversal UI, Cash & Godam +
  Roznamcha screens, in-place bill *field* editing.
- **Phases 3–6 ⬜ NOT STARTED** (though most Phase-3 use-cases already exist).

**Documented deviations from `02_ARCHITECTURE.md` §6** (all deliberate, for
integer-exactness): StockCategory stores `quantityGrams` + `totalCostBasisPaisa`
(avgCost derived, not a stored per-gram column); rates stored as `ratePaisaPerKg`;
Bill has an added `isOpening` flag; repository layer deferred (use-cases hit
`AppDatabase` directly, one-txn invariant preserved). Flutter SDK at
`/home/sami/Android/flutter` (not on PATH). Host tests need `test/sqlite_loader.dart`
(libsqlite3.so.0). See `CLAUDE.md` for the file-by-file map.

## Update Log
*(Append entries here as the project progresses — decisions made, scope changes, things learned mid-build that future sessions should know without re-discovering.)*

- **2026-07-21**: Initial PRD/Architecture/Rules/Phases/Memory set created from requirements-gathering conversation. Four clarifying questions asked and answered (see Confirmed Business Decisions above). No code written yet — this is the planning baseline.
- **2026-07-21 (same day, hardening pass)**: Applied a 13-point "foolproofing" checklist covering real-world trading-business edge cases: zero/negative-stock cost reset, parent-only stock costing (sub-categories as tags), physical wastage write-offs, integer Paisa/Grams storage (no floats), UUIDv4 keys, in-place transactional bill edits, advance-allocation double-cash-movement guard, dynamic Godam FIFO tracing, domain-layer access control enforcement, cash overdraft soft-warnings, non-destructive payment reversal/bounce flow, Day-0 migration onboarding for an already-running business, and pre-migration SQLite vaulting. All five files updated accordingly — this is now the current baseline; still no code written.
- **2026-07-21 (same day, design + gap-filling pass)**: Reviewed two design inputs — `DESIGN.md` (Coinbase marketing-site style guide, judged NOT usable as an app spec) and `Godam_Ledger_dc.html` (a real Claude Design interactive prototype, judged the actual usable design reference). Created `06_DESIGN_SYSTEM.md` documenting this distinction, the validated token set, and 10 identified gaps in the prototype. Added three previously-discussed-but-undocumented features into the PRD: Cash Flow Ledger/Roznamcha (§4.5), Settlement History tab on Party Detail, Pending Bills filter, and a Stock Ledger sub-category filter view. Explicitly documented the bidirectional party-balance principle (receivable and payable always shown separately, never netted) after working through a real numeric example. Still no code written — six planning documents now form the baseline.
- **2026-07-22 (Phase 2 completed — daily-use UI end-to-end)**: Built the full
  Phase-2 presentation layer on top of the existing domain core. New read layer
  (`data/local/read_queries.dart`, `app/read_providers.dart`) derives party
  balances (via `LedgerService`), stock positions, bill paid-status, and trash
  views — all recomputed on `ledgerRevision` bumps, nothing stored. New use-cases:
  `manage_party` (create + edit-with-`UpdateHistory`), `manage_stock` (inline
  custom category + editable target margin), and `manage_trash` (soft-delete +
  restore for Bills/Parties). **Key correctness decision**: a bill soft-delete/
  restore must not corrupt the moving-average core, so instead of inverting the
  costing math (not cleanly invertible across a zero/negative reset), it **replays
  the surviving ledger** to rebuild each affected category's stored qty/cost
  (`data/local/stock_rebuild.dart`); cash effects unwind by soft-deleting the
  bill's own movements + advance payments, and derived party balances self-correct.
  Screens: onboarding (business name + Admin PIN + optional View PIN, PIN hashed
  with a deterministic salted FNV in `flutter_secure_storage`), PIN lock,
  AppRoot auth gate, Day-0 wizard, Parties list/detail (Settlement + History tabs),
  New Bill (one surface, three types), Bills list + Pending filter, Bill
  detail/receipt (image share), Stock cards + recommended-rate explainer + ledger
  + write-off sheet, Trash. Shared widgets: `PillButton`, calm confirm/warning
  sheets (`showWarningsSheet` drives the `NeedsConfirmation` round-trip),
  `SegmentedPills`, `AppTextField`, `runWithConfirm`/`confirmAndRun`,
  `core/errors/error_copy.dart` (single calm-copy mapping). View-mode is enforced
  in use-cases AND hides mutating controls. **53 tests green** (added `trash_test`
  hand-tracing delete/restore stock rebuild + guards, and `new_bill_flow_test`
  widget test). `flutter analyze lib test` clean. Deferred (Phase 3): standalone
  payment/allocation UI, reversal UI, Cash & Godam + Roznamcha, in-place bill
  field editing. Fonts still fall back (TTFs not bundled).
- **2026-07-22 (first code — Phases 0, 1, and start of 2)**: Scaffolded the Flutter project (`flutter create`, org `com.godamledger`) with the approved dependency set. Built and test-proved **Phase 0** (Drift schema + seeding + `DbVault` pre-migration vaulting) and all of **Phase 1** (the 5 domain services and every use-case, including `run_day_zero_migration` and `compute_dashboard_summary`). Started **Phase 2**: design-system theme, Riverpod DI, app shell, and the Dashboard screen with a widget test. **47 tests pass; `flutter analyze lib test` clean.** Recorded deliberate schema deviations for integer-exactness (StockCategory `quantityGrams`+`totalCostBasisPaisa` with derived avgCost; `ratePaisaPerKg`; Bill `isOpening` flag) and deferred the repository layer (use-cases hit `AppDatabase` directly, one-transaction invariant preserved). Validation highlight: a hand-traced day-0-plus-a-month scenario where net worth increases by exactly the period profit — evidence the whole ledger is internally consistent. See per-doc status banners (added this session) and `CLAUDE.md` for the file map.

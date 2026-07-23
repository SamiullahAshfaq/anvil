# Rules & Guardrails for Implementation (for Claude / whoever codes this)

These rules exist because the first build technically "passed tests" while missing the actual business logic. Passing tests is not the goal — **matching real business behavior** is. Read the PRD and Architecture docs first; this file governs *how* to build what's specified there.

> **Compliance status (2026-07-23)** — domain/use-case layer + Phase-2/3 UI follow
> these rules, proven by 55 tests: domain-first with tests before UI (§1.1);
> one-use-case-one-transaction (§1.2); derived balances (§1.3); moving-average
> with zero/negative reset (§1.4); per-bill/per-line rate (§1.5, in New Bill);
> soft stock validation (§1.6, calm warning sheet); **manual many-to-many payment
> allocation (§1.7, `new_payment_screen`/`allocate_advance_screen` — user picks
> bills and amounts, no auto-FIFO)**; **Godam FIFO traceability with "view
> source" from any spend (§1.8, `godam_ledger_screen`'s trace sheet)**; inline
> sub-categories + inline custom parent category (§1.9); parent-only costing
> (§1.16); integer Paisa/Grams, no floats (§1.18, §2.14); UUIDv4 keys (§1.17);
> advance-allocation no-duplicate-CashMovement guard (§1.20, regression-tested in
> Phase 1 **and exercised end-to-end by the Phase-3 UI + `cash_read_test.dart`**);
> dynamic Godam FIFO (§1.21, now also read-modeled in `cash_read_providers.dart`
> for the UI); View-mode enforced in use-cases AND UI (§1.22, widget-tested);
> write-off both modes (§1.23, in UI); **non-destructive reversal (§1.24, now
> reachable from the Party Detail settlement timeline via
> `reverse_payment_sheet`, not just the use-case)**; overdraft soft-warning
> (§1.25, round-tripped in UI across bill payments, standalone payments, AND
> Godam transfers); Day-0 as dated entries (§1.26, wizard); pre-migration
> vaulting (§1.27); soft-delete → Trash + restore (§1.11, `manage_trash`, bill
> delete replays the ledger to keep stock exact); UpdateHistory on party edits
> (§1.12/§1.19); centralized calm-error copy (§4, `core/errors/error_copy.dart`).
> **Still outstanding**: CI (§3); UpdateHistory on in-place *bill* edits (§1.19 —
> bill field-edit UI not built, Trash+re-enter used instead); photo capture +
> photo-path sync exclusion test (§1.10 — no sync layer yet); 30-day auto-purge
> execution (Trash shows the countdown; purge is Phase 5).

## 1. What To Do

1. **Write the domain/service layer first, with tests, before any UI.** `stock_costing_service.dart`, `ledger_service.dart`, and `cash_trace_service.dart` should have unit tests covering the exact scenarios in the PRD (multi-line-item bills, moving average recalculation, FIFO Godam trace) *before* a single screen is built. If these are wrong, no amount of UI polish matters.
2. **Every multi-table write goes through exactly one use-case function, inside one DB transaction.** No screen/widget calls two repositories directly for what is logically one business event (e.g. a Sale touching Stock + Party balance + Cash must be one transaction, not three sequential awaited calls that could partially fail).
3. **Derive, don't store, anything that can be computed.** Party balances, cash pool balances, stock totals — compute from the underlying ledger/movement tables (or maintain as a cached column that is *recalculated* by the same transaction that writes the source rows, never edited independently).
4. **Model moving-average costing exactly as specified**: `newAvgCost = ((oldQty × oldAvgCost) + (newWeight × newRate)) / (oldQty + newWeight)` on every purchase; sales reduce `quantity` only and use the *current* `avgCost` as COGS — they must never modify `avgCost`. **If `oldQty <= 0` at the time of a purchase, reset `avgCost = newRate` directly instead of applying the blended formula** — blending across a zero or negative crossing produces a distorted (or in the negative case, mathematically nonsensical) cost basis. Write a unit test for this formula with at least: a first purchase, a second purchase at a different rate, a partial sale, then another purchase, **and a sell-to-zero-then-purchase-again sequence verifying the reset** — verify avgCost is correct at each step.
16. **Enforce parent-level-only costing.** `StockCategory.quantity` and `avgCost` exist and are mutated only at parent-category rows. `BillLineItem.subCategoryLabel` is a plain string tag with no quantity/cost of its own — every purchase or sale, tagged or untagged, reads/writes the same parent row. Never create a code path where a sub-category tag resolves to its own separate stock ledger.
17. **Use UUIDv4 for every primary and foreign key**, generated client-side at record-creation time, across all Drift tables. Never rely on auto-increment integer IDs anywhere in this schema.
18. **Store all currency as integer Paisa and all weight as integer Grams** in the database layer, with zero `double`/`float` fields for money or weight. Conversion to Rupees/kg/ton happens only in display-formatting utilities at the UI boundary — never store a converted decimal value anywhere, and never do currency/weight arithmetic in floating point.
19. **Bill/Party/Payment edits are in-place transactional updates**, each mandatorily paired with an `UpdateHistory` row (per changed field, old→new) written in the *same* transaction as the edit — not a separate "immutable new version" row scheme.
20. **Allocating an existing advance payment to a new bill must insert a `PaymentAllocation` row only** — never a new `CashMovement`. The cash already moved when the original advance was recorded; creating a second movement here double-counts cash and is a critical-severity bug class to explicitly guard against (write a regression test for this exact scenario).
21. **Compute Godam FIFO traceability dynamically**, by sorting `CashMovement` rows chronologically in `cash_trace_service.dart` at query/read time — never maintain a separately-stored allocation table for this that could drift out of sync with the underlying movements. Use `pairedMovementId` to link each Home/Bank→Godam transfer's outbound and inbound halves.
22. **Enforce Admin/View access control inside the use-case layer itself**, throwing an `UnauthorizedException` for any mutating call made while in View mode — in addition to (not instead of) hiding/disabling the relevant UI controls.
23. **Implement Stock Write-Off/Wastage as a first-class use-case** with two explicit modes (absorb into remaining stock's cost basis, or log as a Wastage expense on the P&L) — never leave physical shrinkage as an unhandled gap that causes app-stock and real-stock to silently diverge.
24. **Implement Payment Reversal as a non-destructive flow**: reopen the affected bill(s) via allocation removal, post an offsetting `CashMovement`, write a permanent timestamped ledger note, and flag (never delete) the original `Payment` row (`reversed = true`).
25. **Warn, don't block, on cash pool overdraft.** Any withdrawal that would take Home/Bank/Godam negative surfaces a calm confirmation ("Record Transfer Now" / "Continue Anyway") via the same `needsConfirmation` pattern used for stock warnings — never a hard block, never silent.
26. **Build a Day-0 Migration flow for onboarding an already-running business.** Opening balances (party dues, cash pool starting positions, stock baseline qty/cost) must be entered as genuine dated ledger entries at first-run setup, not as raw editable fields on the Party/CashPool/StockCategory tables themselves.
27. **Implement pre-migration SQLite vaulting.** Before any Drift schema `onUpgrade` runs, copy the current database file to a timestamped vault file; on migration failure, restore from the vault automatically rather than proceeding on a partially-migrated or corrupted schema.
5. **Support both per-bill and per-line rate modes** on Purchase/Sale bills, controlled by a single toggle the user sets per bill, not a global setting.
6. **Implement soft-only stock validation on sales.** Compute would-be-negative stock, show a calm inline warning with Continue/Cancel — never a hard block, never a jarring alert.
7. **Implement manual payment allocation as many-to-many.** A `PaymentAllocation` join table, a UI where the user sees open bills for a party and manually checks/assigns amounts against them, remainder becomes an unallocated advance balance.
8. **Treat Godam as a cash-state pool with FIFO traceability.** Every spend from Godam should be traceable to the transfer(s) that funded it — maintain this via a ledger of transfers-in and consumption-out, oldest-transfer-first, and expose "view source" from any Godam spend.
9. **Make custom sub-categories genuinely inline.** Creating a bill line item should let the user type a new sub-category name on the spot (autocomplete existing ones, allow new), with zero separate "manage categories" detour required for basic use.
10. **Keep photos strictly local.** Store the file path in local DB; explicitly exclude that field from anything sent to Supabase. Write this as an actual test/assertion in the sync payload mapper, not just a comment.
11. **Every delete is a soft-delete** (`deletedAt` timestamp + `TrashRecord` row with `purgeAt` = now+30 days). Build one shared "trash-aware" query helper/repository mixin used everywhere, so no individual repository can accidentally hard-delete or forget to log it.
12. **Log every edit to Party/Bill/Payment fields into `UpdateHistory`** at the use-case layer (diff old vs new before commit), surfaced via a "View update history" action per record — not shown inline in normal views.
13. **Keep error copy calm and specific.** "This will put Scrap below zero — continue?" not "Error: Invalid operation." Centralize user-facing error copy in one place (`core/errors/`) so tone stays consistent and is easy to review as a batch.
14. **Every screen-level number must be tappable/traceable to its source** where the PRD implies trust matters (recommended rate, dashboard profit, Godam balance) — either a drill-down screen or a "why this number" explanation. This is a UX requirement, not decoration — it's what makes the owner trust the app enough to stop keeping the manual register.
15. **Use real device testing or at minimum widget tests for the 3-4 critical flows** (new purchase, new sale with stock warning, payment allocation, Godam transfer + spend) in addition to domain unit tests. Don't let "37 tests pass" become the finish line again — tie test names to the specific PRD scenarios they verify.

## 2. What To Avoid

1. **Do not treat Parties/Bills/Stock/Cash as independent CRUD modules.** They are one connected ledger. If you find yourself writing a screen that updates Stock without going through a Bill use-case, stop.
2. **Do not implement average cost as a lifetime average of all purchases ever.** This was likely wrong or ambiguous in the original build and is explicitly the *wrong* formula per this spec — it must exclude already-sold stock.
3. **Do not auto-allocate payments (no automatic FIFO-bill-matching).** The owner wants manual control here — building "smart" auto-allocation is scope creep that contradicts a direct requirement.
4. **Do not hard-block sales that exceed stock.** This is a deliberate, confirmed business decision (selling ahead of physical receipt happens in this trade) — don't "improve" this into strict validation.
5. **Do not build multi-Godam / multi-location physical inventory tracking.** Confirmed out of scope — Godam is a cash-state concept only. Resist the urge to generalize this into a full warehouse-management feature.
6. **Do not build multi-device real-time sync/conflict resolution.** Supabase is backup/restore only. Don't build operational-transform or CRDT-style merge logic — it's unnecessary complexity for a confirmed single-device-primary use case.
7. **Do not upload bill photos anywhere**, under any sync/backup/"just in case" rationale. Local only, permanently.
8. **Do not use native alert dialogs (`AlertDialog` harsh red styling, shake animations, aggressive haptics) for errors or confirmations.** Use calm bottom sheets / inline banners consistent with the design system.
9. **Do not hardcode expense categories or stock categories as a fixed enum with only 3 values.** Both must be user-extendable (Bura/Degi Bura/Scrap are seeds, not the ceiling; Salaries/Food/Electricity are seeds, not the ceiling).
10. **Do not let "tests pass" or "build succeeds" substitute for a business-logic review against this PRD.** Before calling any phase done, re-read the relevant PRD section and manually trace at least one worked numeric example through the actual running app.
11. **Do not add complex RBAC, multi-user accounts, or login/signup flows.** Admin PIN + optional View PIN, full stop — this was explicit in the original brief and remains explicit here.
12. **Do not silently swallow transaction failures.** If a use-case transaction fails partway, the whole thing must roll back — never leave stock updated but the bill unsaved, or vice versa.
13. **Do not build features not in this PRD** (multi-currency, GST/tax filing, barcode scanning, push notifications) without an explicit new requirement — these are named out-of-scope for a reason: keep v1 shippable.
14. **Do not use `double`/`float` for any currency or weight value, anywhere** — not in the DB, not in domain calculations, not in intermediate variables. Floating-point drift is exactly what causes the zero-stock reset rule to silently fail (a quantity of `0.0000000000000001` never equals zero) and prevents cash from cleanly reconciling. Integers (Paisa, Grams) only, converted to display units at the last possible moment.
15. **Do not give sub-categories their own stock quantity or cost basis.** This is the single easiest way to accidentally reintroduce the exact bug this rebuild is meant to fix — a category silently going negative because an untagged sale drew from the "wrong" bucket.
16. **Do not delete a `Payment` row to handle a bounced/reversed payment.** Use the reversal flow (rule 24 above) — deleting breaks the audit trail and is exactly the kind of shortcut that erodes trust in the app as the source of truth.
17. **Do not create a duplicate `CashMovement` when allocating an existing advance balance to a bill.** This is called out separately because it's a subtle, easy-to-miss double-count — the cash moved once, at the time the advance was originally recorded.
18. **Do not rely on Flutter widget visibility/disabled-state alone for View-mode security.** A hidden button is a UX nicety; the actual gate is in the use-case layer.
19. **Do not run a schema migration without a pre-migration vault step**, even for what seems like a trivial/additive migration — local SQLite is the only copy of a live business's data at that moment.

## 3. Libraries — Approved List (do not substitute without reason)

| Purpose | Library | Notes |
|---|---|---|
| Local DB | `drift` | Do not use raw `sqflite` directly — lose type safety and reactive streams |
| State | `flutter_riverpod` | Do not mix in `provider` or `bloc` — pick one paradigm |
| Backup/sync backend | `supabase_flutter` | Metadata/backup only |
| Secure local storage | `flutter_secure_storage` | For PIN hash |
| Charts | `fl_chart` | Confirm color contrast against WCAG AA before shipping any chart |
| Sharing | `share_plus` | Native share sheet |
| Receipt/image rendering | `screenshot` (widget-to-image) or `CustomPainter` | Either is fine; pick one and stay consistent |
| Testing | `flutter_test`, `mocktail` | No new test framework needed |
| CI | GitHub Actions (existing) | Keep analyze → test → build pipeline |
| UUID generation | `uuid` (v4) | Used for every primary/foreign key at record-creation time — never DB auto-increment |

Do not introduce new state-management, DB, or backend libraries mid-project without updating this file and getting explicit confirmation — churn here is exactly how the first build likely lost coherence.

## 4. Error Handling Standards

- All domain use-cases throw typed exceptions from a single `AppException` hierarchy (e.g. `InsufficientStockWarning` [non-blocking, informational], `CashOverdraftWarning` [non-blocking, informational], `UnauthorizedException` [View-mode blocked a mutation], `TransactionFailedException`, `ValidationException`), never raw strings or generic `Exception`.
- UI layer catches typed exceptions and maps them to calm, specific copy via a single mapping table in `core/errors/` — never construct user-facing error text ad hoc inside a widget.
- Warnings (like negative stock) are **not** exceptions that block flow — they are a confirmation step the use-case surfaces back to the UI (return a "needsConfirmation" result type), letting the user proceed deliberately.
- Any transaction failure must be caught, rolled back, logged (locally, for the owner's own debugging /future support), and surfaced as a calm "Something didn't save — nothing was changed, try again" message. Never a stack trace to the user.

## 5. Boundaries for Ambiguity — Default Decisions

When a requirement is genuinely ambiguous during implementation and re-confirming with the user isn't practical mid-build, default to these (all consistent with the confirmed answers and stated UX philosophy):

- **Ambiguous rate mode**: default new bills to per-bill single rate (simpler), let user switch to per-line explicitly.
- **Ambiguous category for a custom sub-category**: require it to be nested under one of the 3 seed categories (or a future top-level category) — never let a sub-category exist with no parent, since stock rollups depend on this.
- **Ambiguous cash pool for a transaction**: never default silently to Godam — always require explicit pool selection, since this is a place manual bookkeeping errors are common.
- **Ambiguous partial payment amount**: never auto-fill "full amount due" — require the owner to explicitly type/confirm the amount, since partial payments are the norm in this trade, not the exception.
- **Ambiguous margin % for recommended rate**: default to a visible, editable per-category setting (e.g. start at 5%) rather than hardcoding — make it obvious it's editable so it doesn't get mistaken for a fixed system rate.
- **Ambiguous "what counts as this month" for dashboard**: use calendar month by the device's local timezone, not fiscal-year logic, unless told otherwise.
- **When truly stuck between two reasonable interpretations**: build the one that's easier to reverse/extend later, and leave a clear `// ASSUMPTION:` comment at the point of decision so it's easy to find and revisit.

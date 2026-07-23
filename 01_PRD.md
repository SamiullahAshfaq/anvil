# PRD — Scrap/Stock Trading Business Manager
*(working name: "Anvil")*

*(See `06_DESIGN_SYSTEM.md` for the validated visual design reference — an interactive HTML prototype and its extracted color/type/shape tokens. That file is the actual UI spec for this app, not a generic style guide.)*

> **Build status (2026-07-23)** — the financial core (§3 concepts, §4.6 dashboard math, §4.3 costing, §4.4 Godam FIFO, §4.8 reversal, Day-0 onboarding) is implemented and test-proven at the domain layer. **Phase 2 UI**: onboarding + PIN + View-only mode, Parties (list/detail/settlement/edit), New Bill (§4.2 Purchase/Sale/Expense with per-bill/per-line rate, inline sub-category, soft warnings), Bills list + pending filter, image receipt share, Stock (§4.3 cards/recommended-rate/ledger/write-off), and Trash (§4.8 soft-delete + restore). **Phase 3 UI is now complete**: Cash & Godam screen + reconciliation (§4.4), Transfer-to-Godam, Godam ledger with two-tap dynamic FIFO spend-trace, Cash Flow Ledger/Roznamcha with filters (§4.5), standalone payment recording + manual allocation (§4.1/§4.2), allocate-existing-advance, and the non-destructive Payment Reversal/bounce flow (§4.8) — all wired into Party Detail and the drawer. **Phase 4 UI is now complete**: the fl_chart monthly/quarterly profit-trend chart, a Month/Quarter scope toggle, receivables/payables-by-party, and full drill-down from every dashboard number to its source records (§4.6). **57 tests green.** **Not yet built (Phase 5+):** in-place bill *field* editing, Supabase backup/sync (§4.7), and the day/week/month summary-image share (§4.8). Feature-by-feature UI status lives in `04_PHASES.md`; nothing here in the PRD has changed scope.

## 1. What This App Actually Is

This is **not** a generic inventory or invoicing app. It is a **single-user, offline-first ledger and cost-accounting tool** for a scrap/raw-material trading business (Bura, Degi Bura, Scrap + custom sub-categories), where the owner needs to know, at any moment, with zero manual calculation:

- Who owes me money, and who do I owe (per party).
- What is my current stock, per category, and at what true cost basis.
- What should I sell at today, given what I actually paid for what's still in hand.
- Where is my cash — Home, Bank, or Godam — and which transfer paid for which bill.
- Was this month/quarter good or bad, and why.

Everything else (photos, sharing, PIN lock, dark mode) is UX polish around this financial core. **The financial core is the product.** If the numbers are wrong, the app has failed regardless of how it looks.

The previous build failed because it treated this as a CRUD app (Parties, Bills, Stock as independent screens) instead of as a **connected ledger** where every bill is a transaction that must atomically update stock cost-basis, party balance, and cash pool — with correctness enforced at the data layer, not hoped for at the UI layer.

## 2. Target User

- **Primary (and only) persona**: The business owner himself. Sole operator, sole decision-maker.
- Technically comfortable enough to use WhatsApp, banking apps — **not** a spreadsheet power user. Should never see a raw number he has to mentally re-derive.
- Uses the app standing in the Godam or at home, often mid-transaction (party is standing there). Speed of bill entry matters as much as correctness.
- Occasionally hands the phone to a trusted person (accountant, family member) in **View-only mode** — no ability to edit, only to see current state.
- Single device is primary. No concurrent multi-user editing requirement (confirmed).

## 3. Core Domain Concepts (must be modeled correctly — this is where the rebuild has to start)

| Concept | Definition | Why it's not simple CRUD |
|---|---|---|
| **Party** | Supplier, Buyer, or Both. Has a running balance (they owe us / we owe them). | Balance must be a *derived, recomputable* value from ledger entries — never a manually-edited field. |
| **Category** | Bura, Degi Bura, Scrap + user-defined custom sub-categories created inline while billing. | Sub-categories are informal ("Pipe" scrap) but must still roll up into the parent category's stock and average rate. |
| **Bill** | A Purchase, a Sale, or an Expense entry. One bill = one or more line items. | A single bill can mix categories (Bura + Scrap in one sale). Each line item independently affects stock. Rate can be per-line OR per-bill (user's choice per bill — confirmed). |
| **Stock (per category)** | Running quantity + a **moving weighted-average cost** of what's *currently unsold*. | Confirmed: average rate = weighted average of remaining stock only, NOT lifetime average of all purchases ever. Every sale reduces quantity and must **not** change the average cost of what remains (only new purchases change it). **When quantity reaches zero (or goes negative from a soft-allowed oversell), the next purchase resets `avgCost` to that purchase's rate directly** — the standard moving-average formula must not be applied across a zero/negative crossing, or it produces a distorted or negative-multiplied cost. This is standard moving-average inventory costing — get this formula wrong and every downstream number (recommended rate, profit) is wrong. |
| **Sub-Category** | A free-text descriptive tag on a bill line item (e.g. "Pipes", a quality grade). | **Reporting/filtering label only — never a separate inventory ledger.** Quantity, moving-average cost, and stock warnings are calculated and locked strictly at the **parent category** level (Bura, Degi Bura, Scrap, or a user-created parent). A line item tagged "Scrap - Pipes" and an untagged "Scrap" sale both draw from the same Scrap parent stock and cost basis — sub-categories must never fragment inventory into separate silos, or a sale without a tag would incorrectly show the parent going negative while a sub-category sits full. |
| **Cash Pool** | Home, Bank, or Godam. Godam is a **cash state**, not a separate physical stock location (confirmed) — money "moved to Godam" is money earmarked/physically taken there to fund purchases and expenses. | Godam balance must be traceable: which Home/Bank transfer funded which bill (FIFO-traceable, per original ask), so "where did this 20k spend come from" is always answerable. |
| **Payment** | A cash movement tied to a Party, allocated against one or more Bills. | Confirmed many-to-many: one payment can cover several bills; one bill can be paid across several payments over time. Allocation is **manual** — user picks which bill(s) a payment settles (confirmed, no auto-FIFO). Unallocated/advance payments must be representable (party paid in advance, no bill yet). |
| **Trade Register** | The full chronological ledger of every stock-affecting and cash-affecting event. | This is the audit trail dashboard/analytics are built from — it is a materialized view, not a separate manually-maintained table. |

## 4. Features (Detailed, Business-Correct)

### 4.1 Parties
- Create party: name, type (Supplier / Buyer / Both), phone (for WhatsApp share), opening balance (optional, for onboarding existing dues).
- **Day 0 Migration Engine**: since this app onboards an *already-running* Rs. 5M–6M business (not a fresh startup), first-run setup must let the owner inject a real starting position in one guided flow: opening balance dues per party (payable/receivable), starting cash ledger entries for Home/Bank/Godam pools, and baseline quantity + cost basis per stock category. These are recorded as genuine immutable ledger entries (a dated "Opening Balance" bill/movement/stock-entry, not a raw editable number) so the full derived-balance model holds from day one — the business's history before the app existed is compressed into one dated starting point, not treated as a special-cased exception to the ledger rules.
- Party detail screen shows: current balance (owes us / we owe them, signed clearly, never ambiguous), full bill history, full payment history, unallocated advance balance if any.
- **Settlement history tab**: a unified, chronological view combining every advance given, every bill created, and every payment received/paid for that party in one timeline — so a mixed scenario (standing receivable + new purchase bill + partial advance + later payment) is readable in one place rather than reconstructed by cross-referencing separate bill/payment lists.
- Balance is **always derived** — sum of (sale bills - payments received) or (purchase bills - payments made), never a stored/editable number. Receivable and payable are tracked and displayed **as two separate numbers**, never silently netted — a party can simultaneously owe you money from past dealings and be owed money from a current in-progress purchase (see worked example in Appendix-style discussion below).

### 4.2 Billing
Single "New Bill" flow with a type switch: **Purchase / Sale / Expense**. Not three disconnected screens — one entry surface, because in real use the owner doesn't think "which module" first, he thinks "what just happened."

**Pending bills filter**: the Bills list screen supports filtering to "Pending" — any purchase not yet fully paid, or any sale not yet fully collected — so outstanding obligations in either direction are visible at a glance, separate from the fully-settled bill history.

**Purchase:**
- Select/create supplier party.
- One or more line items: category (Bura/Degi Bura/Scrap/custom), optional custom sub-category (free text, created inline), weight, rate.
- Bill-level OR line-level rate — user toggles which mode per bill (confirmed requirement).
- Optional advance payment at time of bill (draws from a chosen cash pool: Home/Bank/Godam).
- On save: increases stock for each category/sub-category at that line's rate (feeds the moving average), increases party payable (what we owe them) by bill total, reduces it by any advance paid immediately.

**Sale:**
- Select/create buyer party.
- Line items: category, sub-category, weight, rate.
- Stock check: soft warning only if the sale would take a category below zero — never a hard block (confirmed). The warning must be calm (per UX principle #8), e.g. "This will put Scrap stock at -12kg — continue?" with Continue/Cancel, not a red alarm modal.
- Payment received at time of sale (full/partial/none), in a specified form (cash/bank), into a specified pool.
- On save: decreases stock at the category's current moving-average cost (for profit calculation — the sale rate is revenue, moving-average cost is COGS), increases party receivable by bill total, reduces it by amount received immediately.

**Expense:**
- Payee: either an existing Party (owner drawing, a person), or a free-standing Expense Category (Salaries, Food, Electricity, Rent, Other — user-extendable list, not hardcoded to 3).
- Amount, cash pool it's drawn from, optional note/photo.
- Does **not** touch stock. Feeds the P&L directly as a cost line.

**All bill types:** optional photo capture (bill/receipt), stored on-device only, never uploaded; date defaults to now but is editable (for back-entry); every bill is shareable as a branded image receipt immediately after save.

### 4.3 Stock
- Per-category card: current quantity, current moving-average cost (per kg **and** per ton — confirmed), sub-category breakdown (collapsible).
- Combined "all stock" card: total value at cost (Σ qty × avg cost per category), suggested blended rate only if it's meaningful (flag if categories are too dissimilar to blend).
- "Recommended selling rate" = average cost + a configurable target margin % (user-settable per category, default e.g. 5%) — shown as guidance, not enforced. This is the single most business-critical number in the app; it must be visibly correct and explainable (tapping it shows the calculation).
- Full stock ledger view: every purchase/sale line item that moved this category's quantity, chronological, with running balance — this is the "show your work" screen for trust.
- **Stock ledger filtered by sub-category tag**: since sub-categories are descriptive labels (not separate inventory), the stock ledger view supports filtering by tag (e.g. show only "Pipes" entries within Scrap) for reporting/analysis purposes — while quantity and avgCost displayed always reflect the parent category as a whole, never the filtered subset.
- **Stock Write-Off / Wastage entry**: a dedicated action to reduce a parent category's physical quantity without a sale — for sorting loss, moisture evaporation, or discarded dross (real-world shrinkage, e.g. buying 1,000kg Degi Bura but ending up with 970kg sellable after sorting). User chooses per entry whether the write-off **absorbs into remaining stock** (redistributes cost across the smaller remaining quantity, so avgCost per kg rises slightly) or **logs as a direct Wastage Expense** on the P&L (quantity drops, cost basis of remaining stock is untouched). Without this, physical stock and app stock silently diverge until the owner stops trusting the app.
- **Parent-level costing lock (critical)**: quantity, avgCost, and the zero-stock reset rule are computed and enforced only at the parent category. Sub-categories are pure tags for filtering/reporting (see Core Concepts table) — they never carry their own quantity or cost.

### 4.4 Cash & Godam
- Three pools: Home, Bank, Godam. Each has a running balance = sum of all movements in/out.
- "Transfer to Godam" action: amount, from (Home/Bank), timestamp. Creates a Godam-funding record.
- Every bill/expense paid *from* Godam draws down against these funding records, oldest-first for traceability (FIFO trace — confirmed as a stated requirement), so any Godam spend can answer "which transfer(s) funded this."
- Godam ledger view: chronological list of fundings in and spends out, running balance, tap any spend to see which bill it was.
- Reconciliation view: Home + Bank + Godam = total cash on hand, shown against what the dashboard's "net worth" implies, so discrepancies surface immediately rather than being discovered a month later.
- **Cash overdraft soft-warning**: if a payment or expense would push Home, Bank, or Godam below zero (common on a busy day — cash paid out before the corresponding transfer is logged), show a calm inline prompt: *"Godam cash will show -Rs. 15,000. Did you forget to record a transfer from Home/Bank?"* with two actions — **Record Transfer Now** (opens the transfer flow inline, then returns to complete the original entry) and **Continue Anyway** (proceeds, pool goes negative, fully visible on the pool balance so it's never silently hidden). Never a hard block — the business must keep moving.

### 4.5 Cash Flow Ledger (Roznamcha)
A dedicated day-wise cash movement view — the digital equivalent of the manual roznamcha register. Distinct from the Godam-specific ledger in §4.4 (which focuses on transfer-in/spend-out FIFO trace); this is the **complete** picture across all three pools.
- Chronological list of every cash movement (in and out), across Home, Bank, and Godam combined, grouped by day.
- Running total shown per day and cumulatively, so "what was my balance at the end of any given day" is always answerable.
- **Filters**: by pool (Home / Bank / Godam), by direction (in / out), by related party (who the cash went to/came from), by related expense category, and by date range (today / this week / this month / custom range).
- Each entry is tappable, drilling down to the source bill, payment, or Godam transfer that caused it — nothing in this view is a dead-end number.
- This is the screen that directly replaces the paper roznamcha: cash went, cash came, cash reverted (payment reversals appear here too), all rolling up to the total balance at day's end.

### 4.6 Dashboard
- Net worth = Cash on hand (Home+Bank+Godam) + Receivables − Payables + Stock value at cost.
- Monthly (and quarterly) profit: Sales revenue − COGS (at moving-average cost, not sale-vs-purchase-rate guesswork) − Expenses. Bar chart, accessible colors, tap a bar to drill into that month.
- Receivables/Payables summary: top parties by balance, total owed to us vs by us.
- Cash reconciliation snapshot (see 4.4).
- Stock value snapshot (see 4.3).
- "What was good / bad this month" — plain-language summary: best-margin category, worst-margin category, biggest single expense, largest outstanding receivable. This is the "enterprise-like" analytics ask from the brief — not just charts, but a narrated takeaway, because the owner wants an answer, not a chart to interpret.

### 4.7 Offline-First + Backup
- 100% functional with zero connectivity — this is not "offline mode as a feature," it is the default and only mode of operation; sync is opportunistic.
- Local database (SQLite via Drift — see architecture doc) is the single source of truth on-device.
- Supabase sync is backup/restore only (confirmed: single-device-primary, not concurrent multi-device). When online, push local changes and pull remote backup state; no real-time collaborative merge logic needed, which significantly simplifies the sync layer versus the original build's likely over-engineering here.
- Bill photos: local file storage only, never uploaded, ever. Sync only pushes the *reference/metadata*, never the image binary, if a photo path is stored in synced tables (or simply exclude photo paths from synced payload entirely).
- Manual "Backup now" action + automatic background attempt when connectivity is detected.
- Restore flow: pairing a new/reinstalled device to pull last backup down.

### 4.8 Sharing + Control
- **Payment Reversal / Bounce flow**: a formal, non-destructive way to reverse a payment that later fails (bounced cheque, failed bank transfer). Reversing a payment: reopens the bill(s) it was allocated to back to their prior unpaid/partial status, logs a reversing cash movement (money leaves the pool it was recorded into), and writes a permanent timestamped note to the party's ledger explaining why the balance jumped back up. The original payment record is never deleted — deleting it would break the audit trail; the reversal is a new, linked, visible event.
- Share single bill as a branded receipt image (native share sheet → WhatsApp, etc.).
- Share day/week/month/custom-date-range summary as an image or text digest.
- Update history: every edit to a Party/Bill/Payment is logged (what changed, old→new, when) and viewable per-record via "View update history" — not shown inline by default (keeps the main UI calm per UX principle).
- Trash: every deletion is soft-delete, recoverable for 30 days, auto-purged after. Trash screen lists deleted items with restore action and days-remaining indicator.
- Access: single 4-digit Admin PIN (full control) + optional 4-digit View-only PIN (read-only, no create/edit/delete, no access to Backup/Trash/Settings). No usernames, no complex RBAC — this is deliberately minimal per the stated requirement.

### 4.9 UI/UX
- Light, dark, and system-follow themes.
- Calm error handling: no red flashing modals, no jarring shake animations. Inline, muted-tone messages; destructive actions (delete) always confirm via a calm bottom sheet, never a native alert.
- Numbers-first typography (monospace for figures) so amounts are always scannable and unambiguous.
- Every screen should answer "what do I do next" without a manual — favor progressive disclosure (advanced fields like custom sub-category collapsed until tapped) over dense forms.

## 5. Explicitly Out of Scope (v1)

To prevent scope creep re-breaking the rebuild:
- Multi-device concurrent editing / real-time collaboration.
- Multi-currency.
- Barcode/QR stock scanning.
- Tax/GST computation or filing integration.
- Multi-Godam / multi-warehouse physical tracking (Godam is a cash-state concept only, per confirmed answer).
- Automated payment allocation (FIFO-auto) — allocation is manual by design.
- Push notifications / reminders (candidate for v2).
- Multi-language UI (candidate for v2, structure for it but don't build it now).

## 6. Success Criteria

The app is "done," for real this time, when the owner can:
1. Enter a real purchase and real sale for a full trading day in under the time it currently takes him to write it in a register.
2. Look at the Stock screen and trust the recommended rate enough to actually quote it to a buyer without mentally re-checking it.
3. Look at the Dashboard at month-end and not need his manual register to sanity-check the profit number.
4. Answer "where did this Godam spend come from" in two taps.
5. Go a full week with zero internet and never notice a difference.

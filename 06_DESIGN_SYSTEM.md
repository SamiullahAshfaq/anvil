# Design System — extracted & validated from the Claude Design prototype

> **Implementation note (2026-07-23)** — the gaps listed in §5 below were
> identified against the HTML prototype, not against built code. As of Phase 4,
> items 1–7 and the profit chart (item 10) have all been implemented directly in
> Flutter
> (following this doc's tokens) rather than first added back to the HTML
> prototype — see the per-item notes in §5 and `04_PHASES.md`/`05_MEMORY.md` for
> what actually shipped. The HTML prototype itself was not regenerated to match;
> treat it as the original visual reference, not a live mirror of the app.

## Important note on the two design inputs you provided

You gave two files. They are **not equivalent** and should not both be handed to a coder as-is:

| File | What it actually is | Verdict |
|---|---|---|
| `DESIGN.md` | A reverse-engineered style guide of **Coinbase's public marketing website** (hero bands, 80px display headlines, pricing tiers, footer link columns, "Sign Up" nav CTAs) | **Not usable as an app design spec.** This documents a content-marketing site, not a mobile app UI. Handing this to Claude Code would produce editorial hero sections, not app screens. |
| `Godam_Ledger_dc.html` | A real interactive **mobile app prototype** (Android device frame, 412×892, light/dark toggle) covering Dashboard, Parties, Party Detail, Bills, Cash & Godam, Stock, Stock Ledger, Expense, Update History, Trash, Backup, PIN unlock, and a Godam spend/reversal detail view | **This is your actual design spec.** It's screen-accurate, uses a much smaller and more sensible token set than `DESIGN.md`, and matches the PRD's actual feature list. |

**Your instinct was right that "the overview is ok"** — that's because the HTML, not the markdown, is the real design. `DESIGN.md` only donated the *brand feel* (Coinbase Blue accent, pill shapes, calm minimal type) — the HTML is where that feel was actually correctly translated into app-specific screens.

**What to give Claude Code**: this file (`06_DESIGN_SYSTEM.md`) + the HTML prototype file. Do not give it `DESIGN.md` directly — it will pull in marketing-site patterns (hero bands, pricing tiers) that don't apply to an app and aren't in your PRD.

---

## 1. Validated Color Tokens (actually used in the prototype)

Only these tokens appear in the working prototype — this is the real palette, far smaller than `DESIGN.md`'s marketing set:

| Token | Purpose | Light mode (typical) | Dark mode (typical) |
|---|---|---|---|
| `c.canvas` | Page/screen background | `#ffffff` | near-black |
| `c.card` | Card surface | `#ffffff` | elevated dark gray |
| `c.surfaceSoft` | Soft background block (e.g. "this month in plain terms") | light gray | dark elevated |
| `c.surfaceStrong` | Pills, icon-circle backgrounds, filter tabs | `#eef0f3`-ish | darker gray |
| `c.surfaceDark` | Net worth card (always-dark treatment, in both themes) | `#0a0b0d` | `#0a0b0d` |
| `c.surfaceDarkElevated` | Chips inside the dark net-worth card | slightly lighter than surfaceDark | same |
| `c.ink` | Primary text | near-black | near-white |
| `c.body` | Secondary/paragraph text | `#5b616e`-ish | light gray |
| `c.muted` | Captions, labels, hints | `#7c828a`-ish | mid gray |
| `c.hairline` | Card borders | `#dee1e6`-ish | subtle dark border |
| `c.hairlineSoft` | Row dividers within a card | lighter than hairline | subtler |
| `c.primary` | Coinbase Blue — the single accent color | `#0052ff` | same (accent stays consistent across modes) |
| `c.onDarkSoft` | Muted text on the always-dark net-worth card | `#a8acb3`-ish | same |
| `c.semanticUp` | Positive amounts (receivable, profit) | green | green |
| `c.semanticDown` | Negative amounts (payable, loss) | red | red |

**Rule carried over correctly from `DESIGN.md` and worth keeping**: `c.primary` (Coinbase Blue) is the **only** accent color. It appears on the logo mark, primary actions, and links — never as a second/third brand color competing with it. Semantic green/red are reserved strictly for financial polarity (receivable vs payable, profit vs loss), never used as decorative color.

## 2. Typography

- **Inter** for all UI text (this is a deliberate, correct substitution — the prototype does not use Coinbase's licensed typefaces, it uses actual open fonts, which is what your build needs anyway).
- **JetBrains Mono** for every numeric value — amounts, weights, dates in ledgers. This was called out in your original PRD/design intent and the prototype honors it consistently: net worth, cash pool balances, party balances, bar chart values are all in mono.
- Weights used: 400 (body), 500 (numbers, sub-labels), 600 (headings, primary labels). No 700/bold seen in the working prototype — consistent with a calm, non-shouty financial app tone.
- Sizes actually used range roughly 10px (tiny chip labels) → 32px (net worth headline). No 80px display-mega, no 64px hero type — none of `DESIGN.md`'s marketing-scale type appears, correctly, because this is an app not a landing page.

## 3. Shape & Elevation

- **Pill radius (9999px / 100px)** for: theme toggle, filter tabs, chips inside the net-worth card, back-button circle, avatar/initial circles.
- **24px radius** for: the net-worth hero card, monthly-profit chart card, "this month in plain terms" block — the primary content cards.
- **18–20px radius** for: secondary cards (party rows, cash pool mini-cards).
- **1px hairline border** (`c.hairline`) on all light-surface cards — no drop shadows anywhere in the prototype. This matches the "flat, calm" UX principle from the PRD — no jarring depth effects.
- The **always-dark net-worth card** (regardless of light/dark theme) is a deliberate, good pattern: it visually anchors the most important number on the screen (net worth) with the highest contrast treatment, consistently, in both themes.

## 4. Screens Covered by the Prototype (validated against the PRD)

The prototype's screen states map directly onto PRD §4 features:

| Prototype state (`isX`) | PRD section it covers |
|---|---|
| `isDashboard` | §4.6 Dashboard — net worth, monthly profit chart, receivables/payables, cash pool snapshot, plain-language takeaway |
| `isParties` | §4.1 Parties — list, receivable/payable totals, filter pills |
| `isPartyDetail` | §4.1 Parties — individual party balance/history, settlement history tab |
| `isBill` | §4.2 Billing — bill entry/detail |
| `isCash` | §4.4 Cash & Godam |
| `isSpend` | §4.4 Godam FIFO trace ("view source" of a spend) |
| `isStock` | §4.3 Stock |
| `isStockLedger` | §4.3 Stock ledger drill-down |
| `isExpense` | §4.2 Expense entry |
| `isHistory` | §4.8 Update history |
| `isTrash` | §4.8 Trash / 30-day recovery |
| `isBackup` | §4.7 Backup & Sync |
| `isPin` | Onboarding / PIN unlock |
| `isReversed` | Payment reversal state (from the 13-point hardening pass) |
| `isMore` | Drawer/settings overflow |
| `isRoot` | App shell / navigation root |

**Not yet in the prototype but in the current PRD** (added after this prototype was likely built): §4.5 Cash Flow Ledger (Roznamcha, day-wise filterable view), the Settlement History tab on Party Detail, and the Stock Write-Off/Wastage entry — see §5 below.

**This is a strong, near-complete screen inventory** — it already reflects the hardened spec, not just the original PRD (the reversal state and Godam spend-trace view are both present, which are v2 additions from your hardening checklist).

## 5. What's Genuinely Missing or Needs Refinement (for your coder to fill in)

Being honest about gaps, since you asked what to include beyond what's there:

1. **New Bill entry flow (the actual form)** — the prototype shows bill *detail/receipt* view states (`isBill`, `isExpense`) but the multi-line-item entry form itself (add line, pick category, tag sub-category, toggle per-bill/per-line rate) isn't fully fleshed out as an interaction — this needs real form design, not just a states list. **✅ Built (Phase 2)** — `presentation/bills/new_bill_screen.dart`.
2. **Stock Write-Off / Wastage entry screen** — not present in the prototype (this was added in the hardening pass, after the prototype was likely built). Needs a new screen: parent category picker, weight, absorb-vs-expense mode toggle. **✅ Built (Phase 2)** — `presentation/stock/write_off_sheet.dart`.
3. **Cash overdraft soft-warning UI** — not present. Needs the actual calm confirmation-sheet component ("Record Transfer Now" / "Continue Anyway"). **✅ Built (Phase 2/3)** — `showWarningsSheet` in `shared_widgets/calm_sheet.dart`, round-tripped from bill payments, standalone payments, and Godam transfers.
4. **Day-0 Migration / onboarding flow** — the `isPin` state suggests first-run PIN setup exists, but the guided opening-balances-and-stock entry flow isn't in the prototype. This is a multi-step onboarding wizard that needs its own screens. **✅ Built (Phase 2)** — `presentation/onboarding/day_zero_screen.dart`.
5. **Payment allocation UI** (many-to-many, manual) — needs a dedicated "select which bill(s) this payment settles" interaction; not clearly present as its own state. **✅ Built (Phase 3)** — `presentation/payments/new_payment_screen.dart` (new payment) and `allocate_advance_screen.dart` (existing advance).
6. **Cash Flow Ledger (roznamcha) with filters** — the day-wise, filterable cash movement view (now PRD §4.5) isn't in the prototype; `isCash`/`isSpend` cover Godam-specific trace but not the full cross-pool filterable ledger described there. **✅ Built (Phase 3)** — `presentation/cash_godam/roznamcha_screen.dart` (pool/direction/party/expense-category/date-range filters, day-grouped with running balance).
7. **Settlement history tab on Party Detail** — the unified advances+bills+payments timeline per party (now PRD §4.1) needs to be added to `isPartyDetail`. This matters especially for the bidirectional-balance case: a party can simultaneously have a standing receivable (they owe you from before) and an in-progress payable (you owe them for a current purchase) — the design must show both numbers clearly side by side, never silently netted into one figure. **✅ Built (Phase 2)** — the Settlement tab in `presentation/parties/party_detail_screen.dart`; Phase 3 added tap-to-reverse on payment rows there.
8. **Empty states** — no evidence of empty-state screens (new user, zero bills yet, zero stock) — these matter for first real use. **Partially built** — e.g. `parties_screen.dart`'s `_Empty`, `godam_ledger_screen.dart`'s empty state; not yet audited across every screen.
9. **Error/validation states** — the calm-error-copy principle needs actual visual treatment (inline banner component) somewhere in the prototype; not clearly present as a distinct state. **✅ Built (Phase 2)** — `showCalmError`/`showCalmInfo` in `shared_widgets/calm_sheet.dart` + `core/errors/error_copy.dart`.
10. **Accessibility check on the chart** — PRD calls for "accessibility-validated colors" on the profit bar chart; worth explicitly re-checking contrast on the `monthlyBars` treatment before finalizing. **✅ Built (Phase 4)** — `presentation/home_dashboard/profit_chart.dart` (`ProfitChart`, `fl_chart` `BarChart`): Coinbase-Blue bars for profit / semantic-red for a loss period, both clearing WCAG AA graphical-object contrast on the card surface, and crucially each bar carries a text value label (and tooltip) so colour is never the sole information channel. A formal light/dark re-check remains folded into the Phase-5 accessibility sweep, but the shipped chart follows the token rules (blue-only accent + polarity-only red).

## 6. Recommendation

- **Use `Godam_Ledger_dc.html` as the actual design reference** for Claude Code — it's screen-accurate and already speaks the right visual language.
- **Do not pass `DESIGN.md` to the coder** as a primary spec; if anything, keep it only as a one-line brand note ("accent color is Coinbase Blue `#0052ff`, pill shapes, calm minimal type — see the HTML prototype for actual app screens").
- **Go back to Claude Design** with the 10 gaps above (§5) as a follow-up brief — ask it to extend the existing prototype with these specific missing screens/states, rather than starting a new design from scratch. This keeps visual consistency with what you already validated and liked.
- Once those 10 gaps are filled in an updated HTML prototype, that becomes the final design handoff artifact alongside this document.

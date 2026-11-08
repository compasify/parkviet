# POS UI polish — 2026-11-05

## Brief
- Register: Product.
- Scene: Vietnamese supermarket cashier on a desktop or touch tablet; frequent repeat actions under time pressure. Clear, calm, practical.
- Direction: Preserve the accepted blue/white wireframe. Compact order strip, bounded catalog, editable basket and a distinct checkout column.
- Color: Restrained; background oklch(0.96 0.01 240), ink oklch(0.29 0.04 245), accent oklch(0.45 0.13 250).
- Type: System sans-serif, three weights, tabular money, hierarchy through size/weight rather than decoration.
- Signature: Blue register header and a single prominent checkout action; product selection stays adjacent to the basket.
- Dials: variance 2/10, motion 1/10, density 7/10.

## Scope and guardrails
- Frontend presentation, feedback and discoverability only; server totals, revision/lease, idempotency and tender evidence stay authoritative.
- Format money for Vietnamese readers without rounding canonical values.
- Progressive disclosure for advanced sale lines, customer creation, discounts and financial reconciliation.
- Do not invent product images, enable debt/card/gateway operations, restart the developer's server or change their data.
- Verify empty/read-only/error, desktop/tablet/mobile, quantity edits, search, payment confirmation and recovery regressions.

## Delivered
- Compact header picker (outside click / Escape closes it; choosing a register dismisses it), compact order strip and a separate two-column selling/checkout surface.
- Debounced authorized catalog search, F2 focus shortcut, clickable compact product cards, list view, explicit unknown stock and a bounded catalog scroll area.
- Server-backed basket with quantity steppers, exact manual entry + Enter/save, aligned line amounts, inline failure feedback and an explicit delete action. Advanced pricing is only shown to authorized staff.
- Walk-in customer by default; customer search/creation is progressively disclosed. Quantity changes no longer remount the customer search.
- Currency display uses server strings without float conversion. VND is displayed as `125.000 ₫`; no prices or totals are calculated optimistically in the selling UI.
- Payment methods are selectable tiles; remaining server amount is prefilled, the next action is prominent, and tender evidence/confirmation is still a separate mandatory step. Reconciliation and history are secondary.
- Removed the misleading nonfunctional “transfer register” button; actual completed-order fulfillment remains the separate guarded action in the payment panel.
- Old-currency shifts are explicitly identified; no old shifts/orders/currencies are rewritten.
- Mobile has a clearly labeled jump to checkout, not a second settlement action.
- Advanced unit/traceability forms mount only on disclosure; browsing 12 products does not fetch 12 sets of unit/traceability metadata.

## Verification
- `vitest run`: 32 passing unit tests, including exact large-decimal formatting and translation-key parity.
- Playwright: 27 passing mocked cases across desktop 1280×800, tablet 768×1024 and mobile; six opt-in live-API cases skipped. No mocked success is presented as a completed real transaction.
- New `e2e/ui-polish.spec.ts` checks debounced search, F2, lease guards, quantity increments/manual edits, revision/idempotency fields, server rejection preserving amounts, lazy unit fetch, zero horizontal overflow and visible interactive targets at least 44px.
- Typecheck/lint/build pass. Build still reports a >500kB JS chunk warning; bundle splitting was not part of this UI polish.
- Inspected the authenticated running POS and its real VND branch catalog. Switched browser selection to Quầy Hiền - VND; no transaction, database change or developer-process restart for this task.
- `render-check.mjs` ran against the exported UI fixture at 375×812, 768×1024 and 1440×900: zero errors, 19 heuristic warnings. The warnings are intentionally clipped screen-reader labels/skip link and hidden native-details content. Actual-visible-control geometry is asserted separately in Playwright (all pass). This is not a full WCAG audit.
- Screenshot artifacts are in `apps/pos/test-results/`: `pos-render-check/` (three widths) and `ui-polish-*/` (interactive layout and advanced/empty state). These files use labeled test fixtures, not fabricated live sales.

## Visual critique (self-assessed, 22/24)
Three weakest initial areas were excessive card height, checkout actions below the fold and touch-control sizing. Advanced controls were reduced to a disclosure, checkout secondary controls were paired, and touch targets were measured and fixed.

| Area | Score / 2 | Evidence / limitation |
|---|---:|---|
| Brief fidelity | 2 | Blue register header, white selling panels and checkout column preserve the accepted wireframe. |
| Hierarchy | 2 | Product search leads; basket is reachable without traversing the full catalog; one primary payment step. |
| Spacing rhythm | 2 | Shared 4/8/12/16/20/24px scale; advanced forms do not occupy default card space. |
| Alignment | 2 | Aligned basket controls and right-aligned tabular money. |
| Typography | 2 | One sans-serif family; distinct subtotal, total and supporting metadata weights. |
| Color discipline | 2 | Blue denotes selection/action; amber/red are reserved for guard/recovery states. |
| Depth/shape | 2 | Shared small radius and hairlines; shadows reserved for overlays/mobile jump. |
| States/feedback | 2 | Read-only, empty, disabled, loading, rejection and payment-evidence states exercised. |
| Responsive | 2 | Two columns on tablet/desktop, one on mobile with checkout jump; no horizontal overflow in tested widths. |
| Visual restraint | 2 | No ornamental charts, gradients, fake photos or invented business metrics. |
| Copy | 1 | Main actions are cashier-friendly, but advanced accounting/traceability terminology still needs domain-user validation. |
| Craft/assets | 1 | Consistent SVG icons and precise money; product-image URL is not yet in the catalog contract, so honest placeholders remain. |

## Remaining boundaries
Debt, card gateways and real-money readiness are not implemented or qualified by this work. Product photos require an authorized API contract. Live lost-response/concurrent-settlement qualification remains separate. Cashier acceptance of the revised design is still required.

## Cross-page consistency — 2026-11-05

### Brief extension
- Register: Product; preserve the accepted selling UI rather than introduce another visual direction.
- Scene: Store staff signing in, configuring access or reviewing received funds on desktop, tablet and mobile.
- Direction: The same blue header, tinted gray background, white hairline panels, 6px radius and 44px controls as the register.
- Color/type/signature: Reuse the selling tokens and system sans-serif; no green authentication theme, marketing art or large development banner.
- Dials: variance 2/10, motion 1/10, density 6/10 on management pages.

### All routes covered
| Route | Result |
|---|---|
| `/pos/login` | Shared blue header and background, centered white login panel, clear field grouping, accessible password toggle, pending/failed authentication feedback and discreet staff-access guidance. |
| `/pos/` | Accepted selling layout retained; auth, lease, recovery, quantity and split-tender regression cases pass. |
| `/pos/settings` | Shared page navigation/title; existing branches and memberships before disclosed creation forms; separate explicit branch selection for membership assignment. Loading, empty, failure, permission and saved states. |
| `/pos/funds` | Scoped list/detail layout, formatted server money, readable statuses, allocation history and disclosed payout controls. Collection-only staff remain read-only. |
| `/pos/payment-attention` | Same ledger/detail frame, canonical-zero filtering (`0`, `0.0`, `0.00`), explicit current-page filter scope and pagination. No success/empty state is substituted for API failure or denied access. |

### Shared behavior and boundaries
- `PosPage` / `PageState` centralize navigation, page headings and feedback; login uses the same `.pos-layout` tokens.
- Shell title and skip-link target follow the route; the open-shift form remains sale-only. The header picker now closes on navigation so it cannot cover destination-page controls.
- Selected fund and payout forms reset on store/staff/branch/permission changes. Detail data must match the selected branch before being displayed.
- On stacked mobile/tablet layouts, selecting a fund moves focus/scroll to its detail heading rather than silently updating content below the list.
- `useReceivedFunds` accepts an optional page (default remains 1); existing payment-panel callers and financial invalidation prefixes are preserved. Attention filtering is limited to each loaded page and says so explicitly.
- No financial endpoint, evidence field, idempotency/recovery flow or server total was replaced with a mock implementation. No real financial write, logout of the user's browser, API data modification or restart of port 5174 was performed for this cross-page work.

### Verification after cross-page changes
- **45 Playwright cases passed**, desktop/tablet/mobile; **6 opt-in real-API cases skipped**. Includes 18 new cross-page cases for auth, navigation, membership form scope, exact money, zero filtering, pagination, branch detail reset, loading/error/empty/detail failure, denied direct URLs and collection-only access.
- **32 unit tests passed**; typecheck, Biome and production build passed. The existing >500kB JS-chunk warning remains (about 577kB minified); no bundle splitting in this scope.
- Interactive screenshots/assertions verify no horizontal overflow and >=44px visible control hit areas, using checkbox labels as their hit areas. Screenshots include opened settings and payout forms as well as denied and error states.
- `render-check.mjs` ran on exported UI fixtures for all four updated routes at **375×812, 768×1024 and 1440×900**: **0 errors**. Login has **0 warnings**; each authenticated page has 10 heuristic warnings across the three widths for screen-reader/skip-link clipping and hidden-details or checkbox targets. The checkbox labels and actual visible controls pass the separate interactive geometry checks. These are not claims of a complete accessibility audit.
- Artifacts: `apps/pos/test-results/render-{login,settings,funds,attention}/` and `apps/pos/test-results/pages-polish-*/`. These screenshots use isolated, labeled fixtures, not evidence of real settlement.

### Rendered self-review
The three weakest interaction details were fixed before final verification: password-toggle hit height, the header picker covering destination controls, and stacked ledger detail updates occurring out of view.

Self-assessed **22/24** using the same rubric above: brief fidelity, hierarchy, spacing, alignment, typography, color, shape, states, responsive layout and restraint score 2/2 each. Copy and assets remain 1/2 each: advanced finance labels still need cashier acceptance, and product photography remains unavailable from the catalog contract. Those limitations do not block visual consistency of the four secondary routes.

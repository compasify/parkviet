# POS selling app

This Vite + React app is the counter. It covers counter work only:

- selling (`/`), returns and exchanges (`/returns`), receipt reprint and lookup
  (`/receipts`) and the customer display (`/display`, no staff session);
- the cashier's own shift (`/shifts`): open it, request cash in/out, withdraw
  their own requests and close it with a blind count;
- collecting a debt payment into the cashier's open shift (`/collect`).

Back office lives in the POS dashboard (`apps/pos-dashboard`): orders,
deliveries, funds and payment attention, other people's shifts and cash request
confirmation, closures and late cash, receivables and reminders, credit
accounts and approvals, inventory traceability, reports and every setting. Do
not add those screens here. The account menu's "Quản trị" group links to them
(`src/lib/dashboard-pages.ts`, built with `posDashboardUrl` from
`src/lib/pos-dashboard-url.ts`), opening in a new tab and listed only for staff
with the capabilities the page needs. Counter screens that point at back-office
work link to the dashboard the same way.

Pure POS logic shared with the dashboard belongs in `packages/pos-shared`.
Modules in `src/lib` that only re-export it stay while this app imports them.

## Run and verify

Run the API through `pnpm spree dev --no-open` from the repository root. In this
directory: `pnpm dev` (port 5175), `pnpm typecheck`, `pnpm lint`, `pnpm test`,
`pnpm test:e2e` (Playwright with mocked API routes; the real-API runs are
opt-in, see `e2e/support/live.ts`).

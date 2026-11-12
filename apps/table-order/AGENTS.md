# Table QR order page

This Vite + React app is what a guest's phone opens from the QR code on a
table or in a room: the menu, an item with its options, the cart, and "Bàn
của tôi" (this phone's orders, the table's lines, calling staff, asking for
the bill). It takes no money and never writes to a table's order: guests'
orders wait for staff (`server/app/workflows/spree/pos/guest_orders/`).

- The server serves the build at `/table/` (`server/Dockerfile`,
  `Spree::Pos::TableOrderAppController`), same origin as the guest API.
- It talks only to `/api/v3/pos_guest/*` (`server/openapi/pos-guest.yaml`)
  with `Authorization: Guest <token>`. The token and the table's code stay
  in `sessionStorage`; neither is ever put in a URL.
- Keep the bundle small: no imports from `apps/pos` or `packages/pos-shared`,
  no router or query library. The option rules in `src/lib/modifiers.ts`
  follow the counter's (`apps/pos/src/lib/menu-selection.ts`).

## Run and verify

Run the API through `pnpm spree dev --no-open` from the repository root. In
this directory: `pnpm dev` (port 5177, opens at `/table/t/<code>`),
`pnpm typecheck`, `pnpm lint`, `pnpm test`, `pnpm build`, and
`pnpm test:e2e` (Playwright with a mocked guest API on port 5178).

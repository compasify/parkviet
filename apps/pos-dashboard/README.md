# ParkViet POS administration

Standalone React administration application using Spree dashboard-core/UI **6.0.3**.
It runs separately from the cashier app (5175) and Spree dashboard (5173).

## Local development

Start the API from the repository root using `pnpm spree dev --no-open` (or use the
developer's existing stack), then:

```sh
cd apps/pos-dashboard
pnpm install
pnpm dev
```

Open **http://localhost:5176** and sign in with a staff/admin account. The first
accessible store is selected; the sidebar's store switcher supports other stores.
Session restoration uses Spree's HTTP-only refresh cookie. POS configuration
access requires `read_pos_topology` or `write_pos_topology`; a branch manager with
`pos.topology.manage` can access only that branch's features and business model.

```sh
pnpm typecheck
pnpm lint
pnpm test
pnpm build
pnpm test:e2e --project desktop
```

E2E tests are in `e2e/`; Playwright starts its own strict-port 5176 server and runs
one worker. Do not leave a separate dev server occupying that port when running
the suite. Desktop, tablet and mobile projects are configured. Do not remove the
cashier's old settings pages until all migrated screens pass the cutover gate.

## Public build-time environment

| Variable | Default | Purpose |
|---|---|---|
| `VITE_SPREE_API_URL` | empty | Public API origin; empty uses same-origin `/api` |
| `VITE_API_PROXY_TARGET` | `http://localhost:3000` | Vite development proxy target for `/api` and `/rails` |
| `VITE_BASE_PATH` | `/` | Public mount path, e.g. `/pos-admin/`; rebuild when changed |

All `VITE_*` values are embedded in browser assets. **Never put API secrets,
database credentials, staff tokens or private keys in VITE variables.**

Branch selection uses `?branch=...&register=...`; branch-resource routes also carry
`$branchId`. Query caches include store identity, and staff permissions refetch on
store switches. No server schema or capability model is changed by this app.

## Separate static production deployment

Build with `pnpm build` and deploy `dist/` as a separate static site. No deployment
is performed by the local implementation/verification workflow.

1. Configure public `VITE_SPREE_API_URL` and `VITE_BASE_PATH` **before** the build.
   For the recommended same-origin topology leave the API URL empty and reverse
   proxy `/api/*` and `/rails/*` to Rails. The Vite proxy is development-only.
2. Serve existing assets normally and rewrite application routes to `index.html`
   (SPA fallback), including `/<store>/settings/receipt-templates/<id>`. Under a
   subpath, serve assets and apply the fallback beneath that same base path.
3. Use HTTPS in production. Cross-origin API deployments need correct CORS with
   credentialed requests, and the dashboard's exact origin must be registered in
   Spree Allowed Origins for `StaffSessionOriginGuard`. Production refresh-cookie
   `SameSite=None; Secure` behavior requires HTTPS; do not bypass the origin guard
   or move refresh tokens into browser storage.
4. Verify login, reload/refresh, logout, store switching and permissions against
   the production proxy/origin configuration. Check `/rails` image URLs too.
5. At the separately gated POS cutover, set the cashier build's public
   `VITE_POS_DASHBOARD_URL` to this site's URL and **rebuild/redeploy the cashier**.
   Changing host environment alone does not update an already-built Vite bundle.

Keep deploy domains in environment configuration, not application source. See
`AGENTS.md` for extension and API-hook conventions.

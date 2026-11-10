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
the suite. Desktop, tablet and mobile projects are configured.

The cashier app (`apps/pos`) no longer has settings or setup pages; its user menu,
sign-in screen and setup notice open this app in a new tab.

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

Build with `pnpm build` and deploy `dist/` as a separate static site, the same way
the cashier app is deployed on its own port. `pnpm preview` serves the build on
the fixed port **5176** with the same `/api` and `/rails` proxy as `pnpm dev`, which
is enough to check a build locally. Mapping a domain to the port is infrastructure
work; no domain appears in the source.

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
5. Set the cashier build's public `VITE_POS_DASHBOARD_URL` to this site's URL
   (including the base path) and **rebuild/redeploy the cashier**. Changing host
   environment alone does not update an already-built Vite bundle; without the
   variable a production cashier build hides its administration links.

### Infrastructure checklist for a new domain

- Point the domain at the static site (port 5176 or the hosting of `dist/`), with
  HTTPS and the SPA fallback above.
- Add the exact origin to the store's **Allowed Origins** in Spree. Without it,
  refresh and logout are rejected by `StaffSessionOriginGuard`
  (`server/config/initializers/staff_session_origin.rb`) and users are signed out
  on every reload.
- Set `VITE_POS_DASHBOARD_URL` for the cashier build and redeploy it.

### After deploying

1. Sign in, reload the page and confirm you are still signed in.
2. Open a deep link such as `/<store>/settings/receipt-templates` directly; it must
   load, not 404.
3. Sign out and confirm protected URLs return to the sign-in page.
4. From the cashier, open the user menu → Cấu hình: the dashboard opens in a new
   tab on the same store and branch.
5. Sign in as a branch manager: only Features and Business model are visible.

Keep deploy domains in environment configuration, not application source. See
`AGENTS.md` for extension and API-hook conventions.

---
name: spree-storefront
description: Use when the user is working on the optional Next.js storefront for Spree 6 (the customer-facing store in `apps/storefront/`, github.com/spree/storefront) — adding a page, customizing checkout, fetching products, multi-region URLs, the wholesale/B2B portal, transactional emails from webhooks, storefront tests, or integrating any frontend with the Store API via `@spree/sdk`. Common phrasings include "customize storefront", "Next.js storefront", "frontend changes", "PDP", "product page", "cart", "checkout flow", "order confirmation page", "@spree/sdk", "publishable key", "country/locale URLs", "wholesale portal", "storefront emails", "webhook route". Provides the storefront architecture, the @spree/sdk integration model, and the storefront-vs-backend decision tree.
---

# Spree Storefront (Next.js)

The Spree Next.js storefront is a separate app that talks to the Spree backend over the v3 Store API (`/api/v3/store/*`) using `@spree/sdk` 2.x. `create-spree-app` puts it in `apps/storefront/` (next to `server/` and `apps/dashboard/`); or fork https://github.com/spree/storefront. Next.js 16, React 19, Tailwind 4.

The storefront is **optional** — any frontend (Astro, Remix, React Native, …) can use the same Store API. This skill assumes the official storefront; the API contract is identical for any client.

## Architecture — server-first

```
Browser → Server Action (src/lib/data/*) → @spree/sdk → Spree Store API
          httpOnly cookies (JWT, refresh token, cart token, country/locale) via src/lib/spree helpers
```

- **All API calls run server-side** (Server Actions / Server Components in `src/lib/data/`). The browser never calls Spree directly; even the publishable key stays server-only (`SPREE_PUBLISHABLE_KEY`, no `NEXT_PUBLIC_`).
- `src/lib/spree/` holds the integration: `getClient()`, cookie helpers, `withAuthRefresh()`, `getLocaleOptions()`, `getCartOptions()`, middleware, surfaces (DTC vs wholesale), webhooks.
- Client components (`CartContext`, `CheckoutContext`, …) hold UI state and call Server Actions — don't add SWR/React Query fetches against the Store API from the browser.

```ts
// src/lib/data/customer.ts (pattern)
import { getClient, withAuthRefresh, setAccessToken, setRefreshToken } from '@/lib/spree'

export async function login(email: string, password: string) {
  const { token, refresh_token, user } = await getClient().auth.login({ email, password })
  await setAccessToken(token)
  await setRefreshToken(refresh_token)
  return { success: true, user }
}

export async function getCustomer() {
  return withAuthRefresh((options) => getClient().customer.get(options))
}
```

Required env (`.env.local`): `SPREE_API_URL`, `SPREE_PUBLISHABLE_KEY`. Optional: `NEXT_PUBLIC_DEFAULT_COUNTRY` / `NEXT_PUBLIC_DEFAULT_LOCALE`, `NEXT_PUBLIC_SITE_URL`, `SPREE_WHOLESALE_CHANNEL`, `SPREE_WHOLESALE_PUBLISHABLE_KEY`, `SPREE_WEBHOOK_SECRET`, `RESEND_API_KEY`, `EMAIL_FROM`. `NEXT_PUBLIC_*` is only for values the browser genuinely needs (default region, Stripe/PayPal publishable keys).

## @spree/sdk essentials

```ts
import { createClient } from '@spree/sdk'

const spree = createClient({
  baseUrl: process.env.SPREE_API_URL!,
  publishableKey: process.env.SPREE_PUBLISHABLE_KEY!,
  locale: 'en',          // sent as x-spree-locale (also per request: { locale })
  channel: 'online',     // sent as X-Spree-Channel; omit for the store default
})

const { data, meta } = await spree.products.list({ expand: ['media', 'default_variant'] })
const product = await spree.products.get('cool-shirt', { expand: ['variants', 'media'] })  // slug or prod_ id

const cart = await spree.carts.create()
await spree.carts.items.create(cart.id, { variant_id: 'variant_k5nR8xLq', quantity: 1 }, { spreeToken: cart.token })

const orders = await spree.customer.orders.list({}, { token })   // logged-in customer (JWT)
```

- Flat responses (`product.name`); relations are `*_id` fields or, with `expand`, nested objects (`product.default_variant`, `product.primary_media`, `product.media[]`). Prices come as `Price` objects (`product.price.display_amount`) — never compute money client-side.
- Auth modes: publishable key only (browsing) · + `spreeToken` (guest cart, `x-spree-token`) · + `token` JWT (customer). Types in `@spree/sdk` (also `@spree/sdk/zod`), webhook helpers in `@spree/sdk/webhooks`.
- IDs are prefixed strings (`prod_`, `variant_`, `cart_`, `or_`, `cust_`, `ful_`). **Carts use `cart.id`** — `cart.number` is a deprecated mirror of `id` kept for 5.x clients (removed in 6.1).

## Cart → checkout → order

Spree 6 splits the mutable **Cart** (`cart_…`) from the immutable **Order** (`or_…`) created when the cart completes. There is **no checkout state machine** to advance: you update the cart (email, addresses, delivery rate, payment) in any order, and the cart reports what's still missing.

```ts
const cart = await spree.carts.get(cartId, { spreeToken })
cart.requirements
// [{ step: 'address', field: 'ship_address', code: 'ship_address_required', message: '…' },
//  { step: 'delivery', field: 'delivery_method', code: 'delivery_method_required', message: '…' }, …]
```

- `requirements[]` entries are `{ step, field, code, message }`. Codes include `line_items_required`, `email_required`, `ship_address_required`, `delivery_method_required`, `payment_required`, `po_number_required`, `guest_checkout_not_allowed`, `quantity_rule_violated`, `order_minimum_not_met`, `discontinued`, `out_of_stock`. Steps (`cart`, `address`, `delivery`, `payment`) are advisory UI grouping — map them to checkout sections and show `message`. Completion is the only hard gate. Custom requirements come from the backend (`Spree::Checkout::Registry.add_requirement`, see `spree-checkout`).
- Delivery: `spree.carts.fulfillments.update(cartId, fulfillmentId, { selected_delivery_rate_id }, opts)` returns the recalculated cart.
- Payment (session-based gateways — Stripe, Adyen, PayPal):
  1. `spree.carts.paymentSessions.create(cartId, { payment_method_id }, opts)` → provider data (client secret, drop-in token, redirect URL).
  2. Render the provider UI / redirect.
  3. `spree.carts.paymentSessions.complete(cartId, sessionId, { session_result }, opts)`.
  4. `spree.carts.complete(cartId, opts)` → returns the **Order** (typed `Order | OrderGroup` — a multi-seller marketplace cart returns an `ogrp_…` group; narrow with `isOrderGroup` from `@spree/sdk`). It's idempotent: if a gateway webhook already completed the cart, it returns the existing result.
  Non-session methods (check, COD, bank transfer): `spree.carts.payments.create(...)`.
- After completion, the cart is gone from `carts.get` — read the result with **`spree.orders.get(id, params, { spreeToken | token })`**. It accepts the `or_…` id or the original `cart_…` id, so the confirmation page (`order-placed/[id]`) can keep using the cart id as its handle. Order `status` is `draft`/`placed`/`canceled`, with separate `payment_status` and `fulfillment_status`.
- Reference flows: `src/lib/data/checkout.ts`, `payment.ts` (`completeCheckoutOrder` also tolerates 403/422 races), `components/checkout/*`, and the gateway gems (e.g. `spree_stripe`).

## Multi-region URLs

Every route lives under `src/app/[country]/[locale]/…` (`/us/en/products`, `/de/de/products`), mapped to a Spree **Market** (country + currency + locale). `src/proxy.ts` (Next 16's middleware file) wires `createSpreeMiddleware({ defaultCountry, defaultLocale, staticRoutes? })` from `@/lib/spree/middleware`, which:

- redirects bare paths to `/{country}/{locale}/…`;
- detects country from the `spree_country` cookie → `x-vercel-ip-country` / `cf-ipcountry` → default, and locale from `spree_locale` → `Accept-Language` → default;
- syncs the `spree_country` / `spree_locale` cookies with the URL.

Data functions don't take region args — they call `getLocaleOptions()`, which reads those cookies and passes locale/country to the SDK. New pages go under `src/app/[country]/[locale]/(storefront)/your-page/page.tsx` to inherit the layout. `CountrySwitcher` changes region by navigating to a new prefix.

## Wholesale / channel surfaces

`/wholesale` is an opt-in B2B portal on a separate **channel**, enabled only when `SPREE_WHOLESALE_CHANNEL` is set to a gated channel's code (unset → all wholesale UI hidden, routes 404). A *surface* = a channel-bound SDK client (`channel: 'wholesale'` → `X-Spree-Channel`) with its own cart cookie and cache tags; the customer JWT is shared. The channel's `storefront_access` (`login_required` | `prices_hidden` | `public`) is enforced by the API (401, or money fields `null`); buyer approval = membership in the Wholesale customer group; trade prices come from backend price lists. Treat it as a reference you can adapt (members-only DTC, B2B-only store) — see `spree-b2b`.

## Webhooks and transactional emails

The storefront can own customer emails (react-email templates in `src/lib/emails/`, sent via Resend; written to `.next/emails/` in dev; preview at `/dev/emails`). The route `src/app/api/webhooks/spree/route.ts` uses `createWebhookHandler` from `@/lib/spree/webhooks`, which verifies `X-Spree-Webhook-Signature` (HMAC-SHA256 over `"{timestamp}.{body}"`, timing-safe, 5-minute replay window) and dispatches by event name:

```ts
import { createWebhookHandler } from '@/lib/spree/webhooks'

const handler = createWebhookHandler({
  secret: process.env.SPREE_WEBHOOK_SECRET!,
  handlers: {
    'order.placed': handleOrderPlaced,
    'order.canceled': handleOrderCanceled,
    'order.fulfilled': handleOrderFulfilled,        // or 'fulfillment.fulfilled' for per-parcel emails
    'customer.password_reset_requested': handlePasswordReset, // must be subscribed by name — `*` never receives it
  },
  // waitUntil, toleranceSeconds optional
})
export const POST = handler
```

- Event names are Spree 6's: **`order.placed`** (not `order.completed`), **`order.fulfilled`** / `fulfillment.fulfilled` (not `order.shipped`). The shipped storefront code still registers `order.completed` and `order.shipped` — deprecated aliases Spree 6.0 still sends alongside the new names and stops sending in 6.1. Switch handlers **and** endpoint subscriptions to the new names.
- Marketplace (split) checkouts: child orders publish `order.placed` with `notify_customer: false`; the purchase's confirmation belongs to `order_group.completed` — add a handler for it if you send order emails (see `spree-marketplace`).
- When the storefront owns customer emails, turn off Spree's own with the store preference `send_consumer_transactional_emails` (false) so customers don't get two. That switch (and `notify_customer: false` on an order) only silences **customer** emails — the store's new-order notification to `new_order_notifications_email` still goes out whenever that address is set.
- Create the endpoint in the dashboard under **Settings → Developer → Webhooks**, subscribe to the events, and copy its secret into `SPREE_WEBHOOK_SECRET`. For local testing expose the storefront (`cloudflared tunnel --url http://localhost:3001`).
- Failed deliveries are retried with backoff (5 attempts over about six minutes, same event `id`), and an endpoint is disabled after 15 consecutive failed deliveries — return 2xx quickly, dedupe on `event.id`, and do slow work in `waitUntil`/a queue. Unhandled events return 200 `{ handled: false }`.
- Outside the official storefront, use `verifyWebhookSignature(body, signature, timestamp, secret)` and `type WebhookEvent<T>` from `@spree/sdk/webhooks`. Full event list: `spree-events-webhooks`.

## Testing

- **Unit/integration:** Vitest — `pnpm test` / `pnpm test:watch` (tests live next to code, e.g. `src/lib/data/__tests__`).
- **E2E:** Playwright against a real backend in Docker: export a matching Stripe test key pair (`STRIPE_PUBLISHABLE_KEY`, `STRIPE_SECRET_KEY`), `pnpm e2e:up` (boots Postgres/Redis + `ghcr.io/spree/spree:latest`, seeds via `@spree/cli`, writes `.env.e2e`), `pnpm test:e2e` (`:ui` for interactive), `pnpm e2e:down`.
- Test against **your** backend: `SPREE_IMAGE=<image> pnpm e2e:up`. In a `create-spree-app` project build it from the root with `docker build . -f server/Dockerfile -t project-spree:e2e` first; generated CI does this for you.

## Storefront vs backend — where does the change belong

| Want to… | Belongs in |
|---|---|
| Layout, copy, styling, a new content page | Storefront (`src/app/[country]/[locale]/(storefront)/…`, `@theme` tokens in `src/app/globals.css`) |
| Add a field to product/cart responses | Backend — model + serializer swap (`spree-resource`, `spree-api-v3`) |
| Change pricing | Backend — price lists / rules (`spree-pricing`) |
| Change how cart totals are calculated | Backend — `Spree::Carts::RecalculateTotals` (DI key `cart_recalculate_totals_workflow`) or a workflow hook (`spree-order-totals`, `spree-workflows`) |
| Add a checkout requirement (e.g. "accept terms") | Backend `Spree::Checkout::Registry.add_requirement`; storefront renders the new `requirements[]` code |
| Add a country / currency / language | Backend Markets; storefront just follows the URL + cookies |
| Customize the checkout UI | Storefront (`components/checkout/*`) |
| A/B test the PDP, client analytics | Storefront (`src/lib/analytics`) |
| Sync orders to a CRM/ERP | Backend subscriber on `order.placed` (`spree-events-webhooks`) |
| Customer email look & feel | Storefront emails (webhooks) **or** backend mailers — pick one owner |

Rule: anything customer-visible is storefront; anything that touches data, money, or business rules is backend, so every frontend gets the same behavior.

## Gotchas

- **Secret keys (`sk_…`) never go in a storefront** — not even server-side; the Store API uses publishable keys. Admin tasks belong in the dashboard or a backend job.
- **Cart tokens grant cart access** — keep them in httpOnly, secure cookies (the helpers do).
- **Cache catalog, never carts/checkout.** The storefront uses Next cache tags per surface (`updateTag(cartTag(surface))`) — invalidate after cart mutations.
- **Don't assume a checkout step order** — drive the UI from `requirements[]`, and handle `carts.complete` returning an error (code `cart_cannot_complete`) by re-reading the cart's `requirements`.
- **Don't call `carts.get` after completion** — use `orders.get` with the cart or order id.
- **Localization is header-driven** (`x-spree-locale`, `X-Spree-Channel`), not `Accept-Language`; the storefront gets it from the URL segments via cookies.
- **Stay on the upstream track**: add the storefront repo as an `upstream` remote and merge periodically; keep customizations in components/data files you own.

## Where to read further

- Docs (installed): `node_modules/@spree/docs/dist/developer/storefront/nextjs/{architecture,customization,multi-region,wholesale,emails,environment-variables,testing,deployment,wallet-payments}.md`; SDK: `developer/sdk/quickstart.md`. Online: https://spreecommerce.org/docs/developer/storefront/nextjs/architecture
- Tutorial: `developer/tutorial/storefront.md`
- Source: https://github.com/spree/storefront (`src/lib/spree/`, `src/lib/data/`, `src/app/api/webhooks/spree/route.ts`)
- Related skills: `spree-typescript-sdk`, `spree-api-v3`, `spree-checkout`, `spree-events-webhooks`, `spree-b2b`, `spree-i18n`, `spree-deployment`.

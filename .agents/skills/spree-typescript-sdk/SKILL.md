---
name: spree-typescript-sdk
description: Use when the user is building a TypeScript or JavaScript client against Spree 6 — a Next.js storefront, a mobile/web app, an integration or back-office tool, a webhook receiver. Covers @spree/sdk (Store API), @spree/admin-sdk (Admin API) and points to @spree/seller-sdk (marketplace). Common phrasings include "Spree SDK", "createClient", "createAdminClient", "store client", "admin client", "cart token / spreeToken", "carts.complete", "orders.get after checkout", "TypeScript types from Spree", "Zod schemas", "verifyWebhookSignature", "retry config", "client.request custom endpoint", "MSW Spree", "@spree/sdk", "@spree/admin-sdk". For curl/raw HTTP and protocol details, see spree-api-v3.
---

# Spree TypeScript SDKs

| Package | Surface | Auth | Version |
|---|---|---|---|
| `@spree/sdk` | Store API (`/api/v3/store`) | Publishable key + optional customer JWT / guest token | 2.x (currently 2.0 beta) |
| `@spree/admin-sdk` | Admin API (`/api/v3/admin`) | Secret key **or** staff JWT | 1.x beta |
| `@spree/seller-sdk` | Seller API (`/api/v3/seller`) | Seller JWT + seller ID (`createSellerClient`, `setSeller`) | 1.x beta. Singletons use `get`/`update` like the admin SDK (`seller.me.get()`, `seller.me.update({ selected_locale })`, `seller.profile.update(…)`). See `spree-marketplace` |
| `@spree/sdk-core` | Shared HTTP, retry, errors | — | Internal, never published. Don't import it |

All three expose the same shape and share `SpreeError`, retry, idempotency and a `request` escape hatch. They target Spree 6. Spree 6 storefronts need `@spree/sdk` 2.x. Until 6.0 is final the SDKs and dashboard packages are published as prereleases on npm's `beta` dist-tag (`pnpm add @spree/sdk@beta`), while `@spree/cli` and `create-spree-app` are stable (3.1.0 / 2.1.0 alongside gems 6.0.0.beta4).

`@spree/sdk` also ships `@spree/sdk/types` (generated types), `@spree/sdk/zod` (Zod schemas) and `@spree/sdk/webhooks` (signature verification, Node only). The Admin and Seller SDKs have matching `/types` and, from the release after `1.0.0-beta.3`, `/zod` subpaths (`@spree/admin-sdk/zod`, `@spree/seller-sdk/zod`). If the subpath doesn't resolve, the installed version predates it. Schemas are named `<Type>Schema` and generated from the API serializers. `zod` (>= 3) is an optional peer dependency, so install it yourself to validate responses at runtime:

```typescript
import { OrderSchema } from '@spree/admin-sdk/zod'

const order = OrderSchema.parse(await adminClient.orders.get('or_xxx'))  // throws on a shape mismatch
```

## @spree/sdk — Store API

```ts
import { createClient } from '@spree/sdk'

const client = createClient({
  baseUrl: 'https://shop.example.com',
  publishableKey: 'pk_xxx',
  // optional defaults, sent as X-Spree-* headers
  country: 'DE', locale: 'de', currency: 'EUR', channel: 'online',
})

const { data: products, meta } = await client.products.list({ name_cont: 'shirt', limit: 24, expand: ['default_variant'] })
const product = await client.products.get('classic-tee')         // id or slug
```

Setters change the defaults for later requests: `client.setLocale('fr')`, `setCurrency`, `setCountry`, `setChannel`. Each client instance keeps its own defaults, so a server-rendered client and a browser client have to be set separately.

### Method vocabulary

`list(params?, options?)`, `get(idOrSlug, params?, options?)`, `create(body, options?)`, `update(id, body, options?)`, `delete(id, options?)`. The method is always `get` (never `show`) and `delete` (never `destroy`). Nested resources take the parent ID first: `client.carts.items.create(cartId, body, options)`.

The Store SDK only exposes what the Store API allows. If a method doesn't typecheck, it doesn't exist on that surface.

| Resource | What you get |
|---|---|
| `products`, `categories`, `collections` (+ `collections.products.list`), `sellers` | Catalog reads (`products.filters` for facets) |
| `markets`, `countries`, `currencies`, `locales`, `channel`, `policies`, `deliveryMethods` | Context and reference data |
| `carts` (+ `items`, `discountCodes`, `giftCards`, `fulfillments`, `payments`, `paymentSessions`, `storeCredits`), `carts.associate`, `carts.complete` | Cart and checkout |
| `orders.get` (+ `returns`, `claims`) | Completed orders |
| `auth`, `customers.create`, `passwordResets`, `customer.*` (profile, addresses, creditCards, giftCards, storeCredits, digitalLinks, orders, paymentSetupSessions) | Accounts |
| `wishlists` (+ `items`) | Wishlists |
| `newsletterSubscribers` (`create`, `verify`, `requestUnsubscribe`, `delete`) | Double opt-in newsletter |
| `account.companies`, `companies` (+ `addresses`, `members`, `invitations`, `orders`), `companyInvitations` (`lookup`, `accept`) | B2B self-service (see `spree-b2b`). `companies.members.create(id, { customer_email })` always returns a `CompanyInvitation` |

Endpoints without a wrapper yet (e.g. `/customers/me/data_requests`, cart `tax_identifier`, `po_document`) are reachable through `client.request` (below).

### Auth, guest tokens, per-request options

```ts
// Customer login: tokens aren't stored on the client; pass them per request
const { token, refresh_token, user } = await client.auth.login({ email, password })
const { data: orders } = await client.customer.orders.list({}, { token })
const fresh = await client.auth.refresh({ refresh_token })        // rotates both tokens
await client.auth.logout({ refresh_token })

// Third-party IdP (strategy registered on the server)
await client.auth.login({ provider: 'external_idp', token: idpJwt })
```

`RequestOptions`: `token` (Bearer JWT), `spreeToken` (guest cart/order token, sent as `X-Spree-Token`), `idempotencyKey`, `headers`.

### Cart → order

```ts
let cart = await client.carts.create()
const opts = { spreeToken: cart.token }            // or { token } for a signed-in customer

cart = await client.carts.items.create(cart.id, { variant_id: 'variant_xxx', quantity: 1 }, opts)
cart = await client.carts.update(cart.id, { email, shipping_address, use_shipping: true }, opts)
// cart.requirements → [{ step, field, code, message }] (what still blocks completion)

const result = await client.carts.complete(cart.id, opts)  // Order (or_…, order.cart_id === cart.id) | OrderGroup (ogrp_…)
```

- **After completion, the cart is gone from cart endpoints.** `client.carts.get(cartId)` throws a 404 `SpreeError` (`cart_not_found`). On the confirmation page, or after a redirect-based payment, read `client.orders.get(cartId, {}, opts)`. The orders endpoint accepts the cart ID and resolves it to its order, with the same guest token.
- Drive the checkout UI from `cart.requirements`, not from a state machine (see `spree-checkout`).
- `Order` exposes `number`, `cart_id`, `coupon_code`, `payment_status`, `fulfillment_status`, totals and `display_*`. The Store serializer has no `state` and no `status`.
- `carts.complete` is typed `Promise<Order | OrderGroup>`: a multi-seller marketplace cart completes into an order group (`ogrp_…`, with `orders[]`). Narrow with the `isOrderGroup` guard exported from `@spree/sdk` — `const orders = isOrderGroup(result) ? result.orders : [result]`. Non-marketplace stores always get an `Order`, but TypeScript still makes you narrow. (`@spree/admin-sdk` has its own `isOrderGroup` for admin completion.)

### Money is `string | null`

Amounts are decimal strings (`"29.99"`) with `display_*` companions. On channels that hide prices from guests they're **`null`**, and the generated types say `string | null`. Handle null, and don't `parseFloat` blindly.

### List params (Ransack)

```ts
await client.products.list({ page: 2, limit: 50, name_cont: 'shirt', sort: '-created_at', expand: ['media'], fields: ['name', 'slug'] })
```

Keys other than `page`/`limit`/`sort`/`expand`/`fields` become `q[...]` predicates (`name_cont` → `q[name_cont]`; arrays get `[]`). Don't nest predicates under a `filter` key.

### Errors

```ts
import { SpreeError } from '@spree/sdk'

try { await client.carts.items.create(cartId, { variant_id, quantity: 1 }, opts) }
catch (err) {
  if (err instanceof SpreeError) {
    err.status   // 422
    err.code     // 'insufficient_stock' | 'validation_error' | ...
    err.details  // { quantity: ['...'] } (attribute keys; 'base' = form-level)
  }
  throw err
}
```

### Retry and idempotency

The default is 2 retries with exponential backoff and jitter, retrying on 429/500/502/503/504 and network errors, and honoring `Retry-After`. Mutating requests get an automatic `Idempotency-Key` while retries are on, so a retried POST can't double-apply. Configure with `retry: { maxRetries, baseDelay, maxDelay, retryOnStatus, retryOnNetworkError }` or turn it off with `retry: false`. Pass `fetch` for Next.js caching, tracing or tests.

## @spree/admin-sdk — Admin API

```ts
import { createAdminClient } from '@spree/admin-sdk'

// Integration (server only)
const admin = createAdminClient({ baseUrl, secretKey: process.env.SPREE_SECRET_KEY! })

const { data: orders } = await admin.orders.list({ status_eq: 'placed', sort: '-completed_at' })
const order = await admin.orders.get('or_xxx', { expand: ['items', 'payments', 'fulfillments'] })
await admin.orders.cancel('or_xxx', { cancel_reason_id: 'ocr_xxx', cancel_note: 'Customer request' })
await admin.orders.refunds.create('or_xxx', { payment_id: 'py_xxx', amount: '25.00', refund_reason_id: 'rr_xxx' })  // refund_reason_id, not reason_id
```

- **Secret key**: scope-limited. A missing scope throws 403 with `details.required_scope`. Mint the narrowest key you can (see `spree-api-v3/references/scopes.md`).
- **Staff JWT** (custom back-office UIs): `admin.auth.login({ email, password })` (or `{ provider, ... }`) returns `{ token, user }`, and the refresh token is set as an HttpOnly cookie. Then call `admin.setToken(token)`. `admin.auth.refresh()` takes **no token argument** (the cookie drives it). Admin JWTs expire after 5 minutes, so wire up `admin.onUnauthorized(async () => { const { token } = await admin.auth.refresh(); admin.setToken(token); return true })`. The client defaults to `credentials: 'include'`. Staff are gated by their **roles' permission keys** (403 `details.required_permission`); see `spree-auth-permissions`.
- `admin.setStore(storeId)` sends `X-Spree-Store-Id` on multi-store hosts.
- Full CRUD plus domain actions: `orders.complete/cancel/approve`, `products.clone/bulkStatusUpdate/bulkAddToCategories/...`, `prices.bulkUpsert`, `stockLevels.bulkUpsert`, `roles`, `permissions.list()`, `exports`, `imports`, `webhookEndpoints`, `apiKeys`, and more (see `packages/admin-sdk/src/admin-client.ts`).
- Invitation listings carry no `acceptance_url`; fetch the link on demand with `admin.invitations.acceptanceLink(id)` (or `admin.sellers.invitations.acceptanceLink(sellerId, id)`) — write-gated. `admin.invitations.create` requires `role_id`.
- `?expand=` of orders/payments/customers/gift cards/store credits is silently dropped when the key/staff member lacks that read permission — check scopes before assuming the API omitted data.
- Stock is `admin.stockLevels` (`sl_…`), not `stockItems`. Addresses use `country_code` / `state_code`, not `country_iso`.
- Products take prices as `prices: [{ currency: 'USD', amount: '29.99' }]` for simple products, or per variant.
- Singletons use `get`: `admin.me.get()` (includes `permission_keys`), `admin.store.get()`.
- Exports: `admin.exports.create({ type, search_params })`, poll `exports.get(id)` until it's done, then download with fetch plus an `Authorization` header into a Blob. There's no `.download()` helper.

## Webhook receivers

```ts
// app/api/webhooks/spree/route.ts (Node runtime)
import { verifyWebhookSignature, type WebhookEvent } from '@spree/sdk/webhooks'
import type { Order } from '@spree/sdk'

export async function POST(request: Request) {
  const rawBody = await request.text()                       // raw bytes, before JSON.parse
  const ok = verifyWebhookSignature(
    rawBody,
    request.headers.get('x-spree-webhook-signature') ?? '',
    request.headers.get('x-spree-webhook-timestamp') ?? '',
    process.env.SPREE_WEBHOOK_SECRET!,
    300,                                                      // replay tolerance (seconds)
  )
  if (!ok) return new Response('Unauthorized', { status: 401 })

  const event = JSON.parse(rawBody) as WebhookEvent<Order>
  if (event.name === 'order.placed') await syncToERP(event.data)
  return Response.json({ ok: true })
}
```

Subscribe to `order.placed`. `order.completed` is still sent through 6.0 as a deprecated alias (its metadata carries `deprecated_alias_of`) and is removed in 6.1. The verifier uses `node:crypto`; on Edge runtimes, implement HMAC-SHA256 over `` `${timestamp}.${rawBody}` `` with Web Crypto (see `spree-events-webhooks`). Failed deliveries are retried with backoff (up to 5 attempts, same `event.id`), so make handlers idempotent on `event.id`.

## Extending the SDK for custom endpoints

Don't fork the SDK, and don't bypass it with raw `fetch`: you'd lose auth headers, locale/currency/channel defaults, retry, idempotency and error normalization.

### 1. One-off calls: `client.request`

Paths are relative to the surface root (`/api/v3/store` or `/api/v3/admin`). `request` does **not** apply `transformListParams`, so wrap Ransack predicates yourself.

```ts
import type { PaginatedResponse } from '@spree/sdk'

type Brand = { id: string; name: string; slug: string }

const { data } = await client.request<PaginatedResponse<Brand>>('GET', '/brands', {
  params: { 'q[name_cont]': 'acme', page: 1, limit: 25 },
})
const created = await admin.request<Brand>('POST', '/brands', { body: { name: 'Acme' } })
```

### 2. A wrapped resource class

```ts
import type { RequestFn, PaginatedResponse } from '@spree/sdk'

export class BrandsClient {
  constructor(private readonly request: RequestFn) {}
  list(params: { page?: number; limit?: number; name_cont?: string } = {}) {
    const { page, limit, ...predicates } = params
    const q = Object.fromEntries(Object.entries(predicates).map(([k, v]) => [`q[${k}]`, v]))
    return this.request<PaginatedResponse<Brand>>('GET', '/brands', { params: { page, limit, ...q } })
  }
  get(id: string) { return this.request<Brand>('GET', `/brands/${id}`) }
}
```

`@spree/admin-sdk` doesn't export `RequestFn`, so type admin wrappers with `AdminClient['request']`.

### 3. Attaching it to the client

```ts
import { createClient, type Client, type ClientConfig } from '@spree/sdk'

export interface ExtendedClient extends Client { brands: BrandsClient }

export function createExtendedClient(config: ClientConfig): ExtendedClient {
  const client = createClient(config) as ExtendedClient
  client.brands = new BrandsClient(client.request)
  return client
}
```

To add a method to a built-in resource, use `Object.assign(base, { products: { ...base.products, republish(id: string) { ... } } })`. **Don't spread the client itself** (`{ ...base }`), because resources live on the prototype and would be dropped.

### Types for custom resources

Serializers generated by `spree:api_resource` are typed through Typelizer (`bundle exec rake typelizer:generate` in the API engine). In a standalone app, point Typelizer's output at your own folder or hand-write the interfaces to match the serializer. The serializer is the source of truth.

## Testing with MSW

The SDK just calls `fetch`, so MSW handlers see every request:

```ts
server.use(
  http.get('https://test.spree.local/api/v3/store/products', () =>
    HttpResponse.json({ data: [{ id: 'prod_test1', name: 'Test' }], meta: { page: 1, limit: 25, count: 1, pages: 1 } })),
)
const client = createClient({ baseUrl: 'https://test.spree.local', publishableKey: 'pk_test' })
```

## Common pitfalls

- **404 on `carts.get` after checkout.** Expected. Use `orders.get(cartId)`.
- **Totals render as "NaN".** The channel hides prices and the fields are `null`.
- **Admin requests 401 every 5 minutes.** You haven't registered `onUnauthorized`, or the refresh cookie is blocked. Cross-origin setups need HTTPS and the origin in Settings → Allowed Origins.
- **403 with a secret key.** Read `err.details.required_scope` and mint a key that has it. Scopes can't be edited on an existing key.
- **Secret key in a browser bundle.** Never do this. `@spree/admin-sdk` with `secretKey` belongs on the server only, and the dashboard uses the JWT flow.
- **Listening for `order.completed`.** Switch to `order.placed`.

## Where to read further

- Store SDK source: `packages/sdk/src/store-client.ts`. Admin SDK: `packages/admin-sdk/src/admin-client.ts`. Seller SDK: `packages/seller-sdk/src/seller-client.ts`
- Docs: `node_modules/@spree/docs/dist/developer/sdk/` (Store quickstart, `admin/quickstart.md`, `admin/authentication.md`)
- OpenAPI: `node_modules/@spree/docs/dist/api-reference/store.yaml`, `admin.yaml`, `seller.yaml`
- Related skills: `spree-api-v3`, `spree-storefront`, `spree-checkout`, `spree-events-webhooks`, `spree-auth-permissions`, `spree-marketplace`.

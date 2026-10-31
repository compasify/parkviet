---
name: spree-api-v3
description: Use when the user is calling or debugging Spree 6's REST API v3 — the Store API (storefronts, mobile apps, customers), the Admin API (integrations, back-office tools) or the Seller API (marketplace sellers). Covers auth (publishable/secret keys, JWT audiences), scopes and permissions, prefixed IDs, the cart → order split, checkout `requirements[]`, order statuses, the `{data, meta}` envelope, expand/fields, Ransack filters, errors, idempotency, localization headers and rate limits. Common phrasings include "Spree API", "Store API", "Admin API", "publishable key", "secret key", "X-Spree-Api-Key", "X-Spree-Token", "API scopes", "403 required_scope", "cart_ vs or_", "complete cart", "cart 404 after checkout", "prefixed IDs", "expand", "Idempotency-Key", "429 rate limit", "v3 endpoint". For ADDING a new endpoint use spree-resource; for roles/permissions internals use spree-auth-permissions.
---

# Spree API v3

Spree 6 has three REST surfaces under `/api/v3/`, and they share one set of conventions:

| Surface | Path | Caller | Auth | Authorization |
|---|---|---|---|---|
| **Store API** | `/api/v3/store/*` | Storefronts, mobile apps, shoppers | `X-Spree-Api-Key: pk_…` + optional `Authorization: Bearer <jwt>` (`aud: store_api`) + guest `X-Spree-Token` | Ownership (see `spree-auth-permissions`) |
| **Admin API** | `/api/v3/admin/*` | Integrations, back-office apps, the dashboard | `X-Spree-Api-Key: sk_…` **or** `Authorization: Bearer <jwt>` (`aud: admin_api`) | Key scopes / role permission keys |
| **Seller API** | `/api/v3/seller/*` | Marketplace seller panel | Seller JWT (`aud: seller_api`) + `X-Spree-Seller-Id` | Seller role keys + `current_seller` scoping (see `spree-marketplace`) |

A token issued for one audience is rejected on the other surfaces. The v2 Storefront/Platform APIs don't exist in Spree 6. If you're migrating an old integration, see `node_modules/@spree/docs/dist/api-reference/store-api/migrating-from-storefront-api-v2.md`.

## Store API

- **Anonymous browsing** needs only `X-Spree-Api-Key: pk_…`. Publishable keys are safe in client code.
- **Guest cart/checkout/order**: also send `X-Spree-Token: <cart.token>`.
- **Signed-in customer**: also send `Authorization: Bearer <jwt>` from `POST /api/v3/store/auth/login`. The response body contains `token`, `refresh_token` and `user`. Rotate with `POST /auth/refresh` and `{ "refresh_token": "…" }`.
- **Context headers**:
  - `X-Spree-Country` resolves the market, which sets the default locale and currency.
  - `X-Spree-Locale` and `X-Spree-Currency` override those defaults.
  - `X-Spree-Channel: <code>` selects the channel; the store default is used if it's absent. A publishable key **bound to a channel** decides the channel itself, and a conflicting header returns `channel_mismatch`.
- Responses are customer-safe: no cost prices, no internal notes. On channels that hide prices from guests, money fields come back `null`, so type them `string | null`.
- The Store API is read-only by default. Writes are limited to carts, checkout, the customer's own account (`/customers/me/*`), wishlists, returns/claims on the customer's own orders, and newsletter/company self-service.

```bash
curl -H "X-Spree-Api-Key: pk_xxx" -H "X-Spree-Country: DE" \
     "https://shop.example.com/api/v3/store/products?q[name_cont]=shirt&expand=default_variant"
```

### Carts and orders are different resources

A **cart** (`cart_…`, `/api/v3/store/carts`) is mutable and has no status. Completing it creates an immutable **order** (`or_…`).

```
POST   /carts                         → cart (token in response)
POST   /carts/{id}/items              { variant_id, quantity }
PATCH  /carts/{id}                    { email, shipping_address, billing_address, use_shipping, … }
PATCH  /carts/{id}/fulfillments/{id}  { selected_delivery_rate_id }
POST   /carts/{id}/payment_sessions   … gateway flow …
POST   /carts/{id}/complete           → the Order (or an OrderGroup for split marketplace checkouts)
GET    /orders/{id}                   → order by or_ id, OR by the original cart_ id
```

- After completion, `GET /carts/{id}` returns **404** (`cart_not_found`), because completed carts drop out of cart lookups. Read the result with `GET /orders/{cart_id}`. The order endpoint accepts the cart's prefixed ID and resolves it to the order created from it (`order.cart_id`). Guests keep using the same `X-Spree-Token`.
- `POST /carts/{id}/complete` is safe to retry: if a payment webhook already completed the cart, the retry returns the existing order.
- **`requirements[]`** on the cart lists what still blocks completion, as `{ step, field, code, message }` (e.g. `{ "step": "delivery", "field": "delivery_method", "code": "delivery_method_required" }`). Steps are only advisory; completion is the one hard gate. Drive the checkout UI from `requirements`, not from a state name. See `spree-checkout`.
- Coupons: `POST /carts/{id}/discount_codes { code }`. Both carts and orders expose `coupon_code`.
- A signed-in customer's history is at `GET /customers/me/orders`.

### Order fields you'll use

- `status` (Admin API): `draft` | `placed` | `canceled`. Filter with `q[status_eq]=placed`.
- `payment_status`: `none`, `authorized`, `partially_paid`, `paid`, `partially_refunded`, `refunded`, `overcharged`, `voided`.
- `fulfillment_status`: `unfulfilled`, `partial`, `fulfilled`, `delivered`, `backorder`, `canceled` (legacy `pending` / `ready` / `shipped` can appear on migrated orders).
- Totals: `item_total`, `delivery_total`, `discount_total`, `tax_total` (`included_`/`additional_`), `fee_total`, `gift_card_total`, `store_credit_total`, `total`, `amount_due`, each paired with `display_*`.
- `withdrawal_period_ends_at` / `within_withdrawal_period` (EU right of withdrawal).

There is no `state`, `payment_state` or `shipment_state`, and no `ship_total`/`promo_total`/`adjustment` rows. Money is itemized as tax lines, discounts and fees (see `spree-order-totals`).

## Admin API

**Secret key** (integrations): `X-Spree-Api-Key: sk_…`. The key selects its store.
**JWT** (people): `POST /api/v3/admin/auth/login { email, password }` (or `{ provider, … }` for SSO). The response body is `{ token, user }`. The refresh token is set as an **HttpOnly cookie** scoped to `/api/v3/admin/auth`, and `POST /auth/refresh` takes no body. Admin JWTs expire after 5 minutes by default. For multi-store hosts, send `X-Spree-Store-Id`.

If a request carries both credentials, the JWT wins.

### Permissions

Every Admin controller maps its actions to one key: `index`/`show` → `read_<resource>`, everything else (including member actions like `/orders/{id}/cancel`) → `write_<resource>`. `write_*` implies `read_*`.

- A secret key is checked against its **scopes**. Failure is 403 `access_denied` with `details.required_scope`.
- JWT staff are checked against their **roles' permission keys on this store**. Failure is 403 with `details.required_permission`. A 403 without that detail means a record-level rule refused — those rules come from `Spree.ability_class` (swappable via `Spree::Dependencies.ability_class`; secret keys use `Spree::ApiKeyAbility` instead). See `spree-auth-permissions`.
- Keys never decide *which* rows you see: every endpoint scopes through the current store.
- Secret-key scopes are fixed at creation. To change them, mint a new key and revoke the old one.

The full scope list with groups and covered resources is in [references/scopes.md](references/scopes.md). At runtime, `GET /api/v3/admin/permissions` returns the same list, and `Spree::ApiKey.known_scopes` gives it in Ruby. Common picks:

```
Order sync out ............ read_orders (+ read_payments, read_fulfillments)
Warehouse / 3PL ........... read_orders, write_fulfillments, write_stock
ERP product feed .......... write_products (+ write_categories / write_collections)
Refund automation ......... read_orders, write_refunds
Staff provisioning ........ write_staff
Everything (avoid) ........ write_all
```

Staff roles are data (`/api/v3/admin/roles`). See `spree-auth-permissions`.

### Admin-only response traits

- Timestamps, internal notes, cost prices, `status`, and custom fields that aren't storefront-visible.
- **Actor pairs.** Records that remember who acted (`canceler`, `approver`, `created_by`, `refunder`, …) expose `*_id` plus `*_type`. The ID is `adm_…` for staff or `key_…` for a secret key, and `*_type` is `admin_user` or `api_key`. Treat `*_type` as an open list. `expand=canceler` returns `{ id, type, label }`.

## Shared conventions

### Prefixed IDs

IDs are always Stripe-style prefixed strings, on both reads and writes (`"variant_id": "variant_k5nR8xLq"`). Never send or expect integer IDs. Common prefixes:

| Prefix | Resource | Prefix | Resource |
|---|---|---|---|
| `prod_` | Product | `variant_` | Variant |
| `cart_` | Cart | `or_` | Order |
| `ogrp_` | OrderGroup (split checkout) | `li_` | LineItem |
| `py_` | Payment | `re_` | Refund |
| `ful_` | Fulfillment | `ret_` | Return |
| `tl_` | TaxLine | `disc_` | Discount |
| `fee_` | Fee | `cust_` | Customer |
| `adm_` | AdminUser | `addr_` | Address |
| `ctg_` | Category | `coll_` | Collection |
| `sl_` | StockLevel | `sloc_` | StockLocation |
| `mkt_` | Market | `ch_` | Channel |
| `sel_` | Seller | `media_` | Media |
| `cf_` | CustomField | `promo_` | Promotion |
| `gc_` | GiftCard | `role_` | Role |
| `key_` | ApiKey record (not the `pk_`/`sk_` token) | `store_` | Store |

The prefix identifies the resource type, so there is no `type` field on the envelope. Verify any others with `grep -rn has_prefix_id spree/core/app/models`. There is no `adj_`, because Adjustment doesn't exist in Spree 6.

### Envelope, pagination, sorting

Lists return `{ data: [...], meta: { page, limit, count, pages, from, to, in, previous, next } }`. A single record is returned as a bare object. Pagination: `?page=2&limit=50` (default 25, max 100). Sort: `?sort=-completed_at,number`.

### Expand and fields

- `?expand=default_variant,media,variants.prices` sideloads associations; dot notation reaches nested ones. Allowed keys vary per resource (see the OpenAPI spec).
- Admin API expansions are permission-checked per segment: `order(s)` needs `read_orders`, `payment(s)`/`payment_splits` `read_payments`, `customer(s)` `read_customers`, `gift_card(s)` `read_gift_cards`, `store_credit(s)` `read_store_credits` (so `orders.payments` needs both). A path the caller can't cover is **silently dropped**, not a 403. Gift card `code` is masked (all but the last four characters) unless the caller holds `read_gift_cards`.
- `?fields=name,slug` returns a sparse response (`id` is always included).

### Filtering (Ransack)

`q[<attr>_<predicate>]=value`, e.g. `q[name_cont]=shirt`, `q[status_eq]=placed`, `q[completed_at_gteq]=2026-09-01`. Predicates include `_eq`, `_not_eq`, `_in`, `_cont`, `_start`, `_gt`, `_gteq`, `_lt`, `_lteq`, `_present`, `_blank`. Attributes outside the model's ransack allowlist are **silently ignored**: you get 200 with that filter dropped. Allowlist them with `Spree.ransack.add_attribute(Spree::Product, :brand_id)`.

The allowlists are narrowed per audience (Ransack `auth_object`: `nil` for Admin, `:store`, `:seller`):

- **Store API** follows only a model's `storefront_ransackable_associations` (products: `tags`, `categories`, `collections`; empty for every other model) and drops the model's `private_ransackable_attributes[:store]` (e.g. order `email`, `considered_risky`, `coupon_code` and the `search`/`multi_search` scopes; variant `cost_price`; store credit `memo`).
- **Seller API** follows no associations and drops `private_ransackable_attributes[:seller]` (order `email`, `considered_risky`, `coupon_code`; plus the `search`/`multi_search` scopes).
- **Admin API** gets the full allowlist. So `Spree.ransack.add_association(Spree::Product, :brand)` makes `q[brand_name_eq]` work for staff only — to let shoppers filter through it too, add `Spree::Product.storefront_ransackable_associations |= %w[brand]` (only for associations whose data the storefront may see). Attributes added with `add_attribute` reach every audience unless listed as private.

### Addresses

Use `first_name`, `last_name`, `address1`, `city`, `postal_code`, `country_code` (ISO2), `state_code`. On carts, `use_shipping: true` copies shipping to billing. `country_iso`/`state_abbr` still appear in responses but are deprecated.

### Rich text

Rich-text attributes come back twice: `description` as plain text and `description_html` as sanitized HTML. Render `*_html` and write to the plain name (the value you send is HTML). Spree sanitizes it on save.

### Money

Amounts are decimal **strings** (`"29.99"`), each paired with a `display_*` formatted string. When prices are hidden they're `null`. On writes, prices are arrays: `"prices": [{ "currency": "USD", "amount": "29.99" }]`.

### Idempotency

Send `Idempotency-Key: <uuid>` (max 255 chars) on POST/PUT/PATCH/DELETE. For 24 hours a retry with the same key and body replays the stored response (header `Idempotent-Replayed: true`). Reusing a key with a different body returns 422 `idempotency_key_reused`. 5xx responses aren't cached. The SDKs and the CLI add the key automatically.

## Errors

```json
{ "error": { "code": "validation_error", "message": "Email can't be blank",
             "details": { "email": ["can't be blank"] } } }
```

| Status | Typical `code` |
|---|---|
| 401 | `authentication_required`, `invalid_token`, `authentication_failed`, `invalid_refresh_token` |
| 403 | `access_denied` (`details.required_scope` / `required_permission`), `channel_mismatch` |
| 404 | `record_not_found`, `cart_not_found`, `order_not_found`, `line_item_not_found`, `variant_not_found` |
| 422 | `validation_error` (per-attribute `details`, with `base` for form-level errors), `cart_cannot_complete`, `insufficient_stock`, `payment_failed`, `idempotency_key_reused` |
| 413 | `request_too_large` (body > `max_request_body_size`, 100 KB) |
| 429 | `rate_limit_exceeded` |

## Rate limits

Built on Rails `rate_limit`, with counters in `Rails.cache`. That cache must be shared (Solid Cache or Redis) across processes. Configure through `Spree::Api::Config` or the env vars:

| Preference (env) | Default | Bucket |
|---|---|---|
| `rate_limit_per_key` (`SPREE_RATE_LIMIT_PER_KEY`) | 300 / window | Publishable key **+ client IP** (per visitor); client IP when no key is sent |
| `rate_limit_per_secret_key` (`SPREE_RATE_LIMIT_PER_SECRET_KEY`) | 600 / window | Per secret key, across the whole API |
| `rate_limit_window` (`SPREE_RATE_LIMIT_WINDOW`) | 60 s | |
| `rate_limit_login` | 5 | Per IP: store/admin/seller login, invitation acceptance |
| `rate_limit_register` | 3 | Per IP: customer registration, newsletter subscribe |
| `rate_limit_refresh` | 10 | Per IP: refresh, logout, admin auth providers |
| `rate_limit_password_reset` | 3 | Per IP |

Responses include `X-RateLimit-Limit`, `X-RateLimit-Remaining` and, when limited, `Retry-After`. Inbound payment/fulfillment webhook endpoints have their own fixed limit of 120/min.

## Debugging recipes

- **401 everywhere**: a `pk_` key sent to the Admin API or an `sk_` key to the Store API; a revoked key; an admin JWT older than 5 minutes (refresh via the cookie); a customer token sent to the Admin API (wrong `aud`).
- **403 on Admin**: read `details.required_scope` / `required_permission`. For a key, mint a new one with that scope. For staff, add the key to their role on this store.
- **Cart 404 right after checkout**: expected. Fetch `GET /orders/{cart_id}`.
- **Empty list but records exist**: wrong channel (`X-Spree-Channel` or a channel-bound key), product not published on that channel, no price in the requested currency or market, or a silently dropped Ransack filter.
- **Probe from a terminal**: `spree api get /orders/or_xxx --expand payments,fulfillments` (see `spree-cli`).

## Where to read further

- OpenAPI specs (authoritative): `node_modules/@spree/docs/dist/api-reference/store.yaml`, `admin.yaml`, `seller.yaml`
- Store API guides: `node_modules/@spree/docs/dist/api-reference/store-api/` (authentication, localization, idempotency, rate limiting, querying, relations)
- Admin API guides: `node_modules/@spree/docs/dist/api-reference/admin-api/` (authentication, errors, querying)
- Webhook events: `node_modules/@spree/docs/dist/api-reference/webhooks-events.md`
- Related skills: `spree-auth-permissions`, `spree-typescript-sdk`, `spree-cli`, `spree-resource` (add endpoints), `spree-checkout`, `spree-marketplace` (Seller API), `spree-events-webhooks`.

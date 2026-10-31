# Seller API and operator endpoints: reference

## Seller API: `/api/v3/seller/*` (`@spree/seller-sdk`)

Every authenticated call sends `Authorization: Bearer <seller JWT>` and `X-Spree-Seller-Id: sel_…`. The exception is `/seller/me`: `GET` tells the panel which sellers the user can act for, `PATCH` edits the signed-in person's own account. The store is derived from the seller on the server. There are no secret keys on this surface.

```ts
import { createSellerClient, SpreeError } from '@spree/seller-sdk'

const client = createSellerClient({ baseUrl, /* jwtToken?, sellerId?, credentials: 'include' by default */ })
const { token, user, sellers } = await client.auth.login({ email, password }) // refresh token = HttpOnly cookie
client.setToken(token)
client.setSeller(sellers[0].id)
client.onUnauthorized(async () => { const { token } = await client.auth.refresh(); client.setToken(token); return true })
```

| SDK namespace | Routes (under `/api/v3/seller`) | Notes |
|---|---|---|
| `auth` | `POST auth/login`, `auth/refresh`, `auth/logout`, `GET auth/providers`, `GET auth/invitations/:id/lookup`, `POST auth/invitations/:id/accept`, `POST/PATCH auth/password_resets` | Rate limited, returns 429 `rate_limit_exceeded`. The invitation link (ID plus token) is the credential. A wrong token returns 404 |
| `me` | `GET me` (`me.get()`), `PATCH me` (`me.update({ first_name, last_name, selected_locale, avatar })`) | No seller header, no seller role needed. Returns `{ user, sellers, … }` where `user` is an `Account` (team-member fields + `selected_locale`). `avatar` takes a direct-upload signed id, or `null` to remove. This is the *person*; the seller business is `profile` |
| `profile` | `GET/PATCH profile` (`profile.get()` / `profile.update()`) | The seller business's public profile |
| `taxIdentifiers` | `tax_identifiers` (index/create/update/destroy, `POST :id/validate`) | |
| `team`, `invitations` | `team` (index/create/destroy), `invitations` (index/destroy, `PATCH :id/resend`, `GET :id/acceptance_link`) | The seller hires its own staff. Listings carry no acceptance link; `invitations.acceptanceLink(id)` needs `write_seller_profile`. Resend rotates the token |
| `onboarding` | `GET onboarding`, `POST onboarding/submit_for_review`, `POST onboarding/payout_account` | `payoutAccount({ refresh_url, return_url })` returns `{ url }`, where `url` is null if the provider hosts nothing. Mint the link on click because links expire |
| `requirementSubmissions` | `POST requirements/:id/submissions`, `GET requirement_submissions/:id/download` | Create only. To change a submission, submit again |
| `products` | CRUD, plus `PATCH :id/submit`, `:id/draft`, `:id/archive`, `POST bulk_submit`, `bulk_status_update`, bulk destroy | Can't set `active`. Only the operator approves |
| `orders` | index/show, `PATCH :id/cancel`, `:id/address`, `notes` (show/update) | Only this seller's orders. `:id/address` writes a fresh address snapshot onto the order only — never the buyer's address book or defaults. Filters can't reach the buyer's `email` (no associations, see `spree-api-v3`) |
| `orders.fulfillments` | index/show/update, `PATCH :id/fulfill`, `:id/cancel`, `:id/split` | There's **no deliver action**, because delivery confirmation belongs to the operator or the carrier feed |
| `orders.deliveries`, `orders.labels` | nested under fulfillments | labels: `GET :id/download` |
| `orders.returns` / `exchanges` / `claims` | index/show/create plus approve/receive/refund/fulfill/resolve/deny/cancel | |
| `balances`, `transfers`, `payouts` | read-only | `transfers.list({ payout_id_eq })` shows what a payout settled |
| `deliveryMethods` | CRUD, `calculators`, `ruleTypes` | The seller's own internal rates and manual fulfillment. Carrier accounts stay with the operator |
| `packageTypes`, `stockLocations`, `policies` | CRUD (stock locations have no destroy; deactivate them instead) | |
| `imports`, `exports`, `directUploads` | Bulk CSV listing and sales CSV | |
| `productTypes`, `deliveryProfiles`, `deliveryZones`, `returnReasons`, `claimReasons`, `orderCancellationReasons`, `trackingCarriers`, `countries` | read-only | Marketplace vocabulary the seller picks from |

### Status codes that matter

| Code | Meaning |
|---|---|
| 401 `authentication_failed` / `invalid_refresh_token` | No token, an expired one, one issued for another audience, or a user who runs no seller |
| 403 `access_denied` | No `X-Spree-Seller-Id`, a seller the user has no role on, or a missing permission (`details.required_permission`) |
| 404 `record_not_found` | Not found **for this seller**, including other sellers' records. The API never says "forbidden" for those |
| 422 `processing_error` | A workflow refused, for example submitting for review with a requirement outstanding (the message names it) |

If you build seller-side custom endpoints, keep the same shape: root every query in the current seller and return 404 for foreign records.

## Operator side: `/api/v3/admin/*` (`@spree/admin-sdk`)

| Resource | Routes | SDK |
|---|---|---|
| Sellers | CRUD; `POST :id/invite`; `PATCH :id/approve` (`override_requirements`), `:id/suspend` (`reason`), `:id/reject` (`reason`), `:id/reopen_onboarding` (`note`); `GET :id/onboarding` | `sellers.create/invite/approve/suspend/reject/reopenOnboarding/onboarding` |
| Seller ledger | `GET sellers/:id/balances`, `POST sellers/:id/payouts` (settle now) | `sellers.balances`, `sellers.settle` |
| Seller team | `sellers/:id/team` (index/destroy), `sellers/:id/invitations` (index/destroy/resend, `GET :id/acceptance_link` — needs `write_sellers`) | Lets the operator repair a seller that locked itself out |
| Requirement submissions | `sellers/:id/requirement_submissions` (index/show/create), `PATCH :id/accept`, `:id/reject` (`review_note`), `GET :id/download` | `sellers.requirementSubmissions.list/accept/reject/waive` (waive = `POST` with `requirement_id`) |
| Checklist config | `seller_requirements` CRUD, `GET seller_requirements/types` | `sellerRequirements.types/create/update/…` |
| Commission rates | CRUD, `GET commission_rates/rule_types` | `commissionRates.*`, `ruleTypes()` |
| Commission lines | index/show (read-only) | `commissionLines.list({ seller_id_eq })` |
| Transfers / payouts | `seller_transfers` index/show, `seller_payouts` index/show plus `PATCH :id/complete` (`reference`) | `sellerTransfers`, `sellerPayouts.complete` |
| Order groups | index/show (read-only) | `orderGroups.list/get` |
| Payout providers | `GET payout_providers`, returns `{ id, name, available, requires_payout_account, default }` | `payoutProviders.list` |
| Product review | `PATCH products/:id/approve`, `products/:id/reject` (`reason`) | `products.approve/reject` |
| Order completion | `PATCH orders/:id/complete` returns an Order **or an OrderGroup** | `isOrderGroup(result)` |

Payout webhooks (unauthenticated, signature checked by the gateway): `POST /api/v3/webhooks/payouts/:payment_method_id`.

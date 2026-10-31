---
name: spree-checkout
description: Use when the user is working on Spree 6 checkout — the Cart → Order split, checkout requirements and advisory steps, `Spree::Checkout::Registry` (add_requirement / register_step / base_steps), cart completion (`Spree::Carts::Complete`), `carts.complete` / `carts.add_item` workflow hooks, addresses, payment sessions, guest checkout, cart association/merge on login, or the Store API / `@spree/sdk` checkout sequence. Common phrasings include "checkout broken", "cart won't complete", "why can't this cart complete", "add a checkout step", "require a field before checkout", "require terms acceptance", "skip the delivery step", "order stuck", "double charge", "guest checkout", "cart not found after checkout", "merge carts on login", "custom checkout validation", "block checkout if…". Covers where each customization belongs and how completion guarantees idempotency.
---

# Spree Checkout

Checkout in Spree 6 is **data-driven, not a state machine**. A `Spree::Cart` collects items, addresses, delivery and payment in any order; the cart reports what it still needs (`requirements`); and exactly one hard gate — the `Spree::Carts::Complete` workflow — turns it into an immutable `Spree::Order`.

> Coming from 5.x (`order.next!`, `checkout_flow`, `state`)? Those APIs are gone — see `spree-upgrade-5-to-6`.

## Cart vs Order

| | `Spree::Cart` (`cart_…`) | `Spree::Order` (`or_…`) |
|---|---|---|
| Phase | Shopping + checkout | Placed purchase (financial record) |
| Lifecycle marker | `completed_at` only — **no status column** | `status` (`draft`/`placed`/`canceled`) + `payment_status` / `fulfillment_status` |
| Mutable? | Yes, until completed; then **read-only** (`readonly?` blocks every write) | Items/prices frozen; admin edits go through explicit services |
| Checkout introspection | `requirements`, `checkout_steps`, `current_checkout_step`, `completed_checkout_steps` | None — it's already placed |
| Money | Rows regenerated on every recalculation | Rows frozen; totals only re-summed |

Records that live through both phases — `LineItem`, `Fulfillment`, `Payment`, `PaymentSession`, `StockReservation`, `TaxLine`, `Discount`, `Fee` — carry **two nullable FKs** (`cart_id` + `order_id`, exactly one set). Always read the parent through `#owner`:

```ruby
line_item.owner   # => Spree::Cart during checkout, Spree::Order after
line_item.order   # nil during checkout — don't assume it's present
```

Shared behavior (addresses, taxation, store credit, gift cards, payment processing, currency/market) lives in `Spree::Purchase::*` concerns included by both models. Decorate the concern (or use a hook) rather than only `Spree::Order`.

`order.cart` points back at the source cart; `spree_orders.cart_id` is **unique** — it's the completion idempotency key.

## Requirements: the one thing checkout enforces

Every cart read computes `Spree::Checkout::Requirements.new(cart).call` → an array of `{ step:, field:, code:, message: }`. Branch on `code`; `message` is translated prose; `step` is a grouping hint.

Built-in advisory requirements (reported on every cart read):

| `code` | `step` | Raised when |
|---|---|---|
| `line_items_required` | `cart` | Cart is empty |
| `email_required` | `address` | No email |
| `ship_address_required` | `address` | Something ships and there's no address |
| `delivery_method_required` | `delivery` | A fulfillment has no delivery method selected |
| `payment_required` | `payment` | Valid payments don't cover `amount_due_at_checkout` |
| `po_number_required` | `address` | The buyer's company requires a PO number (staff-keyed carts exempt) |
| `order_minimum_not_met` | `cart` | Below the B2B order minimum |

Completion-only checks (`call(completion: true)`, run inside `Carts::Complete` because they load every line item): `out_of_stock`, `discontinued`, `quantity_rule_violated` (all `step: 'cart'`), and `guest_checkout_not_allowed`.

**An empty `requirements` array does not guarantee completion will succeed.** Treat a failed completion as a normal path.

## Steps are advisory

```ruby
cart.checkout_steps             # => ["address", "delivery", "payment", "complete"]
cart.current_checkout_step      # => step of the first unmet requirement ("cart" reports as "address")
cart.completed_checkout_steps   # => steps before the current one
```

The Store API exposes these as `current_step` and `completed_steps`. Built-in steps come from `Spree::Checkout::Registry.base_steps`:

| Step | Present when |
|---|---|
| `address` | Always |
| `delivery` | `cart.delivery_step_required?` (has items, not all-digital) |
| `payment` | `cart.payment_required?` (total above zero) |
| `confirm` | `cart.confirmation_required?` (a payment method asks, or store preference) |
| `complete` | Always |

Nothing on the server refuses a write because of the step — clients may set email, address, delivery and payment in any order. A free digital order reports `address` → `complete`; don't hardcode five steps in a storefront.

## Customizing: `Spree::Checkout::Registry`

Configure in `server/config/initializers/spree.rb`. One declaration feeds **both** the `requirements` array and the completion gate.

Registration timing: the Registry is plain class-level state loaded from `lib/` — core never resets it at boot (only `Registry.reset!`, meant for tests), so top-level initializer calls or a `Rails.application.config.after_initialize` block both work. Avoid `config.to_prepare`: it re-runs on every dev code reload and `add_requirement` / `register_step` append without de-duplicating, so each reload adds another copy of the requirement.

### Add a requirement to an existing step

```ruby
# Require accepting terms before placing the order (stored in cart metadata,
# written by the storefront via PATCH /carts/:id { metadata: { terms_accepted: true } })
Spree::Checkout::Registry.add_requirement(
  step: :payment,
  field: :terms_accepted,                       # code becomes "terms_accepted_required"
  message: 'You must accept the terms of sale',
  satisfied: ->(cart) { ActiveModel::Type::Boolean.new.cast(cart.metadata['terms_accepted']) },
  applicable: ->(cart) { cart.market&.name == 'Europe' } # optional, checked before satisfied:
)
```

- `code` is always derived as `"#{field}_required"` for added requirements.
- `message` is stored verbatim at boot — a `Spree.t` call here resolves once, in the boot locale. For per-request translation use `register_step` (its `requirements:` lambda runs per cart).
- `Spree::Checkout::Registry.remove_requirement(step:, field:)` removes one you (or an extension) registered.

PO numbers are already built in: set `po_number_required` on the company and the cart reports `po_number_required` (see `spree-b2b`). Don't re-register it.

### Add a whole step

```ruby
Spree::Checkout::Registry.register_step(
  name: :loyalty,
  before: :payment,                                  # or after:; before: wins if both
  applicable: ->(cart) { cart.customer.present? },
  satisfied: ->(cart) { cart.metadata['loyalty_number'].present? },
  requirements: ->(cart) {
    [{ step: 'loyalty', field: 'loyalty_number', code: 'loyalty_number_missing',
       message: Spree.t('loyalty.number_required', default: 'Enter your loyalty number') }]
  }
)
```

Unanchored steps (or anchors this cart doesn't have, like `before: :payment` on a free cart) land right before `complete`. `Registry.remove_step(:loyalty)` undoes it.

### Reorder or drop built-in steps

```ruby
Spree::Checkout::Registry.base_steps.delete('confirm')
Spree::Checkout::Registry.base_steps['payment'] = ->(cart) { cart.total > 0 }
Spree::Checkout::Registry.base_step_names = %w[address payment delivery complete]
```

Removing a step only removes the **label**. Requirements filed under it still gate completion — dropping `payment` does not let an unpaid cart complete.

### Storing the data a requirement checks

`Spree::Cart` has a `metadata` JSON column the Store API accepts on `PATCH /api/v3/store/carts/:id` (merged, not replaced). Carts do **not** include `Spree::HasCustomFields`. At completion the cart's `metadata` is **deep-copied onto the order** (and, for a checkout split between sellers, onto every child order and the `OrderGroup`), so `order.metadata['vat_number']` is still there after placement. After that the two are independent — editing one never changes the other. **Treat those keys as customer input:** shoppers write cart metadata through the Store API, so never keep anything your code later trusts there (fraud/approval flags, prices, entitlements) — use a staff-only field, custom field or your own column for that.

## Completion: `Spree::Carts::Complete`

```ruby
result = Spree.carts_complete_workflow.call(cart: cart)          # optional expected_total:, payment_pending:
if result.success?
  order = result.value   # Spree::Order — or Spree::OrderGroup when a multi-seller cart split
else
  result.error.to_s      # why: requirements, payment failure, hook rejection, cart_changed...
end
```

Three phases with explicit transaction boundaries:

1. **Prepare**: replay check and contract-price confirmation run first, outside the lock. Then, under `cart.with_lock`: concurrent-completion guard → **in-lock recalculation** (the charged total is computed now, never trusted from earlier requests) → optional `expected_total` drift guard (`cart_changed`) → `Requirements#call(completion: true)` → **`carts.complete.validate` hooks** → stamp `completing_at` → create a `draft` order copying line items, fulfillments + selected rates, TaxLine/Discount/Fee rows, promotions, address snapshots, tax identifier and PO document; re-point payments, payment sessions, reservations and coupon codes.
2. **Payment** (`external_step`, outside any transaction): process payments if not already covered.
3. **Finalize**: `carts.complete.before_finalize` hooks → `Spree.order_complete_workflow` (inventory, `draft → placed`, statuses, `order.placed` event) → cart `completed_at` → coupon codes marked used → `tax_provider.commit` → `carts.complete.after_finalize` hooks.

### Guarantees you can rely on

- **Idempotent.** A double-click, retry, or a payment webhook racing the customer's return gets the **same order back** — the replay step returns `cart.order`, the unique `spree_orders.cart_id` index catches concurrent winners (`RecordNotUnique` re-enters and replays), and a live `completing_at` claim (5-minute TTL) returns `completion_in_progress` (API: `409`).
- **Crash recovery.** If the process dies after the order commit, the next attempt (or `Spree::Orders::FinalizeStaleDraftsJob`) re-runs Finalize instead of charging again.
- **Pre-capture failure rolls back.** A payment failure before any money is captured destroys the draft order, re-points payments/sessions/reservations/coupons back to the cart, and clears `completing_at` — the customer can fix and retry.
- **Guest token carries over.** The order gets `token: cart.token`, so a guest reads their order with the same `X-Spree-Token`.
- **Totals are recomputed at the last moment**, so a price or promotion that changed during review can't produce a wrong charge.

## Workflow hooks around checkout

Register in the initializer; handlers are class-name strings (reload-safe) with `call(workflow)`. See `spree-workflows` for the full hook catalog.

| Key | Kind | Use for |
|---|---|---|
| `carts.add_item.validate` | validate | Purchase limits, eligibility — before the line item is built |
| `carts.upsert_items.validate` | validate | Same rule for quantity edits/removals/bulk (register both keys) |
| `carts.add_item.after_item_added` | lifecycle (in txn) | Write related records atomically |
| `carts.complete.validate` | validate | Last-moment veto (fraud score, external credit check) — **before** any money moves |
| `carts.complete.before_finalize` | lifecycle | Runs **after payment**; copy data onto `workflow.order` |
| `carts.complete.after_finalize` | lifecycle | After the order is placed |
| `carts.merge.validate` / `after_merge` | validate / lifecycle | Merge policy |

```ruby
module MyApp
  class CreditCheck
    def call(workflow)
      cart = workflow.cart
      return unless cart.company && MyApp::Credit.on_hold?(cart.company) # your own service

      workflow.reject!('Your account is on credit hold. Contact your account manager.')
    end
  end
end

Spree.hooks.register('carts.complete.validate', 'MyApp::CreditCheck')
```

**Never reject in `before_finalize` or `after_finalize`.** The card has already been charged; rejecting rolls back the database but the charge stands. Veto in `validate`. And prefer a Registry requirement over a `validate` hook for anything the customer can fix — requirements show up on every cart read, a hook only fails at the end.

Side effects (emails, ERP push) belong in an `order.placed` event subscriber, not a hook (`spree-events-webhooks`).

## Addresses

`Spree::Purchase::Addresses` (shared by Cart and Order):

- **Dedupe:** `ship_address_attributes=` / `bill_address_attributes=` reuse an identical row from the customer's address book instead of creating duplicates; guests may only edit the row already in the slot.
- **Promote to defaults:** a signed-in customer's checkout address becomes their default ship/bill address (wallet/quick-checkout addresses excluded).
- **Ownership guard:** `ship_address_id=` / `bill_address_id=` only accept an address from the customer's own book (or their company's). Anything else silently resolves to `nil` — a guest can never select an address by ID.
- **`use_shipping: true`** copies the shipping address onto billing (shipping is canonical). `use_billing` is deprecated.
- Address fields: `first_name`, `last_name`, `address1`, `city`, `postal_code`, `country_code`, `state_code`.
- Signed-in customers get blank slots auto-filled from saved defaults.

Changing the address re-prices items, rebuilds delivery proposals and re-estimates tax (`cart.recalculate_for_address_change!`).

## Payment sessions

Sessions are **scoped to the cart**: `POST /api/v3/store/carts/:cart_id/payment_sessions` looks the cart up first, so a session id from another cart 404s. Create/update run under the cart row lock; `complete` deliberately doesn't hold the lock across the gateway call — `PaymentSession#settle_payment!` serializes locally, so a confirm racing the gateway webhook records the capture once. Only `complete` resolves an already-completed cart (the webhook may have finished checkout first); creating a session on a completed cart 404s. See `spree-payments`.

## Store API / SDK checkout sequence

```typescript
import { createClient } from '@spree/sdk'
const client = createClient({ baseUrl, publishableKey: 'pk_…' })

let cart = await client.carts.create()
const opts = { spreeToken: cart.token }            // guests: persist cart.id + cart.token

await client.carts.items.create(cart.id, { variant_id: 'variant_…', quantity: 1 }, opts)

cart = await client.carts.update(cart.id, {
  email: 'jane@example.com',
  shipping_address: { first_name: 'Jane', last_name: 'Doe', address1: '1 Main St',
    city: 'Austin', postal_code: '78701', country_code: 'US', state_code: 'TX' },
  use_shipping: true,
}, opts)

for (const f of cart.fulfillments) {
  await client.carts.fulfillments.update(cart.id, f.id,
    { selected_delivery_rate_id: f.delivery_rates[0].id }, opts)
}

const session = await client.carts.paymentSessions.create(cart.id, { payment_method_id: 'pm_…' }, opts)
// confirm with the provider's SDK (Stripe.js etc.), then:
await client.carts.paymentSessions.complete(cart.id, session.id, {}, opts)

cart = await client.carts.get(cart.id, opts)
if (cart.requirements.length) { /* route the user by requirements[0].step / code */ }

const result = await client.carts.complete(cart.id, opts)  // Order | OrderGroup — narrow with isOrderGroup from @spree/sdk
```

Every write returns the whole cart with fresh totals and `requirements` — never make a separate "recalculate" call. Discount codes, gift cards and store credit (`carts.discountCodes`, `carts.giftCards`, `carts.storeCredits`) can be applied any time before completion. Store credit is applied through its own endpoint and is never one of `cart.payment_methods`. A cart takes a gift card or store credit, not both. A gift card's share follows the total when delivery, discounts or tax change.

## Login: associate and merge

- `client.carts.associate(cartId, { token: jwt, spreeToken: cart.token })` (`PATCH /carts/:id/associate`) claims a guest cart for the signed-in customer. It requires **both** the JWT and the cart token, only claims guest carts (or the caller's own), fills email and blank addresses from the customer's defaults.
- The API does **not** auto-merge with the customer's other open carts (`customer.carts.where(store: current_store)` lists them — `Spree::Cart` rows). To fold two carts together, call `Spree.cart_merge_workflow.call(cart: survivor, other_cart: guest_cart, customer:)` (or `survivor.merge!(guest_cart)`) from your own endpoint/subscriber. A currency mismatch fails and keeps both carts. Policy (keep the larger cart, cap quantities) goes in a `carts.merge.validate` hook.

## After completion

- The completed cart is read-only and **404s on every Store API cart endpoint** (the cart scope is `incomplete`). Read the order via `client.orders.get(order.id, {}, { spreeToken })`.
- `POST /carts/:id/complete` is the exception: re-posting (with the cart id, or the returned order/group id) returns the existing order.
- Storefronts should drop the stored cart id/token once `complete` succeeds.

## Troubleshooting: "why can't this cart complete?"

1. **Read `cart.requirements`** (`spree console`: `Spree::Checkout::Requirements.new(cart).call(completion: true)`). The completion-only set adds stock/discontinued/quantity-rule/guest-policy failures.
2. `completion_in_progress` / `409` → another attempt holds `completing_at` (TTL 5 min). Retry; don't clear it by hand while a payment may be in flight.
3. `payment_required` though the customer paid → a gift card or store credit was removed: **any item change runs `Spree::Carts::Recalculate`, which unapplies gift cards and checkout store credit**. Re-apply after editing items.
4. `coupon_code_unavailable` → the cart no longer holds its single-use batch code (another cart took it over, or an order used it). The next cart read drops it with a warning; the shopper re-reviews the total (see `spree-promotions`).
5. `delivery_method_required` with no rates → the address has no matching delivery zone; `cart.warnings` carries `delivery_unavailable` per item.
6. A custom requirement never clears → your `satisfied:` lambda reads data the storefront never writes (e.g. `custom_fields` on a cart — use `metadata`).
7. Rejected by a hook → the error message comes from `workflow.reject!` / `workflow.errors` in some `carts.complete.validate` handler; `Spree.hooks.keys` lists registrations.

## Testing

```ruby
cart = create(:cart_ready_to_complete)
result = Spree.carts_complete_workflow.call(cart: cart)
expect(result).to be_success
expect(result.value).to be_placed
expect(Spree.carts_complete_workflow.call(cart: cart.reload).value).to eq(result.value) # replay

# Registry state is global — reset in an after hook
after { Spree::Checkout::Registry.reset! }
```

Factories: `:cart`, `:cart_with_line_items`, `:cart_ready_for_delivery`, `:cart_ready_to_complete`. See `spree-testing`.

## Common mistakes

- Looking for `order.state`, `next!`, `checkout_flow` — gone. Steps are derived; requirements are the gate.
- Adding a model validation on `Spree::Cart` for a checkout field — that blocks every partial write. Use a Registry requirement.
- Rejecting in `before_finalize` — money already moved.
- Reading `line_item.order` in code that runs during checkout — use `owner`.
- Hardcoding the step list in the storefront — render from `completed_steps` / `current_step` and route by `requirements[].code`.
- Writing to a completed cart (raises `ActiveRecord::ReadOnlyRecord`) — edit the order through the admin services instead.

## Where to read further

- `node_modules/@spree/docs/dist/developer/core-concepts/carts.md` and `orders.md`
- `node_modules/@spree/docs/dist/developer/customization/checkout.md` — Registry
- `node_modules/@spree/docs/dist/developer/customization/workflows.md` — hooks
- `node_modules/@spree/docs/dist/developer/sdk/store/cart-checkout.md`
- Related skills: `spree-order-totals`, `spree-taxes`, `spree-payments`, `spree-promotions`, `spree-fulfillment`, `spree-workflows`, `spree-b2b`
- Source: `spree/core/app/workflows/spree/carts/complete.rb`, `spree/core/lib/spree/checkout/`

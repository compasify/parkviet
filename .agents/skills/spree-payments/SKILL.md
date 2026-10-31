---
name: spree-payments
description: Use when the user is working with Spree 6 payments — payment methods and gateways (Stripe, Adyen, PayPal, Razorpay), session-based vs direct (offline) payment methods, payment sessions and payment setup sessions (saved cards), payment statuses, capture timing (checkout / on_dispatch / manual), capture and void, refunds, gateway webhooks, building a custom payment method, store credits and gift cards, and payment events. Common phrasings include "add payment gateway", "install Stripe", "custom payment method", "payment session", "client_secret", "3D Secure", "offsite redirect", "customer closed the tab", "payment webhook", "capture on shipment", "authorize only", "manual capture", "refund an order", "store credit", "gift card", "payment failed", "payment stuck", "payment.paid", "order.paid", "cash on delivery", "bank transfer", "purchase order".
---

# Spree Payments

```
PaymentMethod (pm_, belongs_to :store)       — a configured way to pay (STI: SpreeStripe::Gateway, Spree::PaymentMethod::Check, …)
  ├── PaymentSession (ps_)                     — gateway-side session (e.g. Stripe PaymentIntent); owned by a cart or order
  ├── PaymentSetupSession (pss_)               — save a payment method for later (e.g. SetupIntent); belongs to a customer
  └── GatewayCustomer                          — provider customer id per customer (internal, encrypted at rest)
Payment (py_)  — one attempt against a cart/order (cart_id + order_id; #owner)
  ├── source: CreditCard (card_) | PaymentSource (wallets, BNPL, bank) | StoreCredit (credit_)
  └── Refund (re_) × n  — with a RefundReason (rr_)
```

A payment is linked to its session by `payment.response_code == payment_session.external_id`. A cart can carry several payments (e.g. store credit + card).

## Payment statuses (no state machine)

`status` is a plain string (`Spree::HasStatus`) written only by the payment workflows and `Spree::Payment::Processing`:

| Status | Meaning |
|---|---|
| `checkout` | Created, not yet processed (default) |
| `processing` | Claimed for a gateway call (atomic claim; blocks double submission) |
| `pending` | Authorized, not captured |
| `completed` | Captured — only these count toward what's paid |
| `failed` | Gateway rejected it (retryable on the same row) |
| `void` | Voided |
| `invalid` | Superseded by a newer checkout payment (`has_invalid_status?` — `invalid?` is ActiveModel's) |

The order's `payment_status` (`none`, `authorized`, `partially_paid`, `paid`, `partially_refunded`, `refunded`, `overcharged`, `voided`) is derived by `Spree::Orders::UpdateStatuses` from payments and refunds (re-run on payment/refund/fulfillment events and by every placed-order money edit: fees, manual discounts, items) — never assign it. "Refunded" counts both ledgers: `Spree::Refund` rows **and** store credit issued as a refund (`order.store_credit_refunds`, `StoreCredit#refunded_order_id`), so an order refunded to store credit reads `partially_refunded` / `refunded`, not `paid`. `Spree::Order.refunded` / `.partially_refunded` scopes filter on this status.

## Capture timing

`capture_method` is a store preference (`preferred_capture_method`, default `checkout`) that a payment method can override (`capture_method`, nil = inherit):

| Value | Behaviour |
|---|---|
| `checkout` | Charged when the order is placed → `completed` |
| `on_dispatch` | Authorized at checkout (`pending`), captured when goods are dispatched |
| `manual` | Authorized at checkout (`pending`); staff capture when they choose |

```typescript
await admin.store.update({ preferred_capture_method: 'on_dispatch' })
await admin.paymentMethods.update('pm_xxx', { capture_method: 'manual' })  // null → inherit store
await admin.orders.payments.capture('or_xxx', 'py_xxx')
await admin.orders.payments.void('or_xxx', 'py_xxx')
```

In Ruby: `payment_method.resolved_capture_method`, `Spree.payment_capture_workflow.call(payment:, amount: nil)` — **`amount` is in cents**; a smaller amount captures part and splits the remainder into a new pending payment. `Spree.payment_void_workflow.call(payment:)`.

## Payment methods

| Attribute | Notes |
|---|---|
| `type` | API sends the shorthand (`stripe`, `check`, `store_credit`, …); the column holds the class |
| `store` | Single owner — `current_store.payment_methods` |
| `active` | Inactive methods are hidden everywhere |
| `storefront_visible` | `false` = staff-only (e.g. "Invoice" for admin-created orders). Replaces `display_on`. The Store API payment and payment-session endpoints accept only `active.storefront_visible` methods — a staff-only method's ID is a 404 there, not a loophole |
| `capture_method` | Override, see above |
| `preferences` | Gateway credentials — YAML in a plain text column, **not encrypted**; treat DB dumps as secret |

Hooks to override on a subclass: `session_required?`, `setup_session_supported?`, `source_required?`, `available_for_order?(order)`, `available_for_store?(store)`, `payment_icon_name`. The Store API embeds `payment_methods` (with `session_required`) in the cart response.

### Installing a gateway

```bash
spree bundle add spree_stripe && spree generate spree_stripe:install
spree bundle add spree_adyen --github spree/spree_adyen && spree generate spree_adyen:install
spree bundle add spree_paypal_checkout && spree generate spree_paypal_checkout:install
spree bundle add spree_razorpay_checkout && spree generate spree_razorpay_checkout:install
spree restart
```

Classic Rails app: `bundle add … && bin/rails g …:install`. Then create the payment method in the dashboard (Settings → Payments) and register its webhook URL (`payment_method.webhook_url` → `/api/v3/webhooks/payments/pm_…`) with the provider. `spree_stripe` is the reference implementation (sessions, setup sessions, webhooks, wallets, Stripe Connect payouts).

## Two flows

### Session-based (Stripe, Adyen, PayPal…) — `session_required? == true`

```typescript
const opts = { spreeToken: cart.token }
// 1. After delivery is chosen (amount must include shipping); recreate/update if the total changes
const session = await client.carts.paymentSessions.create(cart.id, { payment_method_id: 'pm_xxx' }, opts)
// 2. Customer pays in the provider SDK with session.external_data.client_secret (3DS/redirects handled there)
// 3. Confirm — creates/settles the Payment, does NOT place the order
await client.carts.paymentSessions.complete(cart.id, session.id, { session_result: '…' }, opts)
// 4. Place the order (Order | OrderGroup on a multi-seller marketplace cart — narrow with isOrderGroup)
const result = await client.carts.complete(cart.id, opts)
```

Session statuses: `pending`, `processing`, `completed`, `failed`, `canceled`, `expired` (no cancel endpoint — cancel/expire come from the provider or `expires_at`).

**Webhook-first completion.** The provider's webhook (`POST /api/v3/webhooks/payments/:payment_method_id`) is the authoritative signal: Spree finds the payment method by its prefixed ID alone (providers send no API key or store header), sets `Spree::Current.store` to the payment method's store, verifies the signature against that method's own secret synchronously (401 on failure), enqueues `Spree::Payments::HandleWebhookJob`, returns 200, then settles the payment and completes the cart via `Carts::Complete` — the job also runs in the payment method's store, so a non-default store's webhooks work without any host/header routing. Whichever of browser or webhook arrives first wins; the other is a no-op. Replays are handled in two layers: freshness belongs to the provider's signature scheme inside `parse_webhook_event` (Stripe's `Stripe::Webhook.construct_event` rejects timestamps older than 5 minutes — a custom gateway must enforce its provider's equivalent), and `Spree::Payments::HandleWebhook` is idempotent on the payment (a redelivery for an already-completed payment is a no-op under the order lock), so a replayed event can't pay or complete twice. Never treat a redirect back from the provider as proof of payment.

### Direct (Check, cash on delivery, bank transfer, PO) — `session_required? == false`

```typescript
await client.carts.payments.create(cart.id, {
  payment_method_id: 'pm_check',
  metadata: { purchase_order_number: 'PO-12345' },   // optional; amount defaults to total minus store credit
}, opts)
await client.carts.complete(cart.id, opts)
```

422 codes: `payment_session_required` (method needs a session), `payment_method_unavailable` (the method's `available_for_order?(cart)` is false — also checked when creating a payment session). On completion the payment lands `pending` (or `completed` when capture is `checkout`); staff capture it when the money arrives.

### Saved payment methods

`client.customer.paymentSetupSessions.create({ payment_method_id }, { token: jwt })` → confirm with the provider SDK using `external_client_secret` → `.complete(id, { external_data: {} })` creates a `CreditCard`/`PaymentSource`. Requires a signed-in customer.

## Building a custom payment method

```ruby
# app/models/my_gateway.rb
class MyGateway < Spree::PaymentMethod
  preference :api_key, :string
  preference :webhook_secret, :string

  def session_required? = true
  def source_required? = false
  def payment_session_class = Spree::PaymentSessions::MyGateway   # STI < Spree::PaymentSession

  # `order:` receives the Cart during checkout
  def create_payment_session(order:, amount: nil, external_data: {})
    total = amount.presence || order.total_minus_store_credits
    remote = client.create_session(amount_cents: Spree::Money.new(total, currency: order.currency).cents,
                                   currency: order.currency, reference: order.prefixed_id)
    payment_session_class.create!(owner: order, payment_method: self, amount: total, currency: order.currency,
                                  status: 'pending', external_id: remote.id, customer: order.customer,
                                  external_data: { client_secret: remote.client_secret })
  end

  def update_payment_session(payment_session:, amount: nil, external_data: {})
    client.update_session(payment_session.external_id, amount: amount) if amount.present?
    payment_session.update!(amount: amount) if amount.present?
    payment_session
  end

  # Verify with the provider, settle the Payment, move the session. Must NOT complete the order.
  def complete_payment_session(payment_session:, params: {})
    remote = client.retrieve_session(payment_session.external_id)
    case remote.status
    when 'succeeded', 'authorized'
      payment_session.process if payment_session.can_process?
      payment_session.settle_payment!(captured: remote.status == 'succeeded')  # false → payment stays pending
      payment_session.complete unless payment_session.completed?
    else
      payment_session.fail if payment_session.can_fail?
    end
    payment_session
  end

  # Return { action: :captured|:authorized|:failed|:canceled, payment_session:, metadata: {} } or nil to ignore
  def parse_webhook_event(raw_body, headers)
    raise Spree::PaymentMethod::WebhookSignatureError unless client.valid_signature?(raw_body, headers['HTTP_X_SIGNATURE'], preferred_webhook_secret)

    event = JSON.parse(raw_body)
    session = payment_sessions.find_by(external_id: event.dig('data', 'session_id'))
    return unless session

    { 'payment.succeeded' => { action: :captured, payment_session: session },
      'payment.failed'    => { action: :failed,   payment_session: session } }[event['type']]
  end

  def payment_icon_name = 'my-gateway'

  private

  def client = MyProvider::Client.new(preferred_api_key)
end
```

```ruby
# config/initializers/spree.rb — core reassigns this registry in its own after_initialize,
# so register inside after_initialize or the entry is wiped
Rails.application.config.after_initialize do
  Spree.payment_methods << MyGateway
end
```

- `settle_payment!(captured:)` is the single settlement path shared by the confirm call and the webhook — it locks the owner, finds or creates the payment, and confirms it; it's safe to race.
- Session transitions (`process`, `complete`, `fail`, `cancel`, `expire`) are non-raising compare-and-swap writes returning `false` when they lose a race; guards are `can_process?`, `can_complete?`, `can_fail?`…
- For setup sessions: `setup_session_supported?`, `payment_setup_session_class`, `create_payment_setup_session(customer:, external_data:)`, `complete_payment_setup_session(setup_session:, params:)`.
- Legacy card gateways subclass `Spree::Gateway` (ActiveMerchant-style `authorize`/`purchase`/`capture`/`void`/`credit` on a provider).

Extend behaviour without subclassing via workflow hooks: `payments.process.validate`, `payments.capture.before_capture`, `payments.void.after_void`, `payment_sessions.complete.after_complete`, `payments.handle_webhook.after_handle` (`Spree.hooks.register('payments.capture.validate', ->(wf) { wf.reject!('…') if … })`). See `spree-workflows`.

## Refunds

Refunds are Admin-only (no Store API route) and run through `Spree::Refunds::Create` (`Spree.refund_create_workflow`): the refund row commits first, then the gateway is credited; a clean gateway failure removes the uncredited row.

```typescript
await admin.orders.refunds.create('or_xxx', { payment_id: 'py_xxx', amount: '25.00', refund_reason_id: 'rr_xxx' })
```

The param is `refund_reason_id` (older `@spree/admin-sdk` releases also accepted `reason_id`, which the API silently drops — the refund then falls back to the store's first refund reason).

```ruby
Spree.refund_create_workflow.call(payment: payment, amount: 25, reason: reason, refunder: admin_user)
# amount nil → full creditable balance (payment.credit_allowed)
```

Hooks: `refunds.create.validate`, `.before_refund`, `.after_refund`. Publishes `payment.refunded`; the order moves to `partially_refunded` / `refunded`. Returns-driven refunds (to the original payment or store credit) go through `Spree::Returns::Refund` — see `spree-returns`.

## Store credits and gift cards

| | Store credit (`credit_`) | Gift card (`gc_`) |
|---|---|---|
| Belongs to | A customer (and store) | A store; optional customer |
| Issued by | Admin (`admin.customers.storeCredits.create('cust_xxx', { amount, currency, memo })`) or return/exchange workflows (`originator`) | Admin (`admin.giftCards.create`, bulk via `admin.giftCardBatches.create`) |
| At checkout | `client.carts.storeCredits.apply(cartId, amount?)` / `.remove` — signed-in customers | `client.carts.giftCards.apply(cartId, code)` / `.remove` — guests too; separate from `discount_codes` |
| Expiry | Never; spent oldest-first (`Spree::StoreCredit.oldest_first`) | Per card `expires_at` |
| Statuses | — | `active`, `partially_redeemed`, `redeemed`, `canceled` (+ expired by date) |

Both pay via `Spree::PaymentMethod::StoreCredit` and reduce the amount due, not the order total. Both are **applied** before the customer picks a payment method, never chosen as one: the store-credit method is excluded from `cart.payment_methods`, and `POST /carts/:id/payments` with it answers `payment_method_unavailable`. Collect whatever `amount_due` is left with a real method. A cart uses a gift card **or** store credit, never both (each apply refuses while the other is on the cart). A gift card's payment covers `min(spendable balance, total)` and is resized on every totals recalculation as delivery, discounts or tax move; it's released when nothing is left to pay. Item changes still unapply both (see `spree-checkout`). Workflows: `Spree.gift_card_apply_workflow` / `gift_card_remove_workflow` / `gift_card_redeem_workflow` / `gift_card_cancel_workflow`; `Spree.store_credit_apply_service` / `store_credit_remove_service`. Cancelling a gift card is refused once it has been spent against. A gift card's `code` is a bearer credential: Admin API responses show it in full only to callers holding `read_gift_cards` (masked to the last four characters elsewhere, e.g. on orders), the webhook delivery log stores it as `[REDACTED]`, and company members see it masked on colleagues' orders. Setting `customer_id` on a gift card through the Admin API needs `read_customers` too (403 `required_permission` otherwise). `Spree::StoreCreditCategory` / `StoreCreditType` are deprecated shells.

## Events

`payment.completed`, `payment.paid`, `payment.captured`, `payment.voided`, `payment.refunded`, `order.paid` (order fully settled — also per child order on split marketplace checkouts), `payment_session.{processing,completed,failed,canceled,expired}`, `payment_setup_session.*`, `gift_card.*`. There is no gateway log table — for transaction forensics use `payment.gateway_dashboard_payment_url` or the `PaymentSession`'s `external_data`. See `spree-events-webhooks`.

## Troubleshooting

- **Payment stuck in `processing`**: the claim happened but the gateway call/crash didn't finish. `failed` and `processing` are claimable, so re-running the workflow (`Spree.payment_process_workflow.call(payment:)`) retries on the same row — check the provider dashboard first.
- **Charged but no order**: the webhook should complete it — verify the webhook URL/secret at the provider and that jobs are running (Solid Queue / `/jobs`). Check `payment_session.status` and `cart.completed_at`.
- **Webhook 401**: `parse_webhook_event` raised `WebhookSignatureError` — wrong secret, or you parsed a re-serialized body instead of `raw_body`.
- **Direct payment rejected with `payment_session_required`**: that method needs the session flow.
- **Amount mismatch on session**: session created before delivery/coupon changed the total — update the session amount or create a new one.

## Where to read further

- `node_modules/@spree/docs/dist/developer/core-concepts/payments.md`
- `node_modules/@spree/docs/dist/developer/how-to/custom-payment-method.md`
- `node_modules/@spree/docs/dist/developer/core-concepts/store-credits-gift-cards.md`
- `node_modules/@spree/docs/dist/integrations/payments/stripe.md` (also `adyen.md`, `paypal.md`, `razorpay.md`)
- Source: `Spree::PaymentMethod`, `Spree::Payment`, `Spree::PaymentSession`, `Spree::Payments::*`, `Spree::Refunds::Create` in `spree_core`; `spree/providers/stripe` for a full gateway
- Related skills: `spree-checkout`, `spree-workflows`, `spree-returns`, `spree-events-webhooks`, `spree-security`

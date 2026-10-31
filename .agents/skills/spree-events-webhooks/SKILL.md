---
name: spree-events-webhooks
description: Use when the user wants Spree 6 to react to something that happened — sync placed orders to an ERP/WMS, send a notification, keep an audit trail, fire outbound webhooks, configure webhook endpoints, verify webhook signatures, or debug a subscriber or delivery that never arrived. Common phrasings include "when an order is placed", "react to X", "Spree events", "subscriber", "publish_event", "publishes_lifecycle_events", "order.placed", "order.completed", "webhook endpoint", "X-Spree-Webhook-Signature", "HMAC", "webhook retry", "webhook disabled", "webhook.test", "audit log / state changes". Covers in-process subscribers AND outbound webhooks, and when to use a workflow hook instead.
---

# Spree Events + Webhooks

Spree announces what happened (`order.placed`, `payment.completed`, `fulfillment.fulfilled`, …) through one event bus. Two consumers sit on it:

| Consumer | Lives | Use for |
|---|---|---|
| **Subscribers** | Ruby classes in your Spree app | Your own side effects — ERP sync, custom email, analytics, audit history |
| **Webhooks** | HTTPS POSTs to external URLs | Another system is the consumer — Next.js storefront, n8n/Zapier/Make, partner apps |

If the reacting code lives outside the Rails app, use a webhook. If it lives inside, use a subscriber.

### Events vs workflow hooks

Events fire **after the fact** and normally run in the background. They cannot stop or change the operation. If you need to veto (`workflow.reject!`), add a step, or feed data into a calculation *while the operation runs*, register a workflow hook instead — `Spree.hooks.register('<flow>.<hook>', Handler)` — see the `spree-workflows` skill.

| Need | Use |
|---|---|
| Block a cart completion / return / cancel under a business rule | Hook (`*.validate`) |
| Do something extra inside the flow, same transaction | Hook (`after_*`) |
| Push a placed order to a WMS, send a Slack message | Subscriber |
| Notify a system outside Spree | Webhook |
| Keep a history of status changes | Subscriber writing your own table |

**Events are the audit trail.** Spree keeps no `StateChange`/`LogEntry` rows. Every meaningful transition already publishes an event (`order.placed`, `order.canceled`, `payment.completed`, `payment.voided`, `fulfillment.fulfilled`, `fulfillment.delivered`, `fulfillment.canceled`, `return.*` …). If you need persistent history, write it from a subscriber.

## Events Spree publishes

Two kinds:

1. **Lifecycle events** — `<prefix>.created`, `.updated`, `.deleted`, emitted after commit by models that declare `publishes_lifecycle_events` (orders, carts, line items, products, variants, prices, payments, fulfillments, stock levels, returns, customers, media, and many more). Customers use the `user.*` prefix (`user.created`, …). A bare `touch` does not emit `.updated`.
2. **Business events** — published explicitly at the moment that matters:

| Event | When |
|---|---|
| `order.placed` | Checkout completed (or an admin placed a draft order). Payload includes `notify_customer` |
| `order.paid` | Payments cover the order total |
| `order.fulfilled` / `order.delivered` | Every fulfillment handed over / delivered |
| `order.canceled` | Order canceled (final — orders can't be resumed) |
| `order.approved` | Risky order approved by staff |
| `cart.created` / `.updated` / `.deleted` | Cart lifecycle — carts are a separate resource from orders |
| `payment.completed` / `.captured` / `.voided` / `.refunded` | Payment moments |
| `payment_session.completed` / `.failed` / `.expired` … | Provider session outcomes (same set on `payment_setup_session.*`) |
| `fulfillment.fulfilled` / `.delivered` / `.canceled` | Parcel went out / arrived / stood down (`fulfilled` metadata carries `notify_customer`) |
| `product.out_of_stock` / `.back_in_stock` / `.activated` / `.archived` | Catalog availability |
| `return.*`, `exchange.*`, `claim.*` | Post-purchase flows (`return.received`, `return.refunded`, …) |
| `digital_link.downloaded` | Customer downloaded a digital asset |
| `import.completed`, `import_row.failed` | Bulk imports |

Full list with payload notes: [references/events.md](references/events.md). The canonical reference is `webhooks-events.md` in the docs (see bottom).

**Pick the specific event.** `order.updated` fires on every note edit; `order.placed` fires once. Sending a confirmation on `order.updated` is how customers get nine emails.

### Renamed events (one-release aliases)

`order.completed` → `order.placed`, `order.shipped` → `order.fulfilled`, `shipment.shipped` → `fulfillment.fulfilled`, `shipment.canceled` → `fulfillment.canceled`, `stock_item.*` → `stock_level.*`, `wished_item.*` → `wishlist_item.*`, `digital.*` → `digital_asset.*`. The old names are still published alongside the new ones until 6.1 — so an `order.*` subscriber sees **both** `order.placed` and `order.completed`, and a `fulfillment.*`+`shipment.*` one sees both names too. Subscribe to the new names. Only `order.completed` carries `metadata.deprecated_alias_of`; in wildcard handlers skip the old names explicitly (see the audit recipe). Coming from 5.x? See `spree-upgrade-5-to-6`.

## Part 1: Subscribers

### Generate one

```bash
spree generate subscriber OrderPlaced order.placed order.canceled   # classic: bin/rails g spree:subscriber …
# --sync       → subscribes_to …, async: false
# --skip-spec  → no spec/subscribers/… file
```

It writes `app/subscribers/order_placed_subscriber.rb`, a spec, and — the step people forget — the registration line in `config/initializers/spree.rb`:

```ruby
Rails.application.config.after_initialize do
  Spree.subscribers << OrderPlacedSubscriber
end
```

Subscribers are **not** auto-discovered. An unregistered subscriber is a silent no-op.

Register the class constant. A class-name String (`'OrderPlacedSubscriber'`) is also accepted and resolved when subscribers are registered at boot, but through 6.0.0.beta4 a String only resolved in development and test. In production it crashed boot with `NoMethodError: undefined method 'subscription_patterns' for String`, a failure your specs can't catch.

```ruby
# app/subscribers/order_placed_subscriber.rb
class OrderPlacedSubscriber < Spree::Subscriber
  subscribes_to 'order.placed'

  def handle(event)
    order = Spree::Order.find_by_prefix_id(event.payload['id'])
    return unless order

    WarehouseClient.new.submit(order)
  end
end
```

- Implement `handle(event)`. Don't override `call` — the base `call` routes `on` handlers and falls back to `handle`.
- `event.name`, `event.payload` (string keys, serialized with the API v3 serializer — prefixed IDs, money as strings), `event.metadata` (always `spree_version`), `event.store_id`, `event.id` (UUID), `event.created_at`.
- Payloads carry the record's top-level attributes only; load the record (`find_by_prefix_id`) when you need associations.

### Several events, wildcards, routing

```ruby
class PaymentSubscriber < Spree::Subscriber
  subscribes_to 'payment.completed', 'payment.voided', 'return.*'

  on 'payment.completed', :handle_complete
  on 'payment.voided',    :handle_void
  # anything without an `on` falls through to #handle

  def handle(event)
    Rails.logger.info("[returns] #{event.name}")
  end

  private

  def handle_complete(event)
    # ...
  end

  def handle_void(event)
    # ...
  end
end
```

### Async (default) vs sync

By default each subscriber runs in `Spree::Events::SubscriberJob` on `Spree.queues.events` (`:default` unless you change it), so a slow API call never slows checkout. The job retries up to 3 times on errors — **make handlers idempotent** (check whether you already acted).

`subscribes_to 'order.placed', async: false` runs inline in the publishing process. Errors raised by sync subscribers are reported via `Rails.error` and **re-raised only in development/test** — in production they are swallowed, so don't rely on a sync subscriber to abort anything (use a hook for that).

### Publishing your own events

Any Spree model can publish:

```ruby
order.publish_event('order.flagged_for_review')                     # payload = serialized order
order.publish_event('order.flagged_for_review', { 'id' => order.prefixed_id, 'score' => 87 })
Spree::Events.publish('brand.synced', { 'id' => brand.prefixed_id })  # from anywhere
```

Custom events flow to subscribers **and** webhook endpoints. Publish after your write commits — `publish_event` dispatches immediately, and async subscribers could otherwise read uncommitted data.

### Lifecycle events on your own model

```ruby
module Spree
  class Brand < Spree.base_class
    publishes_lifecycle_events                     # brand.created / .updated / .deleted
    # publishes_lifecycle_events only: [:create, :delete]
    # publishes_lifecycle_events except: [:update]
    # self.event_prefix = 'brand'                  # override the prefix if needed
  end
end
```

The payload uses `Spree::Api::V3::BrandSerializer` if it exists (the `spree:api_resource` generator creates it), otherwise a minimal `{ id, created_at, updated_at }`. `.deleted` captures the payload before destroy.

### Silencing events

```ruby
Spree::Events.disable { bulk_fix! }                 # nothing published in the block
Spree::Events.disable_lifecycle { import_rows! }    # suppress *.created/updated/deleted only
```

Use in data migrations and backfills so you don't flood webhooks.

### Store context matters

Every event records `store_id` from `Spree::Current.store`. Webhook delivery **skips events with no store**, and endpoints only receive events from their own store. In jobs, rake tasks and console scripts set it explicitly:

```ruby
Spree::Current.store = order.store
order.publish_event('order.flagged_for_review')
```

## Part 2: Webhooks (outbound HTTPS)

```
event published ─▶ Spree::WebhookEventSubscriber (subscribes to '*', ships with spree_api)
  ─▶ for each enabled Spree::WebhookEndpoint in event.store_id that subscribed_to?(name)
  ─▶ Spree::WebhookDelivery (whd_…) ─▶ Spree::WebhookDeliveryJob (Spree.queues.webhooks)
  ─▶ Spree::Webhooks::DeliverWebhook: signed POST, 30s timeout, result recorded
```

### Create an endpoint

Dashboard: **Settings → Developer → Webhooks**. Or the Admin API:

```bash
spree api post /webhook_endpoints -d '{
  "name": "ERP sync",
  "url": "https://erp.example.com/spree-webhooks",
  "subscriptions": ["order.placed", "order.canceled", "fulfillment.*"],
  "active": true
}'
```

```ts
const endpoint = await admin.webhookEndpoints.create({
  url: 'https://erp.example.com/spree-webhooks',
  subscriptions: ['order.placed', 'fulfillment.*'],
})
endpoint.secret_key // 64-char hex — returned ONLY on create; store it now
```

- `subscriptions`: exact names, wildcards (`order.*`), or `"*"`/empty = everything.
- Endpoints belong to the current store (set from the request, never passed).
- Endpoint IDs are `whe_…`, deliveries `whd_…`.
- `spree_api` config: `SPREE_WEBHOOKS_ENABLED` (global kill switch), `SPREE_WEBHOOKS_VERIFY_SSL` (default on outside development).
- Password-reset events for admin and seller users are never delivered, even to `*` endpoints.
- `customer.password_reset_requested` carries a live reset token, so it is in `Spree::WebhookEndpoint::CREDENTIAL_EVENTS`: it reaches **only endpoints that list it by name** — never `*`, an empty subscription list, or a pattern like `customer.*`. Creating an endpoint that names it, or changing the URL/subscriptions of one that does, needs `write_customers` on top of `write_webhooks` (403 otherwise).
- Customer records publish `user.created` / `user.updated` / `user.deleted` (plus `customer.anonymized`, `customer.password_reset*`) — there is no `customer.created`.

### Envelope + headers

```http
POST /spree-webhooks
Content-Type: application/json
User-Agent: Spree-Webhooks/1.0
X-Spree-Webhook-Signature: <hex hmac-sha256>
X-Spree-Webhook-Timestamp: 1767225600
X-Spree-Webhook-Event: order.placed

{ "id": "<event uuid>", "name": "order.placed", "created_at": "…",
  "data": { "id": "or_m3Rp9wXz", "number": "R123456789", "total": "129.99", "notify_customer": true, … },
  "metadata": { "spree_version": "6.0.0" } }
```

`id` is the event UUID — use it to dedupe on the receiving side.

### Verify the signature

HMAC-SHA256 over `"#{timestamp}.#{raw_body}"` with the endpoint's `secret_key`.

```ruby
def verified?(request)
  ts   = request.headers['X-Spree-Webhook-Timestamp'].to_i
  sig  = request.headers['X-Spree-Webhook-Signature'].to_s
  body = request.raw_post
  return false if (Time.current.to_i - ts).abs > 300   # replay window

  expected = OpenSSL::HMAC.hexdigest('SHA256', ENV.fetch('SPREE_WEBHOOK_SECRET'), "#{ts}.#{body}")
  ActiveSupport::SecurityUtils.secure_compare(expected, sig)
end
```

```ts
import crypto from 'node:crypto'

export function verified(rawBody: string, ts: string, sig: string, secret: string) {
  if (Math.abs(Date.now() / 1000 - Number(ts)) > 300) return false
  const expected = crypto.createHmac('sha256', secret).update(`${ts}.${rawBody}`).digest('hex')
  return expected.length === sig.length && crypto.timingSafeEqual(Buffer.from(expected), Buffer.from(sig))
}
```

Verify against the **raw** body (re-serialized JSON won't match), always timing-safe compare, always check the timestamp. In Next.js route handlers read `await req.text()` before parsing.

### Failures, redelivery, auto-disable

- A non-2xx response, timeout or connection error marks the delivery failed (`response_code`, `response_body`, `error_type`, `request_errors`, `execution_time`) and `Spree::WebhookDeliveryJob` **retries it with backoff** (`retry_on …, wait: :polynomially_longer, attempts: 5`): 5 attempts in total over roughly six minutes, each overwriting the outcome on the **same** delivery record (the log shows the latest attempt). Retries stop as soon as the endpoint is switched off (by hand or by auto-disable); an exhausted retry is not re-raised into the queue backend. Every attempt carries the same event `id` — dedupe on it.
- Resend manually once retries are exhausted: dashboard delivery log, `delivery.redeliver!`, `POST /api/v3/admin/webhook_endpoints/:id/deliveries/:id/redeliver`, or `admin.webhookEndpoints.deliveries.redeliver(whe, whd)`.
- After **15 consecutive failed deliveries** (`Spree::WebhookEndpoint::AUTO_DISABLE_THRESHOLD`; counted per delivery record, not per retry attempt) the endpoint is disabled (`active: false`, `disabled_at` set) and staff get `Spree::WebhookMailer.endpoint_disabled`. Re-enable with `endpoint.enable!`, `PATCH …/webhook_endpoints/:id/enable`, or by setting `active: true` in the dashboard — all clear the disabled state.
- **The delivery log is not the wire payload.** Credentials are redacted before `spree_webhook_deliveries.payload` is written and re-attached only in memory at send time (`Spree::WebhookPayloadRedaction`): `token` (guest cart token), `reset_token`, `unsubscribe_token`, `verification_token`, `download_url`, payment-session client secrets, and a gift card's `code`. Receivers get the real values (automatic retries included); the log and Admin API show `[REDACTED]`. A manual redelivery resends the stored payload, so those fields arrive as `[REDACTED]` — don't rely on redelivering password-reset or payment-session events.
- The Admin API returns a delivery's `payload` only when the caller can read the record the event is about (`delivery.payload_permission_key`, e.g. `read_orders` for `order.*`, `read_customers` for `customer.*`/`user.*` and any unmapped subject); otherwise `payload` is `null` and only status/response are shown.
- If you need guaranteed delivery, make the receiver fast (ack 2xx, then queue) and reconcile periodically via the Admin API.

### Test an endpoint

```ruby
endpoint.send_test!   # queues a synthetic 'webhook.test' delivery
```

Or `POST /api/v3/admin/webhook_endpoints/:id/send_test` / the dashboard "Send test" button.

### SSRF + extra headers

Outside development, endpoint URLs that resolve to private/loopback addresses are rejected on save and requests go through `ssrf_filter`. In development, localhost / `host.docker.internal` work. To add outbound headers (e.g. trace propagation), append a callable in `config.to_prepare`:

```ruby
Spree::Webhooks::DeliverWebhook.header_decorators << ->(headers, delivery) { headers['X-Env'] = Rails.env }
```

## Recipes

**Persist an audit trail**

```ruby
class OrderAuditSubscriber < Spree::Subscriber
  subscribes_to 'order.*', 'payment.*', 'fulfillment.*'
  LEGACY_ALIASES = %w[order.completed order.shipped].freeze

  def handle(event)
    return if LEGACY_ALIASES.include?(event.name)        # 6.0 dual-emitted old names
    AuditEntry.create_or_find_by!(event_id: event.id) do |e|
      e.name = event.name
      e.resource_id = event.payload['id']
      e.payload = event.payload
    end
  end
end
```

**Slack on failed payment session**

```ruby
class PaymentFailureSubscriber < Spree::Subscriber
  subscribes_to 'payment_session.failed'

  def handle(event)
    Slack.notify("Payment session #{event.payload['id']} failed")
  end
end
```

## Debugging

**Subscriber never runs**
1. `Spree.subscribers.include?(MySubscriber)` — registered?
2. Exact event name? (`order.placed`, not `order.complete`.) Watch the log: `[Spree Event] order.placed | payload: …` (disable with `Spree::Config.events_log_enabled = false`).
3. Async? Is the job worker running (Solid Queue / Sidekiq), and did `Spree::Events::SubscriberJob` fail?
4. Tests: core's suite disables events globally; if your suite does too, tag the example `events: true` or wrap in `Spree::Events.enable { … }`.

**Endpoint receives nothing**
1. `endpoint.active? && !endpoint.auto_disabled?`
2. `endpoint.subscribed_to?('order.placed')`
3. Event had a store? (`Spree::Current.store` set in jobs/scripts.) Endpoint in the same store?
4. `endpoint.send_test!`, then `endpoint.webhook_deliveries.recent.first` for `response_code` / `request_errors`.
5. `SPREE_WEBHOOKS_ENABLED` not set to false; job worker running.

**Signature mismatch** — parsed body instead of raw, wrong endpoint's secret, or clock drift beyond your window.

## Where to read further

- Events: `node_modules/@spree/docs/dist/developer/core-concepts/events.md`
- Webhooks: `node_modules/@spree/docs/dist/developer/core-concepts/webhooks.md`
- Every event + payload: `node_modules/@spree/docs/dist/api-reference/webhooks-events.md` (https://spreecommerce.org/docs/api-reference/webhooks-events)
- Source: `Spree::Subscriber`, `Spree::Publishable`, `Spree::Events`, `Spree::WebhookEndpoint`, `Spree::WebhookDelivery`, `Spree::Webhooks::DeliverWebhook`, `Spree::WebhookEventSubscriber`
- Related skills: `spree-workflows` (hooks), `spree-security` (webhook receivers), `spree-testing` (testing subscribers)

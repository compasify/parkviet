---
name: spree-security
description: Use when the user is hardening a Spree 6 app, reviewing a PR or finding for security issues, managing secrets and API keys, configuring CORS/CSP, securing the dashboard or /jobs, handling GDPR data requests, or asking about Spree-specific risks (publishable vs secret keys, scope minimization, IDOR on carts/orders, rich-text XSS, webhook HMAC and SSRF, encrypted columns, PCI scope). Common phrasings include "Spree security", "leaked secret key", "rotate API key", "CORS", "Allowed Origins", "CSP", "XSS in product description", "IDOR", "cross-store data leak", "mass assignment", "permitted attributes", "webhook signature", "SSRF", "Active Record encryption", "GDPR", "anonymize customer", "PCI", "Mission Control password". For roles, permission keys and login strategies use spree-auth-permissions.
---

# Spree Security

Spree inherits Rails' security model and adds an e-commerce attack surface: payment flows, customer PII, staff credentials and outbound webhooks. This skill covers what a developer extending Spree 6 has to get right. For **who may do what** (roles, permission keys, scopes, storefront ownership, SSO), see `spree-auth-permissions`.

## Threat model in four lines

1. **Store API**: internet-facing and called by untrusted clients. Risks: IDOR on carts/orders, XSS via catalog content, abuse of cart/auth endpoints.
2. **Admin API + dashboard**: staff credentials get phished and integrations leak keys. Risks: over-scoped secret keys, cross-store leaks in custom controllers, privilege creep in roles.
3. **Payments**: money and PCI. Risks: card data in logs or the DB, unverified gateway webhooks, refund abuse.
4. **Outbound traffic**: webhooks and integrations. Risks: SSRF, unverified receivers.

## Secrets

- Keep them in Rails encrypted credentials or env vars, never in the repo. `VITE_*` variables are compiled into the dashboard bundle, so **never put a secret in one**.
- **Leaked secret:** rotate at the provider first, then update credentials/env and deploy, then scrub git history (`git filter-repo`). If you clean history first, the leaked key keeps working until it's rotated.
- **`secret_key_base` must stay stable per environment.** Secret API keys are stored as HMAC-SHA256 digests keyed by it, so rotating it invalidates every `sk_` key. It's also the last fallback for JWT signing. Set a dedicated JWT secret with `SPREE_JWT_SECRET_KEY` (or credentials `jwt_secret_key`).
- **Active Record encryption.** Spree encrypts `Spree::WebhookEndpoint#secret_key` and `Spree::GatewayCustomer#profile_id` (deterministic) and `Spree::UserIdentity#access_token` / `#refresh_token` (OAuth tokens) **only when keys are configured** — without them they're plaintext, and the starter logs a warning at boot. Set all three env vars: `ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY`, `ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY`, `ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT`.
  - `create-spree-app` writes a dev set into `.env`; `spree encryption init` adds one to an older project's `.env` (never overwrites existing keys, no `--force`; then recreate containers with `spree update`, or `spree dev` when ejected — `spree restart` keeps the old env); `spree encryption init --print` or `bin/rails db:encryption:init` prints a fresh set for production. Use a separate set per environment and back it up in your secret manager.
  - The starter's `config/application.rb` copies the env vars (falling back to the `active_record_encryption` credentials entry) **into `config.active_record.encryption`**. That matters: the webhook-secret and gateway-customer `encrypts` calls check `Rails.configuration.active_record.encryption`, so keys that live only in credentials, without that snippet, leave those two columns plaintext. Apps from an older starter need the snippet (see `spree-upgrade-5-to-6`).
  - **Never change or lose the keys** once data is encrypted. Rails can rotate the primary key, but not the deterministic key/salt the webhook secrets and gateway customer IDs use.
  - Turning encryption on for existing data: identity tokens stay readable (`support_unencrypted_data: true`) and encrypt on next write. Webhook secrets and gateway customer IDs don't — set `config.active_record.encryption.support_unencrypted_data = true` and `extend_queries = true`, deploy with the keys, run `[Spree::WebhookEndpoint, Spree::GatewayCustomer, Spree::UserIdentity].each { |m| m.find_each(&:encrypt) }`, then remove both settings.
- **Payment-method and integration preferences are not encrypted.** Gateway credentials live in the serialized `preferences` column, so treat the database and its backups as holding live secrets. Enter live gateway keys through the dashboard (Settings → Payments), not in seeds.

The `spree/agent-skills` plugin ships a hook that warns when an agent writes a known-shape secret (Stripe live keys, AWS keys, PATs). It's a tripwire, not a review.

## API keys

```
pk_*  Publishable. Safe in browser and mobile code. Store API only.
sk_*  Secret. Server-to-server only. Never ship it in a bundle, app or VITE_* variable.
```

- **Minimum scopes.** `spree api-key create --type secret --scopes read_orders,write_fulfillments`. Don't give integrations `write_all`. The scope list is in `spree-api-v3/references/scopes.md`.
- Scopes and channel bindings are **immutable**. To rotate or change access, mint a new key, deploy it, then revoke the old one (Settings → API keys, or `spree api-key revoke`).
- Writes made with a secret key are attributed to that key (`*_type: api_key`), so you can audit what a leaked key did through the actor fields and `WebhookDelivery` logs.
- Bind a storefront's publishable key to its channel so shoppers can't switch channels by sending `X-Spree-Channel`.
- A leaked `pk_` is a nuisance: rate-limit and rotate. A leaked `sk_` is a breach: revoke it, then audit.

## Dashboard and staff sessions

The React dashboard (`@spree/dashboard`, served at `/dashboard` by `spree_dashboard`) holds **no API keys**:

- Staff sign in and the **JWT lives in memory only** (5-minute default lifetime, `admin_jwt_expiration`). The refresh token is an **HttpOnly, signed cookie** scoped to `/api/v3/admin/auth`. JavaScript can't read it, and it rotates on every refresh.
- Over HTTPS the cookie is `SameSite=None; Secure`. Over plain HTTP it falls back to `SameSite=Lax` (dev only).
- **Same-origin** (the default: dashboard served by Rails at `/dashboard`) needs no CORS or cookie configuration.
- **Cross-origin** (dashboard on a CDN): HTTPS on both sides, **and** add the dashboard origin under **Settings → Allowed Origins** (`Spree::AllowedOrigin`, `/api/v3/admin/allowed_origins`). The starter's `config/initializers/cors.rb` consults that table for `/api/v3/admin/*` with `credentials: true`. CSRF protection for the cookie is SameSite plus the strict origin allowlist, so keep the list exact and short.
- **Gating in the UI is not authorization.** The dashboard hides buttons based on `GET /api/v3/admin/me` permission keys, but the API gate enforces them. Any dashboard plugin action must hit an endpoint that declares `scoped_resource` (see `spree-auth-permissions`). Record-level refusals behind that gate come from `Spree.ability_class` — a custom subclass can tighten staff access further, but it never loosens the key gate, and secret keys (`Spree::ApiKeyAbility`) bypass it.
- Staff SSO: register `OidcStrategy` and optionally remove `:email` from `Spree.admin_authentication_strategies`. Staff accounts are never auto-provisioned from the IdP.
- Staff-management guardrails are built in (details in `spree-auth-permissions`): only an admin can grant or remove the `admin` role and a store keeps at least one admin; invitations must name a role; invitation acceptance links come from a separate write-gated endpoint (never from listings) and resending rotates the token; staff password-reset links only point at the dashboard origin; login, current-password confirmation and invitation acceptance share one lockout (`Spree::Authentication::Lockout`) — route any password check you add through it too.
- Give every staff member their own account and a least-privilege role. Don't share an `admin@` login.

### Mission Control (`/jobs`)

The jobs UI is protected by HTTP Basic auth. In production set `MISSION_CONTROL_USER` and `MISSION_CONTROL_PASSWORD`; without them the dashboard stays locked. The starter's local defaults (`spree` / `spree123`) apply only in development and test. Never copy them into production env files.

## Store API: IDOR and cross-store leaks

- Carts and orders are readable by their owner (JWT) **or** by whoever holds the guest token (`X-Spree-Token`). Anyone holding the token can read that cart or order, so never log tokens or put them in URLs you share.
- Prefixed IDs are **not secret** (they're encodings of sequential keys). Authorize every lookup; never rely on the ID being hard to guess.
- In custom Store controllers, read through `storefront_access_policy.scope(Model.for_store(current_store))` or through `current_user.<association>`. Never use `Model.find(params[:id])`.
- In custom Admin controllers, use the inherited `scope` (store-scoped) and declare `scoped_resource`. Multi-store apps share one database, so `Spree::Order.find` in a controller is a cross-store leak.
- **Every ID in a write body is a lookup too.** Resolve referenced IDs (`stock_location_id`, `reason_id`, a custom field's parent, translation targets, price-list variants, promotion rule products) through `current_store` (and the seller, on seller surfaces), and take parent records from the route, never from a query/body param. Core does this for its own endpoints; a custom controller that assigns a raw `*_id` from params reopens the cross-store hole.
- In development and test, `Spree::StoreScopeGuard` flags `SELECT`s on store-owned tables (any `spree_*` table with `store_id`) that are neither store-scoped nor id-filtered. It watches every API v3 request **and any unit of work that assigns `Spree::Current.store`** — jobs, webhook controllers, console scripts, specs — until `Spree::Current` resets. Mode: `SPREE_STORE_SCOPE_GUARD` / `Spree::Config[:store_scope_guard]` = `log` (default), `raise` (Spree's own API suite), `off`; never active in production. Wrap a deliberately global lookup in `Spree::StoreScopeGuard.skip { … }`. Take its warnings seriously.

## Mass assignment

API v3 controllers build their allowlist from `resource_permitted_attributes` (custom controllers) plus each model's `additional_permitted_attributes`. There is no `Spree::PermittedAttributes` module. Don't override `permitted_params` — that drops what extensions add.

```ruby
# Make an extension column writable on the existing endpoints (never `<<`, the array is frozen):
Spree::Product.additional_permitted_attributes += [:brand_id]
Spree::Address.additional_permitted_attributes += [{ tag_ids: [] }]

# Custom controllers list their own:
def resource_permitted_attributes = %i[name rating body]
```

Never use `params.permit!`. Never permit ownership or privilege columns (`customer_id`, `store_id`, `role_ids`, `status`) on customer-facing endpoints. Set those server-side.

## Injection and XSS

- **SQL:** use parameterized `where('x > ?', v)` or hash conditions, never string interpolation. Ransack is safe because it only filters on allowlisted attributes. Unknown `q[...]` predicates are silently dropped. Expose new filters with `Spree.ransack.add_attribute(Model, :attr)`, and never allowlist secrets or digests. Filters are a yes/no oracle, so the Store and Seller APIs get narrower allowlists than staff (`storefront_ransackable_associations`, `private_ransackable_attributes`/`private_ransackable_scopes` keyed `:store`/`:seller`); keep private data out of the storefront list when you widen it. Controllers inheriting the Store/Seller `ResourceController` pass it for you (`ransack_auth_object`); a hand-rolled query in a customer-facing controller should call `ransack(params, auth_object: :store)` itself.
- **Rich text:** product, category, collection and seller descriptions are sanitized **on save** by `Spree::RichTextSanitizer` (via `has_spree_rich_text` / `sanitizes_rich_text`). The allowlist covers what the dashboard's Tiptap editor emits: `p br hr h1–h6 strong em s u code pre blockquote ul ol li a img`, and `data:`/`javascript:` URLs are stripped. The API returns `description` as plain text and `description_html` as sanitized markup.
  - To widen the allowlist deliberately: `Spree::RichTextSanitizer.allowed_tags += %w[table thead tbody tr th td]` in an initializer.
  - Writes that skip callbacks (`update_columns`, `update_all`, raw SQL, bulk imports that bypass models) are **not** sanitized. Call `Spree::RichTextSanitizer.sanitize(html)` yourself.
  - New rich-text columns on your models: `include Spree::SanitizableRichText` + `has_spree_rich_text :body`. Translated attributes need `sanitizes_rich_text` on the `Translation` class too.
- **Storefront:** render `*_html` with your framework's raw-HTML escape hatch (for example, React's `dangerouslySetInnerHTML`) only for these server-sanitized fields. Escape everything else.
- **CSV exports:** neutralize cells starting with `=`, `+`, `-` or `@` before writing files that staff open in spreadsheets.

## CORS and CSP

```ruby
# config/initializers/cors.rb: storefront on another origin (the admin block comes from the starter)
allow do
  origins 'https://shop.example.com'
  resource '/api/v3/store/*', headers: :any, methods: %i[get post patch put delete options]
end
```

- Never use `origins '*'` together with `credentials: true`. The admin, and a cross-origin seller panel, must use the Allowed Origins table.
- Set CSP on the app that renders HTML. For a Next.js storefront that means the Next app, not Rails. The Rails side mainly serves JSON plus the dashboard.

## Webhooks

**Outbound** (Spree → your receiver). Each delivery carries `X-Spree-Webhook-Signature` = hex HMAC-SHA256 of `"#{timestamp}.#{raw_body}"` using the endpoint's secret, plus `X-Spree-Webhook-Timestamp` and `X-Spree-Webhook-Event`. **Receivers must:**

1. Verify against the **raw** body bytes, before JSON parsing.
2. Compare with a constant-time function (`ActiveSupport::SecurityUtils.secure_compare`, `crypto.timingSafeEqual`).
3. Reject timestamps older than about 5 minutes (replay).
4. Be idempotent. Non-2xx responses, timeouts and connection errors are retried with backoff by `Spree::WebhookDeliveryJob` (5 attempts in total, same event `id`), and a manual redelivery sends the same event again.

`@spree/sdk/webhooks` exports `verifyWebhookSignature(rawBody, signature, timestamp, secret, tolerance = 300)`. See `spree-events-webhooks`.

**SSRF.** Outside development, deliveries go through `SsrfFilter`, which blocks private, loopback and link-local targets. Development bypasses it so `localhost` receivers work. Don't copy `Rails.env.development?` branches into other code paths. `webhooks_verify_ssl` defaults to on outside development; leave it on. Creating webhook endpoints requires `write_webhooks`, which is deliberately separate from `settings`.

**What `write_webhooks`/`read_webhooks` does not grant.** `customer.password_reset_requested` carries a live reset token: it reaches only endpoints that name it (never `*` or `customer.*`), and subscribing to it — or repointing an endpoint that receives it — also needs `write_customers`. The delivery log stores credentials (cart `token`, reset/verification tokens, download URLs, payment-session secrets, gift card `code`) as `[REDACTED]`, and the Admin API returns a delivery's `payload` only to callers who can read the underlying record (`null` otherwise).

**Inbound** (gateway → Spree, e.g. `/api/v3/webhooks/payments/...`): the record is found by its prefixed ID alone (the request can't name a store), the request runs in that payment method's/integration's store, and the provider verifies the signature against that record's own secret — returning 401 when it's invalid. The signature is the only authentication. If you write a custom provider, verify the signature before acting (see `spree-providers`, `spree-payments`).

## Data privacy (GDPR)

- **Subject requests** are `Spree::DataRequest` records. Customers create them with `POST /api/v3/store/customers/me/data_requests { kind: "access" | "erasure" }` (erasure requires `current_password`). Staff use `GET /api/v3/admin/customers/:id/export` and `POST /api/v3/admin/customers/:id/anonymize`. Exports are built in the background and emailed as expiring signed links.
- **Erasure means anonymization**, done by the `Spree::Customers::Anonymize` workflow. It scrubs the account, address book, order address snapshots, saved cards, identities and sessions, and strips the email, IP and user agent from consent rows (the rows themselves are kept — see Consent below). It keeps financial records (orders, payments, tax lines, line items, plus country, state and a truncated postcode for tax jurisdiction), and publishes `customer.anonymized`.
- **If you add a table holding personal data, extend anonymization in the same change.** Core has a schema-guard spec that fails when a personal-data column isn't covered.
- Hooks:
  ```ruby
  Rails.application.config.after_initialize do
    Spree.hooks.register('customers.anonymize.validate', 'MyApp::LegalHold')            # workflow.reject!('Under legal hold')
    Spree.hooks.register('data_requests.fulfill.extend_payload', 'MyApp::LoyaltyExport') # return a Hash to merge
  end
  ```
- **Consent:** `Spree::ConsentRecord` records acceptance events (purpose, source, time, document digest). The customer also has `email_marketing_consent_updated_at` / `_source`. Consent rows survive erasure (purpose, source and timestamp stay as proof) with email, IP and user agent cleared, and erasure appends an `email_marketing` withdrawal row (source `anonymization`) if the customer had opted in. Cookie consent is the storefront's responsibility.
- Staff access to `DataRequest` and `ConsentRecord` rides `read_customers` / `write_customers`.

## PCI scope

Spree never stores or transmits PANs. Card data goes browser → gateway through the gateway's hosted fields (Stripe Elements / Payment Element via `spree_stripe`, Adyen Drop-in, PayPal). Spree only receives tokens and payment sessions. `Spree::CreditCard` holds brand, last4, expiry and a gateway reference, never the full number or CVC.

- **Never add card-data columns** or proxy raw card fields through your API. If you think you need to, use gateway tokenization instead.
- With hosted fields only, you're usually at SAQ A. Collecting card data yourself puts you at SAQ D.
- Param filtering already covers `number`, `verification_value` and the like. Extend `Rails.application.config.filter_parameters` for any custom sensitive param names.

## Rate limiting

The API throttles built in: per publishable key + IP (300/min), per secret key (600/min), and per-IP limits on login, registration, refresh and password reset. Counters live in `Rails.cache`, so multi-process deployments need a shared store (Solid Cache or Redis). Put a CDN or WAF in front for volumetric abuse. See `spree-api-v3` for the table.

## Dependency hygiene

Run `bundle audit`, `brakeman`, and `pnpm audit` for the storefront and dashboard in CI. The plugin doesn't ship a CI workflow.

## Deployment checklist

- [ ] Secrets in credentials/env. No secrets in `VITE_*`, in the repo, or in seeds.
- [ ] `secret_key_base` stable; `SPREE_JWT_SECRET_KEY` set; the three `ACTIVE_RECORD_ENCRYPTION_*` keys set (production-only set, backed up) and read into `config.active_record.encryption`.
- [ ] `config.force_ssl = true`; HTTPS on API, dashboard and storefront.
- [ ] Allowed Origins lists only real dashboard/seller-panel origins. Storefront CORS lists explicit origins.
- [ ] `MISSION_CONTROL_USER` / `MISSION_CONTROL_PASSWORD` set.
- [ ] Integrations use minimum-scope secret keys, each named after its purpose. `write_all` reserved for break-glass use.
- [ ] Staff have individual accounts and least-privilege roles. SSO enforced if the org has an IdP.
- [ ] Webhook receivers verify HMAC, check the timestamp, and are idempotent.
- [ ] Custom controllers are store-scoped (Admin) or ownership-scoped (Store).
- [ ] Anonymization covers any personal-data tables you added.
- [ ] Shared cache store for rate limits. CDN/WAF in front.
- [ ] Database backups encrypted and stored away from the DB.

## Where to read further

- PCI: `node_modules/@spree/docs/dist/developer/security/pci_compliance.md`
- Data privacy: `node_modules/@spree/docs/dist/developer/core-concepts/data-privacy.md`
- Dashboard deployment and auth: `node_modules/@spree/docs/dist/developer/dashboard/deployment.md`
- Admin API auth: `node_modules/@spree/docs/dist/api-reference/admin-api/authentication.md`
- Background jobs / Mission Control: `node_modules/@spree/docs/dist/developer/deployment/background_jobs.md`
- Rails Security Guide: https://guides.rubyonrails.org/security.html
- Related skills: `spree-auth-permissions`, `spree-api-v3`, `spree-events-webhooks`, `spree-payments`, `spree-deployment`.

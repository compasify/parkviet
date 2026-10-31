---
name: spree-performance
description: Use when investigating or improving Spree 6 performance — slow cart writes, slow checkout, slow Store API product listings, N+1 queries in custom endpoints or serializers, search latency, Meilisearch indexing floods, image processing backlogs, Solid Queue/Sidekiq queue tuning, HTTP/CDN caching of the Store API, dashboard data-fetching, or tracing with OpenTelemetry. Common phrasings include "slow cart", "add to cart is slow", "tax provider called too often", "N+1 in Spree", "slow product listing", "search slow", "Meilisearch reindex", "import is starving jobs", "jobs backlog", "queue tuning", "Spree cache", "CDN caching API", "trace a checkout", "find the slow workflow step".
---

# Spree Performance

Spree 6 is API-first: the hot paths are **Store API requests** (catalog reads, cart writes, checkout) and **background jobs**. Most wins come from a handful of known hotspots, not generic Rails tuning.

## Measure first

1. **Trace it.** Add `gem 'spree_opentelemetry'` and point `OTEL_EXPORTER_OTLP_ENDPOINT` at a collector (Jaeger locally: `docker run --rm -p 16686:16686 -p 4318:4318 jaegertracing/jaeger:latest`). Every `Spree::Workflow` run, **each step**, hook dispatch, event subscriber dispatch, webhook delivery and gateway call gets its own span alongside SQL and HTTP spans — e.g. `carts.add_item`, `carts.complete process_payments`. This tells you *which step* is slow without guessing. Custom workflows are traced automatically.
2. **Count queries** in a console or request spec: `ActiveRecord::Base.logger = Logger.new($stdout)` and run the workflow directly.
3. **Production APM** (Skylight, Scout, New Relic, Datadog) all work; Datadog/Honeycomb/New Relic can also ingest the OTel traces.

## Cart writes: the recalculation pipeline

Cart mutations (`Spree::Carts::AddItem`, `UpsertItems`, line item updates/removals and other cart edits) run `Spree.cart_recalculate_workflow` (`Spree::Carts::Recalculate`), which:

1. refreshes totals via `Spree.cart_recalculate_totals_workflow` (`Spree::Carts::RecalculateTotals`),
2. rebuilds delivery proposals (`cart.ensure_updated_fulfillments` — delivery rate providers run here),
3. activates promotions (`set_promotion_context` hook, then `Spree::PromotionHandler::Cart`),
4. runs `RecalculateTotals` **again** to rebuild discounts and tax,
5. runs `after_recalculate` hook handlers.

`RecalculateTotals` regenerates typed rows (`Spree::Discount`, `Spree::Fee`, `Spree::TaxLine`) and calls `cart.tax_provider.estimate(...)` each time it runs on an unplaced cart. Consequences:

- **An external tax provider is called at least twice per cart write.** Cache estimates inside your provider (key on line items, quantities, amounts, ship-to address, exemptions) and keep timeouts tight. Placed orders are money-frozen and skip regeneration.
- **External delivery rate providers** run on every proposal rebuild — cache quotes per (address, package contents).
- **Hook handlers** (`carts.recalculate.after_recalculate`, `carts.recalculate.set_promotion_context`, `carts.recalculate_totals.set_tax_line_context`) run on every write. Keep them query-light; push anything non-essential to an event subscriber (`cart.updated`) which runs async.
- **Never** do network I/O inside a DB transaction. In your own workflows use `external_step` for gateway/network calls — it raises if run inside a workflow transaction and marks the span as a client call.
- Don't add `after_save` callbacks on `Spree::LineItem`/`Spree::Cart` that recalculate — the workflow already does, and callbacks multiply the work.

## Catalog reads: N+1s

The Store API's `ResourceController#collection` already chains `.includes(collection_includes).preload_associations_lazily` (ar_lazy_preload) and paginates with Pagy (default `limit` 25, max 100). The products controller explicitly includes what lazy preloading can't pick up:

```ruby
# Spree::Api::V3::Store::ProductsController#scope_includes (abridged)
[:seller, {
  primary_media: [attachment_attachment: :blob, poster_attachment: :blob],
  default_variant: [:prices, stock_levels: [:stock_location, :active_stock_reservations]],
  variants: [:prices, :seller, stock_levels: [:stock_location, :active_stock_reservations]]
}]
```

When building custom endpoints or serializers, copy that shape:

- There is no master variant. Listings read `product.default_variant` — preload it with `:prices`.
- `variant.price_in(currency)` uses the loaded `prices` association when present and falls back to **one query per variant** otherwise. Always preload `prices` before iterating.
- `Spree::Media` has a default scope that includes `attachment` and `poster` blobs; preload `primary_media` for listings.
- Add fields to a serializer → check the new associations are preloaded. In your controller, override `scope_includes` / `collection_includes` rather than calling `.includes` inline.
- Clients should use `expand=` only for what the screen needs and `fields=` for sparse payloads — every expansion is extra loading and serialization.

```ruby
products = current_store.products.active
  .includes(primary_media: [], default_variant: [:prices])
  .preload_associations_lazily
```

## HTTP caching on the Store API

Store catalog controllers (products, categories, collections, markets, currencies, locales, policies, sellers) include `Spree::Api::V3::HttpCaching`:

- **Guests** get `Cache-Control: public` (5 min, `stale-while-revalidate` on lists) plus an ETag; responses `Vary` on `Accept, x-spree-currency, x-spree-locale, x-spree-channel`. List ETags fold in max `updated_at`, count, `expand`, `fields`, `q`, page, limit, currency, locale and channel.
- **Authenticated** customers get `private, no-store`.

So a CDN in front of the API can cache guest catalog traffic — configure it to respect `Vary`/these headers, and keep the storefront sending the `x-spree-*` headers rather than query-string variants. For your own Store API controllers, call `cache_collection(collection)` / `cache_resource(resource)` in index/show actions (both return `false` after sending a 304). Cart, checkout and account endpoints must stay uncached.

`Rails.cache` is Solid Cache by default (DB-backed). It's fine for memoized lookups; switch to Redis/Valkey (`redis_cache_store`) if cache traffic becomes significant. Never cache per-customer data under shared keys.

## Search

- **Database provider** (`Spree::SearchProvider::Database`, default): text search is a leading-wildcard `LIKE` over product names/SKUs (plus custom fields whose definitions are marked searchable), then Ransack filters. Fine for small catalogs; degrades past roughly 10K products. `pg_trgm` is enabled by a core migration on PostgreSQL — if you add a trigram index, `EXPLAIN` the generated SQL first so the index matches the actual expression.
- **Meilisearch** (`spree_meilisearch` gem, `Spree.search_provider = 'SpreeMeilisearch::SearchProvider'`): the right choice for medium/large catalogs and faceting.
  - Every product create/update commit enqueues `Spree::SearchProvider::IndexJob` (queue `Spree.queues.search`, retries with backoff) per store. Bulk imports generate a flood — route `search` to its own low-priority queue, or reindex once after the import: `bin/rails spree:search:reindex` (`spree task search:reindex`).
  - Reindex after changing index settings/presenter fields.

## Images

`Spree::Media` defines named webp variants from `Spree::Config.product_image_variant_sizes` (default `mini`, `small`, `medium`, `large`, `xlarge` 2000×2000, `og_image` 1200×630) with `preprocessed: true` — Active Storage enqueues transforms at upload time, so each upload costs one transform per size (for video, also per poster). Rich-text `:embed` variants are generated on first use.

- Trim sizes you don't use in an initializer (must be set before models load) — fewer sizes = less CPU per upload.
- Route transforms away from checkout-critical work (`config.active_storage.queues.transform`), and put a CDN in front of `/rails/active_storage/representations/` (see `spree-deployment`, `CDN_HOST`).
- Don't pre-warm variants from a subscriber — the named variants already are, and ad-hoc variants have different digests.

## Background jobs

Spree jobs choose their queue from `Spree.queues` (defaults are all `:default`). Keys: `default`, `events`, `exports`, `images`, `imports`, `products`, `variants`, `categories`, `collections`, `stock_location_stock_levels`, `coupon_codes`, `themes`, `addresses`, `gift_cards`, `webhooks`, `payment_webhooks`, `api_keys`, `search`, `stock_reservations`, `tax_identifiers`, `data_requests`, `payouts`. Verify against `Spree.queues` in the installed `spree_core` (`lib/spree/core.rb`).

```ruby
# server/config/initializers/spree.rb
Spree.queues.payment_webhooks   = :spree_payment_webhooks
Spree.queues.events             = :spree_events
Spree.queues.webhooks           = :spree_webhooks
Spree.queues.stock_reservations = :spree_stock_reservations
Spree.queues.imports            = :spree_imports
Spree.queues.images             = :spree_images
Spree.queues.search             = :spree_search
Spree.queues.categories         = :spree_categories
Spree.queues.collections        = :spree_collections
Spree.queues.payouts            = :spree_payouts
```

Use the current key names — `Spree.queues.taxons=` and `stock_location_stock_items=` are deprecated, and assigning a key Spree doesn't read (e.g. `reports`) is silently ignored.

### Solid Queue tuning

- `config/queue.yml` polls queues **in listed order** — put checkout/payment/stock-reservation work first, bulk catalog/import/image work later, keep the trailing `"*"`.
- In combined mode, job threads share the Puma process and GVL with web requests: raising `JOB_THREADS` there trades API latency for throughput. Once jobs matter, split to a `bin/jobs` worker (`SOLID_QUEUE_IN_PUMA=false` on web) and scale with `JOB_THREADS`/`JOB_CONCURRENCY`/replicas.
- For isolation, define several workers in `queue.yml` — e.g. one pool for `[spree_payment_webhooks, spree_events, spree_webhooks, mailers, default]` and another for `[spree_imports, spree_images, active_storage_transform, spree_search]`.
- CSV imports cap themselves via `SPREE_IMPORT_JOB_CONCURRENCY` (default 75% of `JOB_THREADS`) so a large import can't occupy every thread.
- DB pool must be ≥ `RAILS_MAX_THREADS + JOB_THREADS` (+ headroom).
- Watch backlog in Mission Control at `/jobs`.
- **Sidekiq** is an option for very high volume — list every queue in `sidekiq.yml` with weights (no catch-all). See `spree-deployment`.

### Event subscribers

Subscribers are async by default (`Spree::Events::SubscriberJob` on `Spree.queues.events`). Use `subscribes_to 'order.placed', async: false` only for work that must happen in-request and is cheap. Heavy or network-bound side effects belong in async subscribers.

## Dashboard (React admin)

The dashboard uses TanStack Query (default `staleTime` 60s, `retry: 1`, no refetch on focus). In plugins:

- Fetch through `adminClient` and pass `expand: [...]` only for data the view renders; use list `limit` and Ransack filters instead of loading everything.
- Reuse query keys so cached data is shared across components; set a longer `staleTime` for slow-changing reference data.
- A slow dashboard page is almost always a slow Admin API endpoint — trace it server-side.

## Common mistakes

- Iterating variants and calling `price_in` without preloading `prices`.
- Calling an external tax/rate API without caching — it runs several times per cart write.
- Doing HTTP calls inside a transaction or a synchronous hook handler.
- Leaving all `Spree.queues` on `:default` in a busy store — imports and image transforms delay payment webhooks and stock reservation expiry.
- Serving guest catalog traffic without a CDN honoring `Vary`, or stripping the `x-spree-*` headers at the CDN.
- Using `Spree::Product.all` in custom endpoints — scope through `current_store` and paginate.

## Where to read further

- `node_modules/@spree/docs/dist/developer/providers/observability.md` — spans, sampling, span metrics
- `node_modules/@spree/docs/dist/developer/deployment/background_jobs.md`, `caching.md`, `cdn.md`
- `node_modules/@spree/docs/dist/developer/core-concepts/search-filtering.md`
- Source: `Spree::Carts::Recalculate` / `RecalculateTotals` (`spree_core/app/workflows/spree/carts/`), `Spree::Api::V3::HttpCaching`, `Spree::Api::V3::ResourceController`
- Related skills: `spree-workflows`, `spree-order-totals`, `spree-taxes`, `spree-deployment`, `spree-events-webhooks`

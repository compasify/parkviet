---
name: spree-pricing
description: Use when the user is working with Spree 6 pricing — variant prices per currency (price_in, amount_in, set_price), compare-at/sale prices, multi-currency, price lists and price rules (market, channel, volume), catalog-owned price lists for B2B/wholesale, percentage price adjustments, quantity breaks / volume pricing, scheduled sales, the pricing context and resolution order, external pricing providers, bulk price updates, and EU Omnibus price history (prior_price). Common phrasings include "set price", "variant.price", "compare at price", "sale price", "price list", "wholesale pricing", "customer-specific price", "volume discount", "tiered pricing", "quantity break", "schedule a sale", "multi-currency", "wrong price shown", "prior price", "Omnibus", "lowest price in 30 days", "bulk update prices".
---

# Spree Pricing

A price in Spree 6 is always **an amount plus a currency** on a variant — there is no implicit "the" price. On top of the base prices sit **price lists** (conditional overrides), resolved per request from a **pricing context**.

```
Variant ── Price (price_) × n
             ├── base prices:  price_list_id = nil, one per currency  (what everyone pays by default)
             └── list prices:  price_list_id = pl_…, per currency, optional min_quantity (quantity breaks)
PriceList (pl_) ── PriceRule × n (STI: MarketRule, ChannelRule, VolumeRule, …)
            └── optionally owned by one Catalog (cat_) → audience = the catalog's assignments
Price ── PriceHistory × n   (base-price changes, for EU Omnibus)
```

Tax-inclusive vs exclusive display and VAT restatement live in `spree-taxes`.

## Base prices: `price_in` / `amount_in` / `set_price`

```ruby
variant.set_price('USD', 39.99)            # upsert the USD base price (saves immediately if the variant is persisted)
variant.set_price('USD', 39.99, 49.99)     # 3rd arg = compare_at_amount; omitting it CLEARS compare-at
variant.set_price('EUR', nil)              # blank amount deletes that currency's base price

variant.price_in('USD')                    # => Spree::Price (unsaved blank Price if none — check .persisted? / .amount)
variant.amount_in('USD')                   # => BigDecimal or nil
variant.compare_at_amount_in('USD')
variant.price_in('USD').display_amount     # "$39.99"

product.price_in('USD')                    # delegates to product.default_variant
variant.prices.base_prices.exists?(currency: 'EUR')
```

- `variant.price`, `price=`, `default_price`, `display_price`, `currency` **don't exist** — pass the currency you mean.
- `price_in` is the **base** price only. For what a shopper actually pays (price lists applied), use `variant.price_for(...)` (below).
- There is no FX conversion: each currency the store sells in needs its own price. A product without a base price in the request currency is hidden from Store API listings.
- `Spree::Price#amount=` parses localized numbers (`'1,599.99'` works).
- Nested writes: `variant.prices = [{ currency:, amount:, compare_at_amount: }]` upserts listed currencies and **removes base prices for currencies not listed** (`[]` clears all). `product.prices = [...]` forwards to the default variant.

### Via the API

```typescript
await admin.prices.create({ variant_id: 'variant_xxx', currency: 'USD', amount: '15.99' })

// Upsert many (matches on variant + currency + price_list_id + min_quantity)
await admin.prices.bulkUpsert({
  prices: [
    { variant_id: 'variant_xxx', currency: 'USD', amount: '15.99', compare_at_amount: '19.99' },
    { variant_id: 'variant_xxx', currency: 'EUR', amount: '14.99' },
  ],
})
await admin.prices.bulkDestroy({ ids: ['price_xxx'] })
```

```bash
spree api post /prices/bulk_upsert -d '{"prices":[{"variant_id":"variant_xxx","currency":"USD","amount":"15.99"}]}'
```

`/api/v3/admin/prices` covers base prices **and** list overrides (`price_list_id: 'pl_…'`). Store API responses carry the already-resolved `price` / `original_price` for the request's currency, market and customer.

## Price lists

| Attribute | Notes |
|---|---|
| `status` | `draft` (default), `active`, `scheduled`, `inactive` — transitions via workflows (`Spree.price_list_activate_workflow` / `price_list_deactivate_workflow`; API `PATCH /price_lists/:id/activate`). Activating a list with a future `starts_at` marks it `scheduled`. |
| `starts_at` / `ends_at` | Time window (store time zone). Scheduled lists apply automatically inside it — this is how you run a Black Friday sale. |
| `match_policy` | `all` / `any` over its rules. |
| `position` | Priority among standalone lists — lower first; first list that prices the variant wins. |
| `price_adjustment_percentage` + `price_adjustment_tiers` | Catalog-owned lists only: derive prices as base × (1 + pct/100), optionally banded by quantity. Explicit price rows on the list still win. |

```typescript
const pl = await admin.priceLists.create({
  name: 'EU Black Friday',
  starts_at: '2026-11-27T00:00:00Z',
  ends_at: '2026-11-30T23:59:00Z',
  match_policy: 'all',
  rules: [{ type: 'market_rule', preferences: { market_ids: ['mkt_eu'] } }],
  prices: [{ variant_id: 'variant_xxx', currency: 'EUR', amount: '19.99' }],
})
await admin.priceLists.activate(pl.id)   // lists are born draft
```

`GET /api/v3/admin/price_lists/price_rule_types` lists registered rule types and their preference schemas. Product membership (placeholder rows per variant × currency) goes through `admin.priceLists.products`.

### Price rules — *where / through what / how much*

| Type (`api_type`) | Class | Matches |
|---|---|---|
| `market_rule` | `Spree::PriceRules::MarketRule` | Context market in `market_ids` (the geography rule — no zone rule) |
| `channel_rule` | `Spree::PriceRules::ChannelRule` | Context channel in `channel_ids` (empty = any) |
| `volume_rule` | `Spree::PriceRules::VolumeRule` | `min_quantity` ≤ line quantity ≤ `max_quantity` (nullable) — *contextual* |
| `user_rule`, `customer_group_rule` | `UserRule`, `CustomerGroupRule` | Grandfathered (`superseded?` = true): existing rules keep matching, but pickers no longer offer them |

**Who** gets a price is not a rule — it's a **catalog**: attach the price list to a `Spree::Catalog` assigned to customer groups or companies (a channel names its default catalog via `default_catalog_id`). See `spree-b2b`.

Custom rule: subclass `Spree::PriceRule`, add `preference`s, implement `applicable?(context)`, register in `config/initializers/spree.rb` with `Rails.application.config.after_initialize { Spree.pricing.rules << MyApp::PriceRules::LoyaltyTierRule }`. Override `self.contextual?` → true if it asks about the purchase (quantity-like) rather than the buyer, so it still applies on catalog-owned lists.

## How a price resolves

`variant.price_for(context_or_hash)` → `Spree::Pricing::PriceResolution` → the store's pricing provider (default `Spree::PricingProvider::Internal`):

1. **Catalog-owned lists, nearest node first** — the buyer's company node, then its ancestors; else their customer groups' catalogs; else the channel's default catalog. Within one node, **the cheapest price wins** (for the quantity being bought). Owned lists skip their audience rules but still check *contextual* rules (e.g. `VolumeRule`), status and dates.
2. **Standalone lists** whose rules match, in `position` order — first that prices the variant wins.
3. **Base price** (`price_list_id: nil`).

```ruby
ctx = Spree::Pricing::Context.new(
  variant: variant, currency: 'EUR',
  market: market, channel: channel, user: customer, company: company, quantity: 24
)  # store/market/channel/country default from Spree::Current; date defaults to now
variant.price_for(ctx)                                   # => Spree::Price or nil
variant.price_for(currency: 'EUR', user: customer, quantity: 24)   # hash form
Spree::Pricing::Context.from_order(variant, cart)        # uses the cart's own market/channel/customer
```

The Store API builds this context from `X-Spree-Currency` / `X-Spree-Country`, the channel of the API key, and the authenticated customer — no manual work. There's no in-process price cache. Only guest responses are publicly cacheable (`Vary: Accept, x-spree-currency, x-spree-locale, x-spree-channel`); authenticated ones are `private, no-store`. Country isn't in `Vary` but picks the market — add it to your CDN/app cache key (see `spree-i18n`).

**External pricing (ERP, contract pricing):** configure a pricing provider (`Spree::PricingProvider::Base#price_for(context)`, `handles?`, `cache_ttl`) — it runs on the catalog read path, so declare a `cache_ttl` and decline anonymous contexts in `handles?`. See `spree-providers`.

## Volume pricing and quantity breaks

Two ways, pick by shape:

- **Quantity breaks on one list** — price rows with `min_quantity > 1` (requires a `price_list_id`). The row with the highest `min_quantity` ≤ line quantity is charged. A variant with a ladder on a list is priced by the ladder alone.
  ```typescript
  await admin.prices.bulkUpsert({ prices: [
    { variant_id: 'variant_xxx', currency: 'USD', price_list_id: 'pl_trade', amount: '10.00' },
    { variant_id: 'variant_xxx', currency: 'USD', price_list_id: 'pl_trade', min_quantity: 24, amount: '8.50' },
  ]})
  ```
- **One list per tier** with a `volume_rule` (`min_quantity`/`max_quantity`) — when whole assortments or other rules differ per tier. Don't let tiers overlap.

A context without `quantity` (listings, exports) is priced at the bottom rung.

## EU Omnibus: price history and `prior_price`

Every change to a **base** price amount writes a `Spree::PriceHistory` row (price-list prices aren't tracked). `price.prior_price` returns the lowest amount recorded in the last 30 days (it includes the just-set amount).

- Per-store preferences: `preferred_track_price_history` (default `true`), `preferred_price_history_retention_days` (default 30). The global `Spree::Config[:track_price_history]` is deprecated — set it on the store:
  ```typescript
  await admin.store.update({ preferred_track_price_history: false })   // non-EU store
  ```
- Store API: `?expand=prior_price` on products/variants → `{ amount, currency, display_amount, recorded_at }`.
- Rake: `spree rake spree:price_history:seed` (one-time baseline, skips prices that already have history), `spree rake spree:price_history:prune` (schedule it — e.g. a Solid Queue recurring task).

## Bulk updates

`update_all` skips callbacks → no price history, no collection re-matching. Prefer the Admin API `bulk_upsert`, or iterate:

```ruby
Spree::Price.base_prices.where(currency: 'USD').where.not(amount: nil).find_in_batches(batch_size: 500) do |batch|
  Spree::Price.transaction { batch.each { |p| p.update!(amount: (p.amount * 1.1).round(2)) } }
end
```

## "Customer sees the wrong price"

1. **Currency** — what's `Spree::Current.currency` / the cart's currency? Does the variant have a base price in it?
2. **Which list won?** `variant.price_for(currency:, user:, quantity:)&.price_list` — then check catalogs for that buyer (company node before customer group before channel default) and standalone lists by `position`. `Spree::Current.price_lists` shows the standalone candidates for the request.
3. **Status / window** — draft lists never apply; scheduled lists only inside `starts_at..ends_at`; a deactivated catalog's owned list goes dormant.
4. **Quantity** — volume rules and breaks only apply when the context has a quantity (cart lines do, listings don't).
5. **Cart vs PDP** — line items keep the price they were priced at; the cart re-prices on changes that matter (items, address/market) through `Spree::Carts::Recalculate`. Placed orders are money-frozen.
6. **Tax display** — gross vs net is a market/tax concern (`spree-taxes`).

## Gotchas

- `set_price(currency, amount)` without the third argument wipes `compare_at_amount`.
- `price_in` returns an unsaved blank `Spree::Price` rather than nil — test `.amount` or `.persisted?`.
- **Read-modify-write trap:** `?expand=variants.prices` returns *every* price row — base, price-list and quantity-break rows, each with `price_list_id` (`null` = base). Writing `prices` back on a variant/product treats every entry as a **base** price (and drops currencies you leave out), so posting the expanded array back overwrites the shop price with a list or ladder amount, and a null-amount membership placeholder deletes a currency. Filter to `price_list_id === null` before sending; write list prices through `/api/v3/admin/prices`. (The dashboard's product form does this filtering; your own clients must too.)
- `min_quantity > 1` without a `price_list_id` is invalid; percentage adjustments are only allowed on catalog-owned lists.
- Removing a catalog's pricing (`price_list: null`) or deleting the catalog soft-deletes the owned list — it never "releases" to match everyone.
- The Store API product filter **price range** (`products.filters` → `price_range`) is computed from **base prices only** — never price-list rows (a company's contract price, a draft or scheduled list) — and is left out entirely when the channel hides prices from the caller. Don't expect it to reflect a B2B buyer's list prices.
- Price-list writes (`Spree::PriceLists::Update`, including a catalog's inline list) silently drop variants from other stores.
- Use promotions (`spree-promotions`) for checkout-time discounts and coupon codes; use price lists when the reduced price must show on the product page.

## Where to read further

- `node_modules/@spree/docs/dist/developer/core-concepts/pricing.md`
- `node_modules/@spree/docs/dist/developer/core-concepts/catalogs.md`
- `node_modules/@spree/docs/dist/user/how-to/volume-pricing.md`, `.../schedule-sale-pricing.md`, `.../wholesale-pricing.md`
- Source: `Spree::Price`, `Spree::PriceList`, `Spree::PriceRule`, `Spree::Pricing::Context`, `Spree::PricingProvider::Internal` in `spree_core`
- Related skills: `spree-catalog`, `spree-b2b`, `spree-taxes`, `spree-providers`, `spree-promotions`

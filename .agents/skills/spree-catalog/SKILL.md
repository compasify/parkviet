---
name: spree-catalog
description: Use when the user is working with the Spree 6 product catalog — products, variants, option types/values, the default variant, product types (templates), categories vs collections, custom fields, media (images, video, media library), channel publications, search providers (database, spree_meilisearch, custom), digital assets, or catalog imports/exports. Common phrasings include "create a product", "add variants", "size and color options", "product type", "category tree", "collection", "brand", "custom field on products", "product images", "product video", "primary_media", "product not showing in store", "publish product on channel", "Meilisearch", "reindex", "custom search provider", "digital download", "master variant". Covers the catalog graph and how to read/write it from Ruby, the Admin SDK and `spree api`.
---

# Spree Catalog

The catalog is everything for sale: **products** (the listing), **variants** (the thing actually bought — SKU, prices, stock), **option types/values** (what distinguishes variants), **categories** and **collections** (how products are grouped), **custom fields**, **media**, and the **search provider** that makes it findable.

> Coming from Spree 5.x (master variant, taxons, metafields, `presentation`)? See the `spree-upgrade-5-to-6` skill for the rename map. This skill describes how Spree 6 works.

## The catalog graph

```
Store ─┬─ Product  (prod_, belongs_to :store — single owner; status draft/active/archived)
       │    ├── default_variant  (real FK default_variant_id — no master variant)
       │    ├── Variant × n  (variant_) — sku, barcode, weight…, Price per currency, StockLevel per location
       │    │     └── OptionValue × n (optval_)  via option_value_variants
       │    ├── ProductOptionType → OptionType (opt_) — name, label, kind (dropdown|color_swatch|buttons)
       │    ├── ProductCategory → Category (ctg_) — nested tree, permalink "clothing/shirts"
       │    ├── ProductCollection → Collection (coll_) — flat; manual or automatic (rules)
       │    ├── ProductPublication → Channel — visibility per channel, optional time window
       │    ├── Media (media_) — product gallery; primary_media = thumbnail
       │    ├── CustomField (cf_) → CustomFieldDefinition (cfdef_, store-owned)
       │    ├── ProductType (pt_) — template it was created from (optional)
       │    ├── DeliveryProfile — how it ships (required; auto-assigned)
       │    └── Seller — marketplace owner (nil = the operator's own catalog)
       └── Catalog (cat_) — audience-specific assortment + price list (see spree-pricing / spree-b2b)
```

## Products

| Attribute | Notes |
|---|---|
| `status` | `draft` (default), `active`, `archived`. Only `active` is visible on the storefront. Marketplaces add `proposed` / `rejected` (seller review — see `spree-marketplace`). |
| `name`, `slug`, `description`, `meta_*` | Translatable (Mobility). `description` is rich text; the API returns `description` (plain) and `description_html`. |
| `available_on`, `discontinue_on` | Sale window, on top of `status`. |
| `store` | `belongs_to :store` — a product has exactly one owning store (`Product.for_store(store)`). Defaults to `Spree::Current.store` / `Spree::Store.default`. |
| `delivery_profile_id` | Required. Stamped on create from the product type, else the store's default profile. |
| `product_type_id`, `tax_category_id`, `seller_id`, `tags`, `metadata` | Operational fields (Admin API only). |

Statuses are a plain string column (`Spree::HasStatus`), not a state machine — `product.active?`, `Product.published` (= `status: 'active'`), `Product.not_archived`.

### Creating products

The Admin API is the canonical write path (it runs the product workflows and prefixed-ID decoding):

```typescript
import { createAdminClient } from '@spree/admin-sdk'
const admin = createAdminClient({ baseUrl: 'https://store.example.com', secretKey: 'sk_xxx' })

// Single-variant product: prices go straight on the product (forwarded to its one variant)
await admin.products.create({
  name: 'The Spree Handbook',
  status: 'active',
  prices: [{ currency: 'USD', amount: '19.99' }],
})

// Product with options: send variants; options are matched by name/value (no ID lookups)
await admin.products.create({
  name: 'Premium T-Shirt',
  status: 'draft',
  variants: [{
    sku: 'TEE-S-NAVY',
    options: [{ name: 'size', value: 'Small' }, { name: 'color', value: 'navy' }],
    prices: [{ currency: 'USD', amount: '29.99' }],
    stock_levels: [{ stock_location_id: 'sloc_xxx', count_on_hand: 50 }],
  }],
  product_publications: [{ channel_id: 'ch_xxx' }], // Admin API does NOT auto-publish
})
```

```bash
spree api post /products -d '{"name":"The Spree Handbook","status":"active","prices":[{"currency":"USD","amount":"19.99"}]}'
spree api post /products/prod_xxx/clone          # duplicate as a new draft
spree api delete /products/prod_xxx              # soft delete
```

Don't send both top-level `prices` and `variants`. Bulk endpoints exist (`bulkStatusUpdate`, `bulkAddToCategories`, `bulkAddTags`, `bulkDestroy`).

In Ruby (seeds, tasks, specs):

```ruby
Spree::Current.store = Spree::Store.default   # outside a request — Store.default can be nil in a fresh DB
product = Spree::Product.create!(name: 'Tote', status: 'active', sku: 'TOTE-1')  # sku= builds the default variant
product.default_variant.set_price('USD', 19.99)     # prices are per currency — see spree-pricing
product.set_custom_field('properties.material', 'Canvas')
```

## Variants and the default variant

**Every product has at least one variant**, and all variants are real and purchasable — there is no hidden master. A book with no options still has one variant carrying its SKU, price and stock.

- `product.default_variant` — the persisted FK `default_variant_id`; the "face" of the product (listing price, add-to-cart before a choice). It's the first variant unless set; if it's removed, another is promoted automatically.
- Product-level `sku`, `barcode`, `weight`, `price_in`, `amount_in`, `track_inventory`… delegate to the default variant (setters build it on demand).
- `product.variants` is every variant (ordered by position). `product.has_multiple_variants?` uses the `variant_count` counter cache.
- `buy_box_variant_id` is the variant a marketplace features when several sellers offer the listing.

```typescript
await admin.products.variants.create('prod_xxx', {
  sku: 'TEE-L-R',
  options: [{ name: 'size', value: 'Large' }, { name: 'color', value: 'Red' }],
  prices: [{ currency: 'USD', amount: '24.99' }],
})
```

## Option types and values

```ruby
size  = Spree::OptionType.create!(name: 'size',  label: 'Size',  kind: 'buttons')
color = Spree::OptionType.create!(name: 'color', label: 'Color', kind: 'color_swatch')
color.option_values.create!(name: 'navy', label: 'Navy', color_code: '#1f2a44')

color.color_swatch?        # kind == 'color_swatch'
variant.options_text       # "Size: Large, Color: Red"
variant.option_value('size') # "Large" (the value's label)
```

- The display field is **`label`** (translatable), not `presentation`. Query with `where(label: ...)`; API filter `q[label_cont]`.
- `kind` ∈ `dropdown`, `color_swatch`, `buttons` (`Spree::OptionType::KINDS`).
- Admin API: sending `option_values` on an option type **replaces the full set** — include every value you want to keep.
- Option types are **store-owned**: a product may only use its own store's (`ProductOptionType` validates it), and variant `options: [{ name:, value: }]` match — or create — option types in the product's store only. `Spree::OptionValue.for_store(store)` scopes values through their option type.

## Product types (templates)

A `Spree::ProductType` (`pt_`) captures "every shoe needs Size + Colour, lives under Footwear, ships by the standard profile, and asks for Material":

| Part | Behaviour |
|---|---|
| option types, categories, delivery profile | **Stamped at creation** onto the product, then independent. Seeding is additive — never removes. |
| custom field definitions | **Live by reference** — the product form always reflects the current type. `required` is advisory (not enforced on write). |

```typescript
const shoes = await admin.productTypes.create({
  name: 'Footwear',
  option_type_ids: ['opt_size', 'opt_color'],
  category_ids: ['ctg_footwear'],
  delivery_profile_id: 'fp_standard',
  custom_field_definitions: [{ id: 'cfdef_material', required: true, sort_order: 0 }],
})
await admin.products.create({ name: 'Trail Runner', product_type_id: shoes.id })
await admin.productTypes.applyToProducts(shoes.id)   // explicit, background, additive re-seed
```

Editing a type never rewrites existing products. A type with products can't be deleted.

## Categories vs collections

| | `Spree::Category` (`ctg_`) | `Spree::Collection` (`coll_`) |
|---|---|---|
| Shape | Nested tree (`parent`, `descendants`), store-owned | Flat, store-owned |
| Membership | Assigned (`product.category_ids = [...]`) | Manual, or **automatic** from rules (`available_on`, `sale`, `tag` rule types; `all`/`any` match) |
| URL | `permalink` = full path, e.g. `clothing/shirts` | `permalink` |
| Use | Navigation | Merchandising: "Summer 2026", "Under $50", "Best sellers" |

```ruby
shirts = Spree::Category.for_store(store).find_by!(permalink: 'clothing/shirts')
shirts.active_products_with_descendants
Spree::Product.in_category(shirts)            # includes descendants
Spree::Product.in_collection(collection)
```

- `category_ids=` / `collection_ids=` only accept ids from the product's own store (foreign ids are silently dropped). `collection_ids=` governs **manual** membership only — automatic memberships are rule-derived and survive.
- **Brand**: model it as a category (if it belongs in navigation) or a collection (if it's a landing page), optionally plus a `brand` custom field. Only build a `Spree::Brand` model (`spree-resource`) if brands need their own data beyond that.
- `Spree::Taxon` / `Taxonomy` and `product.taxons` are deprecated aliases (removed in 6.1).

Store API: `client.categories.get('clothing/shirts')`, `client.categories.products.list(...)`, `client.collections.products.list('summer-2026')`. Promotions target categories with the `category` rule (see `spree-promotions`).

## Custom fields

Typed, merchant-curated data — no migration, no decorator. A **definition** (`Spree::CustomFieldDefinition`, store-owned) declares the shape; a **custom field** (`Spree::CustomField`) is one record's value.

```typescript
const def = await admin.customFieldDefinitions.create({
  resource_type: 'Spree::Product',
  namespace: 'properties', key: 'material', label: 'Material',
  field_type: 'short_text',          // short_text | long_text | rich_text | number | boolean | json
  storefront_visible: true,          // false = absent from the Store API entirely
  searchable: true,                  // also: sortable — both make it filterable
})
await admin.products.customFields.create('prod_xxx', { custom_field_definition_id: def.id, value: '100% Cotton' })
```

```ruby
product.set_custom_field('properties.material', '100% Cotton')   # blank value deletes the row
product.get_custom_field('properties.material')&.value
product.storefront_custom_fields                                  # storefront_visible only
store.custom_field_definitions                                    # read definitions through the store
```

Store API: `?expand=custom_fields`. Filter/sort with the `cf_` key: `q[cf_properties_material_i_cont]=wool`, `sort=-cf_properties_weight`. Custom fields are for people; `metadata` (JSON) is for machines and never reaches the Store API.

## Media

`Spree::Media` (`media_`, formerly `Spree::Asset`) is store-owned and lives in a **media library** — a file can be uploaded unplaced, then attached to products, variants, categories, collections. Reuse shares the blob, not the row.

- `media_type` ∈ `image`, `video` (uploaded MP4/WebM/QuickTime, optional `poster_signed_id`), `external_video` (YouTube/Vimeo `external_video_url`; `video_embed_url` derived on save).
- `product.primary_media` / `variant.primary_media` — the thumbnail (first renderable image). `product.gallery_media` falls back to variant images. The Store API's `thumbnail_url` is always present — don't `expand=media` on listing pages.
- `focal_point_x/y` for crop-aware thumbnails; named sizes via Active Storage variants.
- Deleting a media file in use returns 422 with its usages (`admin.media.usage(id)`).

```typescript
await admin.products.media.create('prod_xxx', { signed_id, alt: 'Front' })  // after a direct upload
await admin.products.media.create('prod_xxx', { media_type: 'external_video', external_video_url: 'https://youtu.be/…' })
```

## Channel visibility ("my product isn't showing")

A product is on a channel only when a `ProductPublication` joins them (optional `published_at`/`unpublished_at` window). The dashboard auto-publishes new products on the default channel; **the Admin API does not**. Write the full set with `PATCH /products/:id { product_publications: [...] }` (absent channels are detached) or bulk with `POST /channels/:id/add_products` / `remove_products`.

Walk this list:

1. `status == 'active'` (outer gate) and within `available_on` / `discontinue_on`?
2. Owned by this store? `Spree::Product.for_store(store).exists?(product.id)`
3. Published on the request's channel? `product.publication_for(channel)` / `Spree::Product.for_channel(channel)`; window open?
4. Has a base price in the request currency? `product.default_variant.price_in('EUR').persisted?` — products without a price in the current currency are hidden.
5. B2B: the buyer's catalogs may restrict the assortment (`Spree.products_for_context_service`) — see `spree-b2b`. The same visible set gates anything that takes a variant from the shopper (e.g. wishlist items): a variant the listing wouldn't show is refused.
6. Meilisearch index stale? `spree rake spree:search:reindex`.

## Search

`Spree.search_provider` (a class-name string) handles text search, filters, facets, sort and pagination for Store API product listings; the controller first builds the security/visibility scope, then delegates.

| Provider | Setup |
|---|---|
| `Spree::SearchProvider::Database` (default) | Nothing. ILIKE + Ransack; fine for small catalogs. No indexing. |
| `SpreeMeilisearch::SearchProvider` | Add `gem 'spree_meilisearch'` + `spree bundle install`, set `MEILISEARCH_URL` (and `MEILISEARCH_API_KEY` in production), set `Spree.search_provider = 'SpreeMeilisearch::SearchProvider'` in `config/initializers/spree.rb`, then reindex. Typo tolerance, relevance, fast facets. |
| Your own | Subclass `Spree::SearchProvider::Base`; implement `search_and_filter(scope:, query:, filters:, sort:, page:, limit:)` (returns a `SearchResult`), `self.indexing_required?`, `index`, `remove`, `remove_by_id`, `index_batch`, `reindex`. |

```bash
spree rake spree:search:reindex        # per store; no-op work for the Database provider
```

- Index documents are shaped by `Spree::Dependencies.search_product_presenter` (set to `SpreeMeilisearch::ProductPresenter` by the gem; core ships none). Swap it to add fields; `product.search_presentation` previews the documents (one per locale × currency).
- Index with **prefixed IDs** (`prod_…`, `ctg_…`), never raw ids.
- Reindex after bulk imports, provider switch, or changing custom-field `searchable`/`sortable` flags.
- Ruby scopes: `Product.search(query)`, `.with_option_value(option, value)`, `.with_option_value_ids`, `.in_category`, `.in_categories`, `.in_collection`, `.price_between`, `.in_stock`. Define your own with plain `scope` (there is no `add_search_scope`).

## Digital assets

A variant is *digital* when its delivery profile is a digital one; it *carries files* via `Spree::DigitalAsset` (`dig_`, belongs to a variant, file in **private** storage — request direct uploads with `private: true`). Placing an order grants one `Spree::DigitalLink` per asset per unit (token, `authorized_clicks` default 5, `authorized_days` default 7). Events: `digital_asset.*`, `digital_link.downloaded`. Custom deliverables (license keys) are a digital asset provider — see `spree-providers` and `docs/developer/how-to/custom-digital-asset-provider`.

## Imports / exports

CSV imports and exports run through the Admin API (`admin.imports`, `admin.exports`, `type: 'products'`, etc.). Custom-field columns use the `custom_field.<namespace>.<key>` prefix. Download a template per type to get the expected columns. See `docs/developer/core-concepts/imports-exports`.

## Gotchas

- `variant.price` / `product.price=` don't exist — prices are per currency (`price_in`, `set_price`). See `spree-pricing`.
- `Product#default_image`, `#featured_image`, `#primary_image` are gone → `primary_media`. `OptionType#color?` → `color_swatch?`.
- `Spree::Product.for_store(store)`, not `Spree::Product.all` — and never assume `Spree::Store.default` exists in jobs/tests; set `Spree::Current.store`.
- Adding custom product attributes: prefer custom fields. If you truly need a column, add it and extend permitted params with `Spree::Product.additional_permitted_attributes += [:brand_id]` (never `<<` — the array is frozen).
- Admin API resolves resources by prefixed ID only; the Store API accepts slug or ID. Old slugs are kept in `friendly_id_slugs` but the Store API 404s on them — redirect in the storefront.
- Seller-submitted products: status is not writable by sellers; use submit/approve/reject — see `spree-marketplace`.

## Where to read further

- `node_modules/@spree/docs/dist/developer/core-concepts/products.md`
- `node_modules/@spree/docs/dist/developer/core-concepts/media.md`
- `node_modules/@spree/docs/dist/developer/core-concepts/metafields.md` (custom fields)
- `node_modules/@spree/docs/dist/developer/core-concepts/search-filtering.md`, `.../slugs.md`, `.../imports-exports.md`
- `node_modules/@spree/docs/dist/developer/how-to/custom-search-provider.md`
- Related skills: `spree-pricing`, `spree-inventory`, `spree-b2b`, `spree-marketplace`, `spree-i18n`, `spree-typescript-sdk`

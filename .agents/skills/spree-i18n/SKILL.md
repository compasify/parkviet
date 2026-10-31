---
name: spree-i18n
description: Use when translating a Spree 6 store — adding a locale, translating product/category/collection content, fixing missing translations, building a multilingual storefront, syncing translations from a TMS via the Admin API, making a custom model translatable, working with Mobility, or wrangling `Spree.t` / dashboard i18next keys. Common phrasings include "add Spanish to Spree", "translate products", "Mobility", "translation tables", "RTL", "missing translation", "Spree.t", "fallback locale", "translated slugs", "translations API", "translate dashboard plugin", "X-Spree-Locale".
---

# Spree I18n + Translations

Three separate translation surfaces:

| What | Mechanism | Where it lives |
|---|---|---|
| **Merchant content** (product names, descriptions, slugs, category names…) | [Mobility](https://github.com/shioyama/mobility) translation tables | `spree_<model>_translations` tables; edited in the dashboard or via the Admin API |
| **Backend strings** (emails, validation errors, API error messages) | Rails I18n + `Spree.t` | `config/locales/<locale>.yml`; community `spree_i18n` gem |
| **Dashboard UI** (the React admin) | i18next JSON bundles | `@spree/dashboard` ships `ar de en es fr pl zh-CN`; plugins register their own |

Which locales a store offers is decided by its **Markets** (each market has `default_locale` + `supported_locales`) — see `spree-data-model` / markets docs.

## Locale resolution (Store API)

Per request, `Spree::Api::V3::LocaleAndCurrency`:

1. Resolves the market from `X-Spree-Country`.
2. Locale = `X-Spree-Locale` header → `?locale=` param (each honored **only** if in `current_store.supported_locales_list`) → `Spree::Current.locale` (market default → store default). Unsupported values silently fall back.
3. Sets `I18n.locale`, `Spree::Current.locale`, and `Spree::Current.content_locale = current_store.default_locale`.
4. Configures Mobility fallbacks via `Spree::Locales::SetFallbackLocaleForStore` — every locale falls back to the store's default locale.

```ts
const client = createClient({ baseUrl, publishableKey, locale: 'fr' })
client.setLocale('de')
await client.products.get('sac-spree', {}, { locale: 'fr' })  // per-request override
```

Pass exactly a code the store supports (`es`, not `es-ES` unless configured). Storefront language switchers read `GET /api/v3/store/locales`.

**Caching:** guest Store API responses set `Vary: Accept, x-spree-currency, x-spree-locale, x-spree-channel`; authenticated responses are `private, no-store`. The `Vary` list does **not** include `x-spree-country`, yet country selects the market (locale/currency fallback, market-scoped prices) — if your storefront sends it, add country to the CDN cache key yourself. A hand-rolled cache (Next.js `fetch` cache, Redis) must key on locale, currency, channel and country.

## Data translations — Mobility

Translatable models declare `TRANSLATABLE_FIELDS` and include `Spree::TranslatableResource`:

| Model | Fields |
|---|---|
| `Spree::Product` | `name`, `description`, `slug`, `meta_title`, `meta_description` |
| `Spree::Category` | `name`, `pretty_name`, `description`, `permalink` |
| `Spree::Collection` | `name`, `description`, `permalink` |
| `Spree::ProductType` | `name` |
| `Spree::OptionType`, `Spree::OptionValue` | `label` |
| `Spree::Store` | `name`, `seo_title`, `meta_description`, `meta_keywords`, support contact fields |
| `Spree::Policy` | `name`, `body` |
| `Spree::Seller` | `name`, `about` |

The registry is `Spree.translatable_resources` (drives the Admin API translation endpoints and dashboard translation editors). `RICH_TEXT_TRANSLATABLE_FIELDS` marks HTML fields so the dashboard shows a rich-text editor.

**Custom field values** (`Spree::CustomField`) are not Mobility-translated — one value per record.

### How reads resolve

Every model uses `translates(*TRANSLATABLE_FIELDS, column_fallback: Spree.mobility_column_fallback)`:

- The **base column** on the model table holds content in the store's default locale (`Spree::Current.content_locale`). Reading/writing in that locale hits the base column.
- Any **other locale** reads the translation table; missing values fall back (via the store fallbacks above) to the default locale → base column. A half-translated catalog still renders.
- `Spree::Config[:always_use_translations] = true` (env `SPREE_ALWAYS_USE_TRANSLATIONS`) disables column fallback: all locales, including the default, go through translation tables. Leave it `false` unless you have a specific reason.

```ruby
Mobility.with_locale(:es) { product.name }             # translated or fallback
product.name(locale: :es, fallback: false)             # nil if no Spanish row — detect gaps
```

Outside a request (console, jobs, rake) there is no store fallback configured and `content_locale` is unset. Set context first:

```ruby
Spree::Current.store = store
Spree::Current.content_locale = store.default_locale
Spree::Locales::SetFallbackLocaleForStore.new.call(store: store)
```

### Writing translations in Ruby

```ruby
product.upsert_translations(
  'es' => { 'name' => 'Camiseta', 'description' => '<p>Una camiseta</p>' },
  'fr' => { 'name' => 'T-shirt' }
)
```

`upsert_translations` semantics: absent locale/field → untouched; `""` → empty string (read falls back); `nil` → deletes that cell. Locales not in the record's store `supported_locales_list` raise `ActiveRecord::RecordInvalid`. Or write directly: `Mobility.with_locale(:es) { product.update!(name: 'Camiseta') }`.

### Translated slugs

Product `slug` and Category/Collection `permalink` are per-locale — `/produits/sac-spree` in French. Slugs are unique within a locale, may repeat across locales. The Store API looks up the slug in the request locale and falls back to the default-locale slug. Old slugs are not auto-resolved (404) — redirect in the storefront.

## Translations through the Admin API / dashboard

Merchants translate in the dashboard (per-record locale switcher, plus a centralized Translations page with coverage). The same surface is available to integrations (TMS sync, AI translation jobs):

| Endpoint | SDK (`@spree/admin-sdk`) | Purpose |
|---|---|---|
| `GET /api/v3/admin/translatable_resources` | `client.translatableResources.list()` | Registry: `[{ resource_type, fields: [{ key, type }] }]` |
| `GET /api/v3/admin/locales` | — | Store's supported locales (`code`, `name`, `default`, `rtl`) |
| `GET /api/v3/admin/products/:id/translations` | `client.products.translations.get(id)` | Matrix: source values + per-locale translations (+ nested children, e.g. option values) |
| `GET /api/v3/admin/<resource>/:id?expand=translations` | — | Translation matrix inline on the record |
| `POST /api/v3/admin/translations/batch` | `client.translations.batch(entries)` | **The write surface** — atomic across records/types |
| `GET /api/v3/admin/translations?resource_type=product` | `client.translations.coverage('product')` | Per-locale coverage grid |

```ts
await admin.translations.batch([
  { resource_type: 'product', resource_id: 'prod_86Rf07xd4z',
    values: { fr: { name: 'Sac Spree' }, de: { name: 'Spree Tasche' } } },
  { resource_type: 'option_value', resource_id: 'optval_…', values: { de: { label: 'Klein' } } },
])
```

`resource_type` tokens are underscored model names (`product`, `option_type`, `option_value`, `category`, `collection`, `product_type`, `store`, `policy`, `seller`). All entries succeed or none do. Secret keys need `write_<resource>` for every resource type in the batch. Translations are **not** written through `PATCH /products/:id`.

Bulk CSV: `Spree::Exports::ProductTranslations` / `Spree::Imports::ProductTranslations` (dashboard import/export; see `spree-reporting`).

## Making your own model translatable

1. Model:

   ```ruby
   module Spree
     class Brand < Spree.base_class
       include Spree::TranslatableResource
       TRANSLATABLE_FIELDS = %i[name description].freeze
       RICH_TEXT_TRANSLATABLE_FIELDS = %i[description].freeze
       translates(*TRANSLATABLE_FIELDS, column_fallback: Spree.mobility_column_fallback)
     end
   end
   ```

2. Migration for `spree_brand_translations` (`spree_brand_id`, `locale`, the fields, timestamps; unique index on `[spree_brand_id, locale]`). Keep the base columns — they hold default-locale content.
3. Register it (initializer, after core config loads):

   ```ruby
   Rails.application.config.after_initialize do
     Spree.translatable_resources += [Spree::Brand]
   end
   ```

   That makes it writable through `POST /translations/batch` (`resource_type: 'brand'`). For `?expand=translations`, include `Spree::Api::V3::Admin::Translatable` in the Brand admin serializer. The nested `GET …/:id/translations` read endpoint needs its own route (core mounts it with a `:translatable` route concern on core resources).

Adding a field to a **core** model: add the column to its translation table (and base table), then in a decorator redefine the frozen constant and call `translates` for the new field (never `TRANSLATABLE_FIELDS << :x` — `FrozenError`):

```ruby
module Spree::ProductDecorator
  def self.prepended(base)
    fields = base::TRANSLATABLE_FIELDS + [:subtitle]
    base.send(:remove_const, :TRANSLATABLE_FIELDS)
    base.const_set(:TRANSLATABLE_FIELDS, fields.freeze)
    base.translates :subtitle, column_fallback: Spree.mobility_column_fallback
  end
  Spree::Product.prepend self
end
```

Expose it in serializers and permitted attributes as usual.

## Backend strings — `Spree.t` and YAML

```ruby
Spree.t(:save)                              # spree.save
Spree.t(:paid, scope: 'payment_states')
Spree.t('custom_feature.title', default: 'Rewards')
```

- Add community translations: `spree bundle add spree_i18n` (40+ locales, picked up automatically).
- Override or add keys in your app's `config/locales/<locale>.yml` under `<locale>.spree.*` — the app's files load last.
- Enable Rails fallbacks with `config.i18n.fallbacks = [:en]` in `config/application.rb` (setting `I18n.fallbacks` in an initializer doesn't enable the backend module). Production.rb usually has `config.i18n.fallbacks = true`.
- `Spree::BaseMailer` configures the store's Mobility fallbacks, so translated data in emails resolves like in the API.
- Keep YAML tidy with `i18n-tasks` (`normalize`, `missing`, `unused`).
- Permission catalog labels for scopes you register live under `spree.permissions_catalog.resources.<name>`.

## Dashboard strings — i18next

The React dashboard does **not** use Rails YAML. Strings live in i18next's `translation` namespace under an `admin.` prefix. Plugins ship bundles:

```ts
import en from './locales/en.json'
import de from './locales/de.json'

export default defineDashboardPlugin({
  locales: { en, de },                // registered before the rest of the config
  nav: [{ key: 'brands', label: i18n.t('admin.brands.title'), path: '/brands' }],
})
```

Conventions: `admin.fields.<resource>.<attribute>.label`; name types a backend gem registers (promotion rules, calculators, integrations…) under `admin.types.<family>.<code>` so the dashboard doesn't fall back to the Ruby label in the store's locale. See `spree-dashboard-plugins`.

## RTL

`Spree::Locale::RTL_LANGUAGE_CODES` = `ar he fa ur yi`; `Spree::Locale.new(code:).rtl?` / `.direction`. `GET /api/v3/admin/locales` returns `rtl`. The storefront owns its `dir="rtl"` (set it in the Next.js layout from the active locale). The dashboard ships an Arabic bundle.

## Common problems

- **"translation missing: es.spree.…"** — add the key in your app's `config/locales/es.yml`, install `spree_i18n`, or enable `config.i18n.fallbacks`.
- **Spanish request still returns English** — is `es` in a market's `supported_locales`? (Unsupported header values are ignored.) Does the translation row exist (`product.name(locale: :es, fallback: false)`)? Is a cache keyed without locale?
- **Locale missing from the storefront switcher** — `store.supported_locales_list` aggregates markets' locales; add it: `market.update!(supported_locales: %w[en es fr])`. `I18n.available_locales` alone doesn't expose it.
- **Batch write 422 "Unsupported locale(s)"** — the locale isn't in the record's store supported locales.
- **Console shows default-locale value for every locale** — no store fallbacks / content locale set; see "How reads resolve".
- **Stale value after writing in the same process** — `product.reload`.

## Where to read further

- `node_modules/@spree/docs/dist/developer/core-concepts/translations.md`
- `node_modules/@spree/docs/dist/developer/core-concepts/slugs.md`
- `node_modules/@spree/docs/dist/developer/core-concepts/markets.md`
- `node_modules/@spree/docs/dist/developer/dashboard/customization/translations.md`
- Mobility: https://github.com/shioyama/mobility · spree_i18n: https://github.com/spree-contrib/spree_i18n

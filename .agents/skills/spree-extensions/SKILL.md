---
name: spree-extensions
description: Use when installing a Spree gem (spree_stripe, spree_easypost, spree_meilisearch, spree_opentelemetry, spree_i18n, spree_adyen, spree_multi_store…) or building your own reusable Spree 6 extension — a gem (Rails engine) for models, API endpoints, permissions, hooks and providers, paired with a dashboard plugin (npm package) for admin screens. Common phrasings - "add Stripe", "install spree_X", "create a Spree extension", "build a gem for Spree", "spree-extension create", "share this across apps", "register a provider from my gem", "engine initializer", "after_initialize vs to_prepare", "extension migrations". For single-app customization start with spree-customization — most work doesn't need a gem.
---

# Spree Extensions

> Commands use the `spree` CLI form (Rails app in `server/`). On a classic Rails app use `bundle …` / `bin/rails …` from the app root — see `spree-project`.

A Spree 6 extension has **two halves**:

| Half | What it is | Holds |
|---|---|---|
| **Gem** (Rails engine) | `spree_<name>` Ruby gem | Models, migrations, Store/Admin API endpoints, serializers, permission scopes, workflow hooks, subscribers, provider classes, integrations |
| **Dashboard plugin** (optional) | npm package using `defineDashboardPlugin` | Admin screens, nav entries, product-page widgets — talking to the gem's Admin API endpoints |

There are no views to add: Spree 6 has no Rails admin and no Rails storefront. Storefront pages live in your storefront app via `@spree/sdk`.

**Is a gem the right shape?** Only when the customization is shared across apps or published. For one app, put the same code in `server/app/` and register it in `server/config/initializers/spree.rb` — see `spree-customization`.

## Installing an extension gem

```bash
spree bundle add spree_reviews          # or edit server/Gemfile, then `spree bundle install`
spree generate spree_reviews:install    # convention: every extension ships <gem>:install
spree migrate
spree restart                           # Gemfile changes need a full restart (Ctrl+C `spree dev` if running)
```

On a fresh `create-spree-app` project using the prebuilt image, run `spree eject` once so the container builds from your `server/` Gemfile.

The install generator typically copies migrations (`db/migrate/<ts>_<name>.<engine_name>.rb`) and may add an initializer. If the extension has a dashboard plugin, also `pnpm add @scope/plugin` in `apps/dashboard/` — plugins are auto-discovered via the `spree.dashboard.plugin` marker in their `package.json`, no host code edit.

### Gems in a scaffolded project

The `spree-starter` server Gemfile (what `create-spree-app` clones into `server/`) includes:

| Gem | Provides |
|---|---|
| `spree` | Meta gem → `spree_core` + `spree_api` |
| `spree_dashboard` | Serves the React admin at `/dashboard` |
| `spree_emails` | Transactional emails |
| `spree_stripe` | Stripe payments + Stripe Connect payout provider |
| `spree_easypost` | EasyPost carrier rates, labels, tracking (delivery rate + fulfillment provider) |
| `spree_meilisearch` | Meilisearch search provider (`SpreeMeilisearch::SearchProvider`) |
| `spree_opentelemetry` | OpenTelemetry tracing (dormant until `OTEL_*` env is set) |
| `spree_i18n` | UI translations |

`spree_adyen` and `spree_paypal_checkout` are present but commented out — check each gem's gemspec/CHANGELOG for a Spree 6 compatible release before enabling. The same goes for any community gem from the Spree 4/5 era (`spree_reviews`, `spree_avatax_official`, …): check the `spree_core` constraint first; most need porting (no `spree_admin`, no `Spree::Adjustment`, no state machines). Integrations catalog: `https://spreecommerce.org/docs/integrations`.

Multi-store *sharing* (one product/promotion/payment method across several stores) is not core — core records belong to one store. Use the `spree_multi_store` extension for that.

## Building an extension

```bash
gem install spree_extension -v '>= 2.0'   # 1.x generates a Spree 5 scaffold (spree_admin, importmap) — don't use it
spree-extension create reviews            # → ./spree_reviews
cd spree_reviews
```

The 2.x scaffold depends on `spree_core` + `spree_api` (`>= 6.0.0.beta`), and ships:
- `lib/spree_reviews/engine.rb` — a `config.to_prepare` that loads every `app/**/*_decorator*.rb` (boot + each dev reload) and a commented `additional_permitted_attributes +=` example.
- `config/initializers/spree.rb` — the extension's registration file, loaded by the host at boot like any initializer, with commented examples for `register_scope`, `Spree.hooks.register` and an `after_initialize` block for subscribers and registries.
- `config/routes.rb` — the `Spree::Core::Engine.add_routes` hook, `lib/spree_reviews/factories.rb`, and an `install` generator that copies migrations.

### Model

```ruby
# db/migrate/20260901000000_create_spree_reviews.rb
create_table :spree_reviews do |t|
  t.references :store, null: false, index: true, foreign_key: false
  t.references :product, null: false, index: true, foreign_key: false
  t.integer :rating, null: false
  t.text :body
  t.boolean :approved, null: false, default: false
  t.timestamps
end
```

```ruby
# app/models/spree/review.rb
module Spree
  class Review < Spree.base_class
    include Spree::SingleStoreResource     # store filled in; API scopes to current store

    has_prefix_id :review                  # review_k5nR8xLq on the wire
    publishes_lifecycle_events             # review.created / .updated / .deleted

    belongs_to :product, class_name: 'Spree::Product'   # required by default ("must exist")

    validates :rating, presence: true, inclusion: { in: 1..5 }
    scope :approved, -> { where(approved: true) }

    self.whitelisted_ransackable_attributes = %w[rating approved]
  end
end
```

Conventions: `Spree.base_class`, no FK constraints, `class_name` on associations, store-scoped data, prefixed IDs, events instead of callbacks.

### API

Store API controller inherits `Spree::Api::V3::Store::ResourceController`; Admin API controller inherits `Spree::Api::V3::Admin::ResourceController` and **must** declare `scoped_resource :reviews` (the permission gate) and `resource_permitted_attributes`. Serializers subclass `Spree::Api::V3::BaseSerializer` (admin serializer extends the store one). Routes:

```ruby
# config/routes.rb
Spree::Core::Engine.add_routes do
  namespace :api, defaults: { format: 'json' } do
    namespace :v3 do
      namespace(:store) { resources :reviews, only: [:index, :show] }
      namespace(:admin) { resources :reviews }
    end
  end
end
```

Full controller/serializer templates: `spree-resource` (the `spree:api_resource` generator emits them) and `spree-api-v3`. Namespace paths of plugin-owned resources to avoid collisions with future core resources.

### Registrations — where and when

Registrations go in the extension's `config/initializers/spree.rb`; model-touching code goes in the engine's `config.to_prepare`. **Timing matters**, because core assigns some registries with `=` inside its own `config.after_initialize`, wiping anything appended earlier:

| Registration | Put it in |
|---|---|
| `Spree.payment_methods <<`, `Spree.fulfillment_providers <<`, `Spree.integrations <<`, `Spree.stock_splitters <<`, `Spree.tracking_carriers[...] =`, `Spree.adjusters <<`, `Spree.promotions.actions <<`, `Spree.*_authentication_strategies.add` | `Rails.application.config.after_initialize do … end` — core *assigns* these in its own `after_initialize`, which runs first |
| `Spree.subscribers`, `Spree.delivery_rate_providers`, `tax_providers`, `payout_providers`, `digital_asset_providers`, `pricing_providers`, `inventory_providers`, `order_routing.rules/strategies`, `promotions.rules`, `Spree.reporting` | Seeded before app initializers and core *concatenates* — any point works; `after_initialize` is the safe uniform choice (and avoids autoloading classes mid-boot) |
| `Spree.hooks.register(...)`, `Spree.permissions.register_scope(...)`, `Spree.search_provider =` | Top level of the initializer (string/registry-based, reload-safe) |
| `Spree::Product.additional_permitted_attributes += [...]`, decorator loading, anything touching model classes | Engine `config.to_prepare` (re-runs on dev reload) |

```ruby
# config/initializers/spree.rb (inside the gem)
Spree.permissions.register_scope(:reviews, group: :catalog, resources: -> { [Spree::Review] })
Spree.hooks.register('products.activate.validate', 'SpreeReviews::RequireDescription')

Rails.application.config.after_initialize do
  Spree.subscribers << SpreeReviews::ReviewRequestSubscriber   # `bin/rails g spree:subscriber` adds these; pass the class — a String crashed production boot through 6.0.0.beta4
  Spree.integrations << 'SpreeReviews::Integration'            # if the gem needs per-store credentials
end
```

```ruby
# lib/spree_reviews/engine.rb
module SpreeReviews
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_reviews'

    config.to_prepare do
      Dir.glob(SpreeReviews::Engine.root.join('app/**/*_decorator*.rb')) do |decorator|
        Rails.configuration.cache_classes ? require(decorator) : load(decorator)
      end
      Spree::Product.additional_permitted_attributes += [:reviews_enabled]  # += never << (frozen array)
    end
  end
end
```

A host app registers the same things the same way from `server/config/initializers/spree.rb`. `to_prepare` is **not** enough for the core-assigned registries — at boot it runs *before* `after_initialize`, so core overwrites it.

What each registration buys you:
- **`register_scope`** mints `read_reviews` / `write_reviews`, shown in the staff role editor and grantable to secret API keys. Label it in `config/locales/en.yml` under `en.spree.permissions_catalog.resources.reviews.{label,description}`. Options: `write: false`, `audiences:`, `read_only_for:`. See `spree-auth-permissions`.
- **Workflow hooks** run inside a core flow and can stop it (`workflow.reject!('…')`). Hook keys are validated at boot when eager loading — a typo fails startup. See `spree-workflows`.
- **Subscribers** (`Spree::Subscriber`, `subscribes_to 'order.placed'`) react after the fact. See `spree-events-webhooks`.
- **Providers** plug into tax, delivery rates, fulfillment, payments, search, payouts, digital assets, auth. See `spree-providers` for every base class and registry.
- **`Spree.dependencies`** swaps a core service/workflow (`*_workflow` keys). See `spree-dependencies`. Prefer hooks — a swapped workflow must be kept in sync with core.

Reach for **decorators last** (e.g. adding `has_many :reviews` to `Spree::Product`) — see `spree-decorators`.

### Dashboard plugin half

```bash
npx @spree/cli plugin new reviews       # or `spree plugin new reviews`
```

The plugin calls `defineDashboardPlugin(...)` to add nav entries, routes and slot widgets, and reads/writes your endpoints through `@spree/admin-sdk`'s `client.request` escape hatch. Ship it as an npm package with the `spree.dashboard.plugin` marker; consumers `pnpm add` it and it auto-registers. Namespace nav keys, locale keys and API paths (`acme-brands`, not `brands`) — duplicate keys throw at boot. See `spree-dashboard-plugins`.

### Testing the extension

```bash
bundle exec rake test_app     # generate spec/dummy (re-run after adding migrations)
bundle exec rspec
```

Uses RSpec + Factory Bot via `spree_dev_tools`. Put your factories in `lib/spree_reviews/factories.rb`. API specs use shared contexts from `spree/api/testing_support/v3/base` — `'API v3 Store'`, `'API v3 Admin authenticated'`, `'API v3 Admin with custom permissions'`, `'API v3 Seller authenticated'`. See `spree-testing`.

## Gotchas

- **Registered in the wrong phase = silently missing.** A payment method, fulfillment provider or integration appended outside `after_initialize` disappears at boot (core reassigns those arrays). Symptom: not selectable in the dashboard / "type must be registered" 422.
- **`additional_permitted_attributes << :x`** raises `FrozenError`. Always `+=`.
- **Admin controller without `scoped_resource`** raises at request time — every Admin API controller must name its permission scope.
- **Migrations don't auto-apply.** After bumping an extension, re-run its install generator (or `spree rails railties:install:migrations`) then `spree migrate`. `spree migrate` alone only installs core migrations.
- **Don't rename copied migrations** — the `.<engine_name>.rb` suffix is how Rails skips already-copied ones and how Spree's boot check spots missing ones.
- **Credentials belong in a `Spree::Integration`** (per store, `:password` preferences are masked), not ENV — a multi-store app pays/ships from different accounts.
- **Two decorators on the same method** — last loaded wins. Prefer hooks/events so extensions compose.
- **Subscriber code hot-reloads**; changing a *registration* (the initializer) needs a restart.

## Where to read further

- Extension tutorial: `node_modules/@spree/docs/dist/developer/contributing/creating-an-extension.md`
- Providers & integrations: `node_modules/@spree/docs/dist/developer/providers/overview.md`
- Dashboard plugins: `node_modules/@spree/docs/dist/developer/dashboard/plugins/{overview,scaffolding,distributing}.md`
- Customization quickstart: https://spreecommerce.org/docs/developer/customization/quickstart
- Related skills: `spree-customization`, `spree-providers`, `spree-workflows`, `spree-resource`, `spree-auth-permissions`, `spree-dashboard-plugins`, `spree-testing`

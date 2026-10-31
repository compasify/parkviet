---
name: spree-decorators
description: Use when the user wants to extend an existing Spree 6 model or API controller without forking — add an association to Spree::Product, add a validation or scope, add a method to Spree::Cart / Spree::Order, narrow what an API v3 endpoint returns, permit an extra attribute on writes. Common phrasings include "add brand to product", "decorate Spree::X", "ProductDecorator", "OrderDecorator", "Module#prepend", "spree:model_decorator", "spree:controller_decorator", "extend an existing Spree model", "add a method to Spree::Order", "override Spree behavior", "monkey patch Spree", "customize an API controller". Provides the decorator pattern, the generators, the prepended(base) idiom, API controller decorators and the gotchas — and routes behavioral changes to workflow hooks, events or dependencies instead.
---

# Spree Decorators

> Commands use the Spree CLI (`spree …`). On a classic Rails app without the CLI, use `bin/rails g …` from the app root. Paths assume the Rails app lives in `server/`.

Decorators change existing Spree classes from your app with Ruby's `Module#prepend`, using a Spree filename convention and two generators. They couple you to Spree internals — use them for **structural** changes (association, validation, scope, read-only helper method, a narrowed controller scope), not for behavior.

## Pick the right tool first

| Use case | Use this instead of a decorator |
|---|---|
| Veto an operation (add-to-cart limit, checkout rule, cancel/return policy) | **Workflow `validate` hook** — `spree-workflows` |
| Contribute data to tax / promotion calculation | **Workflow context hook** — `spree-workflows` |
| Do something alongside a cart/order/fulfillment/payment operation | **Workflow lifecycle hook** — `spree-workflows` |
| React after a save / sync to ERP / send notification | **Event subscriber** — `spree-events-webhooks` |
| Replace how a flow computes | `Spree.dependencies` — `spree-dependencies` |
| Change an API response shape | Serializer subclass via `Spree.api.*_serializer` — `spree-dependencies` |
| Accept an extra attribute on API writes | `Model.additional_permitted_attributes += [...]` (below) |
| Make a field filterable via `q[...]` | `Spree.ransack.add_attribute(Spree::Product, :brand_id)` |
| Store an extra value without a migration | Custom fields (`product.set_custom_field('ns.key', value)`) — `spree-catalog` |
| Add a new endpoint | A new `ResourceController` subclass — `spree-resource` |
| Admin UI changes | Dashboard plugins / slots — `spree-dashboard-plugins` |
| Add an association, validation, scope, or helper method to a model | **Decorator** (this skill) |
| Narrow an existing endpoint's `scope`, swap its `serializer_class` | **Controller decorator** (this skill) |

Never decorate business verbs (`Order#finalize!`, `Order#cancel`, `Payment#capture!`, `Fulfillment#finalize!`): they are deprecated shells that delegate to workflows, and the real flows (`Spree::Carts::Complete`, `Spree::Orders::Cancel`, `Spree::Payments::Capture`) don't call them. Status transitions have no state-machine callbacks to hook either — use the workflow's hooks.

## The pattern

```ruby
# server/app/models/spree/product_decorator.rb
module Spree
  module ProductDecorator
    def self.prepended(base)
      # class-level: associations, validations, scopes, class_attributes — called on base
    end

    # instance methods here; call super to reach the original
  end

  Product.prepend(ProductDecorator)
end
```

Decorators are loaded by a `config.to_prepare` block in `config/application.rb` (added by the Spree installer) that globs `app/**/*_decorator*.rb` — so `prepend` runs at boot and after every dev reload. If your app lacks that block, add it: Zeitwerk alone never loads an unreferenced decorator and it will silently not apply.

## Generators

```bash
spree generate model_decorator Spree::Product
# → server/app/models/spree/product_decorator.rb

spree generate controller_decorator Spree::Api::V3::Admin::ProductsController
# → server/app/controllers/spree/api/v3/admin/products_controller_decorator.rb
```

(`bin/rails g spree:model_decorator …` without the CLI.) The model generator runs the name through `classify`, which singularizes — for plural-named classes (`Spree::Exports::Products`) write the file by hand.

## Model decorator patterns

### Add an association

Migration first — Spree style is no FK constraint:

```bash
spree generate migration AddBrandIdToSpreeProducts brand_id:bigint:index
```

```ruby
class AddBrandIdToSpreeProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :spree_products, :brand_id, :bigint
    add_index :spree_products, :brand_id
  end
end
```

```ruby
module Spree
  module ProductDecorator
    def self.prepended(base)
      base.belongs_to :brand, class_name: 'Spree::Brand', optional: true
      base.has_many :videos, class_name: 'Spree::Video', dependent: :destroy
      base.additional_permitted_attributes += [:brand_id]   # writable via Admin API (see below)
    end
  end

  Product.prepend(ProductDecorator)
end
```

`belongs_to` is **required by default** in Spree models — add `optional: true` or every existing product fails with "Brand must exist". Always pass `class_name` (string — resolved lazily, avoids load-order issues) and `dependent:` on `has_many`.

### Validation, scope, class method

```ruby
module Spree
  module ProductDecorator
    def self.prepended(base)
      base.validates :external_id, uniqueness: { scope: :store_id }, allow_nil: true   # plus a DB index
      base.scope :recently_added, -> { where(created_at: 30.days.ago..) }
      base.scope :tagged_featured, -> { where("metadata->>'featured' = ?", 'true') }  # jsonb on PostgreSQL
      base.extend ClassMethods
    end

    module ClassMethods
      def search_by_name(query)
        where('LOWER(name) LIKE ?', "%#{sanitize_sql_like(query.downcase)}%")
      end
    end
  end

  Product.prepend(ProductDecorator)
end
```

Models with metadata have a single `metadata` JSON column (`public_metadata` / `private_metadata` no longer exist; `private_metadata` is a deprecated Ruby alias). `metadata` is internal, never exposed on the Store API — for storefront-visible or filterable data prefer a real column or a custom field. JSON operators (`->>`) are PostgreSQL syntax; MySQL/SQLite need different SQL.

Operation-level rules ("max 10 per order", "B2B customers only") are **not** model validations — they belong in a workflow `validate` hook so data migrations and staff corrections aren't blocked. Don't `clear_validators!` to relax a core rule; see `node_modules/@spree/docs/dist/developer/customization/validations.md`.

### Override a method (call `super`)

```ruby
module Spree
  module ProductDecorator
    def purchasable?
      return false if metadata[:embargoed]
      super
    end
  end

  Product.prepend(ProductDecorator)
end
```

Omitting `super` replaces the original entirely. Keep overrides to read-only/derived methods; anything that writes or moves money belongs in a workflow.

### Cart & Order: methods live in `Spree::Purchase::*` concerns

`Spree::Cart` (pre-checkout) and `Spree::Order` (placed, immutable) share behavior through concerns — `Spree::Purchase::Totals`, `::Addresses`, `::Taxation`, `::PaymentProcessing`, `::CheckoutSteps` (Cart only), `::Validations`, etc. (`spree_core` `app/models/concerns/spree/purchase/`). Before decorating, find where the method is defined (`Spree::Cart.instance_method(:amount).owner`).

- To change it for one side only, decorate `Spree::Cart` **or** `Spree::Order` (the prepended module sits in front of the concern, `super` reaches it).
- For both, decorate both classes (or prepend to the concern itself: `Spree::Purchase::Totals.prepend(MyTotals)` — Ruby 3 propagates to classes that already included it).
- Most cart/order logic you'd want to change (adding items, totals, completion) is in workflows, not models — use hooks.

### Permit a new attribute on writes

```ruby
Spree::Product.additional_permitted_attributes += [:brand_id]
Spree::LineItem.additional_permitted_attributes += [:gift_note]
```

- Always `+=` (or `|=`). Never `<<` — the default is a frozen array (`FrozenError`) — and never `=`, which drops what other extensions added.
- Put it in the model decorator's `prepended` (as above) or a `Rails.application.config.to_prepare` block, so it survives dev reloads of the engine's models.
- API v3 controllers union this list with their own (`resource_permitted_attributes`); `Spree::PermittedAttributes` no longer exists.
- Line items: `Spree::LineItem.additional_permitted_attributes` is the **only** thing that reaches the record through add-to-cart — sent top-level or inside `options` on `POST /carts/:id/items` (`Spree::Carts::AddItem`). Everything else in `options` is dropped, and `id`, `variant_id` and `quantity` can never be set that way (they were checked and priced already), even if you permit them.

### Make it filterable

```ruby
# config/initializers/spree.rb
Spree.ransack.add_attribute(Spree::Product, :brand_id)
Spree.ransack.add_association(Spree::Product, :brand)
Spree.ransack.add_scope(Spree::Product, :recently_added)
```

Without this, `q[brand_id_eq]=…` is silently dropped (200, unfiltered). `add_association` only widens the **Admin** API: the Store API follows just `storefront_ransackable_associations` (add `Spree::Product.storefront_ransackable_associations |= %w[brand]` in the same initializer if shoppers should filter by brand name) and the Seller API follows none. Hide a staff-only attribute from shoppers/sellers with `private_ransackable_attributes` (`{ store: [...], seller: [...] }`). See `spree-api-v3`.

## Controller decorator patterns (API v3)

The only controllers Spree ships are the API ones — `Spree::Api::V3::Store::*`, `Spree::Api::V3::Admin::*` (and `::Seller::*`). There is no Rails admin or Rails storefront to decorate. Override the **named hooks** a `ResourceController` exposes — `scope`, `serializer_class`, `collection_includes`, `scope_includes`, `resource_permitted_attributes`, `model_class` — not actions.

### Narrow what an endpoint returns

```ruby
# server/app/controllers/spree/api/v3/admin/products_controller_decorator.rb
module Spree::Api::V3::Admin
  module ProductsControllerDecorator
    protected

    # Chain onto super — it is already store-scoped (and ability-scoped on the
    # Admin API). Replacing it leaks other stores' records.
    # current_user is nil for secret-key (sk_) requests — guard with &.
    def scope
      return super if current_user&.spree_admin?

      super.where(discontinue_on: nil)
    end
  end
end

Spree::Api::V3::Admin::ProductsController.prepend(Spree::Api::V3::Admin::ProductsControllerDecorator)
```

On the Store API, `current_user` is the signed-in customer (nil for guests); on the Admin API it's the staff member (nil for secret-key requests). Hook methods are `protected` in the base — keep them `protected` in the decorator.

### Swap the serializer for one endpoint

```ruby
module Spree::Api::V3::Store
  module ProductsControllerDecorator
    protected

    def serializer_class
      MyStore::DetailedProductSerializer
    end
  end
end

Spree::Api::V3::Store::ProductsController.prepend(Spree::Api::V3::Store::ProductsControllerDecorator)
```

To swap it everywhere, use `Spree.api.product_serializer = …` instead (`spree-dependencies`).

### A new action is a new controller

Don't add actions to Spree's controllers via decorators. Subclass the resource controller — you inherit pagination, Ransack filtering, prefixed IDs, error envelopes and authorization:

```ruby
# server/app/controllers/spree/api/v3/admin/product_audits_controller.rb
module Spree::Api::V3::Admin
  class ProductAuditsController < ResourceController
    scoped_resource :products   # API-key scope: read_products / write_products (required on Admin controllers)

    protected

    def model_class = MyStore::ProductAudit
    def serializer_class = MyStore::ProductAuditSerializer
    def resource_permitted_attributes = [:note]
  end
end
```

```ruby
# config/routes.rb
Spree::Core::Engine.add_routes do
  namespace :api, defaults: { format: 'json' } do
    namespace :v3 do
      namespace :admin do
        resources :product_audits
      end
    end
  end
end
```

`spree generate api_resource` scaffolds model + serializer + controller + routes — see `spree-resource`.

API decorators must render JSON (`render_error` / the standard error envelope), never flash/redirect.

## Common pitfalls

- **Forgot `super`** — silently replaces Spree's logic.
- **Instance variables in `prepended`** (`@setting = true`) live on the module, not instances — use `base.class_attribute :setting, default: true`.
- **Constant references at boot** — `has_many :variants` without `class_name: 'Spree::Variant'` can hit load-order errors.
- **File/module mismatch** — `Spree::ProductDecorator` must live at `app/models/spree/product_decorator.rb`.
- **Decorating `Spree::Order` for checkout behavior** — pre-checkout state is `Spree::Cart`; the order only exists after `Spree::Carts::Complete`.
- **`belongs_to` without `optional: true`** — "must exist" errors on existing rows.
- **`Spree.user_class`** — deprecated; decorate `Spree.customer_class` (default `Spree::Customer`) or `Spree.admin_user_class` (`Spree::AdminUser`).

## Organizing many decorators

```
server/app/models/spree/
├── product_decorator.rb        # the only file that calls prepend
└── product/
    ├── brand_decorator.rb      # plain modules
    └── seo_decorator.rb
```

```ruby
module Spree
  module ProductDecorator
    include Product::BrandDecorator
    include Product::SeoDecorator
  end

  Product.prepend(ProductDecorator)
end
```

Zeitwerk resolves the nested modules from their paths — no `require` / `require_dependency` (removed in Zeitwerk mode). Note the nested files also match the `*_decorator*.rb` glob, so they must not call `prepend` themselves.

## Migrating callback decorators

A decorator adding `after_save :sync_to_erp` should become a subscriber:

```ruby
# server/app/subscribers/product_sync_subscriber.rb   (spree generate subscriber ProductSync)
class ProductSyncSubscriber < Spree::Subscriber
  subscribes_to 'product.updated'

  def handle(event)
    ExternalSyncJob.perform_later(event.payload['id'])
  end
end
```

The payload is the serialized record (prefixed `id`), not a changeset. Registration and async behavior: `spree-events-webhooks`. Callbacks that touch money, stock or an external system inside an operation belong in a workflow hook instead.

## Where to read further

- `node_modules/@spree/docs/dist/developer/customization/decorators.md` (https://spreecommerce.org/docs/developer/customization/decorators)
- `node_modules/@spree/docs/dist/developer/customization/validations.md` — hooks vs decorator validations vs registries
- `node_modules/@spree/docs/dist/developer/customization/api.md` — custom API endpoints
- `node_modules/@spree/docs/dist/developer/tutorial/model-and-api.md` — brand-on-product walkthrough
- Related skills: `spree-workflows`, `spree-dependencies`, `spree-events-webhooks`, `spree-resource`, `spree-customization`

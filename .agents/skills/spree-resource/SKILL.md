---
name: spree-resource
description: Use when the user wants to add a new model, database table, or REST API endpoint to a Spree 6 project. Covers `spree:api_resource` (model + migration + Store/Admin API controllers + serializers + factory + controller specs + routes + permission scope) and `spree:model` (model + migration only). Common phrasings include "add a Brand model", "create a new resource", "expose X as an API endpoint", "add an Admin API for Y", "scaffold a Spree resource", "create a Spree model without an API", "internal model", "make my model store-scoped".
---

# Adding a Spree Resource

> Commands use the Spree CLI (`spree …`, Docker, Rails app in `server/`). On a classic Rails app without the CLI, run `bin/rails g spree:api_resource …` from the app root and drop the `server/` prefix from paths (see `spree-project`).

To add a model exposed through the v3 API, use the `spree:api_resource` generator. One command produces:

- The model (`server/app/models/spree/<name>.rb`) and its migration
- Store + Admin API controllers and serializers
- A FactoryBot factory and controller specs for both APIs
- Route lines inside the `Spree::Core::Engine.add_routes` block of your app's `config/routes.rb`
- The `read_<plural>` / `write_<plural>` permission scope (`Spree.permissions.register_scope` appended to `config/initializers/spree.rb`) and its role-editor label (`config/locales/spree_<plural>.en.yml`) — Admin surface only

Prerequisite: run `spree eject` first. Generators execute inside the web container, and only the ejected dev compose bind-mounts `./server`, so generated files appear (and persist) on your host.

## The one-command path

```bash
spree generate api_resource Brand name:string:index slug:string:uniq active:boolean
spree migrate
```

Output summary:

```text
✓ Generated Spree::Brand API resource
  Prefixed ID:  brand_xxxxxxxxxx
  Store API:    /api/v3/store/brands  (read-only)
  Admin API:    /api/v3/admin/brands  (full CRUD)
```

Field syntax follows Rails' attribute parser, with Spree conventions applied:

| You write | You get |
|---|---|
| `name:string` / `:text` / `:integer` / `:decimal` / `:boolean` / `:date` / `:datetime` | `null: false` column; presence validation for non-boolean fields |
| `name:string:index` | Non-unique index |
| `slug:string:uniq` | Unique index + uniqueness validation — scoped to `store_id` when the model is store-scoped (the default), plus `spree_base_uniqueness_scope` |
| `brand:belongs_to` (or `:references`) | `belongs_to` with `class_name`, index, **no FK constraint**, `null: false` |
| `category:belongs_to{TaxCategory}` | Explicit class hint (unqualified names only) → `class_name: 'TaxCategory'`, resolved inside the `Spree` namespace |
| `description:rich_text` | `has_spree_rich_text` + `Spree::SanitizableRichText` |
| `logo:attachment` / `photos:attachments` | `has_one_attached` / `has_many_attached` |

`belongs_to` class resolution: `user` → `Spree.customer_class`; `admin_user`, `created_by`, `approver`, `canceler` → `Spree.admin_user_class`; anything else → `Spree::<Camelized>`.

## Flags

| Flag | Default | Effect |
|---|---|---|
| `--writable` | off | Store API gets create/update/destroy. Default Store API is read-only (index + show). |
| `--no-store` | — | Skip the Store API controller + serializer + route. Admin-only resource. |
| `--no-admin` | — | Skip the Admin API surface. Rare. |
| `--store-name=Discount` | — | Expose the Store API under a different name (`/api/v3/store/discounts`); model, table and Admin API keep the canonical name. |
| `--no-store-scoped` | scoped | By default the model includes `Spree::SingleStoreResource` (`store_id` column, `belongs_to :store`, auto-assigned from `Spree::Current.store`, `for_store` scope, store can't be changed later). Opt out only for global reference data. |
| `--no-lifecycle-events` | on | By default the model calls `publishes_lifecycle_events` (`brand.created/updated/deleted` events for subscribers and webhooks). |
| `--custom-fields` | off | Includes `Spree::HasCustomFields` + `Spree::Metadata` (merchant-defined custom fields + `metadata` JSON). |
| `--paranoid` | off | `acts_as_paranoid` + `deleted_at` column/index; Admin serializer exposes `deleted_at`. |
| `--id-prefix=br` | snake-cased class name | Prefixed-ID prefix (`brand_…` by default). Core uses short prefixes: `prod_`, `variant_`, `cart_`, `or_`, `py_`, `ful_`, `cust_`, `sl_`. |
| `--parent=Spree::Foo` | `Spree.base_class` | Parent class expression. |
| `--permission-group=settings` | `catalog` | Where the `read_`/`write_` keys appear in the role editor and API-key scope picker (`orders`, `catalog`, `customers`, `settings`, … or your own lowercase identifier). |
| `--skip-routes` | off | Don't touch routes. |
| `--skip-specs` | off | Don't generate controller specs. |

## What gets created

```
server/app/models/spree/brand.rb                                    (owned-once)
server/db/migrate/<ts>_create_spree_brands.rb                       (append-only)
server/app/controllers/spree/api/v3/store/brands_controller.rb      (managed)
server/app/controllers/spree/api/v3/admin/brands_controller.rb      (managed)
server/app/serializers/spree/api/v3/brand_serializer.rb             (managed)
server/app/serializers/spree/api/v3/admin/brand_serializer.rb       (managed)
server/spec/factories/spree/brand_factory.rb                        (managed)
server/spec/controllers/spree/api/v3/{store,admin}/brands_controller_spec.rb (managed)
server/config/routes.rb                                             (idempotent inject)
server/config/initializers/spree.rb                                 (idempotent append — register_scope)
server/config/locales/spree_brands.en.yml                           (owned-once — permission label)
```

Generated model (store-scoped default):

```ruby
module Spree
  class Brand < Spree.base_class
    include Spree::SingleStoreResource

    has_prefix_id :brand
    publishes_lifecycle_events

    validates :name, presence: true
    validates :slug, presence: true, uniqueness: { scope: [:store_id, *spree_base_uniqueness_scope] }
    self.whitelisted_ransackable_attributes = %w[name slug active]
    self.whitelisted_ransackable_associations = %w[]
    self.whitelisted_ransackable_scopes = %w[]
  end
end
```

**Routes.** The generator inserts `resources :brands, only: [:index, :show]` (store) and `resources :brands` (admin) into the `namespace :store` / `namespace :admin` blocks inside `Spree::Core::Engine.add_routes` in `config/routes.rb` (create-spree-app / spree-starter ship this block empty). If the block or namespace is missing, it skips with a warning — add it by hand:

```ruby
Rails.application.routes.draw do
  Spree::Core::Engine.add_routes do
    namespace :api, defaults: { format: 'json' } do
      namespace :v3 do
        namespace :store do
          resources :brands, only: [:index, :show]
        end
        namespace :admin do
          resources :brands
        end
      end
    end
  end
  mount Spree::Core::Engine, at: '/'
end
```

## The "owned-once / managed / append-only" contract

- **Model (owned-once)** — written once; re-runs never touch it. Your validations, scopes, associations live here.
- **Migration (append-only)** — generated once. Change schema with a new migration: `spree generate migration AddLogoToSpreeBrands logo_url:string`.
- **Controllers, serializers, factory, specs (managed)** — overwritten on re-run. If you hand-edit them, don't re-run the generator for that resource (or re-apply your edits).
- **Routes and permission scope (idempotent)** — a route line or `register_scope(:brands, …)` already present isn't duplicated. The permission locale file is owned-once, so an edited label survives re-runs.

## After running the generator

1. **Review the model** — add validations, associations, scopes. Generated `belongs_to` is required (Spree models require `belongs_to` by default; failure message is "must exist"). Add `optional: true` and relax the migration's `null: false` for optional references.
2. **Migrate** — `spree migrate`.
3. **Grant the permission** — the Admin controller declares `scoped_resource :brands`, and the generator registered the matching scope in `config/initializers/spree.rb`:

   ```ruby
   # Permissions for the Brand API — grants read_brands / write_brands
   # to staff roles and secret API keys. Labels: config/locales/spree_brands.en.yml
   Spree.permissions.register_scope(:brands, group: :catalog, resources: -> { [Spree::Brand] })
   ```

   Until you grant `read_brands` / `write_brands` to a staff role (dashboard **Settings → Roles**, the Admin API, or seeds) or mint them on a secret key, only full-access principals get in (the `admin` role, `read_all`/`write_all` keys). The label lives under `spree.permissions_catalog.resources.brands` (`label`, optional `description`). With `--no-admin` nothing is registered. See `spree-auth-permissions`.
4. **Store-scoping on reads** — the base controller scopes collections with `Model.for_store(current_store)`. `SingleStoreResource` provides that scope; for `--no-store-scoped` models `for_store` falls back to `current_store.<plural>` if the association exists, else the whole table. Add `has_many :brands, class_name: 'Spree::Brand', dependent: :destroy` to `Spree::Store` via a decorator if you want `current_store.brands`. A permission decides *whether* someone may read brands, not *which* ones — keep lookups store-scoped.
5. **Permitted attributes** — the generated controllers declare the writable columns in `resource_permitted_attributes` (not a `permitted_params` override), so extension-declared attributes (`Spree::Brand.additional_permitted_attributes += [...]`) and param normalization still apply:

   ```ruby
   def resource_permitted_attributes
     [:name, :slug, :active]
   end
   ```

   Edit the list to drop columns clients shouldn't write — but the controllers are managed, so a re-run restores the template.
6. **Run the specs** — `spree rspec spec/controllers/spree/api/v3/`. The specs use the `'API v3 Store guest'` / `'API v3 Admin authenticated'` shared contexts from `spree_api`'s testing support (see `spree-testing`).

## Adding a status

Spree has no state machines. For a record with a lifecycle, add a string `status` column and use `Spree::HasStatus`; transitions belong in workflows (see `spree-workflows`):

```ruby
include Spree::HasStatus
has_status :draft, :active, :archived, default: :draft   # predicates (active?), scopes (.active), inclusion validation, .with_status(...)
```

Extensions append statuses with `Spree::Brand.add_status('paused', after: 'active')`. Don't use Rails enums for status.

## TypeScript types

In a project, serializers you generate are app-local — they're not in the published `@spree/sdk` / `@spree/admin-sdk` types. Call custom endpoints via `client.request<T>(...)` with hand-written types (see `spree-typescript-sdk`). The generated serializer's `typelize` line documents the JSON types (decimals serialize as strings).

## Common patterns

```bash
# Read-only catalog resource (Store GET, Admin CRUD)
spree generate api_resource Brand name:string:uniq active:boolean

# Writable customer-facing resource
spree generate api_resource SavedList label:string user:belongs_to --writable

# Admin-only back-office data
spree generate api_resource SupplierNote body:text --no-store

# Soft-delete + custom fields
spree generate api_resource Vendor name:string:uniq slug:string:uniq --paranoid --custom-fields

# Global reference data (no store_id)
spree generate api_resource Certification code:string:uniq --no-store-scoped
```

For a writable customer resource, remember the Store API authorizes by ownership: override `scope` in the Store controller to read through the customer (e.g. `current_user.saved_lists`), otherwise any shopper can see every record in the store.

## Model only — no API surface

`spree:model` produces the model + migration with the same conventions (prefixed ID, `Spree.base_class`, store scoping, lifecycle events, `null: false`, no FKs, ransack allowlists) and accepts the same model flags (`--paranoid`, `--custom-fields`, `--id-prefix`, `--parent`, `--no-store-scoped`, `--no-lifecycle-events`). Unlike `api_resource`, it keeps Rails' test-framework hooks, so with rspec/factory_bot configured you also get a stub model spec and factory.

```bash
spree generate model BrandImage position:integer brand:belongs_to
```

Use it when the record is internal (log, join table), only reachable through a parent's API, or you'll hand-write controllers. To add an API later, run `spree generate api_resource Brand …` — it detects the existing model and skips the model + migration (owned-once), generating only the API surface.

## Gotchas

- **Don't add FK constraints** or Rails enums; keep `foreign_key: false` and string statuses.
- **Extending core models** (e.g. `brand_id` on products) is a decorator + `Spree::Product.additional_permitted_attributes += [:brand_id]` (never `<<` — the array is frozen). See `spree-decorators`.
- **Jobs, rake tasks, console:** store-scoped records need a store. Set `Spree::Current.store = store` (don't rely on `Spree::Store.default`, which can be nil).
- **Custom read-only member actions** — add them to `read_actions` in the controller so they map to `read_*` instead of `write_*`.

## Where to read further

- `node_modules/@spree/docs/dist/developer/tutorial/model-and-api.md` — end-to-end Brand walkthrough
- `node_modules/@spree/docs/dist/developer/customization/permissions.md` — `register_scope`
- `node_modules/@spree/docs/dist/developer/customization/api.md` — extending the API
- Generator source: `spree/core/lib/generators/spree/{api_resource,model}/`

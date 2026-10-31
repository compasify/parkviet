---
name: spree-customization
description: Use FIRST when a Spree 6 customization is on the table and the right pattern isn't obvious — "how do I customize X", "where should this logic go", "decorator or subscriber?", "hook or event?", "how do I block checkout when…", "add a field to products", "change how tax/shipping/search works", "extend Spree without forking". A decision tree that routes each need to the right extension point (store settings, SPREE_* config, model preferences, workflow hooks, events, webhooks, Checkout::Registry, providers, custom fields vs metadata, validators, permitted attributes, permission scopes, new resources, dependencies, decorators, dashboard plugins) and to the skill that covers it in depth.
---

# Spree Customization — Where Does My Code Belong?

Spree 6 is built to be extended without forking. The hard part is picking the pattern. Work down the table: options near the top are data or configuration, cheaper to write and untouched by upgrades; options near the bottom couple you to Spree internals.

> Commands use the `spree` CLI form. On a classic Rails app use `bin/rails …` from the app root and drop the `server/` path prefix — see `spree-project`.

## The decision tree

| You want to… | Reach for | Skill |
|---|---|---|
| Change currency, markets, languages, delivery zones/methods, tax rates, payment methods, order numbering | **Store settings** — dashboard → Settings, or the Admin API. Data, no deploy | `spree-dashboard`, `spree-api-v3` |
| Tune installation-wide limits (password length, JWT expiry, rate limits, cart expiry, webhooks on/off) | **`SPREE_*` env vars** (typed, validated at boot); `Spree.config { \|c\| … }` still works in `config/initializers/spree.rb` | — (docs: `customization/configuration`) |
| Give a record type its own typed settings (a `Brand` "featured" flag, a calculator's rate) | **Model preference** — `preference :featured, :boolean, default: false` on a model with a `preferences` column | `spree-resource` |
| Veto an operation (purchase limits, region policy, B2B eligibility) | **Workflow `validate` hook** — `Spree.hooks.register('carts.add_item.validate', 'MyApp::CheckLimit')`, handler calls `workflow.reject!` | `spree-workflows` |
| Run code *inside* a core flow (after finalize, before cancel, feed pricing/provider context) | **Workflow lifecycle / context hook** — `carts.complete.after_finalize`, `orders.cancel.before_cancel`, `set_*_context` | `spree-workflows` |
| React *after* something happened in your own app (index, sync, email, audit) | **Event subscriber** — `Spree::Subscriber` on `order.placed`, `product.updated`… | `spree-events-webhooks` |
| Tell an external system something happened, no Ruby | **Webhook endpoint** — dashboard → Settings → Webhooks, or Admin API | `spree-events-webhooks` |
| Require something before checkout completes (PO number, phone, age check) or add a checkout step | **`Spree::Checkout::Registry.add_requirement` / `register_step`** — surfaces in the Cart API `requirements[]` | `spree-checkout` |
| Replace how tax, delivery rates, fulfillment, search, pricing, inventory, payouts, digital delivery or payments work | **Provider** — register a class (`Spree.tax_providers`, `Spree.delivery_rate_providers`, `Spree.search_provider = …`, `Spree.payment_methods`, …) and select it on the store/market/method | `spree-providers`, `spree-taxes`, `spree-payments` |
| Sign customers/staff in with your own IdP or token | **Auth strategy** — `Spree.store_authentication_strategies.add(:idp, MyApp::Auth::IdpStrategy)` (also `admin_`/`seller_`) | `spree-auth-permissions` |
| Store extra merchant-facing data (material, care instructions, gift message) | **Custom fields** — `CustomFieldDefinition` + `record.set_custom_field('custom.material', 'Cotton')`; typed, filterable, `storefront_visible` | `spree-catalog` |
| Store integration/machine data (ERP id, UTM source, sync state) | **`metadata`** — schemaless JSON, merge semantics, write-only in Store API, readable in Admin API | `spree-api-v3` |
| Make an attribute filterable/sortable via `q[...]` | **`Spree.ransack.add_attribute / add_association / add_scope`** | `spree-api-v3` |
| Add or drop an address rule (PO boxes, phone format) | **`Spree.validators.addresses.register / unregister`** (from `config.to_prepare`) | `spree-customization` (below) |
| Make a new column writable through the Admin API | **`Spree::Product.additional_permitted_attributes += [:brand_id]`** | `spree-resource` |
| Gate a new resource behind staff roles / API key scopes | **`Spree.permissions.register_scope(:brands, group: :catalog, resources: -> { [Spree::Brand] })`** → `read_brands` / `write_brands` | `spree-auth-permissions` |
| Add a whole new model + Admin/Store endpoint | **`spree generate api_resource Brand …`** | `spree-resource` |
| Add a status to a core model | **`Spree::Return.add_status('on_hold', after: 'approved')`** + your own workflow to move records there | `spree-workflows` |
| Change what a core flow fundamentally does | **Dependency swap** — `Spree::Dependencies.cart_add_item_workflow = 'MyApp::Carts::AddItem'` | `spree-dependencies` |
| Add an association, scope or helper method to a core model | **Decorator** (`spree generate model_decorator Spree::Product`) — last resort | `spree-decorators` |
| Add admin screens, fields, columns, nav items | **Dashboard plugin** in `apps/dashboard/src/plugins.ts` (`defineDashboardPlugin`) | `spree-dashboard`, `spree-dashboard-plugins` |
| Share any of the above across apps | **Extension gem** (Rails engine) + optional dashboard plugin (`spree plugin new`) | `spree-extensions` |

### Hook, event or dependency?

1. **Must you block or change the outcome?** → workflow hook. Only `validate` (and `before_cancel`) hooks can stop a flow, and they run before money moves.
2. **Do you just need to know it happened?** → event subscriber (in-app) or webhook (external). Decoupled, async by default, survives upgrades untouched.
3. **Must the flow do something fundamentally different?** → dependency swap — and accept that you now own that class across upgrades.

## Worked examples

### Block checkout for a region — validate hook

```ruby
# server/config/initializers/spree.rb
Spree.hooks.register('carts.complete.validate', 'MyApp::RegionPolicy')

# server/app/services/my_app/region_policy.rb
module MyApp
  class RegionPolicy
    def call(workflow)
      return unless workflow.cart.ship_address&.country_code == 'KP'

      workflow.reject!('We cannot deliver to this region')
    end
  end
end
```

Hook keys are validated at boot (`Spree::Hooks::UnknownHookError` on a typo). Handlers are stored as class-name strings, so registration is reload-safe. Several handlers may share a key — the first `reject!` wins.

### Push placed orders to an ERP — event subscriber

```bash
spree generate subscriber ErpOrderSync order.placed   # creates the class AND registers it
```

```ruby
# server/app/subscribers/erp_order_sync_subscriber.rb
class ErpOrderSyncSubscriber < Spree::Subscriber
  subscribes_to 'order.placed'

  def handle(event)
    order = Spree::Order.find_by_prefix_id(event.payload['id'])
    MyApp::Erp.push(order) if order
  end
end
```

Subscribers are not auto-discovered — without the generator, add `Spree.subscribers << ErpOrderSyncSubscriber` yourself.

### Require a PO number for B2B carts — checkout requirement

```ruby
Spree::Checkout::Registry.add_requirement(
  step: :payment,
  field: :po_number,
  message: 'PO number is required',
  satisfied: ->(cart) { cart.metadata['po_number'].present? },
  applicable: ->(cart) { cart.company.present? }
)
```

The requirement appears in the Cart API `requirements` array, so the storefront renders it without duplicating the rule, and `Carts::Complete` refuses to finish until it is satisfied.

### Add a `brand_id` to products — resource + permitted attribute + decorator

```bash
spree generate api_resource Brand name:string
spree generate migration AddBrandIdToSpreeProducts brand_id:bigint:index
spree migrate
```

```ruby
# server/config/initializers/spree.rb
Rails.application.config.to_prepare do
  Spree::Product.additional_permitted_attributes += [:brand_id]   # += — the default is frozen
  Spree::Product.storefront_ransackable_associations |= %w[brand]  # Store API filters follow only this list
end
Spree.ransack.add_association(Spree::Product, :brand)            # Admin API filters
Spree.permissions.register_scope(:brands, group: :catalog, resources: -> { [Spree::Brand] })

# server/app/models/spree/product_decorator.rb — structural addition, the one legit decorator job
module Spree
  module ProductDecorator
    def self.prepended(base)
      base.belongs_to :brand, class_name: 'Spree::Brand', optional: true
    end
  end
  Product.prepend(ProductDecorator)
end
```

If the data is merchant-editable and doesn't need its own table, a **custom field** is less work than all of the above.

### Relax a shipped address rule — validator registry

```ruby
# server/config/initializers/spree.rb
Rails.application.config.to_prepare do
  Spree.validators.addresses.register(MyApp::PostBoxValidator)          # an ActiveModel::Validator
  Spree.validators.addresses.unregister(Spree::Addresses::PhoneValidator)
end
```

Several rules are also plain store preferences (`address_requires_phone`, `company_field_enabled`, `disable_sku_validation`) — check those first. There is no general validator registry for other models: add a model validation with a decorator; veto *operations* with a `validate` hook.

### Replace cart add-to-cart logic — dependency swap

```ruby
Spree::Dependencies.cart_add_item_workflow = 'MyApp::Carts::AddItem'   # subclass Spree::Carts::AddItem
```

Keys end in `_workflow` for workflows (`carts_complete_workflow`, `order_cancel_workflow`, `cart_recalculate_totals_workflow`, `fulfillment_update_workflow`, …) and `_service` for plain services (`order_update_statuses_service`). Prefer a hook when you only need to *add* behavior.

## Anti-patterns

- **Overriding `finalize!`, `after_finalize`, cancel or other lifecycle methods in a decorator** → register a hook (`carts.complete.after_finalize`, `orders.cancel.after_cancel`). There are no state machines left to hook into — `state_machine` blocks, `after_transition` and `checkout_flow` don't exist.
- **`after_save` / `after_commit` callbacks added to Spree models for side effects** → event subscriber.
- **`clear_validators!`** → wipes every validation on the model, including other extensions'. Use store preferences, `Spree.validators.addresses.unregister`, or a targeted decorator.
- **`Spree::Product.additional_permitted_attributes << :brand_id`** → raises `FrozenError`. Always `+=`.
- **Writing a legacy `*_service` dependency key** (`cart_add_item_service`, `carts_complete_service`) → the write is stashed and ignored with a warning; use the `*_workflow` key.
- **Setting `payment_status` / `fulfillment_status` directly** → they're derived by `Spree::Orders::UpdateStatuses`; act on payments/fulfillments instead.
- **Enums or a state machine for a new status field** → `include Spree::HasStatus; has_status :a, :b, default: :a`, transitions in a workflow.
- **Admin changes via Rails views/partials** → the admin is the React dashboard; use a dashboard plugin.
- **A private extension gem for one app** → put code in `server/app/`; gems are for sharing across apps.
- **Forking Spree** → walk this table first; the seam almost certainly exists.

## Where to read further

- `node_modules/@spree/docs/dist/developer/customization/quickstart.md` — the canonical recommended order
- `…/customization/{configuration,workflows,dependencies,decorators,validations,metadata,model-preferences,permissions,checkout,api}.md`
- `…/providers/overview.md` and `…/how-to/custom-*.md` for each provider contract
- `…/dashboard/customization/quickstart.md` for admin UI
- Online: https://spreecommerce.org/docs/developer/customization/quickstart

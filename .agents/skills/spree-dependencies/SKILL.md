---
name: spree-dependencies
description: Use when the user wants to replace a whole Spree 6 service, workflow or API serializer with their own class — swap the add-to-cart workflow, checkout completion, cart totals recalculation, order status writer, storefront access policy, or an API v3 serializer. Common phrasings include "Spree.dependencies", "Spree::Dependencies", "swap a service", "replace Spree::Carts::AddItem", "cart_add_item_workflow", "carts_complete_workflow", "cart_recalculate_totals_workflow", "storefront_access_policy_class", "override an API serializer", "Spree.api.product_serializer", "dependency injection in Spree", "spree:dependencies:list", "spree:dependencies:overrides", "my cart_add_item_service override stopped working", "what can I swap". Covers when a swap is justified (usually a workflow hook is better), subclassing a shipped workflow, service vs workflow seams, legacy *_service keys that are stashed not applied, API serializer seams, per-controller overrides, and the introspection rake tasks.
---

# Spree Dependencies (swapping whole classes)

> Commands use the Spree CLI (`spree …`). On a classic Rails app without the CLI, run `bin/rails …` / `bundle exec rake …` from the app root. Paths assume the Rails app lives in `server/`.

`Spree.dependencies` lets you replace a core class — a service, a workflow, a policy, a serializer — with your own. Spree's code calls `Spree.cart_add_item_workflow.call(...)`, never `Spree::Carts::AddItem.call(...)`, so your replacement runs everywhere: Store API, Admin API, dashboard, jobs, imports.

## First: do you actually need to replace the class?

Replacing a class means **you own a copy** that must be re-synced with every Spree release. Most reasons people swap a class are covered by a workflow hook, which survives upgrades:

| You want to… | Use instead of a swap |
|---|---|
| Block add-to-cart / checkout / a cancel / a return | `validate` hook — `Spree.hooks.register('carts.add_item.validate', 'MyStore::Rule')` |
| Add data to tax or promotion calculation | Context hook (`carts.recalculate_totals.set_tax_line_context`, `carts.recalculate.set_promotion_context`) |
| Write rows alongside the change, atomically | Lifecycle hook (`carts.add_item.after_item_added`, `carts.complete.after_finalize`) |
| Sync to ERP / send email / reindex | Event subscriber (`spree-events-webhooks`) |
| Add a checkout requirement | `Spree::Checkout::Registry.add_requirement` (`spree-checkout`) |
| Add a field to an API response | Subclass the serializer (below) — a small, legitimate swap |

See the `spree-workflows` skill for the hook catalog. Swap a class only when you are genuinely replacing *how* something is computed (a different merge strategy, a custom buy-box ranking, a B2B access policy, a commission model).

## The seams

`Spree::Core::Dependencies::INJECTION_POINTS_WITH_DEFAULTS` (in `spree_core`, `lib/spree/core/dependencies.rb`) defines **167 core injection points**; **106** of them are `*_workflow` keys. `Spree::Api::ApiDependencies::INJECTION_POINTS_WITH_DEFAULTS` (`spree_api`, `lib/spree/api/dependencies.rb`) holds **272 API points — serializers only**: 91 Store (`product_serializer`), 139 Admin (`admin_product_serializer`), 42 Seller (`seller_*_serializer`). (Counts from the 6.0 source; run `spree rake spree:dependencies:list` for your version.)

Naming tells you the contract:

| Suffix | Base class | You override |
|---|---|---|
| `*_workflow` | `Spree::Workflow` subclass | `#perform(**keywords)` — never `#call` |
| `*_service` | plain class with `prepend Spree::ServiceModule::Base` | `#call(**keywords)` |
| `*_class`, `*_finder`, `*_handler`, others | varies — read the default | as documented on the default |

Frequently swapped:

| Key | Default | Notes |
|---|---|---|
| `cart_add_item_workflow` | `Spree::Carts::AddItem` | `perform(variant:, cart:, quantity:, metadata:, options:, price:)` |
| `cart_upsert_items_workflow` | `Spree::Carts::UpsertItems` | set-quantity / remove / bulk |
| `cart_recalculate_workflow` | `Spree::Carts::Recalculate` | full reprice (delivery, promotions, totals) |
| `cart_recalculate_totals_workflow` | `Spree::Carts::RecalculateTotals` | the single totals seam (discount/fee/tax rows → sums) |
| `order_recalculate_totals_workflow` | `Spree::Orders::RecalculateTotals` | post-placement re-sum twin |
| `cart_merge_workflow` | `Spree::Carts::Merge` | guest→customer cart merge |
| `carts_complete_workflow` | `Spree::Carts::Complete` | checkout completion — prefer `carts.complete.*` hooks |
| `order_complete_workflow` / `order_cancel_workflow` | `Spree::Orders::Complete` / `::Cancel` | |
| `order_update_statuses_service` | `Spree::Orders::UpdateStatuses` | sole writer of `payment_status` / `fulfillment_status` |
| `fulfillment_create_workflow` / `fulfillment_update_workflow` | `Spree::Fulfillments::Create` / `::Update` | |
| `payment_process_workflow`, `payment_capture_workflow`, `payment_void_workflow`, `refund_create_workflow` | `Spree::Payments::*`, `Spree::Refunds::Create` | |
| `return_create_workflow` … `claim_*_workflow` | `Spree::Returns::*`, `Exchanges::*`, `Claims::*` | |
| `storefront_access_policy_class` | `Spree::Storefront::AccessPolicy` | Store API record visibility (ownership + guest tokens); the B2B seam |
| `products_for_context_service` | `Spree::Products::ForContext` | catalog narrowing for a buyer |
| `product_buy_box_service` | `Spree::Products::SelectBuyBox` | marketplace: which variant leads |
| `purchase_amount_due_at_checkout_service` | `Spree::Purchases::AmountDueAtCheckout` | deposits / net terms |
| `tax_resolve_exemptions_service` | `Spree::Tax::ResolveExemptions` | exemption evidence for the tax provider |
| `reporting_adapter` | `Spree::Reporting::Adapters::Live` | |
| `search_product_presenter` | `nil` (set by a search gem) | |

`ability_class` (`Spree::Ability`) builds every staff CanCanCan ability — Admin API JWT staff, the Seller API, imports/exports. Subclass `Spree::Ability`, keep `initialize(user, options = {})` (`options[:store]`, `options[:resource]`), call `super`, then add rules. It works behind the permission-key gate, and secret API keys (`Spree::ApiKeyAbility`) never consult it. See `spree-auth-permissions`.

## Replacing a workflow

Subclass the shipped workflow and override `perform` with the same keywords. `perform`'s signature is the contract (Ruby raises `ArgumentError` on a mismatch); a bare `super` runs the whole parent flow and returns its `Result`.

```ruby
# server/app/workflows/my_store/carts/add_item.rb
module MyStore
  module Carts
    class AddItem < Spree::Carts::AddItem
      # REQUIRED: without this the subclass dispatches 'my_store.carts.add_item.*'
      # and every handler registered on 'carts.add_item.*' silently stops firing.
      workflow_key 'carts.add_item'

      def perform(variant:, cart: nil, **rest)
        result = super                       # full Spree flow; a failure raises through, so code below runs only on success

        external_step :notify_recommendations # network I/O — outside any transaction
        result                                # Result#value is the line item
      end

      private

      def notify_recommendations
        MyStore::Recommendations.item_added(cart_id: cart.prefixed_id, sku: line_item.sku)
      end
    end
  end
end
```

```ruby
# server/config/initializers/spree.rb
Spree.cart_add_item_workflow = MyStore::Carts::AddItem
```

Rules for workflow replacements:

- **Override `perform`, never `call`.** `Spree::Workflow#call` owns instrumentation, `failure`/`halt!` handling and compensation.
- **Keep `workflow_key`** pointing at the parent's key (see above). This is the most common silent breakage.
- To change one piece, override the private step method (e.g. `add_to_line_item`) and call `super` — but step names are internals and can change between releases; a hook is safer.
- Return a `Spree::ServiceModule::Result` (`super`'s, or `success(value)`); a non-Result return is wrapped in `success`.
- Callers of `Spree.cart_add_item_workflow` expect the parent's `Result#value` type (a line item here). Don't change it.
- Workflows collaborate through other seams (`step :recalculate, with: -> { Spree.cart_recalculate_workflow }`), so swapping one seam affects every flow that delegates to it.

## Replacing a plain service

Same pattern, overriding `call`:

```ruby
module MyStore
  class CartUpdate < Spree::Carts::Update
    def call(cart:, params:)
      result = super
      MyStore::ErpSync.enqueue(result.value.prefixed_id) if result.success?
      result
    end
  end
end

Spree.carts_update_service = MyStore::CartUpdate
```

Inherit from the default so you keep `Spree::ServiceModule::Base` wiring (class-level `.call`, `success`/`failure`). Always return a `Result`.

## Legacy `*_service` keys are stashed, not applied

Seams that became workflows still accept the old names so apps boot — but **assigning one does nothing**. The value is stored, a deprecation warning says "NO LONGER CONSULTED by Spree — the override was not applied", and Spree keeps calling the workflow. A class written against the old service contract (`call(order:, …)` with `run` steps) isn't interchangeable with the workflow contract. Port it: subclass the workflow, move logic into `perform`/hooks, assign the new key. These names are removed in 6.1.

| Legacy key (stash-only) | Assign this instead | Default |
|---|---|---|
| `cart_add_item_service` | `cart_add_item_workflow` | `Spree::Carts::AddItem` |
| `cart_recalculate_service` | `cart_recalculate_workflow` | `Spree::Carts::Recalculate` |
| `cart_merge_strategy` | `cart_merge_workflow` | `Spree::Carts::Merge` |
| `carts_complete_service` | `carts_complete_workflow` | `Spree::Carts::Complete` |
| `carts_upsert_items_service` | `cart_upsert_items_workflow` | `Spree::Carts::UpsertItems` |
| `order_complete_service` | `order_complete_workflow` | `Spree::Orders::Complete` |
| `order_cancel_service` | `order_cancel_workflow` | `Spree::Orders::Cancel` |
| `fulfillment_create_service` | `fulfillment_create_workflow` | `Spree::Fulfillments::Create` |
| `shipment_update_service`, `fulfillment_update_service` | `fulfillment_update_workflow` | `Spree::Fulfillments::Update` |
| `payments_handle_webhook_service` | `payments_handle_webhook_workflow` | `Spree::Payments::HandleWebhook` |
| `gift_card_apply/remove/redeem_service` | `gift_card_apply/remove/redeem_workflow` | `Spree::GiftCards::*` |

Pure renames (applied, with a warning): `checkout_add_store_credit_service` → `store_credit_apply_service`, `checkout_remove_store_credit_service` → `store_credit_remove_service`; API `stock_item_serializer` → `stock_level_serializer`, `digital_serializer` → `digital_asset_serializer` (and `admin_` twins).

**Removed keys** (assigning raises `NoMethodError` at boot): `carts_validate_service` (completion validation is `Spree::Checkout::Requirements` + `carts.complete.validate`), `checkout_next_service`, `checkout_update_service`, `checkout_complete_service`, `checkout_select_shipping_method_service`, `checkout_get_shipping_rates_service`, `cart_create_service`, `cart_update_service`, `cart_estimate_shipping_rates_service`, `cart_change_currency_service`, `line_item_*_service`, `shipment_*_service`, `account_*_service`, and the legacy finders/sorters (`products_finder`, `taxon_finder`, `variant_finder`, …). Carts are created/updated via `carts_create_service` / `carts_update_service`; checkout progression is `checkout_advance_service`. Coming from 5.x? See `spree-upgrade-5-to-6`.

## API serializers

API dependencies are **serializers only** — there are no per-API service keys; every endpoint calls the core `Spree.<key>` seams directly.

```ruby
# server/app/serializers/my_store/product_serializer.rb
module MyStore
  class ProductSerializer < Spree::Api::V3::ProductSerializer   # Alba resource
    typelize brand_name: [:string, nullable: true]
    attribute :brand_name do |product|
      product.brand&.name
    end
  end
end

# config/initializers/spree.rb
Spree.api.product_serializer       = 'MyStore::ProductSerializer'        # Store API
Spree.api.admin_product_serializer = 'MyStore::Admin::ProductSerializer' # Admin API — separate key
```

- Store and Admin keys are independent. `Spree::Api::V3::Admin::ProductSerializer` inherits the *shipped* `Spree::Api::V3::ProductSerializer` by constant, so swapping `product_serializer` does **not** change Admin output — subclass and swap both if you need the field in both.
- Nested associations often resolve through the accessor (`one :product, resource: proc { Spree.api.product_serializer }`), so your class is used there too.
- Adding typed fields for `@spree/sdk` types: `typelize` (see `spree-typescript-sdk`).

## Per-controller overrides

To change one endpoint only, decorate the API controller's named hook (`serializer_class`, `scope`, `collection_includes`, `model_class`, `resource_permitted_attributes`):

```ruby
# server/app/controllers/spree/api/v3/store/products_controller_decorator.rb
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

There are no per-controller `*_service` hooks — controllers call the global seams. See `spree-decorators`.

## Using seams from your own code

```ruby
Spree.cart_add_item_workflow.call(cart: cart, variant: variant, quantity: 1)   # resolves overrides
Spree.api.cart_serializer.new(cart, params: { store: current_store }).to_h

Spree::Carts::AddItem.call(...)   # ❌ bypasses any override
```

Extensions especially must go through the accessor so they compose with the host app's overrides.

Syntax: `Spree.<key> = MyClass` (recommended — fails immediately on a typo'd constant), `Spree.dependencies { |d| d.<key> = MyClass }` for several, or the legacy `Spree::Dependencies.<key> = 'MyClass'` (string; resolved lazily, still supported).

## Inspecting overrides

```bash
spree rake spree:dependencies:list        # every seam with its current value, [OVERRIDDEN] marked
spree rake spree:dependencies:list | grep workflow
spree rake spree:dependencies:overrides   # only overrides: default -> current (file:line that set it)
spree rake spree:dependencies:validate    # constantize every seam; exits 1 on NameError — good CI check
```

`overrides` is the first thing to run on an inherited project. Programmatic equivalents: `Spree::Dependencies.current_values`, `.overridden?(:cart_add_item_workflow)`, `.override_info(:cart_add_item_workflow)`, `.validate!`; `Spree::Api::Dependencies` for the API side. Legacy stash-only writes don't appear as overrides — grep initializers for `_service =` after upgrading.

## Gotchas

- **Load order:** overrides go in `config/initializers/spree.rb`. If two gems set the same key, the last assignment wins; check with `spree:dependencies:overrides`.
- **Swapped workflow lost its hooks** → missing `workflow_key` (see above).
- **Override "does nothing" after upgrade** → you're assigning a legacy `*_service` key; look for the "NO LONGER CONSULTED" deprecation in the boot log.
- **Dropping behavior:** a replacement that skips `super` must re-implement stock reservations, pricing providers, availability checks, recalculation and events. Read the parent's `perform` in full first.
- **`ArgumentError` at call time** → your `perform` signature doesn't accept a keyword callers pass. Accept `**rest` and forward it.

## Where to read further

- `node_modules/@spree/docs/dist/developer/customization/dependencies.md` (https://spreecommerce.org/docs/developer/customization/dependencies) — note: parts of the published page still show API v2 `storefront_*` keys; the source constants are authoritative.
- `node_modules/@spree/docs/dist/developer/customization/workflows.md` — hooks, the preferred alternative
- Source: `spree_core` `lib/spree/core/dependencies.rb` (`INJECTION_POINTS_WITH_DEFAULTS`, `LEGACY_WORKFLOW_KEYS`, `LEGACY_SERVICE_KEYS`, `RENAMED_SERVICE_KEYS`), `spree_api` `lib/spree/api/dependencies.rb`, `lib/tasks/dependencies.rake`
- Related skills: `spree-workflows`, `spree-customization`, `spree-decorators`, `spree-extensions`

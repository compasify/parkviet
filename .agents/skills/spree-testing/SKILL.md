---
name: spree-testing
description: Use when the user is writing or running automated tests for a Spree 6 app or extension — model specs, workflow/hook specs, subscriber specs, API v3 controller/request specs, factories, and dashboard (Vitest/Playwright) tests. Covers RSpec + Factory Bot (not Minitest/fixtures), spree_dev_tools, Spree's factories (:cart, :cart_ready_to_complete, :completed_order_with_totals …), the 'API v3 Store' / 'API v3 Admin' shared contexts, Spree::Current.store in tests, `spree rspec`, and common failures. Common phrasings include "test my Spree model", "Spree spec", "Spree factories", "spree_dev_tools", "include_context API v3", "test a workflow hook", "test a subscriber", "OrderWalkthrough", "Store must exist", "spree rspec", "dashboard tests".
---

# Spree Testing

| Layer | Tooling |
|---|---|
| Rails app (`server/`) | RSpec + Factory Bot + `spree_dev_tools` — not Minitest, not fixtures |
| Dashboard (`apps/dashboard`) | Vitest (unit) + Playwright (e2e), preconfigured |
| Storefront (`apps/storefront`) | whatever the Next.js app ships with |

Spree has no server-rendered admin or storefront, so there are no Capybara feature specs to write for Spree screens. Browser coverage belongs to Playwright against the dashboard/storefront.

## Setup

Projects from `create-spree-app` arrive with RSpec configured. For a classic app:

```ruby
# Gemfile
group :development, :test do
  gem 'spree_dev_tools'
end
```

```bash
bin/rails g spree_dev_tools:install
```

The generator runs `rspec:install` if needed and writes `spec/support/{spree,factory_bot,database_cleaner,active_job}.rb`. `spec/support/spree.rb` loads:

- Spree's factories (`spree/testing_support/factories`) + FactoryBot syntax
- `spree/testing_support/store` — a default USD store (`@default_store`) created before each group and cleaned after each example
- `Spree::TestingSupport::Preferences` (`reset_spree_preferences` before each example)
- `spree/api/testing_support/v3/base` — the API v3 shared contexts and JWT helper
- `json_response` for `type: :request` and `type: :controller`
- `ActiveJob::TestHelper`, DatabaseCleaner (transaction strategy)

Factory decorators in `spec/factories/spree/**/*_decorator.rb` are loaded automatically.

## Running

```bash
spree rspec                                       # whole suite, in the web container, RAILS_ENV=test
spree rspec spec/models/spree/brand_spec.rb:15    # file / line; any rspec flags pass through
bundle exec rspec …                               # classic app, from the app root
```

`spree rspec` works from a cold stack (it falls back to a one-off container). After adding migrations in a classic app: `bin/rails db:test:prepare`.

## Factories you'll use

Read the source when in doubt: `$(bundle show spree_core)/lib/spree/testing_support/factories/`.

| Need | Factory |
|---|---|
| Customer / staff | `:customer` (alias `:user`), `:customer_with_addresses`, `:admin_user` (gets the admin role; `:without_admin_role` trait) |
| Product | `:product` (default variant priced 19.99 in store currency), `:product_in_stock`, `:product_with_option_types`, `:digital_product`; transients `price:`, `compare_at_price:`, `currency:` |
| Variant | `:variant` (same price transients), `trait :with_no_price`, `:on_demand_variant` |
| Cart (`Spree::Cart`) | `:cart`, `:cart_with_line_items` (`line_items_count:`), `:cart_ready_for_delivery` (addresses + delivery proposals), `:cart_ready_to_complete` (payment covers total) |
| Order (`Spree::Order`) | `:order` (draft), `:order_with_line_items`, `:completed_order_with_totals` (placed), `:completed_order_with_pending_payment`, `:order_ready_to_ship`, `:shipped_order` |
| Fulfillment | `:fulfillment` (alias `:shipment`), `:delivery_method` (alias `:shipping_method`), `:free_delivery_method`, `:pickup_delivery_method`, `:digital_delivery_method` |
| Inventory | `:stock_location`, `:stock_level` |
| Payments | `:payment`, `:check_payment_method`, `:credit_card_payment_method`, `:store_credit_payment_method` |
| Catalog | `:category`, `:collection`, `:automatic_collection`, `:custom_field_definition` |
| Returns | `:return`, `:approved_return`, `:received_return` |
| API / permissions | `:api_key` (`:publishable`, `:secret` → scopes `['write_all']`, `:revoked`), `:role` (`permissions: %w[read_orders]`) |

Checkout state comes from factories, not walkthroughs. `OrderWalkthrough.up_to(...)` is deprecated (removed in 6.1) — use `:cart_ready_for_delivery`, `:cart_ready_to_complete` or `:completed_order_with_totals`.

Carts and orders are different models: a cart has no status; completion creates an `Order` with `status` (`draft`/`placed`/`canceled`). To exercise real completion:

```ruby
cart = create(:cart_ready_to_complete)
result = Spree.carts_complete_workflow.call(cart: cart)

expect(result).to be_success
order = result.value
expect(order).to be_placed
```

Prices are per currency — there is no `variant.price`. Assert with `variant.price_in('EUR')&.amount` / `variant.amount_in('EUR')`; set with `create(:variant, price: 10, currency: 'EUR')` or `variant.set_price('EUR', 10)`.

Your own resources: `spree generate api_resource Brand …` writes `spec/factories/spree/brand_factory.rb` plus Store/Admin controller specs.

## Store context and required associations

- **Set `Spree::Current.store`** in specs that run code outside a request (workflows, jobs, services) when the store isn't the default one. `Spree::Current.store` falls back to `Spree::Store.default`, which is `nil` if no default store exists — store-scoped records then fail with **"Store must exist"**. Groups tagged `without_global_store: true` skip the default store entirely.
- **`belongs_to` is required** on Spree models. A factory for your model must build every non-optional association; failures read "`<Assoc> must exist`" (not "can't be blank"). If blank is legitimate, declare `optional: true` on the association.
- `Spree::Current` is an `ActiveSupport::CurrentAttributes`; rspec-rails resets it between examples, so set it inside the example (or a `before`).
- **Assigning `Spree::Current.store` arms `Spree::StoreScopeGuard`** for the rest of the example: any `SELECT` on a store-owned table that's neither store-scoped nor id-filtered is logged (default `log` mode), or raises `Spree::StoreScopeGuard::UnscopedQueryError` with `SPREE_STORE_SCOPE_GUARD=raise` (what Spree's own API suite uses — worth turning on in CI). API v3 request/controller specs are always guarded. Fix the query (`store.products…`), or wrap a deliberately global lookup in `Spree::StoreScopeGuard.skip { … }`.
- The extension dummy app (`rake test_app`) configures Active Record encryption keys, so encrypted columns (webhook secrets, identity tokens) behave as in production. A host app's test env needs its own keys for the same behavior.

## Model specs

```ruby
require 'rails_helper'

RSpec.describe Spree::Brand, type: :model do
  it 'rejects a duplicate slug in the same store' do
    create(:brand, slug: 'nike')
    expect(build(:brand, slug: 'nike')).not_to be_valid
  end
end
```

Prefer `build` when persistence isn't needed. Test your custom logic — not Rails presence validations, strong params, or plain associations.

## Workflow and hook specs

Workflows return a result: `success?`, `value`, `error`.

```ruby
RSpec.describe MyApp::RequirePoNumber do        # a 'carts.complete.validate' handler
  after { Spree.hooks.unregister('carts.complete.validate', described_class) }

  it 'vetoes completion without a PO number' do
    Spree.hooks.register('carts.complete.validate', described_class)
    cart = create(:cart_ready_to_complete)

    result = Spree.carts_complete_workflow.call(cart: cart)

    expect(result).not_to be_success
    expect(result.error.to_s).to include('PO number')
  end
end
```

Unregister only what you registered — `Spree.hooks.clear!` also removes core's own registrations (e.g. the return-eligibility validator) for the rest of the process. Hook keys come from the workflow (`hooks :validate, …`); an unknown key fails boot when eager loading.

To unit-test a handler in isolation, pass a double or the real workflow instance it reads from (`flow.cart`, `flow.reject!(msg)`).

## Subscriber specs

The subscriber generator writes a spec; the pattern:

```ruby
RSpec.describe OrderPlacedSubscriber do
  let(:order) { create(:completed_order_with_totals) }
  let(:event) { Spree::Event.new(name: 'order.placed', payload: { 'id' => order.prefixed_id }) }

  it 'submits the order' do
    expect(WarehouseClient).to receive_message_chain(:new, :submit).with(order)
    described_class.new.handle(event)
  end
end
```

Call `handle` directly — don't go through the bus to test your handler. To assert that something **publishes** an event:

```ruby
expect(Spree::Events).to receive(:publish).with('brand.created', anything, anything).and_call_original
brand.save!
```

For models with `publishes_lifecycle_events`, reuse Spree's shared example:

```ruby
require 'spree/testing_support/lifecycle_events'

RSpec.describe Spree::Brand do
  it_behaves_like 'lifecycle events'           # factory: :brand, event_prefix: 'brand' inferred
end
```

If your suite globally disables events (`Spree::Events.disable!`, as Spree's own suite does), re-enable per example with `Spree::Events.enable { … }`.

## API v3 controller specs

Shared contexts (from `spree/api/testing_support/v3/base`, already loaded by `spree_dev_tools`):

| Context | Provides |
|---|---|
| `'API v3 Store'` | `store`, publishable `api_key`, `api_key_headers`, `user` (customer), `jwt_token`, `bearer_headers`; stubs `current_store` |
| `'API v3 Store guest'` / `'API v3 Store authenticated'` | above + `headers` (key only / key + customer JWT) |
| `'API v3 Admin'` | `store`, `secret_api_key` (`write_all`), `admin_user`, `admin_jwt_token`, `bearer_headers` |
| `'API v3 Admin authenticated'` | above + `headers` |
| `'API v3 Admin with custom permissions'` | set `let(:custom_permissions) { %w[read_orders] }` — staff JWT with only those keys |
| `'API v3 Seller'` / `'API v3 Seller authenticated'` | seller, seller user, JWT, `X-Spree-Seller-Id` header |

Shared examples: `'returns 200 OK'`, `'returns 201 Created'`, `'returns 204 No Content'`, `'returns 401 Unauthorized'`, `'returns 403 Forbidden'`, `'returns 404 Not Found'`, `'returns 422 Unprocessable Entity'`, `'requires API key'`, `'requires authentication'` (all expect a `subject`).

```ruby
RSpec.describe Spree::Api::V3::Admin::BrandsController, type: :controller do
  render_views
  routes { Spree::Core::Engine.routes }        # API controllers are mounted by the engine
  include_context 'API v3 Admin authenticated'
  before { request.headers.merge!(headers) }

  let!(:brand) { create(:brand) }

  describe 'GET #index' do
    subject { get :index, params: { q: { name_cont: brand.name[0, 3] } }, as: :json }

    it_behaves_like 'returns 200 OK'

    it 'returns prefixed ids' do
      subject
      expect(json_response['data'].map { |b| b['id'] }).to include(brand.prefixed_id)
    end
  end

  context 'with a role lacking write_brands' do
    include_context 'API v3 Admin with custom permissions'
    let(:custom_permissions) { %w[read_brands] }

    subject { post :create, params: { name: 'X' }, as: :json }

    it_behaves_like 'returns 403 Forbidden'
  end
end
```

- Always assert on prefixed IDs (`brand.prefixed_id`), never integer IDs.
- The generator's specs use exactly this shape — extend them rather than starting over.
- Permission keys (`read_<resource>`/`write_<resource>`) for your own resources exist only after `Spree.permissions.register_scope` — see `spree-auth-permissions`.

## Dashboard tests

```bash
cd apps/dashboard
pnpm test          # vitest run
pnpm test:e2e      # playwright test (testDir ./e2e)
```

Unit-test the logic between UI and API — query keys (store-scoped via `withStoreScope`), form → payload mappers, permission predicates, table state → Ransack params. Don't unit-test components or thin SDK wrappers. One Playwright spec per feature proves the layers connect: create data via the Admin API, log in, navigate from the sidebar (routes are store-scoped), assert visible text. Suffix test data with `Date.now()` — e2e runs share a database. Details: `spree-dashboard-plugins`.

## Extension (gem) testing

Extensions test against a generated dummy app:

```bash
bundle exec rake test_app      # regenerate spec/dummy after schema changes
bundle exec rspec
```

`test_app` / `parallel_setup` exist only in engines and extensions, not in apps.

## Common failures

| Symptom | Cause / fix |
|---|---|
| `Store must exist` / `Validation failed: Store must exist` | No default store in this context — tag without `without_global_store`, or set `Spree::Current.store` / pass `store:` |
| `<Assoc> must exist` from your factory | Required `belongs_to`; build the association or mark it `optional: true` |
| `NoMethodError: price` on variant | Prices are per currency — `price_in(currency)` / `amount_in(currency)` |
| `undefined method 'state'` / `state_machine` | No state machines — assert `status` (`be_placed`, `status: 'canceled'`) |
| Order factory with `state: 'complete'` | Still supported as a transient, but prefer `:completed_order_with_totals` |
| Wrong currency | Order/cart factories default to `USD`; pass `currency:` |
| Subscriber "never runs" in a spec | Async subscribers only enqueue; call `handle` directly or `perform_enqueued_jobs` |
| `OrderWalkthrough` deprecation warning | Switch to the cart factories |
| Flaky time tests | `Timecop.freeze` / `travel_to` |

## Where to read further

- Testing tutorial: `node_modules/@spree/docs/dist/developer/tutorial/testing.md`
- Factories: `spree_core/lib/spree/testing_support/factories/`
- Shared contexts: `spree_api/lib/spree/api/testing_support/v3/base.rb`
- `spree_dev_tools`: `lib/spree_dev_tools/rspec/support/` and the install generator
- Related skills: `spree-workflows`, `spree-events-webhooks`, `spree-resource`, `spree-auth-permissions`, `spree-dashboard-plugins`

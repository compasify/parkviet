# Spree 5.x → 6.0 grep recipes

Pattern → what it means → what to do. Run from the Rails app root (`server/`, older create-spree-app projects `backend/`, classic apps the repo root) over `app config lib spec db/seeds.rb`, and separately over `apps/storefront`, `apps/dashboard` and any integration repos for the wire-format rows.

Legend: **Removed** = raises `NameError`/`NoMethodError` now. **Deprecated** = still works with a `Spree::Deprecation` warning, removed in 6.1 — fix now anyway.

```bash
# one-liner for any row
grep -rnE "<pattern>" app config lib spec
```

## Checkout, statuses, state machines

| Pattern | Status | Replacement |
|---|---|---|
| `checkout_flow`, `go_to_state`, `insert_checkout_step`, `remove_checkout_step`, `remove_transition` | Removed | `Spree::Checkout::Registry.add_requirement(step:, field:, message:, satisfied:, applicable:)`, `register_step(name:, satisfied:, requirements:, before:/after:)`, `Registry.base_steps` (see **spree-checkout**) |
| `state_machine`, `before_transition`, `after_transition`, `order.state ==`, `.next!`, `.advance` | Removed | No state machines anywhere. Statuses are string `status` columns (`Spree::HasStatus`, `Model.add_status('x', after: 'y')`); transitions are workflows — hook with `Spree.hooks.register('<flow>.<hook>', handler)` or subscribe to events (see **spree-workflows**) |
| `payment_state`, `shipment_state` | Deprecated alias | `payment_status`, `fulfillment_status` — read only; written by `Spree::Orders::UpdateStatuses`. Never assign |
| `q[state_eq]=complete`, `where(state: 'complete')` on orders | Changed | Orders: `status` `draft`/`placed`/`canceled`; API filter `q[status_eq]=placed`. Carts have no status (`completed_at` only) |
| `requirements` keyed on `shipping_method` / `shipping_method_required` (storefront) | Changed, no bridge | `field: 'delivery_method'`, `code: 'delivery_method_required'`; translation key `checkout_requirements.delivery_method_required` |
| `carts_validate_service` | Removed | `Spree::Checkout::Requirements` / `add_requirement` |

## Cart / Order split, completion, totals

| Pattern | Status | Replacement |
|---|---|---|
| `finalize!` | Deprecated | `Spree.order_complete_workflow`; side effects → `order.placed` subscriber or `carts.complete.before_finalize` hook. Re-finalizing is a no-op |
| `order.completed` (event name, webhooks, subscribers) | Deprecated alias until 6.1 | `order.placed` |
| `OrderUpdater`, `CartUpdater`, `order.updater`, `update_with_updater!` | Deprecated shells | `recalculate_totals!` / `update_statuses!`; the seam is `Spree::Carts::RecalculateTotals` |
| `register_update_hook` | Deprecated, no longer runs at completion | workflow hook or event subscriber |
| `line_item.order`, `payment.order`, `shipment.order` assumed present | Changed | `#owner` (cart **or** order; `cart_id` + `order_id`, exactly one set) |
| Mutating an order after checkout through cart code | Changed | Completed carts are read-only; use order-side services (`Spree::Orders::Discounts::*`, `Orders::Fees::*`, `Orders::Update`) |
| `\bresume!?\b`, `Orders::Resume`, `Fulfillments::Resume`, `order.resumed`, `fulfillment.resumed`, `/resume` endpoints | Removed | Cancel is final; place a new order / create a new fulfillment |
| `remove_out_of_stock_items!` | Deprecated on Order | `Spree::Carts::RemoveOutOfStockItems` |
| `order:` kwarg into cart services | Deprecated | `cart:` |
| `last_incomplete_spree_order`, `user.carts` expecting `Spree::Order` rows | Deprecated / Changed | `customer.carts` now returns open `Spree::Cart` records (scope with `.where(store: …)`); admin drafts are `customer.orders.drafts`. `last_incomplete_spree_order` returns drafts and is removed in 6.1 |
| `Spree::OrderRouting::Strategy::Legacy` | Removed (falls back to Rules with a warning) | `Spree::OrderRouting::Strategy::Rules`; clear the stored preference |

## Money rows

| Pattern | Status | Replacement |
|---|---|---|
| `Spree::Adjustment`, `.adjustments`, `all_adjustments`, `adjustable`, `Adjuster` | Removed | `Spree::TaxLine`, `Spree::Discount`, `Spree::Fee` (`cart.discounts`, `order.tax_lines`, …) |
| `promo_total` | Deprecated (column renamed) | `discount_total` (Order, LineItem, Fulfillment) |
| `ship_total` | Deprecated | `delivery_total` |
| `item_count` | Deprecated | `total_quantity` |
| `shipping_discount` | Deprecated | `fulfillment_discount` |
| `shipment_total`, `display_shipment_total`, `display_ship_total`, `display_promo_total` | Deprecated | `delivery_total`, `display_delivery_total`, `display_discount_total` |
| `available_payment_methods`, `collect_payment_methods`, `collect_frontend_payment_methods` | Deprecated | `payment_methods` (never includes store credit) |
| `associate_user!`, `.user`, `.user_id` on carts/orders | Deprecated | `associate_customer!`, `customer`, `customer_id` |
| `set_shipments_cost`, `ensure_updated_shipments`, `update_with_updater!`, `all_line_items` | Deprecated | `set_fulfillments_cost`, `ensure_updated_fulfillments`, `recalculate_totals!`, `line_items` |

The deprecated order names in this table (not the removed adjustment API), plus `delivery_required?` / `requires_ship_address?` / `create_proposed_*` / `special_instructions` below is answered by **`Spree::Cart` as well as `Spree::Order`** (`Spree::Purchase::DeprecatedAliases`). 5.x extensions, payment gateway gems especially, call them on what is now a cart. They warn rather than crash until 6.1, so grep your gems' code for them too.
| `private_metadata['typed_adjustments_frozen']` | — | read `metadata['typed_adjustments_frozen']` to find orders the migration refused to convert |

## Catalog, prices, media

| Pattern | Status | Replacement |
|---|---|---|
| `\.master\b`, `is_master`, `master_id`, `variants_including_master` | Removed | `product.default_variant` (real FK `default_variant_id`, a real variant with its own SKU/price/stock) |
| `variant.price`, `product.price`, `price =`, `default_price`, `DefaultPrice`, `enable_legacy_default_price`, `display_price`, `compare_at_price=` | Removed | `price_in(currency)`, `amount_in(currency)`, `set_price(currency, amount, compare_at)`, `price_in(cur).display_amount` |
| `variant.currency`, `product.currency` | Removed | pass the currency explicitly |
| Ransack `default_price_*` | Removed | query `prices` |
| `Spree::Taxon`, `Spree::Taxonomy`, `taxons`, `taxonomy` | Deprecated alias / data-only | `Spree::Category` (tree, store-owned) and `Spree::Collection` (flat, rule-based); `product.categories`, `product.collections` |
| `Category.for_taxonomy`, `set_store` | Removed | `.for_store`, `#ensure_store` |
| `presentation` on OptionType/OptionValue, `q[presentation_cont]`, `PresentationTranslatable` | Deprecated (instance only; `where(presentation:)` raises) | `label`, `q[label_cont]`, `Spree::LabelTranslatable` |
| `OptionType#color?` | Removed | `color_swatch?` |
| `default_image`, `featured_image`, `primary_image` | Removed | `primary_media` |
| `Spree::Image`, `Spree::Asset`, `ImageMethods`, `styles`, `generate_url`, `original_url` | Removed / `Asset` deprecated alias | `Spree::Media`; Active Storage variants + `cdn_image_url` |
| `Spree::StockItem`, `stock_items` | Deprecated alias | `Spree::StockLevel` (`sl_`) |
| `Spree::Digital`, `digitals`, `digital.*` events, `/store/digitals/:token` | Deprecated | `Spree::DigitalAsset`, `digital_assets`, `digital_asset.*`, `/store/digital_links/:token` |
| `Spree::WishedItem`, `wished_items` | Deprecated alias | `Spree::WishlistItem`, `wishlist_items` |
| `Product.with_option`, `.with`, `.in_name*`, `.with_ids`, `.for_user`, `add_search_scope` | Removed | `.with_option_value`, `.search`, `where(id:)`, plain `scope` |
| `searcher_class` | Removed | `Spree.search_provider` |
| `Spree::SearchProvider::Meilisearch`, `SearchProvider::ProductPresenter` | Deprecated (needs `spree_meilisearch` gem) | `SpreeMeilisearch::SearchProvider`, `SpreeMeilisearch::ProductPresenter` |
| `stores: [...]` on Product/Promotion/PaymentMethod | Removed | single `belongs_to :store`; sharing lives in `spree_multi_store` |

## Custom fields (metafields)

| Pattern | Status | Replacement |
|---|---|---|
| `Spree::Metafield`, `MetafieldDefinition`, `Spree::Metafields::*`, `include Spree::Metafields` | Deprecated | `Spree::CustomField`, `CustomFieldDefinition`, `Spree::CustomFields::*`, `include Spree::HasCustomFields` |
| `set_metafield`, `get_metafield`, `has_metafield?`, `metafields`, `public_metafields`, `with_metafield_key*`, `Spree.metafields` | Deprecated | `set_custom_field`, `get_custom_field`, `has_custom_field?`, `custom_fields`, `storefront_custom_fields`, `with_custom_field_key*`, `Spree.custom_fields` |
| `private_metafields` | Removed | filter `custom_fields` / `Spree::CustomField.admin_only` |
| definition `name`, `metafield_type`, `display_on` | Deprecated (columns renamed) | `label`, `field_type` (returns token like `short_text`; class via `field_type_class_name`), `storefront_visible` |
| `custom_field.value.body` | Changed | `value` is a sanitized HTML String |
| `metafield\.` in CSV templates/integrations | Breaking | `custom_field.` prefix (e.g. `custom_field.custom.material`); old prefix is silently ignored on import |
| `shipping_category` CSV column | Breaking | `product_type` |
| `CustomFieldDefinition.where/all` (global) | Changed | `store.custom_field_definitions` (store-scoped) |

## Metadata

| Pattern | Status | Replacement |
|---|---|---|
| `private_metadata` | Deprecated reader/writer (dirty methods like `private_metadata_changed?` raise) | `metadata` |
| `public_metadata` | Removed (merged into `metadata`) | `metadata` for private developer data; custom fields with `storefront_visible` for anything customers should see |

## Fulfillment, delivery, returns

| Pattern | Status | Replacement |
|---|---|---|
| `Spree::Shipment`, `shipments` | Deprecated alias | `Spree::Fulfillment` (`ful_`), `fulfillments` |
| `Spree::ShippingMethod`, `ShippingRate`, `shipping_method`, `add_shipping_method` | Deprecated alias | `Spree::DeliveryMethod`, `DeliveryRate`, `delivery_method`, `add_delivery_method` |
| `Spree::ShippingCategory`, `shipping_category` | Removed | `Spree::DeliveryProfile`, `delivery_profile` |
| `Spree::Zone`, `ZoneMember`, `zone.include?`, `Zone.match` | Migration-only shell | `Spree::DeliveryZone` for delivery; tax rates name countries/states directly |
| `.ship!`, `.ship`, `shipped?`, `can_ship?`, `shipped_at`, `'shipped'` status | Deprecated | `Spree.fulfillment_fulfill_workflow.call(fulfillment:)` (`Spree::Fulfillments::Fulfill`), `fulfilled?`, `can_fulfill?`, `fulfilled_at`, `'fulfilled'` |
| `'pending'`/`'ready'`/`'ready_for_pickup'` fulfillment states | Changed | `unfulfilled` / `fulfilled` / `delivered` |
| `create_proposed_shipments`, `create_proposed_fulfillments`, `target_shipment` | Deprecated | `rebuild_fulfillments!`, `target_fulfillment` |
| `delivery_required?`, `requires_ship_address?` | Deprecated | `delivery_step_required?`, `shipping_address_required?` |
| `tracking` on shipment | Moved | `spree_deliveries` rows (`fulfillment.deliveries`) |
| `ReturnAuthorization`, `CustomerReturn`, `Reimbursement`, `ReimbursementType`, `ReturnItem`, `EligibilityValidator` | Removed | `Spree::Return`, `Spree::Exchange`, `Spree::Claim`; `Spree::ReturnLineItem`/`ExchangeLineItem`/`ClaimLineItem`; `Spree::Returns::Refund`; policy via `Spree.hooks.register('returns.create.validate', …)` (core's window rule is now `Spree::Returns::EligibilityValidator` on `returns.create.validate` + `exchanges.create.validate`; unregister it in a plain initializer to replace it) |
| `ReturnAuthorizationReason` | Deprecated alias | `Spree::ReturnReason` |
| `return_eligibility_number_of_days`, `restock_inventory`, `expedited_exchanges*` | Deprecated, no effect | `market.preferred_return_window_days`, `ReturnLineItem#resellable`, `Spree::Exchange` |

## Customers, addresses, geography

| Pattern | Status | Replacement |
|---|---|---|
| `Spree.user_class`, `Spree::User`, `spree_users` | Deprecated / migrated | `Spree.customer_class` (`Spree::Customer`, `cust_`); staff: `Spree.admin_user_class` (`Spree::AdminUser`). Events for customers are `user.*`, staff `admin.*` |
| Devise (`devise`, `Devise.pepper`, `encrypted_password`, `authenticate_spree_user!`) | Removed from Spree | `has_secure_password` on the gem models; custom auth via `Spree.store_authentication_strategies` / `admin_authentication_strategies` |
| `firstname`, `lastname`, `zipcode`, `bill_address_firstname`, `normalize_zipcode`, `q[zipcode_cont]` | Deprecated (columns renamed) | `first_name`, `last_name`, `postal_code`, `bill_address_first_name`, `normalize_postal_code`, `q[postal_code_cont]`; validation errors now keyed `postal_code` |
| `use_billing`, `clone_billing_address` | Deprecated | `use_shipping` (shipping address is canonical) |
| `special_instructions` | Deprecated | `customer_note` |
| `country_id`, `state_id`, `Spree::Country.find*/where`, `Spree::State.find*/where`, `country_iso`, `state_abbr` | Changed — countries/states are reference data (plain objects) | `country_code`, `state_code`; `Spree::Country.by_iso(code)`, `Spree::Country.all`, `Spree::State.for_country(code)` |
| `user_default_billing?`, `user_default_shipping?` | Removed | `is_default_billing?`, `is_default_shipping?` |
| `Store#admin_users`, `supported_shipping_zones`, `spree_admin_created?` | Removed | `#users`, `#countries_with_shipping_coverage`, `.spree_admin.exists?` |
| `Spree::Store.default` assumed present | Changed (may return `nil`) | ensure a default store; set `Spree::Current.store` in jobs/tasks/tests |

## Permissions, API, controllers

| Pattern | Status | Replacement |
|---|---|---|
| `PermissionSets`, `permissions.assign`, `DefaultCustomer` | Removed | Role rows: `Spree::Role#permissions` = `%w[read_orders write_orders …]`; extensions: `Spree.permissions.register_scope(...)`; record-level rules the catalog can't express → subclass `Spree::Ability` and set `Spree::Dependencies.ability_class` (API v3 staff/seller abilities use it; secret keys don't) |
| `ApiKey::SCOPES` | Removed | `Spree::ApiKey.known_scopes` |
| storefront `can`/`cannot` rules (CanCanCan) | Not consulted by the Store API | `Spree::Storefront::AccessPolicy` subclass (`Spree::Dependencies.storefront_access_policy_class`) or a workflow `validate` hook |
| `PermittedAttributes`, `permitted_[a-z_]+_attributes`, `StrongParameters` | Removed | `Spree::Product.additional_permitted_attributes += [:brand_id]` (never `<<` — `FrozenError`); custom v3 controllers define `resource_permitted_attributes` |
| API v2 (`/api/v2/`, `Spree::Api::V2`, JSON:API clients) | Removed | API v3 (`/api/v3/store`, `/api/v3/admin`) + `@spree/sdk` / `@spree/admin-sdk` |
| `Spree::Admin::`, `spree_admin`, `app/views/spree/admin`, admin decorators/partials | Removed | React dashboard plugins in `apps/dashboard` (see **spree-dashboard-plugins**) |
| `spree_storefront`, `Spree::StorefrontController`, storefront theme code | Removed | Next.js storefront (`apps/storefront`) |
| `settings` scope used for `/admin_users`, `/invitations`, `/roles` | Changed | `read_staff` / `write_staff` |

## DI, events, audit, reports

| Pattern | Status | Replacement |
|---|---|---|
| `_service\s*=` in initializers (`cart_add_item_service`, `cart_recalculate_service`, `carts_complete_service`, `order_cancel_service`, `order_complete_service`, `shipment_update_service`, `fulfillment_update_service`, `fulfillment_create_service`, `gift_card_*_service`, `payments_handle_webhook_service`, `carts_upsert_items_service`, `cart_merge_strategy`) | Legacy — **stashed, not applied** | matching `*_workflow` key (`cart_add_item_workflow`, `carts_complete_workflow`, `order_complete_workflow`, `fulfillment_update_workflow`, …) with a subclass of the shipped workflow — or prefer a `Spree.hooks.register` handler |
| `order_resume_workflow`, `fulfillment_resume_workflow`, `carts_validate_service` | Removed | — |
| `Spree::StateChange`, `state_changes`, `Spree::LogEntry`, `log_entries` | Removed | events are the audit trail — subscribe (`order.placed`, `payment.completed`, `fulfillment.fulfilled`, …) and persist yourself if needed |
| `Spree::Report`, `Reports::*`, `ReportLineItem`, `ReportMailer`, `Spree.reports`, `report.*` events | Removed | reporting queries (see **spree-reporting**) or a `Spree::Export` subclass |
| `set_email_locale` | Removed | `with_store_locale(store) { … }` |

## Tests and assertions

| Pattern | Status | Replacement |
|---|---|---|
| `OrderWalkthrough` | Deprecated | factories `:cart`, `:cart_ready_for_delivery`, `:cart_ready_to_complete`, `:completed_order_with_totals` |
| `create(:order)` for checkout specs | Changed | `create(:cart, …)` — orders only exist after completion |
| `"can't be blank"` on associations | Changed | `"must exist"` (`belongs_to` required by default) |
| `belongs_to` in your own `Spree::Base` models without `optional:` | Changed | add `optional: true` where blank is legitimate |
| specs relying on `Spree::Store.default` auto-building | Changed | create a default store; set `Spree::Current.store` |

## Frontend / SDK (apps/storefront, apps/dashboard, integrations)

| Pattern | Replacement |
|---|---|
| `@spree/sdk` `^1` / `0.x` in `package.json` | `@spree/sdk` 2.x |
| `@spree/admin-sdk` `0.x` | `@spree/admin-sdk` 1.x |
| `shipping_method` in requirement handling | `delivery_method` / `delivery_method_required` |
| binding editors to `description` / `internal_note` | hydrate from `description_html` / `internal_note_html` |
| `order.completed` webhook subscriptions | `order.placed` |
| reading digital download bodies directly | follow the `302` redirect |
| `shipment` / `shipping_method` / `zipcode` fields | `fulfillment` / `delivery_method` / `postal_code` |

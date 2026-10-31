# Spree 6 permission catalog — secret-key scopes and role keys

Source of truth: `spree/core/lib/spree/core/permissions/default_catalog.rb`. At runtime, `GET /api/v3/admin/permissions` returns the registered catalog entries (`Spree.permissions.entries`, including scopes registered by extensions) — without the `read_all` / `write_all` aliases. `Spree::ApiKey.known_scopes` (Ruby) returns the staff-grantable keys plus those two aliases.

`write_<x>` implies `read_<x>`. The same keys serve as secret-key scopes (`Spree::ApiKey#scopes`) and staff-role permissions (`Spree::Role#permissions`).

## Staff-grantable keys (in picker order)

| Group | Scope | Keys | Covers (CanCanCan subjects) |
|---|---|---|---|
| analytics | `dashboard` | `read_dashboard` (read-only) | Dashboard analytics |
| analytics | `reports` | `read_reports`, `write_reports` | Reporting queries, saved reports, report exports |
| orders | `orders` | `read_orders`, `write_orders` | Order, OrderGroup, LineItem, TaxLine, Discount, Fee, Return, Exchange, Claim, TaxIdentifier, order custom fields, DigitalLink |
| orders | `payments` | `read_payments`, `write_payments` | Payment, PaymentSplit (capture, void) |
| orders | `fulfillments` | `read_fulfillments`, `write_fulfillments` | Fulfillment, ShippingLabel, Delivery |
| orders | `refunds` | `read_refunds`, `write_refunds` | Refund |
| catalog | `products` | `read_products`, `write_products` | Product, Variant, OptionType/Value, Price, PriceList, PriceRule, Catalog, CatalogProduct/Assignment, DigitalAsset, product custom fields, Import/ImportRow |
| catalog | `product_types` | `read_product_types`, `write_product_types` | ProductType |
| catalog | `publishing` | `read_publishing`, `write_publishing` | ProductPublication (channel publishing) |
| catalog | `media` | `read_media`, `write_media` | Media library (cross-resource) |
| catalog | `categories` | `read_categories`, `write_categories` | Category, ProductCategory |
| catalog | `collections` | `read_collections`, `write_collections` | Collection, ProductCollection, CollectionRule |
| catalog | `stock` | `read_stock`, `write_stock` | StockLevel, StockLocation, StockMovement, StockTransfer(+Item), StockReservation, StockReceipt(+Item) |
| catalog | `purchasing` | `read_purchasing`, `write_purchasing` | Supplier, PurchaseOrder(+Item), StockReceipt(+Item) |
| customers | `customers` | `read_customers`, `write_customers` | Customer, Address, CreditCard, CustomerGroup, Company, CompanyMembership/Invitation, TaxIdentifier, TaxExemptionCertificate, DataRequest, ConsentRecord, customer custom fields |
| sellers | `sellers` | `read_sellers`, `write_sellers` | Seller, SellerRequirement(+Submission) |
| sellers | `commissions` | `read_commissions`, `write_commissions` | CommissionRate, CommissionRule, CommissionLine |
| sellers | `payouts` | `read_payouts`, `write_payouts` | SellerTransfer, SellerPayout |
| loyalty | `gift_cards` | `read_gift_cards`, `write_gift_cards` | GiftCard, GiftCardBatch |
| loyalty | `store_credits` | `read_store_credits`, `write_store_credits` | StoreCredit, StoreCreditEvent |
| marketing | `promotions` | `read_promotions`, `write_promotions` | Promotion, PromotionRule/Action/Category, CouponCode, promotion custom fields |
| settings | `settings` | `read_settings`, `write_settings` | Store, PaymentMethod, Gateway, DeliveryZone(+Member), StockLocation, DeliveryProfile, Market, TaxCategory, TaxRate, AllowedOrigin, Refund/Return/Claim/OrderCancellation reasons, Channel, OrderRoutingRule, CustomFieldDefinition, Policy |
| settings | `delivery_methods` | `read_delivery_methods`, `write_delivery_methods` | DeliveryMethod, DeliveryMethodRule, DeliveryMethodService |
| settings | `package_types` | `read_package_types`, `write_package_types` | PackageType |
| settings | `webhooks` | `read_webhooks`, `write_webhooks` | WebhookEndpoint, WebhookDelivery |
| settings | `integrations` | `read_integrations`, `write_integrations` | Integration |
| access | `api_keys` | `read_api_keys`, `write_api_keys` | ApiKey (a key can only mint scopes it holds) |
| access | `staff` | `read_staff`, `write_staff` | AdminUser, Invitation, Role, RoleUser |

## Aliases (secret keys only)

- `read_all`: every staff `read_*` key.
- `write_all`: every staff key (full admin). Don't hand this to integrations.

## Seller-audience keys (not grantable to staff or secret keys)

These exist only for marketplace seller roles (`/api/v3/seller`). See `spree-marketplace`.

| Scope | Keys | Notes |
|---|---|---|
| `seller_profile` | `read_seller_profile`, `write_seller_profile` | Seller's own profile, branding, addresses |
| `seller_earnings` | `read_seller_earnings` | Seller's own balance and payouts (read-only) |

Scopes shared with sellers (`audiences: %i[store seller]`): `dashboard`, `orders`, `fulfillments`, `products`, `product_types` (read-only for sellers), `media`, `stock`, `delivery_methods`, `package_types`.

## Endpoint quirks

- **Custom-field values** use the parent resource's key (`/products/:id/custom_fields` → `products`). Definitions (`/custom_field_definitions`) use `settings`.
- **Exports** (`/exports`) have no scope of their own. Each type requires the read key of what it exports (`Spree::Export.required_scope`). The index lists only the types the caller can read.
- **Imports** require the write key of what they import (`Spree::Import.required_scope`).
- **Translations** resolve to the scope of the translated resource (`Spree.permissions.scope_for_resource`).
- **Stock locations**: reading them needs `read_stock`, but creating, updating or deleting them needs `write_settings`, because they're shared store-wide.
- **Embedded records need their own key.** `?expand=` segments naming `order(s)`, `payment(s)`/`payment_splits`, `customer(s)`, `gift_card(s)`, `store_credit(s)` are silently dropped unless the caller also holds that resource's read key (`orders.payments` needs both). Gift card `code` is masked (last four characters) without `read_gift_cards`.
- **Gift cards**: setting `customer_id` also needs `read_customers` (403 `required_permission: read_customers`).
- **Webhooks**: `read_webhooks` shows a delivery's `payload` only when the caller can also read the record the event is about (`payload` is `null` otherwise). Subscribing an endpoint to `customer.password_reset_requested` (or changing the URL/subscriptions of one that receives it) needs `write_customers` as well as `write_webhooks`.
- **Invitations**: creating one needs `write_staff` plus the right to grant its role (`role_id` is required). The acceptance link (`GET /invitations/:id/acceptance_link`) is write-gated the same way; seller-team links need `write_sellers` (Admin) or `write_seller_profile` (Seller API).
- **Role changes**: only an `admin`-role holder can grant or remove the `admin` role; others can grant or remove only roles within their own keys; a store keeps at least one admin.

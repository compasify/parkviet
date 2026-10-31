# Fulfillment extension contracts (Spree 6)

Reference for the pluggable pieces behind `spree-fulfillment`. Register everything from a
`Rails.application.config.after_initialize` block in `config/initializers/spree.rb` — core
*assigns* `Spree.stock_splitters`, `Spree.fulfillment_providers` and
`Spree.calculators.shipping_methods` in its own `after_initialize`, so appends made earlier
(top of an initializer, or `to_prepare`, which runs before `after_initialize` at boot) are
overwritten. `Spree.delivery_rate_providers`, `Spree.order_routing.*` and
`Spree.delivery_method_rules` are concatenated by core, but `after_initialize` works for all of
them, so use it uniformly.

## Delivery rate provider

```ruby
class SpreeAcme::DeliveryRateProvider < Spree::DeliveryRateProvider::Base
  # Class-level
  def self.integration_class = 'SpreeAcme::Integration' # derives available_for_store?; nil = always available
  def self.requires_address? = true   # carriers: true (can only price methods whose fulfillment provider ships)
  def self.uses_calculator? = false   # default false; Internal returns true
  def self.service_catalog(integration)                # optional — admin carrier-services picker
    return Spree::DeliveryRateProvider::ServiceCatalog.none if integration.nil?
    Spree::DeliveryRateProvider::ServiceCatalog.listing(
      integration.client.services.map { |s| { carrier: s.carrier, service: s.code, label: s.name } }
    )
  rescue SpreeAcme::Error => e
    Spree::DeliveryRateProvider::ServiceCatalog.unavailable(e.message)
  end

  # Instance-level — initialized with the delivery method (`delivery_method`, `store`, `integration`)
  def estimates(package) # Array<Estimate>; one per carrier service; [] hides the method
    # Splitters can yield several packages from one location for one order — key on the
    # contents too, or a later package reuses the first package's rates.
    contents = package.contents.map { |i| [i.variant&.id, i.quantity, i.state] }.sort_by(&:to_s)
    key = [:acme_quotes, store.id, package.stock_location.id, package.owner.id, contents]
    quotes = Spree::Current.provider_cache[key] ||= integration.client.rates(package) # shared across delivery methods
    quotes.map do |q|
      Spree::DeliveryRateProvider::Estimate.new(
        cost: q.amount,              # pre-tax
        currency: q.currency,        # nil = store currency; mismatches with the cart are dropped
        carrier: q.carrier,
        service_level: q.service,
        estimated_delivery_date: q.eta,
        metadata: { quote_id: q.id }
      )
    end
  rescue SpreeAcme::Error => e
    Rails.error.report(e, source: 'acme.rating')
    []
  end
  # or implement `estimate(package)` returning one Estimate or nil — Base#estimates wraps it

  # `book(delivery_rate)` / `release(delivery_rate)` exist on the contract but core does not call them yet.
end
```

`Estimate` attributes: `cost`, `unpriced` (freight), `currency`, `carrier`, `service_level`, `name`,
`estimated_delivery_date`, `metadata`. The merchant narrows/renames/marks up services per method
(`Spree::DeliveryMethodService` rows), matched on `carrier` + `service_level`.

Test it as a plain object: `described_class.new(create(:delivery_method, rate_provider: described_class.to_s)).estimates(package)` with the carrier client stubbed.

## Fulfillment provider

```ruby
class SpreeAcme::FulfillmentProvider < Spree::FulfillmentProvider::Base
  def self.integration_class = 'SpreeAcme::Integration'
  def self.generates_labels? = true         # enables auto label purchase in Fulfillments::Fulfill
  # Behaviour predicates (override only the one that applies): digital?, pickup?, pickup_point?

  def can_fulfill?(fulfillment) = true      # provider veto, composed into Fulfillment#can_fulfill?
  def requires_address? = true              # false for digital / pickup kinds
  def auto_fulfill? = false                 # true = fulfills itself on order placement (digital)

  def create_fulfillment(fulfillment)       # REQUIRED — 3PL pick, counter handoff, …
    { tracking_number: '…', tracking_url: '…' } # optional; becomes primary Delivery unless staff typed one
  end
  def cancel_fulfillment(fulfillment); end  # REQUIRED — stand the carrier/3PL down

  def purchase_label(owner); end            # owner: Spree::Fulfillment or Spree::Return → Spree::LabelPurchase or nil
  def refund_label(shipping_label); end     # 'refunded' | 'refund_requested' | false
  def tracking_url(delivery); end
  def documents(owner) = []                 # Array<Spree::ShippingDocument> (customs forms, invoices)
end
```

Core never asks for a second label for an owner that already holds an active one, so providers
need no idempotency bookkeeping. Label purchase is network I/O and runs outside the DB transaction.

## Integration + carrier tracking webhook

```ruby
class SpreeAcme::Integration < Spree::Integration
  preference :api_key, :password          # :password preferences are masked on read
  preference :webhook_secret, :password

  def self.integration_group = 'shipping'

  def can_connect?
    client.ping
    true
  rescue StandardError => e
    self.connection_error_message = e.message
    false
  end

  # POST /api/v3/webhooks/fulfillments/:integration_id  (integration prefixed ID)
  def parse_webhook_event(raw_post, headers)
    raise Spree::Integration::WebhookSignatureError if preferred_webhook_secret.blank?
    payload = SpreeAcme.verify!(raw_post, headers, preferred_webhook_secret)
    return unless payload['type'] == 'tracker.updated'

    {
      tracking_code: payload['tracking_code'],
      tracking_status: STATUS_MAP.fetch(payload['status'], 'unknown'), # Spree::Delivery::STATUSES
      estimated_delivery_at: payload['eta'],
      delivered_at: payload['delivered_scan_at'],                      # carrier scan time, not "now"
      details: payload.slice('status_detail')
    }
  rescue SpreeAcme::SignatureError => e
    raise Spree::Integration::WebhookSignatureError, e.message
  end
end
```

Responses: 401 on `WebhookSignatureError`; 404 when the integration isn't active in the current
store; 200 for `nil` events, unmatched tracking codes and swallowed errors (reported via
`Rails.error`). The endpoint is rate-limited to 120/min per IP.

## Order routing rule

```ruby
module MyApp::OrderRouting::Rules
  class ClosestLocation < Spree::OrderRoutingRule
    preference :max_distance_km, :integer, default: 1000

    def rank(order, locations)
      target = order.ship_address
      locations.map do |loc|
        distance = target && MyApp::Geo.distance_km(loc, target) # your own geo logic
        LocationRanking.new( # Spree::OrderRoutingRule::LocationRanking
          location: loc,
          rank: distance && distance <= preferred_max_distance_km ? distance.to_i : nil # nil = abstain
        )
      end
    end
  end
end

Rails.application.config.after_initialize do
  Spree.order_routing.rules << MyApp::OrderRouting::Rules::ClosestLocation
end
# Then one row per channel: ClosestLocation.create!(store:, channel:, position: 0, preferred_max_distance_km: 500)
```

Reducer semantics: lowest rank wins; ties carry forward to the next rule; all-abstain falls back to
the default location, then `id`. Always return one ranking per input location. Rules rank, they
don't filter. Remember: storefront carts are built by `Spree::Stock::Coordinator`, not the routing
strategy — rules affect admin-built orders and `OrderInventory` changes (see SKILL.md).

## Order routing strategy

Subclass `Spree::OrderRouting::Strategy::Base` (initialized with `order:`), implement all four:
`for_allocation` → `Array<Spree::Stock::Package>` (build with `Spree::Stock::Packer.new(location, units, Spree.stock_splitters, owner: order).packages` and set `package.delivery_rates = Spree::Stock::Estimator.new(order).delivery_rates(package)`), and `for_sale(fulfillment:)`, `for_release`, `for_cancellation` (Base raises `NotImplementedError`; define no-ops if unused — core doesn't invoke them today). Register with `Spree.order_routing.strategies << MyStrategy` and set `preferred_order_routing_strategy` on the store or a channel.

## Stock splitter

```ruby
class MyApp::Stock::Splitter::Refrigerated < Spree::Stock::Splitter::Base
  def split(packages)
    split = packages.flat_map do |package|
      package.contents.group_by { |item| item.variant.refrigerated? }
             .values.reject(&:empty?).map { |contents| build_package(contents) }
    end
    return_next(split) # forgetting this silently skips every later splitter
  end
end
```

`package.contents` are `Spree::Stock::ContentItem`s (`variant`, `inventory_unit` → the
`FulfillmentItem`, `weight`, `state` `:on_hand`/`:backordered`). Build new packages; don't mutate
inputs. Order matters: `DeliveryProfile` first (coarse), `Backordered` usually last.

## Delivery method rule

```ruby
class MyApp::DeliveryMethodRules::NoHazmat < Spree::DeliveryMethodRule
  def eligible?(package)
    package.contents.none? { |item| item.variant.get_custom_field('logistics.hazmat')&.value == 'true' }
  end
end
Rails.application.config.after_initialize { Spree.delivery_method_rules << MyApp::DeliveryMethodRules::NoHazmat }
```

Rules are AND-ed, one per kind per method, evaluated in the Estimator for both calculator- and
provider-priced methods. Built-ins: `ChannelRule`, `CompanyRule`, `ExcludedProductsRule`,
`ItemTotalRule`, `VolumeRule`, `WeightRule` (all under `Spree::DeliveryMethodRules`).

---
name: spree-promotions
description: Use when the user is working with Spree 6 promotions and discounts — creating promotions (automatic or coupon code), bulk/multi-use coupon codes, promotion rules and actions, calculators, how competing promotions are resolved, manual discounts, writing a custom promotion rule, action or calculator, or a custom adjuster. Common phrasings include "create promotion", "coupon code", "discount code", "generate 1000 codes", "BOGO", "free shipping promotion", "10% off category", "promotion not applying", "custom promotion rule", "custom promotion action", "custom calculator", "stack promotions", "best discount wins", "manual discount", "goodwill discount", "Spree::Discount", "Taxon rule".
---

# Spree Promotions

A **promotion** (`promo_`) is a campaign: rules decide *whether* it applies, actions decide *what* it does. What lands on a cart/order is a **discount** (`Spree::Discount`, `disc_`) — a money row that survives the promotion being edited or deleted.

```
Promotion (belongs_to :store; kind coupon_code|automatic; starts_at/expires_at; usage_limit; match_policy all|any)
  ├── PromotionRule (prorule_, STI)      — eligible?(cart_or_order)
  ├── PromotionAction (pact_, STI)       — discount_scope + compute_amount, or a side effect in perform
  │     └── Calculator (calc_)            — how much (FlatRate, FlatPercentItemTotal, PercentOnLineItem, …)
  └── CouponCode (coupon_) × n           — multi-code promotions; state unused|used
Discount — kind 'promotion' | 'manual'; attached to exactly one LineItem or Fulfillment; amount ≤ 0
```

## How promotions apply

Every cart change runs `Spree::Carts::RecalculateTotals`, which runs `Spree::Adjusters::Promotion`:

1. **Candidates** — promotions connected to the cart, plus the cart's persisted `coupon_code` promotion, plus automatic ones being activated. Each is checked: active window, usage limit, then rules per `match_policy`.
2. **Competition, winner-only** — per competition group the most negative amount wins (ties → newest action):
   - `:line_item` actions compete **per line item** (only items passing the rules' `actionable?`),
   - `:fulfillment` actions compete **per fulfillment**,
   - `:order` actions compete order-wide; the winner is **spread across line items** proportionally (largest remainder) — there are no order-attached discount rows.
3. **Persistence** — winning rows written, clamped so no line/fulfillment goes below zero; stale promotion rows deleted. Losers aren't stored and simply compete again next time. Tax is then estimated on discounted amounts.
4. **Placement** — once `Spree::Order` exists its discount rows are frozen; usage is recorded against the promotion.

There is no stacking in 6.0 — two promotions on the same line don't combine.

## Creating promotions

```typescript
// "20% off orders over $100 with code SUMMER20"
await admin.promotions.create({
  name: 'Summer Sale',
  kind: 'coupon_code',
  code: 'SUMMER20',
  starts_at: '2027-06-01T00:00:00Z',
  expires_at: '2027-09-01T00:00:00Z',
  rules: [{ type: 'item_total', preferences: { amount_min: 100 } }],
  actions: [{ type: 'create_adjustment',
              calculator: { type: 'flat_percent_item_total', preferences: { flat_percent: 20 } } }],
})
await admin.promotions.rules.create('promo_xxx', { type: 'first_order' })
await admin.promotions.actions.create('promo_xxx', { type: 'free_shipping' })
```

```bash
spree api get /promotion_rules/types        # registered rule types + preference schemas
spree api get /promotion_actions/types
spree api get "/promotion_actions/calculators?type=create_adjustment"
```

- `kind`: `automatic` (no code, applies when rules match) or `coupon_code`. Setting a `code` flips an automatic promotion to `coupon_code`; codes are stored and matched lowercased.
- **Multi-code (batch) promotions**: `multi_codes: true, number_of_codes: 1000, code_prefix: 'SUMMER'` generates `Spree::CouponCode` rows (large batches in a background job); each code is single-use (`unused` → `used`), `usage_limit` doesn't apply. A code is **spent only when an order is placed with it** — applying it to a cart just holds it (`coupon_code.holder`). List them with `GET /promotions/:id/coupon_codes`.
- Wire `type` values are the `api_type` shorthand (`item_total`, `create_item_adjustments`, `flat_rate`) — never Ruby class names.
- Promotions are single-store (`current_store.promotions`). Outside a request set `Spree::Current.store`.

### Built-in rules

`currency`, `country`, `channel`, `market`, `item_total`, `product` (any/all/none), `category` (children count; `Spree::Promotion::Rules::Taxon` is a deprecated alias) — their `product_ids=` / `category_ids=` resolve prefixed or raw IDs through the promotion's store, so another store's record raises `RecordNotFound` (and fails validation); a custom rule that links records can reuse `ids_within_store(ids, promotion.store.products)` — `option_value`, `user`, `customer_group`, `first_order`, `user_logged_in`, `one_use_per_user`.

### Built-in actions

| Action (`api_type`) | `discount_scope` | Default calculator | Notes |
|---|---|---|---|
| `create_adjustment` — order discount | `:order` | `FlatPercentItemTotal` | Also `FlatRate`, `FlexiRate`, `TieredPercent`, `TieredFlatRate`. Spread over line items. |
| `create_item_adjustments` — item discount | `:line_item` | `PercentOnLineItem` | Also `FlatRate`, `FlexiRate`. Only actionable items. |
| `free_shipping` | `:fulfillment` | — | Row persists at zero; `order.has_free_shipping?` tests row existence. |
| `create_line_items` — free gift | `:line_item` | — | Tops the cart up to the gift quantity (stock-checked) **and** writes a line-level discount covering the gifted units (only those — extra units of the same variant are paid for). Don't pair it with an order discount "to pay for the gift" — that discounts twice. Rules decide whether it applies, not which lines it pays for, and the gift itself can't satisfy the rules. **Given-away units don't count toward what promotions measure**: `ItemTotal` thresholds (this promotion's own too, so the gift is taken back once the paid goods drop to the threshold) and the base an order-level percentage is taken from (`Purchase::Totals#amount` subtracts `gift_amount`). A copy the shopper pays for counts toward other promotions like any item. A shopper already holding the variant gets it free instead of a duplicate. When the promotion stops applying, cart recalculation reverts it and takes the gift units back out (only for promotions actually joined to the cart, so a shopper's own purchase of that variant is never deleted). |

**Calculators carry a currency.** `FlatRate` (and other amount-based calculators) return 0 when their `preferred_currency` doesn't match the cart — set one promotion/calculator per currency or the promotion silently does nothing for some customers.

## Coupon codes at checkout

```typescript
const cart = await client.carts.discountCodes.apply(cart.id, 'SUMMER20', { spreeToken: cart.token })
await client.carts.discountCodes.remove(cart.id, 'SUMMER20', { spreeToken: cart.token })
```

The code is stored on `cart.coupon_code` (and copied to `order.coupon_code`). If the cart doesn't qualify yet (e.g. below the minimum), the code **stays on the cart** with a `coupon_code_not_eligible` warning and activates on the recalculation where it first qualifies. Gift cards use their own endpoint (`carts.giftCards`) — see `spree-payments`.

Batch (single-use) codes are **held from the moment they're saved on a cart**, even before the cart qualifies, and only the holder is discounted (`Promotion#eligible?` fails for a purchase that doesn't hold the code, via `Spree::CouponCode.held_by`). A replaced or removed code is given back. Abandoned carts: a code held by another **open** cart is taken over by whoever presents it next (the old cart loses the discount), and whichever order is placed first keeps it. A cart already in completion (`completion_claimed?`), a completed cart and a draft order never give up a held code — the newcomer gets `coupon_code_used`, as they do when the code was spent by a placed order (or while it was being applied). A cart that lost its code (`cart.coupon_code_unavailable?`) has it dropped on its next Store API request that reads or changes the cart, with a `coupon_code_unavailable` warning. `carts.complete` refuses such a cart with `coupon_code_unavailable` rather than charging more than the shopper was shown. Server side the handler is `Spree.coupon_handler` (`Spree::PromotionHandler::Coupon`).

## Manual discounts

Staff can add discounts to a placed order with no promotion behind them (`kind: 'manual'`):

```typescript
await admin.orders.discounts.create('or_xxx', { label: 'Goodwill', value: '10', value_type: 'percent', line_item_id: 'li_xxx' })
await admin.orders.discounts.create('or_xxx', { label: 'Price match', value: '15.00', value_type: 'flat' })
```

Only manual rows can be edited/deleted — promotion rows return 422.

## Custom rule

```ruby
# app/models/spree/promotion/rules/minimum_quantity.rb
module Spree
  class Promotion
    module Rules
      class MinimumQuantity < Spree::PromotionRule
        preference :quantity, :integer, default: 5

        # MUST accept both — promotions are evaluated on the Cart through checkout
        def applicable?(promotable)
          promotable.is_a?(Spree::Cart) || promotable.is_a?(Spree::Order)
        end

        def eligible?(promotable, _options = {})
          return true if promotable.line_items.sum(&:quantity) >= preferred_quantity

          eligibility_errors.add(:base, "Add at least #{preferred_quantity} items")
          false
        end

        # optional: restrict which line items item-level actions discount (default true)
        # def actionable?(line_item) = …
      end
    end
  end
end
```

- Rules that aren't `applicable?` to the promotable are **skipped**, not failed — a rule guarding on `Spree::Order` only is ignored on carts, so the promotion can apply *without* your condition (and if it's the only rule, applies to everyone).
- Read the buyer via `promotable.customer`, totals via `item_total` (subtract `promotable.gift_amount(promotion: promotion)` for a spend threshold that should ignore free gifts, as `ItemTotal` does), lines via `line_items` — the `Spree::Purchase::*` surface shared by Cart and Order.
- Preferences (`:string`, `:integer`, `:decimal`, `:boolean`, `:array`) become the generated dashboard form. Association-backed config (e.g. `brand_ids`) also needs `self.additional_permitted_attributes = [brand_ids: []]` on the subclass so the Admin API permits it.

## Custom action

A discount action declares **where** and **how much**; the adjuster does competition, clamping, writing and cleanup:

```ruby
# app/models/spree/promotion/actions/tiered_discount.rb
module Spree
  class Promotion
    module Actions
      class TieredDiscount < Spree::PromotionAction
        preference :currency, :string, default: 'USD'

        def discount_scope = :order          # :line_item | :fulfillment | :order

        def perform(options = {})            # connects the promotion; returns true if it yields a candidate
          apply_via_adjuster(options)
        end

        # Called with the adjustable matching discount_scope (cart/order, line item, or fulfillment).
        # Return a NEGATIVE amount, or 0 for "no discount".
        def compute_amount(order)
          return 0 unless order.currency == preferred_currency

          discount = if order.item_total >= 100 then 25 elsif order.item_total >= 50 then 10 else 0 end
          -[discount, order.item_total].min
        end
      end
    end
  end
end
```

Non-discount actions (loyalty points, notifications) leave `discount_scope` nil and do their work in `perform(options)` (`options[:order]`, `options[:promotion]`), returning `true` if applied; optionally `revert(options)`. Keep side effects idempotent — `perform` can be called on repeated activations.

## Custom calculator

```ruby
class MyApp::Calculator::PerItemCap < Spree::Calculator
  preference :amount, :decimal, default: 0
  preference :currency, :string, default: -> { Spree::Store.default&.default_currency || 'USD' }

  def self.description = 'Flat amount per unit, capped at line amount'

  def compute(line_item)                 # item actions pass a line item; order actions pass the cart/order
    return 0 unless line_item.currency.casecmp?(preferred_currency)

    [preferred_amount * line_item.quantity, line_item.amount].min
  end
end
```

Calculators return a **positive** amount; actions negate it.

## Registration (all in one place)

Core reassigns these registries inside its own `after_initialize` — appending at the top level of an initializer or in `to_prepare` gets wiped. Always:

```ruby
# config/initializers/spree.rb
Rails.application.config.after_initialize do
  Spree.promotions.rules   << Spree::Promotion::Rules::MinimumQuantity
  Spree.promotions.actions << Spree::Promotion::Actions::TieredDiscount
  Spree.calculators.promotion_actions_create_item_adjustments << MyApp::Calculator::PerItemCap
  # order-level calculators go in Spree.calculators.promotion_actions_create_adjustments
end
```

Then add locale keys — the dashboard's promotion editor builds its pickers and preference forms from the `/types` endpoints, so no UI code is needed:

```yaml
# config/locales/en.yml
en:
  spree:
    promotion_rule_types:
      minimum_quantity:
        name: Minimum quantity
        description: Cart must contain at least N items
    promotion_action_types:
      tiered_discount:
        name: Tiered discount
        description: $10 off over $50, $25 off over $100
```

The key is the class's `api_type` (demodulized, underscored). Override `def self.api_type = 'min_qty'` to keep the wire name stable across a class rename.

## Custom adjusters (non-promotion charges/discounts)

Loyalty pricing, gift-wrap fees, payment surcharges have no rules or codes — they're adjusters: subclass `Spree::Adjusters::Base`, implement an idempotent `update` that writes/removes its own rows on `order` (the cart during checkout), and register with `Spree.adjusters << MyAdjuster` inside `after_initialize`. Don't write `kind: 'promotion'` rows (the promotion adjuster deletes rows it didn't write); `Spree::Discount` only allows `promotion`/`manual` kinds and must attach to a line item or fulfillment. Fees and totals are covered in `spree-order-totals`.

## Testing

```ruby
RSpec.describe Spree::Promotion::Rules::MinimumQuantity do
  let(:rule) { described_class.new(preferred_quantity: 3) }
  let(:cart) { create(:cart_with_line_items, line_items_count: 1) }

  it 'is applicable to carts' do
    expect(rule.applicable?(cart)).to be(true)
  end

  it 'needs 3 units' do
    expect(rule.eligible?(cart)).to be(false)
    cart.line_items.first.update!(quantity: 3)
    expect(rule.eligible?(cart.reload)).to be(true)
  end
end
```

Factories: `:promotion`, `:promotion_with_item_adjustment`, `:promotion_with_order_adjustment`, `:promotion_with_item_total_rule`, `:free_shipping_promotion`, `:cart_with_line_items`. Test eligibility against a **cart**, not only an order.

## "Promotion isn't applying"

1. Active? `starts_at`/`expires_at`; `promotion.usage_limit_exceeded?(cart)`; for coupon promotions, does `cart.coupon_code` match (codes are lowercased)?
2. Rules: `promotion.eligible?(cart)` then `promotion.eligibility_errors`. Custom rule `applicable?` to `Spree::Cart`?
3. Currency: amount calculators return 0 for another currency.
4. Lost the competition? Another promotion gave a bigger saving on the same line/fulfillment/order group — only one wins.
5. Item actions: rules' `actionable?` excluded the lines (e.g. `category`/`product` rule not matching those items).
6. Order already placed? Placed orders don't re-run promotions.
7. Custom type missing from the dashboard: not registered in `after_initialize`, or server not restarted.

## Where to read further

- `node_modules/@spree/docs/dist/developer/core-concepts/promotions.md`, `.../discounts.md`, `.../calculators.md`
- `node_modules/@spree/docs/dist/developer/how-to/custom-promotion.md`
- Source: `Spree::Adjusters::Promotion`, `Spree::PromotionRule`, `Spree::PromotionAction`, `Spree::Promotion::Rules::*`, `Spree::Promotion::Actions::*` in `spree_core`
- Related skills: `spree-order-totals`, `spree-checkout`, `spree-pricing` (price lists vs promotions), `spree-testing`

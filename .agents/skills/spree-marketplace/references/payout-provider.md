# Writing a payout provider

Read this when Stripe Connect isn't your payment rail, for example a bank-transfer API, a wallet, or another PSP's platform product. Core keeps the ledger. The provider only moves money.

## The contract: `Spree::PayoutProvider::Base`

Providers are stateless and built with no arguments. Everything request-specific arrives as a parameter.

| Method | Called when | Your job |
|---|---|---|
| `transfer!(seller_transfer)` | An order is fulfilled and the seller is payable | Credit the earning. If your rail only moves money at settlement, `update!(status: 'completed')` and return it |
| `pay!(seller_payout)` | The sweep or an operator settles a seller | Send the batch and store your ID in `reference`. **Leave the status as pending**, because completion comes when the money has landed |
| `reverse!(seller_transfer)` | A refund reverses part of an earning | Claw the money back if your rail can. Otherwise treat this as a no-op that completes the row. Core writes the reversal row either way |
| `available_payout(seller, currency)` | Before the sweep | The payable amount, or `nil` for no limit. **Raise** if you can't find out, because `nil` means "settle everything" |
| `self.requires_payout_account?` | | When true, core won't credit a seller until they're payable (`payouts_enabled_at`) |
| `onboarding_url(seller, refresh_url:, return_url:)` | Seller clicks "connect" | Mint a fresh hosted link, or return `nil`. Raise `Spree::Core::GatewayError`, which becomes a 422 |
| `onboarded?(seller)` | Rendering the checklist or at approval | Ask your API directly. Don't read the cached stamp |
| `onboarding_state(seller)` / `onboarding_message(seller)` | Checklist | `:action` / `:pending` / `:rejected` / `nil`, plus free text |
| `self.display_name`, `self.reference_system`, `self.available_for_store?(store)` | Settings picker | `reference_system` is the lowercase key that seller accounts are filed under. `available_for_store?` should mean "usable today" |
| `idempotency_key(record)` | Every write | Returns `"spree-#{record.prefixed_id}"`. Pass it to your API |

Don't override `provider_key`. It's the class name, and the ledger's unique `(provider, reference)` index keys on it. Only pin it (`def self.provider_key = 'Old::Name'`) if you rename the class.

## Errors decide retries

| Raise | Meaning | Core does |
|---|---|---|
| `Spree::Core::GatewayError` (or any `StandardError`) | A definite refusal, so no money moved | Transfer: stays retryable, and `SellerTransfers::ExecutePendingDueJob` retries it hourly. Payout: marked `failed`, and its transfers are released to the next sweep |
| `Spree::Core::AmbiguousGatewayError` | Unknown outcome (timeout, 5xx, idempotency conflict) | Row set to `unresolved`. Nothing automatic touches it again. An operator or your webhook resolves it |

Raising a plain error on a timeout is how a settlement gets sent twice. The payout fails, its earnings go back on the pile, and the next sweep batches them into a new payout with a **new** idempotency key.

## Skeleton

```ruby
# app/models/my_app/payout_provider.rb
module MyApp
  class PayoutProvider < Spree::PayoutProvider::Base
    def self.display_name = 'Acme Bank Rails'
    def self.reference_system = 'acme'
    def self.requires_payout_account? = true
    def self.available_for_store?(store) = store.integrations.active.exists?(type: 'MyApp::AcmeIntegration')

    def onboarded?(seller)
      client(seller.store).accounts.retrieve(seller.payout_account_reference(self.class)).verified?
    end

    def transfer!(seller_transfer)            # money only moves at payout time on this rail
      seller_transfer.update!(status: 'completed')
      seller_transfer
    end

    def pay!(seller_payout)
      seller = seller_payout.seller
      t = client(seller.store).transfers.create(
        amount: Spree::Money::Rounding.to_minor_units(seller_payout.amount, seller_payout.currency),
        currency: seller_payout.currency,
        destination: seller.payout_account_reference(self.class),
        idempotency_key: idempotency_key(seller_payout)
      )
      begin
        seller_payout.update!(reference: t.id)  # status stays pending until the webhook confirms
      rescue StandardError => e
        # The provider already accepted the money — a plain error here would fail the
        # payout and release its transfers into a second payout. Report it as ambiguous.
        raise Spree::Core::AmbiguousGatewayError, "transfer #{t.id} created; saving reference failed: #{e.message}"
      end
      seller_payout
    rescue Acme::TimeoutError, Acme::ServerError => e
      raise Spree::Core::AmbiguousGatewayError, e.message
    rescue Acme::Error => e
      raise Spree::Core::GatewayError, e.message
    end

    def reverse!(seller_transfer)             # can't claw back: no-op, core keeps the books
      seller_transfer.update!(status: 'completed')
      seller_transfer
    end

    private

    def client(store) = Acme::Client.new(api_key: store.integrations.active.find_by!(type: 'MyApp::AcmeIntegration').preferred_api_key)
  end
end
```

Keep credentials in a `Spree::Integration` subclass (`preference :api_key, :password`, `preference :webhook_secret, :password`), never in ENV. Each store pays from its own account. Register both:

```ruby
# config/initializers/spree.rb
Rails.application.config.after_initialize do
  Spree.integrations << 'MyApp::AcmeIntegration'
  Spree.payout_providers << MyApp::PayoutProvider
end
```

Then set `preferred_payout_provider: 'MyApp::PayoutProvider'` on the store (Settings → Marketplace), and add the `payout_account` seller requirement.

## Seller accounts

- `seller.set_payout_account_reference(MyApp::PayoutProvider, 'acct_123')` / `seller.payout_account_reference(MyApp::PayoutProvider)` store the account ID as an external reference under `reference_system`.
- `Spree::Seller.with_payout_account(store, MyApp::PayoutProvider, 'acct_123').first` is the reverse lookup for webhooks. It's store-scoped and uniquely indexed.

## Webhooks

A provider that is also a payment method can implement `handle_payout_webhook(raw_body, headers)` on its gateway and use the shipped `POST /api/v3/webhooks/payouts/:payment_method_id` route. A standalone provider adds its own route addressed to the **integration** (which holds the signing secret):

- Verify with HMAC-SHA256 plus `ActiveSupport::SecurityUtils.secure_compare`. Return 401 when the signature is bad, and rate limit the endpoint.
- Handle the event inline and **return a 5xx when it fails** so the provider redelivers. A 200 for work that didn't happen loses a settlement.
- Account became payable: `seller.update!(payouts_enabled_at: verified ? (seller.payouts_enabled_at || Time.current) : nil)`, then `Spree::SellerTransfers::ExecutePendingJob.perform_later(seller.id)` if the seller just became payable.
- Payout landed: find it with `seller.seller_payouts.find_by(provider: MyApp::PayoutProvider.provider_key, reference: id)`, return early if it's `completed?`, then call `Spree.seller_payout_complete_workflow.call(seller_payout: payout, reference: id)`. This is idempotent and safe to race with an operator. On failure, call `payout.fail!`, which releases the transfers.

## Test checklist

Spree's reference spec is `spree/providers/stripe/spec/models/spree_stripe/payout_provider_spec.rb`. Test that:

- `pay!` passes the idempotency key, stores `reference`, and leaves the status `pending`
- a timeout raises `AmbiguousGatewayError` and a refusal raises `GatewayError`
- amounts are sent in the units your API expects (`Spree::Money::Rounding.to_minor_units`)
- `onboarded?` hits the API instead of reading the stamp

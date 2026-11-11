# frozen_string_literal: true

module Spree
  # A POS service charge is an order-level fee of its own kind, taxed under
  # the tax category the branch chose. The tax engine reads `tax_category_id`
  # when an item has one; a fee stores it in its metadata, and without one it
  # is taxed under the store's default category.
  module FeeDecorator
    # Decorators are loaded again on every code reload.
    SERVICE_CHARGE_KIND = 'service_charge' unless const_defined?(:SERVICE_CHARGE_KIND)
    # What a VIP table still owes below its minimum spend (Pos::Fnb::MinimumSpend).
    MINIMUM_SPEND_KIND = 'minimum_spend' unless const_defined?(:MINIMUM_SPEND_KIND)

    def self.prepended(base)
      [SERVICE_CHARGE_KIND, MINIMUM_SPEND_KIND].each { |kind| base::KINDS << kind unless base::KINDS.include?(kind) }
    end

    def tax_category_id
      value = metadata.is_a?(Hash) ? metadata['tax_category_id'] : nil
      value.presence&.to_i
    end
  end

  Fee.prepend(FeeDecorator)
end

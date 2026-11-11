# frozen_string_literal: true

module Spree
  # A POS service charge is an order-level fee of its own kind, taxed under
  # the tax category the branch chose. The tax engine reads `tax_category_id`
  # when an item has one; a fee stores it in its metadata, and without one it
  # is taxed under the store's default category.
  module FeeDecorator
    # Decorators are loaded again on every code reload.
    SERVICE_CHARGE_KIND = 'service_charge' unless const_defined?(:SERVICE_CHARGE_KIND)

    def self.prepended(base)
      base::KINDS << SERVICE_CHARGE_KIND unless base::KINDS.include?(SERVICE_CHARGE_KIND)
    end

    def tax_category_id
      value = metadata.is_a?(Hash) ? metadata['tax_category_id'] : nil
      value.presence&.to_i
    end
  end

  Fee.prepend(FeeDecorator)
end

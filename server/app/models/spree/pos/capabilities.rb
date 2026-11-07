# frozen_string_literal: true

module Spree
  module Pos
    # Assignable POS capabilities. Selling stays gated per capability; payment
  # collection and liability resolution are separate capabilities.
    module Capabilities
      MANAGE = 'pos.topology.manage'
      OPEN_SHIFT = 'pos.shift.open'
      DISCOUNT = 'pos.discount.apply'
      PRICE_OVERRIDE = 'pos.price.override'
      CUSTOMER = 'pos.customer.write'
      PAYMENT = 'pos.payment.collect'
      RESOLVE = 'pos.payment.resolve'
      RECOVER = 'pos.topology.recover'
      APPROVE = 'pos.approval.grant'
      TAKEOVER = 'pos.workspace.takeover'
      # Credit stays off until a manager configures an account; configuring
      # accounts and selling on credit are separate grants.
      CREDIT_MANAGE = 'pos.credit.manage'
      CREDIT_SELL = 'pos.credit.sell'
      ASSIGNABLE = [MANAGE, OPEN_SHIFT, DISCOUNT, PRICE_OVERRIDE, CUSTOMER, PAYMENT, RESOLVE, RECOVER, APPROVE, TAKEOVER,
                    CREDIT_MANAGE, CREDIT_SELL].freeze

      def self.sanitize(values)
        Array(values).map(&:to_s).uniq
      end
    end
  end
end

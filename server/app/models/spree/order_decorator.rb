# frozen_string_literal: true

module Spree
  module OrderDecorator
    def self.prepended(base)
      base.has_one :pos_walk_in_order, class_name: 'Pos::WalkInOrder', foreign_key: :order_id, dependent: :destroy
    end

    private

    # Core's existing validator remains in force for every ordinary order and
    # whenever an email is supplied (including format/length validation).
    # The marker is server-owned, not a writable metadata flag.
    def require_email
      return false unless super
      return super if email.present? || customer_id.present? || new_record? || accept_marketing? || signup_for_an_account?
      return false if Pos::WalkInOrder.exists?(order_id: id)

      super
    end
  end

  Order.prepend(OrderDecorator)
end

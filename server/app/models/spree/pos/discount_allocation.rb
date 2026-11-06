# frozen_string_literal: true

module Spree
  module Pos
    class DiscountAllocation < Record
      self.table_name = 'spree_pos_discount_allocations'
      belongs_to :discount_intent, class_name: 'Spree::Pos::DiscountIntent', optional: true
      belongs_to :line_discount_intent, class_name: 'Spree::Pos::LineDiscountIntent', optional: true
      belongs_to :discount, class_name: 'Spree::Discount'
    end
  end
end

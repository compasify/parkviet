# frozen_string_literal: true

module Spree
  module Pos
    # The last call number handed out at a branch on one business date.
    # Written only by OrderNumbers.next_value!, one upsert per number.
    class OrderNumberCounter < Record
      self.table_name = 'spree_pos_order_number_counters'

      belongs_to :branch, class_name: 'Spree::Pos::Branch'

      validates :business_date, presence: true
      validates :last_value, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    end
  end
end

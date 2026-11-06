# frozen_string_literal: true

module Spree
  module Pos
    # Server-owned order-wide draft intent. No client write path until policy,
    # approval and workspace command enforcement are in place.
    class DiscountIntent < Record
      self.table_name = 'spree_pos_discount_intents'
      has_prefix_id :posdiscount

      belongs_to :workspace, class_name: 'Spree::Pos::Workspace'
      belongs_to :actor, class_name: staff_class_name
      has_many :allocations, class_name: 'Spree::Pos::DiscountAllocation', dependent: :restrict_with_error

      validates :value_type, inclusion: { in: %w[flat percent] }
      validates :value, presence: true, length: { maximum: 64 }, format: { with: /\A\d+(?:\.\d+)?\z/ }
      validates :reason, presence: true, length: { maximum: 200 }
      validate :valid_value

      private

      def valid_value
        return unless value.is_a?(String) && value.match?(/\A\d+(?:\.\d+)?\z/)

        number = BigDecimal(value)
        errors.add(:value, :invalid) if number <= 0 || (value_type == 'percent' && number > 100) || (value_type == 'flat' && !number.frac.zero?)
      end
    end
  end
end

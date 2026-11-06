# frozen_string_literal: true

module Spree
  module Pos
    class LineDiscountIntent < Record
      self.table_name = 'spree_pos_line_discount_intents'
      has_prefix_id :poslinediscount

      belongs_to :workspace, class_name: 'Spree::Pos::Workspace'
      belongs_to :sale_line, class_name: 'Spree::Pos::SaleLine'
      belongs_to :actor, class_name: staff_class_name
      has_many :allocations, class_name: 'Spree::Pos::DiscountAllocation', foreign_key: :line_discount_intent_id, dependent: :restrict_with_error, inverse_of: :line_discount_intent

      validates :value_type, inclusion: { in: %w[flat percent unit_price item_flat item_percent] }
      validates :value, presence: true, length: { maximum: 64 }, format: { with: /\A\d+(?:\.\d+)?\z/ }
      validates :reason, presence: true, length: { maximum: 200 }
      validate :valid_value

      private

      def valid_value
        return unless value.is_a?(String) && value.match?(/\A\d+(?:\.\d+)?\z/)

        number = BigDecimal(value)
        errors.add(:value, :invalid) if (%w[flat percent].include?(value_type) && number <= 0) || (%w[percent item_percent].include?(value_type) && number > 100) || (%w[flat unit_price item_flat].include?(value_type) && !number.frac.zero?)
      end

      public

      def self.item_override_amount(base:, value:, value_type:, currency:)
        raise DiscountCalculator::InvalidDiscount unless currency == 'VND' && base >= 0 && base.frac.zero?
        return BigDecimal('0') if BigDecimal(value).zero?

        DiscountCalculator.call(bases: [base], value: value, value_type: value_type.delete_prefix('item_'), currency: currency).first
      end
    end
  end
end

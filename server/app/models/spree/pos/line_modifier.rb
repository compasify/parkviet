# frozen_string_literal: true

module Spree
  module Pos
    # An option a sale line was sold with, copied at the time of sale: later
    # changes to the option never change the line, and a deleted option
    # leaves its copy.
    class LineModifier < Record
      self.table_name = 'spree_pos_line_modifiers'
      has_prefix_id :poslinemod

      belongs_to :sale_line, class_name: 'Spree::Pos::SaleLine', inverse_of: :line_modifiers
      belongs_to :modifier_option, class_name: 'Spree::Pos::ModifierOption', optional: true

      validates :name, :group_name, presence: true
      validates :quantity, numericality: { only_integer: true, greater_than: 0 }
      validates :price_delta, numericality: { greater_than_or_equal_to: 0 }

      def to_pos
        {
          id: prefixed_id, option_id: modifier_option&.prefixed_id, name: name, group_name: group_name,
          price_delta: price_delta.to_s('F'), quantity: quantity
        }
      end
    end
  end
end

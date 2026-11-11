# frozen_string_literal: true

module Spree
  module Pos
    # What one unit of a combo line contained when it was sold. The combo's
    # price stays on its own line; components never get a line item.
    class LineComponent < Record
      self.table_name = 'spree_pos_line_components'
      has_prefix_id :poslinecomp

      belongs_to :sale_line, class_name: 'Spree::Pos::SaleLine', inverse_of: :line_components
      belongs_to :variant, class_name: 'Spree::Variant'

      validates :name, presence: true
      validates :quantity, numericality: { only_integer: true, greater_than: 0 }

      def to_pos
        { id: prefixed_id, variant_id: variant.prefixed_id, name: name, quantity: quantity }
      end
    end
  end
end

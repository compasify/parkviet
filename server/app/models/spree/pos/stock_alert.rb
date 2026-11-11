# frozen_string_literal: true

module Spree
  module Pos
    # A branch's low-stock threshold for a variant, in its stock unit. Going
    # below it when a recipe is consumed records `stock.low`.
    class StockAlert < Record
      self.table_name = 'spree_pos_stock_alerts'
      has_prefix_id :posstockalert

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :variant, -> { with_deleted }, class_name: 'Spree::Variant'

      validates :min_quantity, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: (2**31) - 1 }
      validates :variant_id, uniqueness: { scope: :branch_id }

      def to_pos(on_hand:)
        {
          id: prefixed_id, branch_id: branch.prefixed_id, variant_id: variant.prefixed_id, name: variant.product&.name,
          sku: variant.sku.presence, options_text: variant.options_text.presence,
          base_unit: StockIntegration.base_unit_code(variant), min_quantity: min_quantity, on_hand: on_hand,
          low: on_hand < min_quantity
        }
      end
    end
  end
end

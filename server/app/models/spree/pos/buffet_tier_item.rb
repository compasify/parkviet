# frozen_string_literal: true

module Spree
  module Pos
    # A dish guests of a buffet tier may order, with an optional cap per round.
    class BuffetTierItem < Record
      self.table_name = 'spree_pos_buffet_tier_items'
      has_prefix_id :posbuffetitem

      belongs_to :buffet_tier, class_name: 'Spree::Pos::BuffetTier', inverse_of: :items
      belongs_to :product, class_name: 'Spree::Product'

      validates :max_per_round, numericality: { only_integer: true, in: 1..99 }, allow_nil: true

      def to_pos
        { id: prefixed_id, product_id: product.prefixed_id, variant_id: product.default_variant.prefixed_id,
          name: product.name, max_per_round: max_per_round }
      end
    end
  end
end

# frozen_string_literal: true

module Spree
  module Pos
    # One ingredient of a recipe version: the quantity as entered, and the
    # same quantity in the ingredient's stock unit, fixed when the version
    # was saved.
    class RecipeIngredient < Record
      self.table_name = 'spree_pos_recipe_ingredients'
      has_prefix_id :posrecipeing

      belongs_to :recipe, class_name: 'Spree::Pos::Recipe', inverse_of: :recipe_ingredients
      belongs_to :ingredient_variant, -> { with_deleted }, class_name: 'Spree::Variant'

      validates :quantity, numericality: { greater_than: 0 }
      validates :base_quantity, numericality: { only_integer: true, greater_than: 0 }
      validates :unit_code, :base_unit_code, presence: true

      # `unit_cost` is the ingredient's cost per stock unit now, or nil.
      def to_pos(unit_cost: nil)
        variant = ingredient_variant
        {
          id: prefixed_id, variant_id: variant.prefixed_id, name: variant.product&.name, sku: variant.sku.presence,
          options_text: variant.options_text.presence, quantity: quantity.to_s('F'), unit_code: unit_code,
          base_quantity: base_quantity, base_unit: base_unit_code, unit_cost: unit_cost&.to_s('F'),
          cost: unit_cost && (unit_cost * base_quantity).to_s('F')
        }
      end
    end
  end
end

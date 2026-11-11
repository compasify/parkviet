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
      # A pour (pour_ml of a bottle_ml bottle) moves no stock itself; the
      # open bottle does (Fnb::PourTracker).
      validates :base_quantity, numericality: { only_integer: true, greater_than: 0 }, unless: :pour?
      validates :pour_ml, :bottle_ml, numericality: { only_integer: true, greater_than: 0 }, if: :pour?
      validates :unit_code, :base_unit_code, presence: true

      def pour?
        pour_ml.present?
      end

      # `unit_cost` is the ingredient's cost per stock unit now, or nil.
      def to_pos(unit_cost: nil)
        variant = ingredient_variant
        {
          id: prefixed_id, variant_id: variant.prefixed_id, name: variant.product&.name, sku: variant.sku.presence,
          options_text: variant.options_text.presence, quantity: quantity.to_s('F'), unit_code: unit_code,
          base_quantity: base_quantity, base_unit: base_unit_code, unit_cost: unit_cost&.to_s('F'),
          cost: unit_cost && (pour? ? (unit_cost * pour_ml / bottle_ml).round(4) : unit_cost * base_quantity).to_s('F'),
          pour_ml: pour_ml, bottle_ml: bottle_ml
        }
      end
    end
  end
end

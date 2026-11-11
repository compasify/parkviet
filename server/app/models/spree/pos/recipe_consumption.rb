# frozen_string_literal: true

module Spree
  module Pos
    # What one source of one sale line used of one ingredient when the sale
    # completed: the size's recipe (`variant`), an option picked
    # (`modifier:<option id>`) or a combo part (`component:<variant id>`).
    # Written once per (line, ingredient, source); the recipe version and the
    # ingredient's cost per stock unit are copied at that time.
    class RecipeConsumption < Record
      self.table_name = 'spree_pos_recipe_consumptions'
      has_prefix_id :posrecipeuse

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :workspace, class_name: 'Spree::Pos::Workspace'
      belongs_to :order, class_name: 'Spree::Order'
      belongs_to :sale_line, class_name: 'Spree::Pos::SaleLine'
      belongs_to :ingredient_variant, -> { with_deleted }, class_name: 'Spree::Variant'
      belongs_to :stock_location, class_name: 'Spree::StockLocation'
      belongs_to :recipe, class_name: 'Spree::Pos::Recipe', optional: true

      validates :base_quantity, numericality: { only_integer: true, greater_than: 0 }
      validates :source_key, presence: true
    end
  end
end

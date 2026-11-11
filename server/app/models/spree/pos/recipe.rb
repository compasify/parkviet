# frozen_string_literal: true

module Spree
  module Pos
    # What one unit of a menu size (a variant) or one pick of a modifier
    # option uses. Versions are never changed: saving a recipe writes a new
    # version and retires the old one, so a consumption always names the
    # version it followed. An owner has at most one active version.
    class Recipe < Record
      self.table_name = 'spree_pos_recipes'
      has_prefix_id :posrecipe

      OWNER_TYPES = %w[Spree::Variant Spree::Pos::ModifierOption].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :owner, polymorphic: true
      belongs_to :created_by, class_name: staff_class_name, optional: true
      has_many :recipe_ingredients, -> { order(:id) }, class_name: 'Spree::Pos::RecipeIngredient', inverse_of: :recipe,
                                                       dependent: :delete_all

      scope :for_store, ->(store) { where(store_id: store.id) }
      scope :active, -> { where(active: true) }

      validates :owner_type, inclusion: { in: OWNER_TYPES }
      validates :version, numericality: { only_integer: true, greater_than: 0 }

      def self.for_owner(owner)
        where(owner_type: owner.class.name, owner_id: owner.id)
      end

      def to_pos(costs: {})
        ingredients = recipe_ingredients.map { |row| row.to_pos(unit_cost: costs[row.ingredient_variant_id]) }
        known = ingredients.map { |row| row[:cost] }
        {
          id: prefixed_id, version: version, active: active, created_at: created_at.iso8601,
          ingredients: ingredients,
          estimated_cost: known.any?(&:nil?) ? nil : known.sum { |value| BigDecimal(value) }.to_s('F')
        }
      end
    end
  end
end

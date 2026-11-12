# frozen_string_literal: true

module Spree
  module Pos
    # The POS side of one Spree product on the store's menu. The product's
    # variants are its sizes, its tax category is its tax rate. A combo is
    # sold at its own price and lists what it contains.
    class MenuItem < Record
      self.table_name = 'spree_pos_menu_items'
      has_prefix_id :posmenuitem

      KINDS = %w[single combo].freeze
      KITCHEN_CATEGORY = /\A[a-z_]{2,40}\z/

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :product, class_name: 'Spree::Product'
      belongs_to :menu_category, class_name: 'Spree::Pos::MenuCategory', optional: true
      has_many :menu_item_modifier_groups, -> { order(:position, :id) }, class_name: 'Spree::Pos::MenuItemModifierGroup',
                                                                        dependent: :delete_all, inverse_of: :menu_item
      has_many :modifier_groups, through: :menu_item_modifier_groups
      has_many :combo_components, -> { order(:id) }, class_name: 'Spree::Pos::ComboComponent', dependent: :delete_all,
                                                     inverse_of: :menu_item

      validates :kind, inclusion: { in: KINDS }
      validates :kitchen_category, format: { with: KITCHEN_CATEGORY }, allow_nil: true
      validates :drink_credit, numericality: { greater_than: 0 }, allow_nil: true
      validate :drink_credit_categories_valid
      validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :product_id, uniqueness: { scope: :store_id }
      validate :product_belongs_to_store
      validate :category_belongs_to_store

      scope :for_store, ->(store) { where(store_id: store.id) }
      scope :active, -> { where(active: true) }

      def combo?
        kind == 'combo'
      end

      # A door ticket: each one sold lets the guest drink this much of the
      # allowed kitchen categories (every category when none are named).
      def door_ticket?
        drink_credit.present?
      end

      # The active menu item a variant is sold as in a store, if any.
      def self.for_variant(store, variant)
        return if variant.nil?

        for_store(store).active.find_by(product_id: variant.product_id)
      end

      # The variants sold as sizes, by position. Spree 6 has no master: every
      # variant is sellable, except a legacy master left next to option
      # variants (the same rule as the catalog search). `now` drops sizes
      # discontinued by then.
      def sizes(now: nil)
        variants = product.variants.to_a
        variants = variants.reject { |variant| variant.discontinue_on.present? && variant.discontinue_on <= now } if now
        variants = variants.reject(&:is_master?) if variants.any?(&:is_master?) && !variants.all?(&:is_master?)
        variants.sort_by { |variant| [variant.position.to_i, variant.id] }
      end

      def to_pos
        {
          id: prefixed_id, product_id: product.prefixed_id, name: product.name, kind: kind,
          menu_category_id: menu_category&.prefixed_id, kitchen_category: kitchen_category, cup_label: cup_label,
          show_components_on_kds: show_components_on_kds, position: position, active: active, qr_orderable: qr_orderable,
          tax_category_id: product.tax_category.try(:prefixed_id),
          modifier_group_ids: menu_item_modifier_groups.map { |row| row.modifier_group.prefixed_id },
          components: combo_components.map(&:to_pos),
          drink_credit: drink_credit&.to_s('F'), drink_credit_categories: Array(drink_credit_categories)
        }
      end

      private

      def drink_credit_categories_valid
        values = drink_credit_categories
        return if values.is_a?(Array) && values.size <= 20 && values.all? { |value| value.is_a?(String) && value.match?(KITCHEN_CATEGORY) }

        errors.add(:drink_credit_categories, :invalid)
      end

      def product_belongs_to_store
        errors.add(:product, :invalid) if product && product.store_id != store_id
      end

      def category_belongs_to_store
        errors.add(:menu_category, :invalid) if menu_category && menu_category.store_id != store_id
      end
    end
  end
end

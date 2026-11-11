# frozen_string_literal: true

module Spree
  module Pos
    # What one combo contains: a variant and how many of it per combo.
    class ComboComponent < Record
      self.table_name = 'spree_pos_combo_components'
      has_prefix_id :poscombocomp

      MAX_QUANTITY = 100

      belongs_to :menu_item, class_name: 'Spree::Pos::MenuItem', inverse_of: :combo_components
      belongs_to :variant, class_name: 'Spree::Variant'

      validates :quantity, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: MAX_QUANTITY }
      validates :variant_id, uniqueness: { scope: :menu_item_id }
      validate :variant_belongs_to_store

      def self.label(variant)
        options = variant.respond_to?(:options_text) ? variant.options_text.to_s : ''
        [variant.product.name, options.presence].compact.join(' - ').first(200)
      end

      def to_pos
        { id: prefixed_id, variant_id: variant.prefixed_id, name: self.class.label(variant), quantity: quantity }
      end

      private

      def variant_belongs_to_store
        return if variant.nil? || menu_item.nil?

        errors.add(:variant, :invalid) if variant.product&.store_id != menu_item.store_id
      end
    end
  end
end

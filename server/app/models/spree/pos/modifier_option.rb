# frozen_string_literal: true

module Spree
  module Pos
    # One pick of a modifier group, with what it adds to the line price. It
    # may name the ingredient variant it uses, for stock deduction.
    class ModifierOption < Record
      self.table_name = 'spree_pos_modifier_options'
      has_prefix_id :posmodopt

      belongs_to :modifier_group, class_name: 'Spree::Pos::ModifierGroup', inverse_of: :modifier_options
      belongs_to :variant, class_name: 'Spree::Variant', optional: true

      validates :name, presence: true, length: { maximum: 80 }
      validates :price_delta, numericality: { greater_than_or_equal_to: 0, less_than: 100_000_000 }
      validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validate :variant_belongs_to_store

      def to_pos
        {
          id: prefixed_id, name: name, price_delta: price_delta.to_s('F'), variant_id: variant&.prefixed_id,
          default_selected: default_selected, position: position, active: active
        }
      end

      private

      def variant_belongs_to_store
        return if variant.nil? || modifier_group.nil?

        errors.add(:variant, :invalid) if variant.product&.store_id != modifier_group.store_id
      end
    end
  end
end

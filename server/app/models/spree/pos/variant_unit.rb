# frozen_string_literal: true

module Spree
  module Pos
    class VariantUnit < Record
      self.table_name = 'spree_pos_variant_units'
      has_prefix_id :posvariantunit

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :sale_unit, class_name: 'Spree::Pos::UnitDefinition'
      belongs_to :base_unit, class_name: 'Spree::Pos::UnitDefinition'
      belongs_to :price_unit, class_name: 'Spree::Pos::UnitDefinition'
      belongs_to :variant, class_name: 'Spree::Variant'

      scope :for_store, ->(store) { where(store_id: store.id) }

      validates :label_code, format: { with: /\A\d{1,8}\z/ }, allow_nil: true

      def to_pos(variant: nil)
        {
          variant_id: variant&.prefixed_id, sale_unit: sale_unit.code, base_unit: base_unit.code, price_unit: price_unit.code,
          ratio_numerator: ratio_numerator, ratio_denominator: ratio_denominator,
          tracked_mode: tracked_mode, version: version, status: status, label_code: label_code
        }
      end
    end
  end
end

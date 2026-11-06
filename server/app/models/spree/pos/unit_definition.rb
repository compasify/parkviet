# frozen_string_literal: true

module Spree
  module Pos
    class UnitDefinition < Record
      self.table_name = 'spree_pos_units'
      has_prefix_id :posunit

      belongs_to :store, class_name: 'Spree::Store'

      scope :for_store, ->(store) { where(store_id: store.id) }

      def self.ensure_defaults!(store)
        defaults = [
          ['item', 'Cái', 'count', 'item', 1, 0],
          ['g', 'Gram', 'mass', 'g', 1, 0],
          ['kg', 'Kilogram', 'mass', 'g', 1000, 3],
          ['ml', 'Mililit', 'volume', 'ml', 1, 0],
          ['l', 'Lít', 'volume', 'ml', 1000, 3],
          ['chai', 'Chai', 'count', 'chai', 1, 0],
          ['pack', 'Lốc', 'count', 'chai', 1, 0],
          ['case', 'Thùng', 'count', 'chai', 1, 0]
        ]
        defaults.map do |code, name, dimension, base_code, factor, precision|
          find_or_create_by!(store: store, code: code) do |unit|
            unit.name = name
            unit.dimension = dimension
            unit.base_code = base_code
            unit.factor_to_base = factor
            unit.sale_precision = precision
            unit.status = 'active'
          end
        end
      end

      def to_pos
        { id: prefixed_id, code: code, name: name, dimension: dimension, base_code: base_code, factor_to_base: factor_to_base, sale_precision: sale_precision, version: version }
      end
    end
  end
end

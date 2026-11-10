# frozen_string_literal: true

module Spree
  module Pos
    class UnitDefinition < Record
      self.table_name = 'spree_pos_units'
      has_prefix_id :posunit

      # [code, name, dimension, base_code, factor_to_base, sale_precision]
      DEFAULTS = [
        ['item', 'Cái', 'count', 'item', 1, 0],
        ['g', 'Gram', 'mass', 'g', 1, 0],
        ['kg', 'Kilogram', 'mass', 'g', 1000, 3],
        ['ml', 'Mililit', 'volume', 'ml', 1, 0],
        ['l', 'Lít', 'volume', 'ml', 1000, 3],
        ['chai', 'Chai', 'count', 'chai', 1, 0],
        ['pack', 'Lốc', 'count', 'chai', 1, 0],
        ['case', 'Thùng', 'count', 'chai', 1, 0]
      ].map(&:freeze).freeze
      DIMENSIONS = %w[mass volume count].freeze
      CODE_FORMAT = /\A[a-z][a-z0-9_]{0,15}\z/
      SAMPLES_PATH = 'config/pos/sample_units.yml'

      # Selling falls back to `item` for SKUs without a unit configuration.
      FALLBACK_CODE = 'item'
      # Fields that define what a quantity means; fixed once the unit exists.
      STRUCTURAL = %w[code dimension base_code factor_to_base].freeze

      belongs_to :store, class_name: 'Spree::Store'

      scope :for_store, ->(store) { where(store_id: store.id) }
      scope :active, -> { where(status: 'active') }

      before_validation do
        self.code = code.to_s.strip.downcase
        self.base_code = base_code.to_s.strip.downcase.presence || code
        self.name = name.to_s.strip
      end

      validates :code, format: { with: CODE_FORMAT }, uniqueness: { scope: :store_id }
      validates :name, presence: true, length: { maximum: 64 }
      validates :dimension, inclusion: { in: DIMENSIONS }
      validates :status, inclusion: { in: %w[active disabled] }
      validates :factor_to_base, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 1_000_000 }
      validates :sale_precision, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 3 }
      validate :converts_to_a_canonical_unit, on: :create

      def self.ensure_defaults!(store)
        create_missing!(store, DEFAULTS)
      end

      # Adds the named units (default or sample codes, see
      # config/pos/sample_units.yml) to the store, with the canonical unit
      # each one converts to. Units the store already has are left as they
      # are, so calling it again changes nothing.
      def self.ensure_samples!(store, codes)
        codes = Array(codes).map(&:to_s).uniq
        unknown = codes - known_codes
        raise ArgumentError, "Unknown unit codes: #{unknown.join(', ')}" if unknown.any?

        rows = codes.map { |code| unit_row(code) }
        bases = rows.map { |row| row[3] }.uniq - rows.map(&:first)
        create_missing!(store, bases.map { |code| unit_row(code) } + rows)
      end

      # Every code a profile may name: the defaults and the samples.
      def self.known_codes
        DEFAULTS.map(&:first) + samples.keys
      end

      # { 'vien' => ['vien', 'Viên', 'count', 'vien', 1, 0], ... }
      def self.samples
        @samples ||= load_samples
      end

      def self.unit_row(code)
        DEFAULTS.find { |row| row.first == code } || samples.fetch(code)
      end

      def self.load_samples
        data = YAML.safe_load_file(Rails.root.join(SAMPLES_PATH))
        units = data.is_a?(Hash) ? data['units'] : nil
        raise ArgumentError, "#{SAMPLES_PATH}: `units` must be a mapping." unless units.is_a?(Hash)

        units.to_h do |code, attrs|
          code = code.to_s
          where = "#{SAMPLES_PATH}: unit #{code.inspect}"
          raise ArgumentError, "#{where}: code must match #{CODE_FORMAT.source}." unless code.match?(CODE_FORMAT)
          raise ArgumentError, "#{where}: reuses a default unit code." if DEFAULTS.any? { |row| row.first == code }
          raise ArgumentError, "#{where}: needs a name." unless attrs.is_a?(Hash) && attrs['name'].to_s.strip.present?
          raise ArgumentError, "#{where}: name is longer than 64 characters." if attrs['name'].to_s.length > 64
          raise ArgumentError, "#{where}: dimension must be one of #{DIMENSIONS.join(', ')}." unless DIMENSIONS.include?(attrs['dimension'])

          [code, [code, attrs['name'].to_s, attrs['dimension'], code, 1, 0].freeze]
        end.freeze
      end
      private_class_method :load_samples, :unit_row

      # One query for the codes the store already has, then a write only for
      # the missing ones. Selling calls this on every add, where every unit
      # normally exists; eight find_or_create_by! round trips made each add slower.
      def self.create_missing!(store, rows)
        existing = where(store_id: store.id, code: rows.map(&:first)).pluck(:code).to_set
        rows.reject { |row| existing.include?(row.first) }.map do |code, name, dimension, base_code, factor, precision|
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
      private_class_method :create_missing!

      def disabled?
        status == 'disabled'
      end

      # Why the unit cannot be disabled, or nil when it can.
      def disable_blocker
        return 'The fallback unit cannot be disabled.' if code == FALLBACK_CODE

        configured = VariantUnit.where(store_id: store_id, status: 'active').
                     where('sale_unit_id = :id OR base_unit_id = :id OR price_unit_id = :id', id: id)
        return 'This unit is used by SKU unit configurations.' if configured.exists?

        derived = self.class.where(store_id: store_id, status: 'active', base_code: code).where.not(id: id)
        return 'Other units convert to this unit.' if derived.exists?

        labels = LabelFormat.where(store_id: store_id, status: 'active', value_unit_code: code)
        return 'Active scale label formats use this unit.' if labels.exists?

        nil
      end

      def to_pos
        { id: prefixed_id, code: code, name: name, dimension: dimension, base_code: base_code, factor_to_base: factor_to_base,
          sale_precision: sale_precision, version: version, status: status }
      end

      private

      # Factors are relative to the canonical unit of the dimension: either
      # the unit itself (factor 1) or a canonical unit of the store.
      def converts_to_a_canonical_unit
        return if code.blank? || base_code.blank?

        if base_code == code
          errors.add(:factor_to_base, :invalid) unless factor_to_base == 1
          return
        end
        base = store && self.class.find_by(store_id: store.id, code: base_code)
        valid = base && base.base_code == base.code && base.dimension == dimension
        errors.add(:base_code, :invalid) unless valid
      end
    end
  end
end

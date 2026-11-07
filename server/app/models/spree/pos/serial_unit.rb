# frozen_string_literal: true

module Spree
  module Pos
    # One serial/IMEI unit of a serial-tracked variant. Unique per store,
    # variant and serial; its status and location say where it is.
    # in_stock, reserved and quarantined units are on the shelf; a sold unit
    # stays on it until the handover consumes its allocation.
    class SerialUnit < Record
      self.table_name = 'spree_pos_serial_units'
      has_prefix_id :posserial

      STATUSES = %w[in_stock reserved sold returned quarantined removed].freeze
      ON_SHELF = %w[in_stock reserved quarantined].freeze
      MAX_LENGTH = 100

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :variant, class_name: 'Spree::Variant'
      belongs_to :stock_location, class_name: 'Spree::StockLocation'
      has_many :trace_allocations, class_name: 'Spree::Pos::TraceAllocation'

      validates :status, inclusion: { in: STATUSES }
      validates :serial, presence: true, length: { maximum: MAX_LENGTH }

      scope :for_store, ->(store) { where(store_id: store.id) }

      # Trimmed and case-preserving; a serial has no spaces or control characters.
      def self.normalize(value)
        serial = value.to_s.strip
        raise Conflict.new('Serial number is invalid.', reason: 'trace_serial_invalid') unless serial.match?(/\A[[:graph:]]{1,#{MAX_LENGTH}}\z/)

        serial
      end

      def to_pos
        {
          id: prefixed_id, variant_id: variant.prefixed_id, sku: variant.sku, name: variant.product.name,
          serial: serial, status: status, stock_location_id: stock_location.prefixed_id,
          branch_id: Branch.find_by(stock_location_id: stock_location_id)&.prefixed_id,
          quarantine_reason: quarantine_reason, updated_at: updated_at.iso8601
        }
      end
    end
  end
end

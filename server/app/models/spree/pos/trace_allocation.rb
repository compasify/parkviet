# frozen_string_literal: true

module Spree
  module Pos
    # Links one sale line to one serial unit or one lot for a quantity in base
    # units: reserved (bound to the draft, with a TTL unless a payment holds
    # the snapshot) -> committed (order placed) -> consumed (handed over). A
    # reservation may be released instead. Once committed, the allocations of
    # a line add up to its base quantity.
    class TraceAllocation < Record
      self.table_name = 'spree_pos_trace_allocations'
      has_prefix_id :postrace

      TTL = 15.minutes
      STATUSES = %w[reserved committed consumed released].freeze
      SOLD = %w[committed consumed].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :workspace, class_name: 'Spree::Pos::Workspace'
      belongs_to :sale_line, class_name: 'Spree::Pos::SaleLine'
      belongs_to :order, class_name: 'Spree::Order'
      belongs_to :variant, class_name: 'Spree::Variant'
      belongs_to :stock_location, class_name: 'Spree::StockLocation'
      belongs_to :inventory_lot, class_name: 'Spree::Pos::InventoryLot', optional: true
      belongs_to :serial_unit, class_name: 'Spree::Pos::SerialUnit', optional: true
      belongs_to :fulfillment_item, class_name: 'Spree::FulfillmentItem', optional: true
      has_many :trace_returns, class_name: 'Spree::Pos::TraceReturn'

      validates :status, inclusion: { in: STATUSES }

      scope :sold, -> { where(status: SOLD) }

      # A reservation without an expiry is held by a payment in progress.
      def live?(now = Workspace.database_now)
        return true if SOLD.include?(status)
        return false unless status == 'reserved'

        expires_at.nil? || expires_at > now
      end

      def kind
        serial_unit_id ? 'serial' : 'lot'
      end

      def to_pos
        {
          id: prefixed_id, kind: kind, serial: serial_unit&.serial, lot_code: inventory_lot&.lot_code,
          expiry_on: inventory_lot&.expiry_on&.iso8601, quantity: quantity, status: status,
          expires_at: status == 'reserved' ? expires_at&.iso8601 : nil
        }
      end

      def to_sold_pos
        {
          serial: serial_unit&.serial, lot_code: inventory_lot&.lot_code, expiry_on: inventory_lot&.expiry_on&.iso8601,
          quantity: quantity, returned_quantity: returned_quantity
        }
      end
    end
  end
end

# frozen_string_literal: true

module Spree
  module Pos
    # One batch of a lot-tracked variant at one stock location, in integer
    # base units. `on_hand` is what the lot physically holds and may sell
    # while active and unexpired; `quarantined_quantity` is held back
    # (damaged or expired returns) and never sold. Both count in the core shelf.
    class InventoryLot < Record
      self.table_name = 'spree_pos_inventory_lots'
      has_prefix_id :poslot

      STATUSES = %w[active quarantined expired].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :variant, class_name: 'Spree::Variant'
      belongs_to :stock_location, class_name: 'Spree::StockLocation'
      belongs_to :source_lot, class_name: 'Spree::Pos::InventoryLot', optional: true
      belongs_to :quarantined_by, class_name: staff_class_name, optional: true
      has_many :trace_allocations, class_name: 'Spree::Pos::TraceAllocation'

      validates :status, inclusion: { in: STATUSES }
      validates :lot_code, presence: true, length: { maximum: 64 }

      scope :for_store, ->(store) { where(store_id: store.id) }

      def expired_on?(date)
        expiry_on.present? && expiry_on < date
      end

      def effective_status(today)
        return status unless status == 'active'

        expired_on?(today) ? 'expired' : 'active'
      end

      # Units held by allocations that have not left the shelf yet. A
      # reservation of `except_workspace_id` is not counted against it.
      def holds(now = Workspace.database_now, except_workspace_id: nil)
        rows = trace_allocations.where(status: %w[reserved committed]).to_a
        reserved = rows.select { |row| row.status == 'reserved' && row.live?(now) && row.workspace_id != except_workspace_id }.sum(&:quantity)
        committed = rows.select { |row| row.status == 'committed' }.sum(&:quantity)
        { reserved: reserved, committed: committed }
      end

      def available(now = Workspace.database_now, except_workspace_id: nil)
        held = holds(now, except_workspace_id: except_workspace_id)
        on_hand - held[:reserved] - held[:committed]
      end

      def to_pos(today: Date.current, holds: nil)
        holds ||= self.holds
        {
          id: prefixed_id, variant_id: variant.prefixed_id, sku: variant.sku, name: variant.product.name,
          stock_location_id: stock_location.prefixed_id,
          branch_id: Branch.find_by(stock_location_id: stock_location_id)&.prefixed_id,
          lot_code: lot_code, expiry_on: expiry_on&.iso8601, status: effective_status(today),
          received_quantity: received_quantity, on_hand: on_hand, quarantined_quantity: quarantined_quantity,
          reserved: holds[:reserved], committed: holds[:committed],
          available: [on_hand - holds[:reserved] - holds[:committed], 0].max,
          base_unit: StockIntegration.base_unit_code(variant), source_lot_id: source_lot&.prefixed_id,
          quarantine_reason: quarantine_reason, created_at: created_at.iso8601
        }
      end
    end
  end
end

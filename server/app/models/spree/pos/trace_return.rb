# frozen_string_literal: true

module Spree
  module Pos
    # Units of one sold trace allocation taken back by a return. Reserved at
    # prepare (the allocation's returned_quantity counts it, so the same unit
    # cannot be returned twice), received once at the receiving location.
    class TraceReturn < Record
      self.table_name = 'spree_pos_trace_returns'
      has_prefix_id :postraceret

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :return_operation, class_name: 'Spree::Pos::ReturnOperation'
      belongs_to :trace_allocation, class_name: 'Spree::Pos::TraceAllocation'
      belongs_to :return_lot, class_name: 'Spree::Pos::InventoryLot', optional: true

      validates :status, inclusion: { in: %w[reserved received canceled] }
      validates :condition, inclusion: { in: %w[resellable damaged] }

      def to_pos
        allocation = trace_allocation
        {
          sale_line_id: allocation.sale_line.prefixed_id, serial: allocation.serial_unit&.serial,
          lot_code: allocation.inventory_lot&.lot_code, expiry_on: allocation.inventory_lot&.expiry_on&.iso8601,
          quantity: quantity, condition: condition, status: status
        }
      end
    end
  end
end

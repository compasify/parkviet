# frozen_string_literal: true

module Spree
  module Pos
    # Returned quantity of one immutable SaleLine, in sequence with every other
    # return of that line. Its components are the delta between the cumulative
    # entitlement after and before it; a posted reservation never changes.
    class ReturnReservation < Record
      self.table_name = 'spree_pos_return_reservations'
      has_prefix_id :posretline

      HOLDING = %w[reserved posted].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :return_operation, class_name: 'Spree::Pos::ReturnOperation'
      belongs_to :sale_line, class_name: 'Spree::Pos::SaleLine'
      belongs_to :line_item, class_name: 'Spree::LineItem'
      belongs_to :fulfillment_item, class_name: 'Spree::FulfillmentItem'
      belongs_to :return_line_item, class_name: 'Spree::ReturnLineItem'

      validates :status, inclusion: { in: %w[reserved posted canceled] }
      validates :condition, inclusion: { in: %w[resellable damaged] }

      scope :holding, -> { where(status: HOLDING) }

      def components
        ReturnEntitlement::Components.new(total: total, net: net, tax: tax, discount: discount, gross: gross)
      end

      def to_pos
        {
          id: prefixed_id, sale_line_id: sale_line.prefixed_id, line_item_id: line_item.prefixed_id,
          name: line_item.variant.product.name, sku: line_item.variant.sku,
          quantity: quantity, sequence: sequence, cumulative_before: cumulative_before, cumulative_after: cumulative_after,
          condition: condition, status: status, received_quantity: received_quantity, restocked_quantity: restocked_quantity,
          total: total.to_s('F'), net: net.to_s('F'), tax: tax.to_s('F'), discount: discount.to_s('F'), gross: gross.to_s('F'),
          trace: TraceReturn.joins(:trace_allocation).where(return_operation_id: return_operation_id).
                 where(spree_pos_trace_allocations: { sale_line_id: sale_line_id }).order(:id).map(&:to_pos)
        }
      end
    end
  end
end

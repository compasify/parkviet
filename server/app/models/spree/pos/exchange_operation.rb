# frozen_string_literal: true

module Spree
  module Pos
    # Links a return to the replacement sale. Each leg keeps its own
    # documents: the return posts credit notes and refund entitlement, the
    # replacement is an ordinary sale paid through normal tenders. The
    # difference is only presented here, never netted into either leg.
    class ExchangeOperation < Record
      self.table_name = 'spree_pos_exchange_operations'
      has_prefix_id :posexchange

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :return_operation, class_name: 'Spree::Pos::ReturnOperation'
      belongs_to :replacement_workspace, class_name: 'Spree::Pos::Workspace'
      belongs_to :actor, class_name: staff_class_name

      scope :for_store, ->(store) { where(store_id: store.id) }

      # What still moves between store and customer: the replacement total
      # against the refund this return gives (estimated by the same split as
      # posting while it is not posted), less refunds already paid out. The
      # amounts are null until the replacement has a total.
      def to_pos
        operation = return_operation
        replacement = replacement_workspace
        order = replacement.order
        split = operation.expected_split
        paid_back = operation.refunded
        owed = [split[:refund] - paid_back, BigDecimal('0')].max
        priced = order.total.positive?
        difference = order.total - owed
        {
          id: prefixed_id, branch_id: branch.prefixed_id, return_id: operation.prefixed_id,
          return_status: operation.status, entitlement_status: operation.entitlement_status,
          entitlement_total: operation.entitlement_total.to_s('F'),
          credit_note_amount: split[:credit_note].to_s('F'), refund_entitlement: split[:refund].to_s('F'),
          refunded: paid_back.to_s('F'), refund_owed: owed.to_s('F'),
          replacement_workspace_id: replacement.prefixed_id, replacement_order_number: order.number,
          replacement_status: replacement.operational_status, replacement_total: order.total.to_s('F'),
          currency: operation.currency,
          customer_pays: priced ? [difference, BigDecimal('0')].max.to_s('F') : nil,
          store_refunds: priced ? [-difference, BigDecimal('0')].max.to_s('F') : nil,
          created_at: created_at&.iso8601
        }
      end
    end
  end
end

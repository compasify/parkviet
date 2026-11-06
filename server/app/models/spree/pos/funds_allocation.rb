# frozen_string_literal: true

module Spree
  module Pos
    class FundsAllocation < Record
      self.table_name = 'spree_pos_funds_allocations'
      has_prefix_id :posalloc

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :received_funds, class_name: 'Spree::Pos::ReceivedFunds'
      belongs_to :workspace, class_name: 'Spree::Pos::Workspace'
      belongs_to :order, class_name: 'Spree::Order'
      belongs_to :payment, class_name: 'Spree::Payment', optional: true

      validates :status, inclusion: { in: %w[active reversed] }
      validates :currency, presence: true

      scope :for_store, ->(store) { where(store_id: store.id) }
      scope :active_now, -> { where(status: 'active') }

      def to_pos
        { id: prefixed_id, received_funds_id: received_funds.prefixed_id,
          workspace_id: workspace.prefixed_id, order_id: order.prefixed_id,
          payment_id: payment&.prefixed_id, status: status, amount: amount.to_s('F'),
          currency: currency, reversed_at: reversed_at&.iso8601 }
      end
    end
  end
end

# frozen_string_literal: true

module Spree
  module Pos
    # Debt collection context around one actual receipt. The money itself is
    # the parent ReceivedFunds; child FundsAllocations (with their own core
    # Payments) settle specific debtor orders. Unallocated money stays
    # available on the parent for later allocation or a liability payout.
    class Collection < Record
      self.table_name = 'spree_pos_collections'
      has_prefix_id :poscollect

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :credit_account, class_name: 'Spree::Pos::CreditAccount'
      belongs_to :received_funds, class_name: 'Spree::Pos::ReceivedFunds'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :actor, class_name: staff_class_name
      has_many :allocations, class_name: 'Spree::Pos::FundsAllocation', foreign_key: :collection_id,
                             dependent: :restrict_with_error

      scope :for_store, ->(store) { where(store_id: store.id) }

      def to_pos
        {
          id: prefixed_id, credit_account_id: credit_account.prefixed_id, branch_id: branch.prefixed_id,
          customer_id: credit_account.customer_profile.prefixed_id, note: note,
          funds: received_funds.to_pos,
          allocations: allocations.includes(:order).order(:id).map(&:to_pos),
          created_at: created_at&.iso8601
        }
      end
    end
  end
end

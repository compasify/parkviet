# frozen_string_literal: true

module Spree
  module Pos
    # One line of a stored value ledger, signed: money in is positive, money
    # out negative. Written once and never changed; a correction is an
    # `adjust` line of its own.
    class StoredValueEntry < Record
      self.table_name = 'spree_pos_stored_value_entries'
      has_prefix_id :posstoredentry

      KINDS = %w[top_up spend refund adjust].freeze

      belongs_to :stored_value_account, class_name: 'Spree::Pos::StoredValueAccount', inverse_of: :entries
      belongs_to :received_funds, class_name: 'Spree::Pos::ReceivedFunds', optional: true
      belongs_to :funds_allocation, class_name: 'Spree::Pos::FundsAllocation', optional: true
      belongs_to :liability_payout, class_name: 'Spree::Pos::LiabilityPayout', optional: true
      belongs_to :workspace, class_name: 'Spree::Pos::Workspace', optional: true
      belongs_to :actor, class_name: staff_class_name

      validates :kind, inclusion: { in: KINDS }
      validates :note, length: { maximum: 255 }

      before_update { raise ActiveRecord::ReadOnlyRecord, 'Stored value entries are append-only.' }
      before_destroy { raise ActiveRecord::ReadOnlyRecord, 'Stored value entries are append-only.' }

      def to_pos
        {
          id: prefixed_id, kind: kind, amount: amount.to_s('F'), minutes: minutes, funds_id: received_funds&.prefixed_id,
          payout_id: liability_payout&.prefixed_id, workspace_id: workspace&.prefixed_id,
          order_number: workspace&.order&.number, actor: { id: actor.prefixed_id, name: StaffName.call(actor) },
          note: note, created_at: created_at.iso8601
        }
      end
    end
  end
end

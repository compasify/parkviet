# frozen_string_literal: true

module Spree
  module Pos
    # A manager's custody decision for cash that a closed snapshot or the
    # ledger could not place: a closed shift's overage and/or a held receipt
    # (late cash attested after its shift). It links them to where the money
    # physically is now. Only `new_physical_inflow` moves drawer cash (one
    # CashMovement into the target open shift); the other outcomes record
    # custody that is already counted elsewhere (an opening float, the safe, a
    # handover), so the current drawer's expected cash is not inflated.
    class CashReconciliation < Record
      self.table_name = 'spree_pos_cash_reconciliations'
      has_prefix_id :poscashrec

      OUTCOMES = %w[in_opening_float safe handed_over new_physical_inflow].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :shift_closure, class_name: 'Spree::Pos::ShiftClosure', optional: true
      belongs_to :received_funds, class_name: 'Spree::Pos::ReceivedFunds', optional: true
      belongs_to :target_shift, class_name: 'Spree::Pos::Shift', optional: true
      belongs_to :actor, class_name: staff_class_name
      has_one :cash_movement, class_name: 'Spree::Pos::CashMovement', dependent: :restrict_with_error

      validates :outcome, inclusion: { in: OUTCOMES }
      validates :reason, presence: true, length: { maximum: 200 }
      validates :custody_reference, length: { maximum: 120 }
      validates :currency, presence: true

      scope :for_store, ->(store) { where(store_id: store.id) }

      def readonly?
        persisted? || super
      end

      def to_pos
        {
          id: prefixed_id, branch_id: branch.prefixed_id, outcome: outcome, amount: amount.to_s('F'),
          currency: currency, reason: reason, custody_reference: custody_reference,
          shift_closure_id: shift_closure&.prefixed_id, closed_shift_id: shift_closure&.shift&.prefixed_id,
          received_funds_id: received_funds&.prefixed_id, received_at: received_funds&.received_at&.iso8601,
          target_shift_id: target_shift&.prefixed_id, cash_movement_id: cash_movement&.prefixed_id,
          actor_id: actor.prefixed_id, actor_name: StaffName.call(actor), created_at: created_at&.iso8601
        }
      end
    end
  end
end

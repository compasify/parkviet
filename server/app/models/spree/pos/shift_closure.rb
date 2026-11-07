# frozen_string_literal: true

module Spree
  module Pos
    # Immutable closing snapshot of one shift: the cash movements up to the
    # cutoff, what the drawer should hold, what was counted and the variance.
    # It is written once in the close transaction and never updated; later
    # facts (late cash, custody) are linked through CashReconciliation.
    class ShiftClosure < Record
      self.table_name = 'spree_pos_shift_closures'
      has_prefix_id :posclosure

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :register, class_name: 'Spree::Pos::Register', optional: true
      belongs_to :shift, class_name: 'Spree::Pos::Shift'
      belongs_to :closer, class_name: staff_class_name
      belongs_to :approver, class_name: staff_class_name, optional: true
      belongs_to :approval, class_name: 'Spree::Pos::Approval', optional: true
      has_many :cash_reconciliations, class_name: 'Spree::Pos::CashReconciliation', dependent: :restrict_with_error

      validates :currency, :closed_at, :opened_at, presence: true
      validates :reason, length: { maximum: 200 }

      scope :for_store, ->(store) { where(store_id: store.id) }

      def readonly?
        persisted? || super
      end

      # Overage already explained by late-cash reconciliations.
      def reconciled_amount
        cash_reconciliations.sum(:amount)
      end

      def to_pos
        {
          id: prefixed_id, shift_id: shift.prefixed_id, branch_id: branch.prefixed_id,
          register_id: register&.prefixed_id, closer_id: closer.prefixed_id, closer_name: StaffName.call(closer),
          approver_id: approver&.prefixed_id, approver_name: approver && StaffName.call(approver),
          currency: currency, opening_float: opening_float.to_s('F'), inflow_total: inflow_total.to_s('F'),
          outflow_total: outflow_total.to_s('F'), expected: expected.to_s('F'), counted: counted.to_s('F'),
          variance: variance.to_s('F'), variance_threshold: variance_threshold&.to_s('F'), reason: reason,
          cutoff_movement_id: cutoff_movement_id && CashMovement.find_by(id: cutoff_movement_id)&.prefixed_id,
          movement_count: movement_count, breakdown: breakdown, reconciled: reconciled_amount.to_s('F'),
          opened_at: opened_at.iso8601, closed_at: closed_at.iso8601
        }
      end
    end
  end
end

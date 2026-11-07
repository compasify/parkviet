# frozen_string_literal: true

module Spree
  module Pos
    # A draft left on a closed shift without any received money continues on
    # its cashier's current open shift at the same branch when they resume it.
    # Drafts holding money never move (they block the close instead). Called
    # under the workspace lock; takes the new shift's barrier next, keeping
    # the workspace -> shift lock order. Audited.
    module ShiftRebind
      module_function

      def call(workspace:, staff:)
        old = workspace.shift
        return if old.open? || old.owner_id != staff.id
        return unless %w[editing parked].include?(workspace.operational_status)
        return if ReceivedFunds.exists?(workspace_id: workspace.id)

        target = Shift.for_store(workspace.store).open_now.where(branch_id: workspace.branch_id, owner_id: staff.id).
                 order(opened_at: :desc).first
        return if target.nil?

        ShiftBarrier.hold!(target)
        workspace.rebind_shift!(target)
        AuditEntry.record!(store: workspace.store, actor: staff, action: 'workspace.rebind_shift', subject: workspace,
                           metadata: { from_shift_id: old.prefixed_id, to_shift_id: target.prefixed_id })
      end
    end
  end
end

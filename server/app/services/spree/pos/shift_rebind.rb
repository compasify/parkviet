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

        target = open_shift_of(workspace, staff)
        return if target.nil?

        move!(workspace, staff, old, target, 'workspace.rebind_shift')
      end

      # A table's bill taken by a cashier other than the shift owner: the
      # order moves to the collector's open shift so the money lands in their
      # drawer. Only while it holds no money; with money it stays where the
      # money is (`strict` refuses a new tender there instead).
      def rebind_to_collector!(workspace:, staff:, strict: true)
        old = workspace.shift
        return if old.owner_id == staff.id || workspace.resource_id.nil?

        if ReceivedFunds.exists?(workspace_id: workspace.id)
          return unless strict

          raise Conflict.new('This table already took money on another shift.', revision: workspace.revision, reason: 'shift_has_funds')
        end

        target = open_shift_of(workspace, staff)
        raise Conflict.new('Open a shift to collect this table.', revision: workspace.revision, reason: 'no_open_shift') if target.nil?

        move!(workspace, staff, old, target, 'workspace.rebind_collector')
      end

      def open_shift_of(workspace, staff)
        Shift.for_store(workspace.store).open_now.where(branch_id: workspace.branch_id, owner_id: staff.id).
          order(opened_at: :desc).first
      end

      def move!(workspace, staff, old, target, action)
        ShiftBarrier.hold!(target)
        workspace.rebind_shift!(target)
        AuditEntry.record!(store: workspace.store, actor: staff, action: action, subject: workspace,
                           metadata: { from_shift_id: old.prefixed_id, to_shift_id: target.prefixed_id })
      end
    end
  end
end

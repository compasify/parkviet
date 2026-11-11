# frozen_string_literal: true

module Spree
  module Pos
    module Fnb
      # Lets a VIP table off its minimum spend on one order, or puts the
      # minimum back. Waiving takes money off the bill, so it needs an
      # approval of `tab.waive_minimum_spend` for the fee's amount unless the
      # cashier may approve; putting it back needs nothing. Only while the
      # snapshot is editable, and audited.
      module WaiveMinimumSpend
        ACTION = Approval::MINIMUM_SPEND_WAIVE_ACTION

        module_function

        def call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, waived:, approval_id: nil)
          waived = ActiveModel::Type::Boolean.new.cast(waived) == true
          payload = { 'command' => ACTION, 'revision' => revision, 'lease_generation' => lease_generation,
                      'editor_digest' => Workspace.editor_digest(editor_id), 'waived' => waived, 'approval_id' => approval_id.to_s.presence }
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace,
                               authorize: -> { Workspaces::ApplyDiscount.authorize!(workspace, staff) }) do
            Workspaces::ApplyDiscount.validate_command!(workspace, staff, revision, lease_generation, editor_id)
            ModulePolicy.require!(workspace.branch, MinimumSpend::MODULE)
            if MinimumSpend.minimum_for(workspace).nil?
              raise Conflict.new('This table has no minimum spend.', revision: workspace.revision, reason: 'minimum_spend_none')
            end

            fee = workspace.order.fees.detect { |row| row.kind == MinimumSpend::KIND }
            approval = nil
            if waived && !workspace.minimum_spend_waived
              approval = Workspaces::ApplyDiscount.approve!(workspace, staff, revision, approval_id, amount: fee&.amount || BigDecimal('0'),
                                                                                                     action: ACTION, capability: Capabilities::APPROVE,
                                                                                                     message: 'Minimum spend waiver approval is required.')
            end
            before = workspace.order.fee_total
            workspace.update!(minimum_spend_waived: waived)
            MinimumSpend.call(workspace)
            workspace.update!(revision: workspace.revision + 1)
            AuditEntry.record!(store: workspace.store, actor: staff, subject: workspace,
                               action: waived ? 'workspace.minimum_spend.waive' : 'workspace.minimum_spend.restore',
                               metadata: { fee_total_before: before.to_s('F'), fee_total: workspace.order.fee_total.to_s('F'),
                                           total: workspace.order.total.to_s('F') }.merge(Workspaces::ApplyDiscount.approval_metadata(approval)))
            workspace.to_pos
          end
        end
      end
    end
  end
end

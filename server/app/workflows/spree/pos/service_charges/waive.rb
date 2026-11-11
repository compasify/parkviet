# frozen_string_literal: true

module Spree
  module Pos
    module ServiceCharges
      # The cashier takes the service charge off one order, or puts it back.
      # Needs the discount capability, changes the quoted money (so only while
      # the snapshot is editable) and is audited.
      module Waive
        module_function

        def call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, waived:)
          waived = ActiveModel::Type::Boolean.new.cast(waived) == true
          payload = { 'command' => 'service_charge.waive', 'revision' => revision, 'lease_generation' => lease_generation,
                      'editor_digest' => Workspace.editor_digest(editor_id), 'waived' => waived }
          authorize = lambda do
            Workspaces::ApplyDiscount.authorize!(workspace, staff)
            raise CanCan::AccessDenied unless AccessPolicy.new(store: workspace.store, staff: staff).allows?(workspace.branch, Capabilities::DISCOUNT)
          end
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace, authorize: authorize) do
            Workspaces::ApplyDiscount.validate_command!(workspace, staff, revision, lease_generation, editor_id)
            ModulePolicy.require!(workspace.branch, Apply::MODULE)
            before = workspace.order.fee_total
            workspace.update!(service_charge_waived: waived)
            Apply.call(workspace)
            workspace.update!(revision: workspace.revision + 1)
            AuditEntry.record!(store: workspace.store, actor: staff, action: waived ? 'workspace.service_charge.waive' : 'workspace.service_charge.restore',
                               subject: workspace, metadata: { fee_total_before: before.to_s('F'), fee_total: workspace.order.fee_total.to_s('F'),
                                                               total: workspace.order.total.to_s('F') })
            workspace.to_pos
          end
        end
      end
    end
  end
end

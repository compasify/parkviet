# frozen_string_literal: true

module Spree
  module Pos
    module OfflineSales
      # A manager decides an offline sale waiting for review should not stand
      # (sold by mistake, a test, a duplicate the counter recorded twice). Its
      # parked order is canceled; it never held money. The cash the counter
      # took is not booked anywhere, so it shows as the shift's overage at
      # the count and is placed through the late cash reconciliation. The
      # reason and the amount are audited.
      module Reject
        module_function

        def call(store:, staff:, key:, sale:, reason:)
          text = reason.to_s.squish
          raise Conflict.new('Say why this sale is rejected.', reason: 'reason_required') if text.blank? || text.length > 200

          workspace = sale.workspace
          payload = { 'command' => 'offline_sale.reject', 'offline_sale_id' => sale.prefixed_id, 'reason' => text }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, workspace: workspace,
                               authorize: -> { authorize!(store, staff, sale) }) do
            sale.lock!
            raise Conflict.new('This offline sale is already settled.', reason: 'offline_sale_settled') unless sale.status == 'needs_review'

            cancel!(workspace, staff, sale) if workspace && %w[parked editing].include?(workspace.operational_status)
            sale.update!(status: 'rejected', resolution: 'rejected', resolution_note: text, resolved_by: staff, resolved_at: Time.current)
            AuditEntry.record!(store: store, actor: staff, action: 'offline_sale.reject', subject: workspace || sale.shift,
                               metadata: { offline_sale_id: sale.prefixed_id, provisional_number: sale.provisional_number,
                                           collected: sale.collected_total.to_s('F'), shift_id: sale.shift.prefixed_id, reason: text })
            sale.reload.to_pos
          end
          sale.reload.to_pos
        end

        # A manager of the branch: someone who approves there.
        def authorize!(store, staff, sale)
          raise ActiveRecord::RecordNotFound unless sale.store_id == store.id

          policy = AccessPolicy.new(store: store, staff: staff)
          raise CanCan::AccessDenied unless policy.permission?('write_pos_orders') && policy.allows?(sale.branch, Capabilities::APPROVE)
        end

        # The parked order goes away as a cancel would take it: never with
        # money on it, its reservations released, audited.
        def cancel!(workspace, staff, sale)
          raise Conflict.new('This order already holds money.', reason: 'payments_recorded') if Workspaces::ChangeStatus.money_recorded?(workspace)

          Inventory::AllocateTraceability.release!(workspace)
          workspace.update!(operational_status: 'canceled', revision: workspace.revision + 1)
          AuditEntry.record!(store: workspace.store, actor: staff, action: 'workspace.canceled', subject: workspace,
                             metadata: { offline_sale_id: sale.prefixed_id })
        end
      end
    end
  end
end

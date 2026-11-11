# frozen_string_literal: true

module Spree
  module Pos
    module PlatformOrders
      # The driver took the order: the sale is settled with what the platform
      # owes for it and completed, through the same commands as any sale at
      # the counter. The cashier takes editing of the draft, prepares and
      # confirms one `platform_receivable` tender for the order total with the
      # platform order as its evidence (received funds, no drawer movement),
      # then completes it, which issues the receipt and queues the e-invoice.
      # One command: it all commits together, or none of it does.
      module Complete
        EVIDENCE = 'platform_order'

        module_function

        def call(platform_order:, staff:, key:, editor_id:)
          workspace = platform_order.workspace
          payload = {
            'command' => 'platform_order.complete', 'platform_order_id' => platform_order.prefixed_id,
            'editor_digest' => Workspace.editor_digest(editor_id)
          }
          authorize = lambda do
            Tenders::Guard.authorize_editor!(workspace, staff)
            Tenders::Guard.authorize_collect!(workspace, staff)
          end
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace,
                               authorize: authorize) do
            platform_order.lock!
            raise Guard.closed!(platform_order) unless platform_order.open?

            Workspaces::ClaimLease.call(workspace: workspace, staff: staff, key: "#{key}:lease", editor_id: editor_id, takeover: true)
            settle_sale!(workspace, staff, key, editor_id, platform_order)
            Workspaces::Complete.call(workspace: workspace, staff: staff, revision: workspace.revision,
                                      lease_generation: workspace.lease_generation, editor_id: editor_id,
                                      key: "#{key}:complete")
            platform_order.assign_gross(workspace.order.reload.total)
            platform_order.update!(status: 'completed', completed_at: Workspace.database_now)
            AuditEntry.record!(store: workspace.store, actor: staff, action: 'platform_order.complete', subject: workspace,
                               metadata: { platform_order_id: platform_order.prefixed_id,
                                           gross: platform_order.gross_amount.to_s('F'),
                                           commission: platform_order.commission_amount.to_s('F') })
            platform_order.to_pos
          end
        end

        def settle_sale!(workspace, staff, key, editor_id, platform_order)
          method = PaymentMethodResolver.new(store: workspace.store).platform_method!
          Tenders::Prepare.call(workspace: workspace, staff: staff, revision: workspace.revision,
                                lease_generation: workspace.lease_generation, editor_id: editor_id, key: "#{key}:tender",
                                payment_method_id: method.prefixed_id, amount: workspace.order.total.to_s('F'))
          attempt = TenderAttempt.where(workspace_id: workspace.id, status: 'prepared').order(:id).last
          Tenders::Confirm.call(workspace: workspace, staff: staff, revision: workspace.revision,
                                lease_generation: workspace.lease_generation, editor_id: editor_id, key: "#{key}:confirm",
                                attempt_id: attempt.prefixed_id, evidence_kind: EVIDENCE,
                                reference: "#{platform_order.platform}:#{platform_order.platform_order_ref}")
        end
      end
    end
  end
end

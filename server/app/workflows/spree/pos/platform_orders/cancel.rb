# frozen_string_literal: true

module Spree
  module Pos
    module PlatformOrders
      # The platform canceled the order before the driver took it. Items the
      # kitchen has and has not handed over are voided with the reason
      # `platform_canceled`, which takes an approval (or a cashier who may
      # grant one), and the draft is canceled; the call number stays with
      # the order. A completed order is returned like any other sale.
      module Cancel
        ACTION = 'platform_order.cancel'
        REASON = 'platform_canceled'
        REASON_MAX = 200

        module_function

        def call(platform_order:, staff:, key:, editor_id:, reason: nil, approval_id: nil)
          workspace = platform_order.workspace
          note = reason.to_s.strip.presence
          payload = {
            'command' => ACTION, 'platform_order_id' => platform_order.prefixed_id,
            'editor_digest' => Workspace.editor_digest(editor_id), 'reason' => note, 'approval_id' => approval_id.to_s.presence
          }
          tickets = []
          result = CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace,
                                        authorize: -> { Guard.counter!(workspace, staff) }) do
            raise Conflict, 'The reason is too long.' if note && note.length > REASON_MAX

            platform_order.lock!
            raise Guard.closed!(platform_order) unless platform_order.open?

            Workspaces::ClaimLease.call(workspace: workspace, staff: staff, key: "#{key}:lease", editor_id: editor_id, takeover: true)
            items = kitchen_items(workspace)
            if items.any?
              approval = approve!(workspace, staff, approval_id)
              tickets = void!(workspace, staff, items, approval)
            end
            Workspaces::ChangeStatus.call(workspace: workspace, staff: staff, status: 'canceled', revision: workspace.revision,
                                          lease_generation: workspace.lease_generation, key: "#{key}:cancel",
                                          editor_id: editor_id)
            platform_order.update!(status: 'canceled', canceled_at: Workspace.database_now, cancel_reason: note || REASON)
            AuditEntry.record!(store: workspace.store, actor: staff, action: ACTION, subject: workspace,
                               metadata: { platform_order_id: platform_order.prefixed_id, reason: note || REASON,
                                           voided_items: items.map(&:prefixed_id) })
            platform_order.to_pos
          end
          tickets.each { |ticket| Kitchen::ChangeItemStatus.publish(ticket) }
          result
        end

        # What the kitchen still has of the order: everything not voided
        # and not handed over yet.
        def kitchen_items(workspace)
          KitchenTicketItem.joins(:kitchen_ticket).where(spree_pos_kitchen_tickets: { workspace_id: workspace.id }).
            where(status: %w[new preparing ready]).order(:id).lock.to_a
        end

        def approve!(workspace, staff, approval_id)
          policy = AccessPolicy.new(store: workspace.store, staff: staff)
          if approval_id.blank? && !policy.allows?(workspace.branch, Capabilities::APPROVE)
            raise Conflict.new('Canceling items the kitchen has needs an approval.', reason: 'approval_required',
                                                                                     revision: workspace.revision)
          end

          Workspaces::ApplyDiscount.approve!(workspace, staff, workspace.revision, approval_id, amount: nil, action: ACTION,
                                                                                                capability: Capabilities::APPROVE,
                                                                                                message: 'Canceling items the kitchen has needs an approval.')
        end

        def void!(workspace, staff, items, approval)
          now = Workspace.database_now
          items.each { |item| item.update!(status: 'voided', voided_at: now, changed_by: staff) }
          AuditEntry.record!(store: workspace.store, actor: staff, action: 'kitchen.void', subject: workspace,
                             metadata: { reason: REASON, items: items.map(&:prefixed_id) }.
                                                                                          merge(Workspaces::ApplyDiscount.approval_metadata(approval)))
          KitchenTicket.where(id: items.map(&:kitchen_ticket_id).uniq).includes(:kitchen_station, :workspace, :branch).to_a
        end
      end
    end
  end
end

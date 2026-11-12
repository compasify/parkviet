# frozen_string_literal: true

module Spree
  module Pos
    module Kiosks
      # The counter's side of kiosk orders. A cashier sees the orders kiosks
      # left for the counter, takes one to collect it (it moves to their own
      # open shift and editor, like any draft without money, and they then
      # tender and complete it as usual), or cancels one a guest abandoned.
      #
      # An order whose QR is still open is not left for the counter yet. One
      # the kiosk lost track of (the kiosk went off) is settled first: a QR
      # the bank confirmed completes the sale as the kiosk would have, any
      # other QR is given back.
      module Handoff
        module_function

        def list(branch)
          scope = Workspace.joins(:shift).includes(:order, :register).
                  where(branch_id: branch.id, order_source: Workspace::KIOSK_SOURCE, operational_status: Workspace::OPEN_STATUSES).
                  where(spree_pos_shifts: { owner_id: StaffMembership.where(branch_id: branch.id, service_account: true).select(:staff_id) }).
                  order(:id).limit(100)
          now = Workspace.database_now
          scope.map { |workspace| row(workspace, now) }
        end

        def row(workspace, now = Workspace.database_now)
          waiting_since = workspace.updated_at
          {
            id: workspace.prefixed_id, order_id: workspace.order.prefixed_id, order_number: workspace.order.number,
            call_number: workspace.order_number, status: workspace.operational_status,
            register: workspace.register && { id: workspace.register.prefixed_id, name: workspace.register.name },
            total: BigDecimal(workspace.order.total.to_s).to_s('F'), currency: workspace.order.currency,
            item_count: workspace.order.line_items.sum(&:quantity), opened_at: workspace.created_at.iso8601,
            waiting_since: waiting_since.iso8601, abandoned: waiting_since < now - Policy::ABANDONED_AFTER
          }
        end

        def authorize!(store, staff, workspace)
          policy = AccessPolicy.new(store: store, staff: staff)
          raise CanCan::AccessDenied unless policy.permission?('write_pos_orders') && Policy.can_take?(policy, workspace)
        end

        # The cashier collects it: on their open shift, with their lease.
        def take(store:, staff:, key:, workspace:, editor_id:)
          editor_digest = Workspace.editor_digest(editor_id)
          payload = { 'command' => 'kiosk_order.take', 'workspace_id' => workspace.prefixed_id, 'editor_digest' => editor_digest }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, workspace: workspace,
                               authorize: -> { authorize!(store, staff, workspace) }) do
            account = kiosk_account!(workspace)
            next workspace.to_pos if settle!(workspace, account, key) == :completed

            target = ShiftRebind.open_shift_of(workspace, staff)
            raise Conflict.new('Open a shift to collect this order.', revision: workspace.revision, reason: 'no_open_shift') if target.nil?

            from = workspace.shift
            ShiftBarrier.hold!(target)
            workspace.rebind_shift!(target)
            workspace.update!(operational_status: 'editing', lease_holder: staff, lease_editor_digest: editor_digest,
                              lease_generation: workspace.lease_generation + 1,
                              lease_expires_at: Workspace.database_now + Workspace::LEASE_TTL, revision: workspace.revision + 1)
            AuditEntry.record!(store: store, actor: staff, action: 'kiosk_order.take', subject: workspace,
                               metadata: { from_shift_id: from.prefixed_id, to_shift_id: target.prefixed_id })
            workspace.to_pos
          end
        end

        # A guest who never came to the counter: the order is canceled with
        # nothing paid. A call number already given stays used.
        def cancel(store:, staff:, key:, workspace:, reason: nil)
          note = reason.to_s.squish.presence
          raise Conflict.new('The reason is too long.', reason: 'reason_invalid') if note && note.length > 200

          payload = { 'command' => 'kiosk_order.cancel', 'workspace_id' => workspace.prefixed_id, 'reason' => note }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, workspace: workspace,
                               authorize: -> { authorize!(store, staff, workspace) }) do
            account = kiosk_account!(workspace)
            next workspace.to_pos if settle!(workspace, account, key) == :completed
            if Workspaces::ChangeStatus.money_recorded?(workspace)
              raise Conflict.new('This order has a payment.', revision: workspace.revision, reason: 'payments_recorded')
            end

            Inventory::AllocateTraceability.release!(workspace)
            workspace.update!(operational_status: 'canceled', revision: workspace.revision + 1)
            AuditEntry.record!(store: store, actor: staff, action: 'kiosk_order.cancel', subject: workspace, metadata: { reason: note }.compact)
            workspace.to_pos
          end
        end

        # The kiosk account still holding it; one a cashier already took is not here.
        def kiosk_account!(workspace)
          account = StaffMembership.find_by(staff_id: workspace.shift.owner_id, branch_id: workspace.branch_id, service_account: true)
          raise Conflict.new('Someone already took this order.', revision: workspace.revision, reason: 'kiosk_order_taken') if account.nil?

          account
        end

        # Settles a QR left open on the order. :completed when the bank had
        # confirmed it and the sale is now complete.
        def settle!(workspace, account, key)
          attempt = Order.waiting_attempt(workspace)
          return if attempt.nil?

          device = account.device
          if View.received?(attempt) && device&.status == 'active'
            Order.finish(device: device, workspace: workspace, key: "#{key}:finish")
            return :completed
          end
          raise Conflict.new('This order is already paid.', reason: 'kiosk_paid') if View.received?(attempt)
          raise Conflict.new('The guest is still paying by QR.', reason: 'kiosk_qr_open') unless expired?(attempt, workspace) || device&.status != 'active'

          Order.release_qr!(workspace, account.staff, Policy.editor_id(device), key)
          nil
        end

        def expired?(attempt, workspace)
          Time.current >= attempt.created_at + workspace.branch.kiosk_qr_timeout_seconds.seconds
        end
      end
    end
  end
end

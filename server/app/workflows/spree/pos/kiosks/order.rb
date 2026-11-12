# frozen_string_literal: true

module Spree
  module Pos
    module Kiosks
      # A guest's order at a self-ordering kiosk, run as the kiosk's service
      # account through the ordinary commands: a draft on the kiosk's shift,
      # menu lines priced again on the server (prices the kiosk sends are
      # never read), then either
      #
      # - VietQR: a tender for the whole order; once the bank's webhook has
      #   confirmed the transfer, `finish` confirms it with that webhook as
      #   evidence and completes the sale (call number, kitchen, receipt);
      # - pay at the counter: the order gets its call number and is parked
      #   for a cashier, who takes it (Handoff) and collects as usual. The
      #   kitchen hears of it only once it is paid, unless the branch sends
      #   kiosk orders before payment.
      #
      # A QR the bank has not confirmed by the branch's timeout is given back
      # and the order goes to the counter. Each step is one command under the
      # kiosk's idempotency key; the commands it runs inside are keyed from it.
      module Order
        PAYMENTS = %w[vietqr counter].freeze

        module_function

        # @return [Hash] the order as the kiosk shows it (View)
        def place(device:, key:, items:, payment:)
          account = Policy.account!(device)
          staff = account.staff
          choice = payment.to_s
          raise Conflict.new('Choose how to pay.', reason: 'kiosk_payment_invalid') unless PAYMENTS.include?(choice)

          rows = GuestOrders::Submit.normalize!(items)
          payload = { 'command' => 'kiosk.order', 'device_id' => device.prefixed_id, 'payment' => choice, 'items' => rows }
          CommandExecutor.call(store: device.store, actor: staff, key: key, payload: payload, authorize: -> { authorize!(device, staff) }) do
            branch = device.branch
            shift = State.require_open!(device, account)
            FeaturePolicy.require!(branch, :vietqr) if choice == 'vietqr'
            available!(branch, rows)
            editor = Policy.editor_id(device)
            workspace = Workspaces::Create.draft!(store: device.store, staff: staff, shift: shift, editor_digest: Workspace.editor_digest(editor),
                                                  service_mode: 'counter', order_source: Workspace::KIOSK_SOURCE)
            AuditEntry.record!(store: device.store, actor: staff, action: 'workspace.create', subject: workspace,
                               metadata: { device_id: device.prefixed_id, kiosk: true })
            rows.each_with_index do |row, index|
              current = workspace.reload
              Workspaces::ManageLineItem.add(workspace: current, staff: staff, revision: current.revision, lease_generation: current.lease_generation,
                                             editor_id: editor, key: "#{key}:line:#{index}", variant_id: row['variant_id'], quantity: row['quantity'],
                                             modifiers: row['modifiers'], note: row['note'], merge: true)
            end
            workspace.reload
            if choice == 'vietqr'
              open_qr!(workspace, device, staff, editor, key)
            else
              hand_off!(workspace, device, staff, editor, key)
            end
            View.call(workspace.reload, device)
          end
        end

        # Completes an order whose transfer the bank has confirmed. Paying
        # again for a completed order changes nothing.
        def finish(device:, workspace:, key:)
          run(device, workspace, key, 'kiosk.finish') do |staff, editor|
            next if workspace.operational_status == 'completed'

            attempt = waiting_attempt(workspace)
            raise Conflict.new('This order has no transfer to confirm.', reason: 'kiosk_no_payment') if attempt.nil?
            raise Conflict.new('The bank has not confirmed this transfer yet.', reason: 'vietqr_not_received') unless View.received?(attempt)

            lease!(workspace, staff, editor, "#{key}:lease")
            current = workspace.reload
            Tenders::Confirm.call(workspace: current, staff: staff, revision: current.revision, lease_generation: current.lease_generation,
                                  editor_id: editor, key: "#{key}:confirm", attempt_id: attempt.prefixed_id, evidence_kind: 'vietqr_webhook')
            current = workspace.reload
            Workspaces::Complete.call(workspace: current, staff: staff, revision: current.revision, lease_generation: current.lease_generation,
                                      editor_id: editor, key: "#{key}:complete")
            # Paid means sent, also where the counter sends by hand.
            Kitchen::Send.call(workspace: workspace.reload, actor: staff, send_key: "kiosk:paid:#{workspace.prefixed_id}", device: device,
                               buffet: false)
            Printing.receipt_after_commit(workspace, device, staff)
          end
        end

        # The guest pays at the counter instead: a QR not yet paid is given back.
        def pay_at_counter(device:, workspace:, key:)
          run(device, workspace, key, 'kiosk.pay_at_counter') do |staff, editor|
            next if workspace.operational_status == 'parked'

            editing!(workspace)
            release_qr!(workspace, staff, editor, key)
            hand_off!(workspace.reload, device, staff, editor, key)
          end
        end

        # The guest walked away before paying (idle reset, "start over"): the
        # QR is given back and the order canceled. One left for the counter
        # is the cashiers' to cancel.
        def cancel(device:, workspace:, key:)
          run(device, workspace, key, 'kiosk.cancel') do |staff, editor|
            next if workspace.operational_status == 'canceled'
            if workspace.operational_status == 'parked'
              raise Conflict.new('This order is waiting at the counter.', reason: 'kiosk_order_handed_off')
            end

            editing!(workspace)
            release_qr!(workspace, staff, editor, key)
            lease!(workspace, staff, editor, "#{key}:lease")
            current = workspace.reload
            Workspaces::ChangeStatus.call(workspace: current, staff: staff, status: 'canceled', revision: current.revision,
                                          lease_generation: current.lease_generation, key: "#{key}:cancel", editor_id: editor)
          end
        end

        # One command on an order this kiosk still holds, under its lock.
        def run(device, workspace, key, command)
          account = Policy.account!(device)
          staff = account.staff
          editor = Policy.editor_id(device)
          payload = { 'command' => command, 'device_id' => device.prefixed_id, 'workspace_id' => workspace.prefixed_id }
          CommandExecutor.call(store: device.store, actor: staff, key: key, payload: payload, workspace: workspace,
                               authorize: -> { authorize!(device, staff, workspace: workspace, account: account) }) do
            yield staff, editor
            View.call(workspace.reload, device)
          end
        end

        # The kiosk's own device, and an order it still holds: one on its
        # account's shift. An order a cashier took is no longer the kiosk's.
        def authorize!(device, staff, workspace: nil, account: nil)
          raise CanCan::AccessDenied if device.status != 'active' || device.mode != 'kiosk' || staff.nil?
          return if workspace.nil?
          raise ActiveRecord::RecordNotFound unless workspace.store_id == device.store_id && Policy.kiosk_owned?(workspace, account)
        end

        # Every item is on the kiosk's menu and not sold out today.
        def available!(branch, rows)
          menu = GuestMenu.variants(branch, channel: :kiosk)
          rows.each do |row|
            entry = menu[row['variant_id']]
            raise Conflict.new('This item cannot be ordered here.', reason: 'item_unavailable', details: { variant_id: row['variant_id'] }) if entry.nil?
            raise Conflict.new('This item is sold out.', reason: 'item_sold_out', details: { menu_item_id: entry[:id] }) if entry[:sold_out]
          end
        end

        def open_qr!(workspace, device, staff, editor, key)
          total = workspace.order.total
          raise Conflict.new('This order has nothing to pay.', reason: 'kiosk_total_invalid') unless total.positive?

          method = PaymentMethodResolver.new(store: workspace.store).available(branch: workspace.branch).find { |row| row.kind == 'vietqr' }
          raise Conflict.new('VietQR is not available.', reason: 'vietqr_unavailable') if method.nil?

          Tenders::Prepare.call(workspace: workspace, staff: staff, revision: workspace.revision, lease_generation: workspace.lease_generation,
                                editor_id: editor, key: "#{key}:prepare", payment_method_id: method.prefixed_id || "posmethod-#{method.kind}",
                                amount: total.to_s('F'))
          AuditEntry.record!(store: workspace.store, actor: staff, action: 'kiosk.qr_open', subject: workspace,
                             metadata: { device_id: device.prefixed_id, amount: total.to_s('F') })
        end

        # The call number, the kitchen when the branch wants it before
        # payment, the counter slip, and parked for the cashier.
        def hand_off!(workspace, device, staff, editor, key)
          OrderNumbers.assign!(workspace)
          if workspace.branch.kiosk_kitchen_before_payment
            tickets = Kitchen::Send.call(workspace: workspace, actor: staff, send_key: "kiosk:counter:#{workspace.prefixed_id}", device: device,
                                         buffet: false)
            workspace.update!(revision: workspace.revision + 1) if tickets.any?
          end
          lease!(workspace, staff, editor, "#{key}:lease")
          current = workspace.reload
          Workspaces::ChangeStatus.call(workspace: current, staff: staff, status: 'parked', revision: current.revision,
                                        lease_generation: current.lease_generation, key: "#{key}:park", editor_id: editor)
          AuditEntry.record!(store: workspace.store, actor: staff, action: 'kiosk.pay_at_counter', subject: workspace,
                             metadata: { device_id: device.prefixed_id, order_number: workspace.reload.order_number })
          Realtime.publish(workspace.branch, 'kiosk_order.waiting', id: workspace.prefixed_id, refs: { workspace_id: workspace.prefixed_id })
          Printing.counter_slip_after_commit(workspace, device, staff)
        end

        # Gives a QR the bank has not confirmed back. Money already reported
        # is never canceled away: the kiosk finishes the order instead.
        def release_qr!(workspace, staff, editor, key)
          attempt = waiting_attempt(workspace)
          return if attempt.nil?
          raise Conflict.new('This order is already paid.', reason: 'kiosk_paid') if View.received?(attempt)

          lease!(workspace, staff, editor, "#{key}:release_lease")
          current = workspace.reload
          Tenders::Cancel.call(workspace: current, staff: staff, revision: current.revision, lease_generation: current.lease_generation,
                               editor_id: editor, key: "#{key}:release", attempt_id: attempt.prefixed_id)
        end

        # The kiosk's lease on its own order, taken again: a QR can stay open
        # longer than a lease lasts.
        def lease!(workspace, staff, editor, key)
          return if workspace.reload.lease_current?(staff, editor)

          Workspaces::ClaimLease.call(workspace: workspace, staff: staff, key: key, editor_id: editor)
        end

        def waiting_attempt(workspace)
          TenderAttempt.where(workspace_id: workspace.id, status: 'prepared').order(:id).last
        end

        def editing!(workspace)
          return if workspace.operational_status == 'editing'

          raise Conflict.new('This order is closed.', reason: 'workspace_closed', details: { status: workspace.operational_status })
        end
      end
    end
  end
end

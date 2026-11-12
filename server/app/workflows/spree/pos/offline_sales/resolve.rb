# frozen_string_literal: true

module Spree
  module Pos
    module OfflineSales
      # The cashier who took the cash finishes an offline sale waiting for
      # review, through the ordinary commands on their open shift:
      #
      # - `accept_collected`: keep the prices the counter charged. One
      #   approval of `workspace.override_price` for the collected total
      #   (bound to the parked order's revision) covers every line whose
      #   price changed, unless the cashier may override prices. The order is
      #   then paid with the cash already taken and completed;
      # - `current_price`: charge today's prices, with `handed_amount` the
      #   cash now taken in all (the customer paid the difference, or the
      #   change was given back);
      # - `edited`: sell `lines` instead (an item ran out and something else
      #   was handed over), priced by the server and paid with `handed_amount`.
      #
      # A sale with no parked order (closed shift, an item no longer sold)
      # gets a new one on the cashier's open shift at the branch.
      module Resolve
        MODES = %w[accept_collected current_price edited].freeze

        module_function

        def call(store:, staff:, key:, sale:, mode:, approval_id: nil, handed_amount: nil, lines: nil, note: nil)
          choice = mode.to_s
          raise Conflict.new('Choose how to finish this sale.', reason: 'offline_resolution_invalid') unless MODES.include?(choice)

          rows = if choice == 'edited'
                   OfflineSales.lines!(Array(lines).map { |row| row.respond_to?(:to_unsafe_h) ? row.to_unsafe_h : row })
                 end
          handed = handed_amount.present? ? OfflineSales.money!(handed_amount) : nil
          text = note.to_s.squish.first(200).presence
          payload = { 'command' => 'offline_sale.resolve', 'offline_sale_id' => sale.prefixed_id, 'mode' => choice,
                      'approval_id' => approval_id.to_s.presence, 'handed_amount' => handed&.to_s('F'), 'lines' => rows, 'note' => text }.compact
          workspace = sale.workspace
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, workspace: workspace,
                               authorize: -> { authorize!(store, staff, sale) }) do
            sale.lock!
            raise Conflict.new('This offline sale is already settled.', reason: 'offline_sale_settled') unless sale.status == 'needs_review'

            finished = OfflineSales.replaying { finish!(store, staff, key, sale, choice, approval_id, handed, rows) }
            sale.update!(status: 'completed', workspace: finished, resolution: choice, resolution_note: text,
                         resolved_by: staff, resolved_at: Time.current)
            AuditEntry.record!(store: store, actor: staff, action: 'offline_sale.resolve', subject: finished,
                               metadata: { offline_sale_id: sale.prefixed_id, provisional_number: sale.provisional_number,
                                           mode: choice, collected: sale.collected_total.to_s('F'),
                                           total: finished.order.total.to_s('F'), replaced_workspace_id: replaced_ref(workspace, finished) }.compact)
            sale.reload.to_pos
          end
          sale.reload.to_pos
        end

        # Only the cashier holding the cash, while they still sell there.
        def authorize!(store, staff, sale)
          raise ActiveRecord::RecordNotFound unless sale.store_id == store.id
          raise CanCan::AccessDenied unless sale.staff_id == staff.id

          OfflineSales.seller!(store, staff, sale.branch)
        end

        def finish!(store, staff, key, sale, choice, approval_id, handed, rows)
          editor = OfflineSales.editor_for(sale.offline_id)
          parked = usable_order(sale)
          case choice
          when 'accept_collected'
            raise Conflict.new('This sale has no order to keep the prices of.', reason: 'offline_sale_no_order') if parked.nil?

            accept_collected!(parked, staff, editor, key, sale, approval_id)
          when 'current_price'
            workspace = parked ? OfflineSales.resume!(parked, staff, editor, key) : new_order!(store, staff, sale, editor, key, sale.lines)
            OfflineSales.pay_and_complete!(workspace, staff, editor, key, handed || sale.handed_amount)
          else
            raise Conflict.new('Say how much cash was taken.', reason: 'offline_cash_short') if handed.nil?

            cancel!(parked, staff, editor, key) if parked
            OfflineSales.pay_and_complete!(new_order!(store, staff, sale, editor, key, rows), staff, editor, key, handed)
          end
        end

        def accept_collected!(parked, staff, editor, key, sale, approval_id)
          # Asked for on the order as it waits, before anything changes it.
          approval = Workspaces::ApplyDiscount.approve!(
            parked, staff, parked.revision, approval_id,
            amount: sale.collected_total, action: Workspaces::OverridePrice::ACTION, capability: Capabilities::PRICE_OVERRIDE,
            message: 'Approval is required to keep the collected prices.'
          )
          workspace = OfflineSales.resume!(parked, staff, editor, key)
          lines = SaleLine.where(workspace_id: workspace.id).order(:id).to_a
          sale.lines.each_with_index do |row, index|
            line = lines[index]
            price = BigDecimal(row['unit_price'])
            next if line.nil? || line.unit_price == price

            Workspaces::OverridePrice.apply!(workspace, staff, line, price, "Offline #{sale.provisional_number}", approval)
          end
          workspace.reload
          unless workspace.order.total == sale.collected_total
            raise Conflict.new('The total still differs from the cash collected.',
                               reason: 'offline_total_mismatch', details: { current_total: workspace.order.total.to_s('F') })
          end

          OfflineSales.pay_and_complete!(workspace, staff, editor, key, sale.handed_amount)
        end

        # The parked order of the sale, while it is still there to finish.
        def usable_order(sale)
          workspace = sale.workspace
          workspace if workspace && %w[parked editing].include?(workspace.operational_status)
        end

        # A new order at the sale's branch on the cashier's open shift, the
        # register of the sale first.
        def new_order!(store, staff, sale, editor, key, rows)
          shifts = Shift.for_store(store).open_now.where(branch_id: sale.branch_id, owner_id: staff.id)
          shift = shifts.find_by(register_id: sale.register_id) || shifts.order(opened_at: :desc).first
          raise Conflict.new('Open a shift to finish this sale.', reason: 'no_open_shift') if shift.nil?

          missing = OfflineSales.unavailable(shift.branch, rows)
          raise Conflict.new('An item does not sell now.', reason: missing.first, details: missing.last) if missing

          OfflineSales.draft!(store: store, staff: staff, shift: shift, editor: editor, key: "#{key}:new", rows: rows,
                              sale_ref: { 'offline_id' => sale.offline_id, 'provisional_number' => sale.provisional_number })
        end

        def cancel!(parked, staff, editor, key)
          workspace = OfflineSales.resume!(parked, staff, editor, key)
          Workspaces::ChangeStatus.call(workspace: workspace, staff: staff, status: 'canceled', revision: workspace.revision,
                                        lease_generation: workspace.lease_generation, key: "#{key}:cancel", editor_id: editor)
        end

        def replaced_ref(before, after)
          before && before.id != after.id ? before.prefixed_id : nil
        end
      end
    end
  end
end

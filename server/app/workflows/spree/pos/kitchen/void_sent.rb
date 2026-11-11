# frozen_string_literal: true

module Spree
  module Pos
    module Kitchen
      # Takes back part of a line the kitchen was already told about. It
      # needs a reason from the branch's list (or "other" with a note) and,
      # unless the person may void (`pos.kitchen.void`), an approval of
      # `kitchen.void_sent` for the order as it stands. The line and its sent
      # quantity go down together, and the station gets a void ticket at
      # once, on its screen and on its printer. An item the kitchen had
      # already made is still voided, marked `wasted` for the waste report;
      # nothing goes back to stock.
      module VoidSent
        ACTION = Approval::KITCHEN_VOID_ACTION
        REASON_LABELS = {
          'khach_doi_y' => 'Khách đổi ý', 'het_mon' => 'Hết món', 'nhap_nham' => 'Nhập nhầm', 'lam_hong' => 'Làm hỏng',
          KitchenVoid::OTHER => 'Khác', KitchenVoid::PLATFORM_CANCELED => 'Nền tảng hủy'
        }.freeze

        module_function

        # A table order is voided without a lease, like adding to it; any
        # other order needs its lease at the revision the client saw.
        def call(workspace:, staff:, key:, sale_line_id:, quantity:, reason_code:, note: nil, approval_id: nil, device: nil,
                 revision: nil, lease_generation: nil, editor_id: nil)
          lease_free = Workspaces::AppendItems.lease_free?(workspace)
          payload = { 'command' => ACTION, 'sale_line_id' => sale_line_id.to_s, 'quantity' => quantity.to_s,
                      'reason_code' => reason_code.to_s, 'note' => note.to_s.strip.presence, 'approval_id' => approval_id.to_s.presence }
          unless lease_free
            payload.merge!('revision' => revision, 'lease_generation' => lease_generation, 'editor_digest' => Workspace.editor_digest(editor_id))
          end
          tickets = []
          result = CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace,
                                        authorize: -> { Deliveries::Assign.authorize!(workspace, staff) }) do
            if lease_free
              Workspaces::AppendItems.validate_append!(workspace)
            else
              Deliveries::Assign.validate_editing!(workspace, staff, revision, lease_generation, editor_id)
              workspace.ensure_snapshot_editable!
            end
            sale_line = SaleLine.locate(SaleLine.where(workspace_id: workspace.id), sale_line_id) || raise(ActiveRecord::RecordNotFound)
            sale_line.lock!
            count = quantity!(quantity, sale_line)
            reason, text = reason!(workspace.branch, reason_code, note)
            approval = approve!(workspace, staff, approval_id)
            void = void!(workspace: workspace, staff: staff, sale_line: sale_line, quantity: count, reason_code: reason, note: text,
                         approval: approval, device: device, key: key)
            tickets << void.kitchen_ticket if void.kitchen_ticket
            workspace.update!(revision: workspace.revision + 1)
            { 'workspace' => workspace.to_pos, 'kitchen_void' => void.to_pos }
          end
          tickets.each { |ticket| print_after_commit(ticket, staff) }
          result
        end

        # Voids `quantity` of a sent line inside the caller's command: ticket
        # items, the void ticket, the void row and the line itself.
        # @return [KitchenVoid]
        def void!(workspace:, staff:, sale_line:, quantity:, reason_code:, note:, approval:, device:, key:)
          now = Workspace.database_now
          items = KitchenTicketItem.joins(:kitchen_ticket).
                  where(sale_line_id: sale_line.id, spree_pos_kitchen_tickets: { kind: 'fire' }).where.not(status: 'voided').
                  includes(kitchen_ticket: :kitchen_station).order(id: :desc).lock.to_a
          open, made = items.partition { |item| KitchenTicketItem::OPEN.include?(item.status) }
          wasted = quantity > open.sum(&:quantity)
          left = quantity
          (open + made).each do |item|
            next if item.quantity > left

            item.update!(status: 'voided', voided_at: now, changed_by: staff)
            left -= item.quantity
            break if left.zero?
          end
          # The screens showing those tickets read them again.
          items.select(&:voided_at).map(&:kitchen_ticket).uniq.each do |fired|
            Realtime.publish(workspace.branch, 'kitchen_ticket.updated', id: fired.prefixed_id,
                                                                         refs: { workspace_id: workspace.prefixed_id, kitchen_station_id: fired.kitchen_station.prefixed_id })
          end
          station = items.first&.kitchen_ticket&.kitchen_station || Router.station_for(workspace.branch, sale_line, workspace.service_mode)
          ticket = station && void_ticket!(workspace, staff, sale_line, station, quantity, reason_text(reason_code, note), key, now)
          void = KitchenVoid.create!(store: workspace.store, workspace: workspace, sale_line: sale_line, quantity: quantity,
                                     name: Send.item_name(sale_line), reason_code: reason_code, note: note, staff: staff, device: device,
                                     approval: approval, wasted: wasted, kitchen_ticket: ticket)
          shrink!(workspace, sale_line, quantity)
          AuditEntry.record!(store: workspace.store, actor: staff, action: ACTION, subject: workspace,
                             metadata: { sale_line_id: sale_line.prefixed_id, kitchen_void_id: void.prefixed_id, quantity: quantity.to_s('F'),
                                         reason_code: reason_code, note: note, wasted: wasted, kitchen_ticket_id: ticket&.prefixed_id,
                                         items: items.select(&:voided_at).map(&:prefixed_id) }.
                                      merge(Workspaces::ApplyDiscount.approval_metadata(approval)))
          void
        end

        # The line keeps what was not voided; a line voided to nothing leaves the order.
        def shrink!(workspace, sale_line, quantity)
          remaining = sale_line.sale_quantity - quantity
          sale_line.update!(kitchen_sent_quantity: sale_line.kitchen_sent_quantity - quantity)
          if remaining.zero?
            Workspaces::ManageLineItem.remove_line!(workspace, sale_line)
          else
            Workspaces::ManageLineItem.change_quantity!(workspace, sale_line, remaining.to_i, nil)
          end
        end

        def void_ticket!(workspace, staff, sale_line, station, quantity, reason, key, now)
          sequence = KitchenTicket.where(workspace_id: workspace.id).maximum(:sequence).to_i + 1
          ticket = KitchenTicket.create!(
            store: workspace.store, branch: workspace.branch, workspace: workspace, kitchen_station: station, sequence: sequence,
            kind: 'void', send_key: "void:#{key}"[0, 200], service_mode: workspace.service_mode, business_date: workspace.business_date,
            header: Send.header_for(workspace), sent_by: staff, sent_at: now
          )
          KitchenTicketItem.create!(kitchen_ticket: ticket, sale_line: sale_line, name: Send.item_name(sale_line),
                                    modifiers: sale_line.line_modifiers.map { |row| Send.modifier(row) }, components: [],
                                    note: reason, quantity: quantity, status: 'voided', voided_at: now, changed_by: staff)
          Realtime.publish(workspace.branch, 'kitchen_ticket.updated',
                           id: ticket.prefixed_id, refs: { workspace_id: workspace.prefixed_id, kitchen_station_id: station.prefixed_id })
          ticket
        end

        # Whole items only, up to what the kitchen was told.
        def quantity!(value, sale_line)
          count = value.is_a?(Integer) ? value : (Integer(value.to_s, 10) rescue nil) # rubocop:disable Style/RescueModifier
          raise Conflict.new('The quantity to void is invalid.', reason: 'void_quantity_invalid') unless count&.positive?
          if count > sale_line.kitchen_sent_quantity
            raise Conflict.new('Only what was sent to the kitchen can be voided.', reason: 'void_quantity_invalid',
                                                                                  details: { kitchen_sent_quantity: sale_line.kitchen_sent_quantity.to_s('F') })
          end

          BigDecimal(count)
        end

        # A reason from the branch's list, or "other" with a note.
        def reason!(branch, code, note)
          code = code.to_s
          text = note.to_s.strip.presence
          raise Conflict.new('The note is too long.', reason: 'note_too_long') if text && text.length > KitchenVoid::NOTE_MAX
          unless code == KitchenVoid::OTHER || Array(branch.void_reasons).include?(code)
            raise Conflict.new('Choose a reason for the void.', reason: 'void_reason_invalid')
          end
          raise Conflict.new('Say why the item is voided.', reason: 'void_note_required') if code == KitchenVoid::OTHER && text.nil?

          [code, text]
        end

        def reason_text(code, note)
          [REASON_LABELS.fetch(code, code), note].compact.join(': ')
        end

        # Free for people who may void; everyone else spends an approval.
        def approve!(workspace, staff, approval_id)
          policy = AccessPolicy.new(store: workspace.store, staff: staff)
          return nil if policy.allows?(workspace.branch, Capabilities::KITCHEN_VOID)

          if approval_id.blank?
            raise Conflict.new('Voiding a sent item needs an approval.', reason: 'approval_required', revision: workspace.revision,
                                                                          details: { action: ACTION })
          end

          Workspaces::ApplyDiscount.approve!(workspace, staff, workspace.revision, approval_id, amount: nil, action: ACTION,
                                                                                                capability: Capabilities::KITCHEN_VOID,
                                                                                                message: 'Voiding a sent item needs an approval.')
        end

        def print_after_commit(ticket, actor)
          ActiveRecord.after_all_transactions_commit { print!(ticket, actor) }
        end

        # The station's printer gets the void ticket too. A printer that is off
        # is logged; the void has happened and the screen shows it.
        def print!(ticket, actor)
          printer = ticket.kitchen_station.printer
          return if printer.nil?

          PrintJobs::Enqueue.call(store: ticket.store, printer: printer, kind: 'void_ticket', document: TicketDocument.build(ticket),
                                  key: "void_ticket:#{ticket.prefixed_id}", actor: actor, source: ticket)
        rescue StandardError => e
          Rails.logger.error("[pos] void ticket #{ticket.prefixed_id} not queued for printing: #{e.class}: #{e.message}")
        end
      end
    end
  end
end

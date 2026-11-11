# frozen_string_literal: true

module Spree
  module Pos
    module Kitchen
      # An order's kitchen history, oldest first: every send (when, who, what
      # went to which station) and every void (when, who, what came back,
      # why, who approved it). Sends made before sends were recorded show
      # their tickets alone.
      module History
        module_function

        def for(workspace)
          tickets = KitchenTicket.where(workspace_id: workspace.id, kind: 'fire').
                    includes(:kitchen_station, :items, kitchen_send: %i[staff device]).order(:sequence).to_a
          sends = tickets.group_by(&:send_key).map { |_key, group| send_entry(group) }
          voids = KitchenVoid.where(workspace_id: workspace.id).includes(:staff, kitchen_ticket: :kitchen_station, approval: :approver).order(:id).map do |row|
            void_entry(row)
          end
          { workspace_id: workspace.prefixed_id, entries: (sends + voids).sort_by { |entry| entry[:at] } }
        end

        def send_entry(tickets)
          kitchen_send = tickets.first.kitchen_send
          staff = kitchen_send&.staff || (tickets.first.sent_by if tickets.first.sent_by_type == Spree.admin_user_class.name)
          {
            kind: 'send', id: kitchen_send&.prefixed_id, sequence: kitchen_send&.sequence, at: tickets.first.sent_at.iso8601(3),
            staff_name: KitchenSend.staff_name(staff), device_id: kitchen_send&.device&.prefixed_id,
            items: tickets.flat_map do |ticket|
              ticket.items.map do |item|
                { name: item.name, quantity: item.quantity.to_s('F'), station_name: ticket.kitchen_station.name, status: item.status,
                  modifiers: item.modifiers, note: item.note }
              end
            end
          }
        end

        def void_entry(row)
          {
            kind: 'void', id: row.prefixed_id, sequence: nil, at: row.created_at.iso8601(3), staff_name: KitchenSend.staff_name(row.staff),
            device_id: nil, reason_code: row.reason_code, note: row.note, wasted: row.wasted,
            approver_name: row.approval && KitchenSend.staff_name(row.approval.approver),
            items: [{ name: row.name, quantity: (-row.quantity).to_s('F'), station_name: row.kitchen_ticket&.kitchen_station&.name,
                      status: 'voided', modifiers: [], note: nil }]
          }
        end
      end
    end
  end
end

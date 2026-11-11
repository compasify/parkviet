# frozen_string_literal: true

module Spree
  module Pos
    module Kitchen
      # Tells the kitchen what it has not been told yet: for every menu line,
      # the part above `kitchen_sent_quantity`, grouped into one ticket per
      # station. A send key makes one send: the same key again returns the
      # tickets it made. Runs inside the caller's transaction, under the
      # workspace lock, and only writes rows; printing and the realtime event
      # leave after commit, so neither can undo a sale.
      module Send
        MODULE = 'fnb.kitchen'
        TRIGGERS = %w[on_complete manual].freeze

        module_function

        # From Workspaces::Complete: every paid order of an `on_complete`
        # branch reaches the kitchen in the transaction that places it.
        def on_complete(workspace:, actor:)
          return [] unless workspace.branch.kitchen_send_trigger == 'on_complete'

          call(workspace: workspace, actor: actor, send_key: "complete:#{workspace.prefixed_id}", buffet: false)
        end

        # "Send to kitchen" while the order is still open. A table order is
        # sent by anyone serving it, without a lease: a send only tells the
        # kitchen what the order already holds. Other orders keep the lease.
        # pproval_id lets a buffet round past its limits through
        # (BuffetRounds, approval uffet.override_round).
        def command(workspace:, staff:, key:, revision: nil, lease_generation: nil, editor_id: nil, device: nil, approval_id: nil)
          lease_free = Workspaces::AppendItems.lease_free?(workspace)
          payload = { 'command' => 'kitchen.send' }
          payload['approval_id'] = approval_id.to_s if approval_id.present?
          unless lease_free
            payload.merge!('revision' => revision, 'lease_generation' => lease_generation,
                           'editor_digest' => Workspace.editor_digest(editor_id))
          end
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace,
                               authorize: -> { Deliveries::Assign.authorize!(workspace, staff) }) do
            if lease_free
              Workspaces::AppendItems.validate_append!(workspace, snapshot: false)
            else
              Deliveries::Assign.validate_editing!(workspace, staff, revision, lease_generation, editor_id)
            end
            ModulePolicy.require!(workspace.branch, MODULE)
            tickets = call(workspace: workspace, actor: staff, send_key: key, device: device, approval_id: approval_id)
            workspace.update!(revision: workspace.revision + 1) if tickets.any?
            { 'workspace' => workspace.to_pos, 'tickets' => tickets.map(&:to_pos), 'ticket_count' => tickets.size }
          end
        end

        # A held course is not sent: it waits at the pass until FireCourse.
        # uffet: false skips the buffet round rules (a paid counter order).
        # @return [Array<KitchenTicket>] the tickets of this send, new or replayed
        def call(workspace:, actor:, send_key:, device: nil, approval_id: nil, buffet: true, scope: nil)
          branch = workspace.branch
          return [] unless ModulePolicy.enabled?(branch, MODULE)

          sent = KitchenTicket.where(workspace_id: workspace.id, send_key: send_key).order(:sequence).to_a
          return sent if sent.any?

          pending = (scope || SaleLine.where(workspace_id: workspace.id)).where(kind: SaleLineKinds::Menu::KIND).
                    where.not(course_status: 'held').
                    where('sale_quantity > kitchen_sent_quantity').order(:id).lock.
                    includes(:line_modifiers, :line_components, variant: %i[product option_values]).to_a
          return [] if pending.empty?

          BuffetRounds.check!(workspace: workspace, lines: pending, actor: actor, approval_id: approval_id) if buffet

          router = Router.new(branch)
          groups = pending.group_by { |line| router.station_for(line, workspace.service_mode) }
          groups.delete(nil)
          return [] if groups.empty?

          # The first send gives the order its call number, so the ticket
          # header carries it.
          OrderNumbers.assign!(workspace)
          kitchen_send = record_send!(workspace, actor, send_key, device)
          tickets = write!(workspace, actor, send_key, groups, kitchen_send)
          # A pass screen firing a course is named on the send itself.
          if actor.is_a?(Spree.admin_user_class)
            AuditEntry.record!(store: workspace.store, actor: actor, action: 'kitchen.send', subject: workspace,
                               metadata: { send_key: send_key, tickets: tickets.map(&:prefixed_id),
                                           lines: pending.map(&:prefixed_id) })
          end
          print_after_commit(tickets, actor)
          CupLabels::Issue.after_commit(workspace: workspace, actor: actor, upto: :sent)
          tickets
        end

        # Sends are numbered per order, under the workspace lock.
        def record_send!(workspace, actor, send_key, device)
          sequence = KitchenSend.where(workspace_id: workspace.id).maximum(:sequence).to_i + 1
          staff = actor.is_a?(Spree.admin_user_class) ? actor : nil
          KitchenSend.create!(workspace: workspace, sequence: sequence, staff: staff, device: device, send_key: send_key)
        end

        def write!(workspace, actor, send_key, groups, kitchen_send = nil)
          now = Workspace.database_now
          sequence = KitchenTicket.where(workspace_id: workspace.id).maximum(:sequence).to_i
          header = header_for(workspace)
          combos = combo_flags(workspace, groups.values.flatten)
          groups.sort_by { |station, _| [station.position, station.id] }.map do |station, lines|
            sequence += 1
            ticket = KitchenTicket.create!(
              store: workspace.store, branch: workspace.branch, workspace: workspace, kitchen_station: station,
              sequence: sequence, kind: 'fire', send_key: send_key, service_mode: workspace.service_mode,
              business_date: workspace.business_date, header: header, sent_by: actor, sent_at: now,
              kitchen_send: kitchen_send
            )
            lines.each do |line|
              KitchenTicketItem.create!(kitchen_ticket: ticket, sale_line: line, name: item_name(line),
                                        modifiers: line.line_modifiers.map { |row| modifier(row) },
                                        components: combos[line.variant.product_id] ? line.line_components.map { |row| component(row) } : [],
                                        note: line.note.presence, quantity: line.sale_quantity - line.kitchen_sent_quantity,
                                        status: 'new')
              line.update!(kitchen_sent_quantity: line.sale_quantity)
            end
            Realtime.publish(workspace.branch, 'kitchen_ticket.updated',
                             id: ticket.prefixed_id, refs: { workspace_id: workspace.prefixed_id, kitchen_station_id: station.prefixed_id })
            ticket
          end
        end

        # What the kitchen needs to hand the order out. No money, no phone.
        # A delivery platform's order names the platform (`order_source`),
        # its code and the code the platform's driver shows.
        def header_for(workspace)
          platform = Workspace::PLATFORM_SOURCES.include?(workspace.order_source) ? PlatformOrder.find_by(workspace_id: workspace.id) : nil
          {
            'platform_order_ref' => platform&.platform_order_ref, 'pickup_code' => platform&.pickup_code,
            'service_mode' => workspace.service_mode, 'order_source' => workspace.order_source,
            'customer_name' => workspace.customer_pos&.dig(:name).presence, 'note' => workspace.note.presence,
            'register_name' => workspace.register&.name, 'order_number' => workspace.order_number,
            'guest_name' => workspace.guest_name.presence, 'table' => table_name(workspace)
          }.compact
        end

        # The table and the letter of its order (A, B…).
        def table_name(workspace)
          # A bar tab has no table: the kitchen calls it by the guest's name.
          return workspace.tab_name.presence if workspace.resource.nil?

          [workspace.resource.name, workspace.table_label.presence].compact.join(' ')
        end

        def combo_flags(workspace, lines)
          MenuItem.where(store_id: workspace.store_id, product_id: lines.map { |line| line.variant.product_id }.uniq, kind: 'combo').
            pluck(:product_id, :show_components_on_kds).to_h
        end

        def item_name(line)
          size = line.variant.option_values.map(&:presentation).join(' / ')
          size.present? ? "#{line.variant.product.name} (#{size})" : line.variant.product.name
        end

        def modifier(row)
          { 'name' => row.name, 'group_name' => row.group_name, 'quantity' => row.quantity }
        end

        def component(row)
          { 'name' => row.name, 'quantity' => row.quantity.to_s }
        end

        # Stations with a printer get the ticket on paper too. A printer that
        # is off or has no live station is logged; the send has already
        # happened and the screen still shows it.
        def print_after_commit(tickets, actor)
          ActiveRecord.after_all_transactions_commit do
            tickets.each { |ticket| print!(ticket, actor) }
          end
        end

        def print!(ticket, actor)
          printer = ticket.kitchen_station.printer
          return if printer.nil?

          PrintJobs::Enqueue.call(store: ticket.store, printer: printer, kind: 'kitchen_ticket', document: TicketDocument.build(ticket),
                                  key: "kitchen_ticket:#{ticket.prefixed_id}", actor: actor, source: ticket)
        rescue StandardError => e
          Rails.logger.error("[pos] kitchen ticket #{ticket.prefixed_id} not queued for printing: #{e.class}: #{e.message}")
        end
      end
    end
  end
end

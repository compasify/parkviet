# frozen_string_literal: true

module Spree
  module Pos
    module Workspaces
      # The checklist of a table order: what came out of the kitchen and what
      # is still to come. Answers the print document, so a waiter's own
      # Bluetooth printer can print it; with `printer_id` it is also queued
      # to that printer of the branch. Takes no money and changes nothing.
      module Checklist
        module_function

        def call(workspace:, staff:, key:, printer_id: nil)
          payload = { 'command' => 'workspace.checklist', 'printer_id' => printer_id.to_s.presence }
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace,
                               authorize: -> { Tables::RequestPayment.authorize!(workspace, staff) }) do
            ModulePolicy.require!(workspace.branch, Tables::Guard::MODULE)
            raise Conflict.new('This order is not at a table.', revision: workspace.revision, reason: 'not_table_order') if workspace.resource_id.nil?

            document = Kitchen::ChecklistDocument.build(workspace, served(workspace))
            job = queue!(workspace, staff, key, printer_id, document) if printer_id.present?
            { 'document' => document, 'print_job' => job&.to_pos }.compact
          end
        end

        # Per sale line, what the kitchen has served of it.
        def served(workspace)
          KitchenTicketItem.joins(:kitchen_ticket).
            where(spree_pos_kitchen_tickets: { workspace_id: workspace.id, kind: 'fire' }, status: 'served').
            where.not(sale_line_id: nil).group(:sale_line_id).sum(:quantity)
        end

        def queue!(workspace, staff, key, printer_id, document)
          printer = PrintJobs::Guard.printer!(workspace.store, printer_id, branch: workspace.branch)
          PrintJobs::Enqueue.ensure_accepts!(printer, 'checklist')
          PrintJobs::Enqueue.call(store: workspace.store, printer: printer, kind: 'checklist', key: PrintJobs::Create.job_key(staff, key),
                                  actor: staff, source: workspace, source_revision: workspace.revision, document: document)
        end
      end
    end
  end
end

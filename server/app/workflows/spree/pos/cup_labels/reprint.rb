# frozen_string_literal: true

module Spree
  module Pos
    module CupLabels
      # The cashier prints the cup labels of one line, or of the whole order,
      # again: a wet or torn label. Only cups that already had a label (sent
      # to the kitchen, or sold) print. Each reprint is one command and one
      # audit entry; the cashier's own collect capability allows it.
      module Reprint
        module_function

        def call(workspace:, staff:, key:, sale_line_id: nil)
          payload = { 'command' => 'cup_label.reprint', 'sale_line_id' => sale_line_id.to_s.presence }
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace,
                               authorize: -> { authorize!(workspace, staff) }) do
            branch = workspace.branch
            ModulePolicy.require!(branch, Issue::MODULE)
            raise Conflict.new('The order was canceled.', reason: 'workspace_canceled') if workspace.operational_status == 'canceled'
            if branch.cup_label_printer.nil?
              raise Conflict.new('This branch has no cup label printer.', reason: 'cup_label_printer_missing')
            end

            line = line!(workspace, sale_line_id)
            upto = workspace.operational_status == 'completed' ? :sold : :sent
            jobs = Issue.call(workspace: workspace, actor: staff, upto: upto, trigger: key, line: line, strict: true)
            raise Conflict.new('No cup labels have been printed for this yet.', reason: 'cup_label_nothing') if jobs.empty?

            AuditEntry.record!(store: workspace.store, actor: staff, action: 'cup_label.reprint', subject: workspace,
                               metadata: { sale_line_id: line&.prefixed_id, jobs: jobs.map(&:prefixed_id) })
            { 'jobs' => jobs.map(&:to_pos) }
          end
        end

        def authorize!(workspace, staff)
          policy = AccessPolicy.new(store: workspace.store, staff: staff)
          return if policy.permission?('write_pos_orders') && policy.allows?(workspace.branch, Capabilities::PAYMENT)

          raise CanCan::AccessDenied
        end

        def line!(workspace, sale_line_id)
          return nil if sale_line_id.blank?

          SaleLine.locate(SaleLine.where(workspace_id: workspace.id), sale_line_id) || raise(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end

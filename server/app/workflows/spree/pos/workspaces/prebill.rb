# frozen_string_literal: true

module Spree
  module Pos
    module Workspaces
      # Records a pre-bill handed to a table, before it is printed. The first
      # one is free; printing again needs an approval for
      # `workspace.reprint_prebill` and taking one back an approval for
      # `workspace.cancel_prebill`, both bound to the order and its revision
      # and audited. A pre-bill takes no money and locks nothing: when the
      # order changes afterwards, the printed one is superseded and the table
      # shows it was edited after its pre-bill.
      #
      # Returns the record and the print document; with `printer_id` it also
      # queues the document to that printer.
      module Prebill
        MODULE = 'fnb.postpay'

        module_function

        def call(workspace:, staff:, key:, approval_id: nil, cancel: false, printer_id: nil, template_id: nil, mask: true)
          cancel = cancel == true || cancel.to_s == 'true'
          payload = { 'command' => cancel ? 'workspace.cancel_prebill' : 'workspace.prebill', 'approval_id' => approval_id.to_s.presence,
                      'printer_id' => printer_id.to_s.presence, 'receipt_template_id' => template_id.to_s.presence }
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace,
                               authorize: -> { Tables::RequestPayment.authorize!(workspace, staff) }) do
            ModulePolicy.require!(workspace.branch, MODULE)
            unless Workspace::OPEN_STATUSES.include?(workspace.operational_status)
              raise Conflict.new('This order is no longer open.', revision: workspace.revision, reason: 'workspace_closed')
            end

            supersede_stale!(workspace)
            cancel ? cancel!(workspace, staff, approval_id) : print!(workspace, staff, key, approval_id, printer_id, template_id, mask)
          end
        end

        # The current pre-bill no longer matches an order changed since.
        def supersede_stale!(workspace)
          PrebillPrint.where(workspace_id: workspace.id, status: 'current').where.not(revision: workspace.revision).
            update_all(status: 'superseded', updated_at: Time.current)
        end

        def print!(workspace, staff, key, approval_id, printer_id, template_id, mask)
          prints = PrebillPrint.where(workspace_id: workspace.id)
          # Any pre-bill still standing (current or superseded) makes this a reprint.
          approval = (approve!(workspace, staff, approval_id, PrebillPrint::REPRINT_ACTION) if prints.where.not(status: 'canceled').exists?)
          prints.where(status: 'current').update_all(status: 'superseded', updated_at: Time.current)
          order = workspace.order
          record = PrebillPrint.create!(workspace: workspace, revision: workspace.revision, sequence: (prints.maximum(:sequence) || 0) + 1,
                                        staff: staff, approval: approval, status: 'current', total: order.total, currency: order.currency)
          view = workspace.to_pos.as_json
          template = PrintJobs::Create.prebill_template(workspace, template_id)
          banner = record.sequence > 1 ? PrintDocuments::REPRINT_BANNER : nil
          document = PrintJobs::Create.prebill_document(workspace, view, template.current_config, mask: mask, banner: banner)
          job = queue!(workspace, staff, key, printer_id, view, template, document) if printer_id.present?
          AuditEntry.record!(store: workspace.store, actor: staff, action: 'workspace.prebill', subject: workspace,
                             metadata: { prebill_id: record.prefixed_id, sequence: record.sequence, revision: workspace.revision,
                                         total: order.total.to_s('F'), approval_id: approval&.prefixed_id,
                                         approver_id: approval&.approver&.prefixed_id, print_job_id: job&.prefixed_id }.compact)
          Realtime.publish(workspace.branch, 'resource.updated', id: workspace.resource.prefixed_id) if workspace.resource
          { 'prebill' => record.to_pos, 'document' => document, 'print_job' => job&.to_pos }.compact
        end

        def cancel!(workspace, staff, approval_id)
          record = PrebillPrint.where(workspace_id: workspace.id, status: %w[current superseded]).order(:sequence).last
          raise Conflict.new('There is no pre-bill to cancel.', revision: workspace.revision, reason: 'prebill_missing') if record.nil?

          approval = approve!(workspace, staff, approval_id, PrebillPrint::CANCEL_ACTION)
          PrebillPrint.where(workspace_id: workspace.id, status: %w[current superseded]).update_all(status: 'canceled', updated_at: Time.current)
          AuditEntry.record!(store: workspace.store, actor: staff, action: 'workspace.prebill.cancel', subject: workspace,
                             metadata: { prebill_id: record.prefixed_id, sequence: record.sequence, approval_id: approval.prefixed_id,
                                         approver_id: approval.approver.prefixed_id })
          Realtime.publish(workspace.branch, 'resource.updated', id: workspace.resource.prefixed_id) if workspace.resource
          { 'prebill' => record.reload.to_pos }
        end

        def approve!(workspace, staff, approval_id, action)
          raise Conflict.new('This needs a manager approval.', revision: workspace.revision, reason: 'approval_required', details: { action: action }) if approval_id.blank?

          approval = Approval.locate(Approval.for_store(workspace.store).where(branch_id: workspace.branch_id), approval_id)
          raise Conflict.new('This needs a manager approval.', revision: workspace.revision, reason: 'approval_required', details: { action: action }) if approval.nil?

          approval.consume!(action: action, amount: nil, currency: nil, revision: workspace.revision, subject: workspace, requester: staff)
          AuditEntry.record!(store: workspace.store, actor: staff, action: 'approval.consume', subject: approval,
                             metadata: { approval_action: action, approver_id: approval.approver.prefixed_id })
          approval
        end

        def queue!(workspace, staff, key, printer_id, view, template, document)
          printer = PrintJobs::Guard.printer!(workspace.store, printer_id, branch: workspace.branch)
          PrintJobs::Enqueue.ensure_accepts!(printer, 'prebill')
          PrintJobs::Enqueue.call(store: workspace.store, printer: printer, kind: 'prebill', key: PrintJobs::Create.job_key(staff, key),
                                  actor: staff, source: workspace, source_revision: workspace.revision,
                                  content_digest: PrintJobs::Create.prebill_digest(view), receipt_template: template,
                                  template_version: template.current_version, document: document)
        end
      end
    end
  end
end

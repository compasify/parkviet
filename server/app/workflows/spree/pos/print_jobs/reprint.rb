# frozen_string_literal: true

module Spree
  module Pos
    module PrintJobs
      # Prints a queued document again, as a new job. A receipt records a copy
      # as any reprint does. A pre-bill spends an approval bound to the
      # workspace and its revision, so the approval cannot be replayed and is
      # void once the order changes. Anything else is stamped as a reprint and
      # creates nothing else, a kitchen ticket included.
      module Reprint
        module_function

        def call(store:, staff:, key:, job:, approval_id: nil, mask: true, authorize:)
          payload = { 'command' => 'print_job.reprint', 'print_job_id' => job.prefixed_id, 'approval_id' => approval_id.to_s.presence }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            printer = job.printer
            Enqueue.ensure_accepts!(printer, job.kind)
            attributes = reprint_attributes(store, staff, job, approval_id, mask)
            print = attributes[:receipt_print]
            copy = Enqueue.call(store: store, printer: printer, kind: job.kind, key: Create.job_key(staff, key), actor: staff, copy_of: job, **attributes)
            AuditEntry.record!(store: store, actor: staff, action: 'print_job.reprint', subject: job,
                               metadata: { print_job_id: copy.prefixed_id, kind: job.kind, approval_id: approval_id.to_s.presence })
            { 'print_job' => copy.to_pos, 'print' => print&.to_pos }.compact
          end
        end

        def reprint_attributes(store, staff, job, approval_id, mask)
          case job.kind
          when 'receipt' then receipt_attributes(staff, job, mask)
          when 'prebill' then prebill_attributes(store, staff, job, approval_id, mask)
          else { source: job.source, document: PrintDocuments.reprint(job.document) }
          end
        end

        def receipt_attributes(staff, job, mask)
          snapshot = job.source
          raise ActiveRecord::RecordNotFound if snapshot.nil?

          print = ReceiptPrint.record!(snapshot: snapshot, actor: staff, requested: requested_layout(job))
          { source: snapshot, receipt_print: print, document: Create.receipt_document(snapshot, print, mask) }
        end

        # The layout of the job being reprinted, when it recorded one. A
        # template disabled since is refused unless it is the original's, so
        # then the print falls back to the original's or the branch's layout.
        def requested_layout(job)
          print = job.receipt_print
          template = print&.receipt_template
          return {} unless template
          return {} if template.disabled? && template.id != print.receipt_snapshot.prints.active.find_by(copy_number: 0)&.receipt_template_id

          { 'receipt_template_id' => template.prefixed_id, 'template_version' => print.template_version.to_s, 'paper' => print.paper }.compact
        end

        # Prints the order as it is now on the template and version first
        # chosen, even if that template was disabled since.
        def prebill_attributes(store, staff, job, approval_id, mask)
          workspace = job.source
          raise ActiveRecord::RecordNotFound if workspace.nil?

          workspace.lock!
          Guard.open_workspace!(workspace)
          consume_approval!(store, staff, workspace, approval_id)
          view = workspace.to_pos.as_json
          template = job.receipt_template || Create.prebill_template(workspace, nil)
          version = job.receipt_template ? job.template_version : template.current_version
          { source: workspace, source_revision: workspace.revision, content_digest: Create.prebill_digest(view), receipt_template: template, template_version: version,
            document: Create.prebill_document(workspace, view, template.version_record(version).config, mask: mask, banner: PrintDocuments::REPRINT_BANNER) }
        end

        def consume_approval!(store, staff, workspace, approval_id)
          raise Conflict.new('Reprinting a pre-bill needs an approval.', reason: 'approval_required') if approval_id.blank?

          approval = Approval.locate(Approval.for_store(store).where(branch_id: workspace.branch_id), approval_id)
          raise Conflict.new('Reprinting a pre-bill needs an approval.', reason: 'approval_required') if approval.nil?

          approval.consume!(action: PrintJob::REPRINT_PREBILL_ACTION, amount: nil, currency: nil, revision: workspace.revision,
                            subject: workspace, requester: staff)
        end
      end
    end
  end
end

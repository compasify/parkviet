# frozen_string_literal: true

module Spree
  module Pos
    module PrintJobs
      # Queues a receipt or a pre-bill from the counter. The job's key is
      # scoped to the staff member, as a command key is: another person reusing
      # a key must get a job of their own. Results hold no document.
      module Create
        # What a pre-bill bills. Serials, tenders, the service mode and the like
        # move the workspace revision without changing what the customer owes.
        DIGEST_LINE_FIELDS = %w[variant_id name sku quantity sale_quantity sale_unit unit_price price amount net_amount item_net_amount].freeze
        DIGEST_CUSTOMER_FIELDS = %w[name phone address].freeze

        module_function

        def job_key(staff, key)
          "staff:#{staff.id}:#{key}"
        end

        # Records the print as the counter does, then queues it labelled with
        # the number it was given.
        def receipt(store:, staff:, key:, snapshot:, printer:, requested:, mask:, authorize:)
          payload = { 'command' => 'print_job.receipt', 'receipt_id' => snapshot.prefixed_id, 'printer_id' => printer.prefixed_id }
          payload['layout'] = requested if requested.any?
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            Enqueue.ensure_accepts!(printer, 'receipt')
            print = ReceiptPrint.record!(snapshot: snapshot, actor: staff, requested: requested)
            job = Enqueue.call(store: store, printer: printer, kind: 'receipt', key: job_key(staff, key), actor: staff, source: snapshot,
                               receipt_print: print, document: receipt_document(snapshot, print, mask))
            { 'print_job' => job.to_pos, 'print' => print.to_pos }
          end
        end

        def receipt_document(snapshot, print, mask)
          config = print.receipt_template.version_record(print.template_version).config
          PrintDocuments.receipt(receipt: snapshot.to_pos(mask: mask).as_json, print: print.to_pos.as_json, config: config)
        end

        # The first print of this content needs no approval; any later one
        # goes through the reprint endpoint.
        def prebill(store:, staff:, key:, workspace:, printer:, template_id:, mask:, authorize:)
          payload = { 'command' => 'print_job.prebill', 'workspace_id' => workspace.prefixed_id, 'printer_id' => printer.prefixed_id,
                      'receipt_template_id' => template_id.presence }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            workspace.lock!
            Guard.open_workspace!(workspace)
            Enqueue.ensure_accepts!(printer, 'prebill')
            view = workspace.to_pos.as_json
            digest = prebill_digest(view)
            raise Conflict.new('This pre-bill was already printed.', reason: 'prebill_already_printed') if PrintJob.prebill_issued?(workspace, digest)

            template = prebill_template(workspace, template_id)
            job = Enqueue.call(store: store, printer: printer, kind: 'prebill', key: job_key(staff, key), actor: staff, source: workspace,
                               source_revision: workspace.revision, content_digest: digest, receipt_template: template,
                               template_version: template.current_version,
                               document: prebill_document(workspace, view, template.current_config, mask: mask))
            AuditEntry.record!(store: store, actor: staff, action: 'print_job.prebill', subject: workspace,
                               metadata: { print_job_id: job.prefixed_id, revision: workspace.revision })
            { 'print_job' => job.to_pos }
          end
        end

        def prebill_digest(view)
          content = { 'lines' => Array(view['line_items']).map { |line| line.slice(*DIGEST_LINE_FIELDS) }, 'totals' => view['totals'],
                      'customer' => view['customer']&.slice(*DIGEST_CUSTOMER_FIELDS), 'note' => view['note'] }
          Digest::SHA256.hexdigest(content.to_json)
        end

        # A queued document is stored and sent to a station, so its customer is
        # masked as on a receipt.
        def prebill_document(workspace, view, config, mask:, banner: nil)
          shown = view['customer'] ? view.merge('customer' => ReceiptSnapshot.masked_customer(view['customer'], mask: mask)) : view
          PrintDocuments.prebill(workspace: shown, place: PrintDocuments.place_of(workspace), config: config,
                                 now: Workspace.database_now, time_zone: workspace.branch.timezone, banner: banner)
        end

        def prebill_template(workspace, template_id)
          return ReceiptTemplate.effective_for(workspace.store, 'prebill', branch: workspace.branch) if template_id.blank?

          template = ReceiptTemplate.locate(ReceiptTemplate.for_store(workspace.store).where(document_type: 'prebill'), template_id)
          raise ActiveRecord::RecordNotFound if template.nil?
          raise Conflict.new('This template is disabled.', reason: 'template_disabled') if template.disabled?

          template
        end
      end
    end
  end
end

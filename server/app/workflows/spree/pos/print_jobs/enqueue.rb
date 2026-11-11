# frozen_string_literal: true

module Spree
  module Pos
    module PrintJobs
      # Puts one document in a printer's line, once per idempotency key. The
      # printer row lock serializes inserts, so ids commit in order and a
      # station cannot pick a later job while an earlier id is still uncommitted.
      # Returns the job; a replay publishes nothing.
      module Enqueue
        module_function

        def call(store:, printer:, kind:, document:, key:, actor: nil, source: nil, source_revision: nil, copy_of: nil, receipt_print: nil,
                 content_digest: nil, receipt_template: nil, template_version: nil)
          PrintJob.transaction(requires_new: true) do
            printer.lock!
            existing = PrintJob.find_by(store_id: store.id, idempotency_key: key)
            next existing if existing

            ensure_queueable!(printer)
            ensure_not_reprinted!(copy_of)
            job = PrintJob.create!(store: store, branch: printer.branch, printer: printer, kind: kind, document: document,
                                   source_type: source&.class&.name, source_id: source&.id, source_revision: source_revision,
                                   idempotency_key: key, created_by: actor, copy_of: copy_of, receipt_print: receipt_print,
                                   content_digest: content_digest, receipt_template: receipt_template, template_version: template_version)
            Realtime.publish(printer.branch, 'print_job.created', id: job.prefixed_id, refs: { printer_id: printer.prefixed_id })
            job
          end
        rescue ActiveRecord::RecordNotUnique
          # Only a concurrent enqueue of this key is a replay.
          PrintJob.find_by(store_id: store.id, idempotency_key: key) || raise
        end

        def ensure_queueable!(printer)
          raise Conflict.new('This printer is disabled.', reason: 'printer_disabled') if printer.disabled?
          raise Conflict.new('This printer does not take queued jobs.', reason: 'printer_not_queued') unless printer.station?
          raise Conflict.new('The print station of this printer is not active.', reason: 'printer_station_unavailable') unless printer.station_live?
        end

        def ensure_accepts!(printer, kind)
          ensure_queueable!(printer)
          raise Conflict.new('This printer is not set up for this document.', reason: 'printer_wrong_kind') unless printer.prints?(kind)
        end

        # Checked under the printer lock, so two reprints of a failed job
        # cannot both get through.
        def ensure_not_reprinted!(original)
          return unless original&.status == 'failed' && original.live_copies.exists?

          raise Conflict.new('This job was already reprinted.', reason: 'print_job_already_reprinted')
        end
      end
    end
  end
end

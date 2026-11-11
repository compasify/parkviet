# frozen_string_literal: true

module Spree
  module Pos
    module PrintJobs
      # Removes a job from the line. A job out at a station with a live claim
      # cannot be canceled: it may already be printing, and its lease ends soon.
      module Cancel
        CANCELABLE = %w[queued failed].freeze

        module_function

        def call(store:, staff:, key:, job:)
          payload = { 'command' => 'print_job.cancel', 'print_job_id' => job.prefixed_id }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { Guard.operate!(store, staff, job.branch) }) do
            # Lock order: snapshot before printer, as when recording a print.
            job.receipt_print&.receipt_snapshot&.lock!
            job.printer.lock!
            job.lock!
            raise Conflict.new('This job can no longer be canceled.', reason: 'print_job_not_cancelable') unless CANCELABLE.include?(job.status)

            job.update!(status: 'canceled', claim_expires_at: nil)
            job.receipt_print&.void_if_latest! if job.provably_unprinted?
            AuditEntry.record!(store: store, actor: staff, action: 'print_job.cancel', subject: job,
                               metadata: { kind: job.kind, attempts: job.attempts, printer_id: job.printer.prefixed_id })
            Realtime.publish(job.branch, 'resource.updated', id: job.prefixed_id, refs: { printer_id: job.printer.prefixed_id })
            job.to_pos
          end
        end
      end
    end
  end
end

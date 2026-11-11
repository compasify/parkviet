# frozen_string_literal: true

module Spree
  module Pos
    module PrintJobs
      # Takes back claims whose lease ran out. The lease is what bounds a
      # station that died mid-job; its last attempt stays reportable until the
      # job is claimed again.
      module Release
        module_function

        # Every expired claim of one printer. A printer locked right now is
        # left for the next run.
        def call(printer_id:)
          PrintJob.transaction do
            printer = Printer.where(id: printer_id).lock('FOR UPDATE SKIP LOCKED').first
            next 0 if printer.nil?

            now = Workspace.database_now
            expired = PrintJob.where(printer_id: printer.id, status: 'claimed').where(claim_expires_at: ..now).order(:id).to_a
            expired.each { |job| expire!(job) }
            expired.size
          end
        end

        # The caller holds the printer lock.
        def expire!(job)
          job.update!(status: job.exhausted? ? 'failed' : 'queued', claim_expires_at: nil, last_error: PrintJob::LEASE_EXPIRED)
          Realtime.publish(job.branch, 'print_job.created', id: job.prefixed_id, refs: { printer_id: job.printer.prefixed_id })
        end
      end
    end
  end
end

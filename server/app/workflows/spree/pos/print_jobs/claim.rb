# frozen_string_literal: true

module Spree
  module Pos
    module PrintJobs
      # Hands a print station its next job. The lock is on the printer, under
      # SKIP LOCKED, not on job rows: a printer another transaction is working on
      # is skipped whole, so a later job can never overtake an earlier one that
      # happens to be locked. Each printer has at most one job out at a time; a
      # later job waits while an earlier one holds a live lease or waits out its
      # retry delay, and a `failed` or `canceled` job holds no place in the line.
      module Claim
        module_function

        def call(device:)
          printer_ids(device).each do |printer_id|
            job = claim_from(printer_id, device)
            return job if job
          end
          nil
        end

        def printer_ids(device)
          Printer.active.where(store_id: device.store_id, branch_id: device.branch_id, print_station_device_id: device.id).order(:id).pluck(:id)
        end

        def claim_from(printer_id, device)
          PrintJob.transaction do
            printer = Printer.active.where(id: printer_id, print_station_device_id: device.id).lock('FOR UPDATE SKIP LOCKED').first
            next nil if printer.nil?

            now = Workspace.database_now
            job = head(printer, now)
            next nil if job.nil? || job.claimed? || job.waiting?(now)

            job.update!(status: 'claimed', attempts: job.attempts + 1, claimed_by_device: device, claim_expires_at: now + PrintJob::LEASE, next_attempt_at: nil)
            Realtime.publish(job.branch, 'resource.updated', id: job.prefixed_id, refs: { printer_id: printer.prefixed_id })
            job
          end
        end

        # The first job still in line, after taking back expired claims ahead of it.
        def head(printer, now)
          loop do
            job = PrintJob.pending.where(printer_id: printer.id).order(:id).first
            return job unless job&.lease_expired?(now)

            Release.expire!(job)
          end
        end
      end
    end
  end
end

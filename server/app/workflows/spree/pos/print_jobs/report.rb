# frozen_string_literal: true

module Spree
  module Pos
    module PrintJobs
      # A print station says how one attempt ended. `attempt` fences the report:
      # the job's attempt counter only moves when the job is claimed again, so
      # the attempt it names is either the latest (accepted, even if the lease
      # has lapsed, because nothing has re-sent the job yet) or superseded
      # (refused, and the newer attempt is left alone). Each attempt's answer is
      # kept, so repeating it after a lost response changes nothing.
      module Report
        STALE = 'print_claim_stale'

        module_function

        def call(device:, job_id:, attempt:, status:, error: nil)
          found = locate(device, job_id)
          PrintJob.transaction do
            # Lock order: snapshot before printer, as when recording a print.
            found.receipt_print&.receipt_snapshot&.lock!
            Printer.lock.find(found.printer_id)
            job = found.lock!
            prior = job.attempt_reports[attempt.to_s]
            next replay(job, prior, device, status) if prior

            current!(job, device, attempt)
            record(job, device, attempt, status, error)
            job
          end
        end

        # A job of this device's branch that it holds or prints for.
        def locate(device, job_id)
          job = PrintJob.locate(PrintJob.for_store(device.store).where(branch_id: device.branch_id), job_id)
          raise ActiveRecord::RecordNotFound if job.nil?
          raise ActiveRecord::RecordNotFound unless job.claimed_by_device_id == device.id || job.printer.print_station_device_id == device.id

          job
        end

        def replay(job, prior, device, status)
          return job if prior['device_id'] == device.prefixed_id && prior['status'] == status

          raise Conflict.new('This attempt was already reported differently.', reason: 'print_report_mismatch')
        end

        def current!(job, device, attempt)
          latest = job.claimed_by_device_id == device.id && job.attempts == attempt
          open = job.claimed? || job.status == 'queued' || (job.status == 'failed' && job.last_error == PrintJob::LEASE_EXPIRED)
          raise Conflict.new('This attempt is no longer current.', reason: STALE) unless latest && open
        end

        def record(job, device, attempt, status, error)
          reports = job.attempt_reports.merge(attempt.to_s => { 'status' => status, 'device_id' => device.prefixed_id })
          status == 'printed' ? printed(job, reports) : failed(job, reports, error)
        end

        def printed(job, reports)
          job.update!(status: 'printed', printed_at: Time.current, claim_expires_at: nil, last_error: nil, attempt_reports: reports)
          publish(job, 'resource.updated')
        end

        # A failed attempt goes back in line, after a delay, until the attempts
        # run out. An answer to an attempt whose lease already lapsed only adds
        # the reason.
        def failed(job, reports, error)
          message = error.to_s.first(PrintJob::MAX_ERROR_LENGTH).presence || 'printer_error'
          unless job.claimed?
            job.update!(last_error: message, attempt_reports: reports)
            release_receipt(job)
            return
          end

          retry_at = job.exhausted? ? nil : Workspace.database_now + PrintJob.retry_delay(job.attempts)
          job.update!(status: job.exhausted? ? 'failed' : 'queued', claim_expires_at: nil, last_error: message, attempt_reports: reports, next_attempt_at: retry_at)
          release_receipt(job)
          publish(job, 'print_job.created')
        end

        # A receipt that certainly never printed gives its number back.
        def release_receipt(job)
          return unless job.status == 'failed' && job.provably_unprinted?

          job.receipt_print&.void_if_latest!
        end

        def publish(job, event)
          Realtime.publish(job.branch, event, id: job.prefixed_id, refs: { printer_id: job.printer.prefixed_id })
        end
      end
    end
  end
end

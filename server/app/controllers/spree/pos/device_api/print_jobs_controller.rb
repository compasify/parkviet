# frozen_string_literal: true

module Spree
  module Pos
    module DeviceApi
      # The print station's side of the queue. Printing is at-least-once: a
      # station must deliver the report of an attempt before claiming again.
      class PrintJobsController < BaseController
        before_action { require_mode!('print_station') }

        rescue_from Conflict do |error|
          render json: { error: { code: 'conflict', message: error.message, details: { reason: error.reason }.compact } }, status: :conflict
        end

        def claim
          job = PrintJobs::Claim.call(device: @device)
          render json: { data: job&.to_claim }
        end

        def report
          attempt = Integer(params[:attempt].to_s, 10, exception: false)
          unless attempt&.positive? && %w[printed failed].include?(params[:status])
            render json: { error: { code: 'parameter_invalid', message: 'A positive attempt and a status of printed or failed are required.' } },
                   status: :unprocessable_content
            return
          end

          job = PrintJobs::Report.call(device: @device, job_id: params[:id], attempt: attempt, status: params[:status], error: params[:error])
          render json: { data: job.to_pos }
        end
      end
    end
  end
end

# frozen_string_literal: true

module Spree
  module Pos
    # Returns print jobs whose station lease ran out, or fails them once their
    # attempts are used up. One printer's trouble never stops the others.
    class ReleasePrintClaimsJob < ApplicationJob
      queue_as :default

      def perform(limit: 500)
        expired_printer_ids(limit).each do |printer_id|
          PrintJobs::Release.call(printer_id: printer_id)
        rescue StandardError => e
          Rails.error.report(e, handled: true, context: { pos_printer_id: printer_id })
        end
      end

      private

      def expired_printer_ids(limit)
        PrintJob.where(status: 'claimed').where(claim_expires_at: ..Workspace.database_now).distinct.limit(limit).pluck(:printer_id)
      end
    end
  end
end

# frozen_string_literal: true

module Spree
  module Pos
    module BottleKeeps
      # Kept bottles past their date are marked expired, each in its own
      # transaction with an `expire` line in its history. Nothing is sold or
      # thrown away: what happens to the bottle is the bar's call.
      class ExpireJob < ApplicationJob
        queue_as :default

        def perform(limit: 500)
          today = Date.current
          overdue = BottleKeep.where(status: 'kept').where('expires_on < ?', today).order(:expires_on, :id).limit(limit).pluck(:id)
          overdue.each do |id|
            BottleKeep.transaction do
              keep = BottleKeep.lock.find(id)
              next unless keep.kept? && keep.expires_on < BusinessDay.for(keep.branch, Workspace.business_now)

              Close.close!(keep, nil, 'expire', nil)
            end
          rescue StandardError => e
            Rails.error.report(e, handled: true, context: { pos_bottle_keep_id: id })
          end
        end
      end
    end
  end
end
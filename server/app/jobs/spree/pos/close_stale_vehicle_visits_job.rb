# frozen_string_literal: true

module Spree
  module Pos
    # Coach visits still open past their window close by themselves, each in
    # its own transaction and as the person who opened it, with the
    # commission kept like a close at the counter (VehicleVisits::Close).
    # Nothing is paid: paying stays a person's command.
    class CloseStaleVehicleVisitsJob < ApplicationJob
      queue_as :default

      def perform(limit: 500)
        now = Workspace.database_now
        due = VehicleVisit.open_now.where(closes_at: ..now).order(:closes_at, :id).limit(limit).pluck(:id)
        due.each do |id|
          VehicleVisit.transaction do
            visit = VehicleVisit.find(id)
            VehicleVisits::Close.close!(visit, visit.opened_by, auto: true) if visit.closes_at <= now
          end
        rescue StandardError => e
          Rails.error.report(e, handled: true, context: { pos_vehicle_visit_id: id })
        end
      end
    end
  end
end

# frozen_string_literal: true

module Spree
  module Pos
    # Every minute: looks for what an owner should hear about (OwnerAlerts)
    # in every active branch. Alerts are stored once, so a late or repeated
    # run only delays a notice.
    class OwnerAlertsScanJob < ApplicationJob
      queue_as :default

      def perform
        now = Workspace.database_now
        Branch.where(status: 'active').includes(:store).find_each { |branch| OwnerAlerts.scan!(branch, now: now) }
        Spree::Store.where(id: Branch.where(status: 'active').select(:store_id)).find_each do |store|
          OwnerAlerts.revenue_milestone!(store, now: now)
        rescue StandardError => e
          Rails.error.report(e, handled: true, context: { pos_store_id: store.id, pos_owner_alert: 'revenue_milestone' })
        end
      end
    end
  end
end

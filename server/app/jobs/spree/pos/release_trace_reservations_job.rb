# frozen_string_literal: true

module Spree
  module Pos
    # Serial/lot reservation sweep: releases reservations whose TTL ran out
    # (abandoned drafts never pin stock), gives payment-held reservations a
    # TTL again once no payment holds the draft, and raises attention once
    # per drift episode for tracked pairs whose typed stock no longer matches
    # the core shelf (pairs already alerted and unchanged are skipped).
    class ReleaseTraceReservationsJob < ApplicationJob
      queue_as :default

      def perform
        Inventory::AllocateTraceability.expire_stale!
        TraceEnrollment.includes(:variant, :stock_location, :branch).find_each do |enrollment|
          StockIntegration.check_drift!(enrollment, skip_unchanged: true)
        rescue StandardError => e
          Rails.logger.error("[pos] trace drift check failed for enrollment #{enrollment.id}: #{e.class}: #{e.message}")
        end
      end
    end
  end
end

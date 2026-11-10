# frozen_string_literal: true

module Spree
  module Pos
    # Copies due tax-rate schedules onto their rates. The date is Vietnam's,
    # because the scheduled amounts are Vietnam VAT. Running twice does nothing
    # to a row already applied.
    class ApplyTaxRateScheduleJob < ApplicationJob
      queue_as :default

      def perform
        apply(Time.current.in_time_zone('Asia/Ho_Chi_Minh').to_date)
      end

      def apply(day)
        TaxRateSchedule.pending.where(effective_on: ..day).order(:effective_on, :id).each do |schedule|
          schedule.with_lock do
            next if schedule.applied_at

            schedule.tax_rate.update!(amount: schedule.amount)
            schedule.update!(applied_at: Time.current)
          end
        end
      end
    end
  end
end

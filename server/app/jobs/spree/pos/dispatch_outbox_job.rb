# frozen_string_literal: true

module Spree
  module Pos
    # Marks due outbox entries processed. No external provider I/O in phase 6;
    # this only proves the enqueue-gap recovery seam is durable and retry-safe.
    class DispatchOutboxJob < ApplicationJob
      queue_as :default

      def perform(limit: 100)
        OutboxEntry.due.limit(limit).each do |entry|
          entry.update!(status: 'processed', processed_at: Time.current, attempts: entry.attempts + 1)
        end
      end
    end
  end
end

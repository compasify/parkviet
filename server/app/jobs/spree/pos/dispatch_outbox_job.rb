# frozen_string_literal: true

module Spree
  module Pos
    # Marks due outbox entries processed. There is no external provider I/O
    # yet; this keeps the enqueue-gap recovery seam durable and retry-safe.
    # Each entry is claimed under SKIP LOCKED so concurrent workers never
    # handle the same entry twice.
    class DispatchOutboxJob < ApplicationJob
      queue_as :default

      def perform(limit: 100)
        limit.times do
          break unless dispatch_next
        end
      end

      private

      def dispatch_next
        OutboxEntry.transaction do
          entry = OutboxEntry.due.lock('FOR UPDATE SKIP LOCKED').first
          next false if entry.nil?

          entry.update!(status: 'processed', processed_at: Time.current, attempts: entry.attempts + 1)
          true
        end
      end
    end
  end
end

# frozen_string_literal: true

module Spree
  module Pos
    # Drains due outbox entries. Event types with a handler in HANDLERS do
    # work that leaves this server (issuing an e-invoice); every other type
    # has no external I/O yet and is only marked processed, which keeps the
    # enqueue-gap recovery seam durable and retry-safe.
    #
    # Each entry is claimed under SKIP LOCKED so concurrent workers never
    # take the same entry. A handled entry is claimed as `processing` with a
    # lease and committed before its handler runs, so the handler's network
    # call never holds a database lock; a worker that dies mid-call leaves a
    # lease that runs out and the entry is taken again. The handler answers
    # nil when done, or the time to try again.
    class DispatchOutboxJob < ApplicationJob
      queue_as :default

      HANDLERS = { Einvoices::ISSUE_EVENT => 'Spree::Pos::Einvoices::Issue' }.freeze
      LEASE = 15.minutes
      ERROR_RETRY = 5.minutes

      def perform(limit: 100)
        limit.times do
          break unless dispatch_next
        end
      end

      private

      def dispatch_next
        entry = claim_next
        return false if entry.nil?

        run(entry) if HANDLERS.key?(entry.event_type)
        true
      end

      def claim_next
        OutboxEntry.transaction do
          now = Time.current
          entry = OutboxEntry.where(status: %w[pending processing]).where(available_at: ..now).order(:id).
                  lock('FOR UPDATE SKIP LOCKED').first
          next nil if entry.nil?

          if HANDLERS.key?(entry.event_type)
            entry.update!(status: 'processing', available_at: now + LEASE, attempts: entry.attempts + 1)
          else
            entry.update!(status: 'processed', processed_at: now, attempts: entry.attempts + 1)
          end
          entry
        end
      end

      def run(entry)
        retry_at = HANDLERS.fetch(entry.event_type).constantize.handle(entry)
        if retry_at
          entry.update!(status: 'pending', available_at: retry_at)
        else
          entry.update!(status: 'processed', processed_at: Time.current, last_error: nil)
        end
      rescue StandardError => e
        Rails.error.report(e, handled: true, context: { outbox_entry_id: entry.id, event_type: entry.event_type })
        entry.update!(status: 'pending', available_at: Time.current + ERROR_RETRY, last_error: e.class.name)
      end
    end
  end
end

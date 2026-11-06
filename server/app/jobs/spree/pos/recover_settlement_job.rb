# frozen_string_literal: true

module Spree
  module Pos
    # Recovery sweep: surfaces workspaces stuck with prepared/unknown tenders
    # or completed money without placement, for staff attention. It never
    # charges or completes anything on its own.
    class RecoverSettlementJob < ApplicationJob
      queue_as :default

      def perform
        TenderAttempt.unresolved.where('created_at < ?', 15.minutes.ago).find_each do |attempt|
          OutboxEntry.record!(store: attempt.store, event_type: 'tender.attention', aggregate: attempt,
                              payload: { 'attempt_id' => attempt.prefixed_id, 'workspace_id' => attempt.workspace.prefixed_id })
        end
      end
    end
  end
end

# frozen_string_literal: true

module Spree
  module Pos
    # Recovery sweep: surfaces money that is stuck for staff attention —
    # prepared/unknown tenders, funds that already cover an order that was
    # never placed, and payouts still awaiting an outcome. It never charges,
    # completes or releases anything on its own, and raises each item once.
    class RecoverSettlementJob < ApplicationJob
      queue_as :default

      STALE_AFTER = 15.minutes

      def perform
        cutoff = STALE_AFTER.ago
        TenderAttempt.unresolved.where(created_at: ...cutoff).includes(:workspace).find_each do |attempt|
          raise_once(attempt.store_id, 'tender.attention', attempt,
                     'attempt_id' => attempt.prefixed_id, 'workspace_id' => attempt.workspace.prefixed_id)
        end
        completion_pending(cutoff).each do |workspace|
          raise_once(workspace.store_id, 'workspace.completion_pending', workspace,
                     'workspace_id' => workspace.prefixed_id, 'order_id' => workspace.order.prefixed_id)
        end
        LiabilityPayout.where(status: %w[requested reserved unknown]).where(updated_at: ...cutoff).find_each do |payout|
          raise_once(payout.store_id, 'liability_payout.attention', payout, 'payout_id' => payout.prefixed_id)
        end
        release_unusable_credit
      end

      # Expired or otherwise unusable credit reservations stop counting at once
      # (they are excluded from exposure in SQL); this sweep records their
      # release for workspaces nobody touched since. The approver is the actor
      # of record because the job acts on their lapsed approval.
      def release_unusable_credit
        stale = CreditReservation.active_now.where.not(id: CreditReservation.holding.select(:id)).includes(:workspace, :approval)
        stale.find_each do |reservation|
          Credit::Release.stale!(workspace: reservation.workspace, actor: reservation.approval.approver,
                                 reason: 'expired_or_unusable')
        end
      end

      private

      def completion_pending(cutoff)
        covered = FundsAllocation.where(status: 'active').group(:workspace_id).sum(:amount)
        Workspace.where(id: covered.keys, operational_status: 'editing').where(updated_at: ...cutoff).
          includes(:order).select do |workspace|
          order = workspace.order
          order.total.positive? && covered[workspace.id] >= order.total && !order.placed? && !order.completed?
        end
      end

      def raise_once(store_id, event_type, aggregate, payload)
        return if OutboxEntry.exists?(event_type: event_type, aggregate_type: aggregate.class.name, aggregate_id: aggregate.id)

        OutboxEntry.create!(store_id: store_id, event_type: event_type, aggregate_type: aggregate.class.name,
                            aggregate_id: aggregate.id, payload: payload, status: 'pending', available_at: Time.current)
      end
    end
  end
end

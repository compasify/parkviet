# frozen_string_literal: true

module Spree
  module Pos
    # Recovery sweep for returns, refunds and short handovers. It
    # - posts received returns whose predecessors have since been resolved,
    # - cancels returns nobody received within ReturnOperation::TTL,
    # - dispatches short handovers once the shelf covers them,
    # - raises attention, once, for refunds still reserved or unknown, returns
    #   waiting on a predecessor or on the counter, and open stock shortfalls.
    # It never pays, approves or releases money. Every item is handled on its
    # own: a failure is logged and raised for attention, and the sweep goes on.
    class RecoverReturnOperationJob < ApplicationJob
      queue_as :default

      STALE_AFTER = 15.minutes

      def perform
        cutoff = STALE_AFTER.ago
        post_waiting
        expire_abandoned
        retry_short_handovers
        RefundRequest.reserving.where(updated_at: ...cutoff).find_each do |request|
          attention(request, "refund.attention.#{request.status}", 'refund_id' => request.prefixed_id, 'status' => request.status)
        end
        ReturnOperation.where(entitlement_status: 'awaiting_predecessor').where(updated_at: ...cutoff).find_each do |operation|
          attention(operation, 'return.awaiting_predecessor', 'return_id' => operation.prefixed_id)
        end
        ReturnOperation.where(status: %w[pending_approval ready]).where(created_at: ...cutoff).find_each do |operation|
          attention(operation, 'return.stale', 'return_id' => operation.prefixed_id, 'status' => operation.status)
        end
        StockDiscrepancy.open_now.where(created_at: ...cutoff).find_each do |gap|
          attention(gap, 'stock.discrepancy.attention', 'discrepancy_id' => gap.prefixed_id)
        end
      end

      private

      def post_waiting
        ReturnOperation.where(status: 'received', entitlement_status: 'awaiting_predecessor').order(:id).pluck(:id).each do |id|
          rescued(ReturnOperation, id) do
            ApplicationRecord.transaction do
              operation = ReturnOperation.lock.find(id)
              Returns::Guard.lock_sale_lines!(operation.reservations.pluck(:sale_line_id))
              Returns::ApplyCreditNote.call(operation: operation, actor: operation.receiver || operation.requester)
            end
          end
        end
      end

      def expire_abandoned
        ReturnOperation.where(status: %w[pending_approval ready]).where(created_at: ...ReturnOperation::TTL.ago).
          order(:id).pluck(:id).each do |id|
          rescued(ReturnOperation, id) { Returns::Cancel.expire!(ReturnOperation.find(id)) }
        end
      end

      def retry_short_handovers
        StockDiscrepancy.open_now.handover.distinct.order(:workspace_id).pluck(:workspace_id).each do |workspace_id|
          rescued(Workspace, workspace_id) do
            ApplicationRecord.transaction do
              workspace = Workspace.lock.find(workspace_id)
              gaps = StockDiscrepancy.open_now.handover.where(workspace_id: workspace_id).includes(:fulfillment).order(:id).to_a
              # Only once the shelf covers every short fulfillment; until then
              # a sweep would only re-record the same shortfall.
              next if gaps.empty? || gaps.map(&:fulfillment).uniq.any? { |row| Orders::Handover.shelf_shortfall(row).any? }

              gap = gaps.first
              Orders::Handover.dispatch!(workspace: workspace, staff: gap.actor, action: 'order.handover_recovered')
            end
          end
        end
      end

      def rescued(model, id)
        yield
      rescue StandardError => e
        Rails.logger.error("[pos] return recovery failed for #{model.name}##{id}: #{e.class}: #{e.message}")
        record = model.find_by(id: id)
        attention(record, 'recovery.failed', 'error' => e.class.name, 'message' => e.message.first(200)) if record
      end

      def attention(record, event_type, payload)
        OutboxEntry.record_once!(store_id: record.store_id, event_type: event_type, aggregate: record, payload: payload)
      end
    end
  end
end

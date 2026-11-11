# frozen_string_literal: true

module Spree
  module Pos
    # What must be resolved before a shift can close, as actionable items:
    # - tender attempts on the shift that are prepared or unknown (money may be
    #   on its way; cancel or resolve them first);
    # - drafts on the shift (editing or parked) that already hold received
    #   money (complete them or move the money first);
    # - cash liability payouts and cash refunds whose payout from this drawer
    #   is uncertain: marked unknown by this shift's owner during the shift
    #   (the would-be confirmer, since cash leaves the confirmer's drawer).
    #   Requested or reserved ones have moved no cash and wait for whoever
    #   confirms them later;
    # - cash out / safe drop requests on the shift still waiting for a
    #   second person.
    # Drafts without money are warnings: they continue on the cashier's next
    # open shift when resumed.
    class ShiftChecklist
      PENDING_ATTEMPTS = %w[prepared unknown].freeze
      OPEN_DRAFTS = %w[editing parked].freeze

      def initialize(shift)
        @shift = shift
      end

      def blocking
        @blocking ||= attempts + funded_drafts + payouts + refunds + movement_requests
      end

      def warnings
        @warnings ||= drafts_without_money
      end

      def blocked?
        blocking.any?
      end

      def to_pos
        { blocking: blocking, warnings: warnings }
      end

      private

      attr_reader :shift

      def attempts
        TenderAttempt.where(shift_id: shift.id, status: PENDING_ATTEMPTS).includes(:pos_payment_method, workspace: :order).
          order(:id).map do |attempt|
          { type: 'tender_attempt', id: attempt.prefixed_id, workspace_id: attempt.workspace.prefixed_id,
            order_number: attempt.workspace.order.number, status: attempt.status, amount: attempt.amount.to_s('F'),
            kind: attempt.pos_payment_method.kind }
        end
      end

      def open_drafts
        @open_drafts ||= Workspace.where(shift_id: shift.id, operational_status: OPEN_DRAFTS).includes(:order, :resource).order(:id).to_a
      end

      def funded_ids
        @funded_ids ||= ReceivedFunds.where(workspace_id: open_drafts.map(&:id)).distinct.pluck(:workspace_id).to_set
      end

      def funded_drafts
        received = ReceivedFunds.where(workspace_id: funded_ids.to_a).group(:workspace_id).sum(:received_net)
        open_drafts.select { |draft| funded_ids.include?(draft.id) }.map do |draft|
          { type: 'workspace_money', workspace_id: draft.prefixed_id, order_number: draft.order.number,
            status: draft.operational_status, amount: received.fetch(draft.id, 0).to_s('F'), **table_of(draft) }
        end
      end

      def drafts_without_money
        open_drafts.reject { |draft| funded_ids.include?(draft.id) }.map do |draft|
          { type: 'draft', workspace_id: draft.prefixed_id, order_number: draft.order.number, status: draft.operational_status,
            **table_of(draft) }
        end
      end

      # The table an open order is served at, so the close dialog names it.
      def table_of(draft)
        return {} unless draft.resource

        { table: { id: draft.resource.prefixed_id, name: draft.resource.name, label: draft.table_label } }
      end

      def unknown_by_owner(column)
        PayoutEvidence.where(actor_id: shift.owner_id, created_at: shift.opened_at..).where.not(column => nil).select(column)
      end

      def payouts
        cash_funds = ReceivedFunds.where(branch_id: shift.branch_id, kind: 'cash').select(:id)
        LiabilityPayout.where(branch_id: shift.branch_id, status: 'unknown', received_funds_id: cash_funds,
                              id: unknown_by_owner(:liability_payout_id)).includes(:received_funds).order(:id).map do |payout|
          { type: 'liability_payout', id: payout.prefixed_id, funds_id: payout.received_funds.prefixed_id,
            status: payout.status, amount: payout.amount.to_s('F') }
        end
      end

      def refunds
        RefundRequest.where(branch_id: shift.branch_id, method: 'cash', status: 'unknown', id: unknown_by_owner(:refund_request_id)).
          includes(:order, :return_operation).order(:id).map do |refund|
          { type: 'refund_request', id: refund.prefixed_id, return_id: refund.return_operation.prefixed_id,
            order_number: refund.order.number, status: refund.status, amount: refund.amount.to_s('F') }
        end
      end

      def movement_requests
        CashMovementRequest.pending.where(shift_id: shift.id).order(:id).map do |request|
          { type: 'cash_movement_request', id: request.prefixed_id, kind: request.kind, status: request.status,
            amount: request.amount.to_s('F') }
        end
      end
    end
  end
end

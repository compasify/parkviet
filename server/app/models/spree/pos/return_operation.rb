# frozen_string_literal: true

module Spree
  module Pos
    # One customer return against one placed POS order, received at `branch`.
    # The goods leg runs through core `Spree::Return` (quantities, receipt,
    # restock); the money leg is the cumulative entitlement of its
    # reservations, split into a credit note on open debt and a refund
    # entitlement that refund requests pay out.
    class ReturnOperation < Record
      self.table_name = 'spree_pos_return_operations'
      has_prefix_id :posreturn

      ACTION = 'return.process'
      STATUSES = %w[pending_approval ready received canceled].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :sale_branch, class_name: 'Spree::Pos::Branch'
      belongs_to :workspace, class_name: 'Spree::Pos::Workspace'
      belongs_to :order, class_name: 'Spree::Order'
      belongs_to :core_return, class_name: 'Spree::Return'
      belongs_to :requester, class_name: staff_class_name
      belongs_to :receiver, class_name: staff_class_name, optional: true
      belongs_to :approval, class_name: 'Spree::Pos::Approval', optional: true
      has_many :reservations, class_name: 'Spree::Pos::ReturnReservation', foreign_key: :return_operation_id,
                              dependent: :restrict_with_error
      has_many :refund_requests, class_name: 'Spree::Pos::RefundRequest', foreign_key: :return_operation_id,
                                 dependent: :restrict_with_error
      has_one :exchange_operation, class_name: 'Spree::Pos::ExchangeOperation', foreign_key: :return_operation_id,
                                   dependent: :restrict_with_error

      validates :status, inclusion: { in: STATUSES }
      validates :reason, presence: true
      validates :currency, presence: true

      scope :for_store, ->(store) { where(store_id: store.id) }

      # A return nobody received within this time is canceled by the recovery
      # job, so abandoned reservations do not hold returnable units forever.
      TTL = 24.hours

      # Refund entitlement not yet spoken for by a live or confirmed refund.
      def refundable_remaining
        refund_entitlement - refund_sum(RefundRequest::HOLDING)
      end

      def refunded
        refund_sum(%w[confirmed])
      end

      # Credit note and refund this return gives: the posted figures once
      # posted, the same split the posting would make while it is not.
      def expected_split
        return { credit_note: BigDecimal('0'), refund: BigDecimal('0') } if status == 'canceled'
        return { credit_note: credit_note_amount, refund: refund_entitlement } if entitlement_status == 'posted'

        Returns::Guard.split(order, entitlement_total, except: self)
      end

      # List row: no lines or refund details, only preloaded associations.
      def to_row
        {
          id: prefixed_id, branch_id: branch.prefixed_id, sale_branch_id: sale_branch.prefixed_id,
          order_id: order.prefixed_id, order_number: order.number, return_number: core_return.number,
          requester_id: requester.prefixed_id, requester_name: requester.try(:full_name).presence,
          status: status, entitlement_status: entitlement_status, reason: reason,
          cross_branch: cross_branch, out_of_window: out_of_window, damaged: damaged,
          requires_approval: requires_approval, revision: revision, approval: approval&.to_ref,
          currency: currency, entitlement_total: money(entitlement_total),
          credit_note_amount: money(credit_note_amount), refund_entitlement: money(refund_entitlement),
          refund_requested: money(refund_sum(RefundRequest::RESERVING)), refunded: money(refunded),
          created_at: created_at&.iso8601, received_at: received_at&.iso8601
        }
      end

      def to_pos(mask: true)
        rows = reservations.includes(:sale_line, line_item: { variant: :product }).order(:id).to_a
        split = expected_split
        to_row.merge(
          workspace_id: workspace.prefixed_id,
          expected_credit_note: money(split[:credit_note]), expected_refund: money(split[:refund]),
          refundable_remaining: money(refundable_remaining),
          lines: rows.map(&:to_pos),
          refund_requests: refund_requests.includes(:order, :received_funds, :funds_allocation, :branch, :requester,
                                                    :confirmer, :shift, :refund, :approval, :payout_evidences).
                           order(:id).map { |request| request.to_pos(mask: mask) },
          exchange_id: exchange_operation&.prefixed_id,
          expires_at: %w[pending_approval ready].include?(status) ? (created_at + TTL).iso8601 : nil,
          posted_at: posted_at&.iso8601, canceled_at: canceled_at&.iso8601
        )
      end

      private

      def money(value)
        BigDecimal(value.to_s).to_s('F')
      end

      def refund_sum(statuses)
        return refund_requests.select { |row| statuses.include?(row.status) }.sum(BigDecimal('0'), &:amount) if refund_requests.loaded?

        refund_requests.where(status: statuses).sum(:amount)
      end
    end
  end
end

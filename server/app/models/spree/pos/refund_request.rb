# frozen_string_literal: true

module Spree
  module Pos
    # Goods refund paid from one original receipt through one allocation
    # child. While reserved or unknown it holds that part of the parent
    # ReceivedFunds; only a confirmed payout, with evidence, becomes a core
    # Refund on the child's Payment.
    class RefundRequest < Record
      self.table_name = 'spree_pos_refund_requests'
      has_prefix_id :posrefund

      ACTION = 'refund.payout'
      RESERVING = %w[reserved unknown].freeze
      HOLDING = %w[reserved unknown confirmed].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :return_operation, class_name: 'Spree::Pos::ReturnOperation'
      belongs_to :funds_allocation, class_name: 'Spree::Pos::FundsAllocation'
      belongs_to :received_funds, class_name: 'Spree::Pos::ReceivedFunds'
      belongs_to :payment, class_name: 'Spree::Payment'
      belongs_to :order, class_name: 'Spree::Order'
      belongs_to :requester, class_name: staff_class_name
      belongs_to :confirmer, class_name: staff_class_name, optional: true
      belongs_to :approval, class_name: 'Spree::Pos::Approval', optional: true
      belongs_to :shift, class_name: 'Spree::Pos::Shift', optional: true
      belongs_to :refund, class_name: 'Spree::Refund', optional: true
      has_many :payout_evidences, class_name: 'Spree::Pos::PayoutEvidence', foreign_key: :refund_request_id,
                                  dependent: :restrict_with_error

      validates :method, inclusion: { in: %w[cash bank_manual] }
      validates :status, inclusion: { in: %w[reserved unknown confirmed failed canceled] }
      validates :currency, presence: true

      scope :for_store, ->(store) { where(store_id: store.id) }
      scope :reserving, -> { where(status: RESERVING) }

      # References (beneficiary account, transfer reference) are masked unless
      # the caller knows the reader resolves or approves money at the branch.
      def to_pos(mask: true)
        evidence = payout_evidences.loaded? ? payout_evidences.max_by(&:id) : payout_evidences.order(:id).last
        hide = ->(value) { mask ? Masking.reference(value) : value }
        {
          id: prefixed_id, return_id: return_operation.prefixed_id, branch_id: branch.prefixed_id,
          order_id: order.prefixed_id, order_number: order.number, allocation_id: funds_allocation.prefixed_id,
          funds_id: received_funds.prefixed_id, funds_kind: received_funds.kind, method: method, status: status,
          amount: amount.to_s('F'), currency: currency, revision: revision, requester_id: requester.prefixed_id,
          confirmer_id: confirmer&.prefixed_id, shift_id: shift&.prefixed_id, refund_id: refund&.prefixed_id,
          beneficiary_reference: hide.call(beneficiary_reference),
          approval: approval&.to_ref,
          evidence: evidence&.to_pos&.merge(reference: hide.call(evidence.reference)),
          created_at: created_at&.iso8601, confirmed_at: confirmed_at&.iso8601, resolved_at: resolved_at&.iso8601
        }
      end
    end
  end
end

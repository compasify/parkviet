# frozen_string_literal: true

module Spree
  module Pos
    # A tender the POS offers (cash, manual bank transfer or VietQR), settled
    # on a core payment method of the store. A row a tender attempt recorded
    # is disabled, never deleted.
    class PosPaymentMethod < Record
      self.table_name = 'spree_pos_payment_methods'
      has_prefix_id :pospaymethod

      # Tenders the counter offers and the store configures.
      COUNTER_KINDS = %w[cash bank_manual vietqr].freeze
      # What a delivery platform owes for an order its customer paid on the
      # platform: only a platform order is settled with it, and the store
      # gets one built-in row (PaymentMethodResolver#platform_method!).
      PLATFORM_KIND = 'platform_receivable'
      KINDS = (COUNTER_KINDS + [PLATFORM_KIND]).freeze
      CODE_FORMAT = /\A[a-z0-9][a-z0-9_]{0,31}\z/

      belongs_to :store, class_name: 'Spree::Store'
      has_many :branch_payment_methods, class_name: 'Spree::Pos::BranchPaymentMethod', dependent: :delete_all
      has_many :tender_attempts, class_name: 'Spree::Pos::TenderAttempt', dependent: :restrict_with_error

      validates :code, :name, presence: true
      validates :code, format: { with: CODE_FORMAT }, uniqueness: { scope: :store_id }
      validates :name, length: { maximum: 120 }
      validates :kind, inclusion: { in: KINDS }
      validates :status, inclusion: { in: %w[active disabled] }
      validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 10_000 }

      scope :for_store, ->(store) { where(store_id: store.id) }
      scope :active_now, -> { where(status: 'active').order(:position, :id) }
      scope :counter, -> { where(kind: COUNTER_KINDS) }

      def active?
        status == 'active'
      end

      def platform?
        kind == PLATFORM_KIND
      end

      def to_pos
        {
          id: prefixed_id, code: code, name: name, kind: kind,
          payment_method_id: payment_method_id ? Spree::PaymentMethod.find_by(id: payment_method_id)&.prefixed_id : nil,
          status: status, position: position
        }
      end
    end
  end
end

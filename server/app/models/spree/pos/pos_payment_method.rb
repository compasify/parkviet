# frozen_string_literal: true

module Spree
  module Pos
    class PosPaymentMethod < Record
      self.table_name = 'spree_pos_payment_methods'
      has_prefix_id :pospaymethod

      belongs_to :store, class_name: 'Spree::Store'

      validates :code, :name, presence: true
      validates :kind, inclusion: { in: %w[cash bank_manual vietqr] }
      validates :status, inclusion: { in: %w[active disabled] }

      scope :for_store, ->(store) { where(store_id: store.id) }
      scope :active_now, -> { where(status: 'active').order(:position, :id) }

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

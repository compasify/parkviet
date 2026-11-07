# frozen_string_literal: true

module Spree
  module Pos
    # One print of a receipt snapshot. Number 0 is the original; every later
    # print is a numbered copy. A print never moves money or stock.
    class ReceiptPrint < Record
      self.table_name = 'spree_pos_receipt_prints'
      has_prefix_id :posprint

      COPY_LABEL = 'BẢN SAO'

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :receipt_snapshot, class_name: 'Spree::Pos::ReceiptSnapshot'
      belongs_to :actor, class_name: staff_class_name

      validates :copy_number, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

      def readonly?
        persisted? || super
      end

      def copy?
        copy_number.positive?
      end

      def to_pos
        { id: prefixed_id, receipt_id: receipt_snapshot.prefixed_id, copy: copy?, copy_number: copy_number,
          label: copy? ? COPY_LABEL : nil, printed_at: created_at.iso8601 }
      end
    end
  end
end

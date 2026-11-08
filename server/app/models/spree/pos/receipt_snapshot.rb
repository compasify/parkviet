# frozen_string_literal: true

module Spree
  module Pos
    # The printable document of one posted source (a sale, a return, a refund
    # payout or a shift closure), written once from the facts posted with it.
    # Later configuration, price or customer changes never alter it; a reprint
    # serves the same payload labelled as a copy. Customer contact details
    # are kept here as posted and masked when read.
    class ReceiptSnapshot < Record
      self.table_name = 'spree_pos_receipt_snapshots'
      has_prefix_id :posreceipt

      SOURCE_TYPES = %w[sale return return_supplement refund shift_closure].freeze
      # Printed on every POS document: it is not a legal e-invoice.
      DISCLAIMER = 'Phiếu bán hàng POS — không phải hóa đơn điện tử'

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :register, class_name: 'Spree::Pos::Register', optional: true
      belongs_to :issued_by, class_name: staff_class_name, optional: true
      has_many :prints, class_name: 'Spree::Pos::ReceiptPrint', dependent: :restrict_with_error

      validates :source_type, inclusion: { in: SOURCE_TYPES }
      validates :number, presence: true, length: { maximum: 64 }
      validates :issued_at, presence: true

      scope :for_store, ->(store) { where(store_id: store.id) }

      SOURCE_MODELS = {
        'sale' => 'Spree::Pos::Workspace', 'return' => 'Spree::Pos::ReturnOperation',
        'return_supplement' => 'Spree::Pos::ReturnOperation', 'refund' => 'Spree::Pos::RefundRequest',
        'shift_closure' => 'Spree::Pos::ShiftClosure'
      }.freeze

      def source_record
        SOURCE_MODELS.fetch(source_type).constantize.find(source_id)
      end

      def readonly?
        persisted? || super
      end

      # First letter of each word, e.g. "Nguyễn Văn An" -> "N••• V•• A•".
      def self.masked_name(name)
        return name if name.blank?

        name.to_s.split(/\s+/).map { |word| word[0] + ('•' * [word.length - 1, 1].max) }.join(' ')
      end

      # `mask` hides the customer's name; the phone is always masked on a
      # printed document, the customer copy included.
      # `copies` (number of copies, nil when never printed) and `original`
      # (the copy-0 print, nil when none) may be preloaded for a list;
      # otherwise they are read here. `original_print` is the template,
      # version and paper of the original, null when it was never printed
      # or was printed before templates existed.
      def to_pos(mask: true, copies: :load, original: :load)
        copies = prints.maximum(:copy_number) if copies == :load
        original = copies.nil? ? nil : prints.includes(:receipt_template).find_by(copy_number: 0) if original == :load
        data = payload.deep_dup
        if (customer = data['customer'])
          customer['name'] = self.class.masked_name(customer['name']) if mask
          customer['phone'] = ReceivableProjection.masked(customer['phone'])
        end
        {
          id: prefixed_id, source_type: source_type, number: number, branch_id: branch.prefixed_id,
          register_id: register&.prefixed_id, issued_at: issued_at.iso8601, issued_late: issued_late,
          disclaimer: DISCLAIMER, printed: !copies.nil?, copy_count: copies.to_i,
          original_print: original&.receipt_template_id ? original.layout : nil,
          document: data
        }
      end
    end
  end
end

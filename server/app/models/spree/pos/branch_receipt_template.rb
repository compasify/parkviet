# frozen_string_literal: true

module Spree
  module Pos
    # The template a branch prints one document type with, instead of the
    # store default. While the template is disabled the default applies
    # (see ReceiptTemplate.effective_for).
    class BranchReceiptTemplate < Record
      self.table_name = 'spree_pos_branch_receipt_templates'

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :receipt_template, class_name: 'Spree::Pos::ReceiptTemplate'

      validates :document_type, inclusion: { in: ReceiptTemplate::DOCUMENT_TYPES }
      validates :document_type, uniqueness: { scope: :branch_id }
      validate :template_fits

      private

      def template_fits
        errors.add(:branch, :invalid) if branch && branch.store_id != store_id
        return if receipt_template.nil?

        errors.add(:receipt_template, :invalid) if receipt_template.store_id != store_id
        errors.add(:receipt_template, :invalid) if receipt_template.document_type != document_type
      end
    end
  end
end

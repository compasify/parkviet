# frozen_string_literal: true

module Spree
  module Pos
    # One saved config of a receipt template. Never changed after it is
    # written: a reprint renders exactly the version the original used.
    class ReceiptTemplateVersion < Record
      self.table_name = 'spree_pos_receipt_template_versions'

      belongs_to :receipt_template, class_name: 'Spree::Pos::ReceiptTemplate', inverse_of: :versions
      belongs_to :created_by, class_name: staff_class_name, optional: true

      validates :version, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
      validate :config_is_an_object

      def readonly?
        persisted? || super
      end

      def to_pos
        {
          version: version, config: config, created_at: created_at.iso8601,
          created_by: created_by && { id: created_by.prefixed_id, name: StaffName.call(created_by) }
        }
      end

      private

      def config_is_an_object
        errors.add(:config, :invalid) unless config.is_a?(Hash)
      end
    end
  end
end

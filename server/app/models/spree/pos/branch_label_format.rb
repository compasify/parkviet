# frozen_string_literal: true

module Spree
  module Pos
    # A store label format a branch reads scale labels with.
    class BranchLabelFormat < Record
      self.table_name = 'spree_pos_branch_label_formats'

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :label_format, class_name: 'Spree::Pos::LabelFormat', inverse_of: :branch_label_formats

      validates :label_format_id, uniqueness: { scope: :branch_id }
      validate :same_store

      private

      def same_store
        errors.add(:branch, :invalid) if branch && branch.store_id != store_id
        errors.add(:label_format, :invalid) if label_format && label_format.store_id != store_id
      end
    end
  end
end

# frozen_string_literal: true

module Spree
  module Pos
    # A floor or room of a branch, drawn as a grid of `floor_width` by
    # `floor_height` cells; its tables sit on that grid.
    class Area < Record
      self.table_name = 'spree_pos_areas'
      has_prefix_id :posarea

      STATUSES = %w[active archived].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      has_many :resources, class_name: 'Spree::Pos::Resource', dependent: :restrict_with_error

      validates :name, presence: true, length: { maximum: 80 }
      validates :status, inclusion: { in: STATUSES }
      validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :floor_width, :floor_height, numericality: { only_integer: true, in: 4..200 }
      validate :name_unique_while_active
      validate :branch_in_store

      scope :active, -> { where(status: 'active') }

      def to_pos
        { id: prefixed_id, branch_id: branch.prefixed_id, name: name, position: position, status: status,
          floor_width: floor_width, floor_height: floor_height }
      end

      private

      def name_unique_while_active
        return unless status == 'active' && branch_id

        clash = self.class.active.where(branch_id: branch_id).where('LOWER(name) = ?', name.to_s.downcase).where.not(id: id).exists?
        errors.add(:name, :taken) if clash
      end

      def branch_in_store
        errors.add(:branch, :invalid) if branch && branch.store_id != store_id
      end
    end
  end
end

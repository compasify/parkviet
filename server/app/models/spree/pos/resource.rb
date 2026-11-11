# frozen_string_literal: true

module Spree
  module Pos
    # A table, room, billiard table or VIP room. Whether it is busy is read
    # from the open orders pointing at it (ResourceState); only cleaning and
    # out of service are set by hand.
    class Resource < Record
      self.table_name = 'spree_pos_resources'
      has_prefix_id :posres

      KINDS = %w[table room billiard vip].freeze
      SHAPES = %w[rect round].freeze
      STATUSES = %w[active archived].freeze
      MANUAL_STATUSES = %w[available cleaning out_of_service].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :area, class_name: 'Spree::Pos::Area'

      validates :name, presence: true, length: { maximum: 40 }
      validates :kind, inclusion: { in: KINDS }
      validates :shape, inclusion: { in: SHAPES }
      validates :status, inclusion: { in: STATUSES }
      validates :manual_status, inclusion: { in: MANUAL_STATUSES }
      validates :capacity, numericality: { only_integer: true, in: 0..999 }
      validates :x, :y, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :w, :h, numericality: { only_integer: true, in: 1..50 }
      validates :rotation, numericality: { only_integer: true, in: 0..359 }
      validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :resource_type_code, length: { maximum: 40 }, allow_nil: true
      validates :minimum_spend, numericality: { greater_than: 0 }, allow_nil: true
      validate :name_unique_while_active
      validate :area_of_branch

      scope :active, -> { where(status: 'active') }

      def active?
        status == 'active'
      end

      def to_pos
        { id: prefixed_id, branch_id: branch.prefixed_id, area_id: area.prefixed_id, kind: kind, name: name,
          capacity: capacity, shape: shape, x: x, y: y, w: w, h: h, rotation: rotation, manual_status: manual_status,
          resource_type_code: resource_type_code, status: status, position: position,
          minimum_spend: minimum_spend&.to_s('F') }
      end

      # What an order shows of its table; no extra query when the table is loaded.
      def to_ref
        { id: prefixed_id, name: name, kind: kind, area_id: area&.prefixed_id }
      end

      private

      def name_unique_while_active
        return unless status == 'active' && branch_id

        clash = self.class.active.where(branch_id: branch_id).where('LOWER(name) = ?', name.to_s.downcase).where.not(id: id).exists?
        errors.add(:name, :taken) if clash
      end

      def area_of_branch
        errors.add(:area, :invalid) if area && (area.branch_id != branch_id || area.store_id != store_id)
      end
    end
  end
end

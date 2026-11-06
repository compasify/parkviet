# frozen_string_literal: true

module Spree
  module Pos
    class Shift < Record
      self.table_name = 'spree_pos_shifts'
      has_prefix_id :posshift

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :register, class_name: 'Spree::Pos::Register', optional: true
      belongs_to :owner, class_name: staff_class_name

      validates :opening_float, numericality: { greater_than_or_equal_to: 0 }
      validates :currency, :status, presence: true
      validates :status, inclusion: { in: %w[open closed] }
      validate :same_store_drawer
      validate :one_open_shift, on: :create

      scope :for_store, ->(store) { where(store_id: store.id) }
      scope :open_now, -> { where(status: 'open') }

      def to_pos
        {
          id: prefixed_id,
          branch_id: branch.prefixed_id,
          register_id: register&.prefixed_id,
          status: status,
          opening_float: opening_float.to_s('F'),
          currency: currency,
          owner_id: owner.prefixed_id,
          opened_at: opened_at&.iso8601,
          reports: false
        }
      end

      private

      def same_store_drawer
        errors.add(:register, :invalid) if register && (register.store_id != store_id || register.branch_id != branch_id)
        errors.add(:branch, :invalid) if branch && branch.store_id != store_id
      end

      def one_open_shift
        return unless status == 'open'

        scope = self.class.for_store(store).open_now.where(register_id: register_id)
        scope = scope.where(branch_id: branch_id, owner_id: owner_id) if register_id.nil?
        errors.add(register_id ? :register : :branch, :taken) if scope.exists?
      end
    end
  end
end

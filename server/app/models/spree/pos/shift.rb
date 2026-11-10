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
      # Shift close: the pending blind count, the immutable closing snapshot
      # and the drawer's cash movements. A closed shift never changes again.
      belongs_to :closing_counted_by, class_name: staff_class_name, optional: true
      has_one :closure, class_name: 'Spree::Pos::ShiftClosure', dependent: :restrict_with_error
      has_many :cash_movements, class_name: 'Spree::Pos::CashMovement', dependent: :restrict_with_error
      before_update :closed_is_final
      validates :closing_reason, length: { maximum: 200 }

      validates :opening_float, numericality: { greater_than_or_equal_to: 0 }
      validates :currency, :status, :business_date, presence: true
      before_validation :assign_business_date, on: :create
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
          closed_at: closed_at&.iso8601,
          business_date: business_date&.iso8601,
          revision: revision,
          counted: !closing_counted.nil?,
          reports: false
        }
      end

      def open?
        status == 'open'
      end

      private

      def assign_business_date
        return if business_date.present? || branch.nil?

        self.business_date = BusinessDay.for(branch, Workspace.business_now)
      end

      def closed_is_final
        raise ActiveRecord::ReadOnlyRecord, 'A closed shift cannot change.' if status_in_database == 'closed'
      end

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

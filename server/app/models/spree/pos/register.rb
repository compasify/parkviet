# frozen_string_literal: true

module Spree
  module Pos
    class Register < Record
      self.table_name = 'spree_pos_registers'
      has_prefix_id :posregister

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      has_many :shifts, class_name: 'Spree::Pos::Shift', dependent: :restrict_with_error

      validates :name, :code, :status, presence: true
      validates :code, uniqueness: { scope: :store_id }, format: { with: /\A[a-z0-9][a-z0-9_-]{0,31}\z/ }
      validates :status, inclusion: { in: %w[active disabled] }
      validate :branch_belongs_to_store
      validate :branch_fixed_after_use, on: :update

      scope :for_store, ->(store) { where(store_id: store.id) }

      def disabled?
        status == 'disabled'
      end

      def to_pos
        {
          id: prefixed_id,
          branch_id: branch.prefixed_id,
          name: name,
          code: code,
          status: status
        }
      end

      private

      def branch_belongs_to_store
        errors.add(:branch, :invalid) if branch && branch.store_id != store_id
      end

      # Shifts and drafts record the drawer's branch; moving a used drawer would
      # leave that history pointing at a branch the drawer no longer belongs to.
      def branch_fixed_after_use
        return unless will_save_change_to_branch_id?
        return unless shifts.exists? || Workspace.where(register_id: id).exists?

        errors.add(:branch, :invalid)
      end
    end
  end
end

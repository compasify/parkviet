# frozen_string_literal: true

module Spree
  module Pos
    # One module switch of a branch (see ModulePolicy). A branch without a
    # row for a module has it off. Turning a module off only refuses new
    # setup commands of that module; selling what is already configured
    # never depends on it.
    class BranchModule < Record
      self.table_name = 'spree_pos_branch_modules'
      has_prefix_id :posbranchmod

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :changed_by, class_name: staff_class_name, optional: true

      validates :module_key, presence: true, uniqueness: { scope: :branch_id }
      validates :enabled, inclusion: { in: [true, false] }
      validates :reason, length: { maximum: 200 }
      validate :module_available
      validate :same_store

      scope :for_store, ->(store) { where(store_id: store.id) }

      def to_pos
        { module: module_key, enabled: enabled, branch_id: branch&.prefixed_id, reason: reason,
          changed_by_id: changed_by&.prefixed_id, changed_by_name: StaffName.call(changed_by), changed_at: updated_at&.iso8601 }
      end

      private

      def module_available
        errors.add(:module_key, :invalid) unless Modules.available?(module_key)
      end

      def same_store
        errors.add(:branch, :invalid) if branch && store && branch.store_id != store_id
      end
    end
  end
end

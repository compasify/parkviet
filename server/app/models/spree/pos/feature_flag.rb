# frozen_string_literal: true

module Spree
  module Pos
    # One switch of a risky POS capability: the store default (no branch) or
    # a branch override. Written only through FeaturePolicy.set!, which audits
    # every change.
    class FeatureFlag < Record
      self.table_name = 'spree_pos_feature_flags'
      has_prefix_id :posflag

      FEATURES = %w[credit returns refunds exchanges traceability customer_display cash_moves exports vietqr].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch', optional: true
      belongs_to :changed_by, class_name: staff_class_name

      validates :feature, inclusion: { in: FEATURES }
      validates :enabled, inclusion: { in: [true, false] }
      validates :reason, presence: true, length: { maximum: 200 }
      validate :same_store

      scope :for_store, ->(store) { where(store_id: store.id) }

      def to_pos
        { feature: feature, enabled: enabled, branch_id: branch&.prefixed_id, reason: reason,
          changed_by_id: changed_by&.prefixed_id, changed_by_name: StaffName.call(changed_by), changed_at: updated_at.iso8601 }
      end

      private

      def same_store
        errors.add(:branch, :invalid) if branch && store && branch.store_id != store_id
      end
    end
  end
end

# frozen_string_literal: true

module Spree
  module Pos
    # The store's main industry profile: the default for new branches. A
    # store without one (and without an active branch) still needs the POS
    # setup. `interests` lists "coming soon" profiles the owner asked for;
    # `wholesale` is recorded only, until the wholesale module exists.
    class StoreProfile < Record
      self.table_name = 'spree_pos_store_profiles'
      has_prefix_id :posstoreprof

      # E-invoice issued for completed POS orders: none (the default, for a
      # seller under the threshold), from the cash register, or one
      # tax-authority code per invoice. Set through Einvoices::SaveSettings.
      EINVOICE_TYPES = %w[none cash_register coded].freeze

      def self.einvoice_type_for(store)
        find_by(store_id: store.id)&.einvoice_type || 'none'
      end

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :changed_by, class_name: staff_class_name, optional: true

      validates :store_id, uniqueness: true
      validates :profile_key, format: { with: Branch::PROFILE_KEY_FORMAT }
      validates :profile_version, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
      validates :wholesale, inclusion: { in: [true, false] }
      validates :einvoice_type, inclusion: { in: EINVOICE_TYPES }
      validate :interests_are_keys

      scope :for_store, ->(store) { where(store_id: store.id) }

      def to_pos
        { id: prefixed_id, profile_key: profile_key, profile_version: profile_version, wholesale: wholesale,
          interests: Array(interests), onboarded_at: onboarded_at&.iso8601, changed_by_id: changed_by&.prefixed_id,
          changed_by_name: StaffName.call(changed_by), updated_at: updated_at&.iso8601 }
      end

      private

      def interests_are_keys
        values = Array(interests)
        errors.add(:interests, :invalid) unless values.all? { |key| key.is_a?(String) && key.match?(Branch::PROFILE_KEY_FORMAT) }
        errors.add(:interests, :invalid) if values.uniq.size != values.size
      end
    end
  end
end

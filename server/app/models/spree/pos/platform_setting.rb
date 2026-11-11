# frozen_string_literal: true

module Spree
  module Pos
    # One delivery platform at one branch: whether the counter takes its
    # orders, and the share of each order the platform keeps (a percent).
    class PlatformSetting < Record
      self.table_name = 'spree_pos_platform_settings'
      has_prefix_id :posplatform

      PLATFORMS = %w[grabfood shopeefood].freeze
      STATUSES = %w[active disabled].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'

      validates :platform, inclusion: { in: PLATFORMS }, uniqueness: { scope: :branch_id }
      validates :status, inclusion: { in: STATUSES }
      validates :commission_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
      validate :branch_in_store

      scope :for_store, ->(store) { where(store_id: store.id) }

      def active?
        status == 'active'
      end

      # Every platform of a branch, configured or not (off, 0%).
      def self.for_branch(branch)
        rows = where(branch_id: branch.id).index_by(&:platform)
        PLATFORMS.map { |platform| rows[platform] || new(store_id: branch.store_id, branch: branch, platform: platform, status: 'disabled') }
      end

      def to_pos
        { platform: platform, status: status, commission_rate: commission_rate.to_s('F'), updated_at: updated_at&.iso8601 }
      end

      private

      def branch_in_store
        errors.add(:branch, :invalid) if branch && branch.store_id != store_id
      end
    end
  end
end

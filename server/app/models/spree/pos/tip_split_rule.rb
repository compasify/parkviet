# frozen_string_literal: true

module Spree
  module Pos
    # How a branch splits its tips: equally, by hours worked, or by amounts
    # the manager types. `role_codes` limits who may share (any role when empty).
    class TipSplitRule < Record
      self.table_name = 'spree_pos_tip_split_rules'
      has_prefix_id :postiprule

      MODES = %w[equal by_hours manual].freeze

      belongs_to :branch, class_name: 'Spree::Pos::Branch'

      validates :mode, inclusion: { in: MODES }
      validate :role_codes_valid

      def self.for(branch)
        find_by(branch_id: branch.id) || new(branch: branch, mode: 'equal', role_codes: [])
      end

      def to_pos
        { branch_id: branch.prefixed_id, mode: mode, role_codes: Array(role_codes) }
      end

      private

      def role_codes_valid
        values = role_codes
        return if values.is_a?(Array) && values.size <= 20 && values.all? { |value| value.is_a?(String) && value.length.between?(1, 64) }

        errors.add(:role_codes, :invalid)
      end
    end
  end
end

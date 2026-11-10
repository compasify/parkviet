# frozen_string_literal: true

module Spree
  module Pos
    # A short single-use code that pairs a terminal. Only its SHA-256 digest
    # is stored. The first successful exchange spends it. The alphabet and
    # the ten-minute life match a customer-display pairing code.
    class DevicePairing < Record
      self.table_name = 'spree_pos_device_pairings'
      has_prefix_id :posdevpair

      TTL = DisplayPairing::TTL

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :device, class_name: 'Spree::Pos::Device', optional: true
      belongs_to :created_by, class_name: staff_class_name

      validates :mode, inclusion: { in: Device::MODES }

      def self.new_code
        DisplayPairing.new_code
      end

      def self.normalize(code)
        DisplayPairing.normalize(code)
      end

      def self.digest(code)
        DisplayPairing.digest(code)
      end

      def usable?(now = Time.current)
        consumed_at.nil? && expires_at > now
      end
    end
  end
end

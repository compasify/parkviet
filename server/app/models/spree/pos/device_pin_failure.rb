# frozen_string_literal: true

module Spree
  module Pos
    # One wrong PIN on one device for one membership. Five of these inside
    # the lock window refuse further attempts until the window passes.
    class DevicePinFailure < Record
      self.table_name = 'spree_pos_device_pin_failures'

      LOCK_WINDOW = 15.minutes
      LOCK_AFTER = 5

      belongs_to :device, class_name: 'Spree::Pos::Device'
      belongs_to :staff_membership, class_name: 'Spree::Pos::StaffMembership'

      def self.recent(device, membership, now = Time.current)
        where(device: device, staff_membership: membership, failed_at: (now - LOCK_WINDOW)..now)
      end

      def self.locked?(device, membership, now = Time.current)
        recent(device, membership, now).count >= LOCK_AFTER
      end
    end
  end
end

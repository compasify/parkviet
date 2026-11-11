# frozen_string_literal: true

module Spree
  module Pos
    # One wrong PIN on one device for one membership. Five inside the window
    # lock that membership on that device for a full window from the fifth.
    # Wrong PINs across all memberships are capped per device as well.
    class DevicePinFailure < Record
      self.table_name = 'spree_pos_device_pin_failures'

      LOCK_WINDOW = 15.minutes
      LOCK_AFTER = 5
      DEVICE_LIMIT = 20

      belongs_to :device, class_name: 'Spree::Pos::Device'
      belongs_to :staff_membership, class_name: 'Spree::Pos::StaffMembership'

      def self.recent(device, membership, now = Time.current)
        where(device: device, staff_membership: membership, failed_at: (now - LOCK_WINDOW)..now)
      end

      # No attempt is recorded while locked, so the latest failure is the one
      # that started the lock.
      def self.locked?(device, membership, now = Time.current)
        last = recent(device, membership, now).maximum(:failed_at)
        return false if last.nil?

        where(device: device, staff_membership: membership, failed_at: (last - LOCK_WINDOW)..last).count >= LOCK_AFTER
      end

      def self.device_limited?(device, now = Time.current)
        where(device: device, failed_at: (now - LOCK_WINDOW)..now).count >= DEVICE_LIMIT
      end
    end
  end
end

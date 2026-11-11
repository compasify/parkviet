# frozen_string_literal: true

module Spree
  module Pos
    # One person signed in on a paired device. The token is a digest. It
    # ends on sign-out, when the device is revoked, after 12 hours, or after
    # the branch's idle limit with no request.
    class DeviceStaffSession < Record
      self.table_name = 'spree_pos_device_staff_sessions'
      has_prefix_id :posdevsess

      ABSOLUTE_TTL = 12.hours
      TOUCH_INTERVAL = 60.seconds

      belongs_to :device, class_name: 'Spree::Pos::Device'
      belongs_to :staff, class_name: staff_class_name

      validates :token_digest, presence: true

      scope :open, -> { where(ended_at: nil) }

      def self.digest(token)
        Digest::SHA256.hexdigest(token.to_s)
      end

      def self.new_token
        SecureRandom.urlsafe_base64(32)
      end

      # The open session for this device and token, or nil. `touch: false` is
      # for callers that are not a person acting, such as a socket reconnecting,
      # so they cannot keep an idle session alive.
      def self.authenticate(device, token, touch: true)
        return if token.blank? || token.length > 200

        session = open.find_by(device_id: device.id, token_digest: digest(token))
        return unless session&.usable?

        session.touch_active! if touch
        session
      end

      def membership
        StaffMembership.find_by(store_id: device.store_id, branch_id: device.branch_id, staff_id: staff_id)
      end

      def usable?(now = Time.current)
        return false if ended_at || expires_at <= now || device.status != 'active'

        last_active_at > now - idle_limit && membership&.status == 'active'
      end

      def idle_limit
        minutes = device.branch.staff_session_idle_minutes
        minutes = 30 unless minutes.is_a?(Integer) && minutes.positive?

        minutes.minutes
      end

      def touch_active!(now = Time.current)
        return if last_active_at > now - TOUCH_INTERVAL

        update_columns(last_active_at: now, updated_at: now)
      end

      def end!(reason)
        update!(ended_at: Time.current, end_reason: reason) if ended_at.nil?
      end
    end
  end
end

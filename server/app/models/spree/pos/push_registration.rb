# frozen_string_literal: true

module Spree
  module Pos
    # The push token of one owner device and who turned push on there. The
    # token is encrypted at rest (when Active Record encryption keys are
    # configured, as production requires) and never returned.
    class PushRegistration < Record
      self.table_name = 'spree_pos_push_registrations'
      has_prefix_id :pospushreg

      PLATFORMS = %w[fcm apns].freeze
      TOKEN_MAX = 4096
      ERROR_MAX = 200

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :device, class_name: 'Spree::Pos::Device'
      belongs_to :staff, class_name: staff_class_name

      encrypts :token if ActiveRecord::Encryption.config.has_primary_key?

      validates :platform, inclusion: { in: PLATFORMS }
      validates :token, presence: true, length: { maximum: TOKEN_MAX }

      scope :enabled, -> { where(enabled: true) }

      def to_pos
        { id: prefixed_id, device_id: device.prefixed_id, platform: platform, enabled: enabled,
          last_error: last_error, last_error_at: last_error_at&.iso8601, last_delivered_at: last_delivered_at&.iso8601 }
      end
    end
  end
end

# frozen_string_literal: true

module Spree
  module Pos
    # A paired terminal. Its bearer token is opaque and stored only as a
    # digest. Revoking the row, or pairing it again, makes the previous token
    # fail at once. Waiter and owner modes cannot act as a person until a
    # staff session is present; the other modes are the machine itself.
    class Device < Record
      self.table_name = 'spree_pos_devices'
      has_prefix_id :posdevice

      MODES = %w[waiter kds expo kiosk print_station owner bridge].freeze
      STAFF_MODES = %w[waiter owner].freeze
      MACHINE_MODES = (MODES - STAFF_MODES).freeze
      PLATFORMS = %w[android ios web].freeze
      STATUSES = %w[active revoked].freeze
      SEEN_INTERVAL = 60.seconds

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :register, class_name: 'Spree::Pos::Register', optional: true
      belongs_to :paired_by, class_name: staff_class_name, optional: true
      belongs_to :revoked_by, class_name: staff_class_name, optional: true
      has_many :pairings, class_name: 'Spree::Pos::DevicePairing', dependent: :restrict_with_error
      has_many :staff_sessions, class_name: 'Spree::Pos::DeviceStaffSession', dependent: :restrict_with_error

      validates :name, presence: true, length: { maximum: 80 }
      validates :mode, inclusion: { in: MODES }
      validates :platform, inclusion: { in: PLATFORMS }
      validates :status, inclusion: { in: STATUSES }
      validates :token_digest, presence: true

      scope :for_store, ->(store) { where(store_id: store.id) }
      scope :active, -> { where(status: 'active') }

      def self.digest(token)
        Digest::SHA256.hexdigest(token.to_s)
      end

      def self.new_token
        SecureRandom.urlsafe_base64(32)
      end

      # The device a token opens, or nil. Callers never learn why.
      def self.authenticate(token)
        return if token.blank? || token.length > 200

        active.find_by(token_digest: digest(token))
      end

      def staff_required?
        STAFF_MODES.include?(mode)
      end

      # At most one write a minute, so a busy screen does not update the row
      # on every request.
      def touch_seen!(now = Time.current)
        return if last_seen_at && last_seen_at > now - SEEN_INTERVAL

        update_columns(last_seen_at: now, updated_at: now)
      end

      # Replaces the token. The caller holds the row lock. Returns the plain
      # token, which is never stored.
      def rotate_token!(actor:)
        token = self.class.new_token
        update!(token_digest: self.class.digest(token), generation: generation + 1, status: 'active',
                revoked_at: nil, revoked_by: nil, paired_by: actor)
        token
      end

      def revoke!(actor:)
        update!(status: 'revoked', revoked_at: Time.current, revoked_by: actor, generation: generation + 1,
                token_digest: self.class.digest(self.class.new_token))
        staff_sessions.where(ended_at: nil).update_all(ended_at: Time.current, end_reason: 'device_revoked', updated_at: Time.current)
      end

      def to_pos
        {
          id: prefixed_id, branch_id: branch.prefixed_id, name: name, mode: mode, platform: platform,
          app_version: app_version, status: status, generation: generation,
          register_id: register&.prefixed_id, kitchen_station_id: kitchen_station_id,
          last_seen_at: last_seen_at&.iso8601, revoked_at: revoked_at&.iso8601
        }
      end
    end
  end
end

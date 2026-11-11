# frozen_string_literal: true

module Spree
  module Pos
    # One customer-facing screen bound to a staff member's open shift. Its
    # bearer token is opaque, stored only as a SHA-256 digest, expires after
    # TOKEN_TTL and is replaced on every rebind. The token reads display
    # state and acknowledges it, nothing else.
    #
    # The generation increments on every bind, pin and clear. The display
    # acknowledges the generation it rendered with a signed lease issued with
    # that state; `acked_at` is the lease's issue time, so an acknowledgement
    # is only as fresh as the state it proves.
    class DisplaySession < Record
      self.table_name = 'spree_pos_display_sessions'
      has_prefix_id :posdisplay

      TOKEN_TTL = 12.hours
      # Default local freshness window; branches may set 5..120 seconds once
      # the merchant has accepted it in device UAT.
      DEFAULT_FRESHNESS = 15
      LEASE_PURPOSE = 'pos_display_lease'
      REVOKE_REASONS = %w[ended unresponsive].freeze
      # order shows the pinned order; call_board the branch's call numbers.
      MODES = %w[order call_board].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :register, class_name: 'Spree::Pos::Register', optional: true
      belongs_to :shift, class_name: 'Spree::Pos::Shift'
      belongs_to :staff, class_name: staff_class_name
      belongs_to :pinned_workspace, class_name: 'Spree::Pos::Workspace', optional: true
      belongs_to :pinned_tender_attempt, class_name: 'Spree::Pos::TenderAttempt', optional: true

      validates :token_digest, presence: true
      validates :revoke_reason, inclusion: { in: REVOKE_REASONS }, allow_nil: true
      validates :mode, inclusion: { in: MODES }

      scope :for_store, ->(store) { where(store_id: store.id) }
      scope :live, -> { where(revoked_at: nil) }

      def self.digest(token)
        Digest::SHA256.hexdigest(token.to_s)
      end

      def self.new_token
        SecureRandom.urlsafe_base64(32)
      end

      def self.lease_verifier
        Rails.application.message_verifier(LEASE_PURPOSE)
      end

      # The session a display token opens, or nil when the token is unknown,
      # revoked or expired, the shift is closed or the staff member no longer
      # works at the branch. Callers never learn which.
      def self.authenticate(token)
        return if token.blank? || token.length > 200

        session = live.find_by(token_digest: digest(token))
        session if session&.usable?
      end

      # A new token for this screen: the previous one stops working, the
      # generation moves on and any pin or acknowledgement is dropped. The
      # caller holds the row lock. Returns the plain token, never stored.
      def rotate_token!(staff: self.staff)
        token = self.class.new_token
        update!(staff: staff, token_digest: self.class.digest(token), token_expires_at: Time.current + TOKEN_TTL,
                generation: generation + 1, pinned_workspace: nil, pinned_tender_attempt: nil, pinned_at: nil,
                acked_generation: nil, acked_at: nil)
        token
      end

      def freshness_seconds
        branch.display_freshness_ttl_seconds || DEFAULT_FRESHNESS
      end

      def expired?(now = Time.current)
        token_expires_at <= now
      end

      def usable?(now = Time.current)
        return false if revoked_at || expired?(now) || !shift.open?

        AccessPolicy.new(store: store, staff: staff).membership_for(branch)&.status == 'active'
      end

      def status
        return 'revoked' if revoked_at
        return 'expired' if expired?
        return 'ended' unless shift.open?

        'active'
      end

      def lease_for(issued_at)
        self.class.lease_verifier.generate([id, generation, issued_at.to_f.round(3)], expires_in: freshness_seconds.seconds)
      end

      # [generation, issued_at] of a lease this session issued, or nil when
      # the lease is forged, belongs to another session or expired.
      def read_lease(lease)
        session_id, leased_generation, issued = self.class.lease_verifier.verified(lease.to_s)
        return unless session_id == id && leased_generation.is_a?(Integer) && issued.is_a?(Numeric)

        [leased_generation, Time.zone.at(issued)]
      rescue ActiveSupport::MessageVerifier::InvalidSignature, ArgumentError, TypeError
        nil
      end

      # The display has acknowledged this generation with a lease that is
      # still within the freshness window.
      def ack_current?(now = Time.current)
        acked_generation == generation && acked_at.present? && acked_at > now - freshness_seconds.seconds
      end

      def to_pos
        now = Time.current
        {
          id: prefixed_id, branch_id: branch.prefixed_id, register_id: register&.prefixed_id, shift_id: shift.prefixed_id,
          status: status, mode: mode, generation: generation, freshness_ttl_seconds: freshness_seconds,
          token_expires_at: token_expires_at.iso8601,
          pinned_workspace_id: pinned_workspace&.prefixed_id, pinned_order_number: pinned_workspace&.order&.number,
          pinned_tender_attempt_id: pinned_tender_attempt&.prefixed_id, pinned_at: pinned_at&.iso8601,
          acked_generation: acked_generation, acked_at: acked_at&.iso8601, ack_current: ack_current?(now),
          last_seen_at: last_seen_at&.iso8601, revoked_at: revoked_at&.iso8601, revoke_reason: revoke_reason,
          server_time: now.iso8601(3)
        }
      end
    end
  end
end

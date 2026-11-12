# frozen_string_literal: true

module Spree
  module Pos
    # One guest phone at a table. Bound to the order that was open at the
    # table when the code was scanned: it orders onto that order only, and
    # stops working when the order is completed or canceled, after TTL, or
    # when the table's code is rotated. Without an open order it reads the
    # menu and calls staff, nothing else. Only token digests are stored.
    class GuestSession < Record
      self.table_name = 'spree_pos_guest_sessions'
      has_prefix_id :posguest

      TTL = 4.hours
      FINGERPRINT_PURPOSE = 'spree.pos.guest_session.fingerprint'

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :table_code, class_name: 'Spree::Pos::TableCode'
      belongs_to :resource, class_name: 'Spree::Pos::Resource'
      belongs_to :workspace, class_name: 'Spree::Pos::Workspace', optional: true
      has_many :guest_orders, class_name: 'Spree::Pos::GuestOrder', dependent: :restrict_with_error
      has_many :guest_requests, class_name: 'Spree::Pos::GuestRequest', dependent: :restrict_with_error

      validates :token_digest, :expires_at, presence: true

      scope :live, -> { where(revoked_at: nil) }

      def self.digest(token)
        Digest::SHA256.hexdigest(token.to_s)
      end

      def self.new_token
        SecureRandom.urlsafe_base64(32)
      end

      # A keyed digest of the client address and browser, to tell phones
      # apart in an investigation without keeping either.
      def self.fingerprint(address, user_agent)
        secret = Rails.application.key_generator.generate_key(FINGERPRINT_PURPOSE, 32)
        OpenSSL::HMAC.hexdigest('SHA256', secret, "#{address}|#{user_agent.to_s.first(200)}")
      end

      # [session, nil] when the token opens a usable session, [nil, reason]
      # otherwise: `session_invalid` for an unknown token, `session_expired`
      # for a session past its time, revoked, or whose order has closed.
      def self.authenticate(token)
        value = token.to_s
        return [nil, 'session_invalid'] if value.blank? || value.length > 200

        session = includes(:branch, :resource, :table_code, :workspace).find_by(token_digest: digest(value))
        return [nil, 'session_invalid'] if session.nil?
        return [nil, 'session_expired'] unless session.usable?

        [session, nil]
      end

      def usable?(now = Time.current)
        revoked_at.nil? && expires_at > now && table_code.active? && (workspace_id.nil? || order_open?)
      end

      # The guest can order: the session is bound to an order still open.
      def ordering?
        workspace_id.present? && order_open?
      end

      def order_open?
        workspace.present? && Workspace::OPEN_STATUSES.include?(workspace.operational_status)
      end
    end
  end
end

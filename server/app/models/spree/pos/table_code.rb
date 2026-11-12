# frozen_string_literal: true

module Spree
  module Pos
    # The code on a table's QR sticker. It opens a guest session at the
    # table and orders nothing by itself. Only the SHA-256 digest of the
    # token (128 random bits) is stored; the token is shown when the sticker
    # is printed. Rotating revokes the code and every session it opened.
    class TableCode < Record
      self.table_name = 'spree_pos_table_codes'
      has_prefix_id :posqr

      STATUSES = %w[active revoked].freeze
      TOKEN_BYTES = 16
      TOKEN = /\A[A-Za-z0-9_-]{16,64}\z/

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :resource, class_name: 'Spree::Pos::Resource'
      belongs_to :created_by, class_name: staff_class_name
      has_many :guest_sessions, class_name: 'Spree::Pos::GuestSession', dependent: :restrict_with_error

      validates :status, inclusion: { in: STATUSES }
      validates :token_digest, presence: true
      validate :resource_of_branch

      scope :active, -> { where(status: 'active') }

      def self.digest(token)
        Digest::SHA256.hexdigest(token.to_s)
      end

      def self.new_token
        SecureRandom.urlsafe_base64(TOKEN_BYTES)
      end

      # The active code of a token, or nil; callers never learn why.
      def self.authenticate(token)
        value = token.to_s
        return unless value.match?(TOKEN)

        active.includes(:branch, :resource).find_by(token_digest: digest(value))
      end

      # Where the sticker's QR points: the guest page on this server.
      def self.url(base_url, token)
        "#{base_url.to_s.chomp('/')}/table/t/#{token}"
      end

      def active?
        status == 'active'
      end

      def to_pos
        { id: prefixed_id, resource_id: resource.prefixed_id, status: status, rotated_at: rotated_at.iso8601,
          revoked_at: revoked_at&.iso8601 }
      end

      private

      def resource_of_branch
        errors.add(:resource, :invalid) if resource && (resource.branch_id != branch_id || resource.store_id != store_id)
      end
    end
  end
end

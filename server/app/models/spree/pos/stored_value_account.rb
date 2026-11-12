# frozen_string_literal: true

module Spree
  module Pos
    # Prepaid value one customer keeps with the store: money held for them,
    # never revenue. Its balance is the sum of its append-only entries; every
    # writer (Spree::Pos::StoredValue) locks this row first, so it is the
    # serialization point for balance checks.
    #
    # Kinds: `meal` (a canteen wallet, always of a meal account), `money` (a
    # prepaid card that pays orders) and `minutes` (a prepaid card of play
    # minutes, each top-up at its own price per minute). A card is found by
    # the digest of what its QR code or RFID tag reads; the value itself is
    # never stored, only its last characters to show.
    class StoredValueAccount < Record
      self.table_name = 'spree_pos_stored_value_accounts'
      has_prefix_id :posstoredvalue

      KINDS = %w[meal money minutes].freeze
      CARD_KINDS = %w[money minutes].freeze
      STATUSES = %w[active closed].freeze
      CARD_TOKEN = /\A[A-Za-z0-9._:-]{6,128}\z/

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch', optional: true
      belongs_to :customer_profile, class_name: 'Spree::Pos::CustomerProfile', optional: true
      has_many :entries, class_name: 'Spree::Pos::StoredValueEntry', inverse_of: :stored_value_account,
                         dependent: :restrict_with_error

      validates :kind, inclusion: { in: KINDS }
      validates :status, inclusion: { in: STATUSES }
      validates :currency, presence: true
      validates :customer_profile, presence: true, if: -> { kind == 'meal' }
      validates :card_digest, presence: true, if: :card?
      validates :holder_name, length: { maximum: 120 }

      scope :for_store, ->(store) { where(store_id: store.id) }
      scope :cards, -> { where(kind: CARD_KINDS) }

      # The digest a card is stored and found by, keyed by the app secret so
      # a leaked table does not reveal the cards' codes.
      def self.card_digest(token)
        OpenSSL::HMAC.hexdigest('SHA256', Rails.application.secret_key_base.to_s, "pos-stored-value-card:#{token}")
      end

      def self.find_card(store, token)
        value = token.to_s.strip
        return nil unless value.match?(CARD_TOKEN)

        for_store(store).cards.find_by(card_digest: card_digest(value))
      end

      def card?
        CARD_KINDS.include?(kind)
      end

      def minutes?
        kind == 'minutes'
      end

      def active?
        status == 'active'
      end

      def balance
        BigDecimal(entries.sum(:amount).to_s)
      end

      def minutes_balance
        entries.sum(:minutes).to_i
      end

      def bump!
        update!(revision: revision + 1)
      end

      def to_pos
        { id: prefixed_id, kind: kind, card_hint: card_hint, holder_name: holder_name || customer_profile&.name,
          customer_id: customer_profile&.prefixed_id, branch_id: branch&.prefixed_id, status: status, currency: currency,
          balance: balance.to_s('F'), minutes_balance: minutes? ? minutes_balance : nil, revision: revision,
          created_at: created_at&.iso8601 }
      end
    end
  end
end

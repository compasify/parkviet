# frozen_string_literal: true

module Spree
  module Pos
    # A short single-use code that pairs a separate device with a display
    # session. Only its SHA-256 digest is stored; it expires after TTL and is
    # spent by the first successful exchange. Issuing a new code or
    # rebinding the display spends the previous ones.
    class DisplayPairing < Record
      self.table_name = 'spree_pos_display_pairings'
      has_prefix_id :pospairing

      TTL = 10.minutes
      LENGTH = 8
      # No 0/O, 1/I/L: read aloud or typed on a tablet without confusion.
      ALPHABET = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789'.chars.freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :display_session, class_name: 'Spree::Pos::DisplaySession'
      belongs_to :created_by, class_name: staff_class_name

      def self.new_code
        Array.new(LENGTH) { ALPHABET[SecureRandom.random_number(ALPHABET.length)] }.join
      end

      # Upper-cased, spaces and dashes removed; nil when it cannot be a code.
      def self.normalize(code)
        value = code.to_s.upcase.delete(' -')
        value if value.length == LENGTH && value.chars.all? { |char| ALPHABET.include?(char) }
      end

      def self.digest(code)
        Digest::SHA256.hexdigest(code)
      end

      def usable?(now = Time.current)
        used_at.nil? && expires_at > now
      end
    end
  end
end

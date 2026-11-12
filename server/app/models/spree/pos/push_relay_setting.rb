# frozen_string_literal: true

module Spree
  module Pos
    # Where a store's server hands background notifications to: a small
    # relay that holds the FCM / APNs credentials, so a server on the shop's
    # LAN never does. The key signs every request and is encrypted at rest
    # (when Active Record encryption keys are configured) and never returned.
    # No row means no push: owners hear events only while the app is open.
    class PushRelaySetting < Record
      self.table_name = 'spree_pos_push_relay_settings'
      has_prefix_id :pospushrelay

      URL_MAX = 300
      KEY_MIN = 32
      KEY_MAX = 512
      ERROR_MAX = 200

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :changed_by, class_name: staff_class_name, optional: true

      encrypts :relay_key if ActiveRecord::Encryption.config.has_primary_key?

      validates :store_id, uniqueness: true
      validates :relay_key, presence: true, length: { in: KEY_MIN..KEY_MAX }
      validate :url_is_web

      def self.for_store(store)
        find_by(store_id: store.id)
      end

      def to_pos
        { url: url, key_set: relay_key.present?, last_error: last_error, last_error_at: last_error_at&.iso8601,
          last_delivered_at: last_delivered_at&.iso8601, updated_at: updated_at&.iso8601 }
      end

      private

      def url_is_web
        return if url.present? && url.length <= URL_MAX && url.match?(%r{\Ahttps://[^\s]+\z}i)

        errors.add(:url, :invalid)
      end
    end
  end
end

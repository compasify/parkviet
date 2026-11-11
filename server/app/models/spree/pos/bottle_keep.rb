# frozen_string_literal: true

module Spree
  module Pos
    # A guest's unfinished bottle kept behind the bar under the code on its
    # label. Only a book of levels: no money moves (the bottle was sold on an
    # ordinary line, and pouring from it later is free). Every change is an
    # event; the level here is the latest event's.
    class BottleKeep < Record
      self.table_name = 'spree_pos_bottle_keeps'
      has_prefix_id :posbottlekeep

      STATUSES = %w[kept finished expired returned].freeze
      CODE = /\A[A-Z0-9]{4,16}\z/
      PHOTO_TYPES = %w[image/jpeg image/png image/webp].freeze
      PHOTO_MAX_BYTES = 2.megabytes

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :customer_profile, class_name: 'Spree::Pos::CustomerProfile', optional: true
      belongs_to :variant, -> { with_deleted }, class_name: 'Spree::Variant'
      belongs_to :source_order, class_name: 'Spree::Order', optional: true
      belongs_to :source_sale_line, class_name: 'Spree::Pos::SaleLine', optional: true
      belongs_to :created_by, class_name: staff_class_name
      has_many :events, -> { order(:id) }, class_name: 'Spree::Pos::BottleKeepEvent', dependent: :restrict_with_error,
                                           inverse_of: :bottle_keep
      has_one_attached :photo

      validates :status, inclusion: { in: STATUSES }
      validates :code, format: { with: CODE }
      validates :level_percent, numericality: { only_integer: true, in: 0..100 }
      validates :kept_on, :expires_on, presence: true
      validates :guest_name, length: { maximum: 120 }
      validates :phone, length: { maximum: 32 }
      validates :note, length: { maximum: 200 }
      validate :guest_known
      validate :photo_acceptable

      scope :kept, -> { where(status: 'kept') }

      def kept?
        status == 'kept'
      end

      def bump!
        update!(revision: revision + 1)
      end

      def to_pos(with_events: false)
        product = variant.product
        row = {
          id: prefixed_id, branch_id: branch.prefixed_id, code: code, status: status, level_percent: level_percent,
          variant_id: variant.prefixed_id, product_name: product&.name, options_text: variant.options_text.presence,
          customer: customer_profile&.to_pos, guest_name: guest_name || customer_profile&.name,
          phone: phone || customer_profile&.phone, kept_on: kept_on.iso8601, expires_on: expires_on.iso8601,
          source_order_id: source_order&.prefixed_id, note: note, revision: revision,
          photo_url: photo_url, created_at: created_at.iso8601, closed_at: closed_at&.iso8601
        }
        row[:events] = events.includes(:actor, :workspace).map(&:to_pos) if with_events
        row
      end

      def photo_url
        return unless photo.attached?

        Rails.application.routes.url_helpers.rails_blob_path(photo, only_path: true)
      rescue StandardError => e
        Rails.logger.warn("[pos] bottle keep photo for #{prefixed_id} failed: #{e.class}: #{e.message}")
        nil
      end

      private

      def guest_known
        errors.add(:guest_name, :blank) if customer_profile_id.nil? && guest_name.blank? && phone.blank?
      end

      def photo_acceptable
        return unless photo.attached?

        blob = photo.blob
        errors.add(:photo, :invalid) unless PHOTO_TYPES.include?(blob.content_type) && blob.byte_size <= PHOTO_MAX_BYTES
      end
    end
  end
end

# frozen_string_literal: true

module Spree
  module Pos
    class OutboxEntry < Record
      self.table_name = 'spree_pos_outbox_entries'
      has_prefix_id :posoutbox

      belongs_to :store, class_name: 'Spree::Store'

      validates :event_type, :aggregate_type, presence: true
      validates :status, inclusion: { in: %w[pending processing processed failed] }

      scope :for_store, ->(store) { where(store_id: store.id) }
      scope :due, -> { where(status: 'pending').where(available_at: ..Time.current).order(:id) }

      def self.record!(store:, event_type:, aggregate:, payload: {})
        create!(store: store, event_type: event_type, aggregate_type: aggregate.class.name,
                aggregate_id: aggregate.id, payload: payload, status: 'pending', available_at: Time.current)
      end
    end
  end
end

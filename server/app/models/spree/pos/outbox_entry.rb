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

      # Attention items raised by recovery sweeps: once per event and aggregate.
      # A transaction-scoped advisory lock on the event and aggregate makes the
      # check-then-insert safe when two sweeps or commands race.
      def self.record_once!(store_id:, event_type:, aggregate:, payload: {})
        transaction do
          lock_key = "pos_outbox_once:#{event_type}:#{aggregate.class.name}:#{aggregate.id}"
          connection.execute(sanitize_sql_array(['SELECT pg_advisory_xact_lock(hashtextextended(?, 0))', lock_key]))
          next if exists?(event_type: event_type, aggregate_type: aggregate.class.name, aggregate_id: aggregate.id)

          create!(store_id: store_id, event_type: event_type, aggregate_type: aggregate.class.name,
                  aggregate_id: aggregate.id, payload: payload, status: 'pending', available_at: Time.current)
        end
      end

      def self.record!(store:, event_type:, aggregate:, payload: {})
        create!(store: store, event_type: event_type, aggregate_type: aggregate.class.name,
                aggregate_id: aggregate.id, payload: payload, status: 'pending', available_at: Time.current)
      end
    end
  end
end

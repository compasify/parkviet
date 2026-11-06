# frozen_string_literal: true

module Spree
  module Pos
    module Topology
      class Disable
        def self.call(record:, actor:)
          record.with_lock do
            # Repeating a disable keeps the original time and does not add a second entry.
            next if record.status == 'disabled'

            record.update!(status: 'disabled', disabled_at: Time.current)
            AuditEntry.record!(store: record.store, actor: actor, action: 'disable', subject: record)
          end
          record
        end
      end
    end
  end
end

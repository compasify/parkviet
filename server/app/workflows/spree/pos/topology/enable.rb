# frozen_string_literal: true

module Spree
  module Pos
    module Topology
      class Enable
        def self.call(record:, actor:, policy:)
          branch = record.is_a?(Branch) ? record : record.branch
          raise CanCan::AccessDenied unless policy.can_recover?(branch)

          record.with_lock do
            next if record.status == 'active'

            record.update!(status: 'active', disabled_at: nil)
            AuditEntry.record!(store: record.store, actor: actor, action: 'enable', subject: record)
          end
          record
        end
      end
    end
  end
end

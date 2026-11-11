# frozen_string_literal: true

module Spree
  module Pos
    module BottleKeeps
      # Ends a kept bottle: `return` when the guest takes it home, `expire`
      # when its time ran out (by hand, or ExpireJob for the overdue ones).
      module Close
        KINDS = { 'return' => 'returned', 'expire' => 'expired' }.freeze
        AUTO_NOTE = 'Hết hạn gửi (tự động)'

        module_function

        def call(store:, staff:, key:, keep_id:, kind:, note: nil)
          kind = kind.to_s
          raise Conflict.new('Unknown way to end a kept bottle.', reason: 'bottle_close_invalid') unless KINDS.key?(kind)

          keep = Guard.keep_record!(store, keep_id)
          payload = { 'command' => "bottle_keep.#{kind}", 'keep_id' => keep.prefixed_id, 'note' => note.to_s.squish.presence }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { Guard.keep!(store, staff, keep.branch) }) do
            ModulePolicy.require!(keep.branch, Guard::MODULE)
            close!(keep, staff, kind, note)
            keep.reload.to_pos(with_events: true)
          end
        end

        # Without an actor (the daily job) the history names the person who
        # kept the bottle and says it ran out on its own; there is no audit row.
        def close!(keep, actor, kind, note)
          keep.lock!
          Guard.kept!(keep)
          keep.update!(status: KINDS.fetch(kind), closed_at: Time.current, revision: keep.revision + 1)
          Guard.event!(keep, kind: kind, actor: actor || keep.created_by, level_before: keep.level_percent, level_after: keep.level_percent,
                             note: actor ? note : AUTO_NOTE)
          Guard.audit!(keep, actor, "bottle_keep.#{kind}", note: note.to_s.squish.presence) if actor
          keep
        end
      end
    end
  end
end

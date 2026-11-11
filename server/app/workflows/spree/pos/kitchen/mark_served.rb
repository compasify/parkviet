# frozen_string_literal: true

module Spree
  module Pos
    module Kitchen
      # The pass hands a ready dish to its table: only a `ready` item becomes
      # `served`. Tapping a served item again changes nothing (the move is
      # idempotent by its target status), so a retried tap is safe. Besides
      # the kitchen event, the order is announced, so the cashier's and the
      # waiter's screens show the dish as out.
      module MarkServed
        module_function

        # `actor` is the pass screen (Device) or the staff member.
        def call(item:, actor:)
          unless %w[ready served].include?(item.status)
            raise Conflict.new('Only a ready dish can be handed out.', reason: 'kitchen_status_invalid', details: { status: item.status })
          end

          served = item.status == 'served'
          ChangeItemStatus.call(item: item, action: 'serve', actor: actor)
          Realtime.announce_workspaces([item.kitchen_ticket.workspace_id]) unless served
          item
        end
      end
    end
  end
end

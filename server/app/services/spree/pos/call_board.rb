# frozen_string_literal: true

module Spree
  module Pos
    # The call numbers of a branch's business day, by how far the kitchen
    # has got: "preparing" while any item of the order is still new or being
    # made, "ready" once every item is ready or served and some are still
    # waiting to be handed over. A ready number leaves the board when its
    # items are served, or `pickup_minutes` after it became ready. Voided
    # items do not count. Orders without a call number or a kitchen ticket
    # are not on the board.
    module CallBoard
      module_function

      # `with_ids` adds the workspace id, for the cashier's pickup queue; the
      # customer display gets numbers and names only.
      def call(branch:, now: Workspace.database_now, with_ids: false)
        window = CupLabels::Settings.for(branch)['pickup_minutes'].minutes
        preparing = []
        ready = []
        rows(branch, BusinessDay.for(branch, now)).group_by(&:first).each_value do |items|
          id, number, guest = items.first
          statuses = items.map { |row| row[3] }
          if statuses.any? { |status| KitchenTicketItem::OPEN.include?(status) }
            preparing << { id: id, number: number }
          elsif statuses.include?('ready')
            ready_at = items.filter_map { |row| row[4] }.max
            ready << { id: id, number: number, guest_name: guest, ready_at: ready_at } if ready_at && ready_at >= now - window
          end
        end
        preparing.sort_by! { |row| row[:number] }
        ready.sort_by! { |row| [-row[:ready_at].to_f, row[:number]] }
        prefixed = with_ids ? Workspace.where(id: (preparing + ready).map { |row| row[:id] }).index_by(&:id) : {}
        {
          preparing: preparing.map { |row| entry(row, prefixed, with_ids) },
          ready: ready.map { |row| entry(row, prefixed, with_ids).merge(guest_name: row[:guest_name], ready_at: row[:ready_at].iso8601(3)) }
        }
      end

      def rows(branch, date)
        KitchenTicketItem.joins(kitchen_ticket: :workspace).
          where(spree_pos_kitchen_tickets: { branch_id: branch.id }, spree_pos_workspaces: { business_date: date }).
          where.not(spree_pos_workspaces: { order_number: nil }).
          where.not(spree_pos_workspaces: { operational_status: 'canceled' }).
          where.not(status: 'voided').
          pluck('spree_pos_workspaces.id', 'spree_pos_workspaces.order_number', 'spree_pos_workspaces.guest_name',
                'spree_pos_kitchen_ticket_items.status', 'spree_pos_kitchen_ticket_items.ready_at')
      end

      def entry(row, prefixed, with_ids)
        with_ids ? { number: row[:number], workspace_id: prefixed.fetch(row[:id]).prefixed_id } : { number: row[:number] }
      end
    end
  end
end

# frozen_string_literal: true

module Spree
  module Pos
    # The owner app's two light reads of one branch. "Today" takes its sales
    # from Reports::Sales for the current business date, so it shows the
    # very figures of the sales report; the rest are small counts. Both need
    # `pos.report.read` at the branch.
    module OwnerDashboard
      module_function

      def today(store:, staff:, branch:)
        scope = reader!(store, staff, branch)
        report = Reports.build('sales', scope: scope, values: {})
        summary = report.summary
        date = report.filters.from
        open = open_workspaces(branch)
        dated = Workspace.where(branch_id: branch.id, business_date: date)
        {
          branch_id: branch.prefixed_id, business_date: date.iso8601, timezone: branch.timezone,
          currency: store.default_currency,
          orders: summary[:orders], sales_total: summary[:sales_total], returns_total: summary[:returns_total],
          net_sales: summary[:net_sales], by_source: summary[:by_source], by_hour: report.by_hour,
          open_units: open.where.not(resource_id: nil).count, open_orders: open.count,
          open_total: money(Spree::Order.where(id: open.select(:order_id)).sum(:total)),
          open_shifts: Shift.for_store(store).where(branch_id: branch.id).open_now.count,
          canceled_orders: dated.where(operational_status: 'canceled').count,
          voided_items: KitchenVoid.where(workspace_id: dated.select(:id)).count,
          pending_approvals: ApprovalRequest.pending.where(branch_id: branch.id).where('expires_at > ?', Workspace.database_now).count
        }
      end

      # Every open table, room or tab: how long it has been open, its
      # running total and how its kitchen is doing.
      def open_units(store:, staff:, branch:)
        reader!(store, staff, branch)
        now = Workspace.database_now
        rows = open_workspaces(branch).includes(:order, :resource).order(:created_at, :id).limit(200).to_a
        waiting = kitchen_waiting(rows.map(&:id), now)
        rows.map do |workspace|
          late, count = waiting.fetch(workspace.id, [false, 0])
          { workspace_id: workspace.prefixed_id, resource_id: workspace.resource&.prefixed_id,
            label: workspace.resource&.name || workspace.tab_name.presence || workspace.table_label.presence || workspace.order&.number,
            service_mode: workspace.service_mode, status: workspace.operational_status, guest_count: workspace.guest_count,
            opened_at: workspace.created_at.iso8601, minutes_open: ((now - workspace.created_at) / 60).floor,
            total: money(workspace.order&.total), kitchen_waiting: count, kitchen_late: late }
        end
      end

      def reader!(store, staff, branch)
        scope = Reports::Scope.new(store: store, staff: staff, branch: branch)
        raise CanCan::AccessDenied unless scope.full?

        scope
      end

      def open_workspaces(branch)
        Workspace.where(branch_id: branch.id, operational_status: Workspace::OPEN_STATUSES)
      end

      # { workspace_id => [any item past its station's late threshold, items still waiting] }
      def kitchen_waiting(ids, now)
        return {} if ids.empty?

        late = "BOOL_OR(spree_pos_kitchen_tickets.sent_at + make_interval(mins => spree_pos_kitchen_stations.late_after_minutes) <= #{ActiveRecord::Base.connection.quote(now)})"
        KitchenTicketItem.joins(kitchen_ticket: :kitchen_station).
          where(spree_pos_kitchen_tickets: { workspace_id: ids, kind: 'fire' }, status: %w[new preparing]).
          group('spree_pos_kitchen_tickets.workspace_id').
          pluck(Arel.sql('spree_pos_kitchen_tickets.workspace_id'), Arel.sql(late), Arel.sql('COUNT(*)')).
          to_h { |id, any_late, count| [id, [any_late == true, count.to_i]] }
      end

      def money(value)
        BigDecimal((value || 0).to_s).to_s('F')
      end
    end
  end
end

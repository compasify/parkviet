# frozen_string_literal: true

module Spree
  module Pos
    # The floor of a branch as the counter sees it: every active area and
    # table, and each table's state computed from its open orders. Nothing
    # here is stored except a table's cleaning / out-of-service mark.
    #
    # States, strongest first: out_of_service, cleaning (no open order),
    # payment_requested, prebilled, waiting_long (a kitchen item waited past
    # its station's late threshold), ordered (sent to the kitchen),
    # occupied, available. A fixed number of queries whatever the number of
    # tables: areas, tables, open orders (with the database clock), and only
    # when orders are open, their kitchen items, payment requests and pre-bills.
    class ResourceState
      STATES = %w[available occupied ordered waiting_long payment_requested prebilled cleaning out_of_service].freeze
      PENDING_ITEMS = %w[new preparing].freeze

      def self.for(branch)
        new(branch).to_pos
      end

      def initialize(branch)
        @branch = branch
      end

      def to_pos
        areas = Area.active.where(branch_id: branch.id).order(:position, :id).to_a
        resources = Resource.active.where(branch_id: branch.id).order(:position, :id).to_a
        area_refs = areas.to_h { |area| [area.id, area.prefixed_id] }
        orders = open_orders
        now = @now || Workspace.database_now
        by_resource = orders.group_by { |row| row[:resource_id] }
        {
          branch_id: branch.prefixed_id,
          server_now: now.iso8601,
          areas: areas.map do |area|
            { id: area.prefixed_id, name: area.name, position: area.position, floor_width: area.floor_width, floor_height: area.floor_height }
          end,
          resources: resources.map { |resource| tile(resource, area_refs, by_resource.fetch(resource.id, []), now) }
        }
      end

      private

      attr_reader :branch

      def open_orders
        rows = Workspace.where(branch_id: branch.id, operational_status: Workspace::OPEN_STATUSES).where.not(resource_id: nil).
               joins(:order).order(:id).
               pluck(:id, :resource_id, :table_label, :guest_count, :revision, :created_at, :operational_status,
                     'spree_orders.total', 'spree_orders.currency', Arel.sql('clock_timestamp()'))
        return [] if rows.empty?

        @now = rows.first.last
        ids = rows.map(&:first)
        kitchen = kitchen_by_workspace(ids)
        requests = PaymentRequest.open.where(workspace_id: ids).pluck(:workspace_id).to_set
        prebills = latest_prebills(ids)
        rows.map do |id, resource_id, label, guests, revision, created_at, status, total, currency, _now|
          print = prebills[id]
          { id: id, resource_id: resource_id, table_label: label, guest_count: guests, revision: revision, created_at: created_at,
            status: status, total: BigDecimal(total.to_s), currency: currency, kitchen: kitchen[id],
            payment_requested: requests.include?(id),
            prebilled: print && print[:status] == 'current' && print[:revision] == revision,
            edited_after_prebill: print.present? && !(print[:status] == 'current' && print[:revision] == revision) }
        end
      end

      # Per order: whether anything went to the kitchen, and whether a sent
      # item has waited longer than its station allows.
      def kitchen_by_workspace(ids)
        KitchenTicketItem.joins(kitchen_ticket: :kitchen_station).where(spree_pos_kitchen_tickets: { workspace_id: ids }).
          group('spree_pos_kitchen_tickets.workspace_id').
          pluck(Arel.sql('spree_pos_kitchen_tickets.workspace_id'), Arel.sql('COUNT(*)'),
                Arel.sql(ActiveRecord::Base.sanitize_sql_array([
                  "BOOL_OR(spree_pos_kitchen_ticket_items.status IN (?) AND spree_pos_kitchen_tickets.sent_at < " \
                  "clock_timestamp() - make_interval(mins => spree_pos_kitchen_stations.late_after_minutes))", PENDING_ITEMS
                ])),
                Arel.sql(ActiveRecord::Base.sanitize_sql_array([
                  'COUNT(*) FILTER (WHERE spree_pos_kitchen_ticket_items.status IN (?))', PENDING_ITEMS
                ]))).
          to_h { |id, count, late, pending| [id, { sent: count.positive?, late: late == true, pending: pending }] }
      end

      def latest_prebills(ids)
        PrebillPrint.where(workspace_id: ids).where.not(status: 'canceled').
          select('DISTINCT ON (workspace_id) workspace_id, status, revision').order(:workspace_id, sequence: :desc).
          to_h { |row| [row.workspace_id, { status: row.status, revision: row.revision }] }
      end

      def tile(resource, area_refs, orders, now)
        oldest = orders.map { |row| row[:created_at] }.min
        guests = orders.filter_map { |row| row[:guest_count] }
        {
          id: resource.prefixed_id, area_id: area_refs[resource.area_id], name: resource.name, kind: resource.kind,
          capacity: resource.capacity, shape: resource.shape, x: resource.x, y: resource.y, w: resource.w, h: resource.h,
          rotation: resource.rotation, manual_status: resource.manual_status,
          state: state_of(resource, orders),
          guest_count: guests.empty? ? nil : guests.sum,
          seated_minutes: oldest && [((now - oldest) / 60).floor, 0].max,
          subtotal: orders.empty? ? nil : orders.sum { |row| row[:total] }.to_s('F'),
          currency: orders.first&.dig(:currency),
          payment_requested: orders.any? { |row| row[:payment_requested] },
          edited_after_prebill: orders.any? { |row| row[:edited_after_prebill] },
          orders: orders.map do |row|
            { id: workspace_ref(row[:id]), table_label: row[:table_label], guest_count: row[:guest_count],
              total: row[:total].to_s('F'), revision: row[:revision], operational_status: row[:status],
              payment_requested: row[:payment_requested], prebilled: row[:prebilled] == true,
              edited_after_prebill: row[:edited_after_prebill], pending_kitchen_items: row[:kitchen]&.dig(:pending) || 0 }
          end
        }
      end

      # Prefixed ids are computed from the key; no record is loaded for them.
      def workspace_ref(id)
        "#{Workspace._prefix_id_prefix}_#{Spree::PrefixedId::SQIDS.encode([id])}"
      end

      def state_of(resource, orders)
        return 'out_of_service' if resource.manual_status == 'out_of_service'
        return (resource.manual_status == 'cleaning' ? 'cleaning' : 'available') if orders.empty?
        return 'payment_requested' if orders.any? { |row| row[:payment_requested] }
        return 'prebilled' if orders.any? { |row| row[:prebilled] }
        return 'waiting_long' if orders.any? { |row| row[:kitchen]&.dig(:late) }
        return 'ordered' if orders.any? { |row| row[:kitchen]&.dig(:sent) }

        'occupied'
      end
    end
  end
end

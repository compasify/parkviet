# frozen_string_literal: true

module Spree
  module Pos
    # The floor of a branch as the counter sees it: every active area and
    # table, and each table's state computed from its open orders. Nothing
    # here is stored except a table's cleaning / out-of-service mark.
    #
    # States, strongest first: out_of_service, cleaning (no open order),
    # payment_requested, prebilled, ending_soon (a running clock's planned
    # end, or its prepaid package's end, is near or past), waiting_long (a kitchen item waited past its station's late
    # threshold), playing (a clock runs in the room), ordered (sent to the
    # kitchen), occupied, available. A fixed number of queries whatever the
    # number of tables: areas, tables, open orders (with the database clock),
    # and only when orders are open, their kitchen items, payment requests and
    # pre-bills; and only when they have clocks, the clocks and their prices.
    class ResourceState
      STATES = %w[available reserved occupied ordered playing waiting_long ending_soon payment_requested prebilled cleaning
                  out_of_service].freeze
      # A room shows ending soon this long before its clock's planned end.
      ENDING_SOON = 10.minutes
      # A free table shows `reserved` this long before its next booking.
      RESERVED_AHEAD = 60.minutes
      # How far ahead a table's next booking is shown on its tile.
      BOOKING_WINDOW = '12 hours'
      PENDING_ITEMS = %w[new preparing].freeze

      def self.for(branch)
        new(branch).to_pos
      end

      def initialize(branch)
        @branch = branch
      end

      def to_pos
        areas = Area.active.where(branch_id: branch.id).order(:position, :id).to_a
        resources = Resource.active.where(branch_id: branch.id).select('spree_pos_resources.*', Arel.sql(NEXT_BOOKING)).
                    order(:position, :id).to_a
        area_refs = areas.to_h { |area| [area.id, area.prefixed_id] }
        orders = open_orders
        now = @now || Workspace.database_now
        by_resource = orders.group_by { |row| row[:resource_id] }
        clocks = timed_by_resource(orders, now)
        {
          branch_id: branch.prefixed_id,
          server_now: now.iso8601,
          # Whether a clock started now is outside the branch's operating hours.
          outside_operating_hours: OperatingHours.check(branch, now).present?,
          areas: areas.map do |area|
            { id: area.prefixed_id, name: area.name, position: area.position, floor_width: area.floor_width, floor_height: area.floor_height }
          end,
          resources: resources.map { |resource| tile(resource, area_refs, by_resource.fetch(resource.id, []), now, clocks[resource.id]) }
        }
      end

      private

      attr_reader :branch

      def open_orders
        rows = Workspace.where(branch_id: branch.id, operational_status: Workspace::OPEN_STATUSES).where.not(resource_id: nil).
               joins(:order).order(:id).
               pluck(:id, :resource_id, :table_label, :guest_count, :revision, :created_at, :operational_status,
                     'spree_orders.total', 'spree_orders.currency', Arel.sql(BUFFET_ENDS), Arel.sql(HAS_CLOCK), Arel.sql(UNSENT_ITEMS),
                     Arel.sql('clock_timestamp()'))
        return [] if rows.empty?

        @now = rows.first.last
        ids = rows.map(&:first)
        kitchen = kitchen_by_workspace(ids)
        requests = PaymentRequest.open.where(workspace_id: ids).pluck(:workspace_id).to_set
        prebills = latest_prebills(ids)
        rows.map do |id, resource_id, label, guests, revision, created_at, status, total, currency, buffet_ends, clock, unsent, _now|
          print = prebills[id]
          { id: id, resource_id: resource_id, table_label: label, guest_count: guests, revision: revision, created_at: created_at,
            status: status, total: BigDecimal(total.to_s), currency: currency, kitchen: kitchen[id],
            payment_requested: requests.include?(id), buffet_ends_at: buffet_ends, clock: clock == true,
            unsent: BigDecimal((unsent || 0).to_s).ceil,
            prebilled: print && print[:status] == 'current' && print[:revision] == revision,
            edited_after_prebill: print.present? && !(print[:status] == 'current' && print[:revision] == revision) }
        end
      end

      # The clock of each room with an open order: the running one, else the
      # last one stopped and not paid yet, with its quote up to now.
      def timed_by_resource(orders, now)
        ids = orders.select { |row| row[:clock] }.map { |row| row[:id] }
        return {} if ids.empty?

        sessions = TimedSession.where(workspace_id: ids).
                   includes(:branch, :resource, :timed_quote_lines, timed_segments: %i[resource rate_plan]).order(:id).to_a
        return {} if sessions.empty?

        book = Timed::Sessions.book_for(branch, sessions, now)
        sessions.group_by(&:resource_id).transform_values do |list|
          session = list.reverse.find(&:active?) || list.last
          quote = session.active? ? Timed::Quote.call(session, now: now, book: book) : nil
          running = session.status == 'running'
          due = running && session.planned_end_at.present?
          package_ended = due && session.package? && session.planned_end_at <= now
          { id: session.prefixed_id, workspace_id: workspace_ref(session.workspace_id), status: session.status,
            started_at: session.started_at.iso8601, stopped_at: session.stopped_at&.iso8601,
            planned_end_at: session.planned_end_at&.iso8601, paused_at: session.paused_since&.iso8601,
            prepaid_minutes: session.prepaid_minutes,
            played_seconds: session.active? ? session.played_seconds(now).floor : nil,
            played_minutes: quote ? quote.played_minutes : session.played_minutes,
            quote_amount: (quote ? quote.amount : session.amount || BigDecimal('0')).to_s('F'),
            ending_soon: due && !package_ended && session.planned_end_at <= now + ENDING_SOON,
            package_ended: package_ended,
            pause_too_long: session.status == 'paused' && Timed::Guard.long_pause?(session, now) }
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

      # The next booking holding a table within BOOKING_WINDOW, read with
      # the tables (no query of its own).
      NEXT_BOOKING = <<~SQL.squish.freeze
        (SELECT json_build_object('id', r.id, 'starts_at', r.starts_at, 'guest_name', r.guest_name, 'party_size', r.party_size)
         FROM spree_pos_reservation_resources rr JOIN spree_pos_reservations r ON r.id = rr.reservation_id
         WHERE rr.resource_id = spree_pos_resources.id AND rr.active AND r.status = 'booked'
           AND rr.ends_at > (clock_timestamp() AT TIME ZONE 'UTC')
           AND rr.starts_at < (clock_timestamp() AT TIME ZONE 'UTC') + interval '#{BOOKING_WINDOW}'
         ORDER BY rr.starts_at LIMIT 1) AS next_booking
      SQL
      # Whether an order has a clock, read with the orders.
      HAS_CLOCK = <<~SQL.squish.freeze
        EXISTS (SELECT 1 FROM spree_pos_timed_sessions ts WHERE ts.workspace_id = spree_pos_workspaces.id)
      SQL
      # Menu units of an order the kitchen has not been told about yet (held
      # courses wait for their fire), read with the orders. Matches what a
      # kitchen send would take (`Kitchen::Send`) and `SaleLine#pending_kitchen_quantity`.
      UNSENT_ITEMS = <<~SQL.squish.freeze
        (SELECT COALESCE(SUM(sl.sale_quantity - sl.kitchen_sent_quantity), 0) FROM spree_pos_sale_lines sl
         WHERE sl.workspace_id = spree_pos_workspaces.id AND sl.kind = '#{SaleLineKinds::Menu::KIND}'
           AND sl.course_status <> 'held' AND sl.sale_quantity > sl.kitchen_sent_quantity)
      SQL
      # When the earliest buffet ticket of an order runs out, read with the orders.
      BUFFET_ENDS = <<~SQL.squish.freeze
        (SELECT MIN(sl.created_at + make_interval(mins => bt.duration_minutes)) FROM spree_pos_sale_lines sl
         JOIN spree_pos_buffet_tiers bt ON bt.id = sl.buffet_tier_id
         WHERE sl.workspace_id = spree_pos_workspaces.id AND sl.kind = 'cover')
      SQL

      def booking_of(resource)
        raw = resource.attributes['next_booking']
        return nil if raw.blank?

        data = raw.is_a?(String) ? JSON.parse(raw) : raw
        { id: Reservation.prefixed_for(data['id']), starts_at: Time.find_zone('UTC').parse(data['starts_at'].to_s).iso8601,
          guest_name: data['guest_name'], party_size: data['party_size'] }
      end

      def tile(resource, area_refs, orders, now, timed = nil)
        oldest = orders.map { |row| row[:created_at] }.min
        guests = orders.filter_map { |row| row[:guest_count] }
        booking = booking_of(resource)
        buffet = orders.filter_map { |row| row[:buffet_ends_at] }.min
        {
          id: resource.prefixed_id, area_id: area_refs[resource.area_id], name: resource.name, kind: resource.kind,
          capacity: resource.capacity, shape: resource.shape, x: resource.x, y: resource.y, w: resource.w, h: resource.h,
          rotation: resource.rotation, manual_status: resource.manual_status,
          state: state_of(resource, orders, booking, now, timed),
          timed: timed,
          next_reservation: booking, buffet_ends_at: buffet&.iso8601,
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
              buffet_ends_at: row[:buffet_ends_at]&.iso8601,
              edited_after_prebill: row[:edited_after_prebill], pending_kitchen_items: row[:kitchen]&.dig(:pending) || 0,
              unsent_kitchen_items: row[:unsent] }
          end
        }
      end

      # Prefixed ids are computed from the key; no record is loaded for them.
      def workspace_ref(id)
        "#{Workspace._prefix_id_prefix}_#{Spree::PrefixedId::SQIDS.encode([id])}"
      end

      def state_of(resource, orders, booking = nil, now = nil, timed = nil)
        return 'out_of_service' if resource.manual_status == 'out_of_service'
        if orders.empty?
          return 'cleaning' if resource.manual_status == 'cleaning'
          return 'reserved' if booking && now && Time.iso8601(booking[:starts_at]) <= now + RESERVED_AHEAD

          return 'available'
        end
        return 'payment_requested' if orders.any? { |row| row[:payment_requested] }
        return 'prebilled' if orders.any? { |row| row[:prebilled] }
        return 'ending_soon' if timed&.dig(:ending_soon) || timed&.dig(:package_ended)
        return 'waiting_long' if orders.any? { |row| row[:kitchen]&.dig(:late) }
        return 'playing' if timed && TimedSession::ACTIVE_STATUSES.include?(timed[:status])
        return 'ordered' if orders.any? { |row| row[:kitchen]&.dig(:sent) }

        'occupied'
      end
    end
  end
end

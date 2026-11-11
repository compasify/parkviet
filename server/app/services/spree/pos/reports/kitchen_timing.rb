# frozen_string_literal: true

module Spree
  module Pos
    module Reports
      # How long the kitchen of a branch took, from each send to ready, for
      # the items that became ready between `from` and `to`: the average and
      # the 90th percentile in seconds and the number of late items (past
      # their station's red threshold), by station, by dish and by hour of
      # the day in the branch's timezone. Recalled items count by their
      # last ready; voided items never became ready and do not count.
      module KitchenTiming
        GROUPS = {
          'station' => 'spree_pos_kitchen_stations.name',
          'dish' => 'spree_pos_kitchen_ticket_items.name',
          'hour' => nil
        }.freeze

        module_function

        def call(branch:, from:, to:)
          GROUPS.keys.index_with { |group| rows(branch, from, to, group) }.merge(
            'branch_id' => branch.prefixed_id, 'timezone' => branch.timezone,
            'from' => from.iso8601, 'to' => to.iso8601, 'summary' => summary(branch, from, to)
          )
        end

        def scope(branch, from, to)
          KitchenTicketItem.joins(kitchen_ticket: :kitchen_station).
            where(spree_pos_kitchen_tickets: { branch_id: branch.id, kind: 'fire' }).
            where(spree_pos_kitchen_ticket_items: { ready_at: from...to }).
            where.not(spree_pos_kitchen_ticket_items: { prep_seconds: nil })
        end

        def measures
          [Arel.sql('COUNT(*)'), Arel.sql('AVG(spree_pos_kitchen_ticket_items.prep_seconds)'),
           Arel.sql('PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY spree_pos_kitchen_ticket_items.prep_seconds)'),
           Arel.sql('COUNT(*) FILTER (WHERE spree_pos_kitchen_ticket_items.late)')]
        end

        def rows(branch, from, to, group)
          column = GROUPS[group] || hour_sql(branch)
          scope(branch, from, to).group(Arel.sql(column)).order(Arel.sql(column)).
            pluck(Arel.sql(column), *measures).map do |key, count, average, p90, late|
              row(count, average, p90, late).merge('key' => group == 'hour' ? key.to_i : key)
            end
        end

        def summary(branch, from, to)
          count, average, p90, late = scope(branch, from, to).pluck(*measures).first
          row(count, average, p90, late)
        end

        def row(count, average, p90, late)
          { 'items' => count.to_i, 'average_seconds' => average&.round&.to_i, 'p90_seconds' => p90&.round&.to_i, 'late_items' => late.to_i }
        end

        def hour_sql(branch)
          zone = ActiveRecord::Base.connection.quote(ActiveSupport::TimeZone[branch.timezone]&.tzinfo&.name || 'UTC')
          "EXTRACT(HOUR FROM spree_pos_kitchen_ticket_items.ready_at AT TIME ZONE 'UTC' AT TIME ZONE #{zone})"
        end
      end
    end
  end
end

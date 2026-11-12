# frozen_string_literal: true

module Spree
  module Pos
    module Reports
      # Coach commission by business date, bus operator and plate: visits,
      # guests, the visits' revenue, commission, what was paid out and what
      # is still owed, and the commission as a share of revenue (a high
      # share for one operator points at padded guest counts). Read from the
      # closed and paid visits' snapshots; open and voided visits are left
      # out, and a cash payout counts as paid once its cash out request was
      # confirmed. Drivers' names and phone numbers are never in it. Readers
      # without branch-wide report access see the visits they opened.
      class VehicleCommissions < Grouped
        COLUMNS = %w[business_date bus_operator plate visits guests revenue commission_amount paid unpaid commission_rate].freeze

        def self.filter_keys
          super + %w[bus_operator_id]
        end

        def summary
          rows = all_rows
          totals = %i[revenue commission_amount paid unpaid].to_h { |key| [key, rows.sum { |row| BigDecimal(row[key]) }] }
          { visits: rows.sum { |row| row[:visits] }, guests: rows.sum { |row| row[:guests] },
            **totals.transform_values { |value| money(value) }, commission_rate: rate(totals[:commission_amount], totals[:revenue]) }
        end

        private

        def build_rows
          visits.includes(:bus_operator, :cash_movement_request).order(:business_date, :plate, :id).
            group_by { |visit| [visit.business_date, visit.bus_operator&.name, visit.plate] }.
            map do |(date, operator, plate), list|
              revenue = list.sum { |visit| visit.revenue_amount || 0 }
              commission = list.sum(&:commission_amount)
              paid = list.select { |visit| visit.payout_status == 'paid' }.sum(&:commission_amount)
              { business_date: date.iso8601, bus_operator: operator, plate: plate, visits: list.size,
                guests: list.sum(&:guest_count), revenue: money(revenue), commission_amount: money(commission), paid: money(paid),
                unpaid: money(commission - paid), commission_rate: rate(commission, revenue) }
            end
        end

        def visits
          relation = VehicleVisit.where(branch_id: branch.id, status: %w[closed paid], business_date: filters.from..filters.to)
          relation = relation.where(opened_by_id: scope.staff.id) unless scope.full?
          relation = relation.where(opened_by_id: filters.cashier.id) if filters.cashier
          if filters['bus_operator_id']
            operator = BusOperator.locate(BusOperator.for_store(scope.store), filters['bus_operator_id'])
            raise ActiveRecord::RecordNotFound if operator.nil?

            relation = relation.where(bus_operator_id: operator.id)
          end
          relation
        end

        # Percent with two decimals; empty when the visits sold nothing.
        def rate(commission, revenue)
          return nil unless revenue.to_d.positive?

          (commission.to_d * 100 / revenue.to_d).round(2).to_s('F')
        end
      end
    end
  end
end

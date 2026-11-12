# frozen_string_literal: true

module Spree
  module Pos
    module Reports
      # Hours served by each attendant per business day, from the
      # attendants book (AttendantAssignment): rooms served, assignments and
      # minutes (an assignment still open counts up to now). It moves no
      # money and none of it is on a bill. The cashier filter picks one
      # attendant; readers without branch-wide report access see their own
      # hours. Not exported.
      class Attendants < Grouped
        COLUMNS = %w[business_date staff_id staff_name rooms assignments minutes hours].freeze

        def summary
          rows = all_rows
          minutes = rows.sum { |row| row[:minutes] }
          { assignments: rows.sum { |row| row[:assignments] }, minutes: minutes, hours: hours(minutes) }
        end

        private

        def build_rows
          now = Workspace.database_now
          assignments.includes(:staff).order(:business_date, :staff_id, :id).
            group_by { |row| [row.business_date, row.staff] }.
            map do |(date, staff), list|
              minutes = list.sum { |row| row.minutes(now) }
              { business_date: date.iso8601, staff_id: staff.prefixed_id, staff_name: StaffName.call(staff),
                rooms: list.map(&:resource_id).uniq.size, assignments: list.size, minutes: minutes, hours: hours(minutes) }
            end
        end

        def assignments
          relation = AttendantAssignment.where(branch_id: branch.id, business_date: filters.from..filters.to)
          relation = relation.where(staff_id: scope.staff.id) unless scope.full?
          relation = relation.where(staff_id: filters.cashier.id) if filters.cashier
          relation
        end

        def hours(minutes)
          (BigDecimal(minutes) / 60).round(2).to_s('F')
        end
      end
    end
  end
end

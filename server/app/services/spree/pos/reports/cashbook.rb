# frozen_string_literal: true

module Spree
  module Pos
    module Reports
      # Drawer cash per shift: every CashMovement with the running expected
      # cash (opening float + movements so far). Shifts are selected when they
      # were open at any time in the date range, so an overnight shift shows
      # under both days with its whole, exact running balance. Readers without
      # branch report access see only their own shifts, and an open one only
      # after its drawer was counted, which keeps the count blind.
      class Cashbook < Base
        COLUMNS = %w[shift_id register cashier at kind category amount running_expected reason evidence_reference
                     source_id currency].freeze
        RUNNING = 'spree_pos_shifts.opening_float + SUM(spree_pos_cash_movements.amount) OVER ' \
                  '(PARTITION BY spree_pos_cash_movements.shift_id ORDER BY spree_pos_cash_movements.id) AS running_expected'

        def relation
          inner = CashMovement.joins(:shift).where(shift_id: selected_shifts.select(:id)).
                  select('spree_pos_cash_movements.*', RUNNING)
          CashMovement.from(inner, :spree_pos_cash_movements).order(:shift_id, :id)
        end

        def total_count
          CashMovement.where(shift_id: selected_shifts.select(:id)).count
        end

        def rows(records)
          ActiveRecord::Associations::Preloader.new(
            records: records, associations: [{ shift: %i[owner register] }, { received_funds: :collection },
                                             :liability_payout, :refund_request, :cash_reconciliation]
          ).call
          records.map do |movement|
            { shift_id: movement.shift.prefixed_id, register: movement.shift.register&.code,
              cashier: StaffName.call(movement.shift.owner), at: local(movement.created_at), kind: movement.kind,
              category: movement.category, amount: money(movement.amount),
              running_expected: money(movement.read_attribute(:running_expected)), reason: movement.reason,
              evidence_reference: movement.evidence_reference, source_id: source_id(movement), currency: movement.currency }
          end
        end

        SHIFT_PAGE = 50

        def self.filter_keys
          super + ['shift_page']
        end

        # One line per selected shift (a page of SHIFT_PAGE, with the true
        # count): opening float, flows, expected, and the closing count and
        # variance once closed. Flows come from one grouped query per page.
        def summary
          total = selected_shifts.count
          page = shift_page
          shifts = selected_shifts.includes(:owner, :register, :closure).order(:opened_at, :id).
                   offset((page - 1) * SHIFT_PAGE).limit(SHIFT_PAGE).to_a
          flows = CashMovement.where(shift_id: shifts.map(&:id)).group(:shift_id).
                  pluck(:shift_id, Arel.sql('SUM(CASE WHEN amount > 0 THEN amount ELSE 0 END)'),
                        Arel.sql('SUM(CASE WHEN amount < 0 THEN -amount ELSE 0 END)'), Arel.sql('COUNT(*)')).
                  to_h { |(id, inflow, outflow, count)| [id, [inflow, outflow, count]] }
          { shifts: shifts.map { |shift| shift_line(shift, flows.fetch(shift.id, [0, 0, 0])) }, shift_count: total,
            shift_page: page, shift_pages: (total.to_f / SHIFT_PAGE).ceil }
        end

        private

        def shift_page
          value = filters['shift_page']
          return 1 if value.nil?
          raise Filters::Invalid, 'shift_page must be a positive number.' unless value.match?(/\A[1-9]\d{0,5}\z/)

          value.to_i
        end

        # Without branch report access only one's own shifts, and none whose
        # drawer has not been counted yet: the blind count stays blind.
        def selected_shifts
          shifts = scope.shifts
          shifts = shifts.where.not(id: scope.blind_shift_ids) unless scope.full?
          shifts = shifts.where(register_id: filters.register.id) if filters.register
          shifts = shifts.where(id: filters.shift.id) if filters.shift
          shifts = shifts.where(owner_id: filters.cashier.id) if filters.cashier
          range = filters.range
          return shifts if range.nil? || filters.shift

          shifts.where('spree_pos_shifts.opened_at < ?', range.end).
            where('spree_pos_shifts.closed_at IS NULL OR spree_pos_shifts.closed_at >= ?', range.begin)
        end

        def shift_line(shift, (inflow, outflow, count))
          closure = shift.closure
          inflow = BigDecimal(inflow.to_s)
          outflow = BigDecimal(outflow.to_s)
          {
            opening_float: shift.opening_float.to_s('F'), inflow_total: inflow.to_s('F'), outflow_total: outflow.to_s('F'),
            expected: (shift.opening_float + inflow - outflow).to_s('F'), movement_count: count.to_i
          }.merge(
            shift_id: shift.prefixed_id, register: shift.register&.code, cashier: StaffName.call(shift.owner),
            status: shift.status, opened_at: local(shift.opened_at), closed_at: local(shift.closed_at),
            counted: closure&.counted&.to_s('F'), variance: closure&.variance&.to_s('F'),
            closure_id: closure&.prefixed_id
          )
        end

        def source_id(movement)
          movement.received_funds&.prefixed_id || movement.liability_payout&.prefixed_id ||
            movement.refund_request&.prefixed_id || movement.cash_reconciliation&.prefixed_id || movement.prefixed_id
        end
      end
    end
  end
end

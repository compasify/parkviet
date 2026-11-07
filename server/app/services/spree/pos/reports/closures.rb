# frozen_string_literal: true

module Spree
  module Pos
    module Reports
      # Closed shifts by close time with the immutable snapshot: expected,
      # counted, variance and its reason and approver, plus how much of an
      # overage later late-cash reconciliations explained.
      class Closures < Base
        COLUMNS = %w[closure_id shift_id register cashier opened_at closed_at opening_float expected counted variance
                     reason approver reconciled currency].freeze

        def relation
          base.order(closed_at: :desc, id: :desc)
        end

        def rows(records)
          ActiveRecord::Associations::Preloader.new(records: records, associations: [:register, :approver, { shift: :owner }]).call
          reconciled = CashReconciliation.where(shift_closure_id: records.map(&:id)).group(:shift_closure_id).sum(:amount)
          records.map do |closure|
            { closure_id: closure.prefixed_id, shift_id: closure.shift.prefixed_id, register: closure.register&.code,
              cashier: StaffName.call(closure.shift.owner), opened_at: local(closure.opened_at),
              closed_at: local(closure.closed_at), opening_float: money(closure.opening_float),
              expected: money(closure.expected), counted: money(closure.counted), variance: money(closure.variance),
              reason: closure.reason, approver: StaffName.call(closure.approver),
              reconciled: money(reconciled[closure.id]), currency: closure.currency }
          end
        end

        def summary
          { closures: base.count, variance_total: money(base.sum(:variance)),
            overage_total: money(base.where('variance > 0').sum(:variance)),
            shortage_total: money(base.where('variance < 0').sum(:variance)) }
        end

        private

        def base
          relation = ShiftClosure.for_store(scope.store).where(branch_id: branch.id, shift_id: scope.shifts.select(:id))
          relation = relation.where(register_id: filters.register.id) if filters.register
          relation = relation.where(shift_id: filters.shift.id) if filters.shift
          relation = relation.where(shift_id: Shift.where(owner_id: filters.cashier.id).select(:id)) if filters.cashier
          within_range(relation, 'spree_pos_shift_closures.closed_at')
        end
      end
    end
  end
end

# frozen_string_literal: true

module Spree
  module Pos
    module Reports
      # Canteen meals by business date, meal time, counter and sponsor, and
      # the refused attempts by reason (`result`). Read from the meal swipe
      # rows; an accepted meal whose order was canceled or lost its eater is
      # not counted. Readers without branch-wide report access see the
      # meals they recorded.
      class Meals < Grouped
        COLUMNS = %w[business_date meal_window register sponsor result meals].freeze
        ENUMS = { 'result' => MealSwipe::RESULTS }.freeze

        def summary
          rows = all_rows
          ok = rows.select { |row| row[:result] == 'ok' }.sum { |row| row[:meals] }
          refused = rows.reject { |row| row[:result] == 'ok' }.group_by { |row| row[:result] }.
                    transform_values { |list| list.sum { |row| row[:meals] } }
          { meals: ok, refused: refused }
        end

        private

        def build_rows
          relation = swipes
          relation = relation.where(result: filters['result']) if filters['result']
          grouped = relation.left_joins(:workspace, meal_account: :meal_sponsor).
                    joins('LEFT JOIN spree_pos_registers ON spree_pos_registers.id = spree_pos_workspaces.register_id').
                    group('spree_pos_meal_swipes.business_date', 'spree_pos_meal_swipes.meal_window', 'spree_pos_registers.name',
                          'spree_pos_meal_sponsors.name', 'spree_pos_meal_swipes.result').
                    order('spree_pos_meal_swipes.business_date DESC', 'spree_pos_meal_swipes.meal_window', 'spree_pos_registers.name',
                          'spree_pos_meal_sponsors.name', 'spree_pos_meal_swipes.result').
                    pluck(Arel.sql('spree_pos_meal_swipes.business_date'), Arel.sql('spree_pos_meal_swipes.meal_window'),
                          Arel.sql('spree_pos_registers.name'), Arel.sql('spree_pos_meal_sponsors.name'),
                          Arel.sql('spree_pos_meal_swipes.result'), Arel.sql('COUNT(*)'))
          grouped.map do |date, window, register, sponsor, result, count|
            { business_date: date.iso8601, meal_window: window, register: register, sponsor: sponsor, result: result,
              meals: count.to_i }
          end
        end

        # Accepted meals that still count, and every refusal.
        def swipes
          base = MealSwipe.where(branch_id: branch.id, business_date: filters.from..filters.to)
          base = base.where(actor_id: scope.staff.id) unless scope.full?
          base = base.where(actor_id: filters.cashier.id) if filters.cashier
          if filters.register || filters.shift
            scoped = Workspace.where(branch_id: branch.id)
            scoped = scoped.where(register_id: filters.register.id) if filters.register
            scoped = scoped.where(shift_id: filters.shift.id) if filters.shift
            base = base.where(workspace_id: scoped.select(:id))
          end
          base.where.not(result: 'ok').or(base.where(id: MealSwipe.counting.select(:id)))
        end
      end
    end
  end
end

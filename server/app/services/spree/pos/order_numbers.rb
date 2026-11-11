# frozen_string_literal: true

module Spree
  module Pos
    # Call numbers of a counter-service branch: 1, 2, 3… per branch and
    # business date, so a shop open past midnight keeps counting until its
    # cutoff. An order gets its number the first time it is sent to the
    # kitchen or completed and keeps it, even when canceled, so no other
    # customer is ever called by it.
    module OrderNumbers
      MODULE = 'fnb.order_number'

      module_function

      # The workspace's call number, handed out now if it has none yet and
      # the branch runs `fnb.order_number`; nil otherwise. The caller holds
      # the workspace lock.
      def assign!(workspace)
        return workspace.order_number if workspace.order_number
        return nil unless ModulePolicy.enabled?(workspace.branch, MODULE)

        workspace.update!(order_number: next_value!(workspace.branch_id, workspace.business_date))
        workspace.order_number
      end

      # One atomic upsert: concurrent callers wait on the counter row and
      # each reads its own value. No application lock.
      def next_value!(branch_id, business_date)
        now = Time.current
        sql = OrderNumberCounter.sanitize_sql_array([<<~SQL.squish, branch_id, business_date, now, now])
          INSERT INTO spree_pos_order_number_counters (branch_id, business_date, last_value, created_at, updated_at)
          VALUES (?, ?, 1, ?, ?)
          ON CONFLICT (branch_id, business_date)
          DO UPDATE SET last_value = spree_pos_order_number_counters.last_value + 1, updated_at = EXCLUDED.updated_at
          RETURNING last_value
        SQL
        OrderNumberCounter.connection.select_value(sql).to_i
      end
    end
  end
end

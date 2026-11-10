# frozen_string_literal: true

# Service mode is a value on the draft (retail stays counter). Business date
# is stamped once from the branch cutoff and is never recomputed.
class AddServiceModeAndBusinessDateToPosWorkspaces < ActiveRecord::Migration[8.1]
  def up
    add_column :spree_pos_workspaces, :service_mode, :string, null: false, default: 'counter'
    add_check_constraint :spree_pos_workspaces,
                         "service_mode IN ('counter', 'dine_in', 'takeaway', 'delivery', 'tab', 'timed')",
                         name: 'chk_pos_workspace_service_mode'
    add_column :spree_pos_workspaces, :business_date, :date
    say_with_time 'backfill workspace business dates' do
      self.class.backfill!(connection)
    end
    change_column_null :spree_pos_workspaces, :business_date, false
    add_index :spree_pos_workspaces, %i[branch_id business_date], name: 'idx_pos_workspaces_branch_business_date'
  end

  def down
    remove_index :spree_pos_workspaces, name: 'idx_pos_workspaces_branch_business_date'
    remove_column :spree_pos_workspaces, :business_date
    remove_check_constraint :spree_pos_workspaces, name: 'chk_pos_workspace_service_mode'
    remove_column :spree_pos_workspaces, :service_mode
  end

  # One thousand rows at a time. A time before the branch cutoff belongs to
  # the previous date in the branch timezone.
  def self.backfill!(connection = ActiveRecord::Base.connection)
    last = 0
    loop do
      ids = connection.select_values(<<~SQL.squish)
        SELECT id FROM spree_pos_workspaces WHERE id > #{last.to_i} ORDER BY id LIMIT 1000
      SQL
      break if ids.empty?

      connection.execute(backfill_sql(ids.map(&:to_i)))
      last = ids.last.to_i
    end
  end

  def self.backfill_sql(ids)
    list = ids.map(&:to_i).join(', ')
    <<~SQL.squish
      UPDATE spree_pos_workspaces AS w
      SET business_date = CASE
        WHEN (w.created_at AT TIME ZONE b.timezone)::time < b.business_day_cutoff
          THEN ((w.created_at AT TIME ZONE b.timezone)::date - 1)
        ELSE (w.created_at AT TIME ZONE b.timezone)::date
      END
      FROM spree_pos_branches AS b
      WHERE w.branch_id = b.id AND w.id IN (#{list})
    SQL
  end
end

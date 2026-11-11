# frozen_string_literal: true

# The business date of a shift is the date it was opened, using the same
# cutoff as a sale. It is not the calendar date of closed_at.
class AddBusinessDateToPosShifts < ActiveRecord::Migration[8.1]
  def up
    add_column :spree_pos_shifts, :business_date, :date
    say_with_time 'backfill shift business dates' do
      self.class.backfill!(connection)
    end
    change_column_null :spree_pos_shifts, :business_date, false
    add_index :spree_pos_shifts, %i[branch_id business_date], name: 'idx_pos_shifts_branch_business_date'
  end

  def down
    remove_index :spree_pos_shifts, name: 'idx_pos_shifts_branch_business_date'
    remove_column :spree_pos_shifts, :business_date
  end

  def self.backfill!(connection = ActiveRecord::Base.connection)
    last = 0
    loop do
      ids = connection.select_values(<<~SQL.squish)
        SELECT id FROM spree_pos_shifts WHERE id > #{last.to_i} ORDER BY id LIMIT 1000
      SQL
      break if ids.empty?

      connection.execute(backfill_sql(ids.map(&:to_i)))
      last = ids.last.to_i
    end
  end

  def self.backfill_sql(ids)
    list = ids.map(&:to_i).join(', ')
    <<~SQL.squish
      UPDATE spree_pos_shifts AS s
      SET business_date = CASE
        WHEN (s.opened_at AT TIME ZONE 'UTC' AT TIME ZONE b.timezone)::time < b.business_day_cutoff
          THEN ((s.opened_at AT TIME ZONE 'UTC' AT TIME ZONE b.timezone)::date - 1)
        ELSE (s.opened_at AT TIME ZONE 'UTC' AT TIME ZONE b.timezone)::date
      END
      FROM spree_pos_branches AS b
      WHERE s.branch_id = b.id AND s.id IN (#{list})
    SQL
  end
end

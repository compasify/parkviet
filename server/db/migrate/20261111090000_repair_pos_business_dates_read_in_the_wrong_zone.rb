# frozen_string_literal: true

# The first business-date backfill read UTC timestamps as if they were branch
# local time. Only rows still holding that wrong value change: a date stamped
# correctly when the row was created never matches it.
class RepairPosBusinessDatesReadInTheWrongZone < ActiveRecord::Migration[8.1]
  TABLES = { 'spree_pos_workspaces' => 'created_at', 'spree_pos_shifts' => 'opened_at' }.freeze

  def up
    say_with_time('repair business dates') { self.class.repair!(connection) }
  end

  def down; end

  def self.repair!(connection = ActiveRecord::Base.connection)
    TABLES.sum do |table, column|
      wrong = business_date("(r.#{column} AT TIME ZONE b.timezone)")
      right = business_date("(r.#{column} AT TIME ZONE 'UTC' AT TIME ZONE b.timezone)")
      connection.update(<<~SQL.squish)
        UPDATE #{table} AS r SET business_date = #{right}
        FROM spree_pos_branches AS b
        WHERE r.branch_id = b.id AND r.business_date = #{wrong} AND #{wrong} <> #{right}
      SQL
    end
  end

  def self.business_date(local)
    "(CASE WHEN #{local}::time < b.business_day_cutoff THEN (#{local}::date - 1) ELSE #{local}::date END)"
  end
end

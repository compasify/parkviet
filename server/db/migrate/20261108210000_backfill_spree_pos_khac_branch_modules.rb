# frozen_string_literal: true

# Branches created through POST /branches between the business-profiles
# migration and Branches::Create got the `khac` profile (column default) but
# no module rows, i.e. every module off. `khac` means all three retail
# modules, so give exactly those branches the rows the backfill gave every
# branch that existed then. A branch with any module row already made its own
# choice and is left alone; so is a branch of another profile. Plain SQL,
# idempotent.
class BackfillSpreePosKhacBranchModules < ActiveRecord::Migration[8.1]
  MODULES = %w[retail.units retail.measured retail.traceability].freeze
  PROFILE = 'khac'

  def self.backfill_sql
    modules = MODULES.map { |key| "('#{key}')" }.join(', ')
    <<~SQL.squish
      INSERT INTO spree_pos_branch_modules (store_id, branch_id, module_key, enabled, reason, created_at, updated_at)
      SELECT b.store_id, b.id, m.module_key, TRUE, 'backfill', NOW(), NOW()
      FROM spree_pos_branches b CROSS JOIN (VALUES #{modules}) AS m(module_key)
      WHERE b.profile_key = '#{PROFILE}'
        AND NOT EXISTS (SELECT 1 FROM spree_pos_branch_modules x WHERE x.branch_id = b.id)
      ON CONFLICT (branch_id, module_key) DO NOTHING
    SQL
  end

  def up
    execute(self.class.backfill_sql)
  end

  # Data only: the rows cannot be told apart from the first backfill's.
  def down; end
end

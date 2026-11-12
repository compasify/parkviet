# frozen_string_literal: true

# Prices of play time. A branch has one active rate plan per kind of room or
# table (`resource_type_code`); its rules price an hour by time of day and
# by kind of day (weekday, weekend, holiday). A plan already used by a play
# segment is never changed: saving it archives it and writes the next
# version, so segments keep the prices they were played at. Special days
# mark a branch's holidays, with a surcharge on the weekend price when the
# plan has no holiday prices of its own.
class CreateSpreePosRatePlansAndRules < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_rate_plans do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }, index: false
      t.string :name, null: false, limit: 120
      t.string :resource_type_code, null: false, limit: 40
      # The service sold for the time: its tax category is the line's tax.
      t.references :variant, null: false, foreign_key: { to_table: :spree_variants }
      t.integer :block_minutes, null: false, default: 15
      t.integer :grace_minutes, null: false, default: 5
      t.integer :minimum_minutes, null: false, default: 0
      t.string :status, null: false, limit: 16, default: 'active'
      t.integer :version, null: false, default: 1
      # The plan this version replaced, for the history of a plan.
      t.references :previous, foreign_key: { to_table: :spree_pos_rate_plans }, index: false
      t.timestamps
    end
    add_index :spree_pos_rate_plans, %i[branch_id resource_type_code], unique: true, where: "status = 'active'",
                                                                         name: 'idx_pos_rate_plans_active_type'
    add_index :spree_pos_rate_plans, %i[branch_id status], name: 'idx_pos_rate_plans_branch'
    add_check_constraint :spree_pos_rate_plans,
                         "status IN ('active', 'archived') AND block_minutes BETWEEN 1 AND 60 AND " \
                         'grace_minutes >= 0 AND grace_minutes <= block_minutes AND minimum_minutes BETWEEN 0 AND 1440 AND version >= 1',
                         name: 'chk_pos_rate_plans_values'

    create_table :spree_pos_rate_rules do |t|
      t.references :rate_plan, null: false, foreign_key: { to_table: :spree_pos_rate_plans, on_delete: :cascade }
      t.string :day_type, null: false, limit: 16
      # Minutes of the day, 0 to 1440; an end before the start runs past midnight.
      t.integer :start_minute, null: false
      t.integer :end_minute, null: false
      t.decimal :price_per_hour, precision: 19, scale: 4, null: false
      t.string :label, limit: 40
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_check_constraint :spree_pos_rate_rules,
                         "day_type IN ('weekday', 'weekend', 'holiday') AND start_minute BETWEEN 0 AND 1439 AND " \
                         'end_minute BETWEEN 1 AND 1440 AND end_minute <> start_minute AND price_per_hour >= 0',
                         name: 'chk_pos_rate_rules_values'

    create_table :spree_pos_special_days do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }, index: false
      t.date :date, null: false
      t.string :name, null: false, limit: 120
      t.decimal :holiday_surcharge_percent, precision: 5, scale: 2
      t.timestamps
    end
    add_index :spree_pos_special_days, %i[branch_id date], unique: true, name: 'idx_pos_special_days_branch_date'
    add_check_constraint :spree_pos_special_days,
                         'holiday_surcharge_percent IS NULL OR holiday_surcharge_percent BETWEEN 0 AND 500',
                         name: 'chk_pos_special_days_surcharge'

    # Days of the week priced as the weekend, 0 = Sunday to 6 = Saturday.
    add_column :spree_pos_branches, :weekend_days, :jsonb, null: false, default: [6, 0]
    add_check_constraint :spree_pos_branches, "jsonb_typeof(weekend_days) = 'array'", name: 'chk_pos_branches_weekend_days'
  end
end

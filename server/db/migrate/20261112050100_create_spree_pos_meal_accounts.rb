# frozen_string_literal: true

# A canteen's meal accounts. A sponsor (company or school) is a customer
# with a credit account that pays for meals in full or in part; an account
# belongs to one eater, is found by the employee or student code, carries a
# prepaid wallet and its daily meal rules. Every meal recorded at the
# counter, accepted or refused, is one swipe row.
class CreateSpreePosMealAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_meal_sponsors do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.references :customer_profile, null: false, foreign_key: { to_table: :spree_pos_customers }, index: false
      t.references :credit_account, foreign_key: { to_table: :spree_pos_credit_accounts }
      t.string :name, null: false, limit: 120
      t.integer :statement_day, null: false, default: 1
      t.string :subsidy_mode, null: false, limit: 16, default: 'none'
      t.decimal :subsidy_value, precision: 19, scale: 4, null: false, default: 0
      t.decimal :subsidy_daily_cap, precision: 19, scale: 4
      t.string :status, null: false, limit: 16, default: 'active'
      t.timestamps
    end
    add_index :spree_pos_meal_sponsors, %i[store_id customer_profile_id], unique: true, name: 'idx_pos_meal_sponsors_customer'
    add_check_constraint :spree_pos_meal_sponsors,
                         "subsidy_mode IN ('none', 'fixed', 'percent') AND status IN ('active', 'suspended') AND " \
                         'statement_day BETWEEN 1 AND 28 AND subsidy_value >= 0 AND ' \
                         "(subsidy_mode <> 'percent' OR subsidy_value <= 100) AND " \
                         '(subsidy_daily_cap IS NULL OR subsidy_daily_cap >= 0)',
                         name: 'chk_pos_meal_sponsors_values'

    create_table :spree_pos_meal_accounts do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.references :customer_profile, null: false, foreign_key: { to_table: :spree_pos_customers }
      t.references :meal_sponsor, foreign_key: { to_table: :spree_pos_meal_sponsors }
      t.references :stored_value_account, null: false, foreign_key: { to_table: :spree_pos_stored_value_accounts },
                                          index: { unique: true }
      t.string :employee_code, null: false, limit: 32
      t.string :group_label, limit: 120
      t.integer :daily_meal_limit
      t.jsonb :meal_windows, null: false, default: []
      t.string :pay_mode, null: false, limit: 16, default: 'wallet'
      t.decimal :low_balance_threshold, precision: 19, scale: 4
      t.string :status, null: false, limit: 16, default: 'active'
      t.integer :revision, null: false, default: 0
      t.timestamps
    end
    add_index :spree_pos_meal_accounts, %i[store_id employee_code], unique: true, name: 'idx_pos_meal_accounts_code'
    add_check_constraint :spree_pos_meal_accounts,
                         "pay_mode IN ('wallet', 'sponsor', 'sponsor_subsidy') AND status IN ('active', 'locked') AND " \
                         "(pay_mode = 'wallet' OR meal_sponsor_id IS NOT NULL) AND " \
                         '(daily_meal_limit IS NULL OR daily_meal_limit BETWEEN 0 AND 20) AND ' \
                         '(low_balance_threshold IS NULL OR low_balance_threshold >= 0)',
                         name: 'chk_pos_meal_accounts_values'

    create_table :spree_pos_meal_swipes do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.references :meal_account, foreign_key: { to_table: :spree_pos_meal_accounts }, index: false
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }, index: false
      t.references :workspace, foreign_key: { to_table: :spree_pos_workspaces }
      t.references :actor, null: false, foreign_key: { to_table: :spree_admin_users }, index: false
      t.string :input_method, null: false, limit: 16
      t.date :business_date, null: false
      t.string :meal_window, limit: 32
      t.string :result, null: false, limit: 16
      t.datetime :created_at, null: false
    end
    add_index :spree_pos_meal_swipes, %i[meal_account_id business_date], name: 'idx_pos_meal_swipes_account_day'
    add_index :spree_pos_meal_swipes, %i[branch_id business_date], name: 'idx_pos_meal_swipes_branch_day'
    add_check_constraint :spree_pos_meal_swipes,
                         "input_method IN ('code', 'search') AND " \
                         "result IN ('ok', 'duplicate', 'limit', 'window', 'revoked', 'unknown') AND " \
                         "(result = 'unknown' OR meal_account_id IS NOT NULL)",
                         name: 'chk_pos_meal_swipes_values'
  end
end

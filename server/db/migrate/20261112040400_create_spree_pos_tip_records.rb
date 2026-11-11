# frozen_string_literal: true

# A tip is money a guest hands over on top of the bill. It stays off the
# order (and so off the VAT invoice): the receipt keeps it unapplied, and
# its tip record says whose it is until it is paid out to the staff.
class CreateSpreePosTipRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_tip_records do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }, index: false
      t.references :workspace, null: false, foreign_key: { to_table: :spree_pos_workspaces }
      t.references :received_funds, null: false, foreign_key: { to_table: :spree_pos_received_funds }, index: { unique: true }
      t.references :shift, null: false, foreign_key: { to_table: :spree_pos_shifts }
      t.decimal :amount, precision: 19, scale: 4, null: false
      t.string :currency, null: false, limit: 16
      t.date :business_date, null: false
      t.string :status, null: false, default: 'held'
      t.references :liability_payout, foreign_key: { to_table: :spree_pos_liability_payouts }
      t.datetime :paid_out_at
      t.timestamps
    end
    add_index :spree_pos_tip_records, %i[branch_id business_date status], name: 'idx_pos_tip_records_day'
    add_check_constraint :spree_pos_tip_records, "amount > 0 AND status IN ('held', 'paid_out')", name: 'chk_pos_tip_records_values'

    create_table :spree_pos_tip_split_rules do |t|
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }, index: { unique: true }
      t.string :mode, null: false, default: 'equal'
      t.jsonb :role_codes, null: false, default: []
      t.timestamps
    end
    add_check_constraint :spree_pos_tip_split_rules, "mode IN ('equal', 'by_hours', 'manual')", name: 'chk_pos_tip_split_rules_mode'

    # Tips stay out of revenue until the accountant says otherwise.
    add_column :spree_pos_branches, :tips_as_revenue, :boolean, null: false, default: false
  end
end

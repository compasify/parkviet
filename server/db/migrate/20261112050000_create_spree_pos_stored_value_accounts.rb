# frozen_string_literal: true

# Prepaid value a customer keeps with the store: money left for later meals,
# not revenue. The balance is the sum of an append-only ledger; every writer
# locks the account row first. A top-up points at the receipt that brought
# the money in, a spend at the allocation that put it on an order, and a
# refund at the payout that gives it back.
class CreateSpreePosStoredValueAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_stored_value_accounts do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.references :customer_profile, null: false, foreign_key: { to_table: :spree_pos_customers }
      t.string :kind, null: false, limit: 16
      t.string :currency, null: false, limit: 16
      t.string :status, null: false, limit: 16, default: 'active'
      t.timestamps
    end
    add_index :spree_pos_stored_value_accounts, %i[store_id kind], name: 'idx_pos_stored_value_accounts_store'
    add_check_constraint :spree_pos_stored_value_accounts, "kind IN ('meal') AND status IN ('active', 'closed')",
                         name: 'chk_pos_stored_value_accounts_values'

    create_table :spree_pos_stored_value_entries do |t|
      t.references :stored_value_account, null: false, foreign_key: { to_table: :spree_pos_stored_value_accounts }, index: false
      t.string :kind, null: false, limit: 16
      t.decimal :amount, precision: 19, scale: 4, null: false
      t.integer :minutes
      t.references :received_funds, foreign_key: { to_table: :spree_pos_received_funds }
      t.references :funds_allocation, foreign_key: { to_table: :spree_pos_funds_allocations }, index: { unique: true }
      t.references :liability_payout, foreign_key: { to_table: :spree_pos_liability_payouts }, index: { unique: true }
      t.references :workspace, foreign_key: { to_table: :spree_pos_workspaces }
      t.references :actor, null: false, foreign_key: { to_table: :spree_admin_users }, index: false
      t.string :note, limit: 255
      t.datetime :created_at, null: false
    end
    add_index :spree_pos_stored_value_entries, %i[stored_value_account_id id], name: 'idx_pos_stored_value_entries_account'
    # The sign follows the kind: money in is positive, money out negative.
    add_check_constraint :spree_pos_stored_value_entries,
                         "(kind = 'top_up' AND amount > 0 AND received_funds_id IS NOT NULL) OR " \
                         "(kind = 'spend' AND amount < 0 AND funds_allocation_id IS NOT NULL) OR " \
                         "(kind = 'refund' AND amount < 0 AND liability_payout_id IS NOT NULL) OR " \
                         "(kind = 'adjust' AND amount <> 0)",
                         name: 'chk_pos_stored_value_entries_kind'
  end
end

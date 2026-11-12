# frozen_string_literal: true

# Prepaid cards beside the meal wallets: a money card (`money`) pays
# orders, a minutes card (`minutes`) pays play time. A card is found by the
# digest of what its QR code or RFID tag reads (never stored itself) and
# shown by its last characters; it may belong to no customer. Minutes cards
# keep their minutes on the ledger lines. A correction of a minutes card
# moves minutes only, on one of its top-up receipts. `revision` binds an
# approval of a correction to the card.
class ExtendSpreePosStoredValueAccounts < ActiveRecord::Migration[8.1]
  OLD_ACCOUNT = "kind = 'meal' AND status IN ('active', 'closed')"
  OLD_ENTRY = "kind = 'top_up' AND amount > 0 AND received_funds_id IS NOT NULL OR " \
              "kind = 'spend' AND amount < 0 AND funds_allocation_id IS NOT NULL OR " \
              "kind = 'refund' AND amount < 0 AND liability_payout_id IS NOT NULL OR " \
              "kind = 'adjust' AND amount <> 0"

  def up
    change_column_null :spree_pos_stored_value_accounts, :customer_profile_id, true
    add_reference :spree_pos_stored_value_accounts, :branch, foreign_key: { to_table: :spree_pos_branches }, index: false
    add_column :spree_pos_stored_value_accounts, :card_digest, :string, limit: 64
    add_column :spree_pos_stored_value_accounts, :card_hint, :string, limit: 8
    add_column :spree_pos_stored_value_accounts, :holder_name, :string, limit: 120
    add_column :spree_pos_stored_value_accounts, :revision, :integer, null: false, default: 0
    add_index :spree_pos_stored_value_accounts, %i[store_id card_digest], unique: true, where: 'card_digest IS NOT NULL',
                                                                          name: 'idx_pos_stored_value_accounts_card'
    remove_check_constraint :spree_pos_stored_value_accounts, name: 'chk_pos_stored_value_accounts_values'
    add_check_constraint :spree_pos_stored_value_accounts,
                         "kind IN ('meal', 'money', 'minutes') AND status IN ('active', 'closed') AND " \
                         "(kind <> 'meal' OR customer_profile_id IS NOT NULL) AND (kind = 'meal' OR card_digest IS NOT NULL)",
                         name: 'chk_pos_stored_value_accounts_values'

    remove_check_constraint :spree_pos_stored_value_entries, name: 'chk_pos_stored_value_entries_kind'
    add_check_constraint :spree_pos_stored_value_entries,
                         "kind = 'top_up' AND amount > 0 AND received_funds_id IS NOT NULL AND (minutes IS NULL OR minutes > 0) OR " \
                         "kind = 'spend' AND amount < 0 AND funds_allocation_id IS NOT NULL AND (minutes IS NULL OR minutes < 0) OR " \
                         "kind = 'refund' AND amount < 0 AND liability_payout_id IS NOT NULL AND (minutes IS NULL OR minutes <= 0) OR " \
                         "kind = 'adjust' AND (amount <> 0 OR (minutes IS NOT NULL AND minutes <> 0 AND received_funds_id IS NOT NULL))",
                         name: 'chk_pos_stored_value_entries_kind'
  end

  def down
    remove_check_constraint :spree_pos_stored_value_entries, name: 'chk_pos_stored_value_entries_kind'
    add_check_constraint :spree_pos_stored_value_entries, OLD_ENTRY, name: 'chk_pos_stored_value_entries_kind'
    remove_check_constraint :spree_pos_stored_value_accounts, name: 'chk_pos_stored_value_accounts_values'
    add_check_constraint :spree_pos_stored_value_accounts, OLD_ACCOUNT, name: 'chk_pos_stored_value_accounts_values'
    remove_index :spree_pos_stored_value_accounts, name: 'idx_pos_stored_value_accounts_card'
    remove_column :spree_pos_stored_value_accounts, :revision
    remove_column :spree_pos_stored_value_accounts, :holder_name
    remove_column :spree_pos_stored_value_accounts, :card_hint
    remove_column :spree_pos_stored_value_accounts, :card_digest
    remove_reference :spree_pos_stored_value_accounts, :branch
    change_column_null :spree_pos_stored_value_accounts, :customer_profile_id, false
  end
end

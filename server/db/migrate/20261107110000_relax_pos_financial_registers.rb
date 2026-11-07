# frozen_string_literal: true

# Branch-only shifts have no register, so money recorded on them cannot require
# one. Received funds also keep the attested receiving account and where the
# physical cash is held: `drawer` cash is counted in its shift, `held` cash
# (late attestation, safe) waits for reconciliation and never touches a drawer.
class RelaxPosFinancialRegisters < ActiveRecord::Migration[8.1]
  def change
    change_column_null :spree_pos_tender_attempts, :register_id, true
    change_column_null :spree_pos_received_funds, :register_id, true
    change_column_null :spree_pos_cash_movements, :register_id, true

    add_column :spree_pos_received_funds, :receiving_account, :string, limit: 120
    add_column :spree_pos_received_funds, :custody, :string, limit: 16, null: false, default: 'drawer'
    add_column :spree_pos_received_funds, :custody_note, :string, limit: 200
    add_check_constraint :spree_pos_received_funds, "custody IN ('drawer', 'held')", name: 'chk_pos_received_funds_custody'
  end
end

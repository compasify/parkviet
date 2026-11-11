# frozen_string_literal: true

# Which e-invoice a store issues for completed POS orders. `none` issues
# nothing and is the default, so existing stores keep selling unchanged.
class AddEinvoiceTypeToSpreePosStoreProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :spree_pos_store_profiles, :einvoice_type, :string, limit: 16, null: false, default: 'none'
    add_check_constraint :spree_pos_store_profiles, "einvoice_type IN ('none', 'cash_register', 'coded')",
                         name: 'chk_pos_store_profiles_einvoice_type'
  end
end

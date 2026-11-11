# frozen_string_literal: true

# A store's e-invoice provider settings: one default row (branch_id null)
# and optional per-branch rows with the branch's own seller details and
# invoice symbol. Provider credentials are encrypted at rest and never read
# back by the API.
class CreateSpreePosEinvoiceSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_einvoice_settings do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, foreign_key: { to_table: :spree_pos_branches }
      t.string :provider, limit: 40, null: false
      t.text :credentials
      t.string :template_code, limit: 1
      t.string :symbol, limit: 6
      t.string :seller_name, limit: 400
      t.string :seller_tax_code, limit: 14
      t.string :seller_address, limit: 400
      t.string :consumer_label, limit: 100
      t.string :lookup_url, limit: 300
      t.integer :buyer_link_hours
      t.string :status, limit: 16, null: false, default: 'active'
      t.references :changed_by, foreign_key: { to_table: :spree_admin_users }
      t.timestamps
    end
    add_index :spree_pos_einvoice_settings, :store_id, unique: true, where: 'branch_id IS NULL', name: 'idx_pos_einvoice_settings_store'
    add_index :spree_pos_einvoice_settings, %i[store_id branch_id], unique: true, where: 'branch_id IS NOT NULL',
                                                                    name: 'idx_pos_einvoice_settings_branch'
    add_check_constraint :spree_pos_einvoice_settings, "status IN ('active', 'disabled')", name: 'chk_pos_einvoice_settings_status'
    add_check_constraint :spree_pos_einvoice_settings, 'buyer_link_hours IS NULL OR buyer_link_hours BETWEEN 1 AND 720',
                         name: 'chk_pos_einvoice_settings_link_hours'
  end
end

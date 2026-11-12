# frozen_string_literal: true

# The code printed on a table's QR sticker. Only its SHA-256 digest is kept;
# the token is shown once, when the sticker is printed. A table has at most
# one active code, and rotating it revokes the old one.
class CreateSpreePosTableCodes < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_table_codes do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.references :resource, null: false, foreign_key: { to_table: :spree_pos_resources }, index: false
      t.string :token_digest, null: false, limit: 64
      t.string :status, null: false, default: 'active', limit: 16
      t.datetime :rotated_at, null: false
      t.datetime :revoked_at
      t.references :created_by, null: false, foreign_key: { to_table: :spree_admin_users }, index: false
      t.timestamps
    end
    add_index :spree_pos_table_codes, :token_digest, unique: true, name: 'idx_pos_table_codes_token'
    add_index :spree_pos_table_codes, :resource_id, unique: true, where: "status = 'active'", name: 'idx_pos_table_codes_active'
    add_check_constraint :spree_pos_table_codes, "status IN ('active', 'revoked')", name: 'chk_pos_table_codes_status'
    add_check_constraint :spree_pos_table_codes, "(status = 'active') = (revoked_at IS NULL)", name: 'chk_pos_table_codes_revoked'
  end
end

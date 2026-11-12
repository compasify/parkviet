# frozen_string_literal: true

# A guest's phone at a table, after scanning its code. Bound to the table's
# open order when there is one (the session dies with it), otherwise it can
# only read the menu and call staff. Only token digests are kept, and the
# client address and browser only as a keyed digest.
class CreateSpreePosGuestSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_guest_sessions do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }, index: false
      t.references :table_code, null: false, foreign_key: { to_table: :spree_pos_table_codes }
      t.references :resource, null: false, foreign_key: { to_table: :spree_pos_resources }, index: false
      t.references :workspace, foreign_key: { to_table: :spree_pos_workspaces, on_delete: :nullify }
      t.string :token_digest, null: false, limit: 64
      t.string :client_fingerprint_digest, limit: 64
      t.datetime :expires_at, null: false
      t.datetime :revoked_at
      t.timestamps
    end
    add_index :spree_pos_guest_sessions, :token_digest, unique: true, name: 'idx_pos_guest_sessions_token'
    add_check_constraint :spree_pos_guest_sessions, 'expires_at > created_at', name: 'chk_pos_guest_sessions_expiry'
  end
end

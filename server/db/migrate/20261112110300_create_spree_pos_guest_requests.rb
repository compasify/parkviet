# frozen_string_literal: true

# A guest calling staff or asking for the bill from their phone. One open
# request of each kind per session.
class CreateSpreePosGuestRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_guest_requests do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }, index: false
      t.references :guest_session, null: false, foreign_key: { to_table: :spree_pos_guest_sessions }, index: false
      t.references :resource, null: false, foreign_key: { to_table: :spree_pos_resources }, index: false
      t.references :workspace, foreign_key: { to_table: :spree_pos_workspaces, on_delete: :nullify }, index: false
      t.string :kind, null: false, limit: 16
      t.string :status, null: false, default: 'open', limit: 16
      t.references :handled_by, foreign_key: { to_table: :spree_admin_users }, index: false
      t.datetime :handled_at
      t.timestamps
    end
    add_index :spree_pos_guest_requests, %i[guest_session_id kind], unique: true, where: "status = 'open'",
                                                                    name: 'idx_pos_guest_requests_open'
    add_index :spree_pos_guest_requests, %i[branch_id status], name: 'idx_pos_guest_requests_branch_status'
    add_check_constraint :spree_pos_guest_requests, "kind IN ('call_staff', 'request_bill')", name: 'chk_pos_guest_requests_kind'
    add_check_constraint :spree_pos_guest_requests, "status IN ('open', 'done')", name: 'chk_pos_guest_requests_status'
    add_check_constraint :spree_pos_guest_requests, "(status = 'open') = (handled_at IS NULL)", name: 'chk_pos_guest_requests_handled'
  end
end

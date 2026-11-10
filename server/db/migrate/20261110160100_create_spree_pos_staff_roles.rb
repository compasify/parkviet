# frozen_string_literal: true

# Named capability sets. A membership with a role takes the role's
# capabilities; one without keeps its own list.
class CreateSpreePosStaffRoles < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_staff_roles do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.string :name, limit: 80, null: false
      t.jsonb :capabilities, null: false, default: []
      t.string :status, null: false, default: 'active'
      t.timestamps
    end
    add_index :spree_pos_staff_roles, 'store_id, lower(name)', unique: true, name: 'idx_pos_staff_roles_store_name'
    add_check_constraint :spree_pos_staff_roles, "status IN ('active', 'disabled')", name: 'chk_pos_staff_roles_status'

    add_reference :spree_pos_staff_memberships, :staff_role, foreign_key: { to_table: :spree_pos_staff_roles }
  end
end

# frozen_string_literal: true

# Who served a room and when: a book of hours, with no money and nothing on
# the bill. A staff member serves one room at a time.
class CreateSpreePosAttendantAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_attendant_assignments do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }, index: false
      t.references :resource, null: false, foreign_key: { to_table: :spree_pos_resources }
      t.references :timed_session, foreign_key: { to_table: :spree_pos_timed_sessions }
      t.references :staff, null: false, foreign_key: { to_table: :spree_admin_users }, index: false
      t.datetime :started_at, null: false
      t.datetime :ended_at
      t.date :business_date, null: false
      t.string :note, limit: 255
      t.references :started_by, null: false, foreign_key: { to_table: :spree_admin_users }, index: false
      t.references :ended_by, foreign_key: { to_table: :spree_admin_users }, index: false
      t.timestamps
    end
    add_index :spree_pos_attendant_assignments, %i[branch_id business_date], name: 'idx_pos_attendant_assignments_day'
    add_index :spree_pos_attendant_assignments, :staff_id, unique: true, where: 'ended_at IS NULL', name: 'idx_pos_attendant_assignments_open'
    add_check_constraint :spree_pos_attendant_assignments, 'ended_at IS NULL OR ended_at >= started_at',
                         name: 'chk_pos_attendant_assignments_times'
  end
end

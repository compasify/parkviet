# frozen_string_literal: true

# One row per "send to kitchen" that told the kitchen something, numbered per
# order, and one row per sent item taken back, with its reason, approval and
# the void ticket it printed. A branch keeps its own list of void reasons.
class CreateSpreePosKitchenSendsAndVoids < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_kitchen_sends do |t|
      t.references :workspace, null: false, foreign_key: { to_table: :spree_pos_workspaces }, index: false
      t.integer :sequence, null: false
      t.references :staff, foreign_key: { to_table: :spree_admin_users }
      t.references :device, foreign_key: { to_table: :spree_pos_devices }
      t.string :send_key, null: false, limit: 200
      t.timestamps
    end
    add_index :spree_pos_kitchen_sends, %i[workspace_id sequence], unique: true, name: 'idx_pos_kitchen_sends_sequence'
    add_index :spree_pos_kitchen_sends, %i[workspace_id send_key], unique: true, name: 'idx_pos_kitchen_sends_key'
    add_check_constraint :spree_pos_kitchen_sends, 'sequence > 0', name: 'chk_pos_kitchen_sends_sequence'

    add_reference :spree_pos_kitchen_tickets, :kitchen_send, foreign_key: { to_table: :spree_pos_kitchen_sends }

    # A sent item voided to nothing leaves the order; what the kitchen was
    # told stays on its tickets without the line.
    remove_foreign_key :spree_pos_kitchen_ticket_items, :spree_pos_sale_lines, column: :sale_line_id
    add_foreign_key :spree_pos_kitchen_ticket_items, :spree_pos_sale_lines, column: :sale_line_id, on_delete: :nullify
    change_column_null :spree_pos_kitchen_ticket_items, :sale_line_id, true

    create_table :spree_pos_kitchen_voids do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.references :workspace, null: false, foreign_key: { to_table: :spree_pos_workspaces }
      t.references :sale_line, foreign_key: { to_table: :spree_pos_sale_lines, on_delete: :nullify }
      t.decimal :quantity, precision: 19, scale: 4, null: false
      t.string :name, null: false
      t.string :reason_code, null: false, limit: 40
      t.string :note, limit: 200
      t.references :staff, null: false, foreign_key: { to_table: :spree_admin_users }
      t.references :device, foreign_key: { to_table: :spree_pos_devices }
      t.references :approval, foreign_key: { to_table: :spree_pos_approvals }
      t.boolean :wasted, null: false, default: false
      t.references :kitchen_ticket, foreign_key: { to_table: :spree_pos_kitchen_tickets }
      t.timestamps
    end
    add_check_constraint :spree_pos_kitchen_voids, 'quantity > 0', name: 'chk_pos_kitchen_voids_quantity'

    add_column :spree_pos_branches, :void_reasons, :jsonb, null: false,
                                                          default: %w[khach_doi_y het_mon nhap_nham lam_hong]
  end
end

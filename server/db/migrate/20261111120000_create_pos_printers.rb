# frozen_string_literal: true

# A branch's printers. A station connection is printed by a paired
# print_station device; epson_epos and star_webprnt by the cashier's browser
# straight to `address`; browser means the print dialog.
class CreatePosPrinters < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_printers do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.references :register, foreign_key: { to_table: :spree_pos_registers }
      t.references :print_station_device, foreign_key: { to_table: :spree_pos_devices }
      t.string :name, null: false
      t.string :connection, null: false
      t.string :address
      t.string :bluetooth_id
      t.string :paper, null: false, default: '80mm'
      t.string :command_language, null: false, default: 'escpos'
      t.text :roles, array: true, null: false, default: []
      t.string :status, null: false, default: 'active'
      t.jsonb :settings, null: false, default: {}
      t.timestamps
    end
    add_check_constraint :spree_pos_printers,
                         "connection IN ('escpos_lan', 'escpos_bluetooth', 'sunmi_builtin', 'epson_epos', 'star_webprnt', 'browser')",
                         name: 'chk_pos_printers_connection'
    add_check_constraint :spree_pos_printers, "paper IN ('58mm', '80mm')", name: 'chk_pos_printers_paper'
    add_check_constraint :spree_pos_printers, "command_language IN ('escpos', 'tspl')", name: 'chk_pos_printers_language'
    add_check_constraint :spree_pos_printers, "status IN ('active', 'disabled')", name: 'chk_pos_printers_status'
  end
end

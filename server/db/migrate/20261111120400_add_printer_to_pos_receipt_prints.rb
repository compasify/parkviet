# frozen_string_literal: true

# The LAN printer a print was sent to from the browser. Only such a print can
# be taken back after a failed delivery. A deleted printer leaves the print.
class AddPrinterToPosReceiptPrints < ActiveRecord::Migration[8.1]
  def change
    add_reference :spree_pos_receipt_prints, :printer, foreign_key: { to_table: :spree_pos_printers, on_delete: :nullify }
  end
end

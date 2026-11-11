# frozen_string_literal: true

# A menu line keeps the cashier's note and a digest of its option set, so two
# cups with different options stay two lines.
class AddMenuColumnsToSpreePosSaleLines < ActiveRecord::Migration[8.1]
  def change
    add_column :spree_pos_sale_lines, :note, :string, limit: 200
    add_column :spree_pos_sale_lines, :modifier_signature, :string, limit: 64
  end
end

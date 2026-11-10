# frozen_string_literal: true

# Names only. Workflows that create menu, timed and cover lines come later.
class WidenPosSaleLineKinds < ActiveRecord::Migration[8.1]
  def up
    remove_check_constraint :spree_pos_sale_lines, name: 'chk_pos_sale_lines_kind'
    add_check_constraint :spree_pos_sale_lines,
                         "kind IN ('ordinary', 'measured', 'tracked', 'menu', 'timed', 'cover')",
                         name: 'chk_pos_sale_lines_kind'
  end

  def down
    remove_check_constraint :spree_pos_sale_lines, name: 'chk_pos_sale_lines_kind'
    add_check_constraint :spree_pos_sale_lines,
                         "kind IN ('ordinary', 'measured', 'tracked')",
                         name: 'chk_pos_sale_lines_kind'
  end
end

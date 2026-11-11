# frozen_string_literal: true

# Courses, seats and buffet tiers of a table's lines, and the buffet tiers
# themselves. A held course stays off the kitchen until it is fired; a
# buffet cover line names its tier, and the dishes eaten on it point at it.
class AddCourseSeatBuffetToSpreePosSaleLines < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_buffet_tiers do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.string :name, null: false
      # The ticket sold per guest; its tax category taxes the cover.
      t.references :product, null: false, foreign_key: { to_table: :spree_products }
      t.integer :duration_minutes, null: false, default: 90
      t.integer :round_item_limit
      t.integer :round_interval_minutes, null: false, default: 0
      t.string :status, null: false, default: 'active'
      t.timestamps
    end
    add_check_constraint :spree_pos_buffet_tiers,
                         "status IN ('active', 'archived') AND duration_minutes BETWEEN 1 AND 1440 AND " \
                         'round_interval_minutes BETWEEN 0 AND 240 AND (round_item_limit IS NULL OR round_item_limit BETWEEN 1 AND 99)',
                         name: 'chk_pos_buffet_tiers_values'

    create_table :spree_pos_buffet_tier_items do |t|
      t.references :buffet_tier, null: false, foreign_key: { to_table: :spree_pos_buffet_tiers, on_delete: :cascade }, index: false
      t.references :product, null: false, foreign_key: { to_table: :spree_products }
      t.integer :max_per_round
      t.timestamps
    end
    add_index :spree_pos_buffet_tier_items, %i[buffet_tier_id product_id], unique: true, name: 'idx_pos_buffet_tier_items_pair'
    add_check_constraint :spree_pos_buffet_tier_items, 'max_per_round IS NULL OR max_per_round BETWEEN 1 AND 99',
                         name: 'chk_pos_buffet_tier_items_max'

    change_table :spree_pos_sale_lines, bulk: true do |t|
      t.integer :course, limit: 2
      t.string :course_status, null: false, default: 'none'
      t.integer :seat, limit: 2
      t.references :buffet_tier, foreign_key: { to_table: :spree_pos_buffet_tiers }, index: false
      t.references :buffet_cover_line, foreign_key: { to_table: :spree_pos_sale_lines, on_delete: :nullify }, index: false
    end
    add_check_constraint :spree_pos_sale_lines,
                         "course_status IN ('none', 'held', 'fired') AND (course IS NULL OR course BETWEEN 1 AND 9) AND " \
                         "(seat IS NULL OR seat BETWEEN 1 AND 99) AND (course_status = 'none' OR course IS NOT NULL)",
                         name: 'chk_pos_sale_lines_course_seat'
    add_index :spree_pos_sale_lines, :buffet_cover_line_id, where: 'buffet_cover_line_id IS NOT NULL',
                                                            name: 'idx_pos_sale_lines_buffet_cover'
    add_index :spree_pos_sale_lines, %i[workspace_id course], where: "course_status = 'held'", name: 'idx_pos_sale_lines_held'
  end
end

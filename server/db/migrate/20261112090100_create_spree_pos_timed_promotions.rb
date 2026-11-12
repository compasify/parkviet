# frozen_string_literal: true

# Free minutes on play time: after playing at least `threshold_minutes`
# (`bonus_after`), or with a prepaid package (`bonus_with_package`). A
# promotion may be limited to kinds of room and to time windows of the week.
class CreateSpreePosTimedPromotions < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_timed_promotions do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }, index: false
      t.string :name, null: false, limit: 120
      t.string :kind, null: false, limit: 24
      t.integer :threshold_minutes, null: false, default: 0
      t.integer :bonus_minutes, null: false
      t.jsonb :resource_kinds, null: false, default: []
      t.jsonb :active_windows, null: false, default: []
      t.string :status, null: false, limit: 16, default: 'active'
      t.timestamps
    end
    add_index :spree_pos_timed_promotions, %i[branch_id status], name: 'idx_pos_timed_promotions_branch'
    add_check_constraint :spree_pos_timed_promotions,
                         "kind IN ('bonus_after', 'bonus_with_package') AND status IN ('active', 'archived') AND " \
                         'threshold_minutes BETWEEN 0 AND 1440 AND bonus_minutes BETWEEN 1 AND 600 AND ' \
                         "jsonb_typeof(resource_kinds) = 'array' AND jsonb_typeof(active_windows) = 'array'",
                         name: 'chk_pos_timed_promotions_values'
    add_foreign_key :spree_pos_timed_quote_lines, :spree_pos_timed_promotions, column: :timed_promotion_id
  end
end

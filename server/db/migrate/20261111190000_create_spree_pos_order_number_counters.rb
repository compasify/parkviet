# frozen_string_literal: true

# The last call number handed out at a branch on one business date. One row
# per branch and date, bumped by a single upsert, so two tills completing at
# once never get the same number.
class CreateSpreePosOrderNumberCounters < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_order_number_counters do |t|
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }, index: false
      t.date :business_date, null: false
      t.integer :last_value, null: false, default: 0
      t.timestamps
    end
    add_index :spree_pos_order_number_counters, %i[branch_id business_date], unique: true,
                                                                             name: 'idx_pos_order_number_counters_day'
    add_check_constraint :spree_pos_order_number_counters, 'last_value >= 0', name: 'chk_pos_order_number_counters_value'
  end
end

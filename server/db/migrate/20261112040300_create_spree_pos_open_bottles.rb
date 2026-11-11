# frozen_string_literal: true

# Pours measured in ml from the bottle open behind the bar. A recipe row may
# take ml from a bottle stocked by the bottle (`pour_ml` of a `bottle_ml`
# bottle); such a row moves no stock itself. Each completed sale pours into
# the branch's open bottle of that variant, once per sale line, and a bottle
# that runs dry leaves the shelf as one bottle.
class CreateSpreePosOpenBottles < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_open_bottles do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }, index: false
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }, index: false
      t.references :variant, null: false, foreign_key: { to_table: :spree_variants }
      t.integer :capacity_ml, null: false
      t.integer :remaining_ml, null: false
      t.string :status, null: false, default: 'open'
      t.datetime :opened_at, null: false
      t.references :opened_by, null: false, foreign_key: { to_table: :spree_admin_users }
      t.datetime :finished_at
      t.timestamps
    end
    add_index :spree_pos_open_bottles, %i[branch_id variant_id status], name: 'idx_pos_open_bottles_branch_variant'
    add_check_constraint :spree_pos_open_bottles,
                         "status IN ('open', 'finished') AND capacity_ml > 0 AND remaining_ml >= 0 AND remaining_ml <= capacity_ml",
                         name: 'chk_pos_open_bottles_values'

    create_table :spree_pos_pour_events do |t|
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }, index: false
      t.references :open_bottle, null: false, foreign_key: { to_table: :spree_pos_open_bottles }
      t.references :sale_line, null: false, foreign_key: { to_table: :spree_pos_sale_lines }, index: false
      t.references :workspace, null: false, foreign_key: { to_table: :spree_pos_workspaces }
      t.integer :ml, null: false
      t.date :business_date, null: false
      t.datetime :created_at, null: false
    end
    add_index :spree_pos_pour_events, %i[sale_line_id open_bottle_id], unique: true, name: 'idx_pos_pour_events_once'
    add_index :spree_pos_pour_events, %i[branch_id business_date], name: 'idx_pos_pour_events_day'
    add_check_constraint :spree_pos_pour_events, 'ml > 0', name: 'chk_pos_pour_events_ml'

    add_column :spree_pos_recipe_ingredients, :pour_ml, :integer
    add_column :spree_pos_recipe_ingredients, :bottle_ml, :integer
    remove_check_constraint :spree_pos_recipe_ingredients, 'quantity > 0::numeric AND base_quantity > 0',
                            name: 'chk_pos_recipe_ingredients_quantity'
    add_check_constraint :spree_pos_recipe_ingredients,
                         'quantity > 0 AND ((pour_ml IS NULL AND bottle_ml IS NULL AND base_quantity > 0) OR ' \
                         '(pour_ml > 0 AND bottle_ml >= pour_ml AND base_quantity = 0))',
                         name: 'chk_pos_recipe_ingredients_quantity'
  end
end

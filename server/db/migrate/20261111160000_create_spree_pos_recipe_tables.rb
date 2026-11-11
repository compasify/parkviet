# frozen_string_literal: true

# Recipes of menu sizes and modifier options, the ingredients each version
# uses, and what a completed sale consumed. A stock discrepancy now says
# where it came from: a short counter handover, or an ingredient the shelf
# could not cover when a recipe was consumed.
class CreateSpreePosRecipeTables < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_recipes do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.string :owner_type, null: false, limit: 64
      t.bigint :owner_id, null: false
      t.integer :version, null: false
      t.boolean :active, null: false, default: true
      t.references :created_by, foreign_key: { to_table: :spree_admin_users }
      t.timestamps
    end
    add_index :spree_pos_recipes, %i[owner_type owner_id version], unique: true, name: 'idx_pos_recipes_version'
    add_index :spree_pos_recipes, %i[owner_type owner_id], unique: true, where: 'active', name: 'idx_pos_recipes_active'
    add_check_constraint :spree_pos_recipes, "owner_type IN ('Spree::Variant', 'Spree::Pos::ModifierOption')",
                         name: 'chk_pos_recipes_owner'
    add_check_constraint :spree_pos_recipes, 'version > 0', name: 'chk_pos_recipes_version'

    create_table :spree_pos_recipe_ingredients do |t|
      t.references :recipe, null: false, foreign_key: { to_table: :spree_pos_recipes, on_delete: :cascade }
      t.references :ingredient_variant, null: false, foreign_key: { to_table: :spree_variants }
      t.decimal :quantity, precision: 12, scale: 4, null: false
      t.string :unit_code, null: false, limit: 16
      # The quantity in the ingredient's stock unit, converted when the
      # version was saved, so a version always consumes what it said.
      t.integer :base_quantity, null: false
      t.string :base_unit_code, null: false, limit: 16
      t.timestamps
    end
    add_index :spree_pos_recipe_ingredients, %i[recipe_id ingredient_variant_id], unique: true,
                                                                                  name: 'idx_pos_recipe_ingredients_variant'
    add_check_constraint :spree_pos_recipe_ingredients, 'quantity > 0 AND base_quantity > 0',
                         name: 'chk_pos_recipe_ingredients_quantity'

    create_table :spree_pos_recipe_consumptions do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches }
      t.references :workspace, null: false, foreign_key: { to_table: :spree_pos_workspaces }
      t.references :order, null: false, foreign_key: { to_table: :spree_orders }
      t.references :sale_line, null: false, foreign_key: { to_table: :spree_pos_sale_lines }
      t.references :ingredient_variant, null: false, foreign_key: { to_table: :spree_variants }
      t.references :stock_location, null: false, foreign_key: { to_table: :spree_stock_locations }
      t.integer :base_quantity, null: false
      t.string :base_unit_code, null: false, limit: 16
      t.references :recipe, foreign_key: { to_table: :spree_pos_recipes }
      t.integer :recipe_version
      t.string :source_key, null: false, limit: 64
      t.decimal :unit_cost, precision: 19, scale: 4
      t.date :business_date, null: false
      t.timestamps
    end
    add_index :spree_pos_recipe_consumptions, %i[sale_line_id ingredient_variant_id source_key], unique: true,
                                                                                                 name: 'idx_pos_recipe_consumptions_source'
    add_index :spree_pos_recipe_consumptions, %i[branch_id business_date], name: 'idx_pos_recipe_consumptions_day'
    add_check_constraint :spree_pos_recipe_consumptions, 'base_quantity > 0', name: 'chk_pos_recipe_consumptions_quantity'

    add_column :spree_pos_stock_discrepancies, :source, :string, limit: 16, null: false, default: 'handover'
    add_check_constraint :spree_pos_stock_discrepancies, "source IN ('handover', 'recipe')",
                         name: 'chk_pos_stock_discrepancies_source'
    remove_index :spree_pos_stock_discrepancies, %i[fulfillment_id variant_id], unique: true,
                                                                                where: "status = 'open'", name: 'idx_pos_stock_discrepancies_open'
    add_index :spree_pos_stock_discrepancies, %i[fulfillment_id variant_id source], unique: true,
                                                                                    where: "status = 'open'", name: 'idx_pos_stock_discrepancies_open'
  end
end

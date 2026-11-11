# frozen_string_literal: true

# The tax categories a store's new menu items start with: one for food and
# ordinary drinks, one for alcoholic drinks. Chosen in the F&B setup step;
# empty for a store that never ran it.
class AddMenuTaxDefaultsToSpreePosStoreProfiles < ActiveRecord::Migration[8.1]
  def change
    add_reference :spree_pos_store_profiles, :food_tax_category, foreign_key: { to_table: :spree_tax_categories }, index: false
    add_reference :spree_pos_store_profiles, :alcohol_tax_category, foreign_key: { to_table: :spree_tax_categories }, index: false
  end
end

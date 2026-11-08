# frozen_string_literal: true

# Industry profiles and per-branch modules. Branches that already run keep
# their behaviour: each one gets the `khac` profile with all three retail
# modules on, and each store that has branches gets a store profile so it is
# not sent through the first-run setup. Plain SQL, no models.
class CreateSpreePosBusinessProfiles < ActiveRecord::Migration[8.1]
  BACKFILL_MODULES = %w[retail.units retail.measured retail.traceability].freeze
  BACKFILL_PROFILE = 'khac'

  # Module rows for branches that have none, and a store profile for stores
  # with branches and no profile. Idempotent, so a spec can run it against
  # rows it created. Branch profile keys come from the column default.
  def self.backfill_sql
    modules = BACKFILL_MODULES.map { |key| "('#{key}')" }.join(', ')
    [
      <<~SQL.squish,
        INSERT INTO spree_pos_branch_modules (store_id, branch_id, module_key, enabled, reason, created_at, updated_at)
        SELECT b.store_id, b.id, m.module_key, TRUE, 'backfill', NOW(), NOW()
        FROM spree_pos_branches b CROSS JOIN (VALUES #{modules}) AS m(module_key)
        WHERE NOT EXISTS (SELECT 1 FROM spree_pos_branch_modules x WHERE x.branch_id = b.id)
        ON CONFLICT (branch_id, module_key) DO NOTHING
      SQL
      <<~SQL.squish
        INSERT INTO spree_pos_store_profiles (store_id, profile_key, profile_version, wholesale, interests, onboarded_at, created_at, updated_at)
        SELECT b.store_id, '#{BACKFILL_PROFILE}', 1, FALSE, '{}', MIN(b.created_at), NOW(), NOW()
        FROM spree_pos_branches b
        GROUP BY b.store_id
        ON CONFLICT (store_id) DO NOTHING
      SQL
    ]
  end

  def up
    create_table :spree_pos_store_profiles do |t|
      t.references :store, null: false, index: { unique: true }, foreign_key: { to_table: :spree_stores }
      t.string :profile_key, limit: 40, null: false
      t.integer :profile_version, null: false, default: 1
      t.boolean :wholesale, null: false, default: false
      t.string :interests, array: true, null: false, default: []
      t.datetime :onboarded_at
      t.bigint :changed_by_id
      t.timestamps
    end
    add_foreign_key :spree_pos_store_profiles, :spree_admin_users, column: :changed_by_id
    add_check_constraint :spree_pos_store_profiles, 'profile_version >= 1', name: 'chk_pos_store_profiles_version'

    # The column default already gives every existing branch `khac`.
    add_column :spree_pos_branches, :profile_key, :string, limit: 40, null: false, default: BACKFILL_PROFILE
    add_column :spree_pos_branches, :profile_version, :integer, null: false, default: 1
    add_check_constraint :spree_pos_branches, 'profile_version >= 1', name: 'chk_pos_branches_profile_version'

    create_table :spree_pos_branch_modules do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, null: false, index: false, foreign_key: { to_table: :spree_pos_branches }
      t.string :module_key, limit: 64, null: false
      t.boolean :enabled, null: false
      t.string :reason, limit: 200
      t.bigint :changed_by_id
      t.timestamps
    end
    add_index :spree_pos_branch_modules, %i[branch_id module_key], unique: true, name: 'idx_pos_branch_modules_key'
    add_foreign_key :spree_pos_branch_modules, :spree_admin_users, column: :changed_by_id

    self.class.backfill_sql.each { |sql| execute(sql) }
  end

  def down
    drop_table :spree_pos_branch_modules
    remove_check_constraint :spree_pos_branches, name: 'chk_pos_branches_profile_version'
    remove_column :spree_pos_branches, :profile_version
    remove_column :spree_pos_branches, :profile_key
    drop_table :spree_pos_store_profiles
  end
end

# frozen_string_literal: true

# Kill-switches for risky POS capabilities. A row without a branch is the
# store default, a row with a branch overrides it there; a feature with no row
# at all is off. Turning a feature off only refuses new commands of that
# feature: no attempt, receipt or ledger row is touched.
class CreateSpreePosFeatureFlags < ActiveRecord::Migration[8.1]
  FEATURES = %w[credit returns refunds exchanges traceability customer_display cash_moves exports].freeze

  def change
    create_table :spree_pos_feature_flags do |t|
      t.references :store, null: false, foreign_key: { to_table: :spree_stores }
      t.references :branch, foreign_key: { to_table: :spree_pos_branches }
      t.string :feature, null: false
      t.boolean :enabled, null: false
      t.references :changed_by, null: false, index: false
      t.string :reason, null: false
      t.timestamps
    end
    add_index :spree_pos_feature_flags, %i[store_id feature], unique: true, where: 'branch_id IS NULL',
                                                               name: 'idx_pos_feature_flags_store_default'
    add_index :spree_pos_feature_flags, %i[branch_id feature], unique: true, where: 'branch_id IS NOT NULL',
                                                                name: 'idx_pos_feature_flags_branch_override'
    add_check_constraint :spree_pos_feature_flags, "feature IN (#{FEATURES.map { |name| "'#{name}'" }.join(', ')})",
                         name: 'chk_pos_feature_flags_feature'
    add_check_constraint :spree_pos_feature_flags, 'char_length(reason) BETWEEN 1 AND 200',
                         name: 'chk_pos_feature_flags_reason'
  end
end

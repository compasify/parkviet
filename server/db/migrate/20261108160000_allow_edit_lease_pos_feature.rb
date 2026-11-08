# frozen_string_literal: true

# `edit_lease` switches on strict editing locks for POS drafts. Without it (the
# default) a cashier opening a draft held elsewhere takes its editing over
# automatically, which suits shops with a single branch and counter.
class AllowEditLeasePosFeature < ActiveRecord::Migration[8.1]
  NAME = 'chk_pos_feature_flags_feature'
  BEFORE = %w[credit returns refunds exchanges traceability customer_display cash_moves exports vietqr].freeze

  def up
    replace_constraint(BEFORE + %w[edit_lease])
  end

  def down
    execute "DELETE FROM spree_pos_feature_flags WHERE feature = 'edit_lease'"
    replace_constraint(BEFORE)
  end

  private

  def replace_constraint(values)
    remove_check_constraint :spree_pos_feature_flags, name: NAME
    list = values.map { |value| connection.quote(value) }.join(', ')
    add_check_constraint :spree_pos_feature_flags, "feature IN (#{list})", name: NAME
  end
end

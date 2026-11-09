# frozen_string_literal: true

# `quick_credit` lets a one-person shop sell the unpaid remainder on credit
# without a second person: the cashier approves their own credit sale.
class AllowQuickCreditPosFeature < ActiveRecord::Migration[8.1]
  NAME = 'chk_pos_feature_flags_feature'
  BEFORE = %w[credit returns refunds exchanges traceability customer_display cash_moves exports vietqr edit_lease].freeze

  def up
    replace_constraint(BEFORE + %w[quick_credit])
  end

  def down
    execute "DELETE FROM spree_pos_feature_flags WHERE feature = 'quick_credit'"
    replace_constraint(BEFORE)
  end

  private

  def replace_constraint(values)
    remove_check_constraint :spree_pos_feature_flags, name: NAME
    list = values.map { |value| connection.quote(value) }.join(', ')
    add_check_constraint :spree_pos_feature_flags, "feature IN (#{list})", name: NAME
  end
end

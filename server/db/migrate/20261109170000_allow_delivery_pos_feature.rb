# frozen_string_literal: true

# `delivery` lets a sale be marked as an order to deliver, with an optional
# delivery fee and a free-text deliverer, tracked until it is delivered.
class AllowDeliveryPosFeature < ActiveRecord::Migration[8.1]
  NAME = 'chk_pos_feature_flags_feature'
  BEFORE = %w[credit returns refunds exchanges traceability customer_display cash_moves exports vietqr edit_lease
              quick_credit].freeze

  def up
    replace_constraint(BEFORE + %w[delivery])
  end

  def down
    execute "DELETE FROM spree_pos_feature_flags WHERE feature = 'delivery'"
    replace_constraint(BEFORE)
  end

  private

  def replace_constraint(values)
    remove_check_constraint :spree_pos_feature_flags, name: NAME
    list = values.map { |value| connection.quote(value) }.join(', ')
    add_check_constraint :spree_pos_feature_flags, "feature IN (#{list})", name: NAME
  end
end

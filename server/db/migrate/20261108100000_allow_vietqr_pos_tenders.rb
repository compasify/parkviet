# frozen_string_literal: true

# VietQR becomes a POS tender kind. Money it brings in is still recorded as a
# bank transfer (received funds stay `cash` / `bank_manual`); the evidence says
# whether the bank webhook or a cashier attested it, and branches can switch
# the tender off with the `vietqr` feature flag.
class AllowVietqrPosTenders < ActiveRecord::Migration[8.1]
  CONSTRAINTS = {
    spree_pos_payment_methods: ['chk_pos_payment_methods_kind', 'kind', %w[cash bank_manual], %w[vietqr]],
    spree_pos_receipt_evidences: ['chk_pos_receipt_evidences_kind', 'kind', %w[cash_count bank_manual external_card], %w[vietqr_webhook vietqr_manual]],
    spree_pos_feature_flags: ['chk_pos_feature_flags_feature', 'feature',
                              %w[credit returns refunds exchanges traceability customer_display cash_moves exports], %w[vietqr]]
  }.freeze

  def up
    CONSTRAINTS.each do |table, (name, column, values, added)|
      replace_constraint(table, name, column, values + added)
    end
  end

  def down
    CONSTRAINTS.each do |table, (name, column, values, _added)|
      replace_constraint(table, name, column, values)
    end
  end

  private

  def replace_constraint(table, name, column, values)
    remove_check_constraint table, name: name
    list = values.map { |value| connection.quote(value) }.join(', ')
    add_check_constraint table, "#{column} IN (#{list})", name: name
  end
end

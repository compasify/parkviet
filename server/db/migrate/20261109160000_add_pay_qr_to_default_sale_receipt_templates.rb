# frozen_string_literal: true

# The built-in sale template now prints the pay-later VietQR of a credit
# sale (payments field `pay_qr`). Stores seeded earlier hold the old built-in
# config as their own template, so the QR would never print for them. Give
# exactly those templates (never edited by anyone, still printing the debt) a
# new version with `pay_qr` added; a template someone edited keeps their
# choice. Versions are immutable, so this adds one. Plain SQL, idempotent.
class AddPayQrToDefaultSaleReceiptTemplates < ActiveRecord::Migration[8.1]
  def up
    execute(<<~SQL.squish)
      WITH targets AS (
        SELECT t.id, t.current_version, v.config
        FROM spree_pos_receipt_templates t
        JOIN spree_pos_receipt_template_versions v
          ON v.receipt_template_id = t.id AND v.version = t.current_version
        WHERE t.document_type = 'sale' AND t.created_by_id IS NULL AND t.updated_by_id IS NULL
          AND jsonb_typeof(v.config -> 'payments' -> 'fields') = 'array'
          AND (v.config -> 'payments' -> 'fields') ? 'debt'
          AND NOT ((v.config -> 'payments' -> 'fields') ? 'pay_qr')
      ), inserted AS (
        INSERT INTO spree_pos_receipt_template_versions (receipt_template_id, version, config, created_by_id, created_at)
        SELECT id, current_version + 1,
               jsonb_set(config, '{payments,fields}', (config -> 'payments' -> 'fields') || '["pay_qr"]'::jsonb),
               NULL, NOW()
        FROM targets
        RETURNING receipt_template_id, version
      )
      UPDATE spree_pos_receipt_templates t
      SET current_version = inserted.version, updated_at = NOW()
      FROM inserted
      WHERE t.id = inserted.receipt_template_id
    SQL
  end

  # Data only: the added versions stay, as every template version does.
  def down; end
end

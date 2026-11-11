# frozen_string_literal: true

# `content_digest` limits free pre-bills to one per billable content, whatever
# moved the workspace revision. `next_attempt_at` spaces out retries after a
# reported failure. The template and version let a reprint match the original.
class AddRetryAndReprintFieldsToPosPrintJobs < ActiveRecord::Migration[8.1]
  def change
    add_column :spree_pos_print_jobs, :content_digest, :string
    add_column :spree_pos_print_jobs, :next_attempt_at, :datetime
    add_reference :spree_pos_print_jobs, :receipt_template, foreign_key: { to_table: :spree_pos_receipt_templates, on_delete: :restrict }
    add_column :spree_pos_print_jobs, :template_version, :integer
  end
end

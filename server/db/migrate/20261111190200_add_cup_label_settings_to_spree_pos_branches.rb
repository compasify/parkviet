# frozen_string_literal: true

# Where a branch prints cup labels, the label size and which fields print,
# and how long a ready call number stays on the call board.
class AddCupLabelSettingsToSpreePosBranches < ActiveRecord::Migration[8.1]
  def change
    add_reference :spree_pos_branches, :cup_label_printer, foreign_key: { to_table: :spree_pos_printers }, index: true
    add_column :spree_pos_branches, :cup_label_settings, :jsonb, null: false, default: {}
  end
end

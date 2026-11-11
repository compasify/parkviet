# frozen_string_literal: true

# What each course number is called at a branch (starters, mains, desserts).
# A branch with no rows uses the three defaults of CourseLabel.
class CreateSpreePosCourseLabels < ActiveRecord::Migration[8.1]
  def change
    create_table :spree_pos_course_labels do |t|
      t.references :branch, null: false, foreign_key: { to_table: :spree_pos_branches, on_delete: :cascade }, index: false
      t.integer :position, null: false
      t.string :name, null: false
      t.timestamps
    end
    add_index :spree_pos_course_labels, %i[branch_id position], unique: true, name: 'idx_pos_course_labels_position'
    add_check_constraint :spree_pos_course_labels, 'position BETWEEN 1 AND 9', name: 'chk_pos_course_labels_position'
  end
end

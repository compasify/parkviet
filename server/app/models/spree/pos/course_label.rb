# frozen_string_literal: true

module Spree
  module Pos
    # The name of a course number at a branch. Without rows of its own a
    # branch uses DEFAULTS.
    class CourseLabel < Record
      self.table_name = 'spree_pos_course_labels'

      DEFAULTS = { 1 => 'Khai vị', 2 => 'Món chính', 3 => 'Tráng miệng' }.freeze
      MAX = 9

      belongs_to :branch, class_name: 'Spree::Pos::Branch'

      validates :position, numericality: { only_integer: true, in: 1..MAX }
      validates :name, presence: true, length: { maximum: 40 }

      # { position => name } of a branch, one query.
      def self.for_branch(branch)
        rows = where(branch_id: branch.id).order(:position).pluck(:position, :name).to_h
        rows.presence || DEFAULTS
      end

      def self.to_pos(branch)
        for_branch(branch).map { |position, name| { position: position, name: name } }
      end
    end
  end
end

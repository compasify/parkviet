# frozen_string_literal: true

module Spree
  module Pos
    # One pre-bill handed to a table: the order revision and total it showed.
    # The first is free; a reprint or a cancel spends an approval. A change to
    # the order supersedes the current one.
    class PrebillPrint < Record
      self.table_name = 'spree_pos_prebill_prints'
      has_prefix_id :posprebill

      STATUSES = %w[current superseded canceled].freeze
      REPRINT_ACTION = 'workspace.reprint_prebill'
      CANCEL_ACTION = 'workspace.cancel_prebill'

      belongs_to :workspace, class_name: 'Spree::Pos::Workspace'
      belongs_to :staff, class_name: staff_class_name
      belongs_to :approval, class_name: 'Spree::Pos::Approval', optional: true

      validates :status, inclusion: { in: STATUSES }
      validates :sequence, numericality: { only_integer: true, greater_than: 0 }
      validates :revision, :total, :currency, presence: true

      def to_pos
        { id: prefixed_id, sequence: sequence, revision: revision, status: status, total: total.to_s('F'), currency: currency,
          staff_id: staff.prefixed_id, approval_id: approval&.prefixed_id, printed_at: created_at.iso8601 }
      end
    end
  end
end

# frozen_string_literal: true

module Spree
  module Pos
    # One line of a kept bottle's history. Written once and never changed.
    class BottleKeepEvent < Record
      self.table_name = 'spree_pos_bottle_keep_events'
      has_prefix_id :posbottleevent

      KINDS = %w[open pour adjust expire return].freeze

      belongs_to :bottle_keep, class_name: 'Spree::Pos::BottleKeep', inverse_of: :events
      belongs_to :workspace, class_name: 'Spree::Pos::Workspace', optional: true
      belongs_to :approval, class_name: 'Spree::Pos::Approval', optional: true
      belongs_to :actor, class_name: staff_class_name

      validates :kind, inclusion: { in: KINDS }
      validates :level_after, numericality: { only_integer: true, in: 0..100 }
      validates :level_before, numericality: { only_integer: true, in: 0..100 }, allow_nil: true
      validates :ml, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
      validates :note, length: { maximum: 200 }

      before_update { raise ActiveRecord::ReadOnlyRecord, 'Bottle keep history is append-only.' }
      before_destroy { raise ActiveRecord::ReadOnlyRecord, 'Bottle keep history is append-only.' }

      def to_pos
        {
          id: prefixed_id, kind: kind, level_before: level_before, level_after: level_after, ml: ml,
          workspace_id: workspace&.prefixed_id, approval_id: approval&.prefixed_id,
          actor: { id: actor.prefixed_id, name: KitchenSend.staff_name(actor) }, note: note, created_at: created_at.iso8601
        }
      end
    end
  end
end

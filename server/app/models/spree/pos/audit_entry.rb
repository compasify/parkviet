# frozen_string_literal: true

module Spree
  module Pos
    class AuditEntry < Record
      self.table_name = 'spree_pos_audit_entries'
      has_prefix_id :posaudit

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :actor, class_name: staff_class_name

      validates :action, :subject_type, :subject_id, presence: true

      def self.record!(store:, actor:, action:, subject:, metadata: {})
        create!(
          store: store,
          actor: actor,
          action: action,
          subject_type: subject.class.name,
          subject_id: subject.id,
          metadata: metadata
        )
      end
    end
  end
end

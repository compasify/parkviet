# frozen_string_literal: true

module Spree
  module Pos
    # A guest calling staff or asking for the bill from their phone. One
    # open request of each kind per phone; staff mark it done.
    class GuestRequest < Record
      self.table_name = 'spree_pos_guest_requests'
      has_prefix_id :posguestreq

      KINDS = %w[call_staff request_bill].freeze
      STATUSES = %w[open done].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :guest_session, class_name: 'Spree::Pos::GuestSession'
      belongs_to :resource, class_name: 'Spree::Pos::Resource'
      belongs_to :workspace, class_name: 'Spree::Pos::Workspace', optional: true
      belongs_to :handled_by, class_name: staff_class_name, optional: true

      validates :kind, inclusion: { in: KINDS }
      validates :status, inclusion: { in: STATUSES }

      scope :still_open, -> { where(status: 'open') }

      def to_pos
        { id: prefixed_id, branch_id: branch.prefixed_id, resource_id: resource.prefixed_id, table_name: resource.name,
          area_id: resource.area&.prefixed_id, workspace_id: workspace&.prefixed_id, kind: kind, status: status,
          handled_by_name: StaffName.call(handled_by), handled_at: handled_at&.iso8601, created_at: created_at.iso8601 }
      end

      def to_guest
        { id: prefixed_id, kind: kind, status: status, created_at: created_at.iso8601 }
      end
    end
  end
end

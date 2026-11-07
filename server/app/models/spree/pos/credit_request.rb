# frozen_string_literal: true

module Spree
  module Pos
    # A cashier asks a manager to approve the unpaid remainder of one workspace
    # revision on credit. Approving it grants the action-bound Approval and
    # reserves exposure; any later revision of the workspace makes it stale.
    class CreditRequest < Record
      self.table_name = 'spree_pos_credit_requests'
      has_prefix_id :poscreditreq

      STATUSES = %w[pending approved rejected stale].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :branch, class_name: 'Spree::Pos::Branch'
      belongs_to :workspace, class_name: 'Spree::Pos::Workspace'
      belongs_to :customer_profile, class_name: 'Spree::Pos::CustomerProfile'
      belongs_to :requester, class_name: staff_class_name
      belongs_to :decided_by, class_name: staff_class_name, optional: true
      belongs_to :credit_reservation, class_name: 'Spree::Pos::CreditReservation', optional: true

      validates :status, inclusion: { in: STATUSES }
      validates :currency, presence: true
      validates :amount, numericality: { greater_than: 0 }

      scope :for_store, ->(store) { where(store_id: store.id) }

      # Pending and still for the workspace's current, editable snapshot.
      scope :actionable, lambda {
        joins(:workspace).where(status: 'pending', spree_pos_workspaces: { operational_status: 'editing' }).
          where('spree_pos_workspaces.revision = spree_pos_credit_requests.workspace_revision')
      }

      def current_status
        return status unless status == 'pending'

        workspace.operational_status == 'editing' && workspace.revision == workspace_revision ? 'pending' : 'stale'
      end

      def to_pos
        reservation = credit_reservation
        {
          id: prefixed_id, branch_id: branch.prefixed_id, workspace_id: workspace.prefixed_id,
          order_number: workspace.order.number, customer: { id: customer_profile.prefixed_id, name: customer_profile.name },
          requester: { id: requester.prefixed_id, name: requester.try(:full_name).presence || requester.email },
          amount: amount.to_s('F'), currency: currency, workspace_revision: workspace_revision,
          status: current_status, reason: reason, created_at: created_at&.iso8601, decided_at: decided_at&.iso8601,
          approval_id: reservation&.approval&.prefixed_id,
          approval_active: reservation.present? && reservation.status == 'active' && reservation.approval.status == 'active'
        }
      end
    end
  end
end

# frozen_string_literal: true

module Spree
  module Pos
    # Exposure held by one approved credit amount on one workspace snapshot.
    # It counts against the limit only while it is still usable: its approval
    # is active and unexpired, and the workspace is still editing the same
    # revision for the same customer. Once any of those changes it can never
    # become usable again, so stale rows stop counting without a sweep and are
    # marked released (with audit) whenever a command meets them.
    class CreditReservation < Record
      self.table_name = 'spree_pos_credit_reservations'
      has_prefix_id :poscreditres

      STATUSES = %w[active committed released].freeze

      belongs_to :store, class_name: 'Spree::Store'
      belongs_to :credit_account, class_name: 'Spree::Pos::CreditAccount'
      belongs_to :workspace, class_name: 'Spree::Pos::Workspace'
      belongs_to :approval, class_name: 'Spree::Pos::Approval'
      belongs_to :customer_profile, class_name: 'Spree::Pos::CustomerProfile'

      validates :status, inclusion: { in: STATUSES }
      validates :currency, presence: true
      validates :amount, numericality: { greater_than: 0 }

      scope :for_store, ->(store) { where(store_id: store.id) }
      scope :active_now, -> { where(status: 'active') }

      # Active rows that still hold exposure, decided entirely in SQL so a
      # limit check under the account lock sees one consistent answer.
      scope :holding, lambda {
        active_now.
          joins(:approval, :workspace).
          where(spree_pos_approvals: { status: 'active', revoked_at: nil, consumed_at: nil }).
          where('spree_pos_approvals.expires_at > clock_timestamp()').
          where(spree_pos_workspaces: { operational_status: 'editing' }).
          where('spree_pos_workspaces.revision = spree_pos_credit_reservations.workspace_revision').
          where('spree_pos_workspaces.pos_customer_id = spree_pos_credit_reservations.customer_profile_id')
      }

      def holding?
        status == 'active' && self.class.holding.where(id: id).exists?
      end

      def to_pos
        {
          id: prefixed_id, credit_account_id: credit_account.prefixed_id, workspace_id: workspace.prefixed_id,
          approval_id: approval.prefixed_id, customer_id: customer_profile.prefixed_id,
          amount: amount.to_s('F'), currency: currency, workspace_revision: workspace_revision,
          status: status, usable: holding?, released_reason: released_reason,
          approver: { id: approval.approver.prefixed_id, name: approval.approver.try(:full_name).presence || approval.approver.email },
          expires_at: approval.expires_at.iso8601
        }
      end
    end
  end
end

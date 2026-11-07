# frozen_string_literal: true

module Spree
  module Pos
    module Approvals
      # Revokes an active approval. A revoked credit approval gives its
      # reserved exposure back at once. Lock order matches completion:
      # workspace -> reservation -> approval.
      class Revoke
        def self.call(approval:, staff:)
          ApplicationRecord.transaction do
            workspace = approval.subject_type == Workspace.name ? Workspace.find_by(id: approval.subject_id) : nil
            workspace&.lock!
            reservation = CreditReservation.active_now.lock.find_by(approval_id: approval.id) if approval.action == Credit::ACTION
            approval.revoke!
            AuditEntry.record!(store: approval.store, actor: staff, action: 'approval.revoke', subject: approval, metadata: {})
            if reservation && workspace
              reservation.update!(status: 'released', released_reason: 'approval_revoked', released_at: Time.current)
              AuditEntry.record!(store: approval.store, actor: staff, action: 'credit.release', subject: workspace,
                                 metadata: { reservation_id: reservation.prefixed_id, approval_id: approval.prefixed_id,
                                             amount: reservation.amount.to_s('F'), reason: 'approval_revoked' })
            end
            approval
          end
        end
      end
    end
  end
end

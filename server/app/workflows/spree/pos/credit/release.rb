# frozen_string_literal: true

module Spree
  module Pos
    module Credit
      # Gives back the exposure of a workspace's active reservations and
      # revokes their approvals, with one audit entry each. Callers hold the
      # workspace lock (through CommandExecutor) so a release cannot race the
      # commit of the same reservation.
      class Release
        def self.call(workspace:, actor:, reason:, only_stale: false)
          CreditReservation.active_now.where(workspace_id: workspace.id).order(:id).lock.to_a.each do |reservation|
            next if only_stale && reservation.holding?

            reservation.update!(status: 'released', released_reason: reason, released_at: Time.current)
            approval = reservation.approval.lock!
            approval.update!(status: 'revoked', revoked_at: Time.current) if approval.status == 'active'
            AuditEntry.record!(store: workspace.store, actor: actor, action: 'credit.release', subject: workspace,
                               metadata: { reservation_id: reservation.prefixed_id, approval_id: approval.prefixed_id,
                                           amount: reservation.amount.to_s('F'), reason: reason })
          end
        end

        # Runs after every workspace command: a reservation or pending request
        # whose snapshot moved on (new revision, other customer, no longer
        # editing, expired or revoked approval) is closed with an audit instead
        # of lingering until someone notices.
        def self.sweep!(workspace:, actor:)
          call(workspace: workspace, actor: actor, reason: 'snapshot_changed', only_stale: true)
          CreditRequest.where(workspace_id: workspace.id, status: 'pending').
            where.not(id: CreditRequest.actionable.select(:id)).
            update_all(status: 'stale', updated_at: Time.current)
        end

        # A refused completion rolls its own transaction back, so the release
        # of the reservations it found unusable is written separately.
        def self.stale!(workspace:, actor:, reason: 'stale_at_completion')
          ApplicationRecord.transaction do
            workspace.lock!
            call(workspace: workspace, actor: actor, reason: reason, only_stale: true)
          end
        end
      end
    end
  end
end

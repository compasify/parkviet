# frozen_string_literal: true

module Spree
  module Pos
    module Tenders
      # Releases a prepared (never confirmed) commitment so the snapshot can
      # be edited again. Confirmed money is a fact and cannot be canceled.
      class Cancel
        def self.call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, attempt_id:)
          payload = {
            'command' => 'tender.cancel', 'revision' => revision, 'lease_generation' => lease_generation,
            'editor_digest' => Workspace.editor_digest(editor_id), 'attempt_id' => attempt_id.to_s
          }
          authorize = lambda do
            Guard.authorize_editor!(workspace, staff)
            Guard.authorize_collect!(workspace, staff)
          end
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace, authorize: authorize) do
            Guard.validate_editor!(workspace, staff, revision, lease_generation, editor_id)
            attempt = TenderAttempt.locate(TenderAttempt.where(workspace_id: workspace.id), attempt_id)
            raise ActiveRecord::RecordNotFound if attempt.nil?
            raise Conflict, 'Only a prepared tender can be canceled.' unless attempt.status == 'prepared'

            attempt.update!(status: 'canceled', canceled_at: Time.current)
            workspace.update!(revision: workspace.revision + 1)
            AuditEntry.record!(store: workspace.store, actor: staff, action: 'tender.cancel', subject: workspace,
                               metadata: { attempt_id: attempt.prefixed_id })
            workspace.to_pos
          end
        end
      end
    end
  end
end

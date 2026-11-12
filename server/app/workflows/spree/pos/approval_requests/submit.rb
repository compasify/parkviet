# frozen_string_literal: true

module Spree
  module Pos
    module ApprovalRequests
      # The person who got `approval_required` asks for that approval from
      # another device. Checked like an approval at the counter would be
      # (Approvals::Issue.check!), but nobody approves yet. Asking again for
      # the same thing answers the pending request; asking for the same
      # action on a newer revision cancels the older request.
      module Submit
        COMMAND = 'approval_request.submit'

        module_function

        def call(store:, staff:, key:, branch:, subject:, action:, revision:, amount:, reason:)
          action = action.to_s
          note = reason.to_s.squish.presence
          raise Conflict.new('This action cannot be approved remotely.', reason: 'approval_action_invalid') unless ApprovalRequest::ACTIONS.include?(action)
          raise Conflict.new('Reason is too long.', reason: 'reason_invalid') if note && note.length > ApprovalRequest::REASON_MAX

          payload = { 'command' => COMMAND, 'branch_id' => branch.prefixed_id, 'subject_id' => subject.prefixed_id, 'action' => action,
                      'revision' => revision.to_s, 'amount' => amount&.to_s('F'), 'reason' => note }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: lambda {
                                 Approvals::Issue.check!(store: store, branch: branch, requester: staff, subject: subject,
                                                         action: action, revision: revision)
                               }) do
            ApprovalRequest.expire_due!(ApprovalRequest.where(requester_id: staff.id))
            mine = ApprovalRequest.pending.lock.where(requester_id: staff.id, subject_type: subject.class.name, subject_id: subject.id,
                                                      action: action).to_a
            same = mine.find { |row| row.revision == revision.to_s && row.amount == amount }
            next { 'approval_request' => same.to_pos } if same

            mine.each { |row| Decide.finish!(row, 'canceled', staff) }
            request = ApprovalRequest.create!(
              store: store, branch: branch, requester: staff, action: action, subject_type: subject.class.name,
              subject_id: subject.id, revision: revision.to_s, amount: amount, currency: amount ? store.default_currency : nil,
              reason: note, status: 'pending', expires_at: Time.current + ApprovalRequest::TTL
            )
            AuditEntry.record!(store: store, actor: staff, action: 'approval_request.submit', subject: request,
                               metadata: { approval_action: action, revision: revision.to_s, amount: amount&.to_s('F') })
            Realtime.publish(branch, 'approval_request.created', id: request.prefixed_id,
                                                                 refs: { Approvals::Issue::REFS.fetch(subject.class.name) => subject.prefixed_id })
            Push.notify(branch, 'approval_request.created', request, except: staff)
            { 'approval_request' => request.to_pos }
          end
        end
      end
    end
  end
end

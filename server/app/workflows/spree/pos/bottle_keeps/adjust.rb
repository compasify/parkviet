# frozen_string_literal: true

module Spree
  module Pos
    module BottleKeeps
      # Corrects a kept bottle's level by hand, up or down, with a reason.
      # Needs an approval of `bottle_keep.adjust` bound to the bottle's
      # revision unless the person may approve. The history keeps the old
      # level next to the new one.
      module Adjust
        ACTION = Approval::BOTTLE_KEEP_ADJUST_ACTION

        module_function

        def call(store:, staff:, key:, keep_id:, level_percent:, note:, revision:, approval_id: nil)
          keep = Guard.keep_record!(store, keep_id)
          payload = { 'command' => ACTION, 'keep_id' => keep.prefixed_id, 'level_percent' => level_percent.to_s,
                      'note' => note.to_s.squish, 'revision' => revision.to_s, 'approval_id' => approval_id.to_s.presence }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { Guard.keep!(store, staff, keep.branch) }) do
            ModulePolicy.require!(keep.branch, Guard::MODULE)
            keep.lock!
            Guard.kept!(keep)
            level = Guard.level!(level_percent)
            raise Conflict.new('Say why the level is corrected.', reason: 'bottle_note_required') if note.to_s.squish.empty?
            if keep.revision.to_s != revision.to_s
              raise Conflict.new('The bottle changed; read it again.', reason: 'bottle_keep_changed', revision: keep.revision)
            end

            approval = approve!(keep, staff, approval_id)
            before = keep.level_percent
            finished = level.zero?
            keep.update!(level_percent: level, status: finished ? 'finished' : 'kept', closed_at: finished ? Time.current : nil,
                         revision: keep.revision + 1)
            Guard.event!(keep, kind: 'adjust', actor: staff, level_before: before, level_after: level, approval: approval, note: note)
            Guard.audit!(keep, staff, ACTION, level_before: before, note: note.to_s.squish,
                                              approval_id: approval&.prefixed_id, approver_id: approval&.approver&.prefixed_id)
            keep.reload.to_pos(with_events: true)
          end
        end

        def approve!(keep, staff, approval_id)
          return nil if AccessPolicy.new(store: keep.store, staff: staff).allows?(keep.branch, Capabilities::APPROVE)

          message = 'Correcting a kept bottle needs approval.'
          details = { action: ACTION, subject_id: keep.prefixed_id, revision: keep.revision }
          raise Conflict.new(message, reason: 'approval_required', details: details) if approval_id.blank?

          approval = Approval.locate(Approval.for_store(keep.store).where(branch_id: keep.branch_id), approval_id)
          raise Conflict.new(message, reason: 'approval_required', details: details) if approval.nil?

          approval.consume!(action: ACTION, amount: nil, currency: nil, revision: keep.revision, subject: keep, requester: staff)
          AuditEntry.record!(store: keep.store, actor: staff, action: 'approval.consume', subject: approval,
                             metadata: { approval_action: ACTION, approver_id: approval.approver.prefixed_id })
          approval
        end
      end
    end
  end
end

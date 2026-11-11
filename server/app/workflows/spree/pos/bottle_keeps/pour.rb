# frozen_string_literal: true

module Spree
  module Pos
    module BottleKeeps
      # Pours from a kept bottle: the new level (never above the old one),
      # optionally the ml and the order the guest drinks it at, and a new
      # photo. Free: nothing is added to any bill. A bottle poured to zero is
      # finished.
      module Pour
        module_function

        def call(store:, staff:, key:, keep_id:, level_percent:, ml: nil, workspace: nil, photo: nil, note: nil)
          keep = Guard.keep_record!(store, keep_id)
          upload = Guard.photo!(photo)
          payload = { 'command' => 'bottle_keep.pour', 'keep_id' => keep.prefixed_id, 'level_percent' => level_percent.to_s,
                      'ml' => ml.to_s.presence, 'workspace_id' => workspace&.prefixed_id, 'note' => note.to_s.squish.presence,
                      'photo' => Guard.photo_digest(upload) }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { Guard.keep!(store, staff, keep.branch) }) do
            ModulePolicy.require!(keep.branch, Guard::MODULE)
            keep.lock!
            Guard.kept!(keep)
            level = Guard.level!(level_percent)
            amount = Guard.ml!(ml)
            if level > keep.level_percent
              raise Conflict.new('Pouring cannot raise the level; correct it instead.', reason: 'bottle_level_raised',
                                                                                       details: { level_percent: keep.level_percent })
            end
            raise Conflict, 'This order is not of the bottle\'s branch.' if workspace && workspace.branch_id != keep.branch_id

            before = keep.level_percent
            finished = level.zero?
            keep.update!(level_percent: level, status: finished ? 'finished' : 'kept', closed_at: finished ? Time.current : nil,
                         revision: keep.revision + 1)
            Guard.attach!(keep, upload)
            Guard.event!(keep, kind: 'pour', actor: staff, level_before: before, level_after: level, ml: amount, workspace: workspace,
                               note: note)
            Guard.audit!(keep, staff, 'bottle_keep.pour', level_before: before, ml: amount, workspace_id: workspace&.prefixed_id)
            keep.reload.to_pos(with_events: true)
          end
        end
      end
    end
  end
end

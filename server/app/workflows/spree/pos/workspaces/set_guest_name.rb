# frozen_string_literal: true

module Spree
  module Pos
    module Workspaces
      # The name the counter calls out with the call number, printed on the
      # cup labels and the kitchen ticket. It moves no money, so it can
      # change while a payment is under way, until the sale is completed.
      # A blank name clears it; the same name changes nothing.
      class SetGuestName
        MODULES = [OrderNumbers::MODULE, CupLabels::Issue::MODULE].freeze

        def self.call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, guest_name:)
          value = guest_name.to_s.squish.presence
          payload = {
            'command' => 'guest_name.set', 'revision' => revision, 'lease_generation' => lease_generation,
            'editor_digest' => Workspace.editor_digest(editor_id), 'guest_name' => value
          }
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace,
                               authorize: -> { Deliveries::Assign.authorize!(workspace, staff) }) do
            Deliveries::Assign.validate_editing!(workspace, staff, revision, lease_generation, editor_id)
            ModulePolicy.require!(workspace.branch, MODULES.first) unless MODULES.any? { |name| ModulePolicy.enabled?(workspace.branch, name) }
            if value && value.length > Workspace::GUEST_NAME_MAX
              raise Conflict.new("The guest name must be at most #{Workspace::GUEST_NAME_MAX} characters.",
                                 revision: workspace.revision, reason: 'guest_name_invalid')
            end

            if workspace.guest_name != value
              before = workspace.guest_name
              workspace.update!(guest_name: value, revision: workspace.revision + 1)
              AuditEntry.record!(store: workspace.store, actor: staff, action: 'workspace.guest_name.set', subject: workspace,
                                 metadata: { before: before, guest_name: value })
            end
            workspace.to_pos
          end
        end
      end
    end
  end
end

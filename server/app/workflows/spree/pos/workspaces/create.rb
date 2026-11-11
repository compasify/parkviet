# frozen_string_literal: true

module Spree
  module Pos
    module Workspaces
      class Create
        def self.call(store:, staff:, key:, editor_id:, register_id: nil, branch_id: nil, service_mode: nil)
          mode = service_mode.presence&.to_s || 'counter'
          unless Workspace::SERVICE_MODES.include?(mode)
            raise Conflict.new('Service mode is invalid.', reason: 'service_mode_invalid')
          end

          editor_digest = Workspace.editor_digest(editor_id)
          payload = { 'command' => 'create', 'register_id' => register_id.to_s, 'editor_digest' => editor_digest, 'service_mode' => mode }
          payload['branch_id'] = branch_id.to_s if register_id.blank?
          selection_shift = lambda do
            if register_id.present?
              register = Register.locate(Register.for_store(store), register_id)
              raise ActiveRecord::RecordNotFound if register.nil?
              raise CanCan::AccessDenied if branch_id.present? && register.branch.prefixed_id != branch_id

              [Shift.for_store(store).open_now.find_by(register_id: register.id, owner_id: staff.id), register]
            else
              policy = AccessPolicy.new(store: store, staff: staff)
              branch = Branch.locate(policy.visible_branches, branch_id)
              raise ActiveRecord::RecordNotFound if branch.nil?
              raise CanCan::AccessDenied unless policy.can_open_branch_shift?(branch)

              [Shift.for_store(store).open_now.find_by(branch_id: branch.id, register_id: nil, owner_id: staff.id), nil]
            end
          end
          authorize = lambda do
            shift, register = selection_shift.call
            policy = AccessPolicy.new(store: store, staff: staff)
            raise CanCan::AccessDenied if shift.nil? || (register && !policy.can_open_shift?(register)) || !policy.permission?('write_pos_orders')
          end
          CommandExecutor.call(store:, actor: staff, key:, payload:, authorize:, replay_authorize: replay_authorize(store, staff)) do
            shift, = selection_shift.call
            raise CanCan::AccessDenied if shift.nil?

            workspace = draft!(store: store, staff: staff, shift: shift, editor_digest: editor_digest, service_mode: mode)
            AuditEntry.record!(store: store, actor: staff, action: 'workspace.create', subject: workspace)
            workspace.to_pos
          end
        end

        # A new draft on `shift`, its lease held by `staff`. Shared with the
        # commands that open an order at a table (`attributes`: the table,
        # guest count and label).
        def self.draft!(store:, staff:, shift:, editor_digest:, service_mode:, **attributes)
          draft = ::Pos::CreateWalkInDraft.call(store: store, staff: staff)
          unless draft.respond_to?(:success?) && draft.success?
            record = draft.respond_to?(:value) ? draft.value : nil
            raise ActiveRecord::RecordInvalid, record if record.respond_to?(:errors)

            raise ActiveRecord::RecordNotSaved, 'Walk-in draft was not created.'
          end

          Workspace.create!(
            store: store,
            branch: shift.branch,
            register: shift.register,
            shift: shift,
            order: draft.value,
            revision: 0,
            lease_generation: 1,
            lease_holder: staff,
            lease_editor_digest: editor_digest,
            lease_expires_at: Workspace.database_now + Workspace::LEASE_TTL,
            operational_status: 'editing',
            service_mode: service_mode,
            business_date: BusinessDay.for(shift.branch, Workspace.business_now),
            **attributes
          )
        end

        # A lost response is recovered from the receipt even after the shift
        # that allowed the draft closed, as long as the same staff member
        # still works at that branch with the POS order permission.
        def self.replay_authorize(store, staff)
          lambda do |receipt|
            policy = AccessPolicy.new(store: store, staff: staff)
            branch = receipt.workspace&.branch
            member = branch && policy.membership_for(branch)
            raise CanCan::AccessDenied unless member&.status == 'active' && policy.permission?('write_pos_orders')
          end
        end
      end
    end
  end
end

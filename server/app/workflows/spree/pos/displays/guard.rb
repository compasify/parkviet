# frozen_string_literal: true

module Spree
  module Pos
    module Displays
      # Who may drive a display: the owner of the bound open shift, while
      # they still hold an active selling membership at its branch.
      module Guard
        module_function

        def own_shift!(store, staff, shift_id)
          shift = Shift.locate(Shift.for_store(store), shift_id)
          raise ActiveRecord::RecordNotFound if shift.nil? || shift.owner_id != staff.id
          raise Conflict.new('Shift is closed.', reason: 'shift_closed') unless shift.open?

          authorize_branch!(store, staff, shift.branch)
          shift
        end

        def authorize_branch!(store, staff, branch)
          policy = AccessPolicy.new(store: store, staff: staff)
          raise CanCan::AccessDenied unless policy.allows?(branch, Capabilities::OPEN_SHIFT)
        end

        def session!(store, staff, session_id)
          session = DisplaySession.locate(DisplaySession.for_store(store).where(staff_id: staff.id), session_id)
          raise ActiveRecord::RecordNotFound if session.nil?

          session
        end

        def usable!(session)
          return if session.usable?

          raise Conflict.new('The customer display is no longer connected; bind it again.', reason: 'display_inactive')
        end
      end
    end
  end
end

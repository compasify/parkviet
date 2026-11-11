# frozen_string_literal: true

module Spree
  module Pos
    module ApplicationCable
      # Who a socket belongs to and which branches it may hear.
      #
      # Staff need a role on the branch's store and an active membership there
      # granting a capability that reads that branch's work: opening a shift or
      # taking over are exactly what `visible_workspaces` admits, and approvers
      # are who `approval.requested` is for. `visible_branches` is deliberately
      # not the rule: a store-wide topology permission lists every branch but
      # reads no workspace in any of them.
      class Principal
        STAFF_CAPABILITIES = [Capabilities::OPEN_SHIFT, Capabilities::TAKEOVER, Capabilities::APPROVE].freeze

        attr_reader :kind, :device, :staff

        def self.for_staff(staff)
          new(kind: :staff, staff: staff)
        end

        def self.for_device(device, session = nil)
          new(kind: session ? :device_staff : :device, device: device, staff: session&.staff, session: session)
        end

        def initialize(kind:, device: nil, staff: nil, session: nil)
          @kind = kind
          @device = device
          @staff = staff
          @session = session
        end

        def may_read?(branch)
          device ? own_branch?(device, branch) : staff_works_at?(branch)
        end

        # A socket outlives its credentials, so this re-reads what they stood
        # for. It never touches a staff session: an open socket is not activity.
        def still_valid?(branch)
          return staff_works_at?(branch) unless device

          current = Device.active.find_by(id: device.id, generation: device.generation)
          return false if current.nil? || !own_branch?(current, branch)

          @session.nil? || @session.reload.usable?
        rescue ActiveRecord::RecordNotFound
          false
        end

        private

        def own_branch?(owner, branch)
          owner.branch_id == branch.id && owner.store_id == branch.store_id
        end

        def staff_works_at?(branch)
          return false unless staff.spree_roles.for_resource(branch.store).exists?

          membership = AccessPolicy.new(store: branch.store, staff: staff).membership_for(branch)
          membership.present? && STAFF_CAPABILITIES.any? { |capability| membership.allows?(capability) }
        end
      end
    end
  end
end

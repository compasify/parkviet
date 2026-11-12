# frozen_string_literal: true

module Spree
  module Pos
    module ApplicationCable
      # Who a socket belongs to and which branches it may hear.
      #
      # Staff need a role on the branch's store and an active membership there
      # granting a capability that reads that branch's work: opening a shift or
      # taking over are exactly what `visible_workspaces` admits, and approvers
      # are who `approval.requested` is for, as deciders of guest orders are
      # who `guest_order.created` is for. `visible_branches` is deliberately
      # not the rule: a store-wide topology permission lists every branch but
      # reads no workspace in any of them.
      class Principal
        STAFF_CAPABILITIES = [Capabilities::OPEN_SHIFT, Capabilities::TAKEOVER, Capabilities::APPROVE,
                              Capabilities::GUEST_ORDER_DECIDE].freeze
        # An owner's phone also follows the branches its person only reads
        # reports of: their day and alerts.
        OWNER_CAPABILITIES = (STAFF_CAPABILITIES + [Capabilities::REPORT_READ]).freeze

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

        # An owner's phone follows its person: any branch of its store that
        # person works at, not only the branch it was paired at.
        def may_read?(branch)
          return staff_works_at?(branch) unless device

          own_branch?(device, branch) || roaming?(device, branch)
        end

        # A socket outlives its credentials, so this re-reads what they stood
        # for. It never touches a staff session: an open socket is not activity.
        def still_valid?(branch)
          return staff_works_at?(branch) unless device

          current = Device.active.find_by(id: device.id, generation: device.generation)
          return false if current.nil? || !(own_branch?(current, branch) || roaming?(current, branch))

          @session.nil? || @session.reload.usable?
        rescue ActiveRecord::RecordNotFound
          false
        end

        private

        def own_branch?(owner, branch)
          owner.branch_id == branch.id && owner.store_id == branch.store_id
        end

        def roaming?(owner, branch)
          owner.mode == 'owner' && staff.present? && owner.store_id == branch.store_id && staff_works_at?(branch, OWNER_CAPABILITIES)
        end

        def staff_works_at?(branch, capabilities = STAFF_CAPABILITIES)
          return false unless staff.spree_roles.for_resource(branch.store).exists?

          membership = AccessPolicy.new(store: branch.store, staff: staff).membership_for(branch)
          membership.present? && capabilities.any? { |capability| membership.allows?(capability) }
        end
      end
    end
  end
end

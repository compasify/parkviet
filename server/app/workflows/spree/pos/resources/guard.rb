# frozen_string_literal: true

module Spree
  module Pos
    module Resources
      # Who keeps a branch's floor plan, and who reads it.
      module Guard
        MODULE = 'resources'

        module_function

        def manage!(store, staff, branch)
          access = AccessPolicy.new(store: store, staff: staff)
          return if access.permission?('write_pos_topology') || access.allows?(branch, Capabilities::RESOURCE_MANAGE)

          raise CanCan::AccessDenied
        end

        # Marking a table cleaning or back in use: managers, and the people
        # serving tables or selling at the branch.
        def mark!(store, staff, branch)
          access = AccessPolicy.new(store: store, staff: staff)
          return if access.permission?('write_pos_topology')
          return if [Capabilities::RESOURCE_MANAGE, Capabilities::TABLE_SERVE, Capabilities::OPEN_SHIFT].any? { |key| access.allows?(branch, key) }

          raise CanCan::AccessDenied
        end

        def read!(store, staff, branch)
          access = AccessPolicy.new(store: store, staff: staff)
          raise ActiveRecord::RecordNotFound unless access.membership_for(branch)&.status == 'active' || access.permission?('read_pos_topology')
        end

        def branch!(store, branch_id)
          Branch.locate(Branch.for_store(store), branch_id) || raise(ActiveRecord::RecordNotFound)
        end

        def area!(branch, area_id)
          Area.locate(Area.where(branch_id: branch.id), area_id) || raise(ActiveRecord::RecordNotFound)
        end

        def resource!(branch, resource_id)
          Resource.locate(Resource.where(branch_id: branch.id), resource_id) || raise(ActiveRecord::RecordNotFound)
        end

        def changed!(branch, record)
          Realtime.publish(branch, 'resource.updated', id: record.prefixed_id)
        end
      end
    end
  end
end

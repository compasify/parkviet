# frozen_string_literal: true

module Spree
  module Pos
    module Menu
      # Who may read and change the menu. The menu belongs to the store:
      # changing it takes pos.menu.manage at one active branch of the store,
      # or store administration. Branch settings (sold out, favourites) take
      # the capability at that branch. A kitchen screen marks items sold out
      # for the person signed in on it.
      module Guard
        MODULE = 'fnb.menu'

        module_function

        def policy(store, staff)
          AccessPolicy.new(store: store, staff: staff)
        end

        def manage!(store, staff)
          access = policy(store, staff)
          return if access.permission?('write_pos_topology')

          allowed = access.memberships.any? { |membership| membership.status == 'active' && membership.allows?(Capabilities::MANAGE_MENU) }
          raise CanCan::AccessDenied unless allowed
        end

        def manage_branch!(store, staff, branch)
          access = policy(store, staff)
          raise CanCan::AccessDenied unless access.allows?(branch, Capabilities::MANAGE_MENU) || access.permission?('write_pos_topology')
        end

        def sold_out!(store, staff, branch, device: nil)
          access = policy(store, staff)
          return if access.permission?('write_pos_topology')
          return if [Capabilities::SET_SOLD_OUT, Capabilities::MANAGE_MENU].any? { |capability| access.allows?(branch, capability) }

          kitchen = device&.mode == 'kds' && device.branch_id == branch.id && access.membership_for(branch)&.status == 'active'
          raise CanCan::AccessDenied unless kitchen
        end

        # The people working at a branch read its menu: the counter sells from it.
        def read!(store, staff, branch)
          access = policy(store, staff)
          raise ActiveRecord::RecordNotFound unless access.membership_for(branch)&.status == 'active' || access.permission?('read_pos_topology')
        end

        def branch!(store, branch_id)
          Branch.locate(Branch.for_store(store), branch_id) || raise(ActiveRecord::RecordNotFound)
        end

        def menu_item!(store, menu_item_id)
          MenuItem.locate(MenuItem.for_store(store), menu_item_id) || raise(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end

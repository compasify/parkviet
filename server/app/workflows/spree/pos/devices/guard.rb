# frozen_string_literal: true

module Spree
  module Pos
    module Devices
      # Who may pair and revoke devices at a branch: a member holding
      # pos.device.manage, or a store administrator.
      module Guard
        module_function

        def manage?(store, staff, branch)
          policy = AccessPolicy.new(store: store, staff: staff)
          policy.allows?(branch, Capabilities::DEVICE_MANAGE) || policy.permission?('write_pos_topology')
        end

        def manage!(store, staff, branch)
          raise CanCan::AccessDenied unless manage?(store, staff, branch)
        end

        def branch!(store, branch_id)
          Branch.for_store(store).find_by_prefix_id!(branch_id)
        end

        def device!(store, device_id)
          Device.for_store(store).find_by_prefix_id!(device_id)
        end

        def register!(branch, register_id)
          raise Conflict.new('A kiosk pairing needs a register.', reason: 'register_required') if register_id.blank?

          register = Register.find_by_prefix_id!(register_id)
          raise ActiveRecord::RecordNotFound if register.store_id != branch.store_id || register.branch_id != branch.id

          register
        end
      end
    end
  end
end

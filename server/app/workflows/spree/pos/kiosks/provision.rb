# frozen_string_literal: true

module Spree
  module Pos
    module Kiosks
      # The service account of a kiosk device. Pairing a device as a kiosk
      # creates it (or turns it back on), with a store role holding only the
      # order permissions and a membership holding only what a kiosk needs.
      # It has no PIN and nobody knows its password: only the device's
      # credential reaches it. Revoking the device, or pairing it again in
      # another mode, turns the account off. Runs in the caller's transaction.
      module Provision
        module_function

        def call(device:, actor:)
          membership = StaffMembership.find_by(device_id: device.id)
          return revoke!(device: device, actor: actor) unless device.mode == 'kiosk' && device.status == 'active'

          if membership
            reactivate!(membership, device)
          else
            membership = create!(device)
          end
          AuditEntry.record!(store: device.store, actor: actor, action: 'kiosk.provision', subject: device,
                             metadata: { membership_id: membership.prefixed_id, register_id: device.register&.prefixed_id })
          membership
        end

        def revoke!(device:, actor:)
          membership = StaffMembership.find_by(device_id: device.id)
          return if membership.nil? || membership.disabled?

          membership.update!(status: 'disabled', disabled_at: Time.current)
          AuditEntry.record!(store: device.store, actor: actor, action: 'kiosk.deprovision', subject: device,
                             metadata: { membership_id: membership.prefixed_id })
          nil
        end

        def create!(device)
          password = SecureRandom.urlsafe_base64(48)
          user = Spree.admin_user_class.create!(email: "kiosk-#{SecureRandom.hex(10)}@kiosk.pos.invalid", password: password,
                                                password_confirmation: password, first_name: 'Kiosk',
                                                last_name: device.name.to_s.first(60))
          Spree::RoleUser.create!(role: role!(device.store), user: user)
          StaffMembership.create!(store: device.store, branch: device.branch, staff: user, capabilities: Policy::CAPABILITIES,
                                  status: 'active', service_account: true, device: device)
        end

        # The account follows the device to its branch while it has no work there.
        def reactivate!(membership, device)
          if membership.branch_id != device.branch_id
            raise Conflict.new('This kiosk worked at another branch; pair a new device.', reason: 'kiosk_branch_changed')
          end

          membership.update!(status: 'active', disabled_at: nil, capabilities: Policy::CAPABILITIES, staff_role: nil)
        end

        def role!(store)
          Spree::Role.find_or_create_by!(name: Policy::ROLE_NAME, resource: store) do |role|
            role.permissions = Policy::PERMISSIONS
            role.description = 'Self-ordering kiosks (service accounts)'
          end
        end
      end
    end
  end
end

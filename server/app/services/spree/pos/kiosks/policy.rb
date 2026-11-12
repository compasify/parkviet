# frozen_string_literal: true

module Spree
  module Pos
    module Kiosks
      # What a self-ordering kiosk may do. Its device works as a service
      # account (a StaffMembership marked `service_account`, tied to the
      # device) that opens orders on the kiosk's own shift, adds menu items,
      # takes a VietQR transfer the bank webhook confirmed, and parks orders
      # for the counter. No discount, price change, cash, cancel of paid
      # work, return or anything else, whatever capabilities the account was
      # given: capabilities are cut to CAPABILITIES (StaffMembership#allows?)
      # and every command outside COMMANDS is refused (CommandExecutor).
      module Policy
        MODULE = 'fnb.kiosk'
        CAPABILITIES = [Capabilities::OPEN_SHIFT, Capabilities::PAYMENT].freeze
        PERMISSIONS = %w[read_pos_orders write_pos_orders].freeze
        COMMANDS = %w[kiosk.order kiosk.finish kiosk.pay_at_counter kiosk.cancel add_line_item claim_lease change_status
                      tender.prepare tender.confirm tender.cancel workspace.complete shift.count shift.close].freeze
        ROLE_NAME = 'pos-kiosk-service'
        # Kiosk orders left at the counter this long are shown as abandoned.
        ABANDONED_AFTER = 30.minutes

        module_function

        def service_account?(staff)
          staff.present? && StaffMembership.where(staff_id: staff.id, service_account: true).exists?
        end

        # Raised before any work of a command a service account may not run.
        def authorize_command!(actor, command)
          return unless actor.is_a?(Spree.admin_user_class)
          return if COMMANDS.include?(command.to_s) || !service_account?(actor)

          raise CanCan::AccessDenied
        end

        # The active service account of a kiosk device, or nil.
        def account(device)
          return if device.nil? || device.mode != 'kiosk' || device.status != 'active'

          StaffMembership.includes(:staff).find_by(device_id: device.id, service_account: true, status: 'active')
        end

        def account!(device)
          account(device) || raise(Conflict.new('This kiosk is not set up.', reason: 'kiosk_unprovisioned'))
        end

        # The editor id the kiosk holds its orders' leases with: fixed per
        # device and pairing, in the UUID v4 shape leases ask for.
        def editor_id(device)
          hex = Digest::SHA256.hexdigest("kiosk-editor:#{device.id}:#{device.generation}")
          "#{hex[0, 8]}-#{hex[8, 4]}-4#{hex[13, 3]}-8#{hex[17, 3]}-#{hex[20, 12]}"
        end

        # The kiosk's own open shift, or nil: its register's, owned by its account.
        def open_shift(device, account = self.account(device))
          return if account.nil? || device.register_id.nil?

          Shift.open_now.find_by(register_id: device.register_id, owner_id: account.staff_id)
        end

        # A kiosk order still with the kiosk: on a shift of the kiosk's account.
        def kiosk_owned?(workspace, account)
          workspace.kiosk? && workspace.shift.owner_id == account.staff_id
        end

        # A cashier may take a kiosk order left for the counter: someone
        # selling and collecting at its branch, never another kiosk.
        def can_take?(policy, workspace)
          return false unless workspace.kiosk? && Workspace::OPEN_STATUSES.include?(workspace.operational_status)

          membership = policy.membership_for(workspace.branch)
          membership.present? && !membership.service_account && membership.allows?(Capabilities::OPEN_SHIFT) &&
            membership.allows?(Capabilities::PAYMENT)
        end

        # Opening and closing a kiosk's shift, pairing it and its settings:
        # the branch's device managers and store administrators.
        def manage!(store, staff, branch)
          Devices::Guard.manage!(store, staff, branch)
        end
      end
    end
  end
end

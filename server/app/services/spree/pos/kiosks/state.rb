# frozen_string_literal: true

module Spree
  module Pos
    module Kiosks
      # Whether a kiosk takes orders now and how it behaves: open only while
      # it is set up, the branch runs kiosks, its register is in use and a
      # manager opened its shift. Otherwise the kiosk shows "paused" and
      # takes no new order.
      module State
        module_function

        def call(device)
          account = Policy.account(device)
          branch = device.branch
          register = device.register
          reason = pause_reason(device, account)
          {
            open: reason.nil?, reason: reason,
            branch: { id: branch.prefixed_id, name: branch.name },
            register: register && { id: register.prefixed_id, name: register.name },
            currency: device.store.default_currency,
            idle_seconds: branch.kiosk_idle_seconds, qr_timeout_seconds: branch.kiosk_qr_timeout_seconds,
            kitchen_before_payment: branch.kiosk_kitchen_before_payment,
            payments: { vietqr: reason.nil? && vietqr?(branch), counter: true }
          }
        end

        def pause_reason(device, account = Policy.account(device))
          branch = device.branch
          register = device.register
          return 'kiosk_unprovisioned' if account.nil?
          return 'module_disabled' unless ModulePolicy.enabled?(branch, Policy::MODULE)
          return 'register_disabled' if branch.disabled? || register.nil? || register.disabled? || !register.kiosk?
          return 'shift_closed' if Policy.open_shift(device, account).nil?

          nil
        end

        # The kiosk's open shift, or the reason it takes no order.
        def require_open!(device, account)
          reason = pause_reason(device, account)
          raise Conflict.new('This kiosk is paused.', reason: 'kiosk_paused', details: { pause_reason: reason }) if reason

          Policy.open_shift(device, account)
        end

        def vietqr?(branch)
          FeaturePolicy.enabled?(branch, :vietqr) &&
            PaymentMethodResolver.new(store: branch.store).available(branch: branch).any? { |row| row.kind == 'vietqr' }
        end
      end
    end
  end
end

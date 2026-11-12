# frozen_string_literal: true

module Spree
  module Pos
    module Kiosks
      # A kiosk sells only on a shift a manager opened for it. The shift
      # belongs to the kiosk's service account, so every order the kiosk
      # opens is its own; it holds no cash (opening float 0, cash tenders are
      # refused to a kiosk) and closes on a zero count. Orders left for the
      # counter do not block the close: a cashier taking one moves it to
      # their own shift. A QR still waiting does.
      module Shifts
        module_function

        def open(store:, staff:, key:, register_id:)
          register = register!(store, register_id)
          payload = { 'command' => 'kiosk.shift_open', 'register_id' => register.prefixed_id }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { Policy.manage!(store, staff, register.branch) }) do
            register.lock!
            ModulePolicy.require!(register.branch, Policy::MODULE)
            raise Conflict.new('This register is disabled.', reason: 'register_disabled') if register.disabled? || register.branch.disabled?

            account = account!(register)
            raise Conflict.new('This kiosk already has an open shift.', reason: 'shift_open') if Shift.open_now.exists?(register_id: register.id)

            shift = Shift.create!(store: store, branch: register.branch, register: register, owner: account.staff, opening_float: 0,
                                  currency: store.default_currency, status: 'open', opened_at: Time.current,
                                  business_date: BusinessDay.for(register.branch, Workspace.business_now))
            AuditEntry.record!(store: store, actor: staff, action: 'kiosk.shift_open', subject: shift,
                               metadata: { register_id: register.prefixed_id, device_id: account.device.prefixed_id })
            announce!(register)
            shift.to_pos
          end
        rescue ActiveRecord::RecordNotUnique
          raise Conflict.new('This kiosk already has an open shift.', reason: 'shift_open')
        end

        # Counts the empty drawer and closes, as the kiosk's account; the
        # manager who asked is audited.
        def close(store:, staff:, key:, register_id:)
          register = register!(store, register_id)
          payload = { 'command' => 'kiosk.shift_close', 'register_id' => register.prefixed_id }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { Policy.manage!(store, staff, register.branch) }) do
            shift = Shift.open_now.find_by(register_id: register.id)
            raise Conflict.new('This kiosk has no open shift.', reason: 'shift_closed') if shift.nil?

            owner = shift.owner
            Pos::Shifts::Count.call(store: store, staff: owner, key: "#{key}:count", shift_id: shift.prefixed_id, counted: '0')
            closure = Pos::Shifts::Close.call(store: store, staff: owner, key: "#{key}:close", shift_id: shift.prefixed_id)
            AuditEntry.record!(store: store, actor: staff, action: 'kiosk.shift_close', subject: shift,
                               metadata: { register_id: register.prefixed_id })
            announce!(register)
            closure
          end
        end

        def register!(store, register_id)
          register = Register.locate(Register.for_store(store), register_id.to_s)
          raise ActiveRecord::RecordNotFound if register.nil?
          raise Conflict.new('This register is not a kiosk.', reason: 'register_not_kiosk') unless register.kiosk?

          register
        end

        # The service account of the device paired to the register.
        def account!(register)
          device = Device.active.where(register_id: register.id, mode: 'kiosk').order(:id).last
          account = Policy.account(device)
          raise Conflict.new('Pair a kiosk with this register first.', reason: 'kiosk_unprovisioned') if account.nil?

          account
        end

        def announce!(register)
          Realtime.publish(register.branch, 'kiosk.updated', id: register.prefixed_id, refs: { register_id: register.prefixed_id })
        end
      end
    end
  end
end

# frozen_string_literal: true

module Spree
  module Pos
    module Kiosks
      # A branch's kiosk settings and the kiosks themselves, for the
      # managers who set them up: how long a kiosk waits for a touch, how
      # long its bank QR stays open, whether orders left for the counter
      # reach the kitchen before they are paid; and each kiosk register with
      # its paired device, its open shift and the orders waiting at the
      # counter. Changes are audited.
      module Settings
        FIELDS = %w[kiosk_idle_seconds kiosk_qr_timeout_seconds kiosk_kitchen_before_payment].freeze
        RANGES = { 'kiosk_idle_seconds' => 15..600, 'kiosk_qr_timeout_seconds' => 60..900 }.freeze

        module_function

        def to_pos(branch)
          {
            branch_id: branch.prefixed_id, kiosk_idle_seconds: branch.kiosk_idle_seconds,
            kiosk_qr_timeout_seconds: branch.kiosk_qr_timeout_seconds,
            kiosk_kitchen_before_payment: branch.kiosk_kitchen_before_payment,
            kiosks: kiosks(branch)
          }
        end

        def kiosks(branch)
          registers = Register.where(branch_id: branch.id, kind: 'kiosk').order(:name, :id).to_a
          devices = Device.active.where(register_id: registers.map(&:id), mode: 'kiosk').order(:id).group_by(&:register_id)
          shifts = Shift.open_now.where(register_id: registers.map(&:id)).index_by(&:register_id)
          waiting = Workspace.where(register_id: registers.map(&:id), order_source: Workspace::KIOSK_SOURCE, operational_status: 'parked').
                    group(:register_id).count
          registers.map do |register|
            device = devices[register.id]&.last
            shift = shifts[register.id]
            {
              register: register.to_pos,
              device: device && device.to_pos.slice(:id, :name, :platform, :app_version, :last_seen_at),
              provisioned: Policy.account(device).present?,
              shift: shift && { id: shift.prefixed_id, opened_at: shift.opened_at&.iso8601, business_date: shift.business_date&.iso8601 },
              waiting_orders: waiting[register.id] || 0
            }
          end
        end

        def update(store:, staff:, key:, branch:, attributes:)
          values = attributes.to_h.stringify_keys.slice(*FIELDS)
          payload = { 'command' => 'kiosk_settings.update', 'branch_id' => branch.prefixed_id, 'attributes' => values }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { Policy.manage!(store, staff, branch) }) do
            branch.lock!
            before = to_pos(branch).except(:kiosks)
            RANGES.each do |field, range|
              next unless values.key?(field)

              seconds = Integer(values[field].to_s, 10) rescue nil # rubocop:disable Style/RescueModifier
              raise Conflict.new('The seconds are invalid.', reason: 'kiosk_settings_invalid', details: { field: field }) unless seconds && range.cover?(seconds)

              branch[field] = seconds
            end
            if values.key?('kiosk_kitchen_before_payment')
              branch.kiosk_kitchen_before_payment = ActiveModel::Type::Boolean.new.cast(values['kiosk_kitchen_before_payment']) == true
            end
            branch.save!
            after = to_pos(branch)
            AuditEntry.record!(store: store, actor: staff, action: 'kiosk_settings.update', subject: branch,
                               metadata: { before: before, after: after.except(:kiosks) })
            after
          end
        end
      end
    end
  end
end

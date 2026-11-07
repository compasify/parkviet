# frozen_string_literal: true

module Spree
  module Pos
    module Inventory
      # Puts a lot or a serial unit on hold (recall, suspected defect) or takes
      # it off hold. A quarantined lot or unit is never allocated again;
      # reservations that unpaid drafts held on it are released, so the draft
      # has to take other stock before it can be paid. Units stay on the shelf count
      # (they are physically there); writing them off is a count.
      class Quarantine
        class << self
          def lot(store:, staff:, key:, lot_id:, reason:, release: false)
            run(store, staff, key, lot_id, reason, release, kind: 'lot') do |lot|
              if release
                raise Conflict.new('Only a quarantined lot can be released.', reason: 'not_quarantined') unless lot.status == 'quarantined'

                lot.update!(status: 'active', quarantine_reason: nil, quarantined_at: nil, quarantined_by: nil)
              else
                raise Conflict.new('This lot is already quarantined.', reason: 'already_quarantined') if lot.status == 'quarantined'

                lot.update!(status: 'quarantined', quarantine_reason: reason.to_s.strip[0, 200], quarantined_at: Time.current, quarantined_by: staff)
                release_reservations!(TraceAllocation.where(inventory_lot_id: lot.id, status: 'reserved'))
              end
              lot.to_pos(today: StockIntegration.today(lot_branch(lot)))
            end
          end

          def serial(store:, staff:, key:, serial_unit_id:, reason:, release: false)
            run(store, staff, key, serial_unit_id, reason, release, kind: 'serial') do |unit|
              if release
                raise Conflict.new('Only a quarantined unit can be released.', reason: 'not_quarantined') unless unit.status == 'quarantined'

                unit.update!(status: 'in_stock', quarantine_reason: nil)
              else
                release_reservations!(TraceAllocation.where(serial_unit_id: unit.id, status: 'reserved'))
                unit.reload
                unless unit.status == 'in_stock'
                  raise Conflict.new("Serial #{unit.serial} is #{unit.status.tr('_', ' ')} and cannot be quarantined.", reason: 'serial_unavailable')
                end

                unit.update!(status: 'quarantined', quarantine_reason: reason.to_s.strip[0, 200])
              end
              unit.to_pos
            end
          end

          private

          def run(store, staff, key, record_id, reason, release, kind:)
            model = kind == 'lot' ? InventoryLot : SerialUnit
            find = lambda do
              record = model.locate(model.for_store(store), record_id)
              raise ActiveRecord::RecordNotFound if record.nil? || lot_branch(record).nil?

              record
            end
            payload = { 'command' => "inventory.#{kind}.#{release ? 'release' : 'quarantine'}", 'id' => record_id.to_s,
                        'reason' => reason.to_s.strip }
            authorize = -> { Guard.authorize!(store, staff, lot_branch(find.call)) }
            CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
              raise Conflict.new('A reason is required.', reason: 'reason_required') if reason.to_s.strip.blank?

              record = find.call
              Guard.lock_levels!(record.variant, [record.stock_location])
              record.lock!
              result = yield(record)
              Guard.finish!(store, staff, "inventory.#{kind}_#{release ? 'released' : 'quarantined'}", record,
                            id: record.prefixed_id, reason: reason.to_s.strip[0, 200])
              result
            end
          end

          def lot_branch(record)
            Branch.find_by(stock_location_id: record.stock_location_id, store_id: record.store_id)
          end

          # A reservation held by a payment in progress (no expiry) stays: the
          # money is already moving for those units.
          def release_reservations!(scope)
            scope.where.not(expires_at: nil).order(:id).each do |row|
              row.update!(status: 'released', released_at: Time.current, expires_at: nil)
              row.serial_unit&.update!(status: 'in_stock') if row.serial_unit&.status == 'reserved'
            end
          end
        end
      end
    end
  end
end

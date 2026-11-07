# frozen_string_literal: true

module Spree
  module Pos
    module Returns
      # Withdraws a return that was not received: core `Spree::Returns::Cancel`
      # frees the units, the reservations are canceled, and every later
      # unposted reservation of the same lines is re-priced at its new
      # cumulative position. A re-priced return gets a new revision, so an
      # approval granted for the old figures no longer matches and must be
      # granted again. Canceling is refused when a later return of the same
      # line is already posted, because that would change a posted document.
      class Cancel
        def self.call(store:, staff:, key:, return_id:, reason:)
          payload = { 'command' => 'return.cancel', 'return_id' => return_id.to_s, 'reason' => reason.to_s.strip }
          authorize = lambda do
            operation = Guard.operation!(store, return_id)
            policy = AccessPolicy.new(store: store, staff: staff)
            allowed = policy.allows?(operation.branch, Capabilities::APPROVE) ||
              (operation.requester_id == staff.id && policy.allows?(operation.branch, Capabilities::RETURN))
            raise CanCan::AccessDenied unless allowed
          end
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            raise Conflict, 'A reason is required.' if reason.to_s.strip.blank?

            perform!(Guard.operation!(store, return_id), staff, reason.to_s.strip, action: 'return.cancel')
          end
        rescue ActiveRecord::Deadlocked
          raise Conflict.new('Another return of these lines was changing at the same time; try again.', reason: 'retry')
        end

        # A return nobody received within its TTL. The requester is the actor
        # of record; the recovery job calls this, so no capability is checked.
        def self.expire!(operation)
          ApplicationRecord.transaction do
            perform!(operation, operation.requester, 'Hết hạn: không nhận hàng trong thời hạn', action: 'return.expire')
          end
        end

        def self.perform!(operation, staff, reason, action:)
          # Every return this cancel may re-price is locked with it, by id,
          # before the SaleLines, the order all return commands lock in.
          line_ids = operation.reservations.pluck(:sale_line_id)
          locked = affected_ids(line_ids) | [operation.id]
          ReturnOperation.where(id: locked).order(:id).lock.to_a
          operation.reload
          unless %w[pending_approval ready].include?(operation.status)
            raise Conflict.new('Only a return that was not received can be canceled.', reason: 'not_cancelable')
          end

          rows = operation.reservations.to_a
          Guard.lock_sale_lines!(line_ids)
          # A return prepared between the first read and the SaleLine locks
          # would be re-priced without its own lock: start again instead.
          unless (affected_ids(line_ids) - locked).empty?
            raise Conflict.new('Another return of these lines was prepared at the same time; try again.', reason: 'retry')
          end

          rows.each do |row|
            later = ReturnReservation.where(sale_line_id: row.sale_line_id, status: 'posted').where('sequence > ?', row.sequence)
            if later.exists?
              raise Conflict.new('A later return of this line is already posted; it needs a correction instead.',
                                 reason: 'dependent_posted')
            end
          end

          result = Spree::Returns::Cancel.call(return_record: operation.core_return, reason: reason)
          raise Conflict, Guard.core_error(result, 'Core return could not be canceled.') unless result.success?

          rows.each { |row| row.update!(status: 'canceled') }
          Inventory::ReturnTraceability.cancel!(operation)
          operation.update!(status: 'canceled', entitlement_status: 'canceled', canceled_at: Time.current)
          reprice_dependents!(operation, rows, staff)
          AuditEntry.record!(store: operation.store, actor: staff, action: action, subject: operation, metadata: { reason: reason })
          operation.reload.to_pos
        end

        def self.affected_ids(line_ids)
          ReturnReservation.where(sale_line_id: line_ids).distinct.pluck(:return_operation_id)
        end

        def self.reprice_dependents!(operation, rows, actor)
          touched = []
          rows.map(&:sale_line).uniq.each do |sale_line|
            entitlement = ReturnEntitlement.new(sale_line.order)
            returned = 0
            ReturnReservation.where(sale_line_id: sale_line.id).where.not(status: 'canceled').order(:sequence).each do |row|
              before = returned
              returned += row.quantity
              next if row.status == 'posted'

              delta = entitlement.delta(row.line_item, sale_line.base_quantity, before, returned)
              next if row.cumulative_before == before && row.components.to_h == delta.to_h

              row.update!(cumulative_before: before, cumulative_after: returned, **delta.to_h)
              touched << row.return_operation_id
            end
          end
          ReturnOperation.where(id: touched.uniq).where.not(id: operation.id).order(:id).each do |dependent|
            total = dependent.reservations.where.not(status: 'canceled').sum(:total)
            dependent.update!(entitlement_total: total, revision: dependent.revision + 1)
            AuditEntry.record!(store: dependent.store, actor: actor, action: 'return.repriced', subject: dependent,
                               metadata: { after_cancel_of: operation.prefixed_id, entitlement: total.to_s('F') })
          end
          # Received returns that were waiting for the canceled one may post now.
          ReturnOperation.where(status: 'received', entitlement_status: 'awaiting_predecessor').
            where(id: ReturnReservation.where(sale_line_id: rows.map(&:sale_line_id)).select(:return_operation_id)).
            order(:id).each { |dependent| ApplyCreditNote.call(operation: dependent, actor: actor) }
        end
      end
    end
  end
end

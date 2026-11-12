# frozen_string_literal: true

module Spree
  module Pos
    module OfflineSales
      # Replays one cash sale a counter made offline, as the cashier who made
      # it, on the shift it was made on, under the key `offline:<offline_id>`
      # (the commands it runs inside are keyed from it), so a replay after a
      # lost response finds the same receipt and never charges twice.
      #
      # The server prices the lines again. When the shift is still open, every
      # item still sells and the total matches the cash the counter took, the
      # order is paid in cash and completed now: business date, order and call
      # numbers, receipt and e-invoice are the server's, the time the counter
      # sold it is kept beside them. Otherwise the sale waits for review with
      # its reason: a changed total parks the order (the cash noted on it); a
      # closed shift or an item no longer sold records no order. Refusals of
      # the commands inside become a review too; nothing is dropped.
      module Ingest
        module_function

        # @return [Hash] the sale as OfflineSale#to_pos, as it stands now
        def call(store:, staff:, key:, params:)
          input = normalize!(params)
          unless key.to_s == OfflineSales.key_for(input['offline_id'])
            raise Conflict.new('The key of an offline sale is offline:<offline_id>.', reason: 'offline_key_mismatch')
          end

          client_now = params[:client_now].present? ? OfflineSales.time!(params[:client_now]) : nil
          payload = input.merge('command' => 'offline_sale.ingest')
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { authorize!(store, staff, input) }) do
            if OfflineSale.exists?(store_id: store.id, offline_id: input['offline_id'])
              raise Conflict.new('Another sale already holds this offline id.', reason: 'offline_sale_taken')
            end

            record!(store, staff, key, input, client_now).to_pos
          end
          OfflineSale.find_by!(store_id: store.id, offline_id: input['offline_id']).to_pos
        end

        def normalize!(params)
          offline_id = params[:offline_id].to_s.downcase
          number = params[:provisional_number].to_s
          raise Conflict.new('The offline id is invalid.', reason: 'offline_sale_invalid') unless offline_id.match?(OfflineSales::UUID)
          raise Conflict.new('The provisional number is invalid.', reason: 'offline_sale_invalid') unless number.match?(OfflineSales::PROVISIONAL)

          total = OfflineSales.money!(params[:total])
          handed = OfflineSales.money!(params[:handed_amount])
          raise Conflict.new('Cash handed is less than the total.', reason: 'offline_cash_short') if handed < total

          {
            'offline_id' => offline_id, 'provisional_number' => number, 'register_id' => params[:register_id].to_s,
            'shift_id' => params[:shift_id].to_s, 'client_sold_at' => OfflineSales.time!(params[:client_sold_at]).utc.iso8601,
            'lines' => OfflineSales.lines!(Array(params[:lines]).map { |row| row.respond_to?(:to_unsafe_h) ? row.to_unsafe_h : row }),
            'total' => total.to_s('F'), 'handed_amount' => handed.to_s('F')
          }
        end

        # The cashier's own shift on the register the counter named, and a
        # cashier who still sells at its branch.
        def authorize!(store, staff, input)
          shift = shift!(store, input)
          raise CanCan::AccessDenied unless shift.owner_id == staff.id

          OfflineSales.seller!(store, staff, shift.branch)
        end

        def shift!(store, input)
          shift = Shift.locate(Shift.for_store(store), input['shift_id'])
          raise ActiveRecord::RecordNotFound if shift.nil? || shift.register.nil? || shift.register.prefixed_id != input['register_id']

          shift
        end

        def record!(store, staff, key, input, client_now)
          shift = shift!(store, input)
          sold_at = Time.iso8601(input['client_sold_at'])
          ref = { 'offline_id' => input['offline_id'], 'provisional_number' => input['provisional_number'] }
          reason, details, workspace = OfflineSales.replaying { replay(store, staff, shift, key, input, sold_at, ref) }
          skew = client_now ? (Time.current - client_now).round : 0
          sale = OfflineSale.create!(
            store: store, branch: shift.branch, register: shift.register, shift: shift, staff: staff,
            offline_id: input['offline_id'], provisional_number: input['provisional_number'], client_sold_at: sold_at,
            clock_skew_seconds: skew, clock_check: skew.abs > OfflineSale::CLOCK_TOLERANCE || sold_at > Time.current + OfflineSale::CLOCK_TOLERANCE,
            payload: { 'lines' => input['lines'] }, collected_total: BigDecimal(input['total']), handed_amount: BigDecimal(input['handed_amount']),
            currency: store.default_currency, status: reason ? 'needs_review' : 'completed', workspace: workspace,
            review_reason: reason, review_details: details || {}
          )
          AuditEntry.record!(store: store, actor: staff, action: "offline_sale.#{sale.status}", subject: workspace || shift,
                             metadata: ref.merge('offline_sale_id' => sale.prefixed_id, 'reason' => reason, 'collected' => input['total'],
                                                 'sold_offline_at' => input['client_sold_at'], 'clock_skew_seconds' => skew).compact)
          sale
        end

        # [reason, details, workspace]: no reason when the sale completed.
        def replay(store, staff, shift, key, input, sold_at, ref)
          return ['shift_closed', { 'closed_at' => shift.closed_at&.iso8601 }, nil] unless shift.open?
          if shift.opened_at && shift.opened_at > sold_at + OfflineSale::CLOCK_TOLERANCE
            return ['shift_mismatch', { 'opened_at' => shift.opened_at&.iso8601 }, nil]
          end

          missing = OfflineSales.unavailable(shift.branch, input['lines'])
          return [*missing, nil] if missing

          ApplicationRecord.transaction(requires_new: true) do
            build(store, staff, shift, key, input, ref)
          end
        rescue Conflict => e
          ['sale_refused', { 'reason' => e.reason, 'message' => e.message }.compact, nil]
        end

        def build(store, staff, shift, key, input, ref)
          editor = OfflineSales.editor_for(input['offline_id'])
          workspace = OfflineSales.draft!(store: store, staff: staff, shift: shift, editor: editor, key: key, rows: input['lines'], sale_ref: ref)
          collected = BigDecimal(input['total'])
          current = workspace.order.total
          if current != collected
            park!(workspace, staff, editor, key, input)
            return ['price_changed', { 'collected_total' => collected.to_s('F'), 'current_total' => current.to_s('F') }, workspace]
          end

          OfflineSales.pay_and_complete!(workspace, staff, editor, key, BigDecimal(input['handed_amount']))
          [nil, {}, workspace]
        end

        # The order waits parked, its note saying what was collected and when.
        def park!(workspace, staff, editor, key, input)
          note = "Offline #{input['provisional_number']}: #{input['total']} #{workspace.order.currency} cash collected " \
                 "(#{input['handed_amount']} handed) at #{input['client_sold_at']}."
          current = workspace.reload
          Workspaces::UpdateNote.call(workspace: current, staff: staff, revision: current.revision, lease_generation: current.lease_generation,
                                      editor_id: editor, key: "#{key}:note", note: note)
          current = workspace.reload
          Workspaces::ChangeStatus.call(workspace: current, staff: staff, status: 'parked', revision: current.revision,
                                        lease_generation: current.lease_generation, key: "#{key}:park", editor_id: editor)
        end
      end
    end
  end
end

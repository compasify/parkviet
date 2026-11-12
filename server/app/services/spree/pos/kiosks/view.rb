# frozen_string_literal: true

module Spree
  module Pos
    module Kiosks
      # A kiosk order as the kiosk screen shows it: what was ordered and the
      # server's prices, the call number, and where the payment stands. No
      # staff names, customer, discounts or shift detail.
      #
      # status: awaiting_payment (a QR is open), at_counter (left for the
      # cashier), paid, canceled. payment.state while a QR is open: waiting,
      # received (the bank's webhook confirmed it, `finish` completes the
      # sale) or expired (past the branch's timeout and not received).
      module View
        module_function

        def call(workspace, device)
          order = workspace.order
          attempt = TenderAttempt.where(workspace_id: workspace.id).order(:id).last
          status = status_of(workspace, attempt)
          {
            id: workspace.prefixed_id, status: status, call_number: workspace.order_number, order_number: order.number,
            currency: order.currency, total: money(order.total), item_total: money(order.item_total),
            lines: lines(workspace),
            payment: status == 'awaiting_payment' ? payment(attempt, workspace.branch) : nil,
            device_id: device.prefixed_id
          }
        end

        def status_of(workspace, attempt)
          case workspace.operational_status
          when 'completed' then 'paid'
          when 'canceled' then 'canceled'
          when 'parked' then 'at_counter'
          else attempt&.status == 'prepared' ? 'awaiting_payment' : 'draft'
          end
        end

        def payment(attempt, branch)
          expires_at = attempt.created_at + branch.kiosk_qr_timeout_seconds.seconds
          received = received?(attempt)
          state = if received then 'received'
                  elsif Time.current >= expires_at then 'expired'
                  else 'waiting'
                  end
          { kind: 'vietqr', attempt_id: attempt.prefixed_id, amount: money(attempt.amount), state: state,
            expires_at: expires_at.iso8601, qr: received ? nil : VietqrTender.display(attempt) }
        end

        # The bank's webhook completed the payment the QR was issued for.
        def received?(attempt)
          allocation = VietqrTender.allocation_for(attempt)
          payment = VietqrTender.payment_for(attempt)
          allocation.present? && allocation.confirmed? && payment&.status == 'completed'
        end

        def lines(workspace)
          SaleLine.where(workspace_id: workspace.id).includes(:line_modifiers, line_item: { variant: :product }).order(:id).map do |sale|
            line = sale.line_item
            { name: line.variant.product.name, quantity: sale.sale_quantity.to_s('F'), unit_price: money(sale.unit_price),
              amount: money(line.amount), note: sale.note,
              modifiers: sale.line_modifiers.map { |row| { name: row.name, quantity: row.quantity } } }
          end
        end

        def money(value)
          BigDecimal(value.to_s).to_s('F')
        end
      end
    end
  end
end

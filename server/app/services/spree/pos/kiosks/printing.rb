# frozen_string_literal: true

module Spree
  module Pos
    module Kiosks
      # What a kiosk prints, on the receipt printer of its own register (a
      # print station's printer whose register is the kiosk's): the receipt
      # of a paid order, which carries the call number, or, for an order
      # left for the counter, a slip with the call number and the amount to
      # pay there. Queued after the sale commits; a missing or broken printer
      # never stops it (the screen shows the number either way).
      module Printing
        PAGE = Kitchen::TicketDocument::PAGE

        module_function

        def printer(device)
          return if device.register_id.nil?

          Printer.active.where(branch_id: device.branch_id, register_id: device.register_id).order(:id).
            detect { |row| row.station? && row.station_live? && row.prints?('receipt') }
        end

        def receipt_after_commit(workspace, device, staff)
          ActiveRecord.after_all_transactions_commit { receipt!(workspace, device, staff) }
        end

        def counter_slip_after_commit(workspace, device, staff)
          ActiveRecord.after_all_transactions_commit { counter_slip!(workspace, device, staff) }
        end

        def receipt!(workspace, device, staff)
          printer = printer(device)
          return if printer.nil?

          ApplicationRecord.transaction do
            snapshot = ReceiptBuilder.for_source!(workspace.reload, actor: staff)
            print = ReceiptPrint.record!(snapshot: snapshot, actor: staff, requested: {}, printer: printer)
            PrintJobs::Enqueue.call(store: workspace.store, printer: printer, kind: 'receipt', key: "kiosk:receipt:#{workspace.prefixed_id}",
                                    actor: staff, source: snapshot, receipt_print: print,
                                    document: PrintJobs::Create.receipt_document(snapshot, print, true))
          end
        rescue StandardError => e
          Rails.logger.error("[pos] kiosk receipt #{workspace.prefixed_id} not queued for printing: #{e.class}: #{e.message}")
        end

        def counter_slip!(workspace, device, staff)
          printer = printer(device)
          return if printer.nil?

          PrintJobs::Enqueue.call(store: workspace.store, printer: printer, kind: 'receipt', key: "kiosk:slip:#{workspace.prefixed_id}",
                                  actor: staff, source: workspace, source_revision: workspace.revision,
                                  document: counter_slip(workspace.reload))
        rescue StandardError => e
          Rails.logger.error("[pos] kiosk slip #{workspace.prefixed_id} not queued for printing: #{e.class}: #{e.message}")
        end

        def counter_slip(workspace, now: Workspace.database_now)
          order = workspace.order
          number = workspace.order_number&.to_s || order.number
          items = View.lines(workspace).map do |line|
            Kitchen::TicketDocument.text(["#{line[:quantity].sub(/\.0\z/, '')} x #{line[:name]}"])
          end
          lines = [
            { 'kind' => 'title', 'title' => 'SỐ GỌI MÓN', 'number' => number },
            Kitchen::TicketDocument.text(['Chưa thanh toán: mời trả tại quầy'], bold: true, align: 'center'),
            *items,
            { 'kind' => 'divider', 'style' => 'solid' },
            Kitchen::TicketDocument.text(["Cần trả: #{amount(order.total, order.currency)}"], size: 'l', bold: true, align: 'center'),
            Kitchen::TicketDocument.text([PrintDocuments::Text.document_time(now.iso8601, workspace.branch.timezone)], align: 'center')
          ]
          PrintDocuments.wrap('receipt', {
                                'documentType' => nil, 'page' => PAGE, 'banners' => [], 'header' => lines,
                                'meta' => [{ 'label' => 'Đơn', 'value' => order.number }],
                                'lines' => { 'layout' => 'stacked', 'items' => [] },
                                'totals' => [], 'payments' => [], 'payQr' => nil, 'notes' => [], 'footer' => [], 'disclaimer' => nil
                              })
        end

        def amount(value, currency)
          number = BigDecimal(value.to_s).round(0).to_i.to_s.reverse.scan(/\d{1,3}/).join('.').reverse
          currency == 'VND' ? "#{number} đ" : "#{number} #{currency}"
        end
      end
    end
  end
end

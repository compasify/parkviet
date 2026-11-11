# frozen_string_literal: true

module Spree
  module Pos
    module Kitchen
      # A kitchen ticket as PrintDocument v1, fixed layout: the station and
      # ticket number, the call number or table, how the order is served and
      # when it was sent, then every item in large type with its options
      # indented below it and its note printed white on black. No prices.
      # A void ticket (oid_ticket) says so in a white-on-black band and
      # prints each taken-back item with a minus and its reason.
      module TicketDocument
        PAGE = { 'margin_mm' => 2, 'font' => 'sans', 'font_size' => 'm', 'line_spacing' => 1.2 }.freeze
        SERVICE_MODES = {
          'counter' => 'TẠI QUẦY', 'dine_in' => 'ĂN TẠI CHỖ', 'takeaway' => 'MANG ĐI', 'delivery' => 'GIAO HÀNG',
          'tab' => 'GHI SỔ', 'timed' => 'TÍNH GIỜ'
        }.freeze
        PLATFORMS = { 'grabfood' => 'GRABFOOD', 'shopeefood' => 'SHOPEEFOOD' }.freeze

        module_function

        def build(ticket)
          header = ticket.header.to_h
          PrintDocuments.wrap(ticket.kind == 'void' ? 'void_ticket' : 'kitchen_ticket', {
                                'documentType' => nil, 'page' => PAGE, 'banners' => [],
                                'header' => head(ticket, header) + ticket.items.flat_map { |item| item_blocks(item) },
                                'meta' => meta(ticket, header), 'lines' => { 'layout' => 'stacked', 'items' => [] },
                                'totals' => [], 'payments' => [], 'payQr' => nil, 'notes' => [], 'footer' => [], 'disclaimer' => nil
                              })
        end

        def head(ticket, header)
          blocks = [{ 'kind' => 'title', 'title' => ticket.kitchen_station.name.upcase, 'number' => "Phiếu ##{ticket.sequence}" }]
          blocks << text(['HỦY MÓN'], size: 'l', bold: true, align: 'center', invert: true) if ticket.kind == 'void'
          call = [header['order_number'] && "Số #{header['order_number']}", header['table'] && "Bàn #{header['table']}"].compact
          blocks << text(call, size: 'l', bold: true, align: 'center') if call.any?
          blocks << text([header['guest_name']], bold: true, align: 'center') if header['guest_name']
          platform = PLATFORMS[header['order_source']]
          if platform
            code = [platform, header['pickup_code'] && "Mã lấy: #{header['pickup_code']}"].compact.join(' · ')
            blocks << text([code], size: 'l', bold: true, align: 'center', invert: true)
          end
          time = PrintDocuments::Text.document_time(ticket.sent_at.iso8601, ticket.branch.timezone)
          blocks << text(["#{SERVICE_MODES.fetch(ticket.service_mode, ticket.service_mode.upcase)} · #{time}"], bold: true, align: 'center')
          blocks << { 'kind' => 'divider', 'style' => 'solid' }
        end

        def item_blocks(item)
          void = item.kitchen_ticket.kind == 'void'
          blocks = [text(["#{void ? '-' : ''}#{quantity(item.quantity)} x #{item.name}"], size: 'l', bold: true)]
          options = Array(item.modifiers).map do |row|
            count = row['quantity'].to_i > 1 ? " x#{row['quantity']}" : ''
            "+ #{row['name']}#{count}"
          end
          parts = Array(item.components).map { |row| "- #{row['name']} x#{quantity(row['quantity'])}" }
          blocks << text(options + parts) if (options + parts).any?
          blocks << text(["#{void ? 'Lý do' : 'Ghi chú'}: #{item.note}"], bold: true, invert: true) if item.note.present?
          blocks
        end

        def meta(ticket, header)
          rows = []
          rows << { 'label' => 'Quầy', 'value' => header['register_name'] } if header['register_name']
          rows << { 'label' => 'Mã đơn nền tảng', 'value' => header['platform_order_ref'] } if header['platform_order_ref']
          rows << { 'label' => 'Khách', 'value' => header['customer_name'] } if header['customer_name']
          rows << { 'label' => 'Ghi chú đơn', 'value' => header['note'] } if header['note']
          rows << { 'label' => 'Đơn', 'value' => ticket.workspace.prefixed_id }
          rows
        end

        def text(lines, size: 'm', bold: false, align: 'left', invert: false)
          block = { 'kind' => 'text', 'lines' => lines, 'align' => align, 'bold' => bold, 'size' => size }
          block['invert'] = true if invert
          block
        end

        def quantity(value)
          PrintDocuments::Text.quantity(value.is_a?(BigDecimal) ? value.to_s('F') : value.to_s)
        end
      end
    end
  end
end

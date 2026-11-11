# frozen_string_literal: true

module Spree
  module Pos
    module Kitchen
      # The checklist of a table order as PrintDocument v1: every line of the
      # order with how much of it has come out of the kitchen and how much
      # is still to come, so a waiter can check the table. No prices.
      module ChecklistDocument
        PAGE = TicketDocument::PAGE

        module_function

        # `served` maps sale line ids to the quantity served.
        def build(workspace, served, now: Workspace.database_now)
          lines = workspace.order.line_items.includes(variant: :product).order(:id).to_a
          sale_lines = SaleLine.where(workspace_id: workspace.id).includes(:line_modifiers).index_by(&:line_item_id)
          PrintDocuments.wrap('checklist', {
                                'documentType' => nil, 'page' => PAGE, 'banners' => [],
                                'header' => head(workspace, now) + lines.flat_map { |line| line_blocks(line, sale_lines[line.id], served) },
                                'meta' => [{ 'label' => 'Đơn', 'value' => workspace.prefixed_id }],
                                'lines' => { 'layout' => 'stacked', 'items' => [] },
                                'totals' => [], 'payments' => [], 'payQr' => nil, 'notes' => [], 'footer' => [], 'disclaimer' => nil
                              })
        end

        def head(workspace, now)
          table = [workspace.resource&.name, workspace.table_label].compact.join(' ')
          blocks = [{ 'kind' => 'title', 'title' => 'PHIẾU KIỂM ĐỒ', 'number' => table.presence && "Bàn #{table}" }]
          guests = workspace.guest_count ? "#{workspace.guest_count} khách · " : ''
          time = PrintDocuments::Text.document_time(now.iso8601, workspace.branch.timezone)
          blocks << TicketDocument.text(["#{guests}#{time}"], align: 'center')
          blocks << { 'kind' => 'divider', 'style' => 'solid' }
        end

        def line_blocks(line, sale_line, served)
          quantity = sale_line ? sale_line.sale_quantity : BigDecimal(line.quantity.to_s)
          done = served.fetch(sale_line&.id, BigDecimal('0'))
          left = [quantity - done, BigDecimal('0')].max
          blocks = [TicketDocument.text(["#{TicketDocument.quantity(quantity)} x #{line.variant.product.name}"], bold: true)]
          options = Array(sale_line&.line_modifiers).map { |row| "+ #{row.name}#{" x#{row.quantity}" if row.quantity > 1}" }
          blocks << TicketDocument.text(options) if options.any?
          blocks << TicketDocument.text(["Đã ra #{TicketDocument.quantity(done)} · Chưa ra #{TicketDocument.quantity(left)}"],
                                        bold: left.positive?)
        end
      end
    end
  end
end

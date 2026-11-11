# frozen_string_literal: true

module Spree
  module Pos
    module CupLabels
      # One cup label as PrintDocument v1 (`cup_label`), fixed layout: the
      # call number with "n/N", the item, its options and note, the guest's
      # name, the time and the shop's name. The branch settings switch the
      # optional fields off and set the label size, which the page carries
      # so a label printer feeds the right stock. No prices.
      module Document
        PAGE = { 'margin_mm' => 1, 'font' => 'sans', 'font_size' => 's', 'line_spacing' => 1.1 }.freeze

        module_function

        # `index` of `total` cups of `line` (a menu SaleLine).
        def build(workspace:, line:, index:, total:, settings:, at:)
          content(settings, at, workspace.branch,
                  number: workspace.order_number, index: index, total: total, item: Kitchen::Send.item_name(line),
                  options: line.line_modifiers.map { |row| row.quantity > 1 ? "#{row.name} x#{row.quantity}" : row.name },
                  note: line.note.presence, guest_name: workspace.guest_name.presence)
        end

        # The label "In thử" prints: every enabled field filled in, so the
        # merchant sees the layout on the real stock.
        def sample(branch:, settings:, at:)
          content(settings, at, branch, number: 1, index: 1, total: 1, item: 'Trà sữa (L)', options: ['Ít đá', 'Trân châu'],
                                        note: 'Ít ngọt', guest_name: 'Lan')
        end

        def content(settings, at, branch, number:, index:, total:, item:, options:, note:, guest_name:)
          fields = settings['fields']
          count = "#{index}/#{total}"
          head = fields.include?('call_number') && number ? "Số #{number} · #{count}" : count
          blocks = [text([head], size: 'l', bold: true, align: 'center'), text([item], bold: true)]
          blocks << text(options.map { |name| "+ #{name}" }) if fields.include?('options') && options.any?
          blocks << text(["Ghi chú: #{note}"], bold: true) if fields.include?('note') && note
          blocks << text([guest_name], bold: true, align: 'center') if fields.include?('guest_name') && guest_name
          footer = []
          footer << PrintDocuments::Text.document_time(at.iso8601, branch.timezone) if fields.include?('time')
          footer << branch.store.name if fields.include?('store_name') && branch.store.name.present?
          blocks << text([footer.join(' · ')], size: 's', align: 'center') if footer.any?
          PrintDocuments.wrap('cup_label', {
                                'documentType' => nil, 'page' => PAGE.merge('label' => Settings.label_mm(settings)), 'banners' => [],
                                'header' => blocks, 'meta' => [], 'lines' => { 'layout' => 'stacked', 'items' => [] },
                                'totals' => [], 'payments' => [], 'payQr' => nil, 'notes' => [], 'footer' => [], 'disclaimer' => nil
                              })
        end

        def text(lines, size: 'm', bold: false, align: 'left')
          { 'kind' => 'text', 'lines' => lines, 'align' => align, 'bold' => bold, 'size' => size }
        end
      end
    end
  end
end

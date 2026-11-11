# frozen_string_literal: true

module Spree
  module Pos
    module PrintDocuments
      # A fixed page that exercises what a printer has to get right: Vietnamese
      # text, alignment, emphasis, a QR code, a barcode and the cutter.
      module TestPage
        BANNER = 'IN THỬ — KHÔNG CÓ GIÁ TRỊ'
        SAMPLE = 'Tiếng Việt: ăâđêôơư ÁÀẢÃẠ ÉÈẺẼẸ'
        PAGE = { 'margin_mm' => 3, 'font' => 'sans', 'font_size' => 'm', 'line_spacing' => 1.35 }.freeze

        module_function

        def call(printer:, now:)
          {
            'documentType' => nil, 'page' => PAGE, 'banners' => [BANNER],
            'header' => [{ 'kind' => 'title', 'title' => 'TRANG IN THỬ', 'number' => nil }],
            'meta' => meta(printer, now), 'lines' => { 'layout' => 'stacked', 'items' => [] },
            'totals' => [], 'payments' => [], 'payQr' => nil, 'notes' => [SAMPLE],
            'footer' => [
              { 'kind' => 'qr', 'value' => 'PARKVIET-PRINT-TEST', 'caption' => nil, 'align' => 'center' },
              { 'kind' => 'barcode', 'value' => 'TEST-1234', 'align' => 'center' }
            ],
            'disclaimer' => nil
          }
        end

        def meta(printer, now)
          [{ 'label' => 'Máy in', 'value' => printer.name }, { 'label' => 'Kết nối', 'value' => printer.connection },
           { 'label' => 'Khổ giấy', 'value' => printer.paper },
           { 'label' => 'Thời gian', 'value' => Text.document_time(now.iso8601, printer.branch.timezone) }]
        end
      end
    end
  end
end

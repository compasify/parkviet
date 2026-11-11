# frozen_string_literal: true

module Spree
  module Pos
    module BottleKeeps
      # The label stuck on a kept bottle: its code, the guest, the bottle,
      # the level and until when it is kept. A receipt-kind PrintDocument, so
      # any receipt printer (or the device's own) prints it; with
      # `printer_id` it is also queued to that printer of the branch.
      module Label
        PAGE = Kitchen::TicketDocument::PAGE

        module_function

        def call(store:, staff:, key:, keep_id:, printer_id: nil)
          keep = Guard.keep_record!(store, keep_id)
          payload = { 'command' => 'bottle_keep.label', 'keep_id' => keep.prefixed_id, 'printer_id' => printer_id.to_s.presence }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> { Guard.keep!(store, staff, keep.branch) }) do
            ModulePolicy.require!(keep.branch, Guard::MODULE)
            document = build(keep)
            job = queue!(keep, staff, key, printer_id, document) if printer_id.present?
            { 'document' => document, 'print_job' => job&.to_pos }.compact
          end
        end

        def build(keep, now: Workspace.database_now)
          guest = keep.customer_profile&.name.presence || keep.guest_name
          lines = [
            { 'kind' => 'title', 'title' => 'GỬI RƯỢU', 'number' => keep.code },
            Kitchen::TicketDocument.text([keep.variant.product.name], bold: true, align: 'center'),
            { 'kind' => 'divider', 'style' => 'solid' },
            Kitchen::TicketDocument.text([guest, keep.phone].compact),
            Kitchen::TicketDocument.text(["Còn #{keep.level_percent}%"], bold: true),
            Kitchen::TicketDocument.text(["Gửi #{date(keep.kept_on)} · Hạn #{date(keep.expires_on)}"]),
            Kitchen::TicketDocument.text([PrintDocuments::Text.document_time(now.iso8601, keep.branch.timezone)], align: 'center'),
            # The waiter's phone scans it to pour from the bottle.
            { 'kind' => 'qr', 'value' => keep.code, 'caption' => nil, 'align' => 'center' }
          ]
          lines.insert(5, Kitchen::TicketDocument.text([keep.note])) if keep.note.present?
          PrintDocuments.wrap('receipt', {
                                'documentType' => nil, 'page' => PAGE, 'banners' => [], 'header' => lines,
                                'meta' => [{ 'label' => 'Mã', 'value' => keep.code }],
                                'lines' => { 'layout' => 'stacked', 'items' => [] },
                                'totals' => [], 'payments' => [], 'payQr' => nil, 'notes' => [], 'footer' => [], 'disclaimer' => nil
                              })
        end

        def date(value)
          value.strftime('%d/%m/%Y')
        end

        def queue!(keep, staff, key, printer_id, document)
          printer = PrintJobs::Guard.printer!(keep.store, printer_id, branch: keep.branch)
          PrintJobs::Enqueue.ensure_accepts!(printer, 'receipt')
          PrintJobs::Enqueue.call(store: keep.store, printer: printer, kind: 'receipt', key: PrintJobs::Create.job_key(staff, key),
                                  actor: staff, source: keep, source_revision: keep.revision, document: document)
        end
      end
    end
  end
end

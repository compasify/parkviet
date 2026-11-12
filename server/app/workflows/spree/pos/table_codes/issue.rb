# frozen_string_literal: true

module Spree
  module Pos
    module TableCodes
      # A new QR code for a table: the table's current code, if any, is
      # revoked with every guest session it opened, and the new token is
      # returned once. With `printer_id` the sticker is queued to that
      # printer of the branch (`table_qr`). Printing a sticker again is
      # issuing a new code, since the old token is not kept.
      #
      # The token never goes into the command receipt: a replay of the same
      # key answers the code without its token (rotate again to get one).
      module Issue
        COMMAND = 'table_code.rotate'

        module_function

        # @return [Array(Hash, String|nil)] the result and the token, nil on a replay
        def call(store:, staff:, key:, resource_id:, base_url:, printer_id: nil)
          token = nil
          payload = { 'command' => COMMAND, 'resource_id' => resource_id.to_s, 'printer_id' => printer_id.to_s.presence }
          resource = Resource.locate(Resource.where(store_id: store.id), resource_id) || raise(ActiveRecord::RecordNotFound)
          branch = resource.branch
          result = CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                                        authorize: -> { GuestOrders::Guard.codes!(store, staff, branch) }) do
            ModulePolicy.require!(branch, GuestOrders::Guard::MODULE)
            raise Conflict.new('This table is archived.', reason: 'table_archived') unless resource.active?

            resource.lock!
            now = Time.current
            previous = TableCode.active.find_by(resource_id: resource.id)
            if previous
              previous.update!(status: 'revoked', revoked_at: now)
              GuestSession.live.where(table_code_id: previous.id).update_all(revoked_at: now, updated_at: now)
            end
            token = TableCode.new_token
            code = TableCode.create!(store: store, branch: branch, resource: resource, token_digest: TableCode.digest(token),
                                     rotated_at: now, created_by: staff)
            job = queue!(store, staff, key, branch, resource, printer_id, TableCode.url(base_url, token)) if printer_id.present?
            AuditEntry.record!(store: store, actor: staff, action: COMMAND, subject: code,
                               metadata: { resource_id: resource.prefixed_id, replaced_id: previous&.prefixed_id,
                                           print_job_id: job&.prefixed_id })
            { 'table_code' => code.to_pos, 'print_job' => job&.to_pos }.compact
          end
          [result, token]
        end

        def queue!(store, staff, key, branch, resource, printer_id, url)
          printer = PrintJobs::Guard.printer!(store, printer_id, branch: branch)
          PrintJobs::Enqueue.ensure_accepts!(printer, 'table_qr')
          PrintJobs::Enqueue.call(store: store, printer: printer, kind: 'table_qr', key: PrintJobs::Create.job_key(staff, key),
                                  actor: staff, source: resource, document: document(branch, resource, url))
        end

        # The sticker as PrintDocument v1: the place, the table and its QR.
        # A server on the shop's LAN is reached only from its Wi-Fi.
        def document(branch, resource, url)
          PrintDocuments.wrap('table_qr', {
                                'documentType' => nil, 'page' => Kitchen::TicketDocument::PAGE, 'banners' => [],
                                'header' => [{ 'kind' => 'title', 'title' => branch.store.name, 'number' => nil },
                                             { 'kind' => 'title', 'title' => resource.name, 'number' => nil }],
                                'meta' => [{ 'label' => 'Chi nhánh', 'value' => branch.name }],
                                'lines' => { 'layout' => 'stacked', 'items' => [] },
                                'totals' => [], 'payments' => [], 'payQr' => nil,
                                'notes' => ['Quét mã để xem thực đơn và gọi món', 'Hãy kết nối Wi-Fi của quán trước khi quét'],
                                'footer' => [{ 'kind' => 'qr', 'value' => url, 'caption' => 'Scan to order', 'align' => 'center' }],
                                'disclaimer' => nil
                              })
        end
      end
    end
  end
end

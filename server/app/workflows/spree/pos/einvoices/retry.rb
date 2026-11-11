# frozen_string_literal: true

module Spree
  module Pos
    module Einvoices
      # Queues failed (or still pending) invoices for an immediate try, one
      # invoice or a batch of up to 100. Invoices in another state are
      # skipped. Needs pos.einvoice.manage at each invoice's branch; audited
      # once per invoice as `einvoice.retry`.
      module Retry
        LIMIT = 100

        module_function

        def call(store:, staff:, key:, einvoices:)
          list = einvoices.first(LIMIT)
          payload = { 'command' => 'einvoice.retry', 'einvoice_ids' => list.map(&:prefixed_id).sort }
          authorize = -> { list.map(&:branch).uniq.each { |branch| Einvoices.manage!(store, staff, branch) } }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            queued = list.filter_map do |einvoice|
              einvoice.lock!
              next unless %w[pending failed].include?(einvoice.status)

              Einvoices.queue!(einvoice)
              AuditEntry.record!(store: store, actor: staff, action: 'einvoice.retry', subject: einvoice,
                                 metadata: { order_id: einvoice.order.prefixed_id, attempts: einvoice.attempts })
              einvoice.prefixed_id
            end
            { 'queued' => queued, 'skipped' => list.size - queued.size }
          end
        end
      end
    end
  end
end

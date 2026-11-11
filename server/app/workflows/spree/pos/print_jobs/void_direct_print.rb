# frozen_string_literal: true

module Spree
  module Pos
    module PrintJobs
      # Takes back a print whose direct delivery from the browser failed before
      # reaching paper. Only a print recorded for a LAN printer, only the person
      # who just recorded it, and only the latest print of the document, so this
      # cannot erase a browser print or an earlier copy.
      module VoidDirectPrint
        WINDOW = 5.minutes
        # Known to mean no paper: refused before sending, refused by the printer,
        # or never sent because an earlier print of the press failed. A dropped
        # connection is not here: the printer may have printed first.
        REASONS = %w[mixed_content no_address printer_error not_sent].freeze

        module_function

        def call(store:, staff:, key:, snapshot:, print_id:, reason:)
          payload = { 'command' => 'receipt.print.void', 'receipt_id' => snapshot.prefixed_id, 'print_id' => print_id.to_s, 'reason' => reason }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: -> {}) do
            snapshot.lock!
            print = ReceiptPrint.locate(snapshot.prints, print_id)
            raise ActiveRecord::RecordNotFound if print.nil?

            refuse!('This print cannot be taken back.') unless voidable?(snapshot, print, staff)
            print.void!
            AuditEntry.record!(store: store, actor: staff, action: 'receipt.print_voided', subject: snapshot,
                               metadata: { print_id: print.prefixed_id, copy_number: print.copy_number, reason: reason })
            print.reload.to_pos
          end
        end

        def voidable?(snapshot, print, staff)
          print.printer_id.present? && print.actor_id == staff.id && !print.voided? && print.created_at > WINDOW.ago && print.latest?
        end

        def refuse!(message)
          raise Conflict.new(message, reason: 'print_not_voidable')
        end
      end
    end
  end
end

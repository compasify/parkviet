# frozen_string_literal: true

module Spree
  module Pos
    module CupLabels
      # A branch's cup label printer, label size and fields, and how long a
      # ready number stays on the call board. Kitchen managers set it up,
      # like stations; every change is one command with an audit entry.
      module Setup
        module_function

        def settings(branch)
          Settings.for(branch).merge('branch_id' => branch.prefixed_id, 'printer_id' => branch.cup_label_printer&.prefixed_id,
                                     'module_enabled' => ModulePolicy.enabled?(branch, Issue::MODULE),
                                     'sizes' => Settings::SIZES.keys, 'available_fields' => Settings::FIELDS)
        end

        # `attributes`: printer_id (blank for none), size, fields, pickup_minutes.
        def update(store:, staff:, key:, branch:, attributes:)
          attributes = attributes.to_h.slice('printer_id', *Settings::KEYS)
          run(store, staff, key, branch, 'cup_label.settings', attributes) do
            branch.lock!
            before = settings(branch).slice('printer_id', *Settings::KEYS)
            branch.cup_label_settings = Settings.merge!(branch, attributes.except('printer_id'))
            branch.cup_label_printer = printer!(branch, attributes['printer_id']) if attributes.key?('printer_id')
            if branch.changed?
              branch.save!
              AuditEntry.record!(store: store, actor: staff, action: 'cup_label.settings', subject: branch,
                                 metadata: { 'before' => before, 'after' => settings(branch).slice('printer_id', *Settings::KEYS) })
            end
            settings(branch)
          end
        end

        # A sample label on the branch's cup label printer, to check size and
        # layout on the real stock.
        def test(store:, staff:, key:, branch:)
          run(store, staff, key, branch, 'cup_label.test', {}) do
            printer = branch.cup_label_printer
            raise Conflict.new('This branch has no cup label printer.', reason: 'cup_label_printer_missing') if printer.nil?

            document = Document.sample(branch: branch, settings: Settings.for(branch), at: Workspace.database_now)
            PrintJobs::Enqueue.call(store: store, printer: printer, kind: 'cup_label', document: document,
                                    key: "cup_label_test:#{key}", actor: staff, source: branch).to_pos
          end
        end

        def run(store, staff, key, branch, command, attributes, &)
          payload = { 'command' => command, 'branch_id' => branch.prefixed_id, 'attributes' => attributes }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { Kitchen::Guard.manage!(store, staff, branch) }, &)
        end

        def printer!(branch, id)
          return if id.blank?

          printer = Printer.locate(Printer.where(branch_id: branch.id), id) || raise(ActiveRecord::RecordNotFound)
          raise Conflict.new('This printer does not take queued jobs.', reason: 'printer_not_queued') unless printer.station?

          printer
        end
      end
    end
  end
end

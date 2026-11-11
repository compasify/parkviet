# frozen_string_literal: true

module Spree
  module Pos
    module Printers
      # Creates or changes a printer of a branch.
      module Save
        FIELDS = %w[name connection address bluetooth_id paper command_language roles status settings].freeze
        REFERENCES = %w[print_station_device_id register_id].freeze

        module_function

        def create(store:, staff:, key:, branch:, attributes:)
          payload = { 'command' => 'printer.create', 'branch_id' => branch.prefixed_id, 'attributes' => attributes }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { PrintJobs::Guard.manage!(store, staff, branch) }) do
            printer = Printer.new(store: store, branch: branch)
            apply(printer, store, branch, attributes)
            printer.save!
            AuditEntry.record!(store: store, actor: staff, action: 'printer.create', subject: printer, metadata: audit(printer))
            printer.to_pos
          end
        end

        def update(store:, staff:, key:, printer:, attributes:)
          payload = { 'command' => 'printer.update', 'printer_id' => printer.prefixed_id, 'attributes' => attributes }
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload,
                               authorize: -> { PrintJobs::Guard.manage!(store, staff, printer.branch) }) do
            printer.lock!
            apply(printer, store, printer.branch, attributes)
            printer.save!
            AuditEntry.record!(store: store, actor: staff, action: 'printer.update', subject: printer, metadata: audit(printer))
            printer.to_pos
          end
        end

        def apply(printer, store, branch, attributes)
          printer.assign_attributes(attributes.slice(*FIELDS))
          printer.print_station_device = device(store, branch, attributes['print_station_device_id']) if attributes.key?('print_station_device_id')
          printer.register = register(store, branch, attributes['register_id']) if attributes.key?('register_id')
        end

        def device(store, branch, id)
          return if id.blank?

          Device.locate(Device.for_store(store).where(branch_id: branch.id), id) || raise(ActiveRecord::RecordNotFound)
        end

        def register(store, branch, id)
          return if id.blank?

          Register.locate(Register.for_store(store).where(branch_id: branch.id), id) || raise(ActiveRecord::RecordNotFound)
        end

        def audit(printer)
          { connection: printer.connection, status: printer.status, roles: printer.roles }
        end
      end
    end
  end
end

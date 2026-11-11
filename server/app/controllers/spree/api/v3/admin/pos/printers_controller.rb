# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # A branch's printers. Reading is for the people working there, since
          # the counter routes by them; changing needs pos.printer.manage or
          # store administration.
          class PrintersController < BaseController
            scoped_resource :pos_topology
            pos_permissions index: %w[read_pos_orders write_pos_orders read_pos_topology write_pos_topology],
                            stations: %w[write_pos_orders write_pos_topology],
                            create: %w[write_pos_orders write_pos_topology], update: %w[write_pos_orders write_pos_topology],
                            destroy: %w[write_pos_orders write_pos_topology], test: %w[write_pos_orders write_pos_topology]

            def index
              branch = guard.branch!(current_store, params[:branch_id])
              guard.read!(current_store, current_user, branch)
              printers = Spree::Pos::Printer.for_store(current_store).where(branch: branch).includes(:branch, :register, :print_station_device).order(:name, :id)
              render json: { data: printers.map(&:to_pos) }
            end

            # The print stations a printer of this branch can be bound to: id and
            # name only, for people who manage printers but not devices.
            def stations
              branch = guard.branch!(current_store, params[:branch_id])
              guard.manage!(current_store, current_user, branch)
              devices = Spree::Pos::Device.for_store(current_store).active.where(branch: branch, mode: 'print_station').order(:name)
              render json: { data: devices.map { |device| { id: device.prefixed_id, name: device.name } } }
            end

            def create
              key = idempotency_key
              return if key.nil?

              branch = guard.branch!(current_store, params[:branch_id])
              result = Spree::Pos::Printers::Save.create(store: current_store, staff: current_user, key: key, branch: branch, attributes: attributes)
              render json: { data: result }, status: :created
            end

            def update
              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::Printers::Save.update(store: current_store, staff: current_user, key: key, printer: printer!, attributes: attributes)
              render json: { data: result }
            end

            # Prefer disabling: a printer that has jobs is refused here.
            def destroy
              key = idempotency_key
              return if key.nil?

              printer = printer!
              payload = { 'command' => 'printer.destroy', 'printer_id' => printer.prefixed_id }
              result = Spree::Pos::CommandExecutor.call(store: current_store, actor: current_user, key: key, payload: payload,
                                                        authorize: -> { guard.manage!(current_store, current_user, printer.branch) }) do
                raise Spree::Pos::Conflict.new('This printer has print jobs. Disable it instead.', reason: 'printer_in_use') unless printer.destroy

                audit!('printer.destroy', printer, name: printer.name)
                { 'id' => printer.prefixed_id }
              end
              render json: { data: result }
            end

            # A station printer gets a queued test job. Printers the browser
            # drives get the document back to print from the browser.
            def test
              key = idempotency_key
              return if key.nil?

              printer = printer!
              guard.manage!(current_store, current_user, printer.branch)
              raise Spree::Pos::Conflict.new('This printer is disabled.', reason: 'printer_disabled') if printer.disabled?

              document = Spree::Pos::PrintDocuments.test_page(printer: printer, now: Spree::Pos::Workspace.database_now)
              return render(json: { data: { print_job: nil, document: document } }) unless printer.station?

              payload = { 'command' => 'printer.test', 'printer_id' => printer.prefixed_id }
              result = Spree::Pos::CommandExecutor.call(store: current_store, actor: current_user, key: key, payload: payload, authorize: -> {}) do
                job = Spree::Pos::PrintJobs::Enqueue.call(store: current_store, printer: printer, kind: 'test', document: document,
                                                          key: Spree::Pos::PrintJobs::Create.job_key(current_user, key), actor: current_user, source: printer)
                { 'print_job' => job.to_pos }
              end
              render json: { data: result.merge('document' => nil) }, status: :created
            end

            private

            def guard
              Spree::Pos::PrintJobs::Guard
            end

            def printer!
              guard.printer!(current_store, params[:id])
            end

            def attributes
              params.permit(*Spree::Pos::Printers::Save::FIELDS.without('roles', 'settings'), *Spree::Pos::Printers::Save::REFERENCES, roles: [], settings: {}).
                to_h
            end
          end
        end
      end
    end
  end
end

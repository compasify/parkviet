# frozen_string_literal: true

module Spree
  module Pos
    module PrintJobs
      # Who may do what with a branch's printers and print queue.
      module Guard
        OPEN_WORKSPACE_STATUSES = %w[editing parked].freeze

        module_function

        def policy(store, staff)
          AccessPolicy.new(store: store, staff: staff)
        end

        def manage!(store, staff, branch)
          access = policy(store, staff)
          raise CanCan::AccessDenied unless access.allows?(branch, Capabilities::PRINTER_MANAGE) || access.permission?('write_pos_topology')
        end

        # The printers of a branch and its queue are read by the people working
        # there: the counter needs them to choose where a document prints.
        def read!(store, staff, branch)
          access = policy(store, staff)
          raise ActiveRecord::RecordNotFound unless access.membership_for(branch)&.status == 'active' || access.permission?('read_pos_topology')
        end

        def operate!(store, staff, branch)
          access = policy(store, staff)
          allowed = [Capabilities::OPEN_SHIFT, Capabilities::TAKEOVER, Capabilities::PRINTER_MANAGE].any? { |capability| access.allows?(branch, capability) }
          raise CanCan::AccessDenied unless allowed || access.permission?('write_pos_topology')
        end

        def branch!(store, branch_id)
          Branch.locate(Branch.for_store(store), branch_id) || raise(ActiveRecord::RecordNotFound)
        end

        def printer!(store, printer_id, branch: nil)
          scope = Printer.for_store(store)
          scope = scope.where(branch_id: branch.id) if branch
          Printer.locate(scope, printer_id) || raise(ActiveRecord::RecordNotFound)
        end

        # Only a workspace still being worked on has a bill to print.
        def open_workspace!(workspace)
          return if OPEN_WORKSPACE_STATUSES.include?(workspace.operational_status)

          raise Conflict.new('This order is no longer open.', reason: 'workspace_not_open')
        end

        # The browser can only be sent to an active LAN printer set up for receipts.
        def direct_printer!(printer)
          raise Conflict.new('This printer is disabled.', reason: 'printer_disabled') if printer.disabled?
          raise Conflict.new('The browser cannot reach this printer.', reason: 'printer_not_direct') unless printer.direct?
          raise Conflict.new('This printer is not set up for this document.', reason: 'printer_wrong_kind') unless printer.prints?('receipt')
        end

        def job!(store, job_id)
          PrintJob.locate(PrintJob.for_store(store), job_id) || raise(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end

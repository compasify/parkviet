# frozen_string_literal: true

module Spree
  module Pos
    module Reservations
      # Part of paying a table order: the held deposits of the booking seated
      # at it are applied to the order, each as a completed core Payment and
      # a FundsAllocation of its receipt (the way a collection settles an
      # order), up to what the order still owes. The rest of the bill is
      # tendered as usual; what a deposit does not cover stays available on
      # its receipt for a refund. Runs under the order's lease like any
      # payment step.
      module ApplyDeposit
        COMMAND = 'reservation.apply_deposit'

        module_function

        def call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:)
          payload = { 'command' => COMMAND, 'revision' => revision, 'lease_generation' => lease_generation,
                      'editor_digest' => Workspace.editor_digest(editor_id) }
          authorize = lambda do
            Tenders::Guard.authorize_editor!(workspace, staff)
            Tenders::Guard.authorize_collect!(workspace, staff)
          end
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace, authorize: authorize) do
            Tenders::Guard.validate_editor!(workspace, staff, revision, lease_generation, editor_id)
            Tenders::Guard.validate_open_shift!(workspace)
            if TenderAttempt.where(workspace: workspace, status: %w[prepared unknown]).exists?
              raise Conflict, 'A prepared tender already reserves this snapshot.'
            end

            reservation = Reservation.find_by(workspace_id: workspace.id)
            raise Conflict.new('No booking is seated at this order.', revision: workspace.revision, reason: 'reservation_missing') if reservation.nil?

            reservation.lock!
            applied = apply!(workspace, reservation)
            raise Conflict.new('No deposit is left to apply.', revision: workspace.revision, reason: 'deposit_none') if applied.empty?

            workspace.update!(revision: workspace.revision + 1)
            reservation.bump!
            AuditEntry.record!(store: workspace.store, actor: staff, action: COMMAND, subject: workspace,
                               metadata: { reservation_id: reservation.prefixed_id,
                                           allocations: applied.map { |row| { id: row.prefixed_id, amount: row.amount.to_s('F') } } })
            workspace.to_pos
          end
        end

        def apply!(workspace, reservation)
          order = workspace.order
          reservation.deposits.where(status: 'held').order(:id).filter_map do |deposit|
            funds = deposit.received_funds.lock!
            raise Conflict, 'Funds currency does not match the order.' if funds.currency != order.currency

            owed = order.total - FundsAllocation.where(workspace: workspace, status: 'active').sum(:amount)
            amount = [FundsBalance.new(funds).available, owed].min
            next nil unless amount.positive?

            core_method = Funds::Allocate.core_method_for(funds)
            raise Conflict.new('Payment method is not available for this store.', reason: 'payment_method_unavailable') if core_method.nil?

            payment = order.payments.create!(payment_method: core_method, amount: amount)
            payment.complete!
            allocation = FundsAllocation.create!(store: workspace.store, received_funds: funds, workspace: workspace, order: order,
                                                 payment: payment, status: 'active', amount: amount, currency: order.currency)
            deposit.update!(status: 'applied', funds_allocation: allocation, resolution_order: order, resolved_at: Time.current)
            allocation
          end
        end
      end
    end
  end
end

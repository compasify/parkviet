# frozen_string_literal: true

module Spree
  module Pos
    module Reservations
      # Keeps the deposit of a booking the guest canceled or did not come
      # to. Kept money becomes revenue only through a sale: a service order
      # of the branch's holding-fee product (an ordinary, taxed line) priced
      # at the deposit, paid by allocating the deposit's receipt, and
      # completed on the requester's own open shift like any order. Needs an
      # approval of `reservation.forfeit_deposit` for that amount unless the
      # requester approves.
      module ForfeitDeposit
        ACTION = 'reservation.forfeit_deposit'
        ENDED = %w[canceled no_show].freeze

        module_function

        def call(store:, staff:, key:, deposit_id:, approval_id: nil)
          payload = { 'command' => ACTION, 'deposit_id' => deposit_id.to_s, 'approval_id' => approval_id.to_s.presence }
          deposit = Guard.deposit!(store, deposit_id)
          reservation = deposit.reservation
          branch = reservation.branch
          authorize = lambda do
            Guard.resolve!(store, staff, branch)
            raise CanCan::AccessDenied unless AccessPolicy.new(store: store, staff: staff).allows?(branch, Capabilities::PAYMENT)
          end
          CommandExecutor.call(store: store, actor: staff, key: key, payload: payload, authorize: authorize) do
            shift = Shift.for_store(store).open_now.find_by(branch_id: branch.id, owner_id: staff.id)
            raise Conflict.new('Open your own shift before keeping a deposit.', reason: 'shift_required') if shift.nil?

            reservation.lock!
            deposit.lock!
            raise Conflict.new('This deposit is already settled.', reason: 'deposit_settled') unless deposit.held?
            unless ENDED.include?(reservation.status)
              raise Conflict.new('Only a canceled or missed booking keeps its deposit.', reason: 'reservation_not_ended',
                                                                                         details: { status: reservation.status })
            end

            product = branch.reservation_fee_product
            raise Conflict.new('Choose the holding-fee service of this branch first.', reason: 'reservation_fee_product_missing') if product.nil?

            funds = deposit.received_funds
            amount = FundsBalance.new(funds).available
            raise Conflict.new('Nothing of this deposit is left.', reason: 'deposit_none') unless amount.positive?

            approval = Guard.approve!(reservation, staff, ACTION, amount, approval_id)
            workspace, allocation = fee_order!(store, staff, shift, product, funds, amount, key)
            deposit.update!(status: 'forfeited', resolution_order: workspace.order, funds_allocation: allocation, resolved_at: Time.current)
            reservation.bump!
            AuditEntry.record!(store: store, actor: staff, action: ACTION, subject: reservation,
                               metadata: { deposit_id: deposit.prefixed_id, workspace_id: workspace.prefixed_id,
                                           order_id: workspace.order.prefixed_id, amount: amount.to_s('F'),
                                           approval_id: approval&.prefixed_id })
            reservation.reload.to_pos.merge(fee_workspace_id: workspace.prefixed_id)
          end
        end

        # The holding-fee sale, paid from the deposit and completed.
        def fee_order!(store, staff, shift, product, funds, amount, key)
          editor_id = SecureRandom.uuid
          workspace = Workspaces::Create.draft!(store: store, staff: staff, shift: shift, editor_digest: Workspace.editor_digest(editor_id),
                                                service_mode: 'counter')
          workspace.update!(note: 'Phí giữ chỗ (mất cọc đặt bàn)')
          LineBuilder.add!(workspace: workspace, staff: staff, variant_id: product.default_variant.prefixed_id, quantity: 1,
                           merge: false, server_price: amount)
          Workspaces::ApplyDiscount.recalculate!(workspace)
          order = workspace.order.reload
          unless order.total == amount
            raise Conflict.new('The holding fee must be priced with its tax included.', reason: 'reservation_fee_tax_excluded')
          end

          core_method = Funds::Allocate.core_method_for(funds)
          raise Conflict, 'Payment method is not available for this store.' if core_method.nil?

          allocation = funds.with_lock do
            payment = order.payments.create!(payment_method: core_method, amount: amount)
            payment.complete!
            FundsAllocation.create!(store: store, received_funds: funds, workspace: workspace, order: order, payment: payment,
                                    status: 'active', amount: amount, currency: order.currency)
          end
          workspace.update!(revision: workspace.revision + 1)
          Workspaces::Complete.call(workspace: workspace, staff: staff, revision: workspace.revision,
                                    lease_generation: workspace.lease_generation, editor_id: editor_id, key: "#{key}:complete")
          [workspace.reload, allocation]
        end
      end
    end
  end
end

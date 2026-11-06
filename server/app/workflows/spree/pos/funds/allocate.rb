# frozen_string_literal: true

module Spree
  module Pos
    module Funds
      # Allocates available unapplied funds to this workspace order. Used for
      # excess/late receipts after the original tender; never creates money.
      class Allocate
        def self.call(workspace:, staff:, revision:, lease_generation:, editor_id:, key:, funds_id:, amount:)
          parsed = Record.money(amount.to_s)
          payload = {
            'command' => 'funds.allocate', 'revision' => revision, 'lease_generation' => lease_generation,
            'editor_digest' => Workspace.editor_digest(editor_id), 'funds_id' => funds_id.to_s, 'amount' => parsed&.to_s('F')
          }
          authorize = lambda do
            Tenders::Guard.authorize_editor!(workspace, staff)
            policy = AccessPolicy.new(store: workspace.store, staff: staff)
            raise CanCan::AccessDenied unless policy.allows?(workspace.branch, Capabilities::RESOLVE)
          end
          CommandExecutor.call(store: workspace.store, actor: staff, key: key, payload: payload, workspace: workspace, authorize: authorize) do
            Tenders::Guard.validate_editor!(workspace, staff, revision, lease_generation, editor_id)
            Tenders::Guard.validate_open_shift!(workspace)
            Tenders::Guard.tracked_guard!(workspace)
            raise Conflict, 'Amount is invalid.' if parsed.nil? || parsed <= 0
            raise Conflict, 'A prepared tender already reserves this snapshot.' if TenderAttempt.where(workspace: workspace, status: %w[prepared unknown]).exists?

            funds = ReceivedFunds.locate(ReceivedFunds.for_store(workspace.store), funds_id)
            raise ActiveRecord::RecordNotFound if funds.nil? || funds.branch_id != workspace.branch_id
            # `received` = tender-confirmed; `attention` = unsolicited fact that
            # a resolver may now allocate. Both are real money on the parent.
            raise Conflict, 'Funds are not in a received state.' unless %w[received attention].include?(funds.status)

            allocation = nil
            funds.with_lock do
              raise Conflict, 'Amount exceeds available unapplied funds.' if FundsBalance.new(funds).available < parsed

              order = workspace.order
              allocated = FundsAllocation.where(workspace: workspace, status: 'active').sum(:amount)
              raise Conflict, 'Amount exceeds the remaining balance.' if parsed > order.total - allocated

              core_method = core_method_for(funds)
              raise Conflict, 'Payment method is not available for this store.' if core_method.nil?

              payment = order.payments.create!(payment_method: core_method, amount: parsed)
              payment.complete!
              allocation = FundsAllocation.create!(
                store: workspace.store, received_funds: funds, workspace: workspace, order: order,
                payment: payment, status: 'active', amount: parsed, currency: order.currency
              )
              funds.update!(workspace: workspace) if funds.workspace_id.nil?
            end
            workspace.update!(revision: workspace.revision + 1)
            AuditEntry.record!(store: workspace.store, actor: staff, action: 'funds.allocate', subject: workspace,
                               metadata: { funds_id: funds.prefixed_id, allocation_id: allocation.prefixed_id, amount: parsed.to_s('F') })
            workspace.to_pos
          end
        end

        def self.core_method_for(funds)
          attempt_method = funds.tender_attempt&.pos_payment_method
          return PaymentMethodResolver.new(store: funds.store).core_for(attempt_method) if attempt_method

          resolver = PaymentMethodResolver.new(store: funds.store)
          row = resolver.available.find { |candidate| candidate.kind == funds.kind }
          row && resolver.core_for(row)
        end
      end
    end
  end
end

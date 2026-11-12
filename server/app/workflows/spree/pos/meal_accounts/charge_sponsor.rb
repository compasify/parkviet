# frozen_string_literal: true

module Spree
  module Pos
    module MealAccounts
      # The sponsor's part of a meal order, sold on the sponsor's credit
      # account as the order completes (Workspaces::Complete with
      # `meal_sponsor`). The part is the order's unpaid remainder and must be
      # exactly the sponsor's part of SplitPlan, so the eater's part is
      # already paid. No manager approves each meal: the sponsor's limit was
      # approved on its credit account, and the debit is checked against it
      # under the account lock (`sponsor_limit` when it does not fit). The
      # debit is the order's receivable entry, collected like any credit sale.
      # Lock order: workspace -> meal account -> credit account.
      module ChargeSponsor
        module_function

        # [debt, meal account, sponsor] after the checks, before any write.
        def plan!(workspace, allocated)
          ModulePolicy.require!(workspace.branch, Guard::MODULE)
          account = Guard.for_workspace(workspace)
          raise Conflict.new('No meal account is on this order.', reason: 'meal_account_missing') if account.nil?

          account.lock!
          raise Conflict.new('This meal account is locked.', reason: 'meal_account_locked') unless account.active?

          plan = SplitPlan.call(workspace, account: account)
          raise Conflict.new('The sponsor cannot pay for this meal.', reason: 'sponsor_unavailable') if plan[:sponsor_unavailable]

          share = BigDecimal(plan[:sponsor_amount])
          raise Conflict.new('The sponsor pays nothing for this meal.', reason: 'sponsor_nothing_due') unless share.positive?

          debt = workspace.order.total - allocated
          unless debt == share
            raise Conflict.new("The eater's part is not paid exactly.", reason: 'meal_split_unpaid',
                                                                        details: { sponsor_amount: share.to_s('F'),
                                                                                   employee_amount: plan[:employee_amount] })
          end

          [debt, account, account.meal_sponsor]
        end

        def commit!(workspace, staff, debt, account, sponsor)
          credit = sponsor.credit_account.lock!
          raise Conflict.new('The sponsor credit account is suspended.', reason: 'sponsor_unavailable') unless credit.active?
          unless credit.exposure.fits?(debt)
            raise Conflict.new('The sponsor credit limit would be exceeded.', reason: 'sponsor_limit',
                                                                              details: { available: credit.exposure.available.to_s('F') })
          end

          # The debit is bound to a reservation like every credit sale: here
          # one recorded and committed in the same step, under a self-approval
          # consumed at once.
          now = Time.current
          approval = Approval.create!(
            store: workspace.store, branch: workspace.branch, approver: staff, requester: staff, subject_type: workspace.class.name,
            subject_id: workspace.id, action: Approval::MEAL_SPONSOR_ACTION, amount: debt, currency: credit.currency,
            revision: workspace.revision.to_s, status: 'consumed', consumed_at: now, expires_at: now + 1.minute, self_credit: true
          )
          reservation = CreditReservation.create!(
            store: workspace.store, credit_account: credit, workspace: workspace, approval: approval,
            customer_profile: account.customer_profile, amount: debt, currency: credit.currency,
            workspace_revision: workspace.revision, status: 'committed', committed_at: now
          )
          ReceivableEntry.create!(
            store: workspace.store, credit_account: credit, branch: workspace.branch, order: workspace.order, workspace: workspace,
            credit_reservation: reservation, actor: staff, kind: 'debit', amount: debt, currency: credit.currency,
            due_on: Credit::Commit.due_on(workspace.branch, credit), source_type: account.class.name, source_id: account.id,
            metadata: { 'meal_account_id' => account.prefixed_id, 'employee_code' => account.employee_code }
          )
        end
      end
    end
  end
end

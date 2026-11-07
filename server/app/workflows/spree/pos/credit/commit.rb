# frozen_string_literal: true

module Spree
  module Pos
    module Credit
      # Turns an approved reservation into the order's immutable debit entry.
      # Runs inside the completion transaction, after the workspace lock, so
      # the debit and the order placement commit or roll back together.
      # Lock order: workspace -> account -> reservation -> approval.
      class Commit
        def self.call(workspace:, staff:, approval_id:, amount:)
          approval = Approval.locate(Approval.for_store(workspace.store).where(branch_id: workspace.branch_id), approval_id)
          raise stale('Credit approval was not found.') if approval.nil?

          reservation = CreditReservation.find_by(approval_id: approval.id, workspace_id: workspace.id)
          raise stale('Credit approval does not belong to this order.') if reservation.nil?

          account = reservation.credit_account.lock!
          reservation.lock!
          raise stale('Credit approval is no longer usable.') unless reservation.holding?
          raise Conflict.new('Credit account is suspended.', reason: 'credit_account_suspended') unless account.active?
          raise stale('Credit amount no longer matches the unpaid remainder.') unless reservation.amount == amount

          begin
            approval.consume!(action: ACTION, amount: amount, currency: reservation.currency, revision: workspace.revision,
                              subject: workspace, requester: staff)
          rescue Conflict => e
            raise stale(e.message)
          end

          reservation.update!(status: 'committed', committed_at: Time.current)
          ReceivableEntry.create!(
            store: workspace.store, credit_account: account, branch: workspace.branch, order: workspace.order,
            workspace: workspace, credit_reservation: reservation, actor: staff, kind: 'debit', amount: amount,
            currency: reservation.currency, due_on: due_on(workspace.branch, account)
          )
        end

        def self.due_on(branch, account)
          Time.now.in_time_zone(branch.timezone).to_date + account.due_days
        end

        def self.stale(message)
          Conflict.new(message, reason: STALE)
        end
      end
    end
  end
end

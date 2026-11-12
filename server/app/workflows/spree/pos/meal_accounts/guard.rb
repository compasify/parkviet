# frozen_string_literal: true

module Spree
  module Pos
    module MealAccounts
      # Shared rules of canteen commands. Accounts and sponsors belong to the
      # store; the branch a command names is where its people work, where the
      # module must be on, and where approvals and receipts are booked.
      module Guard
        MODULE = 'fnb.meal_accounts'

        module_function

        # Adding, importing, locking and changing accounts and sponsors.
        def manage!(store, staff, branch)
          access = AccessPolicy.new(store: store, staff: staff)
          raise CanCan::AccessDenied if branch.disabled?
          return if access.permission?('write_pos_topology') || access.allows?(branch, Capabilities::MEAL_ACCOUNT_MANAGE)

          raise CanCan::AccessDenied
        end

        # Looking accounts up: their managers and the counter.
        def read!(store, staff, branch)
          access = AccessPolicy.new(store: store, staff: staff)
          return if access.permission?('write_pos_topology')

          keys = [Capabilities::MEAL_ACCOUNT_MANAGE, Capabilities::OPEN_SHIFT, Capabilities::PAYMENT]
          raise CanCan::AccessDenied unless keys.any? { |key| access.allows?(branch, key) }
        end

        # Asking for a wallet refund or correction: managers and cashiers.
        def request!(store, staff, branch)
          access = AccessPolicy.new(store: store, staff: staff)
          raise CanCan::AccessDenied if branch.disabled?
          return if [Capabilities::MEAL_ACCOUNT_MANAGE, Capabilities::OPEN_SHIFT].any? { |key| access.allows?(branch, key) }

          raise CanCan::AccessDenied
        end

        def branch!(store, branch_id)
          Branch.locate(Branch.for_store(store), branch_id) || raise(ActiveRecord::RecordNotFound)
        end

        def account!(store, account_id)
          MealAccount.locate(MealAccount.for_store(store), account_id) || raise(ActiveRecord::RecordNotFound)
        end

        def sponsor!(store, sponsor_id)
          MealSponsor.locate(MealSponsor.for_store(store), sponsor_id) || raise(ActiveRecord::RecordNotFound)
        end

        def amount!(value, currency, allow_negative: false)
          text = value.to_s.strip
          negative = allow_negative && text.start_with?('-')
          parsed = Record.money(negative ? text.delete_prefix('-') : text)
          invalid = parsed.nil? || parsed.zero? || !Record.countable_money?(parsed, currency)
          raise Conflict.new('The amount is invalid.', reason: 'meal_amount_invalid') if invalid

          negative ? -parsed : parsed
        end

        # The meal account whose eater was recorded on this order, or nil.
        def for_workspace(workspace)
          return nil if workspace.pos_customer_id.nil?

          swipe = MealSwipe.counting.where(workspace_id: workspace.id).order(id: :desc).first
          swipe&.meal_account
        end

        # An approver needs nothing more; anyone else brings an approval of
        # this account as it is now. Returns the consumed approval, or nil.
        def approve!(account, staff, branch, action, amount, approval_id)
          policy = AccessPolicy.new(store: account.store, staff: staff)
          return nil if policy.allows?(branch, Capabilities::APPROVE)

          message = 'This needs an approval.'
          raise Conflict.new(message, reason: 'approval_required', details: { action: action }) if approval_id.blank?

          approval = Approval.locate(Approval.for_store(account.store).where(branch_id: branch.id), approval_id)
          raise Conflict.new(message, reason: 'approval_required', details: { action: action }) if approval.nil?

          approval.consume!(action: action, amount: amount, currency: amount && account.store.default_currency,
                            revision: account.revision, subject: account, requester: staff)
          AuditEntry.record!(store: account.store, actor: staff, action: 'approval.consume', subject: approval,
                             metadata: { approval_action: action, approver_id: approval.approver.prefixed_id,
                                         amount: amount&.to_s('F') })
          approval
        end

        def text!(value, max, field)
          string = value.to_s.strip
          raise Conflict.new("The #{field} is too long.", reason: 'meal_account_invalid', details: { field: field }) if string.length > max

          string.presence
        end
      end
    end
  end
end

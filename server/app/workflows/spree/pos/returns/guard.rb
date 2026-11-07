# frozen_string_literal: true

module Spree
  module Pos
    module Returns
      # Shared lookups and the return plan. Lock order for every return,
      # refund and exchange command:
      #   return operation -> sale lines (by id) -> credit account -> parent funds -> order.
      module Guard
        module_function

        def authorize_return!(store, staff, branch)
          policy = AccessPolicy.new(store: store, staff: staff)
          raise CanCan::AccessDenied if branch.disabled? || !policy.permission?('write_pos_orders') ||
            !policy.allows?(branch, Capabilities::RETURN)
        end

        def branch!(store, branch_id)
          branch = Branch.locate(Branch.for_store(store), branch_id)
          raise ActiveRecord::RecordNotFound if branch.nil?

          branch
        end

        def operation!(store, return_id)
          operation = ReturnOperation.locate(ReturnOperation.for_store(store), return_id)
          raise ActiveRecord::RecordNotFound if operation.nil?

          operation
        end

        # A placed POS sale of this store, wherever it was sold. Callers decide
        # who may see it.
        def sale!(store, order_id)
          order = Spree::Order.find_by_prefix_id(order_id.to_s)
          raise ActiveRecord::RecordNotFound if order.nil? || order.store_id != store.id

          workspace = Workspace.for_store(store).find_by(order_id: order.id, operational_status: 'completed')
          raise ActiveRecord::RecordNotFound if workspace.nil?

          workspace
        end

        def lock_sale_lines!(ids)
          SaleLine.where(id: ids.uniq.sort).order(:id).lock.to_a
        end

        def today(branch)
          Time.current.in_time_zone(branch.timezone).to_date
        end

        def out_of_window?(order, branch)
          placed = order.completed_at || order.updated_at
          (today(branch) - placed.in_time_zone(branch.timezone).to_date).to_i > branch.return_window_days.to_i
        end

        def receivable_balance(order)
          ReceivableEntry.balance_sum(ReceivableEntry.where(order_id: order.id))
        end

        # Money the order actually received through its allocation children.
        def paid(order)
          FundsAllocation.where(order_id: order.id, status: 'active').where.not(payment_id: nil).sum(:amount)
        end

        # Splits `value` returned on `order` into the credit note that lowers
        # open debt first and the refund entitlement above it, capped by what
        # was actually paid and not already granted to another return.
        def split(order, value, except: nil, balance: nil)
          others = ReturnOperation.where(order_id: order.id).where.not(status: 'canceled')
          others = others.where.not(id: except.id) if except
          posted_refunds = others.where(entitlement_status: 'posted').sum(:refund_entitlement)
          balance ||= begin
            pending = others.where.not(entitlement_status: 'posted').sum(:entitlement_total)
            [receivable_balance(order) - pending, BigDecimal('0')].max
          end
          credit_note = [value, balance].min
          refund = [value - credit_note, paid(order) - posted_refunds].min.clamp(BigDecimal('0'), nil)
          { credit_note: credit_note, refund: refund }
        end

        def core_error(result, fallback)
          message = result.error
          message = message.errors.full_messages.to_sentence if message.respond_to?(:errors) && message.errors.any?
          message.to_s.presence || fallback
        end
      end
    end
  end
end

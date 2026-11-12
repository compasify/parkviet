# frozen_string_literal: true

module Spree
  module Pos
    module MealAccounts
      # Who pays what of one meal order: the sponsor's part and the eater's
      # part, from the account's pay mode and the sponsor's subsidy. A
      # subsidy is a fixed amount or a percentage of the order, never more
      # than the order, and within the sponsor's daily cap per eater: what
      # the sponsor already paid for this eater's other completed orders of
      # the business day comes off the cap. The checkout prepares the two
      # tenders from this plan and completion checks it again.
      module SplitPlan
        module_function

        def call(workspace, account: Guard.for_workspace(workspace))
          total = workspace.order.total
          return plan(total, BigDecimal('0'), nil, nil, unavailable: false) if account.nil?

          sponsor = account.meal_sponsor
          usable = sponsor&.active? && sponsor.credit_account&.active?
          share = usable ? sponsor_share(workspace, account, sponsor, total) : BigDecimal('0')
          plan(total, share, usable ? sponsor : nil, account, unavailable: account.pay_mode != 'wallet' && !usable)
        end

        def sponsor_share(workspace, account, sponsor, total)
          case account.pay_mode
          when 'sponsor' then total
          when 'sponsor_subsidy' then subsidy(workspace, account, sponsor, total)
          else BigDecimal('0')
          end
        end

        def subsidy(workspace, account, sponsor, total)
          exponent = ::Money::Currency.find(workspace.order.currency)&.exponent || 0
          per_meal = case sponsor.subsidy_mode
                     when 'fixed' then sponsor.subsidy_value
                     when 'percent' then (total * sponsor.subsidy_value / 100).floor(exponent)
                     else BigDecimal('0')
                     end
          share = [per_meal, total].min
          return share if sponsor.subsidy_daily_cap.nil?

          left = sponsor.subsidy_daily_cap - used_today(workspace, account, sponsor)
          [share, [left, BigDecimal('0')].max].min
        end

        # The sponsor's debits for this eater's other orders of the day.
        def used_today(workspace, account, sponsor)
          orders = Workspace.where(store_id: workspace.store_id, pos_customer_id: account.customer_profile_id,
                                   business_date: workspace.business_date, operational_status: 'completed').
                   where.not(id: workspace.id)
          ReceivableEntry.balance_sum(ReceivableEntry.where(credit_account_id: sponsor.credit_account_id, kind: 'debit',
                                                            workspace_id: orders.select(:id)))
        end

        def plan(total, share, sponsor, account, unavailable:)
          {
            meal_account_id: account&.prefixed_id, pay_mode: account&.pay_mode, total: total.to_s('F'),
            sponsor_id: sponsor&.prefixed_id, sponsor_name: sponsor&.name,
            sponsor_amount: share.to_s('F'), employee_amount: (total - share).to_s('F'), sponsor_unavailable: unavailable
          }
        end
      end
    end
  end
end

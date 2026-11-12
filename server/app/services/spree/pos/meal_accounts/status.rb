# frozen_string_literal: true

module Spree
  module Pos
    module MealAccounts
      # What the counter shows about the eater on an order: who they are,
      # the wallet balance, the meals left today and who pays what.
      module Status
        module_function

        def call(account, workspace)
          return nil if account.nil?

          balance = account.stored_value_account.balance
          used = MealSwipe.counting.where(meal_account_id: account.id, business_date: workspace.business_date).count
          plan = SplitPlan.call(workspace, account: account)
          threshold = account.low_balance_threshold
          account.to_pos(balance: balance).merge(
            meals_today: used,
            meals_left: account.daily_meal_limit && [account.daily_meal_limit - used, 0].max,
            low_balance: threshold.present? && balance < threshold,
            wallet_covers: balance >= BigDecimal(plan[:employee_amount]),
            plan: plan
          )
        end
      end
    end
  end
end

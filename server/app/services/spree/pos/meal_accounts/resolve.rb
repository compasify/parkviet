# frozen_string_literal: true

module Spree
  module Pos
    module MealAccounts
      # The one place an eater is identified: an exact employee code, or
      # suggestions by name. Read only and always inside one store. A meal
      # card, when canteens get one, is one more lookup here; the counter
      # screen and the meal recording do not change.
      module Resolve
        SUGGESTIONS = 8

        module_function

        # { match: account or nil, suggestions: [accounts] }
        def call(store:, input:)
          text = input.to_s.strip.first(120)
          return { match: nil, suggestions: [] } if text.blank?

          scope = MealAccount.for_store(store).includes(:customer_profile, :meal_sponsor, :stored_value_account)
          match = by_code(scope, text)
          return { match: match, suggestions: [] } if match

          { match: nil, suggestions: by_name(scope, text) }
        end

        def by_code(scope, text)
          code = MealAccount.normalize_code(text)
          code&.match?(MealAccount::CODE_FORMAT) ? scope.find_by(employee_code: code) : nil
        end

        def by_name(scope, text)
          return [] if text.length < 2

          term = "%#{ActiveRecord::Base.sanitize_sql_like(text)}%"
          scope.joins(:customer_profile).
            where('spree_pos_customers.name ILIKE :term OR spree_pos_meal_accounts.employee_code ILIKE :term', term: term).
            order('spree_pos_customers.name', :id).limit(SUGGESTIONS).to_a
        end
      end
    end
  end
end

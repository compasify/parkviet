# frozen_string_literal: true

module Spree
  module Pos
    # Vietnam VAT categories a store can attach to products. The 8% food rate
    # and the 10% rate that replaces it on 2027-01-01 are rows, not code:
    # ApplyTaxRateScheduleJob copies a due schedule onto the tax rate.
    module TaxCategories
      FOOD = 'vat_food'
      SPECIAL = 'vat_special'
      FOOD_RATE = BigDecimal('0.08')
      SPECIAL_RATE = BigDecimal('0.10')
      FOOD_BECOMES_STANDARD_ON = Date.new(2027, 1, 1)

      module_function

      def seed!(store)
        food = category!(store, FOOD, 'VAT thực phẩm')
        special = category!(store, SPECIAL, 'VAT đặc biệt')
        food_rate = rate!(store, food, 'VAT thực phẩm 8%', FOOD_RATE)
        rate!(store, special, 'VAT đặc biệt 10%', SPECIAL_RATE)
        schedule!(store, food_rate, FOOD_BECOMES_STANDARD_ON, SPECIAL_RATE)
      end

      def category!(store, code, name)
        found = Spree::TaxCategory.find_by(store_id: store.id, tax_code: code)
        return found if found

        Spree::TaxCategory.create!(store: store, name: name, tax_code: code, description: name, is_default: false)
      end

      # Spree 6 matches a rate by country code. Vietnam is VN; a later seed
      # leaves an existing rate's amount alone so a schedule can change it.
      def rate!(store, category, name, amount)
        found = Spree::TaxRate.find_by(store_id: store.id, tax_category_id: category.id, country_code: 'VN')
        return found if found

        Spree::TaxRate.create!(
          store: store, tax_category: category, name: name, amount: amount,
          included_in_price: true, show_rate_in_label: true, country_code: 'VN'
        )
      end

      def schedule!(store, tax_rate, effective_on, amount)
        Spree::Pos::TaxRateSchedule.find_or_create_by!(tax_rate: tax_rate, effective_on: effective_on) do |row|
          row.store = store
          row.amount = amount
        end
      end
    end
  end
end

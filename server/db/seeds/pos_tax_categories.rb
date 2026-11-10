# frozen_string_literal: true

# VAT categories for every store that does not already have them. Safe to
# run again: an existing category, rate or schedule is left as it is.
Spree::Store.find_each do |store|
  Spree::Pos::TaxCategories.seed!(store)
end

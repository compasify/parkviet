# frozen_string_literal: true

module Spree
  module Stores
    # Opens another store beside the existing ones — a restaurant next to a
    # retail shop — with its own catalog, orders, payment methods and
    # settings, managed from the same dashboard. Built the way first-run setup
    # builds the default store: the per-store seeds, then the country-shaped
    # defaults. The owner gets the store's admin role, which is what lists it
    # in their store switcher. Never marks the store as default.
    module CreateAdditional
      module_function

      # @param owner [Spree::AdminUser] becomes the new store's admin
      # @param country [Spree::Country] where the store sells from
      # @param attributes [Hash] Spree::Store attributes: name, url and the
      #   email addresses
      # @return [Spree::Store]
      def call(owner:, country:, attributes:, locale: nil, currency: nil)
        ApplicationRecord.transaction do
          store = Spree::Store.create!(attributes.merge(default: false, default_country_code: country.iso))

          Spree::Seeds::StoreResources.call(store: store)
          Spree::Stores::ProvisionDefaults.call(store: store, country: country, locale: locale, currency: currency)
          Spree::Pos::TaxCategories.seed!(store) if country.iso == 'VN'
          store.add_user(owner)

          store.reload
        end
      end
    end
  end
end

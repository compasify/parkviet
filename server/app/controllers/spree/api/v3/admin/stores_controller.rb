# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        # Opens another store from the dashboard. Spree 6 already scopes every
        # Admin API request to the store named by X-Spree-Store-Id and lists
        # the stores a user holds a role on in the store switcher; creating a
        # store is the one step it leaves to the console.
        class StoresController < BaseController
          scoped_resource :settings

          request_params 'StoreCreateParams', action: :create do |body|
            body.attribute :name, :string, required: true, permit: false, example: 'Nhà hàng'
            body.attribute :country_code, :country, required: true, permit: false, example: 'VN',
                                                    description: 'Sets the market, warehouse, delivery zones and currency.'
            body.attribute :locale, :locale, permit: false, example: 'vi', description: "Defaults to the country's language."
            body.attribute :currency, :currency, permit: false, example: 'VND', description: "Defaults to the country's currency."
            body.attribute :mail_from_address, :string, permit: false, format: :email, description: "Defaults to the current store's."
            body.attribute :customer_support_email, :string, permit: false, format: :email, description: "Defaults to the current store's."
          end

          # POST /api/v3/admin/stores
          def create
            return render_owner_only unless owner?
            return render_field_error(:name, "Name can't be blank") if params[:name].blank?
            return render_field_error(:country_code, unknown_country_message) if country.nil?
            return render_field_error(:currency, "Unknown currency #{params[:currency]}") if unknown_currency?
            return render_field_error(:locale, "Unknown locale #{params[:locale]}") if unknown_locale?

            store = Spree::Stores::CreateAdditional.call(
              owner: current_user,
              country: country,
              attributes: store_attributes,
              locale: params[:locale].presence,
              currency: params[:currency].presence
            )

            render json: Spree.api.admin_store_serializer.new(store, params: serializer_params.merge(store: store)).to_h,
                   status: :created
          rescue ActiveRecord::RecordInvalid => e
            render_validation_error(e.record.errors)
          end

          private

          # A secret key is bound to one store, so it never opens another.
          def owner?
            secret_api_key.nil? && current_user.present? && current_user.spree_admin?(current_store)
          end

          # The URL and email addresses left blank come from the current store.
          def store_attributes
            {
              name: params[:name].to_s.strip,
              url: current_store.url.presence || 'localhost',
              mail_from_address: params[:mail_from_address].presence || current_store.mail_from_address,
              customer_support_email: params[:customer_support_email].presence || current_store.customer_support_email
            }
          end

          def country
            @country ||= Spree::Country.by_iso(params[:country_code]) if params[:country_code].present?
          end

          def unknown_country_message
            params[:country_code].present? ? "Unknown country #{params[:country_code]}" : "Country can't be blank"
          end

          def unknown_currency?
            params[:currency].present? && ::Money::Currency.find(params[:currency].to_s.strip).nil?
          end

          def unknown_locale?
            params[:locale].present? && Spree::Locales.listed(params[:locale]).nil?
          end

          def render_owner_only
            render_error(
              code: ERROR_CODES[:access_denied],
              message: 'Only an admin of the current store can open a new store.',
              status: :forbidden
            )
          end

          def render_field_error(field, message)
            render_error(
              code: ERROR_CODES[:validation_error],
              message: message,
              status: :unprocessable_content,
              details: { field => [message] }
            )
          end
        end
      end
    end
  end
end

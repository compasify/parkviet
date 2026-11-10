# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Staff identity plus the branches and shift this session may see.
          # Selling, stock and payment capabilities are not granted here.
          class ContextController < BaseController
            scoped_resource :pos_orders
            pos_permissions show: %w[read_pos_orders read_pos_topology write_pos_topology]

            def show
              return if channel_rejected?

              store = current_store
              resolved = Spree::Pos::ContextResolver.new(store: store, staff: current_user).call(
                branch_id: params[:branch_id],
                register_id: params[:register_id]
              )
              render json: {
                sales_channel: Spree::Pos::SalesChannel.status(store),
                administration: {
                  read: policy.permission?('read_pos_topology') || policy.permission?('write_pos_topology'),
                  write: policy.permission?('write_pos_topology')
                },
                staff: {
                  id: current_user.prefixed_id,
                  email: current_user.email,
                  full_name: current_user.full_name
                },
                store: {
                  id: store.prefixed_id,
                  name: store.name,
                  currency: store.default_currency,
                  locale: store.default_locale,
                  timezone: store_timezone(store),
                  profile: store_profile(store)
                }
              }.merge(resolved)
            end

            private

            # Every printable field, null when blank, so the client sees one shape.
            def store_profile(store)
              present = Spree::Pos::ReceiptBuilder.store_profile(store)
              Spree::Pos::ReceiptBuilder::STORE_PROFILE_FIELDS.index_with { |field| present[field] }.
                merge('logo_url' => store_logo_url(store))
            end

            # The same public URL the Admin API serves as the store's `logo_url`.
            def store_logo_url(store)
              return unless store.respond_to?(:logo) && store.logo.attached?

              Rails.application.routes.url_helpers.cdn_image_url(store.logo)
            rescue ArgumentError => e
              # A missing default host must not stop the POS; the logo is optional.
              Rails.error.report(e, handled: true)
              nil
            end

            def store_timezone(store)
              return unless store.respond_to?(:preferred_timezone)

              value = store.preferred_timezone
              value = value.name if value.respond_to?(:name) && !value.is_a?(String)
              value.to_s.presence
            end
          end
        end
      end
    end
  end
end

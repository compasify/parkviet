# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # The store's e-invoice settings: which invoice it issues, the
          # registered providers it may pick (only those with an adapter),
          # the store default and per-branch rows. Credentials are accepted on
          # write and never returned. `sample` issues a sample invoice through
          # a sandbox provider without saving anything. Store
          # administration (write_pos_topology) only.
          class EinvoiceSettingsController < BaseController
            scoped_resource :pos_topology
            pos_permissions show: %w[write_pos_topology], update: %w[write_pos_topology], sample: %w[write_pos_topology]

            def show
              render json: { data: payload }
            end

            def update
              key = idempotency_key
              return if key.nil?

              branch = params[:branch_id].present? ? branch!(params[:branch_id]) : nil
              Spree::Pos::Einvoices::SaveSettings.call(store: current_store, staff: current_user, key: key,
                                                       einvoice_type: params[:einvoice_type].presence,
                                                       setting: params[:setting].presence, branch: branch)
              render json: { data: payload }
            end

            def sample
              Spree::Pos::Einvoices.settings!(current_store, current_user)
              branch = params[:branch_id].present? ? branch!(params[:branch_id]) : nil
              setting = branch ? Spree::Pos::EinvoiceSetting.for_branch(branch) : default_setting
              raise Spree::Pos::Conflict.new('Choose a provider first.', reason: Spree::Pos::Einvoices::Issue::NOT_CONFIGURED) if setting.nil?

              result = Spree::Pos::Einvoices::Sample.call(setting: setting, branch: branch)
              render json: { data: result }
            end

            private

            def default_setting
              Spree::Pos::EinvoiceSetting.active.find_by(store_id: current_store.id, branch_id: nil)
            end

            def payload
              {
                einvoice_type: Spree::Pos::StoreProfile.einvoice_type_for(current_store),
                providers: Spree::Pos::Einvoices.catalog,
                settings: Spree::Pos::EinvoiceSetting.for_store(current_store).includes(:branch).order(Arel.sql('branch_id NULLS FIRST'), :id).
                          map(&:to_pos),
                public_link: Spree::Pos::Einvoices::BuyerLink.base_url.present?
              }
            end
          end
        end
      end
    end
  end
end

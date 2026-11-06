# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Selectable records are store-scoped; cashier membership is not
          # authority to enumerate staff or warehouses.
          class ConfigurationOptionsController < BaseController
            scoped_resource :pos_topology
            pos_permissions staff: %w[read_pos_topology write_pos_topology], locations: %w[read_pos_topology write_pos_topology]

            def staff
              return if channel_rejected?

              scope = Spree.admin_user_class.joins(:spree_roles)
                .merge(Spree::Role.for_resource(current_store)).where(deactivated_at: nil).distinct.order(:email)
              term = params[:q].to_s.strip
              scope = scope.where('email ILIKE ?', "%#{ActiveRecord::Base.sanitize_sql_like(term)}%") if term.present?
              records, meta = page_scope(scope)
              render json: { data: records.map { |user| { id: user.prefixed_id, email: user.email, full_name: user.full_name } }, meta: meta }
            end

            def locations
              return if channel_rejected?

              records, meta = page_scope(Spree::StockLocation.where(store_id: current_store.id).order(:name, :id))
              render json: { data: records.map { |location| { id: location.prefixed_id, name: location.name, active: location.active } }, meta: meta }
            end
          end
        end
      end
    end
  end
end

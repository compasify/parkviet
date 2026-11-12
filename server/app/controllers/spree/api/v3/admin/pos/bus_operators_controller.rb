# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # The store's bus operators (nhà xe), managed from a branch with
          # coach visits (`branch_id`).
          class BusOperatorsController < BaseController
            scoped_resource :pos_orders
            pos_permissions index: %w[read_pos_orders write_pos_orders]

            def index
              return if channel_rejected?

              branch = guard.branch!(current_store, params[:branch_id])
              guard.read!(current_store, current_user, branch)
              scope = Spree::Pos::BusOperator.for_store(current_store).order(:name)
              scope = scope.where(status: params[:status].to_s) if params[:status].present?
              if params[:q].present?
                scope = scope.where('name ILIKE ?', "%#{ActiveRecord::Base.sanitize_sql_like(params[:q].to_s.strip)}%")
              end
              render_page(scope)
            end

            def create
              command(status: :created) do |key|
                Spree::Pos::VehicleVisits::SaveBusOperator.call(store: current_store, staff: current_user, key: key,
                                                                branch_id: params[:branch_id], attributes: attributes)
              end
            end

            def update
              command do |key|
                Spree::Pos::VehicleVisits::SaveBusOperator.call(store: current_store, staff: current_user, key: key,
                                                                branch_id: params[:branch_id], attributes: attributes,
                                                                operator_id: params[:id])
              end
            end

            private

            def guard
              Spree::Pos::VehicleVisits::Guard
            end

            def command(status: :ok)
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              render json: { data: yield(key) }, status: status
            end

            def attributes
              params.permit(*Spree::Pos::VehicleVisits::SaveBusOperator::FIELDS).to_h
            end
          end
        end
      end
    end
  end
end

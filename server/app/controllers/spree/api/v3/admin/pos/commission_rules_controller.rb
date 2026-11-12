# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # A branch's coach commission rules (`branch_id`): amounts per
          # vehicle type and per guest, minimums and dates, general or for
          # one bus operator.
          class CommissionRulesController < BaseController
            scoped_resource :pos_orders
            pos_permissions index: %w[read_pos_orders write_pos_orders]

            def index
              return if channel_rejected?

              branch = guard.branch!(current_store, params[:branch_id])
              guard.read!(current_store, current_user, branch)
              scope = Spree::Pos::CommissionRule.for_store(current_store).where(branch_id: branch.id).
                      includes(:bus_operator, :branch).order(:status, Arel.sql('bus_operator_id NULLS FIRST'), id: :desc)
              scope = scope.where(status: params[:status].to_s) if params[:status].present?
              render_page(scope)
            end

            def create
              command(status: :created) do |key|
                Spree::Pos::VehicleVisits::SaveCommissionRule.call(store: current_store, staff: current_user, key: key,
                                                                   branch_id: params[:branch_id], attributes: attributes)
              end
            end

            def update
              command do |key|
                Spree::Pos::VehicleVisits::SaveCommissionRule.call(store: current_store, staff: current_user, key: key,
                                                                   branch_id: params[:branch_id], attributes: attributes,
                                                                   rule_id: params[:id])
              end
            end

            private

            def guard
              Spree::Pos::VehicleVisits::Guard
            end

            def command(status: :ok)
              return if channel_rejected? || currency_rejected?

              key = idempotency_key
              return if key.nil?

              render json: { data: yield(key) }, status: status
            end

            def attributes
              params.permit(*Spree::Pos::VehicleVisits::SaveCommissionRule::FIELDS,
                            per_vehicle_amounts: Spree::Pos::VehicleVisit::VEHICLE_TYPES).to_h
            end
          end
        end
      end
    end
  end
end

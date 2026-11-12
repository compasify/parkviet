# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # A canteen's sponsors: companies and schools that pay for meals on
          # their credit account, with their subsidy and statement day. The
          # statement of a period is the `meal_statement` report (and its
          # export); the debt is collected like any credit sale.
          class MealSponsorsController < BaseController
            scoped_resource :pos_orders
            pos_permissions index: %w[read_pos_orders write_pos_orders], show: %w[read_pos_orders write_pos_orders],
                            create: %w[write_pos_orders write_pos_topology], update: %w[write_pos_orders write_pos_topology]

            def index
              branch = guard.branch!(current_store, params[:branch_id])
              guard.read!(current_store, current_user, branch)
              scope = Spree::Pos::MealSponsor.for_store(current_store).includes(:customer_profile, :credit_account).order(:name)
              scope = scope.where(status: params[:status].to_s) if params[:status].present?
              render_page(scope)
            end

            def show
              branch = guard.branch!(current_store, params[:branch_id])
              guard.read!(current_store, current_user, branch)
              render json: { data: guard.sponsor!(current_store, params[:id]).to_pos }
            end

            def create
              command(status: :created) do |key|
                Spree::Pos::MealSponsors::Save.call(store: current_store, staff: current_user, key: key, branch_id: params[:branch_id],
                                                    attributes: attributes)
              end
            end

            def update
              command do |key|
                Spree::Pos::MealSponsors::Save.call(store: current_store, staff: current_user, key: key, branch_id: params[:branch_id],
                                                    attributes: attributes, sponsor_id: params[:id])
              end
            end

            private

            def guard
              Spree::Pos::MealAccounts::Guard
            end

            def command(status: :ok)
              return if channel_rejected? || currency_rejected?

              key = idempotency_key
              return if key.nil?

              render json: { data: yield(key) }, status: status
            end

            def attributes
              params.permit(*Spree::Pos::MealSponsors::Save::FIELDS, :credit_limit, :due_days).to_h
            end
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Workspaces
            # A canteen order: the eater on it and who pays what (`show`),
            # recording a meal (`swipe`, a 409 with `reason` when refused) and
            # paying the eater's part from their wallet (`pay`).
            class MealsController < BaseController
              scoped_resource :pos_orders

              def show
                return if channel_rejected?

                workspace = workspace!(params[:workspace_id])
                account = Spree::Pos::MealAccounts::Guard.for_workspace(workspace)
                render json: { data: { workspace_id: workspace.prefixed_id, meal: Spree::Pos::MealAccounts::Status.call(account, workspace),
                                       plan: Spree::Pos::MealAccounts::SplitPlan.call(workspace, account: account) } }
              end

              def swipe
                command(status: :created) do |key, workspace|
                  Spree::Pos::MealAccounts::Swipe.call(
                    **editing(workspace, key), code: params[:code], meal_account_id: params[:meal_account_id],
                                               input_method: params[:input_method], approval_id: params[:approval_id],
                                               override: ActiveModel::Type::Boolean.new.cast(params[:override_limit])
                  )
                end
              end

              def pay
                command do |key, workspace|
                  Spree::Pos::MealWallets::Pay.call(**editing(workspace, key), amount: params[:amount])
                end
              end

              private

              def command(status: :ok)
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                render json: { data: yield(key, workspace!(params[:workspace_id])) }, status: status
              end

              def editing(workspace, key)
                { workspace: workspace, staff: current_user, revision: params[:expected_revision].to_i,
                  lease_generation: params[:lease_generation].to_i, editor_id: params[:editor_id], key: key }
              end
            end
          end
        end
      end
    end
  end
end

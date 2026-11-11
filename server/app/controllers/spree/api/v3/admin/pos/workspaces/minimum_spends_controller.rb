# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Workspaces
            # Lets a VIP table off its minimum spend on one order, or puts it back.
            class MinimumSpendsController < BaseController
              scoped_resource :pos_orders

              def update
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Fnb::WaiveMinimumSpend.call(
                  workspace: workspace!(params[:workspace_id]), staff: current_user,
                  revision: params[:expected_revision].to_i, lease_generation: params[:lease_generation].to_i,
                  editor_id: params[:editor_id], key: key, waived: params[:waived], approval_id: params[:approval_id]
                )
                render json: { data: result }
              end
            end
          end
        end
      end
    end
  end
end
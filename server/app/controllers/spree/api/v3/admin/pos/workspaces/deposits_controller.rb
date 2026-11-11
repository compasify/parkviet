# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Workspaces
            # Paying a table order: the deposits of the booking seated at it
            # go towards the bill.
            class DepositsController < BaseController
              scoped_resource :pos_orders

              def apply
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Reservations::ApplyDeposit.call(
                  workspace: workspace!(params[:workspace_id]), staff: current_user,
                  revision: params[:expected_revision].to_i, lease_generation: params[:lease_generation].to_i,
                  editor_id: params[:editor_id], key: key
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

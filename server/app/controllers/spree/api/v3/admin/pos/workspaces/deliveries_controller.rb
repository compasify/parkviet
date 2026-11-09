# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Workspaces
            # Marks the draft as an order to deliver (deliverer, fee) or back
            # to a counter sale.
            class DeliveriesController < BaseController
              scoped_resource :pos_orders

              def assign
                run do |args|
                  Spree::Pos::Deliveries::Assign.call(**args, deliverer: params[:deliverer], fee: params[:fee])
                end
              end

              def clear
                run { |args| Spree::Pos::Deliveries::Assign.clear(**args) }
              end

              private

              def run
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = yield(
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

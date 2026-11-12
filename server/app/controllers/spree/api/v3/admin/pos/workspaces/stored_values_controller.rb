# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Workspaces
            # Part of an order's payment from a prepaid money card read at the
            # counter (`card_token`), under the order's lease.
            class StoredValuesController < BaseController
              scoped_resource :pos_orders

              def pay
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                workspace = workspace!(params[:workspace_id])
                data = Spree::Pos::StoredValueCards::Pay.call(
                  workspace: workspace, staff: current_user, revision: params[:expected_revision].to_i,
                  lease_generation: params[:lease_generation].to_i, editor_id: params[:editor_id], key: key,
                  card_token: params[:card_token], card_id: params[:card_id], amount: params[:amount]
                )
                render json: { data: data }
              end
            end
          end
        end
      end
    end
  end
end

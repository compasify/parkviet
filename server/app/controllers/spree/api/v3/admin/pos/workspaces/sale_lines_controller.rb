# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Workspaces
            # A table order's lines the kitchen has not been told about,
            # changed or taken off without a lease, checked against the
            # line's own `row_version`.
            class SaleLinesController < BaseController
              scoped_resource :pos_orders

              def update
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Workspaces::EditUnsentLine.call(
                  workspace: workspace!(params[:workspace_id]), staff: current_user, key: key, sale_line_id: params[:id],
                  row_version: params[:row_version], quantity: params[:quantity]
                )
                render json: { data: result }
              end

              def destroy
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Workspaces::RemoveUnsentLine.call(
                  workspace: workspace!(params[:workspace_id]), staff: current_user, key: key, sale_line_id: params[:id],
                  row_version: params[:row_version]
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

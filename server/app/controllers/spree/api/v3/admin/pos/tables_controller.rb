# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Orders at a table: seat guests, move to another table, merge into
          # another table's order, split items off to a new order.
          class TablesController < BaseController
            scoped_resource :pos_orders

            def open_table
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::Tables::Open.call(store: current_store, staff: current_user, key: key, editor_id: params[:editor_id],
                                                     branch_id: params[:branch_id], resource_id: params[:resource_id],
                                                     guest_count: params[:guest_count], add_order: params[:add_order])
              render json: { data: result }, status: :created
            end

            def move
              command(Spree::Pos::Tables::Move, resource_id: params[:resource_id])
            end

            def merge
              command(Spree::Pos::Tables::Merge, target_workspace_id: params[:target_workspace_id])
            end

            # y: seat gives every seat its own bill; otherwise the chosen lines move.
            def split
              return command(Spree::Pos::Tables::SplitBySeat, shared: params[:shared] || {}) if params[:by].to_s == 'seat'

              command(Spree::Pos::Tables::Split, sale_line_ids: Array(params[:sale_line_ids]), resource_id: params[:resource_id],
                                                 guest_count: params[:guest_count])
            end

            private

            def command(workflow, **arguments)
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              result = workflow.call(workspace: workspace!(params[:workspace_id]), staff: current_user,
                                     revision: params[:expected_revision].to_i, lease_generation: params[:lease_generation].to_i,
                                     editor_id: params[:editor_id], key: key, **arguments)
              render json: { data: result }
            end
          end
        end
      end
    end
  end
end

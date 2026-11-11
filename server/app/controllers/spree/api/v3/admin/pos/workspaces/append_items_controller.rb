# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Workspaces
            # A batch of items added to a table order by anyone serving it,
            # without a lease. Answers the workspace, with the lines of the
            # batch in `meta`.
            class AppendItemsController < BaseController
              scoped_resource :pos_orders

              def create
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                items = params[:items].is_a?(Array) ? params[:items].map { |row| item(row) } : params[:items]
                result = Spree::Pos::Workspaces::AppendItems.call(
                  workspace: workspace!(params[:workspace_id]), staff: current_user, key: key, items: items,
                  append_batch_id: params[:append_batch_id], device: @pos_device
                )
                render json: { data: result['workspace'], meta: { sale_line_ids: result['sale_line_ids'] } }
              end

              private

              def item(row)
                return row unless row.respond_to?(:permit)

                permitted = row.permit(:variant_id, :quantity, :note, :course, :seat, :hold, :buffet_tier_id, :buffet_cover_line_id).to_h
                permitted['modifiers'] = ItemsController.modifier_params(row) if row.key?(:modifiers)
                permitted
              end
            end
          end
        end
      end
    end
  end
end

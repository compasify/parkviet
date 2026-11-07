# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          module Workspaces
            class ItemsController < BaseController
              scoped_resource :pos_orders

              def create
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Workspaces::ManageLineItem.add(
                  workspace: workspace!(params[:workspace_id]), staff: current_user,
                  revision: params[:expected_revision].to_i, lease_generation: params[:lease_generation].to_i,
                  editor_id: params[:editor_id], key: key, variant_id: params[:variant_id], quantity: params[:quantity],
                  sale_quantity: params[:sale_quantity], sale_unit_code: params[:sale_unit_code] || params[:sale_unit],
                  lot_code: params[:lot_code], expiry_on: params[:expiry_on], serial_codes: params[:serial_codes],
                  price_override: params[:price_override], merge: ActiveModel::Type::Boolean.new.cast(params[:merge]),
                  measurement_event_id: params[:measurement_event_id], label_barcode: params[:label_barcode]
                )
                render json: { data: result }
              end

              def update
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Workspaces::ManageLineItem.update_quantity(
                  workspace: workspace!(params[:workspace_id]), staff: current_user,
                  revision: params[:expected_revision].to_i, lease_generation: params[:lease_generation].to_i,
                  editor_id: params[:editor_id], key: key, sale_line_id: params[:id], quantity: params[:quantity], sale_quantity: params[:sale_quantity]
                )
                render json: { data: result }
              end

              def destroy
                return if channel_rejected?

                key = idempotency_key
                return if key.nil?

                result = Spree::Pos::Workspaces::ManageLineItem.remove(
                  workspace: workspace!(params[:workspace_id]), staff: current_user,
                  revision: params[:expected_revision].to_i, lease_generation: params[:lease_generation].to_i,
                  editor_id: params[:editor_id], key: key, sale_line_id: params[:id]
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
